ch.vorburger.xtendbeans Release Notes
=====================================


v1.1.1 @ 2016-08-30
---

* Support for setters that don't return void, as typically found on Builder classes
* Support for properties of type Map (incl. via addXXX methods)
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

