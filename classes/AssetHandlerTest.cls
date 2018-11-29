/**
 *
 * Test class for Asset Trigger
 * 
 * @author          snpa 
 * @modifiedBy      Gokul Palagiri
 * @created         2018-04-10
 * @modified        2018-10-25
 * @systemLayer     Test 
 *  
*/
@isTest
private class AssetHandlerTest {
    public static final String SALES_PROFILE = 'Sales';
    
    static Account objAccount;
    static Contact objPatient;  
    static Order objOrder;
    static OrderItem objOrderItem;
    static user testUser;
    
    private static void init() {
        Profile p = [SELECT Id, Name FROM Profile WHERE Name = :SALES_PROFILE];
        Id idUSAccountRecordType = [SELECT Id, Name, DeveloperName FROM RecordType WHERE Name = 'US Account'].Id; 
        testUser = TestDataFactory.createUser(p.id);
        insert testUser;
        
        System.runAs(testUser) {
            objAccount = TestDataFactory.createAccount();
            objAccount.RecordTypeId=idUSAccountRecordType;
            insert objAccount;

        Id idPateintRecordType = [SELECT Id, Name, DeveloperName FROM RecordType WHERE Name = 'Patient'].Id;
        objPatient = new Contact(firstname='TEST', lastname= 'CONTACT',
                Birthdate = System.today().addYears(-29),
                declined_to_provide_address__c = true,
                declined_to_provide_phone__c = true,
                declined_to_provide_ssn__c = true,
                accountid = objAccount.Id,
                recordTypeId = idPateintRecordType);
        insert objPatient;            
        
            Id orderRtId =  Utility.getRecordTypeId (Order.SObjectType, Constants.RECORD_TYPE_NAME_ORDER_MDRF);
            objOrder = TestDataFactory.createOrder(objAccount.Id);
            objOrder.status = Constants.PICKLIST_VALUE_STATUS_NOT_SUBMITTED;
            objOrder.recordTypeId = orderRtId;
            objOrder.submit_to_sap__c = true;
            objOrder.PoNumber = '1234';
            objOrder.OwnerId = testUser.Id;
            objOrder.AccountId = objAccount.Id;
            objOrder.rep_at_implant__c = testUser.Id;
            objOrder.EffectiveDate = System.Today();
            objOrder.implant_date__c = System.Today();
            objOrder.patient__c = objPatient.Id;
            insert objOrder;

            objOrderItem = TestDataFactory.createOrderItem(objOrder.Id);
            Insert objOrderItem;
        }
    }
    
    /**
     * Method checks if after a asset is linked to a patient
     * a field updates are done
     */
    @isTest
    static void testPatientUpdateForNewAsset() {
        init();
        Id idPateintRecordType = [SELECT Id, Name, DeveloperName FROM RecordType WHERE Name = 'Patient'].Id;
        
        contact patient = new Contact(firstname='TEST', lastname= 'CONTACT',
                                        Birthdate = System.today().addYears(-29),
                                        declined_to_provide_address__c = true,
                                        declined_to_provide_phone__c = true,
                                        declined_to_provide_ssn__c = true,
                                        accountid = objAccount.Id,
                                        recordTypeId = idPateintRecordType);
        insert patient;
        
        Product2 prod = new Product2(Name = Constants.PICKLIST_VALUE_PRODUCT_TYPE_ICD);
        prod.product_type__c = Constants.PICKLIST_VALUE_PRODUCT_TYPE_ICD;
        insert prod;
        
        System.runAs(testUser) {
            Asset objAsset = TestDataFactory.createAsset(objAccount.Id);
            objAsset.product_type__c = Constants.PICKLIST_VALUE_PRODUCT_TYPE_ICD;
            objAsset.order__c = objOrder.Id;
            objAsset.order_product__c = objOrderItem.Id;
            objAsset.Status = Constants.IMPLANT_STATUS_IMPLANTED;
            objAsset.patient__c = patient.Id;
            objAsset.Product2Id = prod.Id;

            Test.startTest();        
               insert objAsset;
            Test.stopTest();
            
            patient = [SELECT Id, implanted_product_new_patient__c, implanted_product_changed__c FROM Contact WHERE Id = :patient.Id];
            System.assertEquals(true, patient.implanted_product_changed__c);
            System.assertEquals(true, patient.implanted_product_new_patient__c);
        }
    }
    
