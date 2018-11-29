/**
 * Test class for User Trigger checks if Employee Contact is created and updated on create and update of User record
 *
 * @author         snpa
 * @created        2018-05-09
 * @systemLayer    Test Class
 *
 **/
@isTest
private class UserHandlerTest {

    /**
     * Test method checks if an Employee contact is created on create of User record
     * @author    snpa
     *
     **/
    private static testMethod void testContactCreation() {

        String uniqueUserName = 'standarduser' + DateTime.now().getTime() + '@testorg.com';
        Profile p = [SELECT id FROM Profile WHERE name='System Administrator'];

        User objUser = TestDataFactory.createUser(p.id);
        Test.startTest();
        	insert objUser;
		Test.stopTest();
        
        list<contact> contactList = getContact(new Set<Id>{objUser.id});
        assertOnContactField(contactList, objUser);
    }
	
    private static testMethod void testBulkContactCreation() {
		
        Profile p = [SELECT id FROM Profile WHERE name='System Administrator'];
        List<User> userList = new List<User>();
        for(Integer i=0 ; i<=200 ; i++) {
        	String uniqueUserName =  String.valueOf(DateTime.now().getTime()) ;
        	userList.add(TestDataFactory.createUser(p.id, 'abc' + String.valueOf(i)));
            
        }        
        Test.startTest();
        	insert userList;
		Test.stopTest();
        
        Set<Id> idSet = new Set<Id>();
        
        for (User objUser : userList) {
        	idSet.add(objUser.id);    
        }
        Map<Id, User> userMap = new Map<Id, User> ([Select firstname, middlename,lastname,email ,fax,phone,id,title
                                                    ,mobilephone ,department,street,city,state ,
                                                    postalcode,country,sap_company_code__c 
                                                    from User where Id IN :idSet]);
        list<contact> contactList = getContact(idSet);
        for(Contact objContact : contactList) {
            assertOnContactField(new List<Contact> {objContact}, userMap.get(objContact.related_user__c));    
        }
    }
    
    /**
     * Test method checks if an Employee contact is updated on update of User record
     * @author    snpa
     *
     **/
    private static testMethod void testContactUpdation() {
        String uniqueUserName = 'standarduser' + DateTime.now().getTime() + '@testorg.com';
        Profile p = [SELECT id FROM Profile WHERE name='System Administrator'];

        User objUser = TestDataFactory.createUser(p.id);
        insert objUser;
        
		Test.startTest();
        
        objUser.firstname = 'NAME';
        objUser.middlename= 'middlename';
        objUser.lastname = 'LASTNAME';
        objUser.email = 'test@test37340939.com';
        objUser.fax = '2334546';
        objUser.phone = '54645676';
        objUser.title = 'testtitle';
        objUser.mobilephone = '4543645767';
        objUser.department = 'testDepartment';
        objUser.street = 'test street';
        objUser.city = 'test city';
        objUser.state = 'Alaska';
        objUser.postalcode = '13234';
        objUser.country = 'United States';
        objUser.sap_company_code__c = '5500';
        update objUser;

        Test.stopTest();

        list<contact> contactList = getContact(new Set<Id>{objUser.id});
        assertOnContactField(contactList, objUser);
    }
    
