@isTest
public class OrderReviewMassTransferTest {
	static Account objAcc;
    static Order objOrder;
        
    static void init(){
        objAcc = TestDataFactory.createAccount();
        insert objAcc;
        
        objOrder = TestDataFactory.createOrder(objAcc.Id);
        Id orderRtId =  Utility.getRecordTypeId(Order.SObjectType, Constants.RECORD_TYPE_NAME_ORDER_MDRF);
        objOrder.RecordTypeId = orderRtId;
        objOrder.submit_to_sap__c = true;
        objOrder.PoNumber = '1234';
        insert objOrder;
    }
    
    @isTest
    static void testController(){
        init();

        List<Order> lstOrder = new List<Order>();
        lstOrder.add(objOrder);
                
        Test.setCurrentPage(Page.OrderReviewMassTransfer);
        ApexPages.StandardSetController stdSetCtrl = new ApexPages.StandardSetController(lstOrder);
        
        Test.startTest();
        	OrderReviewMassTransfer ctrl = new OrderReviewMassTransfer(stdSetCtrl);
        Test.stopTest();
        
        System.assertNotEquals(null, ctrl);
    } 
    
    @isTest
    static void testUpdate(){
        init();
        
        List<Order> lstOrder = [SELECT Id, OwnerId FROM Order WHERE Id = :objOrder.Id];
                
        Test.setCurrentPage(Page.OrderReviewMassTransfer);
        ApexPages.StandardSetController stdSetCtrl = new ApexPages.StandardSetController(lstOrder);
        stdSetCtrl.setSelected(lstOrder);
        OrderReviewMassTransfer ctrl = new OrderReviewMassTransfer(stdSetCtrl);
        
        Test.startTest();
			ctrl.updateOrders();
        Test.stopTest();
        
        objOrder = [SELECT Id, OwnerId FROM Order WHERE Id = :objOrder.Id];
        System.assertEquals(UserInfo.getUserId(), objOrder.OwnerId);
    }
}