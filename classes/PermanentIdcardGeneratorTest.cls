/*
 * Test class for PermanentIdcardGenerator
 *  Created Date - April 9, 2018
 *  Created by   - susi
 */
@isTest
private class PermanentIdcardGeneratorTest {
	   
    public static testMethod void testUpdatePrintDate() {
        
        Account acc = TestDataFactory.createAccount();
        insert acc;
        
        Contact contph = TestDataFactory.createPhysician(false);
        contph.accountId = acc.id;
        insert contph;
        
        Contact cont = TestDataFactory.createPatient(false);
        cont.accountId = acc.id;
        insert cont;
        
        workorder wo = new workorder();
        wo.implanting_physician__c = contph.id;
        wo.no_rep_present_at_implant__c = true;
        wo.AccountId = acc.id;
        insert wo;
        
        Test.startTest();
        	List<Contact> cList = new List<Contact>{cont};
       		ApexPages.StandardSetController controller = new ApexPages.StandardSetController(cList);
        	controller.setSelected(cList);
            PermanentIdcardGenerator idGen = new PermanentIdcardGenerator(controller);  
        	PermanentIdcardGenerator.isAllPatients(cont.id);
            idGen.updatePrintDate();
        Test.stopTest();    
    }
}