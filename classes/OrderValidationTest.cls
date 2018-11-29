/**
* @author:			arwe
*					T-Systems Multimedia Solutions GmbH
*					Riesaer Strasse 5,
*					01129 Dresden
*					www.t-systems-mms.com
*
* @description      
*                  
*
* @date             12.10.2018
* 
*/

@IsTest
private class OrderValidationTest {

    static Account objAccount;
    static Order objOrder;
    static User testUser;


    @isTest
    static void testValidOrder(){
        init();

        System.runAs(testUser){
            Product2 prod = new Product2(Name = 'ICD');
            prod.product_type__c = Constants.PICKLIST_VALUE_PRODUCT_TYPE_ICD;
            insert prod;

            Asset objAsset = TestDataFactory.createAsset(objOrder.AccountId);
            objAsset.order__c = objOrder.Id;
            objAsset.Status = Constants.IMPLANT_STATUS_IMPLANTED;
            objAsset.product_type__c = Constants.PICKLIST_VALUE_PRODUCT_TYPE_ICD;
            objAsset.Product2Id = prod.Id;
            objAsset.patient__c = objOrder.patient__c;
            insert objAsset;

            List<OrderItem> lstOrderItems = new List<OrderItem>();
            OrderItem objOrderDevice = TestDataFactory.createOrderItem(objOrder.Id);
            objOrderDevice.product_type__c = Constants.PICKLIST_VALUE_PRODUCT_TYPE_PACEMAKER;
            objOrderDevice.stock_type__c = 'L';
            objOrderDevice.part_of_system_price__c = true;
            objOrderDevice.UnitPrice = 0;
            lstOrderItems.add(objOrderDevice);
            OrderItem objOrderLead = TestDataFactory.createOrderItem(objOrder.Id);
            objOrderLead.product_type__c = Constants.PICKLIST_VALUE_PRODUCT_TYPE_LEAD;
            objOrderLead.part_of_system_price__c = true;
            objOrderLead.UnitPrice = 0;
            lstOrderItems.add(objOrderLead);
            OrderItem objOrderLead2 = TestDataFactory.createOrderItem(objOrder.Id);
            objOrderLead2.product_type__c = Constants.PICKLIST_VALUE_PRODUCT_TYPE_LEAD;
            objOrderLead2.part_of_system_price__c = true;
            objOrderLead2.UnitPrice = 0;
            lstOrderItems.add(objOrderLead2);
            insert lstOrderItems;

            Test.startTest();
            objOrder.Status = Constants.PICKLIST_VALUE_ORDER_STATUS_SUBMITTED_PROCESSING;
            update objOrder;
            Test.stopTest();
        }

        assertValidation(Constants.PICKLIST_VALIDATION_REASON_NONE);
    }

    /**
    * Method checks OrderItem is a Lead and "Price" = $0, AND not part of the System
    * and MDRF status is changed to processing then send the order to review
    */
    @isTest
    static void testZeroDollarLeadOutsideSystem() {
        init();

        System.runAs(testUser){
            List<OrderItem> lstOrderItems = new List<OrderItem>();
            OrderItem objOrderDevice = TestDataFactory.createOrderItem(objOrder.Id);
            objOrderDevice.product_type__c = Constants.PICKLIST_VALUE_PRODUCT_TYPE_PACEMAKER;
            objOrderDevice.stock_type__c = 'L';
            objOrderDevice.part_of_system_price__c = false;
            objOrderDevice.UnitPrice = 0;
            lstOrderItems.add(objOrderDevice);

            Product2 prod = new Product2(Name = 'ICD');
            prod.product_type__c = 'ICD';
            insert prod;

            Asset objAsset = TestDataFactory.createAsset(objOrder.AccountId);
            objAsset.order__c = objOrder.Id;
            objAsset.Status = Constants.IMPLANT_STATUS_IMPLANTED;
            objAsset.Product2Id = prod.Id;
            insert objAsset;

            OrderItem objOrderLead = TestDataFactory.createOrderItem(objOrder.Id);
            objOrderLead.product_type__c = Constants.PICKLIST_VALUE_PRODUCT_TYPE_LEAD;
            objOrderLead.part_of_system_price__c = true;
            objOrderLead.UnitPrice = 0;
            lstOrderItems.add(objOrderLead);
            OrderItem objOrderLead2 = TestDataFactory.createOrderItem(objOrder.Id);
            objOrderLead2.product_type__c = Constants.PICKLIST_VALUE_PRODUCT_TYPE_LEAD;
            objOrderLead2.part_of_system_price__c = true;
            objOrderLead2.UnitPrice = 0;
            lstOrderItems.add(objOrderLead2);
            insert lstOrderItems;

            Test.startTest();
            objOrder.Status = Constants.PICKLIST_VALUE_ORDER_STATUS_SUBMITTED_PROCESSING;
            update objOrder;
            Test.stopTest();
        }

        assertValidation(Constants.PICKLIST_VALIDATION_REASON_ZERO_DOLLAR_PRODUCT_OUTSIDE_SYSTEM);
    }

