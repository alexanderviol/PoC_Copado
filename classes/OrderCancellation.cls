/** 
 * Check and perform the order cancellation
 * 
 * @author			emma 
 * @created			2018-10-09
 *  
*/
public class OrderCancellation {
    
    public static final String CANCELED = Constants.PICKLIST_VALUE_ORDER_STATUS_CANCELED;
    public static final String SAP_ERROR_REVIEW = Constants.PICKLIST_VALUE_ORDER_STATUS_SAP_ERROR;
    public static final String PROCESSED_TO_SAP = Constants.PICKLIST_VALUE_ORDER_STATUS_PROCESSED_SAP;
    public static final String INVOICED = Constants.PICKLIST_VALUE_ORDER_STATUS_INVOICED;
    public static final String SHIPPED = Constants.PICKLIST_VALUE_STATUS_SHIPPED;
    
    public static final String WORK_ORDER_CANCELED = Constants.PICKLIST_STATUS_VALUE_WORK_ORDER_CANCELED;
    
    public static void onBeforeUpdateOrderCancellation(Map<Id, Order> mapNewOrder, List<Order> newOrderList, Map<Id, Order> mapOldOrder){
        Boolean permitted = isCancelPermitted(mapNewOrder, mapOldOrder);
        checkCancelPermission(mapNewOrder, permitted);
        deactivateCreatedContact(mapNewOrder, permitted);
        updateAllAttachedContacts(newOrderList, permitted);
    }
    
    public static void onAfterUpdateOrderCancellation(Map<Id, Order> mapNewOrder, Map<Id, Order> mapOldOrder){
        Boolean permitted = isCancelPermitted(mapNewOrder, mapOldOrder);
		checkCancelPermission(mapNewOrder, permitted);
        cancelOrdersProcess(mapNewOrder, permitted);
	    cancelWorkOrderProcess(mapNewOrder, permitted); 
    }
    
