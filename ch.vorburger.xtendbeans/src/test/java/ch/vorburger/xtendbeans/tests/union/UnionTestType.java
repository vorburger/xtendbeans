package ch.vorburger.xtendbeans.tests.union;

public class UnionTestType {

    private final LowestLevel1 _lowestLevel1;
    private final LowestLevel2 _lowestLevel2;
    private char[] _value;

    public UnionTestType(LowestLevel1 _lowestLevel1) {
        super();
        this._lowestLevel1 = _lowestLevel1;
        this._lowestLevel2 = null;
    }

    public UnionTestType(LowestLevel2 _lowestLevel2) {
        super();
        this._lowestLevel2 = _lowestLevel2;
        this._lowestLevel1 = null;
    }

    public UnionTestType(char[] _value) {
        java.lang.String defVal = new java.lang.String(_value);
        UnionTestType defInst = UnionTestTypeBuilder.getDefaultInstance(defVal);
        this._lowestLevel1 = defInst._lowestLevel1;
        this._lowestLevel2 = defInst._lowestLevel2;
        this._value = _value == null ? null : _value.clone();
    }

    public UnionTestType(UnionTestType source) {
        this._lowestLevel1 = source._lowestLevel1;
        this._lowestLevel2 = source._lowestLevel2;
        this._value = source._value;
    }

    public LowestLevel1 getLowestLevel1() {
        return _lowestLevel1;
    }

    public LowestLevel2 getLowestLevel2() {
        return _lowestLevel2;
    }

    public char[] getValue() {
        if (_value == null) {
            if (_lowestLevel1 != null) {
                _value = _lowestLevel1.getValue().toString().toCharArray();
            } else if (_lowestLevel2 != null) {
                _value = _lowestLevel2.getValue().toString().toCharArray();
            }
        }
        return _value == null ? null : _value.clone();
    }

    // hashCode(), equals() & toString() omitted, just to keep it short}

}
