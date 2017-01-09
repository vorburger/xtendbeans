package ch.vorburger.xtendbeans.tests.union;

public class UnionTestTypeBuilder {

    public static UnionTestType getDefaultInstance(java.lang.String defaultValue) {
        if (defaultValue.length() > 8) {
            return new UnionTestType(new LowestLevel1(defaultValue));
        } else {
            return new UnionTestType(new LowestLevel2(defaultValue));
        }
    }

}
