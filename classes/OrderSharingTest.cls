/**
* @author:			arwe
*					T-Systems Multimedia Solutions GmbH
*					Riesaer Strasse 5,
*					01129 Dresden
*					www.t-systems-mms.com
*
* @description      Tests for OrderSharing
*                  
*
* @date             04.10.2018
* 
*/

@IsTest
private class OrderSharingTest {
	    
    private static Order createOrder() {

        Account account = TestDataFactory.createAccount();
        insert account;
		
        Id orderRtId =  Utility.getRecordTypeId (Order.SObjectType, Constants.RECORD_TYPE_NAME_ORDER_MDRF);
        
        Order order = TestDataFactory.createOrder(account.Id);
        order.RecordTypeId = orderRtId;
        return order;
    }

    @IsTest
    static void createOrderWithTwoReps() {

        Id salesProfileId = Utility.getProfileId(Constants.PROFILE_NAME_SALES);

        List<User> users = new List<User>();
        User userManager = TestDataFactory.createUser(salesProfileId);
        users.add(userManager);        
        User userImplant = TestDataFactory.createUser(salesProfileId);
        users.add(userImplant);
        User userCredit = TestDataFactory.createUser(salesProfileId);        
        users.add(userCredit);

        insert users;
        
        users = new List<User>();
        userImplant.managerId = userManager.id;
		users.add(userImplant);
		userCredit.ManagerId = userImplant.Id;
		users.add(userCredit);
        update users;
        
        // create two Users
        Order order = createOrder();
        order.rep_at_implant__c = userImplant.Id;
        order.rep_for_credit__c = userCredit.Id;
		order.pricebook__c = Constants.CRM_ORDER;
        Test.startTest();

        insert order;

        Test.stopTest();

        // Eval Sharing
        List<OrderShare> orderSharings = [SELECT Id, UserOrGroupId, OrderAccessLevel, UserOrGroup.Name, OrderId 
                                          	FROM OrderShare 
                                          WHERE RowCause = 'Manual']; // WHERE OrderId = : order.Id

        System.debug('Evaluation of orderSharing ' + orderSharings);
        // there should be 3 Entries 2 for reps and 1 Manager
        System.assertEquals(3,orderSharings.size());


        Map<Id,OrderShare> orderShareByUserMap = new Map<Id, OrderShare>();

        for (OrderShare orderShare : orderSharings){
            orderShareByUserMap.put(orderShare.UserOrGroupId, orderShare);
        }

        // Sharing for rep_at_implant__c
        OrderShare repForImplantShare = orderShareByUserMap.get(order.rep_at_implant__c);
        System.assertEquals(OrderSharing.SHARING_ACCESS_LEVEL, repForImplantShare.OrderAccessLevel);
        System.assertEquals(order.Id, repForImplantShare.OrderId);


        // Sharing for rep_for_credit__c
        OrderShare repForCreditShare = orderShareByUserMap.get(order.rep_for_credit__c);
        System.assertEquals(OrderSharing.SHARING_ACCESS_LEVEL, repForCreditShare.OrderAccessLevel);
        System.assertEquals(order.Id, repForCreditShare.OrderId);

    }