    @isTest
    static void testZeroDollarLoopRecorderOutsideSystem() {
        init();

        System.runAs(testUser){
            List<OrderItem> lstOrderItems = new List<OrderItem>();
            OrderItem objOrderDevice = TestDataFactory.createOrderItem(objOrder.Id);
            objOrderDevice.product_type__c = Constants.PICKLIST_VALUE_PRODUCT_TYPE_LOOP_RECORDER;
            objOrderDevice.stock_type__c = 'L';
            objOrderDevice.part_of_system_price__c = false;
            objOrderDevice.UnitPrice = 0;
            lstOrderItems.add(objOrderDevice);

            Product2 prod = new Product2(Name = 'ICD');
            prod.product_type__c = 'ICD';
            insert prod;

            Asset objAsset = TestDataFactory.createAsset(objOrder.AccountId);
            objAsset.order__c = objOrder.Id;
            objAsset.Status = Constants.IMPLANT_STATUS_IMPLANTED;
            objAsset.Product2Id = prod.Id;
            insert objAsset;

            OrderItem objOrderLead = TestDataFactory.createOrderItem(objOrder.Id);
            objOrderLead.product_type__c = Constants.PICKLIST_VALUE_PRODUCT_TYPE_LEAD;
            objOrderLead.part_of_system_price__c = true;
            objOrderLead.UnitPrice = 0;
            lstOrderItems.add(objOrderLead);
            OrderItem objOrderLead2 = TestDataFactory.createOrderItem(objOrder.Id);
            objOrderLead2.product_type__c = Constants.PICKLIST_VALUE_PRODUCT_TYPE_LEAD;
            objOrderLead2.part_of_system_price__c = true;
            objOrderLead2.UnitPrice = 0;
            lstOrderItems.add(objOrderLead2);
            insert lstOrderItems;

            Test.startTest();
            objOrder.Status = Constants.PICKLIST_VALUE_ORDER_STATUS_SUBMITTED_PROCESSING;
            update objOrder;
            Test.stopTest();
        }

        assertValidation(Constants.PICKLIST_VALIDATION_REASON_ZERO_DOLLAR_PRODUCT_OUTSIDE_SYSTEM);
    }

    /**
    * Method checks OrderItem has Location as "Bulk Stock", OrderItem Adjusted Price > 0
    * and MDRF status is changed to processing from Not submitted
    * then send the order to review
    */
    @isTest
    static void testBulkProductPriceGreaterZero() {
        init();

        System.runAs(testUser){
            OrderItem objOrderItem = TestDataFactory.createOrderItem(objOrder.Id);
            objOrderItem.stock_type__c = Constants.PICKLIST_VALUE_ORDER_ITEM_STOCK_TYPE_BULK;
            objOrderItem.UnitPrice = 19;
            insert objOrderItem;

            Test.startTest();
            objOrder.Status = Constants.PICKLIST_VALUE_ORDER_STATUS_SUBMITTED_PROCESSING;
            update objOrder;
            Test.stopTest();
        }
        assertValidation(Constants.PICKLIST_VALIDATION_REASON_BULK_PRODUCT_WITH_PRICE_GREATER_ZERO);
    }

