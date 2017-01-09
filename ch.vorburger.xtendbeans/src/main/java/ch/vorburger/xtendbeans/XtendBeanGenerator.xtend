/*
 * Copyright (c) 2016 Red Hat, Inc. and others. All rights reserved.
 *
 * This program and the accompanying materials are made available under the
 * terms of the Eclipse Public License v1.0 which accompanies this distribution,
 * and is available at http://www.eclipse.org/legal/epl-v10.html
 */
package ch.vorburger.xtendbeans

import com.google.common.base.Preconditions
import com.google.common.collect.Multimap
import com.google.common.collect.Multimaps
import java.lang.reflect.Constructor
import java.lang.reflect.Method
import java.lang.reflect.Modifier
import java.lang.reflect.Parameter
import java.math.BigInteger
import java.util.Arrays
import java.util.Collections
import java.util.List
import java.util.Map
import java.util.Map.Entry
import java.util.Objects
import java.util.Optional
import java.util.Set
import java.util.function.Supplier
import org.eclipse.xtend.lib.annotations.Accessors
import org.eclipse.xtext.xbase.lib.Functions.Function0
import org.eclipse.xtext.xbase.lib.util.ReflectExtensions
import org.mockito.cglib.core.ReflectUtils
import org.objenesis.Objenesis
import org.objenesis.ObjenesisStd
import org.objenesis.instantiator.ObjectInstantiator

/**
 * Xtend new (Java Bean) object code generates.
 *
 * Generates highly readable Java Bean object initialization code
 * based on the <a href="https://eclipse.org/xtend/documentation/203_xtend_expressions.html#with-operator">
 * Xtend With Operator</a>.  This syntax is very well suited e.g. to capture expected objects in test code.
 *
 * <p>Xtend is a cool JVM language which itself
 * transpiles to Java source code.  There are <a href="https://eclipse.org/xtend/download.html">plugins
 * for Eclipse and IntelliJ IDEA to work with Xtend</a> available.  It is also possible
 * to use Gradle's Continuous Build mode on the Command Line to get Xtend translated to Java on the fly.
 * (It would even be imaginable to use Xtend's runtime interpreter to allow reading *.xtend files and create
 * objects from them, similar to a JSON or XML unmarshalling library, without any code generation.)
 *
 * <p>PS: This implementation is currently written with performance characteristics intended for
 * manually dumping objects when writing tests.  In particular, no Java Reflection results are
 * cached so far. It is thus not suitable for serializing objects in production.
 *
 * @author Michael Vorburger
 */
class XtendBeanGenerator {

    val Objenesis objenesis = new ObjenesisStd
    val ReflectExtensions xtendReflectExtensions = new ReflectExtensions

    def void print(Object bean) {
        System.out.println('''// Code auto. generated by Michael Vorburger's «class.name»''')
        System.out.println(getExpression(bean))
    }

    def String getExpression(Object bean) {
        stringify(bean).toString
    }

    def protected CharSequence getNewBeanExpression(Object bean) {
        val builderClass = getBuilderClass(bean)
        getNewBeanExpression(bean, builderClass)
    }

    def protected CharSequence getNewBeanExpression(Object bean, Class<?> builderClass) {
        val isUsingBuilder = isUsingBuilder(bean, builderClass)
        val propertiesByName = getBeanProperties(bean, builderClass)
        val propertiesByType = Multimaps.index(propertiesByName.values, [ Property p | p.type ])
        val constructorArguments = constructorArguments(bean, builderClass, propertiesByName, propertiesByType) // This removes some properties
        val filteredRemainingProperties = filter(propertiesByName.filter[name, property |
            ((property.isWriteable || property.isList) && !property.hasDefaultValue)].values)
        '''
        «IF isUsingBuilder»(«ENDIF»new «builderClass.simpleName»«constructorArguments»«IF !filteredRemainingProperties.empty» «getOperator(bean, builderClass)» [«ENDIF»
            «getPropertiesListExpression(filteredRemainingProperties)»
            «getPropertiesListExpression(getAdditionalSpecialProperties(bean, builderClass))»
            «getAdditionalInitializationExpression(bean, builderClass)»
        «IF !filteredRemainingProperties.empty»]«ENDIF»«IF isUsingBuilder»).build()«ENDIF»'''
    }

