/**
 * Handler class for the workOrder Trigger
 * 
 * @author              f.heer
 * @created             YYYY-MM-DD               
 * @modifiedBy          emma/Harald Proksch
 * @modified            2018-08-23
 * @systemLayer         Handler  
 *  
*/
public class WorkOrderHandler {
    public static final String TRANSMISSION_TRIGGER_STATUS = Constants.PICKLIST_STATUS_VALUE_WORK_ORDER_TRANSMITTED;
    @testVisible private static final String CANCELED = Constants.PICKLIST_STATUS_VALUE_WORK_ORDER_CANCELED;
    
    
    public static void checkAndPerformTransmissionToOrder(Map<Id, WorkOrder> oldMap, Map<Id, WorkOrder> newMap) {
        List<WorkOrder> woToCheck = new List<WorkOrder>();
        for(WorkOrder wo: oldMap.values() ) {
            if(wo.status != TRANSMISSION_TRIGGER_STATUS) {
                woToCheck.add(wo);
            }
        }
        List<WorkOrder> wosForTransmission = new List<WorkOrder> ();
        List<Id> wosForTransmissionIds = new List<Id>();
        for(WorkOrder wo : woToCheck) {
            WorkOrder newWo = newMap.get(wo.Id);
            if(newWo != null && newWo.Status == TRANSMISSION_TRIGGER_STATUS) {
                If(newWo.order__c != null) { 
                    newWo.addError('This WorkOrder has already been transmitted to Order.'); 
                }
                else {
                    wosForTransmission.add(newWo);
                    wosForTransmissionIds.add(newWo.Id);
                }
            }
        }
        if(wosForTransmission.size() > 0) {
            List<WorkOrderLineItem> wolis = [SELECT Id, Status FROM WorkOrderLineItem WHERE WorkOrderId IN :wosForTransmissionIds];
            if(wolis.size() > 0) {
                for(WorkOrderLineItem woli : wolis) {
                    woli.Status = TRANSMISSION_TRIGGER_STATUS;
                }
                update wolis;
            }
            WorkOrderConversion.convertToOrder(wosForTransmission);
        }
    }
   /*
    * updates the Following Physician Field on a Patient based on the Following Physician Field value on a Implant Procedure
    * 21.08.2018
    *
    * @param     newMap  input map of all inserted and updated work orders
    * @return    void    none
    * @author    Harald Proksch
    */ 
    public static void updatePatientWithFollowingPhysician(Map<Id, WorkOrder> newMap){            
        Map<Id, Id> woPatient = new Map<Id, Id>();
        List<Contact> updPatients = new List<Contact>();
                
        for(WorkOrder objWorkOrder : newMap.values()){
            system.debug('impacted work orders' + newMap.values());
            woPatient.put(objWorkOrder.patient__c, objWorkOrder.following_physician__c);
        }

        for (Contact currContact : [Select Id,following_physician__c from Contact where id in : woPatient.keySet()]) {
            system.debug('impacted contacts' + currContact.id);
            if (currContact.following_physician__c != woPatient.get(currContact.Id)) {
                currContact.following_physician__c = woPatient.get(currContact.Id);
                updPatients.add(currContact);
            }
        }    
        if (updPatients.size() > 0) {
            if (!Schema.sObjectType.Contact.fields.following_physician__c.isUpdateable()){
                addError('Insufficient access to update status');
            } else {
                update updPatients; 
            }
        }
    }
    
