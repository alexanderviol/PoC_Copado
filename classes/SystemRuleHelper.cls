public without sharing class SystemRuleHelper {

    /**
     * Performs the counting of Sub-Rules. Called from Trigger CountSubRules.
     */
    public static void triggerCounting() {
		Set<Id> ruleIDsToUpdate = new Set<Id>();
        // Special case: update needs to change the referenced system rules both before and after
        // the update.
        if(Trigger.isUpdate) {
            Map<Id, SObject> oldMap = Trigger.oldMap;
            Map<Id, SObject> newMap = Trigger.newMap;
            for(Id theId : oldMap.keySet()) {
                system_rule__c oldRule = (system_rule__c)oldMap.get(theId);
                system_rule__c newRule = (system_rule__c)newMap.get(theId);
                if(oldRule.parent_rule__c != newRule.parent_rule__c) {
                    ruleIDsToUpdate.add(oldRule.parent_rule__c);
                    ruleIDsToUpdate.add(newRule.parent_rule__c);
                }
            }
        }
        else if (Trigger.isDelete) {
            for(SObject obj : Trigger.old) {
	            ruleIDsToUpdate.add(((system_rule__c)obj).parent_rule__c);
            }
        }
        else {
            for(SObject obj : Trigger.new) {
                ruleIDsToUpdate.add(((system_rule__c)obj).parent_rule__c);
            }
        }
        
        List<system_rule__c> countedRules = [SELECT Id, (SELECT Id FROM system_rules__r) from system_rule__c 
                                      WHERE id IN :ruleIDsToUpdate];
        List<system_rule__c> rulesToUpdate = new List<system_rule__c>();
        for(system_rule__c rule : countedRules) {
            Integer subRuleCount = rule.system_rules__r == null ? 0 : rule.system_rules__r.size();
            rulesToUpdate.add(new system_rule__c (Id = rule.Id, no_subrules__c = subRuleCount));
        }
        update rulesToUpdate;
        
    }
    
}