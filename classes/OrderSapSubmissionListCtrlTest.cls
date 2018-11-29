/**
 * Testclass for the OrderSapSubmissionListCtrl
 * 
 * @author         ilu_pkas 
 * @modifiedBy     ilu_pkas
 * @created        2018-MM-DD
 * @modified       2018-08-30
 * @systemLayer    Test 
 *  
*/
@isTest
public class OrderSapSubmissionListCtrlTest {
	static Account objAcc;
    static Order objOrder;
    
    /**
     * Creating test data
     */    
    static void init(){
        objAcc = TestDataFactory.createAccount();
        insert objAcc;
        
        objOrder = TestDataFactory.createOrder(objAcc.Id);
        Id orderRtId = Utility.getRecordTypeId(Order.SObjectType, Constants.RECORD_TYPE_NAME_ORDER_MDRF);
        objOrder.Status = Constants.PICKLIST_VALUE_ORDER_STATUS_PENDING_SAP;
        objOrder.RecordTypeId = orderRtId;
        objOrder.submit_to_sap__c = true;
        objOrder.PoNumber = '1234';
        objOrder.submit_to_sap__c = false;
        insert objOrder;
    }
    
    /**
     * Testing, that the controller creation works without any errors
     */
    @isTest
    static void testController(){
        init();

        List<Order> lstOrder = new List<Order>();
        lstOrder.add(objOrder);
                
        Test.setCurrentPage(Page.OrderSapSubmissionList);
        ApexPages.StandardSetController stdSetCtrl = new ApexPages.StandardSetController(lstOrder);
        
        Test.startTest();
        	OrderSapSubmissionListCtrl ctrl = new OrderSapSubmissionListCtrl(stdSetCtrl);
        Test.stopTest();
        
        System.assertNotEquals(null, ctrl);
    } 
    
    /*
     * Testing the update method of the controller with one order with ops role
     */
    @isTest
    static void updateWithRoleSalesOp(){
        
        Id profileInsideSalesId = Utility.getProfileId(Constants.PROFILE_NAME_SYSTEM_MMS_INSIDE_SALES);
        Id opsUserRoleId = Utility.getUserRoleIdByName(Constants.User_ROLE_NAME_SO);
        User OpsUser = TestDataFactory.createUser(profileInsideSalesId, 'opsUsr');
        OpsUser.UserRoleId = opsUserRoleId;
        insert OpsUser;
        
        System.runAs (OpsUser) {
           init();
        }
        List<Order> lstOrder = [SELECT Id, submit_to_sap__c, Status FROM Order WHERE Id = :objOrder.Id];

        Test.setCurrentPage(Page.OrderSapSubmissionList);
        ApexPages.StandardSetController stdSetCtrl = new ApexPages.StandardSetController(lstOrder);
        stdSetCtrl.setSelected(lstOrder);
        OrderSapSubmissionListCtrl ctrl = new OrderSapSubmissionListCtrl(stdSetCtrl);
        
        System.runAs(OpsUser) {
            Test.startTest();
                 try {
                    ctrl.updateOrders();
                } catch (DmlException e) {
                    System.debug('Exception: ' + e.getMessage());
                    System.assert(e.getMessage().contains(Label.PERMISSION_DENIED));
                }
            Test.stopTest();
        } 
        
       objOrder = [SELECT Id, submit_to_sap__c FROM Order WHERE Id = :objOrder.Id];
       System.assertEquals(true, objOrder.submit_to_sap__c);
    }
    
    /*
     * Testing the update method of the controller with one order with Inside sales profile
     */
    @isTest
    static void updateWithProfileSystemInsideSales(){
        
        Id profileInsideSalesId = Utility.getProfileId(Constants.PROFILE_NAME_SYSTEM_MMS_INSIDE_SALES);
   
        User insideSalesUser = TestDataFactory.createUser(profileInsideSalesId, 'opsUsr');
        insert insideSalesUser;
        
        System.runAs (insideSalesUser) {
           init();
        }
        List<Order> lstOrder = [SELECT Id, submit_to_sap__c, Status FROM Order WHERE Id = :objOrder.Id];

        Test.setCurrentPage(Page.OrderSapSubmissionList);
        ApexPages.StandardSetController stdSetCtrl = new ApexPages.StandardSetController(lstOrder);
        stdSetCtrl.setSelected(lstOrder);
        OrderSapSubmissionListCtrl ctrl = new OrderSapSubmissionListCtrl(stdSetCtrl);
        
        System.runAs(insideSalesUser) {
            Test.startTest();
                 try {
                    ctrl.updateOrders();
                } catch (DmlException e) {
                    System.debug('Exception: ' + e.getMessage());
                    System.assert(e.getMessage().contains(Label.PERMISSION_DENIED));
                }
            Test.stopTest();
        } 
        
       objOrder = [SELECT Id, submit_to_sap__c FROM Order WHERE Id = :objOrder.Id];
       System.assertEquals(false, objOrder.submit_to_sap__c);
    }
    
    /**
     * Testing the update method of the controller with a customer solution
     */ 
    @isTest
    static void updateFailWithProfileInsideSalesAndCS(){
        Id profileInsideSalesId = Utility.getProfileId(Constants.PROFILE_NAME_SYSTEM_MMS_INSIDE_SALES);
        Id opsUserRoleId = Utility.getUserRoleIdByName(Constants.USER_ROLE_NAME_CS);
        User CSUser = TestDataFactory.createUser(profileInsideSalesId, 'CsUsr');
        CSUser.UserRoleId = opsUserRoleId;
        insert CSUser;
        
        System.runAs (CSUser) {
           init();
        }
        List<Order> lstOrder = [SELECT Id, submit_to_sap__c, Status FROM Order WHERE Id = :objOrder.Id];
                
        Test.setCurrentPage(Page.OrderSapSubmissionList);
        ApexPages.StandardSetController stdSetCtrl = new ApexPages.StandardSetController(lstOrder);
        stdSetCtrl.setSelected(lstOrder);
        OrderSapSubmissionListCtrl ctrl = new OrderSapSubmissionListCtrl(stdSetCtrl);
        
        System.runAs(CSUser) {
            Test.startTest();
                 try {
                    ctrl.updateOrders();
                } catch (DmlException e) {
                    System.debug('Exception: ' + e.getMessage());
                    System.assert(e.getMessage().contains(Label.PERMISSION_DENIED));
                }
            Test.stopTest();
        } 
        
        objOrder = [SELECT Id, submit_to_sap__c FROM Order WHERE Id = :objOrder.Id];
        System.assertEquals(false, objOrder.submit_to_sap__c);
    }
}