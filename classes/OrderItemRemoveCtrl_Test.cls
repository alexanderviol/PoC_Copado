/**
 *
 * Testclass for the OrderItemRemoveCtrl
 * 
 * @author         ilu_pkas 
 * @modifiedBy     ilu_pkas
 * @created        2018-MM-DD
 * @modified       2018-08-30
 * @systemLayer    Test 
 *  
*/
@isTest
public class OrderItemRemoveCtrl_Test {

   	static Account objAccount;  
    static Order objOrder;
    static User testUser;
    
   	private static void init(){
        objAccount = TestDataFactory.createAccount();
        insert objAccount;

        objOrder = TestDataFactory.createOrder(objAccount.Id);
        objOrder.Status = Constants.PICKLIST_VALUE_ORDER_STATUS_NOT_SUBMITTED;
        objOrder.RecordTypeId = Utility.getRecordTypeId(Order.SObjectType, Constants.RECORD_TYPE_NAME_ORDER_MDRF);
        objOrder.submit_to_sap__c = true;
        objOrder.PoNumber = 'aplhanumeric1234';        
        objOrder.rep_at_implant__c = UserInfo.getUserId();
        insert objOrder;
    }
    
    @isTest
    private static void simpleOrderItemNoSystem(){
        init();
        
        OrderItem objOrderItem = TestDataFactory.createOrderItem(objOrder.Id);
        objOrderItem.product_type__c = Constants.PICKLIST_VALUE_PRODUCT_TYPE_ICD;
        objOrderItem.part_of_system_price__c = false;
        objOrderItem.UnitPrice = 0;
        objOrderItem.expiration_date_ubd__c = Date.today();
        insert objOrderItem;
        
        Integer intItemCountBefore = [SELECT Id FROM OrderItem].size();
        System.debug('### '+intItemCountBefore);
        
        Test.startTest();
        	ApexPages.currentPage().getParameters().put('id', String.valueOf(objOrderItem.Id));
        	ApexPages.StandardController stdOrderItem = new ApexPages.StandardController(objOrderItem);
        	OrderItemRemoveCtrl ctrl = new OrderItemRemoveCtrl(stdOrderItem);
        	ctrl.checkForDeletion();        
        Test.stopTest();
        
        Integer intItemCountAfter = [SELECT Id FROM OrderItem].size();
       	System.debug('### '+intItemCountAfter);
        
        System.assertEquals(0, intItemCountAfter);
    }
    
    
    @isTest
    private static void complexOrderItemNoSystem(){
        init();
        
        OrderItem objOrderItem = TestDataFactory.createOrderItem(objOrder.Id);
        objOrderItem.product_type__c = Constants.PICKLIST_VALUE_PRODUCT_TYPE_ICD;
        objOrderItem.part_of_system_price__c = false;
        objOrderItem.UnitPrice = 0;
        objOrderItem.expiration_date_ubd__c = Date.today();
        insert objOrderItem;
        
        Asset objAsset = TestDataFactory.createAsset(objAccount.Id);
        objAsset.order_product__c = objOrderItem.Id;
        insert objAsset;
        
        Product2 prod = new Product2(Name = 'ICD');
        insert prod;
		Id pricebookId = Test.getStandardPricebookId();
        PricebookEntry standardPrice = new PricebookEntry(
            Pricebook2Id = pricebookId, Product2Id = prod.Id,
            UnitPrice = 10000, IsActive = true);
        insert standardPrice;
        
        WorkOrder objWorkOrder = new WorkOrder();
        objWorkOrder.StartDate = Date.today();
        objWorkOrder.EndDate = Date.today();
        objWorkOrder.Pricebook2Id = pricebookId;
        objWorkORder.rep_at_implant__c = UserInfo.getUserId();
        insert objWorkOrder;
        
        ProductConsumed item = new ProductConsumed();
        item.WorkOrderId = objWorkOrder.Id;
        item.PricebookEntryId = standardPrice.Id;
        item.QuantityConsumed = 2;
        item.asset__c = objAsset.Id;
        insert item;
        
        Integer intItemCountBefore = [SELECT Id FROM OrderItem].size();
        Integer intAssetCountBefore = [SELECT Id FROM Asset].size();
        Integer intProdConCountBefore = [SELECT Id FROM ProductConsumed].size();
        System.debug('### Items '+intItemCountBefore);
        System.debug('### Asset '+intAssetCountBefore);
        System.debug('### ProdCon '+intProdConCountBefore);
        
        Test.startTest();
        	ApexPages.currentPage().getParameters().put('id', String.valueOf(objOrderItem.Id));
        	ApexPages.StandardController stdOrderItem = new ApexPages.StandardController(objOrderItem);
        	OrderItemRemoveCtrl ctrl = new OrderItemRemoveCtrl(stdOrderItem);
        	ctrl.checkForDeletion();        
        Test.stopTest();
        
        Integer intItemCountAfter = [SELECT Id FROM OrderItem].size();
        Integer intAssetCountAfter = [SELECT Id FROM Asset].size();
        Integer intProdConCountAfter = [SELECT Id FROM ProductConsumed].size();
       	System.debug('### Item '+intItemCountAfter);
        System.debug('### Asset '+intAssetCountAfter);
        System.debug('### ProdCon '+intProdConCountAfter);
        
        System.assertEquals(0, intItemCountAfter);
        System.assertEquals(0, intAssetCountAfter);
        System.assertEquals(0, intProdConCountAfter);
    }
    
    @isTest
    private static void deleteRec(){
        init();
        
        OrderItem objOrderItem = TestDataFactory.createOrderItem(objOrder.Id);
        objOrderItem.product_type__c = Constants.PICKLIST_VALUE_PRODUCT_TYPE_ICD;
        objOrderItem.part_of_system_price__c = false;
        objOrderItem.UnitPrice = 0;
        objOrderItem.expiration_date_ubd__c = Date.today();
        insert objOrderItem;
        
        Integer intItemCountBefore = [SELECT Id FROM OrderItem].size();
        System.debug('### '+intItemCountBefore);
        
        Test.startTest();
        	ApexPages.currentPage().getParameters().put('id', String.valueOf(objOrderItem.Id));
        	ApexPages.StandardController stdOrderItem = new ApexPages.StandardController(objOrderItem);
        	OrderItemRemoveCtrl ctrl = new OrderItemRemoveCtrl(stdOrderItem);
        Test.stopTest();
        
        Integer intItemCountAfter = [SELECT Id FROM OrderItem].size();
       	System.debug('### '+intItemCountAfter);
        
        System.assertEquals(intItemCountBefore, intItemCountAfter);
    }
}