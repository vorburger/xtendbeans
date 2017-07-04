/*
 * Copyright (c) 2017 Red Hat, Inc. and others. All rights reserved.
 *
 * This program and the accompanying materials are made available under the
 * terms of the Eclipse Public License v1.0 which accompanies this distribution,
 * and is available at http://www.eclipse.org/legal/epl-v10.html
 */
package ch.vorburger.xtendbeans.tests

import org.eclipse.xtend.lib.annotations.Accessors
import org.eclipse.xtend.lib.annotations.FinalFieldsConstructor

// Do NOT have any @Accessors(PUBLIC_GETTER)
class BeanWithNoGettersBuilderBuilder implements Builder<BeanWithBuilder> {

    String name

    def BeanWithNoGettersBuilderBuilder setName(String name) {
        this.name = name
        return this
    }

    override BeanWithBuilder build() {
        new BeanWithBuilderImpl(name)
    }

    @FinalFieldsConstructor
    @Accessors(PUBLIC_GETTER)
    static private class BeanWithBuilderImpl implements BeanWithBuilder {
        final String name
    }

}