    /**
     * 
     * Method to check and cancel the Work order
     *
     * @param     newWorkOrderList    List<WorkOrder>
     * @param     oldWorkOrderList    List<WorkOrder>
     * @return    void
     * @author    emma
     * @created   2018-06-25
     * @modified  2018-08-22
     *
    */
    public static void checkAndPerformWorkOrderCancellation (Map<Id,WorkOrder> newWorkOrderMap, Map<Id,WorkOrder> oldWorkOrderMap){
        Map<Id, List<WorkOrderLineItem>> mapWorkOrderLineItem = new Map <Id, List<WorkOrderLineItem>>();
        Map<Id, List<ProductConsumed>> mapProductConsumed = new Map <Id, List<ProductConsumed>>();
        Set<Id> processedWorkOrdersId = new Set<Id>();

        list<WorkOrderLineItem> lstWorkOrderLineItem = new list<WorkOrderLineItem>();
        list<ProductConsumed> lstProductConsumed = new list<ProductConsumed>();
         
        for(WorkOrder objWorkOrder : newWorkOrderMap.values()){
            if (objWorkOrder.Status == CANCELED){
                if (objWorkOrder.Id != null){
                    processedWorkOrdersId.add(objWorkOrder.Id);
                }
            }
        }
        if (!processedWorkOrdersId.isEmpty()){
            // get the woli map and PC map
            mapWorkOrderLineItem = getWorkOrderLineItemFromWorkOrder(processedWorkOrdersId);
            mapProductConsumed = getProductConsumedFromWorkOrder(processedWorkOrdersId);
        }
        for (WorkOrder wo : newWorkOrderMap.values()){
            
             /*if (oldWorkOrderMap.get(wo.Id).Status == TRANSMISSION_TRIGGER_STATUS && wo.status == CANCELED ){
                addError(System.Label.WORKORDER_TRASMITTED_AND_CANNOT_BE_CANCELED);    
            }else if (wo.Status == CANCELED && oldWorkOrderMap.get(wo.Id).Status != TRANSMISSION_TRIGGER_STATUS){*/ 
            
            //restricting cancellation from workOrder line Item is handled by a custom validation rule on the workOrder object
            // And the validation has been removed because we want to cancel the workOrder when we cancel an order even if it is transmitted.
                if (wo.Status == CANCELED){
                //list of workOrderLine Item
                lstWorkOrderLineItem = getWorkOrderLineItemToCancel(mapWorkOrderLineItem !=null &&
                                             wo.id != null &&
                                             mapWorkOrderLineItem.containsKey(wo.id) ? mapWorkOrderLineItem.get(wo.id) : null);
                //List of Product Consumed
                 lstProductConsumed = getProductConsumedlistToCancel(mapProductConsumed !=null &&
                                               wo.id != null &&
                                               mapProductConsumed.containsKey(wo.id) ? mapProductConsumed.get(wo.id) : null);
            }
        }
        if (lstWorkOrderLineItem.size() > 0){
        	if (!Schema.sObjectType.WorkOrderLineItem.fields.Status.isUpdateable()){
            	 addError(System.Label.WORKORDER_INSUFFICIENT_ACCESS);
        	}else{
            	update lstWorkOrderLineItem;
        	}
        }
        if (lstProductConsumed.size() > 0){
            if (!Schema.sObjectType.ProductConsumed.isDeletable()){
            	addError(System.Label.PRODUCT_CONSUMED_INSUFFICIENT_ACCESS);    
            } else {
                Delete lstProductConsumed;
            }     
        }
    }
   /*
    * the linkage to contract is canceled from OnBeforeupdate
    * 
    */ 
    public static void OnBeforeUpdate(Map<Id,WorkOrder> newWorkOrderMap, Map<Id,WorkOrder> oldWorkOrderMap){
        updateWorkOrderContacts(newWorkOrderMap,oldWorkOrderMap);
    }
    /**
     * Helper method to Delete related product consumed
     *
     * @param     productConsumedLst    List<ProductConsumed>
     * @return    list<ProductConsumed>
    */
    private static list<ProductConsumed> getProductConsumedlistToCancel(List<ProductConsumed> productConsumedLst){
        list<ProductConsumed> lstProductsConsumed = new list<ProductConsumed>();
        if (productConsumedLst !=null){
            for(ProductConsumed pc : productConsumedLst){
                lstProductsConsumed.add(pc);    
            }
        }
        return lstProductsConsumed; 
    }
    
