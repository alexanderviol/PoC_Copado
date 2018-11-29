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
* @date             03.10.2018
* 
*/

@IsTest
private class OrderStatusPermissionTest {

    private static Order createOrder(Id ownerId) {
        Account account = TestDataFactory.createAccount();
        account.RecordTypeId = Utility.getRecordTypeId(Account.getSObjectType(), Constants.RECORD_TYPE_NAME_ACCOUNT_PHYSICIAN);
        insert account;

        Order order = TestDataFactory.createOrder(account.Id);
        order.Status = Constants.PICKLIST_VALUE_ORDER_STATUS_NOT_SUBMITTED;
        order.OwnerId = ownerId;
        order.RecordTypeId = Utility.getRecordTypeId(Order.getSObjectType(), Constants.RECORD_TYPE_NAME_ORDER_CARDIO_MESSENGER);
        insert order;

        return order;
    }

    @IsTest
    static void checkPermittedChangesFail() {

        String profileSalesId = Utility.getProfileId(Constants.PROFILE_NAME_SALES);
        User salesUser = TestDataFactory.createUser(profileSalesId, 'SalesTes');
        insert salesUser;

        Account account = TestDataFactory.createAccount();
        insert account;

        Order order = TestDataFactory.createOrder(account.Id);
        order.OwnerId = salesUser.Id;
        order.Status = Constants.PICKLIST_VALUE_ORDER_STATUS_PENDING_SAP;
        order.RecordTypeId = Utility.getRecordTypeId(Order.getSObjectType(), Constants.RECORD_TYPE_NAME_ORDER_MDRF);
        insert order;

        Test.startTest();

        try {

            System.runAs(salesUser) {
                order.ShippingCity = 'Nowhere City';
                update order;
                System.assert(false, 'Code should not reach here! For this User Field change is not allowed');
            }

        } catch (DmlException e) {
            // all fine
            System.debug('Exception: ' + e.getMessage());
            System.assert(e.getMessage().contains(String.format(Label.ERR_FIELD_CHANGE_NOT_PERMITTED, new String[] {'shippingcity', order.Status})));
        }

        Test.stopTest();

        // Eval
        Order orderEval = [SELECT Id, Status, ShippingCity FROM Order WHERE Id = :order.Id];
        System.assertEquals(null, orderEval.ShippingCity);

    }

    @IsTest
    static void checkPermittedChanges() {

        String profileSalesId = Utility.getProfileId(Constants.PROFILE_NAME_SALES);
        User salesUser = TestDataFactory.createUser(profileSalesId, 'SalesTes');
        insert salesUser;

        Account account = TestDataFactory.createAccount();
        insert account;

        Order order = TestDataFactory.createOrder(account.Id);
        order.OwnerId = salesUser.Id;
        order.Status = Constants.PICKLIST_VALUE_ORDER_STATUS_PENDING_SAP;
        order.RecordTypeId = Utility.getRecordTypeId(Order.getSObjectType(), Constants.RECORD_TYPE_NAME_ORDER_MDRF);
        insert order;

        Test.startTest();

            System.runAs(salesUser) {
                order.PoNumber = '12';
                update order;
            }

        Test.stopTest();

        // Eval
        Order orderEval = [SELECT Id, Status, PoNumber FROM Order WHERE Id = :order.Id];
        System.assertEquals(order.PoNumber, orderEval.PoNumber);

    }

    @IsTest
    static void checkOrderStatusAdminCanDoEverything() {

        Order order = createOrder(UserInfo.getUserId());

        Test.startTest();

        order.Status = Constants.PICKLIST_VALUE_ORDER_STATUS_INVOICED;
        update order;

        Test.stopTest();

        // Eval

        Order orderEval = [SELECT Id, Status FROM Order WHERE Id = :order.Id];
        System.assertEquals(Constants.PICKLIST_VALUE_ORDER_STATUS_INVOICED, orderEval.Status);

    }

