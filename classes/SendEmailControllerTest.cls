/*
 * Test class for SendEmailController
 *  Created Date - 4/2/2018
 *  Created by   - susi
 */
@isTest
private class SendEmailControllerTest {
    
    public static testMethod void testGetRecords() {
        Account acc = TestDataFactory.createAccount();
        insert acc;
        
        Contact con = TestDataFactory.createPhysician(false);
        con.accountId = acc.id;
        insert con;
        
        Test.startTest();
            //Calling the method
            SendEmailController.wrapper  wp = SendEmailController.getRecords(con.Id);
            System.AssertEquals(wp.c.Email,con.Email);
        Test.stopTest();
        
    }
    
    public static testMethod void testGetlookupFieldValues() {
        Account acc = TestDataFactory.createAccount();
        insert acc;
        
        Contact con = TestDataFactory.createPhysician(false);
        con.accountId = acc.id;
        insert con;
        
        workorder wo = new workorder();
        wo.implanting_physician__c = con.id;
        wo.no_rep_present_at_implant__c = true;
        wo.AccountId = acc.id;
        insert wo;
        
        Test.startTest();
            //Calling the method
            List<SendEmailController.KeyValueWrapper>  wp = SendEmailController.getlookupFieldValues(wo.Id);
        Test.stopTest();
        
    }
}