    def protected Iterable<Property> filter(Iterable<Property> properties) {
        properties
    }

    def protected Iterable<Property> getAdditionalSpecialProperties(Object bean, Class<?> builderClass) {
        Collections.emptyList
    }

    def protected getPropertiesListExpression(Iterable<Property> properties) '''
        «FOR property : properties»
        «property.name» «IF property.isList && !property.isWriteable»+=«ELSE»=«ENDIF» «stringify(property.valueFunction.get)»
        «ENDFOR»
    '''

    def protected CharSequence getAdditionalInitializationExpression(Object bean, Class<?> builderClass) {
        ""
    }

    def protected isUsingBuilder(Object bean, Class<?> builderClass) {
        !builderClass.equals(bean.class)
    }

    def protected getOperator(Object bean, Class<?> builderClass) {
        "=>"
    }

    def protected isList(Property property) {
        property.type.isAssignableFrom(List) // NOT || property.type.isArray
    }

    def protected Class<?> getBuilderClass(Object bean) {
        val beanClass = bean.class
        val Optional<Class<?>> optBuilderClass = if (beanClass.enclosingClass?.simpleName?.endsWith("Builder"))
            Optional.of(beanClass.enclosingClass)
        else
            getOptionalBuilderClassByAppendingBuilderToClassName(beanClass)
        optBuilderClass.filter([builderClass | isBuilder(builderClass)]).orElse(beanClass)
    }

    def protected boolean isBuilder(Class<?> builderClass) {
        // make sure that there are public constructors
        builderClass.getConstructors().length > 0
        // and even if there are, make sure that there are not only static methods
            && atLeastOneNonStatic(builderClass.methods)
    }

    def private boolean atLeastOneNonStatic(Method[] methods) {
        for (method : methods) {
            if (!Modifier.isStatic(method.modifiers)
                && !method.declaringClass.equals(Object)
            ) {
                return true
            }
        }
        return false;
    }

    def protected Optional<Class<?>> getOptionalBuilderClassByAppendingBuilderToClassName(Class<?> klass) {
        val classLoader = klass.classLoader
        val buildClassName = klass.name + "Builder"
        try {
            Optional.of(Class.forName(buildClassName, false, classLoader))
        } catch (ClassNotFoundException e) {
            Optional.empty
        }
    }

    @Deprecated // use getOptionalBuilderClassByAppendingBuilderToClassName() instead
    def protected Class<?> getBuilderClassByAppendingBuilderToClassName(Class<?> klass) {
        getOptionalBuilderClassByAppendingBuilderToClassName(klass).orElse(klass)
    }

    def protected constructorArguments(Object bean, Class<?> builderClass, Map<String, Property> propertiesByName, Multimap<Class<?>, Property> propertiesByType) {
        val constructors = builderClass.constructors
        if (constructors.isEmpty) ''''''
        else {
            val constructor = findSuitableConstructor(constructors, propertiesByName, propertiesByType)
            if (constructor == null) ''''''
            else {
                val parameters = constructor.parameters
                '''«FOR parameter : parameters BEFORE '(' SEPARATOR ', ' AFTER ')'»«getConstructorParameterValue(parameter, propertiesByName, propertiesByType)»«ENDFOR»'''
            }
        }
    }