    /**
     * Test method checks if Order sharinf is updated on Manager change
     * @author    snpa
     *
     **/
    private static testMethod void orderSharingTest() {
        Account account = TestDataFactory.createAccount();
        insert account;
	
        Id salesProfileId = Utility.getProfileId(Constants.PROFILE_NAME_SALES);        
        List<User> users = new List<User>();
        User userCrmCreditManager = TestDataFactory.createUser(salesProfileId);
        users.add(userCrmCreditManager);        
        User userCrmImplantImplant = TestDataFactory.createUser(salesProfileId);
        users.add(userCrmImplantImplant);
        User userViCreditManager = TestDataFactory.createUser(salesProfileId);
        users.add(userViCreditManager);        
        User userViImplantManager = TestDataFactory.createUser(salesProfileId);
        users.add(userViImplantManager);
        User userImplant = TestDataFactory.createUser(salesProfileId);
        users.add(userImplant);
        User userCredit = TestDataFactory.createUser(salesProfileId);        
        users.add(userCredit);
        insert users;     
        
        Id orderRtId =  Utility.getRecordTypeId (Order.SObjectType, Constants.RECORD_TYPE_NAME_ORDER_MDRF);
        
        Order order = TestDataFactory.createOrder(account.Id);
        order.RecordTypeId = orderRtId;
        order.rep_at_implant__c = userImplant.Id;
        order.rep_for_credit__c = userCredit.Id;
		order.pricebook__c = Constants.CRM_ORDER;
        insert order;
        
         Order viOrder = TestDataFactory.createOrder(account.Id);
         viOrder.RecordTypeId = orderRtId;
         viOrder.rep_at_implant__c = userImplant.Id;
         viOrder.rep_for_credit__c = userCredit.Id;
		 viOrder.pricebook__c = Constants.CVI_Order;
         insert viOrder;        
        
        system.assert(viOrder.pricebook__c == Constants.CVI_Order);
        Test.startTest();
            users = new List<User>();
            userImplant.managerId = userCrmImplantImplant.id;
            userImplant.manager_vi__c = userViImplantManager.id;           
            users.add(userImplant);
            userCredit.ManagerId = userCrmCreditManager.Id;
            userCredit.manager_vi__c = userViCreditManager.id;
            users.add(userCredit);
            update users;
        Test.stopTest();
        
        // Eval Sharing
        List<OrderShare> orderSharings = [SELECT Id, UserOrGroupId, OrderAccessLevel, UserOrGroup.Name, OrderId 
                                          	FROM OrderShare 
                                          WHERE RowCause = 'Manual' AND 
                                            OrderAccessLevel = :OrderSharing.SHARING_ACCESS_LEVEL]; // WHERE OrderId = : order.Id

        System.debug('Evaluation of orderSharing ' + orderSharings);
        // there should be  4 for reps and 4 Manager
        System.assertEquals(8,orderSharings.size());

        Map<string,OrderShare> orderShareByUserMap = new Map<string, OrderShare>();

        for (OrderShare orderShare : orderSharings){
            orderShareByUserMap.put(orderShare.UserOrGroupId +''+ orderShare.OrderId, orderShare);
        }

        // Sharing for rep_at_implant__c
        OrderShare repForImplantShare = orderShareByUserMap.get(order.rep_at_implant__c+''+order.Id);
        System.assertEquals(OrderSharing.SHARING_ACCESS_LEVEL, repForImplantShare.OrderAccessLevel);
        System.assertEquals(order.Id, repForImplantShare.OrderId);

        // Sharing for rep_for_credit__c
        OrderShare repForCreditShare = orderShareByUserMap.get(order.rep_for_credit__c+''+order.Id);
        System.assertEquals(OrderSharing.SHARING_ACCESS_LEVEL, repForCreditShare.OrderAccessLevel);
        System.assertEquals(order.Id, repForCreditShare.OrderId);
        
        // Sharing for rep_at_implant__c
        OrderShare crmRepForImplantManagerShare = orderShareByUserMap.get(userCrmImplantImplant.Id+''+order.Id);
        System.assertEquals(OrderSharing.SHARING_ACCESS_LEVEL, crmRepForImplantManagerShare.OrderAccessLevel);
        System.assertEquals(order.Id, crmRepForImplantManagerShare.OrderId);

        // Sharing for rep_for_credit__c
        OrderShare crmRepForCreditManagerShare = orderShareByUserMap.get(userCrmCreditManager.Id+''+order.Id);
        System.assertEquals(OrderSharing.SHARING_ACCESS_LEVEL, crmRepForCreditManagerShare.OrderAccessLevel);
        System.assertEquals(order.Id, crmRepForCreditManagerShare.OrderId);
        
        // Sharing for rep_at_implant__c
        OrderShare viRepForImplantShare = orderShareByUserMap.get(viOrder.rep_at_implant__c+''+viOrder.Id);
        System.assertEquals(OrderSharing.SHARING_ACCESS_LEVEL, viRepForImplantShare.OrderAccessLevel);
        System.assertEquals(viOrder.Id, viRepForImplantShare.OrderId);


        // Sharing for rep_for_credit__c
        OrderShare viRepForCreditShare = orderShareByUserMap.get(viOrder.rep_for_credit__c+''+viOrder.Id);
        System.assertEquals(OrderSharing.SHARING_ACCESS_LEVEL, viRepForCreditShare.OrderAccessLevel);
        System.assertEquals(viOrder.Id, viRepForCreditShare.OrderId);  
        
        // Sharing for rep_at_implant__c
        /**
         * NOTE - Commented since it is not possible to create VI Orders at the moment. To be changed with ne RT for VI 
         * Orders        
         */
        /*OrderShare viRepForImplantManagerShare = orderShareByUserMap.get(userViImplantManager.Id+''+viOrder.Id);       
        System.assertEquals(OrderSharing.SHARING_ACCESS_LEVEL, viRepForImplantManagerShare.OrderAccessLevel);
        System.assertEquals(viOrder.Id, viRepForImplantManagerShare.OrderId);

        // Sharing for rep_for_credit__c
        OrderShare viRepForCreditManagerShare = orderShareByUserMap.get(userViCreditManager.Id+''+viOrder.Id);
        System.assertEquals(OrderSharing.SHARING_ACCESS_LEVEL, viRepForCreditManagerShare.OrderAccessLevel);
        System.assertEquals(viOrder.Id, viRepForCreditManagerShare.OrderId);   */
    }
    /**
     * Retrieves Employee Contact based on related User
     *
     * @param     userId            Id of User
     * @return    List<Contact>     List of Contacts that are related to given User
     * @author    snpa
     *
     **/
    private static List<contact> getContact(Set<Id> userIdSet) {
        return  [SELECT id,
                    firstname,
                    middlename,
                    lastname,
                    recordtypeid,
                    email,
                    fax,
                    phone,
                    title,
                    mobilephone,
                    department,
                    mailingstreet,
                    mailingcity,
                    mailingstate,
                    mailingpostalcode ,
                    mailingcountry,
                    related_user__c,
                    sap_company_code__c,
                    accountid,
                    account.sap_company_code__c,
                    account.recordType.developerName
                FROM contact
            WHERE related_user__c IN: userIdSet];
    }

