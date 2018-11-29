/**
* Updates Sub Rules-Field on System Rules. Counting of relations which are not Master-Detail cannot
* be done without a trigger.
*/

trigger CountSubRules on System_Rule__c (after insert, after update, after delete) {
    SystemRuleHelper.triggerCounting();
}