    /**
    * Method checks Implanting facility is in  Puerto Rico
    * then send the order to review
    */
    @isTest
    static void testLocationPuertoRico() {
        init();

        System.runAs(testUser){
            Product2 prod = new Product2(Name = 'ICD');
            prod.product_type__c = Constants.PICKLIST_VALUE_PRODUCT_TYPE_ICD;
            insert prod;

            Asset objAsset = TestDataFactory.createAsset(objOrder.AccountId);
            objAsset.order__c = objOrder.Id;
            objAsset.Status = Constants.IMPLANT_STATUS_IMPLANTED;
            objAsset.product_type__c = Constants.PICKLIST_VALUE_PRODUCT_TYPE_ICD;
            objAsset.Product2Id = prod.Id;
            objAsset.patient__c = objOrder.patient__c;
            insert objAsset;

            List<OrderItem> lstOrderItems = new List<OrderItem>();
            OrderItem objOrderDevice = TestDataFactory.createOrderItem(objOrder.Id);
            objOrderDevice.product_type__c = Constants.PICKLIST_VALUE_PRODUCT_TYPE_PACEMAKER;
            objOrderDevice.stock_type__c = 'L';
            objOrderDevice.part_of_system_price__c = true;
            objOrderDevice.UnitPrice = 0;
            lstOrderItems.add(objOrderDevice);
            OrderItem objOrderLead = TestDataFactory.createOrderItem(objOrder.Id);
            objOrderLead.product_type__c = Constants.PICKLIST_VALUE_PRODUCT_TYPE_LEAD;
            objOrderLead.part_of_system_price__c = true;
            objOrderLead.UnitPrice = 0;
            lstOrderItems.add(objOrderLead);
            OrderItem objOrderLead2 = TestDataFactory.createOrderItem(objOrder.Id);
            objOrderLead2.product_type__c = Constants.PICKLIST_VALUE_PRODUCT_TYPE_LEAD;
            objOrderLead2.part_of_system_price__c = true;
            objOrderLead2.UnitPrice = 0;
            lstOrderItems.add(objOrderLead2);
            insert lstOrderItems;

            objAccount.ShippingCountryCode = 'US';
            objAccount.ShippingStateCode = 'PR';
            update objAccount;

            Test.startTest();
            objOrder.Status = Constants.PICKLIST_VALUE_ORDER_STATUS_SUBMITTED_PROCESSING;
            update objOrder;
            Test.stopTest();
        }
        assertValidation(Constants.PICKLIST_VALIDATION_REASON_IMPLANTING_FACILITY_IN_PUERTO_RICO);
    }

    /**
    * Method checks if asset is part of system and has price more than 0
    * then send the order to review
    */
    @isTest
    static void testPartOfSysOrderItemPrice() {
        init();

        System.runAs(testUser){
            OrderItem objOrderItem = TestDataFactory.createOrderItem(objOrder.Id);
            objOrderItem.part_of_system_price__c = true;
            objOrderItem.UnitPrice = 19;
            insert objOrderItem;

            Test.startTest();
            objOrder.Status = Constants.PICKLIST_VALUE_ORDER_STATUS_SUBMITTED_PROCESSING;
            update objOrder;
            Test.stopTest();
        }

        assertValidation(Constants.PICKLIST_VALIDATION_REASON_PART_OF_SYSTEM_AND_PRICE_GREATER_ZERO);
    }

