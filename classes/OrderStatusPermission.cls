/**
* @author:			arwe
*					T-Systems Multimedia Solutions GmbH
*					Riesaer Strasse 5,
*					01129 Dresden
*					www.t-systems-mms.com
*
* @description      Checks if change for Status is allowed
*                  
*
* @date             03.10.2018
* 
*/

public class OrderStatusPermission {

    private static List <String> PROFILES_ALLOWED_FOR_EVERYTHING = new List<String>{Constants.PROFILE_NAME_SYSTEM_ADMIN, Constants.PROFILE_Name_System_MMS_FUNC, Constants.PROFILE_NAME_HMSC};
    private static List <String> ROLES_CS_AND_SO = new List<String>{Constants.User_ROLE_NAME_CS, Constants.User_ROLE_NAME_SO};

    // TODO how about a custom Metadata?
    private static List <String> PERMITTED_FIELDS = new List<String>{'status','ponumber','date_cm_approved__c','submitted_date__c ','pricebook__c','pricebook2id','submit_to_sap__c'};
    private static List <String> STATUS_PERMISSION_FOR_SALES_FIELD_CHANGES = new List<String>{Constants.PICKLIST_VALUE_ORDER_STATUS_NOT_SUBMITTED};
    private static List <String> STATUS_PERMISSION_FOR_SALES_FIELD_CHANGES_CM_ORDER = new List<String>{Constants.PICKLIST_VALUE_ORDER_STATUS_NOT_SUBMITTED, Constants.PICKLIST_VALUE_ORDER_STATUS_SUBMITTED_PROCESSING};

    /**
     * Checks if user is permitted to change a field (for profile Sales) on MDRF
     *
     * This method is not pretty clever it is better to have the rules in custom metadata to do changes afterwards
     * I am so sorry! This is stupid but for now we have to do it like this.
     *
     * @param newOrderList list of Orders
     * @param mapOldOrder Map of old orders (before the update)
     */
    public static void checkPermittedChanges(List<Order> newOrderList, Map<Id, Order> mapOldOrder){
        // check Profile
        String profileName = Utility.getProfileNameById(UserInfo.getProfileId());

        // only for Sales Profile
        if (profileName != Constants.PROFILE_NAME_SALES) {
            return;
        }

        Set<String> fieldApiNames = Schema.SObjectType.Order.fields.getMap().keySet();

        Id mdrfRecordTypeId = Utility.getRecordTypeId(Order.SObjectType, Constants.RECORD_TYPE_NAME_ORDER_MDRF);
        Id cmRecordTypeId = Utility.getRecordTypeId(Order.SObjectType, Constants.RECORD_TYPE_NAME_ORDER_CARDIO_MESSENGER);

        // go over every order
        for (Order order : newOrderList){
            // If there is not adjustment possible Status != Not Submitted and RecordType is MDRF
            if(!STATUS_PERMISSION_FOR_SALES_FIELD_CHANGES.contains(order.Status) && order.RecordTypeId == mdrfRecordTypeId){
                // check every field
                for (String fieldName : fieldApiNames){
                    //check if field has changed and is not in permitted fields
                    if((order.get(fieldName) != mapOldOrder.get(order.Id).get(fieldName)) && ! PERMITTED_FIELDS.contains(fieldName.toLowerCase())){
                        // Field change is not permitted
                        order.addError(String.format(Label.ERR_FIELD_CHANGE_NOT_PERMITTED, new String[] {fieldName, order.Status}));
                    }
                }
            }else if(!STATUS_PERMISSION_FOR_SALES_FIELD_CHANGES_CM_ORDER.contains(order.Status) && order.RecordTypeId == cmRecordTypeId){
                //skip validation while creating CM Direct Handout Order. || SAFBIO-2315
                if(Utility.toSkipValidation(order.id))  
                    return;
				// check every field
                for (String fieldName : fieldApiNames){
                    //check if field has changed and is not in permitted fields
                    if((order.get(fieldName) != mapOldOrder.get(order.Id).get(fieldName)) && ! PERMITTED_FIELDS.contains(fieldName.toLowerCase())){
                        // Field change is not permitted
                        order.addError(String.format(Label.ERR_FIELD_CHANGE_NOT_PERMITTED, new String[] {fieldName, order.Status}));
                    }
                }
            }
        }

    }
    
    /*
     * Check if the PO number has been changed on the order
     * SAFBIO-2435
     */ 
    public static Map <Id, String> poChanged(List<Order> newOrderList, Map<Id, Order> mapOldOrder){
        List<Order> changedPoOrders = new List<Order>();
        Map <Id, String> mapOldPonumberByOrderId = new Map <Id, String>();
        for (Order order : newOrderList){
            if(order.PoNumber != mapOldOrder.get(order.Id).PoNumber && mapOldOrder.get(order.Id).PoNumber == null){
                mapOldPonumberByOrderId.put(order.Id, mapOldOrder.get(order.Id).PoNumber);
            }
        }
        return mapOldPonumberByOrderId;
	}

