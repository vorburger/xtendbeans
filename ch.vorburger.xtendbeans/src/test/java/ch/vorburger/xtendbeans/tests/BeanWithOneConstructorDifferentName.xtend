/*
 * Copyright (c) 2017 Red Hat, Inc. and others. All rights reserved.
 *
 * This program and the accompanying materials are made available under the
 * terms of the Eclipse Public License v1.0 which accompanies this distribution,
 * and is available at http://www.eclipse.org/legal/epl-v10.html
 */
package ch.vorburger.xtendbeans.tests

import org.eclipse.xtend.lib.annotations.Accessors

class BeanWithOneConstructorDifferentName {

    @Accessors(PUBLIC_GETTER) final String name

    new(String value) { // parameter of type String but named value instead of name
        name = value
    }

}