    /**
    * Method checks if asset is device out of system and has price more than 0
    * then send the order to review to customer solution queue
    */
    @isTest
    static void testDeviceWithNoLeads(){
        init();

        System.runAs(testUser){
            OrderItem objOrderItem = TestDataFactory.createOrderItem(objOrder.Id);
            objOrderItem.product_type__c = Constants.PICKLIST_VALUE_PRODUCT_TYPE_ICD;
            objOrderItem.part_of_system_price__c = false;
            objOrderItem.UnitPrice = 2;
            insert objOrderItem;

            Test.startTest();
            objOrder.Status = Constants.PICKLIST_VALUE_ORDER_STATUS_SUBMITTED_PROCESSING;
            update objOrder;
            Test.stopTest();
        }
        assertValidation(Constants.PICKLIST_VALIDATION_REASON_DEVICE_WITH_NO_LEADS);
    }

    /**
    * Method checks if asset is device out of system and has price more than 0
    * then send the order to review to customer solution queue
    */
    @isTest
    static void testDeviceWithOneNotImplantedLead(){
        init();

        System.runAs(testUser){
            Product2 prod = new Product2(Name = 'Lead');
            prod.product_type__c = Constants.PICKLIST_VALUE_PRODUCT_TYPE_LEAD;
            insert prod;

            Asset objAsset = TestDataFactory.createAsset(objOrder.AccountId);
            objAsset.order__c = objOrder.Id;
            objAsset.patient__c = objOrder.patient__c;
            objAsset.Status = Constants.IMPLANT_STATUS_EXPLANTED;
            objAsset.product_type__c = Constants.PICKLIST_VALUE_PRODUCT_TYPE_LEAD;
            objAsset.Product2Id = prod.Id;

            objAsset.oos_date__c = Date.today();
            objAsset.oos_additional_information__c = 'test';
            objAsset.explant_Date__c = Date.today();
            objAsset.event_reason__c = Constants.PICKLIST_VALUE_OOS_REASON_UPGRADE;
            objAsset.has_attached_oos_complaints__c = false;
            insert objAsset;

            OrderItem objOrderItem = TestDataFactory.createOrderItem(objOrder.Id);
            objOrderItem.product_type__c = Constants.PICKLIST_VALUE_PRODUCT_TYPE_ICD;
            objOrderItem.part_of_system_price__c = false;
            objOrderItem.UnitPrice = 2;
            insert objOrderItem;

            Test.startTest();
            objOrder.Status = Constants.PICKLIST_VALUE_ORDER_STATUS_SUBMITTED_PROCESSING;
            update objOrder;
            Test.stopTest();
        }
        assertValidation(Constants.PICKLIST_VALIDATION_REASON_DEVICE_WITH_NO_LEADS);
    }

    /**
    * Method checks if reason for price discepancy is bulk swap then send to review
    * also when the order is reviewed in 2nd step submit it to SAP and chnge queue
    */
    @isTest
    static void testSecondStep(){
        init();

        System.runAs(testUser){
            OrderItem objOrderItem = TestDataFactory.createOrderItem(objOrder.Id);
            objOrderItem.product_type__c = Constants.PICKLIST_VALUE_PRODUCT_TYPE_LEAD;

            objOrderItem.price_discrepancy_reason__c = Constants.PICKLIST_VALUE_ORDER_ITEM_DISCREPANY_REASON_BULKSWAP;
            objOrderItem.UnitPrice = 1;
            insert objOrderItem;

            objOrder.Status = Constants.PICKLIST_VALUE_ORDER_STATUS_SUBMITTED_PROCESSING;
            update objOrder;

            objOrder = [SELECT Id, OwnerId, submit_to_sap__c, validation_reason__c FROM Order WHERE Id = :objOrder.Id];

            assertValidation(Constants.PICKLIST_VALIDATION_REASON_PRICE_DISCREPANCY_REASON_BULK_SWAP);

            Test.startTest();
            objOrderItem.price_discrepancy_reason__c = '';
            update objOrderItem;

            objOrder.validation_reason__c = 'None';
            objOrder.Status = Constants.PICKLIST_VALUE_ORDER_STATUS_PENDING_SAP;
            update objOrder;
            Test.stopTest();
        }

        assertValidation(Constants.PICKLIST_VALIDATION_REASON_NONE);
    }

