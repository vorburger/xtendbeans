/*
 * Copyright (c) 2017 Red Hat, Inc. and others. All rights reserved.
 *
 * This program and the accompanying materials are made available under the
 * terms of the Eclipse Public License v1.0 which accompanies this distribution,
 * and is available at http://www.eclipse.org/legal/epl-v10.html
 */
package ch.vorburger.xtendbeans

import com.google.common.base.Preconditions
import java.lang.reflect.Method
import java.lang.reflect.Modifier
import java.util.HashMap
import org.eclipse.xtend.lib.annotations.ToString
import org.slf4j.Logger
import org.slf4j.LoggerFactory

/**
 * Reflection Utilities.
 *
 * Unlike e.g. java.beans.Introspector, this:
 *  1. also finds properties which have only a setter, but no getter (as is common in some Builders):
 *  2. also finds "chainable" setters which return this instead of void
 *  3. allows overloaded setters with different types
 *
 * Just like XtendBeanGenerator, this is not performance optimized (does not cache results of introspection by reflection).
 *
 * @author Michael Vorburger.ch
 */
package class ReflectUtils {

    def BeanProperty[] getProperties(Class<?> classType) {
        Preconditions.checkArgument(!classType.isInterface(), "interface not supported")
        val propertiesMap = new HashMap<Pair<String, Class<?>>, BeanProperty>
        var Class<?> searchType = classType
        while (searchType !== null) {
            val methods = searchType.declaredMethods // no need here, we'll do it at the end: .sortWith([method1, method2 | method1.name.compareTo(method2.name)])
            for (Method method : methods) {
                if (Modifier.isPublic(method.getModifiers())
                 && !Modifier.isStatic(method.getModifiers())
                 && !Modifier.isAbstract(method.getModifiers())
                 && !isObjectMethod(method)
                ) {
                    // Check if it looks like a setter of some sort
                    if (method.parameterTypes.length == 1) {
                        // NB: We do, intentionally, not check if this methods returns void
                        val name = dropPrefix(method.name, "set")
                        val propertyType = method.parameterTypes.get(0)
                        propertiesMap.compute(Pair.of(name, propertyType), [nameClassPairKey, getterOnlyProperty |
                            if (getterOnlyProperty === null)
                                new BeanProperty(name, propertyType, true, false)
                            else if (getterOnlyProperty.type == propertyType)
                                new BeanProperty(name, propertyType, true, getterOnlyProperty.isReadable)
                            else
                                throw new IllegalArgumentException("Class has a setter and getter where type does not match: " + getterOnlyProperty)
                        ])

                    // Check if it looks like a getter of some sort
                    } else if (method.parameterTypes.length == 0
                            && method.returnType !== Void.TYPE ) {
                        val name = dropPrefix(method.name, "get")
                        val propertyType = method.returnType
                        propertiesMap.compute(Pair.of(name, propertyType), [nameClassPairKey, setterOnlyProperty |
                            if (setterOnlyProperty === null)
                                new BeanProperty(name, propertyType, false, true)
                            else if (setterOnlyProperty.type == propertyType)
                                new BeanProperty(name, propertyType, setterOnlyProperty.isWriteable, true)
                            else
                                throw new IllegalArgumentException("Class has a setter and getter where type does not match: " + setterOnlyProperty)
                        ])
                    }
                }
            }
            searchType = searchType.superclass
            if (searchType == Object)
                searchType = null
        }
        // The order in which declaredMethods returned methods above is unpredictable (changes from run to run!), so:
        propertiesMap.values.sortWith([p1, p2 | p1.name.compareTo(p2.name)])
    }

    def private isObjectMethod(Method method) {
           (method.name == "equals"   && method.parameterTypes.length == 1 && method.returnType == Boolean.TYPE)
        || (method.name == "hashCode" && method.parameterTypes.length == 0 && method.returnType == Integer.TYPE)
        || (method.name == "toString" && method.parameterTypes.length == 0 && method.returnType == String)
        || (method.name == "clone"    && method.parameterTypes.length == 0 && method.returnType == Object)
        || (method.name == "finalize" && method.parameterTypes.length == 0 && method.returnType == Void.TYPE)
    }

    def private String dropPrefix(String value, String prefix) {
        if (value.startsWith(prefix)) {
            value.substring(prefix.length).toFirstLower
        } else {
            value
        }
    }

    @ToString
    static class BeanProperty {
        val static Logger LOG = LoggerFactory.getLogger(BeanProperty)

        public val String name
        public val Class<?> type
        /** Indicates if the property is writable on the class passed to getProperties. */
        public val boolean isWriteable
        /**
         * Indicates if the property is readable on the class passed to getProperties.
         * Note that even if this is false, it may still be readable on another class,
         * so invokeGetter may still work, if the object passed there; this is used
         * to read properties from beans even if their Builder has no getter. */
        public val boolean isReadable

        // @Accessors and @FinalFieldsConstructor don't do null checks
        new(String name, Class<?> type, boolean isWriteable, boolean isReadable) {
            this.name = Preconditions.checkNotNull(name, "name")
            this.type = Preconditions.checkNotNull(type, "type")
            this.isWriteable = isWriteable
            this.isReadable = isReadable
        }

        def Object invokeGetter(Object object) {
            if (object !== null) {
                try {
                    val method = object.class.getMethod("get" + name.toFirstUpper)
                    method.accessible = true
                    method.invoke(object)
                } catch (NoSuchMethodException e) {
                    // do not LOG these; it just there's no getter
                    null
                } catch (Throwable t) {
                    LOG.warn("Caught Throwable when invoking getter (returning null)", t)
                    null
                }
            } else {
                null
            }
        }
    }
}
