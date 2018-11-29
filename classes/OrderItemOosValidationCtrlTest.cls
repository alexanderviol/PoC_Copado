@isTest
public class OrderItemOosValidationCtrlTest {
    static Account objAccount;
    static Order objOrder;
    static Asset objAsset;
    static User testUser;

    public static void setup(){
        testUser = TestDataFactory.createUser(UserInfo.getProfileId());
        testUser.UserRoleId = [SELECT Id FROM UserRole WHERE DeveloperName = : Constants.USER_ROLE_NAME_SO LIMIT 1].Id;

        System.runAs(testUser){
            objAccount = TestDataFactory.createAccount();
            insert objAccount;

            Id orderRtId =  Utility.getRecordTypeId ('Order', Constants.RECORD_TYPE_NAME_ORDER_MDRF);
            objOrder = TestDataFactory.createOrder(objAccount.Id);
            objOrder.RecordTypeId = orderRtId;
            objOrder.submit_to_sap__c = true;
            objOrder.PoNumber = '1234';
            insert objOrder;
			
            WorkOrder wo = TestDataFactory.createWorkOrder();
            wo.order__c = objOrder.Id;
            insert wo;
            
            Product2 prod = new Product2(Name = Constants.PICKLIST_VALUE_PRODUCT_TYPE_ICD);
            prod.product_type__c = Constants.PICKLIST_VALUE_PRODUCT_TYPE_ICD;
            insert prod;

            objAsset = TestDataFactory.createAsset(objAccount.Id);
            System.debug('patient '+objOrder.patient__c);
            objAsset.recordTypeId = Utility.getRecordTypeId ('Asset', Constants.RECORD_TYPE_NAME_ASSET_US_BIOTRONIK);
            objAsset.patient__c = objOrder.patient__c;
            objAsset.product_type__c = Constants.PICKLIST_VALUE_PRODUCT_TYPE_ICD;
            objAsset.product2Id = prod.Id;
            objAsset.status = Constants.IMPLANT_STATUS_CAPPED;
            objAsset.oos_date__c = null;
            objAsset.date_asset_status_changed__c = system.today().addDays(-1);
            objAsset.imported_as_oos__c = false;
            insert objAsset;
        }
    }
    
    @isTest
    public static void getOosAssets(){
        setup();
        List<Asset> lstOosAssets = new List<Asset>();
        
        Test.startTest();
        	lstOosAssets = OrderItemOosValidationCtrl.getMissingComplaintAssets(objOrder.Id);
        Test.stopTest();
        
        System.assertEquals(1, lstOosAssets.size());
    }
    
    @isTest
    public static void getOosAssetsWithNotRelevantOosAsset(){
        setup();
        List<Asset> lstOosAssets = new List<Asset>();
        System.runAs(testUser){
            
            objAsset.oos_date__c = Date.today();
            objAsset.oos_additional_information__c = 'Test';
            objAsset.event_reason__c = Constants.PICKLIST_VALUE_OOS_REASON_UPGRADE;
            objAsset.has_attached_oos_complaints__c = false;
            update objAsset;
            
            Test.startTest();
                lstOosAssets = OrderItemOosValidationCtrl.getMissingComplaintAssets(objOrder.Id);
            Test.stopTest();
        }
        System.assertEquals(0, lstOosAssets.size());
    }
    
    @isTest
    public static void submitForProcessing(){
        setup();
        
        System.runAs(testUser){
			List<OrderItem> lstItems = new List<OrderItem>();
            OrderItem objOrderItem = TestDataFactory.createOrderItem(objOrder.Id);
            objOrderItem.product_type__c = Constants.PICKLIST_VALUE_PRODUCT_TYPE_ICD;
            objOrderItem.part_of_system_price__c = false;
            objOrderItem.UnitPrice = 0;
            lstItems.add(objOrderItem);

            OrderItem objLead = TestDataFactory.createOrderItem(objOrder.Id);
            objLead.product_type__c = Constants.PICKLIST_VALUE_PRODUCT_TYPE_LEAD;
            objLead.UnitPrice = 1;
            lstItems.add(objLead);

            OrderItem objLead2 = TestDataFactory.createOrderItem(objOrder.Id);
            objLead2.product_type__c = Constants.PICKLIST_VALUE_PRODUCT_TYPE_LEAD;
            objLead2.UnitPrice = 1;
            lstItems.add(objLead2);

            insert lstItems;
            
            Test.startTest();
                objOrder.status = Constants.PICKLIST_VALUE_ORDER_STATUS_SUBMITTED_PROCESSING;
            	update objOrder;	
            Test.stopTest();
        }
        objOrder = [SELECT Id, Status FROM Order WHERE Id = :objOrder.Id];
        System.assertNotEquals(Constants.PICKLIST_VALUE_ORDER_STATUS_SUBMITTED_PROCESSING, objOrder.Status);
    }
    
    
}