    /**
   * Method checks validation for more than one realated device
   */
    @isTest
    static void test2DeviceWith2Leads(){
        init();

        System.runAs(testUser){
            List<OrderItem> lstItems = new List<OrderItem>();
            OrderItem objOrderItem = TestDataFactory.createOrderItem(objOrder.Id);
            objOrderItem.product_type__c = Constants.PICKLIST_VALUE_PRODUCT_TYPE_PACEMAKER;
            objOrderItem.part_of_system_price__c = false;
            objOrderItem.UnitPrice = 0;
            lstItems.add(objOrderItem);

            OrderItem objOrderItem2 = TestDataFactory.createOrderItem(objOrder.Id);
            objOrderItem2.product_type__c = Constants.PICKLIST_VALUE_PRODUCT_TYPE_PACEMAKER;
            objOrderItem2.part_of_system_price__c = false;
            objOrderItem2.UnitPrice = 0;
            lstItems.add(objOrderItem2);

            OrderItem objLead = TestDataFactory.createOrderItem(objOrder.Id);
            objLead.product_type__c = Constants.PICKLIST_VALUE_PRODUCT_TYPE_LEAD;
            objLead.price_discrepancy_reason__c = Constants.PICKLIST_VALUE_ORDER_ITEM_DISCREPANY_REASON_BULKSWAP;
            objLead.UnitPrice = 1;
            lstItems.add(objLead);

            OrderItem objLead2 = TestDataFactory.createOrderItem(objOrder.Id);
            objLead2.product_type__c = Constants.PICKLIST_VALUE_PRODUCT_TYPE_LEAD;
            objLead2.price_discrepancy_reason__c = Constants.PICKLIST_VALUE_ORDER_ITEM_DISCREPANY_REASON_BULKSWAP;
            objLead2.UnitPrice = 1;
            lstItems.add(objLead2);

            Product2 prod = new Product2(Name = 'ICD');
            prod.product_type__c = 'ICD';
            insert prod;

            Asset objAsset = TestDataFactory.createAsset(objOrder.AccountId);
            objAsset.order__c = objOrder.Id;
            objAsset.patient__c = objOrder.patient__c;
            objAsset.Status = Constants.IMPLANT_STATUS_IMPLANTED;
            objAsset.Product2Id = prod.Id;
            insert objAsset;

            objAsset = TestDataFactory.createAsset(objOrder.AccountId);
            objAsset.order__c = objOrder.Id;
            objAsset.patient__c = objOrder.patient__c;
            objAsset.Status = Constants.IMPLANT_STATUS_IMPLANTED;
            objAsset.Product2Id = prod.Id;
            insert objAsset;

            insert lstItems;

            Test.startTest();
            objOrder.Status = Constants.PICKLIST_VALUE_ORDER_STATUS_SUBMITTED_PROCESSING;
            update objOrder;
            Test.stopTest();
        }

        Order objOrder = [SELECT Id, validation_reason__c FROM Order WHERE Id = :objOrder.Id];
        System.assertEquals('Price Discrepancy Reason = Bulk swap;More than 1 Device on MDRF', objOrder.validation_reason__c);
    }

    // Test If only Order Items (Product Type = 'Lead') was attached to the submitted Order Record
    // AND NO Asset with Product Type 'Device' OR 'ICD' OR 'Pacemaker' and Status 'Implanted'
    @isTest
    static void testLeadWithNoDevice(){
        init();

        System.runAs(testUser){
            OrderItem objOrderItem = TestDataFactory.createOrderItem(objOrder.Id);
            objOrderItem.product_type__c = Constants.PICKLIST_VALUE_PRODUCT_TYPE_LEAD;
            objOrderItem.part_of_system_price__c = true;
            objOrderItem.UnitPrice = 0;
            insert objOrderItem;

            Test.startTest();
            objOrder.Status = Constants.PICKLIST_VALUE_ORDER_STATUS_SUBMITTED_PROCESSING;
            update objOrder;
            Test.stopTest();
        }
        assertValidation(Constants.PICKLIST_VALIDATION_REASON_LEAD_WITH_NO_DEVICE);
    }

