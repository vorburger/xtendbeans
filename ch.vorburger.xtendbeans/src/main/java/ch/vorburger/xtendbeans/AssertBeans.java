/*
 * Copyright (c) 2016 Red Hat, Inc. and others. All rights reserved.
 *
 * This program and the accompanying materials are made available under the
 * terms of the Eclipse Public License v1.0 which accompanies this distribution,
 * and is available at http://www.eclipse.org/legal/epl-v10.html
 */
package ch.vorburger.xtendbeans;

import org.junit.Assert;
import org.junit.ComparisonFailure;

/**
 * Utility similar to core JUnit's {@link Assert} but with particular support
 * for Java Beans &amp; Value Objects, based on the {@link XtendBeanGenerator}.
 *
 * <p>
 * These methods can be used directly:
 * <code>AssertBeans.assertEqualBeans(...)</code>, however, they read better if
 * they are referenced through static import:<br>
 *
 * <pre>
 * import static ch.vorburger.xtendbeans.AssertBeans.assertEqualBeans;
 *    ...
 *    assertEqualBeans(expected, actual);
 * </pre>
 *
 * The expected object would typically have been defined in a *.xtend source
 * file, and the actual object would typically be an instance of something
 * created by a test.  Any mismatch will be shown in a very readable textual
 * format. This format is suitable for copy/paste into an for the expected
 * object.
 *
 * <p>
 * Note that your IDE can support you to create the static import. For example
 * in Eclipse, type: AssertBeans &lt;Ctrl-Space&gt; (will import AssertBeans,
 * non static) . &lt;Ctrl-Space&gt; (will auto-complete assertEqualBeans). Now
 * cursor back to highlight "assertEqualBeans" and Ctrl-Shift-M on it will turn
 * it into a static import.
 *
 * @author Michael Vorburger
 */
public final class AssertBeans {

    private final static XtendBeanGenerator generator = new XtendBeanGenerator();

    /**
     * Asserts that two JavaBean or immutable Value Objects are equal. If they are not, throws an
     * {@link ComparisonFailure} with highly readable textual representations of the objects' properties.
     *
     * @param expected
     *            expected value
     * @param actual
     *            the value to check against <code>expected</code>
     */
    public static void assertEqualBeans(Object expected, Object actual) throws ComparisonFailure {
        // Do *NOT* rely on expected/actual java.lang.Object.equals(Object);
        // and obviously neither e.g. java.util.Objects.equals(Object, Object) based on. it
        final String expectedAsText = generator.getExpression(expected);
        assertEqualByText(expectedAsText, actual);
    }

    public static void assertEqualByText(String expectedText, Object actual) throws ComparisonFailure {
        final String actualText = generator.getExpression(actual);
        if (!expectedText.equals(actualText)) {
            throw new ComparisonFailure("Expected and actual beans do not match", expectedText, actualText);
        }
    }

    private AssertBeans() {
    }
}
