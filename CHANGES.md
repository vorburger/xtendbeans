ch.vorburger.xtendbeans Release Notes
=====================================


v1.2.3 @ TBD
---

* Support all Iterable, not just List
* Fixed confusing "empty" new expression occuring e.g. for anonymous inner classes
* Bumped xtend.version from 2.10.0 to 2.11.0


v1.2.2 @ 2017-01-23
---

* POM use mockito-core instead of mockito-all, which is bad dangerous substance abuse (because it included outdated hamcrest; non-shadowed)
* POM now explicitly depends on objenesis, which used to be in mockito-all (non-shadowed), as scope compile instead of runtime (due to above)
* Bumped xtend.version from 2.9.2 to 2.10.0


v1.2.1 @ 2017-01-10
---

* Support "union" kind of pattern classes (see also https://bugs.opendaylight.org/show_bug.cgi?id=7498)
* Fixed spurious end of line new line characters which should not be there if only invoking constructor
* Test for possible future support of objects with factory methods and private constructor


v1.2.0 @ 2016-09-01
---

* Support setters that don't return void, as typically found on Builder classes
* Support matching constructor arguments by type instead name
* Support properties of type Map (incl. via addXXX methods)
* Support Class instances (customizable name/simpleName)
* Customizable extra additional special properties
* Customizable arbitrary extra initialization code
* Customizable Property filtering (e.g. exclusion)
* Fixed possible NullPointerException in assertEqualByText()


v1.1.0 @ 2016-08-29
---

* AssertBeans without Object.equals()
* Class to use after "new" can be customized (useful if it cannot be auto-detected)
* Builder Class with extension operation for shorter syntax can be used through customization (XtendBeanGeneratorTest#beanWithBuilderAndExtensionMethod())
* Documentation in README


v1.0.0 @ 2016-08-10
---

* Initial Release

