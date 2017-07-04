/*
 * Copyright (c) 2017 Red Hat, Inc. and others. All rights reserved.
 *
 * This program and the accompanying materials are made available under the
 * terms of the Eclipse Public License v1.0 which accompanies this distribution,
 * and is available at http://www.eclipse.org/legal/epl-v10.html
 */
package ch.vorburger.xtendbeans

import static com.google.common.truth.Truth.assertThat

import org.junit.Test

/**
 * Unit tests for ReflectUtils.
 *
 * @author Michael Vorburger.ch
 */
class ReflectUtilsTest {

    static class Static {
        def static String getStatic() { }
    }

    @Test def noStaticMethods() {
        assertThat(new ReflectUtils().getProperties(Static)).empty
    }

    static class Empty { }

    @Test def noObjectMethods() {
        assertThat(new ReflectUtils().getProperties(Empty)).empty
    }

    static class ObjectOverload {
        override equals(Object obj) {
            super.equals(obj)
        }

        override hashCode() {
            super.hashCode()
        }

    }

    @Test def noOverloadedObjectMethods() {
        assertThat(new ReflectUtils().getProperties(ObjectOverload)).empty
    }

    static class JustSetter {
        def void setSomething(String value) { }
    }

    @Test def justSetter() {
        val properties = new ReflectUtils().getProperties(JustSetter)
        assertThat(properties).hasLength(1)
        assertThat(properties.get(0).name).isEqualTo("something")
        assertThat(properties.get(0).type).isEqualTo(String)
        assertThat(properties.get(0).isReadable).isFalse
        assertThat(properties.get(0).isWriteable).isTrue
    }

    static class JustSetterOverride extends JustSetter {
        override void setSomething(String value) { }
    }

    @Test def justSetterOverride() {
        val properties = new ReflectUtils().getProperties(JustSetterOverride)
        assertThat(properties).hasLength(1)
    }

    static class GetterAndSetter {
        def String getSomething() { }
        def void setSomething(String value) { }
    }

    @Test def getterAndSetter() {
        val properties = new ReflectUtils().getProperties(GetterAndSetter)
        assertThat(properties).hasLength(1)
        assertThat(properties.get(0).name).isEqualTo("something")
        assertThat(properties.get(0).type).isEqualTo(String)
        assertThat(properties.get(0).isReadable).isTrue
        assertThat(properties.get(0).isWriteable).isTrue
    }

    static class TwoSettersSameNameDifferentType {
        def void setSomething(String value) { }
        def void setSomething(String[] value) { }
    }

    @Test def twoSettersSameNameDifferentType() {
        assertThat(new ReflectUtils().getProperties(TwoSettersSameNameDifferentType)).hasLength(2)
    }
}
