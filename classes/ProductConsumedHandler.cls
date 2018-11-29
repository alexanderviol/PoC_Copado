/* 
 *  Description  - Handler for ProductConsumedTrigger
 *  Created Date - 16.05.2018
 *  Created by   - ilu_pka
 */
public class ProductConsumedHandler {
    @testVisible private static final String NOTSUBMITTED = 'Not Submitted';

    /**
     * Method called on before delete of workOrderLineItems
     */
    public void onBeforeDelete(Map<id, ProductConsumed> oldItemsMap) {
        checkForSalesFcsDeletion(oldItemsMap);
    }
    
    private void checkForSalesFcsDeletion(Map<id, ProductConsumed> oldItemsMap){
        if(isUserCasOrCs())
            return;
/* SAFBIO-914 - need to clarify this        
        for(ProductConsumed item :oldItemsMap.values()){
            if(item.workorder.status != NOTSUBMITTED){
                item.addError('Deletion of this consumed product is not allowed, depending on the work order status');
            }
        }
*/
    }
    
    private boolean isUserCasOrCs(){
        Id idUser = UserInfo.getUserId();
        User usrCurrent = [SELECT Id, UserRole.DeveloperName FROM User WHERE ID = :idUser];
       
        Boolean bResult = usrCurrent.UserRole.DeveloperName == 'BINC_Customer_Solutions' || usrCurrent.UserRole.DeveloperName == Constants.USER_ROLE_NAME_SO;
        
        return bResult;
    }
    
    public static void onBeforeInsert(List<ProductConsumed> newPCs) {
        Map<Id, List<ProductConsumed>> pcsToConsider = new Map<Id, List<ProductConsumed>> ();
        Set<Id> serviceAppointmentParents = new Set<Id>();
        for (ProductConsumed pc : newPCs) {
            if(pc.implant_date__c == null) {
                Id saParentId;
                if (pc.WorkOrderLineItemId != null) {
                    saParentId = pc.WorkOrderLineItemId;
                }
                else if (pc.WorkOrderId != null) {
                    saParentId = pc.WorkOrderId;
                }
                serviceAppointmentParents.add(saParentId);
                List<ProductConsumed> tPcs = pcsToConsider.get(saParentId);
                if (tPcs == null) {
                    tPcs = new List<ProductConsumed> ();
                    pcsToConsider.put(saParentId, tPcs);
                }
                tPcs.add(pc);
            }
        }
        if(serviceAppointmentParents.size() > 0) {
            Date implantDate;
            for(ServiceAppointment sApp : [SELECT Id, SchedEndTime, ActualEndTime, ParentRecordId FROM ServiceAppointment WHERE ParentRecordId IN :serviceAppointmentParents]) {
                if(sApp.ActualEndTime != null) {
                    implantDate = sApp.ActualEndTime.dateGMT();
                }
                else {
                    implantDate = sApp.SchedEndTime.dateGMT();
                }
                List<ProductConsumed> tPcs = pcsToConsider.get(sApp.ParentRecordId);
                if(tPcs != null && tPcs.size() > 0) {
                    for (ProductConsumed pc : tPcs) {
                        pc.implant_date__c = implantDate;
                    }
                }
            }
        }
    }
}