    @isTest
    static void testDeviceWithOnlyOneLead(){
        init();

        System.runAs(testUser){
            List<OrderItem> lstOrderItems = new List<OrderItem>();
            OrderItem objOrderDevice = TestDataFactory.createOrderItem(objOrder.Id);
            objOrderDevice.product_type__c = Constants.PICKLIST_VALUE_PRODUCT_TYPE_ICD;
            objOrderDevice.part_of_system_price__c = false;
            objOrderDevice.UnitPrice = 2;
            lstOrderItems.add(objOrderDevice);

            OrderItem objOrderLead = TestDataFactory.createOrderItem(objOrder.Id);
            objOrderLead.product_type__c = Constants.PICKLIST_VALUE_PRODUCT_TYPE_LEAD;
            objOrderLead.part_of_system_price__c = true;
            objOrderLead.UnitPrice = 0;
            lstOrderItems.add(objOrderLead);
            insert lstOrderItems;

            Product2 prod = new Product2(Name = 'ICD');
            prod.product_type__c = 'ICD';
            insert prod;

            Asset objAsset = TestDataFactory.createAsset(objOrder.AccountId);
            objAsset.order__c = objOrder.Id;
            objAsset.patient__c = objOrder.patient__c;
            objAsset.Status = Constants.IMPLANT_STATUS_IMPLANTED;
            objAsset.Product2Id = prod.Id;
            insert objAsset;

            Test.startTest();
            objOrder.Status = Constants.PICKLIST_VALUE_ORDER_STATUS_SUBMITTED_PROCESSING;
            update objOrder;
            Test.stopTest();
        }
        assertValidation(Constants.PICKLIST_VALIDATION_REASON_DEVICE_WITH_ONLY_ONE_LEAD);
    }

    @isTest
    static void testLeadItemAndOneLeadAssetNoDevice(){
        init();

        System.runAs(testUser){
            List<OrderItem> lstOrderItems = new List<OrderItem>();
            OrderItem objOrderLead = TestDataFactory.createOrderItem(objOrder.Id);
            objOrderLead.product_type__c = Constants.PICKLIST_VALUE_PRODUCT_TYPE_LEAD;
            objOrderLead.part_of_system_price__c = true;
            objOrderLead.UnitPrice = 0;
            lstOrderItems.add(objOrderLead);
            insert lstOrderItems;

            Product2 prod = new Product2(Name = 'ICD');
            prod.product_type__c = 'ICD';
            insert prod;

            List<Asset> lstAssetsToInsert = new List<Asset>();
            Asset objAssetLead = TestDataFactory.createAsset(objOrder.AccountId);
            objAssetLead.Status = Constants.IMPLANT_STATUS_IMPLANTED;
            objAssetLead.Product2Id = prod.Id;
            objAssetLead.product_type__c = Constants.PICKLIST_VALUE_PRODUCT_TYPE_LEAD;
            objAssetLead.patient__c = objOrder.patient__c;
            lstAssetsToInsert.add(objAssetLead);
            insert lstAssetsToInsert;

            objOrderLead.asset__c = objAssetLead.Id;
            update objOrderLead;

            Test.startTest();
            objOrder.Status = Constants.PICKLIST_VALUE_ORDER_STATUS_SUBMITTED_PROCESSING;
            update objOrder;
            Test.stopTest();
        }
        // check if DEVICE_WITH_NO_LEADS did not exist in Validation Reason
        assertNotValidationReasons(Constants.PICKLIST_VALIDATION_REASON_DEVICE_WITH_NO_LEADS);
        assertValidation(Constants.PICKLIST_VALIDATION_REASON_LEAD_WITH_NO_DEVICE);
    }

