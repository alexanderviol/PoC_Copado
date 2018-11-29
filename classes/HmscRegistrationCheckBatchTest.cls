/**
 *
 * Test class for the HmscRegistrationCheckBatch
 * 
 * @author         ilu_pkas 
 * @modifiedBy     ilu_pkas
 * @created        2018-MM-DD
 * @modified       2018-08-30
 * @systemLayer    Test 
 *  
*/
@isTest
public class HmscRegistrationCheckBatchTest {
	static Account objAccount;  
    static Order objOrder;
    static Contact objPatient;
    static User testUser;    
    
    private static void init(){
        objAccount = TestDataFactory.createAccount();
        insert objAccount;
        
        objPatient = TestDataFactory.createPatient(false);
        objPatient.AccountId = objAccount.Id;
        insert objPatient;
        
        Id orderRtId =  Utility.getRecordTypeId(Order.SObjectType, Constants.RECORD_TYPE_NAME_ORDER_MDRF);
        objOrder = TestDataFactory.createOrder(objAccount.Id);
        objOrder.Status = Constants.PICKLIST_VALUE_ORDER_STATUS_PENDING_HMSC;
        objOrder.RecordTypeId = orderRtId;
        objOrder.PoNumber = '123456789test';
        objOrder.patient__c = objPatient.Id;
        objOrder.rep_at_implant__c = UserInfo.getUserId();
        objOrder.date_cm_submitted__c = Date.today().addDays(-10);
       
        insert objOrder;      
        
        System.debug('### '+[SELECT Status FROM Order WHERE ID = :objOrder.Id]);
    }
    
    /**
     * This test case generates coverage for the call of the salesforce internal schedule feature
     */
    @isTest
    private static void testScheduel(){
        Test.startTest();
            HmscRegistrationCheckBatch myClass = new HmscRegistrationCheckBatch();   
            String chron = '0 0 23 * * ?';        
            System.schedule('Test Sched', chron, myClass);
        Test.stopTest();
    }
    
    @isTest
    private static void testBatch(){
        init();
        
        Product2 prod = new Product2(Name = 'ICD');
        prod.product_type__c = 'ICD';
        insert prod;
        
        Asset objAsset = TestDataFactory.createAsset(objAccount.Id);
        objAsset.product_type__c = Constants.PICKLIST_VALUE_PRODUCT_TYPE_ICD;
        objAsset.order__c = objOrder.id;
        objAsset.status = Constants.IMPLANT_STATUS_IMPLANTED;
        objAsset.Product2Id = prod.Id;
        insert objAsset;
         
        objPatient.hmsc_registration__c = true;
        objPatient.HMSC_Registration_StringVal__c = 'yes';
        update objPatient;
        
        Test.startTest();
        	HmscRegistrationCheckBatch batch = new HmscRegistrationCheckBatch();
        	Database.executeBatch(batch);
        Test.stopTest();
        
        objOrder = [SELECT Id, Status FROM Order WHERE Id = :objOrder.Id];
        System.assertEquals(Constants.PICKLIST_VALUE_ORDER_STATUS_PENDING_SAP, objOrder.Status);

    }
    /*
    @isTest
    private static void testBatchCancelation(){
        init();
        
        Product2 prod = new Product2(Name = 'ICD');
        prod.product_type__c = 'ICD';
        insert prod;
        
        Asset objAsset = TestDataFactory.createAsset(objAccount.Id);
        objAsset.product_type__c = OrderHandler.ICD;
        objAsset.order__c = objOrder.id;
        objAsset.status = AssetHandler.IMPLANTED;
        objAsset.Product2Id = prod.Id;
        insert objAsset;

        Integer intDays = Integer.valueOf(Utility.getSettingValue(HmscRegistrationCheckBatch.IDENTIFIER_HMSC_BATCH_CONFIG));
        objOrder.date_cm_submitted__c = Date.today().addDays(-intDays - 10);
        update objOrder;
        
        Test.startTest();
        	HmscRegistrationCheckBatch batch = new HmscRegistrationCheckBatch();
        	Database.executeBatch(batch);
        Test.stopTest();
        
        objOrder = [SELECT Id, Status FROM Order WHERE Id = :objOrder.Id];
        System.assertEquals(HmscRegistrationCheckBatch.CANCELED, objOrder.Status);
    }*/
}