    public static void checkCancelPermission (Map<Id, Order> mapNewOrder, Boolean permitted){      
        for (Order orders:mapNewOrder.Values()){
            if (orders.Status != CANCELED)
                return;
            if(permitted == false && orders.Status == CANCELED){
                // trow error everytime is not permitted to cancel the order
                orders.addError(Label.ERROR_TO_CANCEL_ORDER);
            }     
        }
    }
    /*
     * Check if the cancellation is permitted or not 
     * @param	mapNewOrder, contains all order records, which got modified during the update mapped by their Id
     * @param 	mapOldOrder, contains all order records with their values from before the update mapped by their Id
     * @return  permitted,   boolean value , if true then the cancellation of order is permitted based on the previous and the new status of the order
     * 
     */
     public static Boolean isCancelPermitted (Map<Id, Order> mapNewOrder, Map<Id, Order> mapOldOrder){
     Boolean permitted = false ;
         Set<String> oldOrderStatus = new Set<String>{SAP_ERROR_REVIEW, PROCESSED_TO_SAP, INVOICED, SHIPPED};
     for(Order ordObj : mapNewOrder.values()){   
            if (ordObj.Status == CANCELED && oldOrderStatus.contains(mapOldOrder.get(ordObj.Id).Status)){
                permitted = false;        
            }else if (ordObj.Status == CANCELED && !oldOrderStatus.contains(mapOldOrder.get(ordObj.Id).Status)){
            	permitted = true;
            }
         system.debug('Is it permitted to cancel the order ? ->  '+ permitted+ 'status is '+ordObj.Status);
        }

     return permitted;
    }
    /*
     * get the set of order Ids that they will be proccessed during the cancellation
     * @param	mapNewOrder, contains all order records, which got modified during the update mapped by their Id
     * @return  orderIdToCancel,  Set<Id>
     */ 
    public static Set<Id> getOrderIdToCancel(Map<Id, Order> mapNewOrder){
        
     	Set<Id> orderIdToCancel = new Set<Id>();
        for(Order objOrder : mapNewOrder.values()){
        if (objOrder.Status == CANCELED && objOrder.RecordTypeId != null){
                if (objOrder.Id != null){
                    orderIdToCancel.add(objOrder.Id);
                }
            }
        }
        return orderIdToCancel;
    }
    /*
     * If a new patient or physician record is created it should be removed or made inactive
     * we compare the date of the creation of the contact and the date of creation of the implant procedure
     * if it is the same , the status of the contact will be set to inactive
     * 
     * JAMA Global ID:908062
     * 
     * @param mapNewOrder, contains all order records, which got modified during the update mapped by their Id
     * @param permitted, boolean value , if true then the cancellation of order is permitted based on the previous and the new status of the order
     * 
     */ 
    public static void deactivateCreatedContact(Map<Id, Order> mapNewOrder, boolean permitted){
        if (permitted == true){
            Date woCreatedDate ;

            Set<Id> orderIdToCancel = new Set<Id>();
            orderIdToCancel = getOrderIdToCancel(mapNewOrder);

            Set<Id> setContactIds = new Set<Id>();
            Map<Id, Contact> mycontactsDetails = new Map<Id,Contact>();

            Map<Id, WorkOrder> workOrderMap = new Map<Id, WorkOrder>();
            workOrderMap = getImplantProcedureByOrderIds(orderIdToCancel);

            List<Contact> mycontacts = new List<Contact>();

            for (WorkOrder wo:workOrderMap.values()){
                woCreatedDate = date.newinstance(wo.CreatedDate.year(), wo.CreatedDate.month(), wo.CreatedDate.day());
            }

            for (Order orders :mapNewOrder.values()){
                Set<Id> contacts = new set <Id>{orders.patient__c,orders.following_physican__c, orders.implanting_physician__c,orders.referring_physician__c };
                    setContactIds.addAll(contacts);
            }
            if (!setContactIds.isEmpty()){
                mycontactsDetails = OrderHelper.getContactMap(setContactIds);
            }

            for(Contact contacts:mycontactsDetails.values()){
                Date ctCreatedDate = date.newinstance(contacts.CreatedDate.year(), contacts.CreatedDate.month(), contacts.CreatedDate.day());
                if (ctCreatedDate == woCreatedDate){
                    contacts.Status__c = Constants.PICKLIST_VALUE_CONTACT_STATUS_INACTIVE;
                    mycontacts.add(contacts);    
                }
            }    

            if (mycontacts!=null){
                update mycontacts;
            }
        }
    }
     /*
     * Cancel all linkage between Order and Contact	 
     * @param	List<Order>		new order list
     * @param   boolean         permitted
	 * @author	emma
     */
    public static void updateAllAttachedContacts(List<Order> newOrderList, boolean permitted){
        if (!newOrderList.isEmpty()){
            if (permitted == true){
            	for (Order orders : newOrderList){
                 	orders.patient__c = null; 
                	orders.implanting_physician__c = null;
                	orders.referring_physician__c = null;
                	orders.following_physican__c = null;
            	}    
            } 
        }
    }
    /*
     * In case the user Cancel an Order, the related workOrder need to be canceled as well.
     * if cancel order permitted then cancel work order will proceed
     * @param mapNewOrder, contains all order records, which got modified during the update mapped by their Id
     * @param permitted, boolean value , if true then the cancellation of order is permitted based on the previous and the new status of the order
     * @return void
     */ 
    public static void cancelWorkOrderProcess (Map<Id, Order> mapNewOrder, boolean permitted) {
        if (permitted == true){
            Set<Id> orderIdToCancel = new Set<Id>();
            List<WorkOrder> woToCancel = new List<WorkOrder>();
            Map<Id, WorkOrder> workOrderMap = new Map<Id, WorkOrder>();
            
            orderIdToCancel = getOrderIdToCancel(mapNewOrder);
            if(!orderIdToCancel.isEmpty()) {
                workOrderMap  = getImplantProcedureByOrderIds(orderIdToCancel);
            }
            for(WorkOrder wo:workOrderMap.values()){
                if(wo.Status != null){
                    wo.Status = WORK_ORDER_CANCELED;
                    woToCancel.add(wo);
                }    
            }
            if (woToCancel!=null){
                update woToCancel;   
            } 
        }
    }
    /**
     * Based on the Order status, the cancellation is done 
     * if the current order status is SAP_ERROR_REVIEW or PROCESSED_TO_SAP or INVOICED, the cancel of the order is not possible
     * In case the current status is anything else the status change to Cancel, the call of the cancel methode is done
     * 
     * SAFBIO-1308
     * 
     * @param	mapNewOrder, contains all order records, which got modified during the update mapped by their Id
     * @param   permitted,   boolean value , if true then the cancellation of order is permitted based on the previous and the new status of the order
     */
    public static void cancelOrdersProcess(Map<Id, Order> mapNewOrder, boolean permitted){
        if (permitted == true){
            Set<Id> orderIdToCancel = new Set<Id>();
            orderIdToCancel = getOrderIdToCancel(mapNewOrder);

            Set<Id> setAssetIds = new Set<Id>();
            Set<Id> setProductConsumedIds = new Set<Id>();
            Map<Id, List<OrderItem>> orderOrderItemMap = new Map<Id, List<OrderItem>>();

            if(!orderIdToCancel.isEmpty()) {
                orderOrderItemMap = OrderHelper.getOrderItemsFromOrder(orderIdToCancel);
            }

            for(Order ordObj : mapNewOrder.values()){

                setAssetIds =  getListAssetOrderItem(orderOrderItemMap != null && ordObj.Id != null &&
                                                     orderOrderItemMap.containsKey(ordObj.Id) ?
                                                     orderOrderItemMap.get(ordObj.Id) : null);

                setProductConsumedIds = getListProductConsumedOrderItem(orderOrderItemMap != null && ordObj.Id != null &&
                                                                        orderOrderItemMap.containsKey(ordObj.Id) ?
                                                                        orderOrderItemMap.get(ordObj.Id) : null);
            } 


            if (setAssetIds != null){
                List <Asset> assets = [select Id from Asset where Id IN: setAssetIds];
                delete assets;
            }
            if (setProductConsumedIds != null){
                List <ProductConsumed> productsConsumeds = [select Id from ProductConsumed where Id IN: setProductConsumedIds];
                delete productsConsumeds;
            }
        }
    }
   /*
    * Method to get set of Id asset attached to the the orderItem list of the processed order
    * @param  List<OrderItem> OrderItemList
    * @Return Set<Id> assetIds
    * 
    */ 
    private static Set<Id> getListAssetOrderItem(List<OrderItem> OrderItemList){
        Set<Id> assetIds = new Set<Id>();
        for (OrderItem orderItem:OrderItemList){
            if (orderItem.asset__c != null){
                assetIds.add(orderItem.asset__c);
            }
        }
        return assetIds;
    }
   /*
    * Method to get set of Id product consumed attached to the the orderItem list of the processed order
    * @param  List<OrderItem> OrderItemList
    * @Return Set<Id> productConsumedIds
    * 
    */ 
    private static Set<Id> getListProductConsumedOrderItem(List<OrderItem> OrderItemList){
        Set<Id> productConsumedIds = new Set<Id>();
        for(OrderItem orderItem:OrderItemList){
            if (orderItem.product_consumed__c !=null){
                productConsumedIds.add(orderItem.product_consumed__c);
            }
        }
        return productConsumedIds;
    }
   
    /**
     * Map of work order mapped by Ids
     * @param setOrderIds
     * @return Map <Id, WorkOrder> 
     */ 
    private static Map <Id, WorkOrder> getImplantProcedureByOrderIds(Set <Id> setOrderIds){
     	Map <Id, WorkOrder> mymap = new Map <Id, WorkOrder>();
        For(WorkOrder wo: [SELECT Id, CreatedDate, order__c, Status FROM WorkOrder WHERE order__c IN :setOrderIds] ){
            if (mymap.isEmpty() || !mymap.containsKey(wo.order__c)){
                mymap.put(wo.order__c, wo);
            }
        }
        return mymap;
    }

}