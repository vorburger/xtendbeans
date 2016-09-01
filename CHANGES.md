ch.vorburger.xtendbeans Release Notes
=====================================


v1.1.1 @ 2016-08-30
---

* Support setters that don't return void, as typically found on Builder classes
* Support matching constructor arguments by type instead name
* Support properties of type Map (incl. via addXXX methods)
* Support Class instances (customizable name/simpleName)
* Customizable extra additional special properties
* Customizable arbitrary extra initialization code
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

