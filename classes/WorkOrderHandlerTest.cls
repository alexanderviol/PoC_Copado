//TestClass for workOrder Handler
//Created by emma
//created date 25.07.2018
@isTest
private class WorkOrderHandlerTest {

    @isTest
    static void testCheckAndPerformWorkOrderCancellation(){
        List<ProductConsumed> lstPc = new List<ProductConsumed>();
        List<WorkOrderLineItem> lstwoli = new List<WorkOrderLineItem>();
        
        Account objAccount = new Account(Name = 'Test Account',
                                         sap_company_code__c = '5500',
                                         sap_no__c = '35627', 
                                         status__c = 'Active');
        insert objAccount;
		Contact physician =  TestDataFactory.createPhysician(false);
    	Contact patient = TestDataFactory.createPatient(true, objAccount.id);
        Product2 prod = new Product2(IsActive = true,
                                     Name = 'ABC product',
                                     study_product__c = true
                                     );
        insert prod;
        Id pricebookId = Test.getStandardPricebookId();
        PricebookEntry standardPrice = new PricebookEntry(Pricebook2Id = pricebookId, 
            											  UnitPrice = 10000, 
                                                          IsActive = true,
                                                          Product2Id= prod.Id);
        insert standardPrice;        
		Id orderRtId =  Utility.getRecordTypeId(Order.SObjectType, Constants.RECORD_TYPE_NAME_ORDER_MDRF);
        Order objOrd = new Order (AccountId = objAccount.Id,
                                   Status = Constants.PICKLIST_VALUE_ORDER_STATUS_NOT_SUBMITTED,
                                   EffectiveDate = System.today(),
                                   Pricebook2Id = pricebookId,
                                   referring_physician__c = physician.Id,
                                   patient__c = patient.Id,
                                   RecordTypeId = orderRtId,
                                   no_rep_present_at_implant__c  = true,
                                   rep_for_credit__c= UserInfo.getUserId());
        insert objOrd;

         WorkOrder objWorkOrder = new WorkOrder(Status = Constants.PICKLIST_VALUE_ORDER_STATUS_NOT_SUBMITTED,
             								   StartDate = Date.today(),
                                               EndDate = Date.today() + 20,
                                               Pricebook2Id = pricebookId,
                                               rep_at_implant__c = UserInfo.getUserId(),
                                               patient__c =patient.Id,
                                               referring_physician__c= physician.Id,
                                               following_physician__c=physician.Id,
                                               AccountId = objAccount.Id
                                               );
        insert objWorkOrder;
        
        System.debug('objWorkOöllr'+objWorkOrder);
        
        ProductConsumed item = new ProductConsumed(WorkOrderId = objWorkOrder.Id,
                                                   PricebookEntryId = standardPrice.Id,
                                                   QuantityConsumed = 2);
        
        ProductConsumed item_2 = new ProductConsumed(WorkOrderId = objWorkOrder.Id,
                                                   PricebookEntryId = standardPrice.Id,
                                                   QuantityConsumed = 2);
        lstPc.add(item);
        lstPc.add(item_2);
        insert lstPc; 

        WorkOrderLineItem objWoli = new WorkOrderLineItem(status = Constants.PICKLIST_STATUS_VALUE_WORK_ORDER_LINE_ITEM_NOT_SUBMITTED,
                                                          WorkOrderId = objWorkOrder.Id,
                                                          OrderId = objOrd.Id);
        
        WorkOrderLineItem objWoli_2 = new WorkOrderLineItem(status = Constants.PICKLIST_STATUS_VALUE_WORK_ORDER_LINE_ITEM_NOT_SUBMITTED,
                                                          WorkOrderId = objWorkOrder.Id,
                                                          OrderId = objOrd.Id);
        lstwoli.add(objWoli);
        lstwoli.add(objWoli_2);
        insert lstwoli;
        
        Test.startTest();
            System.debug('objWorkOrder'+objWorkOrder);
        	objWorkOrder.Status = WorkOrderHandler.CANCELED;
            update objWorkOrder;
        Test.stopTest();
        
            WorkOrder wolst = [select Id,referring_physician__c, patient__c, implanting_physician__c, following_physician__c
                               		FROM  WorkOrder
                                   	WHERE Id =:objWorkOrder.Id];
        
           System.assertEquals(NULL, wolst.referring_physician__c);
           System.assertEquals(NULL, wolst.patient__c);
        
        
           WorkOrderLineItem woli =[Select Id, Status, WorkOrderId FROM WorkOrderLineItem where WorkOrderId = :objWorkOrder.Id LIMIT 1 ];
          
           System.assertEquals(Constants.PICKLIST_STATUS_VALUE_WORK_ORDER_LINE_ITEM_CANCELED, woli.Status);
           
           List<ProductConsumed> pc = [SELECT Id, WorkOrderId From ProductConsumed WHERE WorkOrderId =: objWorkOrder.Id ];
           System.assertEquals(0, pc.size());
           System.debug('pc.size()' + pc.size());
        
    } 
}