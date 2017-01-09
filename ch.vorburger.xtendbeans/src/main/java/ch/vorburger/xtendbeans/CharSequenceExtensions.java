/*
 * Copyright (c) 2017 Red Hat, Inc. and others. All rights reserved.
 *
 * This program and the accompanying materials are made available under the
 * terms of the Eclipse Public License v1.0 which accompanies this distribution,
 * and is available at http://www.eclipse.org/legal/epl-v10.html
 */
package ch.vorburger.xtendbeans;

/**
 * Utility for {@link CharSequence}.
 *
 * This is written in Java instead of Xtend because Xtend is a PITA for this kind of lower level utility;
 * its auto conversion of == to org.eclipse.xtext.xbase.lib.ObjectExtensions.operator_equals(Object, Object)
 * and '\n' (Java char) to "\n" (String) is very confusing, and makes this kind of code hard (because
 * the comparison would always fail, because a '\n' is never equal to a "\n").
 *
 * @author Michael Vorburger
 */
class CharSequenceExtensions {

    // "chomp" as in Perl or https://commons.apache.org/proper/commons-lang/apidocs/org/apache/commons/lang3/StringUtils.html#chomp-java.lang.String-
    static CharSequence chomp(CharSequence cs) {
        if (cs != null) {
            final int len = cs.length();
            if (len > 1 && cs.charAt(len - 2) == '\r' && cs.charAt(len - 1) == '\n') {
                return cs.subSequence(0, len - 2);
            } else if (len > 0 && cs.charAt(len - 1) == '\n') {
                return cs.subSequence(0, len - 1);
            }
        }
        return cs;
    }
}
