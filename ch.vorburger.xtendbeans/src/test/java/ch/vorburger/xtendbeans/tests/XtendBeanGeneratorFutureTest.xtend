/*
 * Copyright (c) 2017 Red Hat, Inc. and others. All rights reserved.
 *
 * This program and the accompanying materials are made available under the
 * terms of the Eclipse Public License v1.0 which accompanies this distribution,
 * and is available at http://www.eclipse.org/legal/epl-v10.html
 */
package ch.vorburger.xtendbeans.tests

import org.eclipse.xtend.lib.annotations.Accessors
import org.junit.Ignore
import org.junit.Test

import static org.junit.Assert.assertEquals
import ch.vorburger.xtendbeans.XtendBeanGenerator

/**
 * Test for possible future features of XtendBeanGenerator.
 *
 * @author Michael Vorburger
 */
class XtendBeanGeneratorFutureTest {

    val g = new XtendBeanGenerator()

    @Test def void privateConstructorFieldBeanWithNull() {
        val b = new PrivateConstructorFieldBean
        assertEquals("new PrivateConstructorFieldBean", g.getExpression(b))
    }

    @Ignore // This is a possible idea for future implementation; not currently required
    @Test def void privateConstructorFieldBeanWithValue() {
        val b = new PrivateConstructorFieldBean
        b.privateConstructorBean = PrivateConstructorValueBeanWithFactoryMethod.someFactory("yolo")
        assertEquals('''
            new PrivateConstructorFieldBean => [
                privateConstructorBean = PrivateConstructorBean.someFactory("yolo")
            ]'''.toString, g.getExpression(b))
    }

    @Accessors
    public static class PrivateConstructorFieldBean {
        PrivateConstructorValueBeanWithFactoryMethod privateConstructorBean
    }

    public static class PrivateConstructorValueBeanWithFactoryMethod {
        String value
        private new() { }
        def static PrivateConstructorValueBeanWithFactoryMethod someFactory(String value) {
            val valueBean = new PrivateConstructorValueBeanWithFactoryMethod
            valueBean.value = value
            valueBean
        }
        def String getValue() {
            value
        }
    }

}
