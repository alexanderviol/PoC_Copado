/**
 *
 * This class provides the feature to mark order for submission to SAP as a bulk job from a list view
 * 
 * @author         ilu_pkas 
 * @modifiedBy     ilu_pkas
 * @created        2018-MM-DD
 * @modified       2018-08-29
 * @systemLayer    Service 
 *  
*/
public with sharing class OrderSapSubmissionListCtrl {
    public PageReference cancel {get; private set;}
    Order[] records;
    
    /**
     * Checks which order are selected in the list view to 
     * 
     * @param	controller, reference to the Order StandardSetController
     */
    public OrderSapSubmissionListCtrl(ApexPages.StandardSetController controller) {
        records = (Order[])controller.getSelected();
        cancel = controller.cancel();
    }
    
    /**
     * Updates the submit_to_sap value of all selected orders from the list view based on their status.
     * 
     * @return	the PageReference of the cancelation method from the StandardSetController.cancel method
     */
    public PageReference updateOrders() {
        Set<Id> setOrderIds = new Set<Id>();
        for(Order ord :records){
            setOrderIds.add(ord.Id);
        }
        
        List<Order> lstUpdatedOrders = [SELECT Id, Status, submit_to_sap__c FROM Order WHERE Id in :setOrderIds AND Status =: Constants.PICKLIST_VALUE_ORDER_STATUS_PENDING_SAP ];
        for(Order record: lstUpdatedOrders) {
        	record.submit_to_sap__c = true;
        }
       /*
        * Check if the user is allowed the submit an order to sap or not
        * SAFBIO-2468
        * Only mms function and system admin and Ops Users Role can submit ORDER to SAP
        */ 
        List <String> PROFILES_ALLOWED_FOR_ADD_PRODUCT = new List<String>{Constants.PROFILE_NAME_SYSTEM_ADMIN, Constants.PROFILE_Name_System_MMS_FUNC };
        List <String> ROLES_ALLOWED_FOR_ADD_PRODUCT = new List<String>{Constants.User_ROLE_NAME_SO};
        String profileName = Utility.getProfileNameById(UserInfo.getProfileId());
        String userRole = Utility.getUserRoleNameById(UserInfo.getUserRoleId());
        
        if (!PROFILES_ALLOWED_FOR_ADD_PRODUCT.contains(profileName) && !ROLES_ALLOWED_FOR_ADD_PRODUCT.contains(userRole)){
            ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.INFO, Label.PERMISSION_DENIED));
            return null;   
        } else {
            update lstUpdatedOrders;
        }
        return cancel.setRedirect(true);
    }
}