    def protected Constructor<?> findSuitableConstructor(Constructor<?>[] constructors, Map<String, Property> propertiesByName, Multimap<Class<?>, Property> propertiesByType) {
        val possibleParameterByNameAndTypeMatchingConstructors = newArrayList
        val possibleParameterOnlyByTypeMatchingConstructors = newArrayList
        for (Constructor<?> constructor : constructors) {
            if (isSuitableConstructorByName(constructor, propertiesByName)) {
                possibleParameterByNameAndTypeMatchingConstructors.add(constructor)
            } else if (isSuitableConstructorByType(constructor, propertiesByType)) {
                // Fallback.. attempt to match just based on type, not name
                possibleParameterOnlyByTypeMatchingConstructors.add(constructor)
            }
        }
        val possibleConstructors =
            if (!possibleParameterByNameAndTypeMatchingConstructors.isEmpty)
                possibleParameterByNameAndTypeMatchingConstructors
            else
                possibleParameterOnlyByTypeMatchingConstructors
        val propertyNames = propertiesByName.keySet
        if (possibleConstructors.isEmpty)
            throw new IllegalStateException("No suitable constructor found, write a *Builder to help, as none of these match: "
                + Arrays.toString(constructors) + "; for: " + propertyNames)
        // Now filter it out to retain only those with the highest number of parameters
        val randomMaxParametersConstructor = possibleConstructors.maxBy[parameterCount]
        val retainedConstructors = possibleConstructors.filter[it.parameterCount == randomMaxParametersConstructor.parameterCount]
        if (retainedConstructors.size == 1)
            retainedConstructors.head
        else if (retainedConstructors.empty)
            throw new IllegalStateException("No suitable constructor found, write a *Builder to help, as none of these match: "
                + Arrays.toString(constructors) + "; for: " + propertyNames)
        else
            throw new IllegalStateException("More than 1 suitable constructor found; remove one or write a *Builder to help instead: "
                + retainedConstructors + "; for: " + propertyNames)
    }

    def protected isSuitableConstructorByName(Constructor<?> constructor, Map<String, Property> propertiesByName) {
        var suitableConstructor = true
        for (parameter : constructor.parameters) {
            val parameterName = getParameterName(parameter)
            if (!propertiesByName.containsKey(parameterName)) {
                suitableConstructor = false
            } else {
                val property = propertiesByName.get(parameterName)
                suitableConstructor = isParameterSuitableForProperty(parameter, property)
            }
        }
        suitableConstructor
    }

    def protected isSuitableConstructorByType(Constructor<?> constructor, Multimap<Class<?>, Property> propertiesByType) {
        var suitableConstructor = true
        for (parameter : constructor.parameters) {
            val matchingProperties = propertiesByType.get(parameter.type)
            if (matchingProperties.size != 1) {
                suitableConstructor = false
            } else {
                val property = matchingProperties.head
                suitableConstructor = isParameterSuitableForProperty(parameter, property)
            }
        }
        suitableConstructor
    }

    def protected isParameterSuitableForProperty(Parameter parameter, Property property) {
        if (!parameter.type.equals(property.type)) {
            return false
        } else if (property.hasDefaultValue) {
            return false
        } else {
            return true
        }
    }

    def protected getConstructorParameterValue(Parameter parameter, Map<String, Property> propertiesByName, Multimap<Class<?>, Property> propertiesByType) {
        val constructorParameterName = getParameterName(parameter)
        val propertyByName = propertiesByName.get(constructorParameterName)
        if (propertyByName != null) {
            propertiesByName.remove(propertyByName.name)
            return stringify(propertyByName.valueFunction.get)
        } else {
            // Fallback.. attempt to match just based on type, not name
            // NOTE In this case we already made sure earlier in isSuitableConstructorByType that there is exactly one matching by type
            val matchingProperties = propertiesByType.get(parameter.type)
            if (matchingProperties.size == 1) {
                val propertyByType = matchingProperties.head
                propertiesByName.remove(propertyByType.name)
                return stringify(propertyByType.valueFunction.get)
            } else if (matchingProperties.size > 1) {
                throw new IllegalStateException(
                    "Constructor parameter '" + constructorParameterName + "' of "
                    + parameter.declaringExecutable + " matches no property by name, "
                    + "but more than 1 property by type: "  + matchingProperties
                    + ", consider writing a *Builder; all bean's properties: "
                    + propertiesByName.keySet)
            } else { // matchingProperties.isEmpty
                throw new IllegalStateException(
                    "Constructor parameter '" + constructorParameterName + "' of "
                    + parameter.declaringExecutable + " not matching by name or type, "
                    + "consider writing a *Builder; bean's properties: "
                    + propertiesByName.keySet)
            }
        }
    }