    @IsTest
    static void updateOrderWithNewTwoReps() {

        Id salesProfileId = Utility.getProfileId(Constants.PROFILE_NAME_SALES);

        List<User> users = new List<User>();
        User userFirstManager = TestDataFactory.createUser(salesProfileId);
        users.add(userFirstManager);
        User userFirstCreditManager = TestDataFactory.createUser(salesProfileId);
        users.add(userFirstCreditManager);
        User userManager = TestDataFactory.createUser(salesProfileId);
        users.add(userManager);
        User userSecondManager = TestDataFactory.createUser(salesProfileId);
        users.add(userSecondManager);
        User userFirstImplant = TestDataFactory.createUser(salesProfileId);
        userFirstImplant.manager_vi__c = userFirstManager.Id;
        users.add(userFirstImplant);
        User userFirstCredit = TestDataFactory.createUser(salesProfileId);
        userFirstCredit.manager_vi__c = userFirstCreditManager.Id;
        users.add(userFirstCredit);
        User userImplant = TestDataFactory.createUser(salesProfileId);
        users.add(userImplant);
        User userCredit = TestDataFactory.createUser(salesProfileId);
        users.add(userCredit);

        insert users;
		
        users = new List<User>();
        userImplant.manager_vi__c = userManager.id;
		users.add(userImplant);
		userCredit.manager_vi__c = userSecondManager.Id;
		users.add(userCredit);
        update users;
        
        System.debug('Users ' + users);

        // create two Users
        Order order = createOrder();
        order.rep_at_implant__c = userFirstImplant.Id;
        order.rep_for_credit__c = userFirstCredit.Id;
		order.pricebook__c = Constants.CVI_ORDER;
        insert order;

        Test.startTest();

        order.rep_at_implant__c = userImplant.Id;
        order.rep_for_credit__c = userCredit.Id;
        update order;

        Test.stopTest();

        // Eval Sharing
        List<OrderShare> orderSharings = [SELECT Id, UserOrGroupId, OrderAccessLevel, UserOrGroup.Name, OrderId FROM OrderShare
                                         	WHERE RowCause = 'Manual']; 

        System.debug('Evaluation of orderSharing ' + orderSharings);
        // there should be 4 Entries and 2 for reps and 2 for Managers 
        System.assertEquals(4,orderSharings.size());


        Map<Id,OrderShare> orderShareByUserMap = new Map<Id, OrderShare>();

        for (OrderShare orderShare : orderSharings){
            orderShareByUserMap.put(orderShare.UserOrGroupId, orderShare);
        }

        // Sharing for rep_at_implant__c
        OrderShare repForImplantShare = orderShareByUserMap.get(order.rep_at_implant__c);
        System.assertEquals(OrderSharing.SHARING_ACCESS_LEVEL, repForImplantShare.OrderAccessLevel);
        System.assertEquals(order.Id, repForImplantShare.OrderId);

        // Sharing for rep_for_credit__c
        OrderShare repForCreditShare = orderShareByUserMap.get(order.rep_for_credit__c);
        System.assertEquals(OrderSharing.SHARING_ACCESS_LEVEL, repForCreditShare.OrderAccessLevel);
        System.assertEquals(order.Id, repForCreditShare.OrderId);
        
        OrderShare repForCreditManagerShare = orderShareByUserMap.get(userSecondManager.id);
        System.assertEquals(OrderSharing.SHARING_ACCESS_LEVEL, repForCreditManagerShare.OrderAccessLevel);
        System.assertEquals(order.Id, repForCreditManagerShare.OrderId);
        
        OrderShare repForImplantManagerShare = orderShareByUserMap.get(userManager.Id);
        System.assertEquals(OrderSharing.SHARING_ACCESS_LEVEL, repForImplantManagerShare.OrderAccessLevel);
        System.assertEquals(order.Id, repForImplantManagerShare.OrderId);

    }

    @IsTest
    static void updateOrderSwitchTwoReps() {

        Id salesProfileId = Utility.getProfileId(Constants.PROFILE_NAME_SALES);

        List<User> users = new List<User>();
        User userImplantManager = TestDataFactory.createUser(salesProfileId);
        users.add(userImplantManager);
        User userCreditManager = TestDataFactory.createUser(salesProfileId);
        users.add(userCreditManager);       

        insert users;
        
        users = new list<User>();
        User userImplant = TestDataFactory.createUser(salesProfileId);
        userImplant.ManagerId = userImplantManager.Id;
        users.add(userImplant);
        User userCredit = TestDataFactory.createUser(salesProfileId);
        userCredit.ManagerId = userCreditManager.Id;
        users.add(userCredit);
        insert users;

        Order order = createOrder();
        order.rep_at_implant__c = userCredit.Id;
        order.rep_for_credit__c = userImplant.Id;
        insert order;

        Test.startTest();

        //do the switcheroo
        order.rep_at_implant__c = userImplant.Id;
        order.rep_for_credit__c = userCredit.Id;
        order.pricebook__c = Constants.CRM_ORDER;
        update order;

        Test.stopTest();
        // Eval Sharing
        List<OrderShare> orderSharings = [SELECT Id, UserOrGroupId, OrderAccessLevel, UserOrGroup.Name, OrderId FROM OrderShare
                                         WHERE RowCause = 'Manual']; // WHERE OrderId = : order.Id

        System.debug('Evaluation of orderSharing ' + orderSharings);
        // there should be 4 Entries 2 for reps and 2 for managers
        System.assertEquals(4,orderSharings.size());


        Map<Id,OrderShare> orderShareByUserMap = new Map<Id, OrderShare>();

        for (OrderShare orderShare : orderSharings){
            orderShareByUserMap.put(orderShare.UserOrGroupId, orderShare);
        }

        // Sharing for rep_at_implant__c
        OrderShare repForImplantShare = orderShareByUserMap.get(order.rep_at_implant__c);
        System.assertEquals(OrderSharing.SHARING_ACCESS_LEVEL, repForImplantShare.OrderAccessLevel);
        System.assertEquals(order.Id, repForImplantShare.OrderId);


        // Sharing for rep_for_credit__c
        OrderShare repForCreditShare = orderShareByUserMap.get(order.rep_for_credit__c);
        System.assertEquals(OrderSharing.SHARING_ACCESS_LEVEL, repForCreditShare.OrderAccessLevel);
        System.assertEquals(order.Id, repForCreditShare.OrderId);
        
        // Sharing for rep_for_credit__c
        OrderShare repForCreditManagerShare = orderShareByUserMap.get(userImplantManager.Id);
        System.assertEquals(OrderSharing.SHARING_ACCESS_LEVEL, repForCreditManagerShare.OrderAccessLevel);
        System.assertEquals(order.Id, repForCreditManagerShare.OrderId);
        
        // Sharing for rep_for_credit__c
        OrderShare repForImplantManagerShare = orderShareByUserMap.get(userCreditManager.Id);
        System.assertEquals(OrderSharing.SHARING_ACCESS_LEVEL, repForImplantManagerShare.OrderAccessLevel);
        System.assertEquals(order.Id, repForImplantManagerShare.OrderId);

    }

