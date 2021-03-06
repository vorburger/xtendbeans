/*
 * Copyright (c) 2016 Red Hat, Inc. and others. All rights reserved.
 *
 * This program and the accompanying materials are made available under the
 * terms of the Eclipse Public License v1.0 which accompanies this distribution,
 * and is available at http://www.eclipse.org/legal/epl-v10.html
 */
package ch.vorburger.xtendbeans.tests

import java.util.List
import org.eclipse.xtend.lib.annotations.Accessors
import org.junit.Ignore
import org.junit.Test
import ch.vorburger.xtendbeans.tests.XtendBeanGeneratorTest.Bean
import ch.vorburger.xtendbeans.tests.XtendBeanGeneratorTest.BeanWithMultiConstructor
import ch.vorburger.xtendbeans.tests.XtendBeanGeneratorTest.BeanWithMultiConstructorBuilder
import ch.vorburger.xtendbeans.XtendBeanGenerator

import static org.junit.Assert.assertEquals
import static org.junit.Assert.assertFalse
import static org.junit.Assert.assertTrue
import java.util.HashMap
import java.util.HashSet
import java.io.File

/**
 * Unit test for basic XtendBeanGenerator.
 *
 * @see XtendBeanGeneratorTest for more advanced tests &amp; examples.
 *
 * @author Michael Vorburger
 */
class XtendBeanGeneratorBaseTest {

    static private class TestableXtendBeanGenerator extends XtendBeanGenerator {
        // Make some protected methods public so that we can test them here
        override public getBuilderClass(Object bean) {
            super.getBuilderClass(bean)
        }
    }

    val g = new TestableXtendBeanGenerator()

    @Test def void simplestNumberExpression() {
        assertThatEndsWith(g.getExpression(123), "123")
    }

    @Test def void simpleCharacter() {
        assertThatEndsWith(g.getExpression(new Character("c")), "'c'")
    }

    @Test def void nullCharacter() {
        var Character nullCharacter
        assertThatEndsWith(g.getExpression(nullCharacter), "null")
    }

    @Test def void defaultCharacter() {
        var char defaultCharacter
        assertThatEndsWith(g.getExpression(defaultCharacter), "")
    }

    @Test def void emptyString() {
        assertThatEndsWith(g.getExpression(""), "")
    }

    @Test def void string() {
        assertThatEndsWith(g.getExpression("hello, World"), "\"hello, World\"")
    }

    // This is a possible idea for future implementation; not currently required
    @Ignore @Test def void charArray() {
        assertThatEndsWith(g.getExpression("hello, World".toCharArray()), "\"hello, World\".toCharArray()")
    }

    @Test def void aNull() {
        assertThatEndsWith(g.getExpression(null), "null")
    }

    @Test def void aClass() {
        assertEquals("java.lang.String", g.getExpression(String))
    }

    @Test def void anonymous() {
        assertEquals("new ch.vorburger.xtendbeans.tests.XtendBeanGeneratorBaseTest$1",
            g.getExpression(new Object() { /* anon inner class */ })
        )
    }