    /**
     * Method checks if on the status change of a linked asset
     * a field update on the patient is done
     */
    @isTest
    static void testPatientUpdateForAssetStatusChange() {
        init();
        Id idPateintRecordType = [SELECT Id, Name, DeveloperName FROM RecordType WHERE Name = 'Patient'].Id;
        
        contact patient = new Contact(firstname='TEST', lastname= 'CONTACT',
                                        Birthdate = System.today().addYears(-29),
                                        declined_to_provide_address__c = true,
                                        declined_to_provide_phone__c = true,
                                        declined_to_provide_ssn__c = true,
                                        accountid = objAccount.Id,
                                        recordTypeId = idPateintRecordType);
        insert patient;
        
        Product2 prod = new Product2(Name = Constants.PICKLIST_VALUE_PRODUCT_TYPE_ICD);
        prod.product_type__c = Constants.PICKLIST_VALUE_PRODUCT_TYPE_ICD;
        insert prod;

        System.runAs(testUser) {
            Asset objAsset = TestDataFactory.createAsset(objAccount.Id);
            objAsset.product_type__c = Constants.PICKLIST_VALUE_PRODUCT_TYPE_ICD;
            objAsset.order__c = objOrder.Id;
            objAsset.order_product__c = objOrderItem.Id;
            objAsset.Status = Constants.IMPLANT_STATUS_IMPLANTED;
            objAsset.patient__c = patient.Id;
            objAsset.Product2Id = prod.Id;
            insert objAsset;

            Test.startTest();
                objAsset.Status = 'Explanted';
                objAsset.Explant_Date__c = Date.today();
                objAsset.oos_date__c = Date.today();
                //objAsset.event_reason_c = 'Infection';
                update objAsset;
            Test.stopTest();

            patient = [SELECT Id, implanted_product_new_patient__c, implanted_product_changed__c FROM Contact WHERE Id = :patient.Id];
            System.assertEquals(true, patient.implanted_product_changed__c);
        }
    } 

    @isTest
    static void testdeleteAsset() {
        init();
        Id idPateintRecordType = [SELECT Id, Name, DeveloperName FROM RecordType WHERE Name = 'Patient'].Id;
        
        contact patient = new Contact(firstname='TEST', lastname= 'CONTACT',
                                        Birthdate = System.today().addYears(-29),
                                        declined_to_provide_address__c = true,
                                        declined_to_provide_phone__c = true,
                                        declined_to_provide_ssn__c = true,
                                        accountid = objAccount.Id,
                                        recordTypeId = idPateintRecordType);
        insert patient;
        
        Product2 prod = new Product2(Name = Constants.PICKLIST_VALUE_PRODUCT_TYPE_ICD);
        prod.product_type__c = Constants.PICKLIST_VALUE_PRODUCT_TYPE_ICD;
        insert prod;
        
        
        System.runAs(testUser) {
            Asset objAsset = TestDataFactory.createAsset(objAccount.Id);
            objAsset.product_type__c = Constants.PICKLIST_VALUE_PRODUCT_TYPE_ICD;
            objAsset.order__c = objOrder.Id;
            objAsset.order_product__c = objOrderItem.Id;
            objAsset.Status = Constants.IMPLANT_STATUS_IMPLANTED;
            objAsset.patient__c = patient.Id;
            objAsset.Product2Id = prod.Id;
            insert objAsset;

            Test.startTest();        
                delete objAsset;
            Test.stopTest();
            
            patient = [SELECT Id, implanted_product_new_patient__c, implanted_product_changed__c FROM Contact WHERE Id = :patient.Id];
            System.assertEquals(true, patient.implanted_product_changed__c);
        }
    }
    