    @isTest
    static void testDeviceWithOneLeadItemAndOneLeadAsset(){
        init();

        System.runAs(testUser){
            List<OrderItem> lstOrderItems = new List<OrderItem>();
            OrderItem objOrderDevice = TestDataFactory.createOrderItem(objOrder.Id);
            objOrderDevice.product_type__c = Constants.PICKLIST_VALUE_PRODUCT_TYPE_PACEMAKER;
            objOrderDevice.part_of_system_price__c = false;
            objOrderDevice.UnitPrice = 2;
            lstOrderItems.add(objOrderDevice);

            OrderItem objOrderLead = TestDataFactory.createOrderItem(objOrder.Id);
            objOrderLead.product_type__c = Constants.PICKLIST_VALUE_PRODUCT_TYPE_LEAD;
            objOrderLead.part_of_system_price__c = true;
            objOrderLead.UnitPrice = 0;
            lstOrderItems.add(objOrderLead);
            insert lstOrderItems;

            Product2 prod = new Product2(Name = 'ICD');
            prod.product_type__c = 'ICD';
            insert prod;

            List<Asset> lstAssetsToInsert = new List<Asset>();
            Asset objAsset = TestDataFactory.createAsset(objOrder.AccountId);
            objAsset.order__c = objOrder.Id;
            objAsset.patient__c = objOrder.patient__c;
            objAsset.Status = Constants.IMPLANT_STATUS_IMPLANTED;
            objAsset.Product2Id = prod.Id;
            lstAssetsToInsert.add(objAsset);

            Asset objAssetLead = TestDataFactory.createAsset(objOrder.AccountId);
            objAssetLead.Status = Constants.IMPLANT_STATUS_IMPLANTED;
            objAssetLead.Product2Id = prod.Id;
            objAssetLead.product_type__c = Constants.PICKLIST_VALUE_PRODUCT_TYPE_LEAD;
            objAssetLead.patient__c = objOrder.patient__c;
            lstAssetsToInsert.add(objAssetLead);
            insert lstAssetsToInsert;

            Test.startTest();
            objOrder.Status = Constants.PICKLIST_VALUE_ORDER_STATUS_SUBMITTED_PROCESSING;
            update objOrder;
            Test.stopTest();
        }

        assertValidation(Constants.PICKLIST_VALIDATION_REASON_NONE);
    }

    @isTest
    static void testSingleLeadDeviceWithOnlyOneLead(){
        init();

        System.runAs(testUser){
            List<OrderItem> lstOrderItems = new List<OrderItem>();
            OrderItem objOrderDevice = TestDataFactory.createOrderItem(objOrder.Id);
            objOrderDevice.product_type__c = Constants.PICKLIST_VALUE_PRODUCT_TYPE_ICD;
            objOrderDevice.part_of_system_price__c = false;
            objOrderDevice.UnitPrice = 2;
            lstOrderItems.add(objOrderDevice);

            OrderItem objOrderLead = TestDataFactory.createOrderItem(objOrder.Id);
            objOrderLead.product_type__c = Constants.PICKLIST_VALUE_PRODUCT_TYPE_LEAD;
            objOrderLead.part_of_system_price__c = true;
            objOrderLead.UnitPrice = 0;
            lstOrderItems.add(objOrderLead);
            insert lstOrderItems;

            objOrderDevice = [SELECT Id, Product2Id FROM OrderItem WHERE Id = :objOrderDevice.Id LIMIT 1];
            Product2 prodOderItem = new Product2();
            prodOderItem.Id = objOrderDevice.Product2Id;
            prodOderItem.sub_group_4__c = 'Single Chamber Pacemakers';
            update prodOderItem;

            Product2 prod = new Product2(Name = 'ICD');
            prod.product_type__c = 'ICD';
            prod.sub_group_4__c = 'Single Chamber Pacemakers';
            insert prod;

            Asset objAsset = TestDataFactory.createAsset(objOrder.AccountId);
            objAsset.order__c = objOrder.Id;
            objAsset.patient__c = objOrder.patient__c;
            objAsset.Status = Constants.IMPLANT_STATUS_IMPLANTED;
            objAsset.Product2Id = prod.Id;
            insert objAsset;

            Test.startTest();
            objOrder.Status = Constants.PICKLIST_VALUE_ORDER_STATUS_SUBMITTED_PROCESSING;
            update objOrder;
            Test.stopTest();
        }

        assertValidation(Constants.PICKLIST_VALIDATION_REASON_NONE);
    }

