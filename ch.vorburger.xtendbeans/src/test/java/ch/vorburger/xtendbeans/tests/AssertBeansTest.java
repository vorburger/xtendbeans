/*
 * Copyright (c) 2016 Red Hat, Inc. and others. All rights reserved.
 *
 * This program and the accompanying materials are made available under the
 * terms of the Eclipse Public License v1.0 which accompanies this distribution,
 * and is available at http://www.eclipse.org/legal/epl-v10.html
 */
package ch.vorburger.xtendbeans.tests;

import ch.vorburger.xtendbeans.AssertBeans;
import org.junit.ComparisonFailure;
import org.junit.Test;

/**
 * Test for {@link AssertBeans}.
 *
 * @author Michael Vorburger
 */
public class AssertBeansTest {

    @Test(expected=ComparisonFailure.class) // but not NullPointerException
    public void testNullExpectedText() {
        AssertBeans.assertEqualByText(null, null);
    }
}