    @IsTest
    static void checkOrderStatusWithSalesUser() {

        String profileSalesId = Utility.getProfileId(Constants.PROFILE_NAME_SALES);

        User salesUser = TestDataFactory.createUser(profileSalesId, 'SalesTes');
        insert salesUser;

        Order order = createOrder(salesUser.Id);

        System.runAs(salesUser) {

            Test.startTest();

            order.Status = Constants.PICKLIST_VALUE_ORDER_STATUS_NOT_SUBMITTED;
            update order;

            Test.stopTest();
        }

        // Eval
        Order orderEval = [SELECT Id, Status FROM Order WHERE Id = :order.Id];
        System.assertEquals(Constants.PICKLIST_VALUE_ORDER_STATUS_NOT_SUBMITTED, orderEval.Status);

    }

    @IsTest
    static void checkOrderStatusWithSalesUserChangeHmsc() {

        String profileSalesId = Utility.getProfileId(Constants.PROFILE_NAME_SALES);

        User salesUser = TestDataFactory.createUser(profileSalesId, 'SalesTes');
        insert salesUser;

        Order order = createOrder(salesUser.Id);
        order.Status = Constants.PICKLIST_VALUE_ORDER_STATUS_NOT_SUBMITTED;
        update order;

        System.runAs(salesUser) {

            Test.startTest();

            order.Status = Constants.PICKLIST_VALUE_ORDER_STATUS_PENDING_HMSC;
            update order;

            Test.stopTest();
        }

        // Eval
        Order orderEval = [SELECT Id, Status FROM Order WHERE Id = :order.Id];
        System.assertEquals(Constants.PICKLIST_VALUE_ORDER_STATUS_PENDING_HMSC, orderEval.Status);

    }

    @IsTest
    static void checkOrderStatusWithSalesUserChangeHmscFail() {

        String profileSalesId = Utility.getProfileId(Constants.PROFILE_NAME_SALES);

        User salesUser = TestDataFactory.createUser(profileSalesId, 'SalesTes');
        insert salesUser;

        Order order = createOrder(salesUser.Id);
        order.Status = Constants.PICKLIST_VALUE_ORDER_STATUS_INVOICED;
        update order;
        Order orderOld;

        System.runAs(salesUser) {

            orderOld = [SELECT Id, Status FROM Order WHERE Id = :order.Id];

            Test.startTest();

            try {

                // set status to Pending Sap should fail
                order.Status = Constants.PICKLIST_VALUE_ORDER_STATUS_PENDING_SAP;
                update order;
                System.assert(false, 'Code should not reach here! For this User it is not allowed to put Status to "' + Constants.PICKLIST_VALUE_ORDER_STATUS_PENDING_SAP + '" status on Order is: "' + order.Status + '"');

            } catch (DmlException e) {
                // all fine
                System.debug('Exception: ' + e.getMessage());
                System.assert(e.getMessage().contains(Label.ERR_ORDER_STATUS_CHANGE_NOT_ALLOWED));
            }

            Test.stopTest();
        }

        // Eval
        Order orderEval = [SELECT Id, Status FROM Order WHERE Id = :order.Id];
        System.assertEquals(orderOld.Status, orderEval.Status);

    }

    @IsTest
    static void checkOrderStatusWithCasUser() {

        Id profileSalesId = Utility.getProfileId(Constants.PROFILE_NAME_SYSTEM_MMS_INSIDE_SALES);
        Id casUserRoleId = Utility.getUserRoleIdByName(Constants.User_ROLE_NAME_SO);
        System.debug('casUserRoleId ' + casUserRoleId);

        User salesUser = TestDataFactory.createUser(profileSalesId, 'SaInsTes');
        salesUser.UserRoleId = casUserRoleId;
        insert salesUser;

        Order order;

        System.runAs(salesUser) {

            order = createOrder(salesUser.Id);

            Test.startTest();

            order.Status = Constants.PICKLIST_VALUE_ORDER_STATUS_PENDING_SAP;
            update order;

            Test.stopTest();
        }

        // Eval
        Order orderEval = [SELECT Id, Status FROM Order WHERE Id = :order.Id];
        System.assertEquals(Constants.PICKLIST_VALUE_ORDER_STATUS_PENDING_SAP, orderEval.Status);

    }

