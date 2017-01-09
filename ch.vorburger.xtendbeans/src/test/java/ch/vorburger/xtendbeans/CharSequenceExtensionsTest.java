/*
 * Copyright (c) 2017 Red Hat, Inc. and others. All rights reserved.
 *
 * This program and the accompanying materials are made available under the
 * terms of the Eclipse Public License v1.0 which accompanies this distribution,
 * and is available at http://www.eclipse.org/legal/epl-v10.html
 */
package ch.vorburger.xtendbeans;

import static org.junit.Assert.*;

import org.junit.Test;

/**
 * Unit test for (package local utility) CharSequenceExtensions.
 *
 * @author Michael Vorburger
 */
public class CharSequenceExtensionsTest {

    @Test public void fixTrailingNewLineIfSingleLine() {
        assertEquals("", CharSequenceExtensions.chomp(""));
        assertEquals("hello, world", CharSequenceExtensions.chomp("hello, world"));
        assertEquals("hello, world", CharSequenceExtensions.chomp("hello, world\n"));
        assertEquals("hello, world", CharSequenceExtensions.chomp("hello, world\r\n"));
        assertEquals("hello, world", CharSequenceExtensions.chomp("hello, world" + System.getProperty("line.separator")));
        assertEquals("", CharSequenceExtensions.chomp("\n"));
        assertEquals("", CharSequenceExtensions.chomp("\r\n"));
    }

}