    /**
     * Asserts if correct values are copied over on Employee records
     *
     * @param     contactList       List of Employees
     * @param     objUser           User instance that is created or updated
     * @return    void
     * @author    snpa
     * 
     **/
    private static void assertOnContactField(List<Contact> contactList, User objUser) {

        system.assert(!contactList.isEmpty() && contactList.size() == 1 &&
                        contactList[0].firstname == objUser.firstname &&
                        contactList[0].middlename == objUser.middlename &&
                        contactList[0].lastname == objUser.lastname &&
                        contactList[0].email == objUser.email &&
                        contactList[0].fax == objUser.fax &&
                        contactList[0].phone == objUser.phone &&
                        contactList[0].related_user__c == objUser.id &&
                        contactList[0].recordTypeId == Utility.getRecordTypeId(UserHandler.CONTACT_OBJ, 
                                                                               Constants.RECORD_TYPE_NAME_CONTACT_EMPLOYEE) &&
                        contactList[0].title == objUser.title &&
                        contactList[0].mobilephone == objUser.mobilephone &&
                        contactList[0].department == objUser.department &&
                        contactList[0].mailingstreet == objUser.street &&
                        contactList[0].mailingcity == objUser.city &&
                        contactList[0].mailingstate == objUser.state &&
                        contactList[0].mailingpostalcode == objUser.postalcode &&
                        contactList[0].mailingcountry == objUser.country &&
                        contactList[0].account.sap_company_code__c == objUser.sap_company_code__c &&
                        contactList[0].account.recordType.developerName == Constants.RECORD_TYPE_NAME_ACCOUNT_MANUFACTURER);
    }
}