    /**
     * Checks if there is an change on Order Status and evaluates if the User has the permission to it
     * SAFBIO-2149, SAFBIO-914
     *
     * TODO think about refactoring this to a State machine
     * @param newOrderList list of Orders
     * @param mapOldOrder Map of old orders (before the update); null if insert Trigger
     */
    public static void checkOrderStatus(List<Order> newOrderList, Map<Id, Order> mapOldOrder){

        String profileName = Utility.getProfileNameById(UserInfo.getProfileId());

        if (PROFILES_ALLOWED_FOR_EVERYTHING.contains(profileName)) {
            // Func User and Admin can do anything
            return;
        }

        //only process orders with status changes
        List<Order> statusChangedOrders = OrderHelper.filterStatusChangeRecords(newOrderList, mapOldOrder);

        String userRole = Utility.getUserRoleNameById(UserInfo.getUserRoleId());

        List <String> allowedStatusChangesSales = new List<String>{Constants.PICKLIST_VALUE_ORDER_STATUS_NOT_SUBMITTED, Constants.PICKLIST_VALUE_ORDER_STATUS_SUBMITTED_PROCESSING, Constants.PICKLIST_VALUE_ORDER_STATUS_CANCELED};
        List <String> allowedStatusChangesCasAndCs = allowedStatusChangesSales.clone();
        allowedStatusChangesCasAndCs.add(Constants.PICKLIST_VALUE_ORDER_STATUS_PENDING_SAP);
        List <String> allowedChangesAfterSubmission = new List<String>{Constants.PICKLIST_VALUE_ORDER_STATUS_SUBMITTED_PROCESSING, Constants.PICKLIST_VALUE_ORDER_STATUS_CANCELED};
        
        // In Case PO number change after order beeing processed to SAP, Sales should be able to change the order to Pending SAP via the process builder
        List <String> allowedChangesPO_IsChangedAfterSubmission = allowedChangesAfterSubmission.clone();
        allowedChangesPO_IsChangedAfterSubmission.add(Constants.PICKLIST_VALUE_ORDER_STATUS_PENDING_SAP);
        
        Map <Id, String> mapoldPoNumber = new Map <Id, String>();
        if (mapOldOrder !=null){
            mapoldPoNumber = poChanged(newOrderList, mapOldOrder);
        }
        
        for (Order order : statusChangedOrders){
            if(Utility.toSkipValidation(order.id)){
                continue;
            }

            List<String> allowedStatusChanges = new List<String>();

            System.debug('USer Role Name: ' +userRole);

            String oldStatus = mapOldOrder.get(order.Id).Status;
            String oldPoNumber = mapoldPoNumber.get(order.Id);
            
            // Check if Role or Profile is permitted for change
            if(ROLES_CS_AND_SO.contains(userRole)){
                // check if state change from transition from "Not Submitted" to "Pending HMSC Registration"
                if(order.Status == Constants.PICKLIST_VALUE_ORDER_STATUS_PENDING_HMSC && oldStatus == Constants.PICKLIST_VALUE_ORDER_STATUS_NOT_SUBMITTED){
                    continue;
                }
                allowedStatusChanges = allowedStatusChangesCasAndCs;

            } else if (profileName == Constants.PROFILE_NAME_SALES ){
                // check if state change from transition from "Not Submitted" to "Pending HMSC Registration"
                if(order.Status == Constants.PICKLIST_VALUE_ORDER_STATUS_PENDING_HMSC && oldStatus == Constants.PICKLIST_VALUE_ORDER_STATUS_NOT_SUBMITTED){
                    continue;
                }
                allowedStatusChanges = allowedStatusChangesSales;

                // when the order already has been submitted for processing; or any other Status after 'Not Submitted' for Sales
                if(oldStatus != Constants.PICKLIST_VALUE_ORDER_STATUS_NOT_SUBMITTED){
                    allowedStatusChanges = allowedChangesAfterSubmission;
                    
                    //when the PO number has been changed and the Order status before the change is Processed to SAP. System should allow changing the status to Pending SAP for Sales.
                    if (oldStatus == Constants.PICKLIST_VALUE_ORDER_STATUS_PROCESSED_SAP && order.Status == Constants.PICKLIST_VALUE_ORDER_STATUS_PENDING_SAP &&
                        oldPoNumber == null && oldPoNumber != order.PoNumber){
                        allowedStatusChanges = allowedChangesPO_IsChangedAfterSubmission;                            
                    }
                }
            }

            // if it is not contained in allowed changes then setting Status is not permitted
            if(!allowedStatusChanges.contains(order.Status) ){
                order.addError(Label.ERR_ORDER_STATUS_CHANGE_NOT_ALLOWED);
            }

        }
    }

}