/* 2018-07-24 Florian Heer <f.heer@conciscon.de>
 * Tests functionality of the OrderItemHandler
 * 
 */
@isTest
public class OrderItemHandler_Test {

    public static final String NAME_ACCOUNT_IMPLANT = 'MyTestAccountImplant';
    public static final String NAME_ACCOUNT_CM = 'MyTestAccountCM';
    
    @testSetup
    public static void setupEnvironment() {
        String productName = 'MyProduct';
        Product2 cmProd, pmProd, leadProd, hmProd;
        Id serviceRTId = Utility.getRecordTypeId(Product2.SObjectType, Constants.RECORD_TYPE_NAME_PRODUCT_SERVICE);
        List<Product2> prods2Insert = new List<Product2>();
        
        cmProd = new Product2 (Name = productName + '_cm', IsActive = true, product_type__c = Constants.PICKLIST_VALUE_PRODUCT_TYPE_CARDIO_MESSENGER);
        prods2Insert.add(cmProd);

        
        
        hmProd = new Product2 (Name = productName + '_hm', IsActive = true, product_type__c = Constants.PICKLIST_VALUE_PRODUCT_TYPE_SERVICE,
                               ExternalId = Constants.HOME_MONITORING_SERVICE_SAP_EXTERNAL_ID,
                              sap_model_no__c = Constants.HOME_MONITORING_SERVICE_SAP_MODEL,
                              RecordTypeId = serviceRTId);
        prods2Insert.add(hmProd);

        
        pmProd = new Product2(Name = productName + '_pm', IsActive = true, product_type__c = Constants.PICKLIST_VALUE_PRODUCT_TYPE_PACEMAKER);
        prods2Insert.add(pmProd);
        leadProd = new Product2(Name = productName + '_lead', IsActive = true, product_type__c = Constants.PICKLIST_VALUE_PRODUCT_TYPE_LEAD);
        prods2Insert.add(leadProd);
        insert prods2Insert;

        Pricebook2 customPB = testDataFactory.findOrCreateCustomPricebook('custom test PB');
        TestDataFactory.upsertPricebookEntry(cmProd.Id, 500, customPB.Id);
        TestDataFactory.upsertPricebookEntry(pmProd.Id, 6000, customPB.Id);
        TestDataFactory.upsertPricebookEntry(leadProd.Id, 120, customPB.Id);
        TestDataFactory.upsertPricebookEntry(hmProd.Id, 0, customPB.Id);
        
        Contact patient = TestDataFactory.createPatient(true);
        
        Account acc = TestDataFactory.createAccount();
        acc.Name = NAME_ACCOUNT_IMPLANT;
        acc.crm_pricebook__c = customPB.Id;
        acc.sap_no__c = '12345';
        insert acc;

        Id orderImplantId = Utility.getRecordTypeId(Order.SObjectType, Constants.RECORD_TYPE_NAME_ORDER_MDRF);
        Id orderCMId = Utility.getRecordTypeId(Order.SObjectType, Constants.RECORD_TYPE_NAME_ORDER_CARDIO_MESSENGER);

        Order o =TestDataFactory.createOrder(acc.Id);
        o.Pricebook2Id = customPB.Id;
        o.RecordTypeId = orderImplantId;
        o.patient__c = patient.Id;
        o.no_rep_present_at_implant__c = true;
        o.rep_at_implant__c = null;
        insert o;

        acc = TestDataFactory.createAccount();
        acc.Name = NAME_ACCOUNT_CM;
        acc.crm_pricebook__c = customPB.Id;
        acc.sap_no__c = '1234';
        insert acc;
        
        o = TestDataFactory.createOrder(acc.Id);
        o.Pricebook2Id = customPB.Id;
        o.RecordTypeId = orderCMId;
        o.patient__c = patient.Id;
        insert o;
        
    }
    