    def protected getParameterName(Parameter parameter) {
        if (!parameter.isNamePresent)
            // https://docs.oracle.com/javase/tutorial/reflect/member/methodparameterreflection.html
            throw new IllegalStateException(
                "Needs javac -parameters; or, in Eclipse: 'Store information about method parameters (usable via "
                + "reflection)' in Window -> Preferences -> Java -> Compiler, for: " + parameter.declaringExecutable);
        parameter.name
    }

    def protected CharSequence stringify(Object object) {
        switch object {
            case null : "null"
            case object.class.isArray : stringifyArray(object)
            List<?>   : '''
                        #[
                            «FOR element : object SEPARATOR ','»
                            «stringify(element)»
                            «ENDFOR»
                        ]'''
            Set<?>    : '''
                        #{
                            «FOR element : object SEPARATOR ','»
                                «stringify(element)»
                            «ENDFOR»
                        }'''
            Map       : stringify(object.entrySet)
            Entry<?,?>: '''«stringify(object.key)» -> «stringify(object.value)»'''
            String    : '''"«object»"'''
            Integer   : '''«object»'''
            Long      : '''«object»L'''
            Boolean   : '''«object»'''
            Byte      : '''«object»'''
            Character : '''«"'"»«object»«"'"»'''
            Double    : '''«object»d'''
            Float     : '''«object»f'''
            Short     : '''«object» as short'''
            BigInteger: '''«object»bi'''
            Enum<?>   : '''«object.declaringClass.simpleName».«object.name»'''
            Class<?>  : stringify(object)
            default   : '''«getNewBeanExpression(object)»'''
        }
    }

    def protected stringify(Class<?> aClass) {
        // override for aClass.simpleName
        aClass.name
    }

    def protected CharSequence stringifyArray(Object array) {
        switch array {
            byte[]    : '''
                        #[
                            «FOR e : array SEPARATOR ','»
                            «stringify(e)»
                            «ENDFOR»
                        ]'''
            boolean[] : '''
                        #[
                            «FOR e : array SEPARATOR ','»
                            «stringify(e)»
                            «ENDFOR»
                        ]'''
            char[] : '''
                        #[
                            «FOR e : array SEPARATOR ','»
                            «stringify(e)»
                            «ENDFOR»
                        ]'''
            double[] : '''
                        #[
                            «FOR e : array SEPARATOR ','»
                            «stringify(e)»
                            «ENDFOR»
                        ]'''
            float[] : '''
                        #[
                            «FOR e : array SEPARATOR ','»
                            «stringify(e)»
                            «ENDFOR»
                        ]'''
            int[]     : '''
                        #[
                            «FOR e : array SEPARATOR ','»
                            «stringify(e)»
                            «ENDFOR»
                        ]'''
            long[]    : '''
                        #[
                            «FOR e : array SEPARATOR ','»
                            «stringify(e)»
                            «ENDFOR»
                        ]'''
            short[]    : '''
                        #[
                            «FOR e : array SEPARATOR ','»
                            «stringify(e)»
                            «ENDFOR»
                        ]'''
            Object[]  : '''
                        #[
                            «FOR e : array SEPARATOR ','»
                            «stringify(e)»
                            «ENDFOR»
                        ]'''
        }
    }

