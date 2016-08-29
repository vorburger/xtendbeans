/*
 * Copyright (c) 2016 Red Hat, Inc. and others. All rights reserved.
 *
 * This program and the accompanying materials are made available under the
 * terms of the Eclipse Public License v1.0 which accompanies this distribution,
 * and is available at http://www.eclipse.org/legal/epl-v10.html
 */
package ch.vorburger.xtendbeans.tests;

/**
 * Builder of T.
 *
 * This is just an example of a possible Builder interface in some framework,
 * used by the test. It is NOT necessary for this library that a class like
 * BeanWithBuilderBuilder to implement an interface like this one.  If it
 * does however, then the XtendBeanGenerator can return code using something
 * like the {@link BuilderExtensions#operator_doubleGreaterThan(Builder, org.eclipse.xtext.xbase.lib.Procedures.Procedure1)}.
 *
 * See
 * {@link ch.vorburger.xtendbeans.tests.XtendBeanGeneratorTest#beanWithBuilderAndExtensionMethod()}
 * for an illustration how to use this.
 *
 * @author Michael Vorburger
 */
public interface Builder<T> {

    T build();

}