    @IsTest
    static void checkOrderStatusWithSalesUserFail() {

        String profileSalesId = Utility.getProfileId(Constants.PROFILE_NAME_SALES);

        User salesUser = TestDataFactory.createUser(profileSalesId, 'SalesTes');
        insert salesUser;

        Order order = createOrder(salesUser.Id);
        Order orderOld;

        System.runAs(salesUser) {

            orderOld = [SELECT Id, Status FROM Order WHERE Id = :order.Id];

            Test.startTest();

            try {

                // set status to Pending Sap should fail
                order.Status = Constants.PICKLIST_VALUE_ORDER_STATUS_PENDING_SAP;
                update order;
                System.assert(false, 'Code should not reach here! For this User it is not allowed to put Status to "' + Constants.PICKLIST_VALUE_ORDER_STATUS_PENDING_SAP + '" status on Order is: "' + order.Status + '"');

            } catch (DmlException e) {
                // all fine
                System.debug('Exception: ' + e.getMessage());
                System.assert(e.getMessage().contains(Label.ERR_ORDER_STATUS_CHANGE_NOT_ALLOWED));
            }

            Test.stopTest();
        }

        // Eval
        Order orderEval = [SELECT Id, Status FROM Order WHERE Id = :order.Id];
        System.assertEquals(orderOld.Status, orderEval.Status);

    }

    @IsTest
    static void checkOrderStatusWithSalesUserAllradySubmittedFail() {

        String profileSalesId = Utility.getProfileId(Constants.PROFILE_NAME_SALES);

        User salesUser = TestDataFactory.createUser(profileSalesId, 'SalesTes');
        insert salesUser;

        Order order = createOrder(salesUser.Id);
        order.Status = Constants.PICKLIST_VALUE_ORDER_STATUS_PENDING_SAP;
        update order;
        Order orderOld;

        System.runAs(salesUser) {

            orderOld = [SELECT Id, Status FROM Order WHERE Id = :order.Id];

            Test.startTest();

            try {

                // set status to Pending Sap should fail
                order.Status = Constants.PICKLIST_VALUE_ORDER_STATUS_NOT_SUBMITTED;
                update order;
                System.assert(false, 'Code should not reach here! For this User it is not allowed to put Status to "' + Constants.PICKLIST_VALUE_ORDER_STATUS_PENDING_SAP + '" status on Order is: "' + order.Status + '"');

            } catch (DmlException e) {
                // all fine
                System.debug('Exception: ' + e.getMessage());
                System.assert(e.getMessage().contains(Label.ERR_ORDER_STATUS_CHANGE_NOT_ALLOWED));
            }

            Test.stopTest();
        }

        // Eval
        Order orderEval = [SELECT Id, Status FROM Order WHERE Id = :order.Id];
        System.assertEquals(orderOld.Status, orderEval.Status);

    }

    @IsTest
    static void checkOrderStatusWithInsideSalesUserFail() {

        String profileSalesId = Utility.getProfileId(Constants.PROFILE_NAME_SYSTEM_MMS_INSIDE_SALES);

        User salesUser = TestDataFactory.createUser(profileSalesId, 'SaInsTes');
        insert salesUser;

        Order order = createOrder(salesUser.Id);
        order.Status = Constants.PICKLIST_VALUE_ORDER_STATUS_PENDING_SAP;
        update order;
        Order orderOld;

        System.runAs(salesUser) {

            orderOld = [SELECT Id, Status FROM Order WHERE Id = :order.Id];

            Test.startTest();

            try {

                // set status to Pending Sap should fail
                order.Status = Constants.PICKLIST_VALUE_ORDER_STATUS_NOT_SUBMITTED;
                update order;
                System.assert(false, 'Code should not reach her! For this User it is not allowed to put Status to "' + Constants.PICKLIST_VALUE_ORDER_STATUS_NOT_SUBMITTED + '" status on Order is: "' + order.Status + '"');

            } catch (DmlException e) {
                // all fine
                System.debug('Exception: ' + e.getMessage());
                System.assert(e.getMessage().contains(Label.ERR_ORDER_STATUS_CHANGE_NOT_ALLOWED));
            }

            Test.stopTest();
        }

        // Eval
        Order orderEval = [SELECT Id, Status FROM Order WHERE Id = :order.Id];
        System.assertEquals(orderOld.Status, orderEval.Status);

    }
    
