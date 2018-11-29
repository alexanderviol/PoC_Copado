/**
*
* Test class for Order Trigger and the OrderHandler
*
* @author			snpa
* @modifiedBy		ilu_pkas
* @created			2018-04-10
* @modified		2018-08-30
* @systemLayer		Test
*
*/
@isTest
private class OrderHandlerTest {
    static Account objAccount;
    static Order objOrder;
    static User testUser;

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

    /**
    * Method checks if donations, without any additional error, are processed
    * 	to the right queue and have the correct validation reason
    */
    @isTest
    static void testForDonation() {
        init();
        
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
            objOrder.donation__c = true;
            objOrder.Status = Constants.PICKLIST_VALUE_ORDER_STATUS_SUBMITTED_PROCESSING;
            update objOrder;
            Test.stopTest();
        }

        objOrder = [SELECT Id, OwnerId, validation_reason__c FROM Order WHERE Id = :objOrder.Id LIMIT 1];
        System.assert(objOrder.validation_reason__c.contains('Donation**'), 'Order validation reason: '+objOrder.validation_reason__c);
    }

    /**
    * Method checks that if a order gets flagged as a donation following steps are done:
    * 	-	marking the order items as donation
    *  -	setting the order items unit price to 0
    */
    @isTest
    static void changedToDonation() {
        init();

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
            objOrder.donation__c = true;
            update objOrder;
            Test.stopTest();
        }

        List<OrderItem> lstDonationItems = [SELECT Id, UnitPrice, ListPrice, part_of_donation__c FROM OrderItem WHERE OrderId = :objOrder.Id];
        System.assertNotEquals(0, lstDonationItems.size());
        for(OrderItem item :lstDonationItems){
            System.assertEquals(0, item.UnitPrice, 'Unit Price for the Donation was not set to zero');
            System.assertEquals(true, item.part_of_donation__c, 'The part of donation flag should be set');
        }
    }

    /**
     * Method checks that if a order gets the donation flag removed following steps are done:
     * 	-	removing the donation flag from the order items
     *  -	setting the order items unit price to the products list price
     */
    @isTest
    static void changedFromDonation() {
        init();

        System.runAs(testUser){
            objOrder.donation__c = true;
            update objOrder;

            List<OrderItem> lstItems = new List<OrderItem>();
            OrderItem objOrderItem = TestDataFactory.createOrderItem(objOrder.Id);
            objOrderItem.product_type__c = Constants.PICKLIST_VALUE_PRODUCT_TYPE_PACEMAKER;
            objOrderItem.part_of_system_price__c = false;
            objOrderItem.UnitPrice = 0;
            lstItems.add(objOrderItem);

            OrderItem objLead = TestDataFactory.createOrderItem(objOrder.Id);
            objLead.product_type__c = Constants.PICKLIST_VALUE_PRODUCT_TYPE_LEAD;
            objLead.UnitPrice = 2;
            lstItems.add(objLead);

            OrderItem objLead2 = TestDataFactory.createOrderItem(objOrder.Id);
            objLead2.product_type__c = Constants.PICKLIST_VALUE_PRODUCT_TYPE_LEAD;
            objLead2.UnitPrice = 2;
            lstItems.add(objLead2);

            insert lstItems;

            Test.startTest();
            objOrder.donation__c = false;
            update objOrder;
            Test.stopTest();
        }

        List<OrderItem> lstDonationItems = [SELECT Id, UnitPrice, part_of_donation__c, ListPrice FROM OrderItem WHERE OrderId = :objOrder.Id];
        for(OrderItem item :lstDonationItems){
            System.assertEquals(item.ListPrice, item.UnitPrice, 'Unit Price for the Donation was not set to the list price');
            System.assertEquals(false, item.part_of_donation__c, 'The part of donation flag should be false');
        }
    }

    //test check required value of a an orderItem when changing when submitting the order
    @isTest
    static void testCheckProductRequiredValue(){
        init();

        System.runAs(testUser){
            List<OrderItem> lstOrderItems = new List<OrderItem>();
            Product2 prod = new Product2(Name = 'Lead');
            insert prod;
            Id pricebookId = Test.getStandardPricebookId();
            PricebookEntry standardPrice = new PricebookEntry(
                    Pricebook2Id = pricebookId, Product2Id = prod.Id,
                    UnitPrice = 10000, IsActive = true);
            insert standardPrice;

            OrderItem objOrderItem = new OrderItem(
                    OrderId = objOrder.Id,
                    Quantity = 1,
                    PricebookEntryId = standardPrice.Id,
                    status__c = 'Implanted',
                    expiration_date_ubd__c = Date.today().addDays(20),
                    udi__c='6254879552412397745',
                    serial_number__c = NULL
            );
            objOrderItem.product_type__c = Constants.PICKLIST_VALUE_PRODUCT_TYPE_LEAD;
            objOrderItem.UnitPrice = 2;

            Test.startTest();
            lstOrderItems.add(objOrderItem);
            insert lstOrderItems;

            try{
                objOrder.Status = Constants.PICKLIST_VALUE_ORDER_STATUS_SUBMITTED_PROCESSING;
                update objOrder;
            }catch(Exception e){
                System.assertEquals(e.getMessage().contains(System.Label.ADD_PRODUCT_REQUIRED_VALUES), True);
                System.assertEquals(true, e.getMessage().contains(System.Label.ADD_PRODUCT_REQUIRED_VALUES), 'Expected Error1');
            }
        }
    }

    @isTest
    static void testCheckProductRequiredValuesWhenSystemDevice(){
        init();

        System.runAs(testUser){
            List<OrderItem> lstOrderItems = new List<OrderItem>();
            Product2 prod = new Product2(Name = 'System Device');
            insert prod;
            Id pricebookId = Test.getStandardPricebookId();
            PricebookEntry standardPrice = new PricebookEntry(
                    Pricebook2Id = pricebookId, Product2Id = prod.Id,
                    UnitPrice = 10000, IsActive = true);
            insert standardPrice;

            OrderItem objOrderItem = new OrderItem(
                    OrderId = objOrder.Id,
                    Quantity = 1,
                    PricebookEntryId = standardPrice.Id,
                    status__c = 'Implanted',
                    expiration_date_ubd__c = Date.today().addDays(20),
                    udi__c='6254879552412397745',
                    serial_number__c = NULL
            );
            objOrderItem.product_type__c = Constants.PICKLIST_VALUE_PRODUCT_TYPE_ICD;
            objOrderItem.UnitPrice = 2;

            Test.startTest();
            lstOrderItems.add(objOrderItem);
            insert lstOrderItems;

            try {
                objOrder.Status = Constants.PICKLIST_VALUE_ORDER_STATUS_SUBMITTED_PROCESSING;
                update objOrder;
            } catch(Exception e) {
                System.assertEquals(true, e.getMessage().contains(System.Label.ADD_PRODUCT_REQUIRED_VALUES), 'Expected Error3');
            }
            Test.stopTest();
        }
    }

    @isTest
    static void validateOosAssets(){
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

            WorkOrder workorder = TestDataFactory.createWorkOrder();
            workorder.order__c = objOrder.Id;
            workorder.patient__c = objOrder.patient__c;
            insert workorder;

            Asset objAsset = TestDataFactory.createAsset(objOrder.AccountId, prod.Id);
            objAsset.patient__c = objOrder.patient__c;
            objAsset.Status = Constants.IMPLANT_STATUS_EXPLANTED;
            objAsset.oos_date__c = null;
            objAsset.imported_as_oos__c = false;
            objAsset.date_asset_status_changed__c = Date.today();
            objAsset.RecordTypeId = Utility.getRecordTypeId(Asset.SObjectType, Constants.RECORD_TYPE_NAME_ASSET_US_BIOTRONIK);
            insert objAsset;

            boolean bException = false;
            try{
                Test.startTest();
                objOrder.Status = Constants.PICKLIST_VALUE_ORDER_STATUS_SUBMITTED_PROCESSING;
                update objOrder;
                Test.stopTest();
            }catch(System.DmlException ex){
                System.debug('### msg '+ex.getMessage());
                if(ex.getMessage().contains(System.Label.ERR_OOS_VALIDATION))
                    bException = true;
            }

            Order objOrder = [SELECT Id, OwnerId, validation_reason__c, Status FROM Order WHERE Id = :objOrder.Id];
            System.assertEquals(true, bException, 'Expected Exception');
            System.assertEquals(Constants.PICKLIST_VALUE_STATUS_NOT_SUBMITTED, objOrder.Status);
        }
    }

    @isTest
    static void testCheckImplantingPhysicianInfoIfNoPhone(){
        init();

        System.runAs(testUser){
            Contact physician =  TestDataFactory.createPhysician(false);
            physician.phone = '';
            physician.AccountId = objAccount.Id;
            insert physician;

            Contact objCnt = TestDataFactory.createPatient(true);

            objOrder.implanting_physician__c = physician.Id;
            update objOrder;

            Test.startTest();
            try{
                objOrder.Status = Constants.PICKLIST_VALUE_ORDER_STATUS_SUBMITTED_PROCESSING;
                update objOrder;
            }catch(Exception e){
                System.debug('### '+e.getMessage());
                System.assertEquals(true, e.getMessage().contains(System.Label.ADD_IMPLANTING_PHYSICIAN_PHONE_NUMBER), 'Expected Error2');
            }
            Test.stopTest();
        }
    }

    @isTest
    static void testCheckFollowingPhysicianInfoInfoPhone(){
        init();

        System.runAs(testUser){
            Contact physician =  TestDataFactory.createPhysician(false);
            physician.AccountId = objAccount.Id;
            insert physician;

            Contact followingphysician =  TestDataFactory.createPhysician(false);
            followingphysician.AccountId = objAccount.Id;
            followingphysician.Phone = '';
            followingphysician.LastName = followingphysician.LastName + 'TestName';
            insert followingphysician;

            Contact objCnt = TestDataFactory.createPatient(false);
            objCnt.following_physician__c = followingphysician.Id;
            insert objCnt;

            objOrder.implanting_physician__c = physician.Id;
            objOrder.patient__c = objCnt.Id;
            update objOrder;
            Test.startTest();
            try{

                objOrder.Status = Constants.PICKLIST_VALUE_ORDER_STATUS_SUBMITTED_PROCESSING;
                update objOrder;
            }catch(Exception e){
                System.assertEquals(true, e.getMessage().contains(System.Label.ADD_FOLLOWING_PHYSICIAN_PHONE));
            }
            Test.stopTest();
        }
    }
}