    @Test def void emptyList() {
        assertThatEndsWith(g.getExpression(#[]), "#[\n]")
    }

    def List<String> aList() { #["hi", "ho"] }
    @Test def void list() {
        assertThatEndsWith(g.getExpression(aList()), "#[\n    \"hi\",\n    \"ho\"\n]")
    }

    def Iterable<String> anIterable() { #["hi"] + #["ho"] }
    @Test def void iterable() {
        assertThatEndsWith(g.getExpression(anIterable()), "#[\n    \"hi\",\n    \"ho\"\n]")
    }

    @Test def void map() {
        assertEquals("#{\n    \"hi\" -> \"saluton\",\n    \"CU\" -> \"gis baldau\"\n}",
            g.getExpression(#{"hi" -> "saluton", "CU" -> "gis baldau" })
        )
    }

    @Test def void emptyXtendSetOrMap() {
        assertEquals("#{\n}", g.getExpression(#{}))
    }

    @Test def void emptyMap() {
        assertEquals("#{\n}", g.getExpression(new HashMap()))
    }

    @Test def void emptySet() {
        assertEquals("#{\n}", g.getExpression(new HashSet()))
    }

    @Test def void set() {
        assertEquals("#{\n    123\n}", g.getExpression(#{ 123 }))
    }

    @Test def void hashSet() {
        assertEquals("#{\n    123\n}", g.getExpression(new HashSet(#{ 123 })))
    }

    @Test def void findEnclosingBuilderClass() {
        assertEquals(BeanWithBuilderBuilder,
            g.getBuilderClass(new BeanWithBuilderBuilder().build))
    }

    @Test def void findAdjacentBuilderClass() {
        assertEquals(BeanWithMultiConstructorBuilder,
            g.getBuilderClass(new BeanWithMultiConstructor(123)))
    }

    @Test def void emptyComplexBean() {
        assertEquals("new Bean", g.getExpression(new Bean))
    }

    @Test def void neverCallOnlyGettersIfThereIsNoSetter() {
        assertEquals("new ExplosiveBean", g.getExpression(new ExplosiveBean))
    }

    @Test def void neverCallOnlyGettersIfThereIsNoSetterEvenIfItDoesNotThrowAnException() {
        val bean = new WeirdBean
        assertEquals("new WeirdBean", g.getExpression(bean))
        assertFalse(bean.wasGetterCalled)
    }

    @Test def void testEnum() {
        assertEquals("TestEnum.a", g.getExpression(TestEnum.a))
    }

    @Test def void listBean() {
        val b = new ListBean => [
            strings += #[ "hi", "bhai" ]
        ]
        assertEquals(
            '''
            new ListBean => [
                strings += #[
                    "hi",
                    "bhai"
                ]
            ]'''.toString, g.getExpression(b))
    }

    @Test def void listBean2() {
        // If there is a List setter, then prefer that over get().add(), so = over +=
        val b = new ListBean2 => [
            strings = #[ "hi", "bhai" ]
        ]
        assertEquals(
            '''
            new ListBean2 => [
                strings = #[
                    "hi",
                    "bhai"
                ]
            ]'''.toString, g.getExpression(b))
    }

    @Test def void arrayBean() {
        val b = new ArrayBean => [
            strings = #[ "hi", "bhai" ]
        ]
        assertEquals(
            '''
            new ArrayBean => [
                strings = #[
                    "hi",
                    "bhai"
                ]
            ]'''.toString, g.getExpression(b))
    }

    @Test def void defaultArray() {
        val b = new ArrayBean
        assertEquals("new ArrayBean", g.getExpression(b))
    }

    @Test def void nullArray() {
        val b = new ArrayBean => [
            strings = null
        ]
        assertEquals("new ArrayBean => [\n    strings = null\n]", g.getExpression(b))
    }

    @Test def void primitiveArrayBean() {
        val b = new PrimitiveArrayBean => [
            ints = #[ 123, 456 ]
        ]
        assertEquals(
            '''
            new PrimitiveArrayBean => [
                ints = #[
                    123,
                    456
                ]
            ]'''.toString, g.getExpression(b))
    }

    @Test def void defaultPrimitiveArrayBean() {
        val b = new PrimitiveArrayBean
        assertEquals("new PrimitiveArrayBean", g.getExpression(b))
    }

    @Test def void nullPrimitiveArrayBean() {
        val b = new PrimitiveArrayBean => [
            ints = null
        ]
        assertEquals("new PrimitiveArrayBean => [\n    ints = null\n]", g.getExpression(b))
    }

    @Test def void arrayBeanList() {
        val b = new ArrayBeanList => [
            strings = #[ "hi", "bhai" ]
            longs = #[ 12, 34 ]
        ]
        assertEquals(
            '''
            (new ArrayBeanListBuilder => [
                longs = #[
                    12L,
                    34L
                ]
                strings += #[
                    "hi",
                    "bhai"
                ]
            ]).build()'''.toString, g.getExpression(b))
    }

    @Ignore // This messy mix of bean with array properties and *Builder with List of it instead is a mess and impossible to support nicely, so just don't do that
    @Test def void nullArrayBeanList() {
        val b = new ArrayBeanList => [
            strings = null
            longs = null
        ]
        assertEquals("new ArrayBeanBuilder", g.getExpression(b))
    }

    @Test def void emptyArrayToCheckCorrectDefaulting() {
        val b = new ArrayBean
        assertEquals("new ArrayBean", g.getExpression(b))
    }

    def private void assertThatEndsWith(String string, String endsWith) {
        assertTrue("'''" + string + "''' expected to endWith '''" + endsWith + "'''", string.endsWith(endsWith));
    }

    public static enum TestEnum { a, b, c }

    public static class ListBean {
        @Accessors(PUBLIC_GETTER) /* but no setter */
        List<String> strings = newArrayList
    }

    public static class ListBean2 {
        @Accessors
        List<String> strings = newArrayList
    }

    @Accessors
    public static class ArrayBean {
        String[] strings = newArrayList
    }

    @Accessors
    public static class PrimitiveArrayBean {
        int[] ints = newArrayList
    }

    @Accessors(PUBLIC_GETTER) // with Builder, below!
    public static class ArrayBeanList {
        String[] strings
        long[] longs
    }

    public static class ArrayBeanListBuilder {
        @Accessors(PUBLIC_GETTER) List<String> strings = newArrayList
        @Accessors List<Long> longs = newArrayList

        def public build() {
            new ArrayBeanList() => [
                it.strings = this.strings
                it.longs = this.longs
            ]
        }
    }

    public static class ExplosiveBean {
        def String getOnlyGetter() {
            throw new IllegalStateException("Explosion, just for testing")
        }
    }

    public static class WeirdBean {
        boolean wasGetterCalled
        def String getOnlyGetter() {
            wasGetterCalled = true
            "hello, world"
        }
    }

}
