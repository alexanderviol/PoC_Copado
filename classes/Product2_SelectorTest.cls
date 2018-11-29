/**************************************************************************************************************
* Product2_SelectorTest - Test Class for Product2_Selector class
* @author Gokul Palagiri
* @CreatedDate -    11.10.2018
* Gokul Palagiri:   11.10.2018 : Initial Version
****************************************************************************************************************/
@isTest
private class Product2_SelectorTest {
    static final String SALES_PROFILE = 'Sales';
    static Account objAccount;
    static Contact objContact;
    static Order objOrder;
    static OrderItem objOrderItem;
    static user testUser;
    static Asset objAsset;
    static Set<Id> product2Ids = new Set<Id>();

    @isTest
    private static void Test_getById(){
        if(product2Ids.isEmpty()){createTestData();}
        List<Product2> sObjectProduct2s = new Product2_Selector().getById(product2Ids, new Set<String>{Product2.Id.getDescribe().getName()});
        System.assert(sObjectProduct2s.size() > 0, 'Incorrect number of sObjects returned');

        List<Product2> sObjectProduct2sNull = new Product2_Selector().getById(new Set<Id>(), new Set<String>{Product2.Id.getDescribe().getName()});
        System.assertEquals(0, sObjectProduct2sNull.size(), 'Incorrect number of sObjects returned');
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
            product2Ids.add(prod.Id);
        }
    }

}