    /**
    * Method checks if an Order with out any OrderItems get catched by
    * the validation
    */
    @isTest
    static void testOrderWithoutOrderItem() {
        init();

        try{
            System.runAs(testUser){
                Test.startTest();
                objOrder.Status = Constants.PICKLIST_VALUE_ORDER_STATUS_SUBMITTED_PROCESSING;
                update objOrder;

                System.assert(true, 'This part should not be reached.');

                Test.stopTest();
            }
        }catch(Exception ex){
            System.assert(ex.getMessage().contains(Label.ERR_ORDER_HAS_NO_ORDER_ITEMS), 'Wrong error. Msg: '+ex.getMessage());
        }

        objOrder = [SELECT Id, Status FROM Order WHERE Id = :objOrder.Id LIMIT 1];
        System.assertEquals(Constants.PICKLIST_VALUE_STATUS_NOT_SUBMITTED, objOrder.Status);
    }



    private static void init() {
        testUser = TestDataFactory.createUser(UserInfo.getProfileId());
        testUser.UserRoleId = [SELECT Id FROM UserRole WHERE DeveloperName = : Constants.USER_ROLE_NAME_SO LIMIT 1].Id;
        System.runAs(testUser){
            objAccount = TestDataFactory.createAccount();
            insert objAccount;

            Id orderRtId =  Utility.getRecordTypeId (Order.SObjectType, Constants.RECORD_TYPE_NAME_ORDER_MDRF);
            objOrder = TestDataFactory.createOrder(objAccount.Id);
            objOrder.Status = Constants.PICKLIST_VALUE_STATUS_NOT_SUBMITTED;
            objOrder.RecordTypeId = orderRtId;
            objOrder.PoNumber = '1234';
            objOrder.validation_reason__c = Constants.PICKLIST_VALIDATION_REASON_NONE;
            insert objOrder;
        }
    }

    private static void assertValidation(String validationReason){
        objOrder = [SELECT Id, OwnerId, validation_reason__c, Status FROM Order WHERE Id = :objOrder.Id LIMIT 1];

        String shouldStatus = OrderValidation.CAS_VALIDATION_VALUES.contains(validationReason) ? Constants.PICKLIST_VALUE_ORDER_STATUS_PENDING_REVIEW : Constants.PICKLIST_VALUE_ORDER_STATUS_PENDING_SAP;

        System.debug('ValidationReason '+objOrder.validation_reason__c + ' / Status '+objOrder.Status);
        System.assert(objOrder.validation_reason__c.contains(validationReason), 'Order validation reasons: '+objOrder.validation_reason__c);
        System.assertEquals(shouldStatus , objOrder.Status);
    }

    private static void assertNotValidationReasons(String validationReason){
        objOrder = [SELECT Id, OwnerId, validation_reason__c, Status FROM Order WHERE Id = :objOrder.Id LIMIT 1];

        String shouldStatus = OrderValidation.CAS_VALIDATION_VALUES.contains(validationReason) ? Constants.PICKLIST_VALUE_ORDER_STATUS_PENDING_REVIEW : Constants.PICKLIST_VALUE_ORDER_STATUS_PENDING_SAP;

        System.debug('ValidationReason '+objOrder.validation_reason__c + ' / Status '+objOrder.Status);
        System.assert(!objOrder.validation_reason__c.contains(validationReason), 'Validation Reason "'+ validationReason +'" should not exist; Order validation reasons: '+objOrder.validation_reason__c);
        System.assertEquals(shouldStatus , objOrder.Status);
    }
}