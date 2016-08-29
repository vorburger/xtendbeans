/*
 * Copyright (c) 2016 Red Hat, Inc. and others. All rights reserved.
 *
 * This program and the accompanying materials are made available under the
 * terms of the Eclipse Public License v1.0 which accompanies this distribution,
 * and is available at http://www.eclipse.org/legal/epl-v10.html
 */
package ch.vorburger.xtendbeans.tests;

import org.eclipse.xtext.xbase.lib.Procedures.Procedure1;

/**
 * Xtend extension method for nicer Xtend syntax for Builder classes.
 *
 * Usage in a *.xtend:
 * <pre>import static extension ch.vorburger.xtendbeans.tests.BuilderExtensions.operator_doubleGreaterThan</pre>
 *
 * @see Builder
 *
 * @author Michael Vorburger
 */
public class BuilderExtensions {

    public static <P extends Object, T extends Builder<P>> P operator_doubleGreaterThan(final T object,
            final Procedure1<? super T> block) {

        block.apply(object);
        return object.build();
    }

}
