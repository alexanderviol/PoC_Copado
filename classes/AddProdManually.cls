/* Created by Florian Heer <f.heer@conciscon.de>
 * 
 * Runs without sharing, hoping to solve SAFBIO-2348 with that.
 */

public without sharing class AddProdManually {
    
    /** Performs a substring search on ProductItems
     * 
     * @param searchText the text to search for. This is treated as a substring.
     * @param orderId the Id of the order. Necessary to filter for available products according to the pricebook.
     * @return a List of all available Product Items, filtered by Pricebook-availability and search text
     */    
    @AuraEnabled
    public static List<ProductItem> searchForProductItems(String searchText, String orderID) {
        System.debug('AddProdManually: receive parameters searchText: ' + searchText + ' orderID: ' + orderID);
        Id relatedPricebook = [SELECT Account.crm_pricebook__c FROM Order WHERE Id = :orderId LIMIT 1].Account.crm_pricebook__c;
        List<PricebookEntry> pbes = [SELECT Product2Id FROM PricebookEntry WHERE Pricebook2Id = :relatedPricebook];
        List<Id> prodIds = new List<Id>();
        for(PricebookEntry pbe : pbes) prodIds.add(pbe.Product2Id);
        searchText = '%' + searchText + '%';
        System.debug('searchText: "' + searchText + '"');
        List<ProductItem> pis = [SELECT Id, Product2.Name, QuantityOnHand, SerialNumber, batch_no__c, Location.Name, 
                                 ubd_expired__c FROM ProductItem 
                                 WHERE 
                                 (
// Bill requested (SAFBIO-2040) to remove the search by name
//                                     Product2.Name LIKE :searchText OR
                                  Product2.EAN__c LIKE :searchText 
                                  OR barcode__c LIKE :searchText
                                  OR SerialNumber LIKE :searchText
                                 )
                                 AND QuantityOnHand > 0 AND Product2Id IN :prodIds LIMIT 50];
        return pis;
    }

    /** Performs the steps necessary to consume a product item and convert it to OrderItem and Asset
     * 
     * @param piId Id of a ProductItem to consume
     * @param amount how many to consume (should always be one in the current setup)
     * @param orderId the Order to attach the created OrderItem and Asset to. Patient is taken from the related WorkOrder.
     */    
    @AuraEnabled
    public static Asset consumeProduct (String piId, String amount, String orderId, String implantStatus) {
        return consumeProduct (piId, amount, orderId, false, implantStatus);
    }
    
    @AuraEnabled
    public static Asset consumeProduct (String piId, String amount, String orderId) {
        return consumeProduct (piId, amount, orderId, false, Constants.PICKLIST_STATUS_ORDER_ITEM_NOT_IMPLANTABLE_PRODUCT);
    }
    
    public static Asset consumeProduct (String piId, String amount, String orderId, Boolean replenish) {
        return consumeProduct (piId, amount, orderId, replenish, Constants.PICKLIST_STATUS_ORDER_ITEM_NOT_IMPLANTABLE_PRODUCT);
    }
    
    

    public static Asset consumeProduct(String piId, String amount, String orderId, Boolean replenish, String implantStatus) {
        System.debug('AAA apm AddProdManually.consumeProduct("' + piId + '","' + amount + '","' + orderId + '")');
        Integer quantity;
        String error = '';
        try {
            quantity = Integer.valueOf(amount.trim());
        }
        catch (TypeException ex) {
            error = String.format(Label.APM_quantity_not_number, new String [] {amount});
        }
        
        If(Schema.sObjectType.ProductConsumed.isCreateable() && error.length() == 0) {
            Id woliId, workOrderId, patientId;
        	List<WorkOrderLineItem> wolis = [SELECT Id, WorkOrderId, WorkOrder.patient__c FROM WorkOrderLineItem WHERE OrderId = :orderId];
            if(wolis.size() > 0) {
                woliId = wolis[0].Id;
                workOrderId = wolis[0].WorkOrderId;
                patientId = wolis[0].WorkOrder.patient__c;
            }
            else {
                List<WorkOrder> wos =  [SELECT Id, patient__c FROM WorkOrder WHERE order__c = :orderId];
                if(wos.size() > 0) {
                    workOrderId = wos[0].Id;
                    patientId = wos[0].patient__c;
                }
            }
			
            
            Date implantDate;
            for(ServiceAppointment sApp : [SELECT Id, SchedEndTime, ActualEndTime FROM ServiceAppointment WHERE ParentRecordId = :workOrderId]) {
                if(sApp.ActualEndTime != null) {
                    implantDate = sApp.ActualEndTime.dateGMT();
                    break;
                }
                else {
                    implantDate = sApp.SchedEndTime.dateGMT();
                }
            }
            if(implantDate == null) {
                implantDate = Date.today();
            }

            
            ProductItem pi = [SELECT Id, ubd_expired__c, product_type__c FROM ProductItem WHERE Id = :piId LIMIT 1];
            
            
			ProductConsumed pc = new ProductConsumed (ProductItemId = piId, QuantityConsumed = Decimal.valueOf(amount),
                                                     WorkOrderId = workOrderId, WorkOrderLineItemId = woliId, status__c = implantStatus,
                                                     expired_ubd_acknowledged__c = pi.ubd_expired__c,
                                                     patient__c = patientId, implant_date__c = implantDate
                                                     );
            if (pi.product_type__c == Constants.PICKLIST_VALUE_PRODUCT_TYPE_LEAD){
              	pc.Lead_Tip_Location__c = Constants.PICKLIST_VALUE_LEAD_TIP_LOCATION_UNKNOWN;  
            }
            insert pc;
            Asset ass = WorkOrderConversion.convertProduct(orderId, pc.Id, replenish);
        	return ass;        
        }
        else {
            error += Label.APM_ProductConsumed_not_creatable;
        }

        if(error.length() == 0) {
            // This holds true, as we employ an early return (return ass;)
        	error = Label.APM_generic_error;
        }
        AuraHandledException ex = new AuraHandledException(error);
        ex.setMessage(error);
        throw ex;
    }
    @AuraEnabled
    public static Boolean checkUserPermission(){
        Boolean allowed = false;
        
        List <String> PROFILES_ALLOWED_FOR_ADD_PRODUCT = new List<String>{Constants.PROFILE_NAME_SALES, Constants.PROFILE_NAME_SYSTEM_ADMIN, Constants.PROFILE_Name_System_MMS_FUNC};
        List <String> ROLES_ALLOWED_FOR_ADD_PRODUCT = new List<String>{Constants.User_ROLE_NAME_SO};
        String profileName = Utility.getProfileNameById(UserInfo.getProfileId());
        String userRole = Utility.getUserRoleNameById(UserInfo.getUserRoleId());
        
        if ((PROFILES_ALLOWED_FOR_ADD_PRODUCT.contains(profileName))|| ROLES_ALLOWED_FOR_ADD_PRODUCT.contains(userRole)){
          	allowed = true;  
        }
        return allowed;
    }
}