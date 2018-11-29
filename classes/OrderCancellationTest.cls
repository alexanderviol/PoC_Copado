@isTest
public class OrderCancellationTest {
    static Account objAccount;  
    static Order objOrder;
    static User salesUser;
    static OrderItem ordIt;
    static Asset objAsset;
    
	@isTest
    private static void init() {
		String profileSalesId = Utility.getProfileId(Constants.PROFILE_NAME_SALES);
        salesUser = TestDataFactory.createUser(profileSalesId, 'SalesTes');
        insert salesUser;
        
        Product2 prod = TestDataFactory.createProduct(Constants.RECORD_TYPE_NAME_PRODUCT);
        prod.product_type__c = Constants.PICKLIST_VALUE_PRODUCT_TYPE_ACCESSORY;
        insert prod;
        
        Id pricebookId = Test.getStandardPricebookId();
        PricebookEntry standardPrice = new PricebookEntry(Pricebook2Id = pricebookId, UnitPrice = 10000, IsActive = true, Product2Id= prod.Id, CurrencyIsoCode = 'USD');
        insert standardPrice;
        
        objAccount= new Account(Name = 'Test Account', sap_company_code__c = '5500', sap_no__c = '35627', status__c = 'Active', crm_pricebook__c = pricebookId);
        insert objAccount;
        
		Contact physician =  TestDataFactory.createPhysician(false);
    	Contact patient = TestDataFactory.createPatient(true, objAccount.id);
        
         WorkOrder objWorkOrder = new WorkOrder(Status = Constants.PICKLIST_STATUS_VALUE_WORK_ORDER_TRANSMITTED, StartDate = Date.today(), EndDate = Date.today()+20, 
                                                Pricebook2Id = pricebookId, rep_at_implant__c = UserInfo.getUserId(),
                                                patient__c =patient.Id, referring_physician__c= physician.Id, following_physician__c=physician.Id, AccountId = objAccount.Id);
        insert objWorkOrder;
		//WorkOrderToOrderConverter.convertToOrder(objWorkOrder);
		//
		Id orderRtId =  Utility.getRecordTypeId(Order.SObjectType, Constants.RECORD_TYPE_NAME_ORDER_MDRF);
        objOrder = new Order (AccountId = objAccount.Id, Status = Constants.PICKLIST_VALUE_ORDER_STATUS_NOT_SUBMITTED, EffectiveDate = System.today(), Pricebook2Id = pricebookId,
                              referring_physician__c = physician.Id, patient__c = patient.Id, RecordTypeId = orderRtId, 
                              no_rep_present_at_implant__c  = true, rep_for_credit__c= UserInfo.getUserId());
        objOrder.OwnerId = salesUser.Id;
        insert objOrder;
		objWorkOrder.order__c = objOrder.Id;
        update objWorkOrder;
       
        OrderItem orderItems = TestDataFactory.createOrderItem(objOrder.Id, prod.Id, 'USD', pricebookId);
        objAsset  = TestDataFactory.createAsset(objAccount.Id, prod.Id);
        
        insert objAsset;
        orderItems.asset__c =objAsset.Id;
        ProductConsumed pc = new ProductConsumed(WorkOrderId = objWorkOrder.Id, PricebookEntryId = standardPrice.Id, QuantityConsumed = 2);
        insert pc; 
        OrderItems.product_consumed__c = pc.Id;
        insert orderItems;
    }   
    
    @isTest 
    static void testCancelProcess(){
        init();
        Id patientId = objOrder.patient__c;
      
        System.runAs(salesUser){
         	objOrder.Status = Constants.PICKLIST_VALUE_ORDER_STATUS_CANCELED;
         	update objOrder;   
        }
         	
        
        
        List<OrderItem> orderItem = [SELECT Id, asset__c, product_consumed__c FROM OrderItem WHERE OrderId =:objOrder.Id];
        for (OrderItem ot:orderItem){
            System.assertEquals(null, ot.asset__c);
            System.assertEquals(null, ot.product_consumed__c);
        }
        
        
        Order orders = [SELECT Id, patient__c From Order where Id =: objOrder.Id];
        System.assertEquals(null, orders.patient__c);
        
        Contact contacts = [SELECT Id, Status__c from Contact where Id =: patientId];
        System.assertEquals(Constants.PICKLIST_VALUE_CONTACT_STATUS_INACTIVE, contacts.Status__c);
        
        WorkOrder wo = [SELECT Id, order__c, patient__c, Status from WorkOrder where order__c=:objOrder.Id];
        System.assertEquals(Constants.PICKLIST_STATUS_VALUE_WORK_ORDER_CANCELED, wo.Status);
        System.assertEquals(null, wo.patient__c);

    }
    
    @isTest
    static void testCancelNotPermitted(){
        String profileSalesId = Utility.getProfileId(Constants.PROFILE_NAME_SALES);
        salesUser = TestDataFactory.createUser(profileSalesId, 'SalesTes');
        insert salesUser;
        
        objAccount = TestDataFactory.createAccount();
        insert objAccount;
        objOrder = TestDataFactory.createOrder(objAccount.Id);
        objOrder.OwnerId = salesUser.Id;
        
        Contact patient = TestDataFactory.createPatient(true);
        objOrder.patient__c = patient.Id;
        
        Insert objOrder;
        
        OrderItem ordersItems = TestDataFactory.createOrderItem(objOrder.Id);
        
        objOrder.Status = Constants.PICKLIST_VALUE_ORDER_STATUS_PROCESSED_SAP;
        update objOrder;
        
        try{
            System.runAs(salesUser){
                objOrder.Status = Constants.PICKLIST_VALUE_ORDER_STATUS_CANCELED;
                update objOrder;
            }   
        }catch(Exception e ){
            System.assertEquals(true, e.getMessage().contains(System.Label.ERROR_TO_CANCEL_ORDER));
        } 
    }    
}