    @isTest
    static void updateMDRFReimportTimestampTest() {
        init();
        Id idPateintRecordType = Utility.getRecordTypeId(Contact.SObjectType, Constants.RECORD_TYPE_NAME_CONTACT_US_PATIENT);
        
        contact patient = new Contact(firstname='TEST', lastname= 'CONTACT',
                                        Birthdate = System.today().addYears(-29),
                                        declined_to_provide_address__c = true,
                                        declined_to_provide_phone__c = true,
                                        declined_to_provide_ssn__c = true,
                                        accountid = objAccount.Id,
                                        recordTypeId = idPateintRecordType);
        insert patient;

        Product2 prod = new Product2(Name = Constants.PICKLIST_VALUE_PRODUCT_TYPE_ICD);
        prod.product_type__c = Constants.PICKLIST_VALUE_PRODUCT_TYPE_ICD;
        insert prod;
        
        System.runAs(testUser) {
            OrderItem oi = TestDataFactory.createOrderItem(objOrder.id);
            oi.OrderId =  objOrder.Id;
            insert oi;

            Asset objAsset = TestDataFactory.createAsset(objAccount.Id);
            objAsset.product_type__c = Constants.PICKLIST_VALUE_PRODUCT_TYPE_ICD;
            objAsset.order__c = objOrder.Id;
            objAsset.order_product__c = objOrderItem.Id;
            objAsset.Status = Constants.IMPLANT_STATUS_IMPLANTED;
            objAsset.patient__c = patient.Id;
            objAsset.Product2Id = prod.Id;
            objAsset.order_product__c = oi.id;
            objAsset.InstallDate = Date.Today();
            insert objAsset;
            
            //Inserting custom settings
            user_id__c defaultusr = new user_id__c(binc_default_initial_reporter_s_user_id__c = testUser.id);
            insert defaultusr;
            
            Test.startTest();  
                objAsset.InstallDate = Date.Today().addDays(2);
                update objAsset;
                Asset asst = [Select order_product__r.Order.mdrf_reimport_timestamp__c FROM Asset where Id =: objAsset.id];
                System.Assert(asst.order_product__r <> null);  
           Test.stopTest();
 
        }
    }

    /* Checks if we set the correct contact and account id on insert and update.
     * 
     * 2018-06-13 Florian Heer <f.heer@conciscon.de>
     */
    static testMethod void testContactAndAccountFieldSynchs() {
        Id assetRTId = Utility.getRecordTypeId(Asset.SObjectType, Constants.RECORD_TYPE_NAME_ASSET_US_BIOTRONIK);
        Id orderRtId = Utility.getRecordTypeId(Order.SObjectType, Constants.RECORD_TYPE_NAME_ORDER_MDRF);

        init();
        Id idPateintRecordType = [SELECT Id, Name, DeveloperName FROM RecordType WHERE Name = 'Patient'].Id;
    Test.StartTest();
        Asset objAsset = TestDataFactory.createAsset(objAccount.Id);
        objAsset.product_type__c = Constants.PICKLIST_VALUE_PRODUCT_TYPE_ICD;
        objAsset.order__c = objOrder.Id;
        objAsset.order_product__c = objOrderItem.Id;
        objAsset.Status = Constants.IMPLANT_STATUS_IMPLANTED;
        objAsset.patient__c = objPatient.Id;
        objAsset.InstallDate = Date.Today();
        objAsset.AccountId = objAccount.Id;
        insert objAsset;

        Asset ass = [SELECT Id, ContactId, AccountId FROM Asset WHERE Id = :objAsset.Id LIMIT 1];
        System.assert(ass.AccountId != null, 'Invalid Account Id');
        System.assert(ass.ContactId != null, 'Invalid Contact Id');

        Update objAsset;
        ass = [SELECT Id, ContactId, patient__c, AccountId, explanting_facility__c FROM Asset WHERE Id = :objAsset.Id LIMIT 1];
        System.assert(ass.AccountId != null, 'Invalid Account Id');
        System.assert(ass.ContactId != null, 'Invalid Contact Id');

        Account newAccount = objAccount.Clone();
        newAccount.Name = 'Different Name';
        newAccount.sap_no__c = '2342134';
        insert newAccount;
        objAsset.explanting_facility__c = newAccount.Id;
        objAsset.patient__c = objPatient.Id;
        Update objAsset;
    Test.StopTest();
        ass = [SELECT Id, AccountId, ContactId FROM Asset WHERE Id = :ass.Id LIMIT 1];
        System.assert(ass.AccountId != null, 'Invalid Account Id');
        System.assert(ass.ContactId != null, 'Invalid Contact Id');

    }
    
}