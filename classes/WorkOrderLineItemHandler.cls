/* 
 *  Description  - Handler for WorkOrderLineItemTrigger
 *  Created Date - 16.05.2018
 *  Created by   - ilu_pka
 */
public class WorkOrderLineItemHandler {
    @testVisible private static final String NOTSUBMITTED = 'Not Submitted';
    @testVisible private static final String CANCELED = 'Canceled';

    /**
     * Method called on before delete of workOrderLineItems
     */
    public void onBeforeDelete(Map<id, WorkOrderLineItem> oldItemsMap) {
        checkForSalesFcsDeletion(oldItemsMap);
    }
    
    private void checkForSalesFcsDeletion(Map<id, WorkOrderLineItem> oldItemsMap){
        if(isUserCasOrCs())
            return;
        
        for(WorkOrderLineItem item :oldItemsMap.values()){
            //if(item.workorder.status != NOTSUBMITTED){ -- changed since in all situation this value equals to NULL, So usually it is not allowed to delete the workorder
            if(item.workorder.status != NULL){
                item.addError('Deletion of this work order line item is not allowed, depending on the work order status');
            }
        }
    }
    
    private boolean isUserCasOrCs(){
        Id idUser = UserInfo.getUserId();
        User usrCurrent = [SELECT Id, UserRole.DeveloperName FROM User WHERE ID = :idUser];
       
        Boolean bResult = usrCurrent.UserRole.DeveloperName == 'BINC_Customer_Solutions' || usrCurrent.UserRole.DeveloperName == Constants.USER_ROLE_NAME_SO;
        
        return bResult;
    }
    
    
    /* SAFBIO-1332
     * Florian Heer <f.heer@conciscon.de>
     * 2018-06-18
     */ 
    public void onAfterUpdate(Map<Id, WorkOrderLineItem> oldMap, Map<Id, WorkOrderLineItem> newMap) {
        List<WorkOrderLineItem> newList = newMap.values();
        List<Id> workOrdersToBeUpdated = new List<Id>();
        for(WorkOrderLineItem woli : newList) {
            if(woli.Status == WorkOrderHandler.TRANSMISSION_TRIGGER_STATUS) {
                WorkOrderLineItem woliOld = oldMap.get(woli.Id);
                if(woliOld.Status != woli.Status) {
                    workOrdersToBeUpdated.add(woli.WorkOrderId);
                }
            }
        }
        if(workOrdersToBeUpdated.size() > 0) {
            List<WorkOrder> wos = [SELECT Id, Status FROM WorkOrder WHERE Id IN :workOrdersToBeUpdated];
            List<WorkOrder> wos2Update = new List<WorkOrder>();
            for(WorkOrder wo : wos) {
                if(wo.Status != WorkOrderHandler.TRANSMISSION_TRIGGER_STATUS) {
                	wo.Status = WorkOrderHandler.TRANSMISSION_TRIGGER_STATUS;
                    wos2Update.add(wo);
                }
            }
            if (wos2Update.size() > 0) {
            	update wos2Update;
            }
        }
    }
}