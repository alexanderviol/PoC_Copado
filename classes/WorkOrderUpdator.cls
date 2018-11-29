/*
 * This class contains the methods used to update workorder record.
 * @Revision History: 
 *
 */
public class WorkOrderUpdator {  
   
   /*
    * This method updates the workorder record
    * @param    wo    Instance of workorder object
    * @param    woRecId    Workorder record Id    
    */
    @AuraEnabled 
    public static void updateWorkOrderredords(WorkOrder wo, String woRecId) {
        WorkOrder workodr = [SELECT id, rep_for_credit__c, rep_at_implant__c, no_rep_present_at_implant__c FROM WorkOrder WHERE Id =: woRecId];
        workodr.rep_for_credit__c = wo.rep_for_credit__c;
        workodr.rep_at_implant__c= wo.rep_at_implant__c;
        workodr.no_rep_present_at_implant__c = wo.no_rep_present_at_implant__c;
        try {
            update workodr;
        } catch(Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
}