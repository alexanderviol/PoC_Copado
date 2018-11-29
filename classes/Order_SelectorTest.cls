/**************************************************************************************************************
* Order_SelectorTest - Test Class for Order_Selector class
* @author Gokul Palagiri
* @CreatedDate -    11.10.2018
* Gokul Palagiri:   11.10.2018 : Initial Version
****************************************************************************************************************/
@isTest
private class Order_SelectorTest {
    static final String SALES_PROFILE = 'Sales';
    static Account objAccount;
    static Contact objContact;
    static Order objOrder;
    static OrderItem objOrderItem;
    static user testUser;
    static Order objAsset;
    static Set<Id> orderIds = new Set<Id>();

    @isTest
    private static void Test_getById(){
        if(orderIds.isEmpty()){createTestData();}
        List<Order> sObjectOrders = new Order_Selector().getById(orderIds, new Set<String>{Order.Id.getDescribe().getName()});
        System.assert(sObjectOrders.size() > 0, 'Incorrect number of sObjects returned');

        List<Order> sObjectOrdersNull = new Order_Selector().getById(new Set<Id>(), new Set<String>{Order.Id.getDescribe().getName()});
        System.assertEquals(0, sObjectOrdersNull.size(), 'Incorrect number of sObjects returned');
    }

    private static void createTestData() {
        Profile p = [SELECT Id, Name FROM Profile WHERE Name = :SALES_PROFILE];
        testUser = TestDataFactory.createUser(p.id);
        insert testUser;

        System.runAs(testUser) {
            objAccount = TestDataFactory.createAccount();
            insert objAccount;

            Id orderRtId =  Utility.getRecordTypeId (Order.SObjectType, Constants.RECORD_TYPE_NAME_ORDER_MDRF);
            objOrder = TestDataFactory.createOrder(objAccount.Id);
            objOrder.status = Constants.PICKLIST_VALUE_STATUS_NOT_SUBMITTED;
            objOrder.recordTypeId = orderRtId;
            objOrder.submit_to_sap__c = true;
            objOrder.PoNumber = '1234';
            objOrder.OwnerId = testUser.Id;
            insert objOrder;
            orderIds.add(objOrder.Id);

            objOrderItem = TestDataFactory.createOrderItem(objOrder.Id);
            Insert objOrderItem;

            Id idPateintRecordType = [SELECT Id, Name, DeveloperName FROM RecordType WHERE Name = 'Patient'].Id;
            objContact = new Contact(firstname='TEST', lastname= 'CONTACT',
                    Birthdate = System.today().addYears(-29),
                    declined_to_provide_address__c = true,
                    declined_to_provide_phone__c = true,
                    declined_to_provide_ssn__c = true,
                    accountid = objAccount.Id,
                    recordTypeId = idPateintRecordType);
            insert objContact;

            Product2 prod = new Product2(Name = Constants.PICKLIST_VALUE_PRODUCT_TYPE_ICD);
            prod.product_type__c = Constants.PICKLIST_VALUE_PRODUCT_TYPE_ICD;
            insert prod;

        }
    }

}