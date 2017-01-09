package ch.vorburger.xtendbeans.tests.union;

import com.google.common.base.Preconditions;

public class LowestLevel2 {

    private final java.lang.String _value;

    public LowestLevel2(java.lang.String _value) {
        Preconditions.checkNotNull(_value, "Supplied value may not be null");
        this._value = _value;
    }

    public LowestLevel2(LowestLevel2 source) {
        this._value = source._value;
    }

    public static LowestLevel2 getDefaultInstance(String defaultValue) {
        return new LowestLevel2(defaultValue);
    }

    public java.lang.String getValue() {
        return _value;
    }

    // hashCode(), equals() & toString() omitted, just to keep it short}
}

