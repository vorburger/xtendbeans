/*
 * Copyright (c) 2017 Red Hat, Inc. and others. All rights reserved.
 *
 * This program and the accompanying materials are made available under the
 * terms of the Eclipse Public License v1.0 which accompanies this distribution,
 * and is available at http://www.eclipse.org/legal/epl-v10.html
 */
package ch.vorburger.xtendbeans.tests

/**
 * This is an intentionally "BAD" Builder.
 *
 * This kind of "Builder" is NOT of the same structure as
 * what is a called a Builder elsewhere here; it's more
 * of a *Factory class.  The corresponding test ensures
 * that this is not used; as it doesn't have to, because
 * the (value) class it builds actually already has a
 * suitable constructor, and using that leads to clearer
 * code.
 *
 * This is like e.g. the YANG gen. IpAddressBuilder in ODL.
 * (Which has the added confusing complexity of mixing up String VS
 * char[] types; NB it has this method:
 * IpAddress getDefaultInstance(java.lang.String defaultValue)
 * for creating IpAddress instances which (only) have a getter
 * like char[] getValue())
 *
 * @author Michael Vorburger
 */
class BeanWithOneConstructorDifferentNameBuilder {

    private new() { }

    def BeanWithOneConstructorDifferentName newInstance(String name) {
        new BeanWithOneConstructorDifferentName(name)
    }

}