    /** 
     * Helper method to Cancel related workOrder Line Item
     *
     * @param     workOrderLineItemLst    List<WorkOrderLineItem>
     * @return    list<WorkOrderLineItem>
    */
    private static list<WorkOrderLineItem> getWorkOrderLineItemToCancel(List<WorkOrderLineItem> workOrderLineItemLst){
        list<WorkOrderLineItem> lstWorkOrderLineItem = new list<WorkOrderLineItem>();
        if (workOrderLineItemLst !=null){
            for(WorkOrderLineItem woli : workOrderLineItemLst){
                woli.Status = Constants.PICKLIST_STATUS_VALUE_WORK_ORDER_LINE_ITEM_CANCELED;
                lstWorkOrderLineItem.add(woli);               
            }   
        }
        return lstWorkOrderLineItem;         
    }
  /** 
	* Helper method to cancel linkage between work order and contact
    *
    * @param     Map<Id,WorkOrder> newWorkOrderMap
    * @param     Map<Id,WorkOrder> oldWorkOrderMap
    * @return    void
    */
    private static void updateWorkOrderContacts (Map<Id,WorkOrder> newWorkOrderMap, Map<Id,WorkOrder> oldWorkOrderMap){
        if (!newWorkOrderMap.isEmpty()){ 
            for (WorkOrder wo : newWorkOrderMap.values()){
                if (wo.Status == CANCELED && oldWorkOrderMap.get(wo.Id).Status != TRANSMISSION_TRIGGER_STATUS){
                    wo.patient__c = null;
                    wo.implanting_physician__c = null;
                    wo.following_physician__c = null;
                    wo.referring_physician__c = null;   
                }  
            }
        } 
    }
    /**
     * Selector Method get all workorder line Item from workorder
     * 
     * @param     setWorkOrderIds    Set<Id>
     * @return    Map<Id, List<WorkOrderLineItem>>
	 */
    private static Map<Id, List<WorkOrderLineItem>> getWorkOrderLineItemFromWorkOrder(Set<Id> setWorkOrderIds){
        System.debug('WORK ORDER iDS set are '+setWorkOrderIds);
        Map<Id,List<WorkOrderLineItem>> mapWorkOrderLineItems = new Map<Id, List<WorkOrderLineItem>>();
        for (WorkOrderLineItem objWorkOrderlineItem: [ SELECT Id,
                                                      		  WorkOrderId
                                                      FROM  WorkOrderLineItem
                                                      WHERE WorkOrderId IN : setWorkOrderIds])
        {
            if(mapWorkOrderLineItems.isEmpty() || !mapWorkOrderLineItems.containsKey(objWorkOrderlineItem.WorkOrderId)){
                mapWorkOrderLineItems.put(objWorkOrderlineItem.WorkOrderId, new List <WorkOrderLineItem>{objWorkOrderlineItem});
            } else {
                mapWorkOrderLineItems.get(objWorkOrderlineItem.WorkOrderId).add(objWorkOrderlineItem); 
            }
            
        }
        System.debug('work order lineItem map is  ' + mapWorkOrderLineItems);
        return mapWorkOrderLineItems;
    }
    
    /**
     * Selector Method to get all product consumed from workorder
     * 
     * @param     setWorkOrderIds    Set<Id>
     * @return    Map<Id, List<ProductConsumed>>
	 */
    private static Map<Id, List<ProductConsumed>> getProductConsumedFromWorkOrder(Set<Id> setWorkOrderIds){
    	Map<Id,List<ProductConsumed>> mapProductConsumed = new Map<Id, List<ProductConsumed>>();
        for(ProductConsumed objProdConsumed : [SELECT Id,
                                                      WorkOrderId
                                               FROM  ProductConsumed 
                                               WHERE WorkOrderId IN : setWorkOrderIds])
        {
            if(mapProductConsumed.isEmpty() || !mapProductConsumed.containsKey(objProdConsumed.WorkOrderId)){
                mapProductConsumed.put(objProdConsumed.WorkOrderId, new List <ProductConsumed>{objProdConsumed});
            } else {
                mapProductConsumed.get(objProdConsumed.WorkOrderId).add(objProdConsumed); 
            }  
        }
        return mapProductConsumed;
    }
    /**
     * Method to create custom error
     * 
     * @param     errorMsg    String
     * @return    void
	 */
    public static Void addError(String errorMsg){
        Trigger.new[0].addError(errorMsg);
    }
}