    /**
     * Owner change would brake our logic. Because after owner is changed every manual sharing is gone... :-(
     * So we have to be sure if logic. Adds the Sharing after owner change.
     */
    @IsTest
    static void updateOrderOwnerChanges() {

        Id salesProfileId = Utility.getProfileId(Constants.PROFILE_NAME_SALES);

        List<User> users = new List<User>();
        
        User userImplantManager = TestDataFactory.createUser(salesProfileId);
        users.add(userImplantManager);
        User userCreditManager = TestDataFactory.createUser(salesProfileId);
        users.add(userCreditManager);       

        insert users;
        
        users = new list<User>();        
        User userImplant = TestDataFactory.createUser(salesProfileId);
        users.add(userImplant);
        User userCredit = TestDataFactory.createUser(salesProfileId);
        users.add(userCredit);
        User newOwner = TestDataFactory.createUser(salesProfileId);
        users.add(newOwner);
        insert users;

        // create two Users
        Order order = createOrder();
        order.rep_at_implant__c = userImplant.Id;
        order.rep_for_credit__c = userCredit.Id;
        order.pricebook__c = Constants.CRM_ORDER;
        insert order;

        Test.startTest();

        order.OwnerId = newOwner.Id;
        
        update order;

        Test.stopTest();

        // Eval Sharing
        List<OrderShare> orderSharings = [SELECT Id, UserOrGroupId, OrderAccessLevel, UserOrGroup.Name, OrderId FROM OrderShare]; // WHERE OrderId = : order.Id

        System.debug('Evaluation of orderSharing ' + orderSharings);
        // there should be 3 Entries 1 for owner and 2 for reps
        System.assertEquals(3,orderSharings.size());

        Map<Id,OrderShare> orderShareByUserMap = new Map<Id, OrderShare>();
        for (OrderShare orderShare : orderSharings){
            orderShareByUserMap.put(orderShare.UserOrGroupId, orderShare);
        }

        // Sharing for rep_at_implant__c
        OrderShare repForImplantShare = orderShareByUserMap.get(order.rep_at_implant__c);
        System.assertEquals(OrderSharing.SHARING_ACCESS_LEVEL, repForImplantShare.OrderAccessLevel);
        System.assertEquals(order.Id, repForImplantShare.OrderId);


        // Sharing for rep_for_credit__c
        OrderShare repForCreditShare = orderShareByUserMap.get(order.rep_for_credit__c);
        System.assertEquals(OrderSharing.SHARING_ACCESS_LEVEL, repForCreditShare.OrderAccessLevel);
        System.assertEquals(order.Id, repForCreditShare.OrderId);

        // Sharing for Owner
        OrderShare repForOwnerShare = orderShareByUserMap.get(order.OwnerId);
        System.assertEquals(order.Id, repForOwnerShare.OrderId);

    }
}