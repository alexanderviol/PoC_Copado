/*
This file is generated and isn't the actual source code for this
managed global class.
This read-only file shows the class's global constructors,
methods, variables, and properties.
To enable code to compile, all methods return null.
*/
global class SetCondition implements QIDC.Condition {
    global String bindVariable {
        get;
    }
    global QIDC.SoqlBuilder builder {
        get;
    }
    global String field {
        get;
    }
    global QIDC.Operator operator {
        get;
    }
    global List<Object> values {
        get;
    }
    global SetCondition() {

    }
    global SetCondition(String field) {

    }
    global SetCondition(String field, QIDC.Operator operator, QIDC.SoqlBuilder builder) {

    }
    global SetCondition(String field, QIDC.Operator operator, List<Object> values) {

    }
    global QIDC.SetCondition excludes(QIDC.SoqlBuilder builder) {
        return null;
    }
    global QIDC.SetCondition excludes(List<Object> values) {
        return null;
    }
    global QIDC.SetCondition field(String field) {
        return null;
    }
    global QIDC.SetCondition includes(QIDC.SoqlBuilder builder) {
        return null;
    }
    global QIDC.SetCondition includes(List<Object> values) {
        return null;
    }
    global QIDC.SetCondition inx(QIDC.SoqlBuilder builder) {
        return null;
    }
    global QIDC.SetCondition inx(String bindVariable) {
        return null;
    }
    global QIDC.SetCondition inx(List<Object> values) {
        return null;
    }
    global QIDC.SetCondition notIn(QIDC.SoqlBuilder builder) {
        return null;
    }
    global QIDC.SetCondition notIn(List<Object> values) {
        return null;
    }
    global static String operatorToString(QIDC.Operator operator) {
        return null;
    }
    global String toSoql() {
        return null;
    }
    global String toSoql(QIDC.SoqlOptions options) {
        return null;
    }
}
