/**
 * Test Class for GenerateAutoNumbersController
 * 
 * @author            SNPA
 * @created           2018-04-26
 * @systemLayer       Test Class 
 *  
 */
@isTest
private class GenerateAutoNumbersControllerTest {
    
     /** 
     * Method checks if correct RP Number is assigned to complaint 
     * @author     SNPA 
     */
	static testMethod void testRPNumberAssignment() {
    	
        case objCase = TestDataFactory.createCase();
        insert objCase;
        
        complaint__c objComplaint = TestDataFactory.createComplaint(objCase.id);
        objComplaint.initial_approver__c = UserInfo.getUserId();
        objComplaint.date_product_received_by_mdr_team__c = system.today();
        insert objComplaint;
        
        Test.startTest();
        	GenerateAutoNumbersController.assignRpNumber(objComplaint.id);        
        Test.stopTest();
        
        objComplaint = [SELECT id, rp_number__c FROM complaint__c WHERE id = :objComplaint.id];
        system.assertEquals(GenerateAutoNumbersController.RP_PREFIX + System.Today().year() + '-00001' , objComplaint.rp_number__c);
    }
    
    /** 
     * Method checks if correct CI Number is assigned to complaint
     * @author     SNPA 
     */
    static testMethod void testCINumberAssignment() {
    	
        case objCase = TestDataFactory.createCase();
        insert objCase;
        
        complaint__c objComplaint = TestDataFactory.createComplaint(objCase.id);
        objComplaint.initial_approver__c = UserInfo.getUserId();
        objComplaint.date_product_received_by_mdr_team__c = system.today();
        insert objComplaint;        
         
        complaint__c objComplaint2 = TestDataFactory.createComplaint(objCase.id);
        objComplaint.initial_approver__c = UserInfo.getUserId();
        objComplaint.date_product_received_by_mdr_team__c = system.today();
        insert objComplaint2;
        
        Test.startTest();
        	GenerateAutoNumbersController.assignCiNumber(objComplaint.id);        	
        Test.stopTest();
                
        objComplaint = [SELECT id, ci_number__c FROM complaint__c WHERE id = :objComplaint.id];
        system.assertEquals(GenerateAutoNumbersController.CI_PREFIX + System.Today().year() + '-00001' , objComplaint.ci_number__c);        
    }

    /** 
     * Method checks if correct MDR Number is assigned to complaint
     * @author     SNPA 
     */
    static testMethod void testMDRNumberAssignment() {
    	
        case objCase = TestDataFactory.createCase();
        insert objCase;
        
        complaint__c objComplaint = TestDataFactory.createComplaint(objCase.id);
        objComplaint.initial_approver__c = UserInfo.getUserId();
        objComplaint.mdr_decision__c = 'Test MDR decision';
        insert objComplaint;

        GenerateAutoNumbersController.assignCiNumber(objComplaint.id);
        GenerateAutoNumbersController.assignMdrNumber(objComplaint.id);
        
        objComplaint = [SELECT id, mdr_number__c FROM complaint__c WHERE id = :objComplaint.id];
        system.assertEquals(GenerateAutoNumbersController.MDR_PREFIX + System.Today().year() + '-00001' , objComplaint.mdr_number__c);
    }
    
    /** 
     * Method checks if correct new Numbers are assigned when Year is changed
     * @author     SNPA 
     */
    static testMethod void testYearChange() {
    	
        case objCase = TestDataFactory.createCase();
        insert objCase;
        
        auto_running_numbers__c objNumber = TestDataFactory.createAutoNumberSetting(2017);
        insert objNumber;
        
        complaint__c objComplaint = TestDataFactory.createComplaint(objCase.id);
        objComplaint.mdr_decision__c = 'Test MDR decision';
        objComplaint.initial_approver__c = UserInfo.getUserId();
        objComplaint.date_product_received_by_mdr_team__c = system.today();
        insert objComplaint;

        GenerateAutoNumbersController.assignCiNumber(objComplaint.id);
        GenerateAutoNumbersController.assignMdrNumber(objComplaint.id);
        
        objComplaint = [SELECT id, ci_number__c, mdr_number__c FROM complaint__c WHERE id = :objComplaint.id];
        system.assertEquals(GenerateAutoNumbersController.MDR_PREFIX + System.Today().year() + '-00001' , objComplaint.mdr_number__c);
        system.assertEquals(GenerateAutoNumbersController.CI_PREFIX + System.Today().year() + '-00001' , objComplaint.ci_number__c);
        
        GenerateAutoNumbersController.assignRpNumber(objComplaint.id);        
        
        objComplaint = [SELECT id, rp_number__c FROM complaint__c WHERE id = :objComplaint.id];
        system.assertEquals(GenerateAutoNumbersController.RP_PREFIX  + System.Today().year() + '-00001' , objComplaint.rp_number__c);
        
        objNumber =  [SELECT ci_number__c, 
                      		 mdr_number__c, 
                      		 rp_number__c, 
                      		 running_number_year__c  
                      	FROM auto_running_numbers__c WHERE id = :objNumber.id];
        system.assert(objNumber.ci_number__c == 2 && 
                     objNumber.mdr_number__c == 2 &&
                     objNumber.rp_number__c == 2 &&
                     objNumber.running_number_year__c == 2018 );        
        
    }
}