    def protected Map<String, Property> getBeanProperties(Object bean, Class<?> builderClass) {
        // could also implement using:
        //   * org.eclipse.xtext.xbase.lib.util.ReflectExtensions.get(Object, String)
        //   * org.codehaus.plexus.util.ReflectionUtils
        //   * org.springframework.util.ReflectionUtils
        //   * other reflection libraries
        val defaultValuesBean = newEmptyBeanForDefaultValues(builderClass)
        val propertyDescriptors = ReflectUtils.getBeanProperties(builderClass)
        val propertiesMap = newLinkedHashMap()
        for (propertyDescriptor : propertyDescriptors) {
            if (isPropertyConsidered(builderClass, propertyDescriptor.name, propertyDescriptor.propertyType))
                propertiesMap.put(propertyDescriptor.name, new Property(
                    propertyDescriptor.name,
                    isPropertyWriteable(builderClass, propertyDescriptor.name, propertyDescriptor.propertyType),
                    propertyDescriptor.propertyType,
                    [ | xtendReflectExtensions.invoke(bean, propertyDescriptor.readMethod.name)],
                    if (!Objects.equals(null, defaultValuesBean))
                        try {
                            xtendReflectExtensions.invoke(defaultValuesBean, propertyDescriptor.readMethod.name)
                        } catch (Throwable t) {
                            null
                        }
                    else
                        null
                ))
        }
        return propertiesMap
    }

    def protected boolean isPropertyWriteable(Class<?> builderClass, String propertyName, Class<?> type) {
        // do NOT use propertyDescriptor.writeMethod != null
        // because java.beans.PropertyDescriptor ignores setters that don't return void, as typically found on Builder classes
        try {
            builderClass.getMethod("set" + propertyName.toFirstUpper, type)
            true;
        } catch (NoSuchMethodException e) {
            false;
        }
    }

    def protected boolean isPropertyConsidered(Class<?> builderClass, String propertyName, Class<?> type) {
        true
    }

    def protected newEmptyBeanForDefaultValues(Class<?> builderClass) {
        try {
            builderClass.newInstance
        } catch (ReflectiveOperationException e) {
            // http://objenesis.org
            val ObjectInstantiator<?> builderClassInstantiator = objenesis.getInstantiatorOf(builderClass)
            builderClassInstantiator.newInstance
        }
    }

    @Accessors(PUBLIC_GETTER)
    protected static class Property {
        final String name
        final boolean isWriteable
        final Class<?> type
        final Supplier<Object> valueFunction
        final Object defaultValue

        // @Accessors and @FinalFieldsConstructor don't do null checks
        new(String name, boolean isWriteable, Class<?> type, Function0<Object> valueFunction, Object defaultValue) {
            this.name = Preconditions.checkNotNull(name, "name")
            this.isWriteable = isWriteable
            this.type = Preconditions.checkNotNull(type, "type")
            this.valueFunction = Preconditions.checkNotNull(valueFunction, "valueFunction")
            this.defaultValue = defaultValue
        }

        def boolean hasDefaultValue() {
            val value = try {
                valueFunction.get
            } catch (Throwable t) {
                null
            }
            return if (value == null && defaultValue == null) {
                true
            } else if (value != null && defaultValue != null) {
                if (!type.isArray)
                    valueFunction.get == defaultValue
                else switch defaultValue {
                    byte[]    : Arrays.equals(value as byte[],    defaultValue as byte[])
                    boolean[] : Arrays.equals(value as boolean[], defaultValue as boolean[])
                    char[]    : Arrays.equals(value as char[],    defaultValue as char[])
                    double[]  : Arrays.equals(value as double[],  defaultValue as double[])
                    float[]   : Arrays.equals(value as float[],   defaultValue as float[])
                    int[]     : Arrays.equals(value as int[],     defaultValue as int[])
                    long[]    : Arrays.equals(value as long[],    defaultValue as long[])
                    short[]   : Arrays.equals(value as short[],   defaultValue as short[])
                    Object[]  : Arrays.deepEquals(value as Object[], defaultValue as Object[])
                    default   : value.equals(defaultValue)
                }
            } else if (value == null || defaultValue == null) {
                false
            }
        }

        override toString() {
            '''Property{name: «name», isWriteable: «isWriteable», type: «type»}'''
        }
    }
}
