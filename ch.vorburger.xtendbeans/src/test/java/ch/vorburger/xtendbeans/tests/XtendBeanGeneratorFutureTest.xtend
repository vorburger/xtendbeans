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
    // NB, if ever implementing: The IllegalAccessException: Class .. can not access a member of .. with modifiers "private")
    // which this currently causes is NOT the real issue! That could be fixed easy enough, e.g. by catch (InstantiationException | IllegalAccessException e)
    // instead of just the current catch (InstantiationException e) in newEmptyBeanForDefaultValues().
    // But the real problem is that of course that should never be called in the first place...
    // more work would be required to support *Factory kind of pattern classes with static create method,
    // instead of (in addition to, really; based on some TBD heuristics which to use) the current
    // *Builder or constructor approach.
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