    /* Test methods are split in two. Inserting an OrderItem causes over 23 SOQL statements.
     * 
     */
    @isTest
    public static void testAddHomeMonitoring_pt1() {
        Order implantOrder = [SELECT Id, num_hm_products__c, CurrencyIsoCode, Pricebook2Id FROM Order WHERE Account.Name = :NAME_ACCOUNT_IMPLANT];
        Order cmOrder = [SELECT Id, num_hm_products__c, CurrencyIsoCode, Pricebook2Id FROM Order WHERE Account.Name = :NAME_ACCOUNT_CM];
        System.assertEquals(0, implantOrder.num_hm_products__c);
        System.assertEquals(0, cmOrder.num_hm_products__c);
        
        System.debug('OIH_Test: -1 - ' + Limits.getQueries());
        List<Product2> cmProds = [SELECT Id FROM Product2 WHERE product_type__c = :Constants.PICKLIST_VALUE_PRODUCT_TYPE_CARDIO_MESSENGER AND Name LIKE 'MyProduct%'];
        List<Product2> pmProds = [SELECT Id FROM Product2 WHERE product_type__c = :Constants.PICKLIST_VALUE_PRODUCT_TYPE_PACEMAKER AND Name LIKE 'MyProduct%'];
        List<Product2> leadProds = [SELECT Id FROM Product2 WHERE product_type__c =: Constants.PICKLIST_VALUE_PRODUCT_TYPE_LEAD AND Name LIKE 'MyProduct%'];
        
        OrderItem oi = TestDataFactory.createOrderItem(cmOrder.Id, cmProds[0].Id
                                                                , cmOrder.CurrencyIsoCode, cmOrder.Pricebook2Id);
        System.debug('OIH_Test: 0 - ' + Limits.getQueries());
        Test.startTest();
        System.debug('OIH_Test: 1 - ' + Limits.getQueries());
        insert oi;
        System.debug('OIH_Test: 1.1 - ' + Limits.getQueries());
        cmOrder = [SELECT Id, num_hm_products__c, CurrencyIsoCode, Pricebook2Id FROM Order WHERE Account.Name = :NAME_ACCOUNT_CM];
        System.assertEquals(1, cmOrder.num_hm_products__c);
        System.debug('OIH_Test: 2 - ' + Limits.getQueries());
        oi = TestDataFactory.createOrderItem(implantOrder.Id, pmProds[0].Id
                                                                , cmOrder.CurrencyIsoCode, cmOrder.Pricebook2Id);
        insert oi;
        implantOrder = [SELECT Id, num_hm_products__c, CurrencyIsoCode, Pricebook2Id FROM Order WHERE Account.Name = :NAME_ACCOUNT_IMPLANT];
        System.assertEquals(0, implantOrder.num_hm_products__c, 'Home Monitoring is only supposed to be added when a Cardio Messenger is added, not for a Pacemaker');

        oi = TestDataFactory.createOrderItem(implantOrder.Id, leadProds[0].Id
                                                                , cmOrder.CurrencyIsoCode, cmOrder.Pricebook2Id);
        System.debug('OIH_Test: 3 - ' + Limits.getQueries());
        insert oi;
        Test.stopTest();
        implantOrder = [SELECT Id, num_hm_products__c, CurrencyIsoCode, Pricebook2Id FROM Order WHERE Account.Name = :NAME_ACCOUNT_IMPLANT];
        System.assertEquals(0, implantOrder.num_hm_products__c, 'Home Monitoring is only supposed to be added when a Cardio Messenger is added, not for a Lead');
    }
    
    @isTest
    public static void testAddHomeMonitoring_pt2() {
        Order implantOrder = [SELECT Id, num_hm_products__c, CurrencyIsoCode, Pricebook2Id FROM Order WHERE Account.Name = :NAME_ACCOUNT_IMPLANT];
        Order cmOrder = [SELECT Id, num_hm_products__c, CurrencyIsoCode, Pricebook2Id FROM Order WHERE Account.Name = :NAME_ACCOUNT_CM];
        System.assertEquals(0, implantOrder.num_hm_products__c);
        System.assertEquals(0, cmOrder.num_hm_products__c);
        
        System.debug('OIH_Test: -1 - ' + Limits.getQueries());
        List<Product2> cmProds = [SELECT Id FROM Product2 WHERE product_type__c =: Constants.PICKLIST_VALUE_PRODUCT_TYPE_CARDIO_MESSENGER AND Name LIKE 'MyProduct%'];
        List<Product2> pmProds = [SELECT Id FROM Product2 WHERE product_type__c =: Constants.PICKLIST_VALUE_PRODUCT_TYPE_PACEMAKER AND Name LIKE 'MyProduct%'];
        List<Product2> leadProds = [SELECT Id FROM Product2 WHERE product_type__c =: Constants.PICKLIST_VALUE_PRODUCT_TYPE_LEAD AND Name LIKE 'MyProduct%'];
        
        OrderItem oi = TestDataFactory.createOrderItem(cmOrder.Id, cmProds[0].Id
                                                                , cmOrder.CurrencyIsoCode, cmOrder.Pricebook2Id);
        System.debug('OIH_Test: 0 - ' + Limits.getQueries());
        Test.startTest();

        
        oi = TestDataFactory.createOrderItem(implantOrder.Id, cmProds[0].Id
                                                                , cmOrder.CurrencyIsoCode, cmOrder.Pricebook2Id);
        insert oi;
        implantOrder = [SELECT Id, num_hm_products__c, CurrencyIsoCode, Pricebook2Id FROM Order WHERE Account.Name = :NAME_ACCOUNT_IMPLANT];
        List<OrderItem> ois = [SELECT Id, Product2.Name, product_type__c, model_no__c FROM OrderItem WHERE OrderId = :implantOrder.Id];
        for(OrderItem oid : ois) {
            System.debug(oid + ' - ' + oid.model_no__c);
        }
        System.assertEquals(1, implantOrder.num_hm_products__c, 'Home Monitoring is supposed to be added when a Cardio Messenger is added.');
        System.debug('XXX: 4 - ' + Limits.getQueries());
        delete oi;
        implantOrder = [SELECT Id, num_hm_products__c, CurrencyIsoCode, Pricebook2Id FROM Order WHERE Account.Name = :NAME_ACCOUNT_IMPLANT];
        System.assertEquals(0, implantOrder.num_hm_products__c, 'Home Monitoring is supposed to be removed when all Cardio Messengers are deleted.');

        oi = TestDataFactory.createOrderItem(implantOrder.Id, cmProds[0].Id
                                             , cmOrder.CurrencyIsoCode, cmOrder.Pricebook2Id);
        insert oi;
        oi = TestDataFactory.createOrderItem(implantOrder.Id, cmProds[0].Id
                                             , cmOrder.CurrencyIsoCode, cmOrder.Pricebook2Id);
        System.debug('XXX: 5 - ' + Limits.getQueries());
        insert oi;
        Test.stopTest();
        implantOrder = [SELECT Id, num_hm_products__c, CurrencyIsoCode, Pricebook2Id FROM Order WHERE Account.Name = :NAME_ACCOUNT_IMPLANT];
        System.assertEquals(1, implantOrder.num_hm_products__c, 'Home Monitoring is supposed to be added only once.');


    }
}