package ch.vorburger.xtendbeans.tests.union;

import com.google.common.base.Preconditions;

public class LowestLevel1 {

    private final java.lang.String _value;

    public LowestLevel1(java.lang.String _value) {
        Preconditions.checkNotNull(_value, "Supplied value may not be null");
        this._value = _value;
    }

    public LowestLevel1(LowestLevel1 source) {
        this._value = source._value;
    }

    public static LowestLevel1 getDefaultInstance(String defaultValue) {
        return new LowestLevel1(defaultValue);
    }

    public java.lang.String getValue() {
        return _value;
    }

    // hashCode(), equals() & toString() omitted, just to keep it short}
}