    @IsTest
    static void checkPermittedChangesCM() {

        String profileSalesId = Utility.getProfileId(Constants.PROFILE_NAME_SALES);
        User salesUser = TestDataFactory.createUser(profileSalesId, 'SalesTes');
        insert salesUser;

        Account account = TestDataFactory.createAccount();
        insert account;

        Order order = TestDataFactory.createOrder(account.Id);
        order.OwnerId = salesUser.Id;
        order.Status = Constants.PICKLIST_VALUE_ORDER_STATUS_PENDING_SAP;
        insert order;

        Test.startTest();

            System.runAs(salesUser) {
                order.PoNumber = '12';
                update order;
            }

        Test.stopTest();

        // Eval
        Order orderEval = [SELECT Id, Status, PoNumber FROM Order WHERE Id = :order.Id];
        System.assertEquals(order.PoNumber, orderEval.PoNumber);

    }

    @IsTest
    static void checkPermittedChangesFailCM() {

        String profileSalesId = Utility.getProfileId(Constants.PROFILE_NAME_SALES);
        User salesUser = TestDataFactory.createUser(profileSalesId, 'SalesTes');
        insert salesUser;

        Account account = TestDataFactory.createAccount();
        insert account;

        Order order = TestDataFactory.createOrder(account.Id);
        order.OwnerId = salesUser.Id;
        order.Status = Constants.PICKLIST_VALUE_ORDER_STATUS_PENDING_SAP;
        order.RecordTypeId = Utility.getRecordTypeId(Order.getSObjectType(), Constants.RECORD_TYPE_NAME_ORDER_CARDIO_MESSENGER);
        insert order;

        Test.startTest();

        try {

            System.runAs(salesUser) {
                order.ShippingCity = 'Nowhere City';
                update order;
                System.assert(false, 'Code should not reach here! For this User Field change is not allowed');
            }

        } catch (DmlException e) {
            // all fine
            System.debug('Exception: ' + e.getMessage());
            System.assert(e.getMessage().contains(String.format(Label.ERR_FIELD_CHANGE_NOT_PERMITTED, new String[] {'shippingcity', order.Status})));
        }

        Test.stopTest();

        // Eval
        Order orderEval = [SELECT Id, Status, ShippingCity FROM Order WHERE Id = :order.Id];
        System.assertEquals(null, orderEval.ShippingCity);

    }
    
    @IsTest
    static void checkChangesInAllowedStatusCM() {

        String profileSalesId = Utility.getProfileId(Constants.PROFILE_NAME_SALES);
        User salesUser = TestDataFactory.createUser(profileSalesId, 'SalesTes');
        insert salesUser;

        Account account = TestDataFactory.createAccount();
        insert account;

        Order order = TestDataFactory.createOrder(account.Id);
        order.OwnerId = salesUser.Id;
        order.Status = Constants.PICKLIST_VALUE_ORDER_STATUS_NOT_SUBMITTED;
        insert order;

        Test.startTest();

        System.runAs(salesUser) {
            order.ShippingCity = 'Nowhere City';
            update order;
        }
		
        Test.stopTest();

        // Eval
        Order orderEval = [SELECT Id, Status, ShippingCity FROM Order WHERE Id = :order.Id];
        System.assertEquals('Nowhere City', orderEval.ShippingCity);

    }
	
