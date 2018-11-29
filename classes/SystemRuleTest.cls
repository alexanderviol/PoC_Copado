/* Tests Code in Relation to system_rule__c
 */

@isTest
public class SystemRuleTest {
    /* Set up environment with products, system rules, sub rules
     * Later also including pricing.
     */
    
    @testSetup
    public static void setupSystemRuleEnvironment () {
        List<Product2> prodsToInsert = new List<Product2>();
        Product2 pacemakerProduct = new Product2(name='srt_pacemaker');
        prodsToInsert.add(pacemakerProduct);
        Product2 systemProduct = new Product2(name='srt_resulting system');
        prodsToInsert.add(systemProduct);
        
        insert prodsToInsert;
        
        system_rule__c mainRule1 = new system_rule__c(product__c = pacemakerProduct.Id,
                                                      system_product__c = systemProduct.Id,
                                                      max_quantity__c = 3);
        system_rule__c mainRule2 = new system_rule__c(product__c = pacemakerProduct.Id,
                                                      system_product__c = systemProduct.Id,
                                                      max_quantity__c = 2);
        
        insert new List<system_rule__c> {mainRule1, mainRule2};
        
        system_rule__c subRule1_1 = new system_rule__c(parent_rule__c = mainRule1.Id);
        
        insert subRule1_1;
            
    }

    /* Test if the sub rule counting trigger works
     */
    @isTest 
    public static void testCountTrigger () {
        List<Product2> testProducts = [SELECT Id, Name FROM Product2 WHERE Name like 'srt_%'];
        System.assertEquals (2, testProducts.size(),'Different amount of products created in setup than expected?');
        
        List<system_rule__c> setupRules = [SELECT Id, no_subrules__c FROM system_rule__c WHERE product__c IN :testProducts];
        System.assertEquals(2, setupRules.size(), 'Different amount of rules created in setup than expected?');
        
        system_rule__c ruleWithSub, ruleWithoutSub;
        for(system_rule__c sr : setupRules) {
            if(sr.no_subrules__c == null || sr.no_subrules__c == 0)
                ruleWithoutSub = sr;
            else
                ruleWithSub = sr;
        }
        
        List<system_rule__c> setupSubRules = [SELECT Id, no_subrules__c FROM system_rule__c WHERE parent_rule__c = :ruleWithSub.Id];
		System.assertEquals(1, setupSubRules.size(), 'Differen amount of subrules created in setup than expected?');
        
        // Test insert case
        system_rule__c newSubRule = new system_rule__c (parent_rule__c = ruleWithSub.Id);
        Test.startTest();
        insert newSubRule;
        
        List<system_rule__c> recountedRules = [SELECT Id, no_subrules__c FROM system_rule__c WHERE Id = :ruleWithSub.Id];
        System.assertEquals(2, recountedRules[0].no_subrules__c);
        
        // Test update case
        newSubRule.parent_rule__c = ruleWithoutSub.Id;
        update newSubRule;

        recountedRules = [SELECT Id, no_subrules__c FROM system_rule__c WHERE Id = :ruleWithSub.ID];
        System.assertEquals(1, recountedRules[0].no_subrules__c);

        recountedRules = [SELECT Id, no_subrules__c FROM system_rule__c WHERE Id = :ruleWithoutSub.ID];
        System.assertEquals(1, recountedRules[0].no_subrules__c);
        
        // Test delete case
        delete newSubRule;

        // Should be no change here
        recountedRules = [SELECT Id, no_subrules__c FROM system_rule__c WHERE Id = :ruleWithSub.ID];
        System.assertEquals(1, recountedRules[0].no_subrules__c);

        // But this one should be 0 now.
        recountedRules = [SELECT Id, no_subrules__c FROM system_rule__c WHERE Id = :ruleWithoutSub.ID];
        System.assertEquals(0, recountedRules[0].no_subrules__c);
        
        
        
        
        
    }
}