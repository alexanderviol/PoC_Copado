/*
 *  Test class for CustomLookUpController  
 *  Created Date - March 6, 2018
 *  Created by   - Sumit
 * 
 * Revision History - 
 * Date             | Developer Name                | Version               | Changes/Ticket Number 
 * ================================================================================================      
 *  
 */
@isTest 
private class CustomLookUpControllerTest {
    static testMethod void fetchLookUpValuesTest() {
        workorder wodr = createWorkorder();  
        Test.startTest();
        	System.assertEquals(0, customLookUpController.fetchLookUpValues(wodr.Id, 'User', 'User', 'RepforCredit').size());
        Test.stopTest();
    }
    
    private static workorder createWorkorder() {
        
        Account acc = TestDataFactory.createAccount();
        insert acc;
        
        Contact con = TestDataFactory.createPhysician(false);
        con.accountid = acc.id;
        insert con;
                
        /*Territory2 t2 = new Territory2();
        t2.developerName = 'Testing';
        insert t2;
        
        ObjectTerritory2Association ota = new ObjectTerritory2Association();
        ota.ObjectId = acc.id;
        ota.Territory2Id = t2.id;
        insert ota;
        
        UserTerritory2Association uta = new UserTerritory2Association();
        uta.Territory2Id = t2.id;
        uta.UserId = u.id;
        insert uta; */
        
        workorder wo = new workorder();
        wo.implanting_physician__c = con.id;
        wo.no_rep_present_at_implant__c = true;
        wo.AccountId = acc.id;
        insert wo;
        return wo;
    }
}