/**
 * Test class for ProMRICheckControllerExt class
 * @author              Sumit
 * @created             16.10.2018 
 */
@isTest
public class ProMRICheckControllerExtTest {

    public static testMethod void checkProMRIFromRecordANDCheckProMRITest() {
    
        Account acc = TestDataFactory.createAccount();
        insert acc;
        
        Contact contph = TestDataFactory.createPhysician(false);
        contph.accountId = acc.id;
        insert contph;
        
        Contact cont = TestDataFactory.createPatient(false);
        cont.accountId = acc.id;
        cont.promri_check_status__c = '1';
        insert cont;

        Test.startTest();
        	List<Contact> cList = new List<Contact>{cont};
       		ApexPages.StandardSetController controller = new ApexPages.StandardSetController(cList);
        	ProMRICheckControllerExt proMri = new ProMRICheckControllerExt(controller);
        	controller.setSelected(cList);
        	ProMRICheckControllerExt.checkProMRIFromRecord(cont.id);
        	ProMRICheckControllerExt.CheckProMRI(cont.id);
        	System.assert(cont.promri_check_status__c <> null);
        Test.stopTest();    
    }
}