	@IsTest
    static void checkValidationSkip() {

        String profileSalesId = Utility.getProfileId(Constants.PROFILE_NAME_SALES);
        User salesUser = TestDataFactory.createUser(profileSalesId, 'SalesTes');
        insert salesUser;

        Account account = TestDataFactory.createAccount();
        insert account;

        Order order = TestDataFactory.createOrder(account.Id);
        order.OwnerId = salesUser.Id;
        order.Status = Constants.PICKLIST_VALUE_STATUS_NOT_SUBMITTED;
        order.RecordTypeId = Utility.getRecordTypeId(Order.getSObjectType(), Constants.RECORD_TYPE_NAME_ORDER_CARDIO_MESSENGER);
        insert order;

        Test.startTest();
			Utility.insertValidationSkip(order.Id);
        
            System.runAs(salesUser) {
                order.Status = Constants.PICKLIST_VALUE_ORDER_STATUS_PENDING_HMSC;
                order.ShippingCountryCode = 'DE';
                update order;
            }
        
        Utility.removeValidationSkip(order.Id);

        Test.stopTest();

        Order orderEval = [SELECT Id, Status, ShippingCountryCode FROM Order WHERE Id = :order.Id];
        System.assertEquals('DE', orderEval.ShippingCountryCode);
        System.assertEquals(Constants.PICKLIST_VALUE_ORDER_STATUS_PENDING_HMSC, orderEval.Status);

    }
    
        @IsTest
    static void checkChangesInAllowedStatusIfPOChange() {

        String profileSalesId = Utility.getProfileId(Constants.PROFILE_NAME_SALES);
        User salesUser = TestDataFactory.createUser(profileSalesId, 'mySales');
        insert salesUser;

        Account account = TestDataFactory.createAccount();
        insert account;

        Order order = TestDataFactory.createOrder(account.Id);
        order.OwnerId = salesUser.Id;
        order.Status = Constants.PICKLIST_VALUE_ORDER_STATUS_PROCESSED_SAP;
        
        order.submit_to_sap__c = true;
        insert order;
        
        Order orderOld;
        
        System.runAs(salesUser) {

            orderOld = [SELECT Id, Status, PoNumber, submit_to_sap__c FROM Order WHERE Id = :order.Id];
            Test.startTest();

            try {

                // As sales set PO to not blanck (Status to Pending Sap and submit to SAP to false ) should not fail
                order.PoNumber = 'No963257';
                update order;
                System.assertNotEquals(null, order.PoNumber);
            } catch (DmlException e) {
                // all fine
                System.debug('Exception: ' + e.getMessage());
                System.assert(e.getMessage().contains(Label.ERR_ORDER_STATUS_CHANGE_NOT_ALLOWED));
            }

            Test.stopTest();

        }
    }
    @IsTest
    static void checkChangesInAllowedStatusIfPOChangeFail() {

        String profileSalesId = Utility.getProfileId(Constants.PROFILE_NAME_SALES);
        User salesUser = TestDataFactory.createUser(profileSalesId, 'mySales');
        insert salesUser;

        Account account = TestDataFactory.createAccount();
        insert account;

        Order order = TestDataFactory.createOrder(account.Id);
        order.OwnerId = salesUser.Id;
        order.Status = Constants.PICKLIST_VALUE_ORDER_STATUS_PROCESSED_SAP;
        order.PoNumber = '96325874111';
        order.submit_to_sap__c = true;
        insert order;
        
        Order orderOld;
        
        System.runAs(salesUser) {

            orderOld = [SELECT Id, Status, PoNumber, submit_to_sap__c FROM Order WHERE Id = :order.Id];
            Test.startTest();

            try {

                // As sales set a new PO
                order.PoNumber = 'No963257';
                update order;
                System.assert(order.PoNumber != orderOld.PoNumber);
                System.assert(order.Status == orderOld.Status);
            } catch (DmlException e) {
                // all fine
                System.debug('Exception: ' + e.getMessage());
                System.assert(e.getMessage().contains(Label.ERR_ORDER_STATUS_CHANGE_NOT_ALLOWED));
            }

            Test.stopTest();

        }
    }
}