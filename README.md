_If you read this and like or use this project, a Star / Watch / Follow on GitHub is much appreciated!_

[![Maven Central](https://maven-badges.herokuapp.com/maven-central/ch.vorburger/xtendbeans/badge.svg)](https://maven-badges.herokuapp.com/maven-central/ch.vorburger/xtendbeans) <== available on Maven central as **ch.vorburger:xtendbeans**

ch.vorburger's Xtend Beans is a very small helper library with an [XtendBeanGenerator class](https://github.com/vorburger/xtendbeans/blob/master/ch.vorburger.xtendbeans/src/main/java/ch/vorburger/xtendbeans/XtendBeanGenerator.xtend) which, given any Java Bean object as input, returns as output a String of an [Xtend "With" operation expression](https://eclipse.org/xtend/documentation/203_xtend_expressions.html#with-operator).  (The objects do not have to implement any special interface or have any annotation.)

With this library, you start with [AssertBeans](https://github.com/vorburger/xtendbeans/blob/master/ch.vorburger.xtendbeans/src/main/java/ch/vorburger/xtendbeans/AssertBeans.java) instead of JUnit's usual Assert.assertEquals() in a @Test:

    AssertBeans.assertEqualBeans("TODO", actualObjects);

Initially, when first writing this assertion part that's typically last in @Test method, this test obviously fails.  But the ComparisonFailure will display nicely in your IDE, and on double-clicking it, you will see not your actualObjects's toString, but an Xtend "With" operator based expression, such as:

    new Person => [
        firstName = 'Homer'
        lastName = 'Simpson'
        address = new Address => [
            street = '742 Evergreen Terrace'
            city = 'SpringField'
        ]
    ]

You now copy/paste this shown "actual" String, from your IDE, into some *.xtend source class, say:

    class MyExpectedObjects {
        static def test1() {
            new Person => [ // .. as above
        }
    }

You can now use this new class in the @Test by replacing the initial TODO to use it:

    AssertBeans.assertEqualBeans(MyExpectedObjects.test1(), actualObjects);

The test is green now.  Any future changes causing discrepancies between actual and expected objects will lead to highly readable and understandable text based diff, in the same syntax.  If the change is justified and not a regression, it is very easy to adapt e.g. the MyExpectedObjects Xtend source accordingly.

You can use this library completely without Xtend as well, and just compare a String-based expected text and the representation generated from an actual object; the AssertBeans' assertEqualByText() method is for that.

This library could be extended to produce literal object property initialization code for other languages than Xtend which offer such syntax (Java doesn't really; Groovy/Scala/Kotlin/Ceylon & Co. do).


_Further background information:_

This is useful for example if you write tests and would like to assert that returned complex objects match some expected objects.  Traditionally, one would manually write many lines of difficult to read Java test code which navigates through actual objects and "matches" them all to expected (nested!) objects and their properties.  Alternatively, one could use some sort of file representation of those objects (in JSON, XML, or whatever other "serialization format" of those beans), read that into beans during the test, and then compare them.  Both of these approaches do not let you see differences between expected and actual (trees of) bean objects easily.

The JUnit *Test class with your @Test methods does not have to written in Xtend but can (stay) in Java.   The Xtend method, e.g. test1() in class MyExpectedObjects, can also take parameters to "template" expected objects, if you have many tests.  The *.xtend syntax is "code" just like Java, and will compile-time check, offer Ctrl-Space completion of property names, or turn red during development, not test execution, should e.g. property or class names of beans change etc.

In a sense this library is a "serialization" helper not unlike frameworks like GSON, Jackson, JAXB & Co.  Instead of producing some sort of mark-up like XML, JSON (or [ESON](https://wiki.eclipse.org/ESON)!), it creates Xtend source code.  However, unlike those kind of frameworks, this library does not include any "de-serialization" (AKA unmarshalling) part to re-construct objects - because the Xtend source (transpiled into Java, compiled to standard JVM bytecode) will already create the original object - there is thus no need to dynamically at run-time "read" anything.


_Reminder how to release new versions:_

    mvn release:prepare
    mvn -Pgpg release:perform
    mvn release:clean

