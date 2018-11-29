@isTest
public class WorkOrderLineItemHandlerTest {
	public static final String PREFIX_TEST_NAMES = 'wolit_';

    /* SAFBIO-1332
     * Florian Heer <f.heer@conciscon.de>
     * 2018-06-25
     */ 
    @testSetup
    public static void setupEnvironment() {
        List<RecordType> rts = [SELECT Id FROM RecordType WHERE DeveloperName LIKE '%us_account%' AND SObjectType = 'Account'];
        
        Account acc = New Account(Name = PREFIX_TEST_NAMES + 'Account', RecordTypeId = rts[0].Id, Status__c = 'Active');
        insert acc;
        
        Id rtIdPatient, rtIdPhysician;
        List<RecordTypeInfo> conRTs = Schema.SObjectType.Contact.getRecordTypeInfos();
        for(RecordTypeInfo rti : conRTs) {
            if(rti.getDeveloperName() == Constants.RECORD_TYPE_NAME_CONTACT_US_PATIENT) rtIdPatient = rti.getRecordTypeId();
            else if(rti.getDeveloperName() == Constants.RECORD_TYPE_NAME_CONTACT_US_PHYSICIAN) rtIdPhysician = rti.getRecordTypeId();
        }
        
        
        Contact c = new Contact (FirstName = 'Capital_letter', LastName = 'ConName',
                                 declined_to_provide_address__c = True, declined_to_provide_dob__c = True, 
                                 //declined_to_provide_fname__c  = True, SAFBIO 1365
                                 declined_to_provide_phone__c = True, 
                                 declined_to_provide_ssn__c  = True,
                                 RecordTypeId = rtIdPatient,
                                 MailingCountry = null, status__c = 'Active');
        
        insert c;

        
        WorkOrder wo = new WorkOrder(Subject = PREFIX_TEST_NAMES + 'wo', StartDate = Date.today(),
                                     EndDate = Date.today().addDays(1), rep_at_implant__c = UserInfo.getUserId()
                                    , AccountId = acc.Id
                                    , patient__c = c.id);
        insert wo;
        
        WorkOrderLineItem woli = new WorkOrderLineItem(Subject = PREFIX_TEST_NAMES + 'woli', WorkOrderId = wo.Id,
                                                       StartDate = Date.today());
        insert woli;
    }
	
    @isTest
    static void workOrderLineItemDeletionNonCas(){
        WorkOrder objWorkOrder = new WorkOrder();
        objWorkOrder.StartDate = Date.today();
        objWorkOrder.EndDate = Date.today();
        objWorkORder.rep_at_implant__c = UserInfo.getUserId();
        insert objWorkOrder;
        
        WorkOrderLineItem item = new WorkOrderLineItem();
        item.WorkOrderId = objWorkOrder.Id;
        item.StartDate = Date.today();
        insert item;
        
        
        Boolean bException = false;
        Integer intCountItemsBefore = [SELECT count() FROM WorkOrderLineItem];
        Test.startTest();        
        try{
            delete item;
        }catch(Exception e){
            bException = true;
        }                
        Test.stopTest();
        
        Integer intCountItemsAfter = [SELECT count() FROM WorkOrderLineItem];
        System.assertEquals(true, bException);
        System.assertEquals(intCountItemsBefore,intCountItemsAfter); 
    }
    
    /* SAFBIO-1332
     * Florian Heer <f.heer@conciscon.de>
     * 2018-06-25
     * Tests if the trigger changes the status of the related WorkOrder if the WorkOrderLineItem's
     * status is set to Transmitted.
     */ 
    @isTest
    public static void testTransmittedStatusOnWorkOrderLineItem() {
        String search = PREFIX_TEST_NAMES + '%';
        
        List<WorkOrder> wos = [SELECT Id, Subject, Status FROM WorkOrder WHERE subject LIKE :search];
        System.assertEquals(1, wos.size(), 'We should have one WorkOrder for the subject search string "' + search + '"');
        System.assertNotEquals('Transmitted', wos[0].Status);
        
        List<WorkOrderLineItem> wolis = [SELECT Id, Status FROM WorkOrderLineItem WHERE WorkOrderId = :wos[0].Id];
        System.assertEquals(1, wolis.size(), 'We should have one WorkOrderLineItem for our WorkOrder.');
        
        wolis[0].Status = 'Transmitted';
        
        Test.startTest();
        update wolis;
        Test.stopTest();
        
        wos = [SELECT Id, Subject, Status FROM WorkOrder WHERE subject LIKE :search];
        System.assertEquals('Transmitted', wos[0].Status, 'The trigger should have updated the Status of the WorkOrder');
        
    }
}