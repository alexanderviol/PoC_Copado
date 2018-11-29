/**
* 
* Handler for OrderTrigger
*
* Includes review process, order cancellation, validations
*
* @author			snpa
* @modifiedBy		ilu_pkas
* @created			2018-04-05
* @modified		    2018-10-16
* @systemLayer		Handler
*
*/
public class OrderHandler {

    /**
    * Constructor
    * 	Selects the id of the MDRF record type
    *
    * @author	ilu_pkas
    */
    public OrderHandler(){
    }

    /**
     * This method controls which functions gets called in case of a before insert trigger event
     *
     * @param newOrderList, contains all new created orders from the trigger
     * @author	ilu_pkas
     */
    public void onBeforeInsert(List<Order> newOrderList) {
        System.debug('BeforeInsert Order');
        OrderStatusPermission.checkOrderStatus(newOrderList, null);
        OrderValidation.reviewOrdersOnInsert(newOrderList);
        Utility.printLimits();
    }

    /**
     * This method controls which functions gets called in case of a after insert trigger event
     *
     * @param newOrderList contains all new created orders from the trigger
     * @author	arwe
     */
    public void onAfterInsert(List<Order> newOrderList){
        System.debug('AfterInsert Order');
        OrderSharing.createSharings(newOrderList,null);
        Utility.printLimits();
    }

    /**
     * This method controls which functions gets called in case of a before update trigger event
     *
     * @param 	newOrderList, contains all order records, which got modified during the update
     * @param 	lstOldOrders, contains all order records, which got modified during the update with their values from before the update
     * @param	mapNewOrder, contains all order records, which got modified during the update mapped by their Id
     * @param 	mapOldOrder, contains all order records with their values from before the update mapped by their Id
     * @author	ilu_pkas
     */
    public void onBeforeUpdate(List<Order> newOrderList, List<Order> lstOldOrders, Map<Id, Order> mapNewOrder, Map<Id, Order> mapOldOrder) {
        System.debug('BeforeUpdate Order');
        OrderStatusPermission.checkOrderStatus(mapNewOrder.values(), mapOldOrder);
        OrderStatusPermission.checkPermittedChanges(mapNewOrder.values(), mapOldOrder);
        OrderValidation.doCheck(newOrderList, mapOldOrder);
        updateReimportDate(mapNewOrder, mapOldOrder);
        OrderCancellation.onBeforeUpdateOrderCancellation(mapNewOrder,  newOrderList,  mapOldOrder);
        Utility.printLimits();
    }

    /**
     * This method controls which functions gets called in case of a after update trigger event
     *
     * @param 	newOrderList, contains all order records, which got modified during the update
     * @param	mapNewOrder, contains all order records, which got modified during the update mapped by their Id
     * @param 	mapOldOrder, contains all order records with their values from before the update mapped by their Id
     *
     * @author	ilu_pkas
     */
     public void onAfterUpdate(Map<Id, Order> mapNewOrder, Map<Id, Order> mapOldOrder){
         System.debug('AfterUpdate Order');
         OrderSharing.createSharings(mapNewOrder.values(),mapOldOrder);
         updatedToDonation(mapNewOrder.values(), mapOldOrder);
         updatedFromDonation(mapNewOrder.values(), mapOldOrder);
         OrderCancellation.onAfterUpdateOrderCancellation(mapNewOrder, mapOldOrder);
         Utility.printLimits();
    }

    /**
    * If a order was changed to a donation, it's price and the order items will be updated
    * 	- Changing UnitPrice to 0
    *   - Setting donation flags to true
    *
    * SAFBIO-1129
    *
    * @param	lstNewOrders, contains all order records, which should be checked for donation
    * @param	mapOldOrders, contains all order records with their values from before the update mapped by their Id
    * @author	ilu_pkas
    */
    public void updatedToDonation(List<Order> lstNewOrders, Map<Id, Order> mapOldOrders){
        Set<Id> setNewDonations = new Set<Id>();

        for(Order objOrder :lstNewOrders){
            if(objOrder.donation__c && !mapOldOrders.get(objOrder.Id).donation__c){
                setNewDonations.add(objOrder.Id);
            }
        }
        if(setNewDonations.isEmpty())
            return;

        List<OrderItem> lstDonationItems = [SELECT Id, UnitPrice FROM OrderItem WHERE OrderID IN :setNewDonations];
        for(OrderItem item :lstDonationItems){
            item.part_of_donation__c = true;
            item.UnitPrice = 0;
        }
        update lstDonationItems;
    }

    /**
    * If a order was changed from a donation, it's price and the order items will be updated
    * 	- Changine UnitPrice to the ListPrice
    *   - Setting donation flags to false
    *
    * SAFBIO-1129
    *
    * @param	lstNewOrders, contains all order records, which should be checked for a removed donation flag
    * @param	mapOldOrders, contains all order records with their values from before the update mapped by their Id
    * @author	ilu_pkas
    */
    public void updatedFromDonation(List<Order> lstNewOrders, Map<Id, Order> mapOldOrders){
        Set<Id> setOldDonations = new Set<Id>();

        for(Order objOrder :lstNewOrders){
            if(!objOrder.donation__c && mapOldOrders.get(objOrder.Id).donation__c){
                setOldDonations.add(objOrder.Id);
            }
        }
        if(setOldDonations.isEmpty())
            return;

        List<OrderItem> lstDonationItems = [SELECT Id, UnitPrice, ListPrice FROM OrderItem WHERE OrderID IN :setOldDonations];
        for(OrderItem item :lstDonationItems){
            item.UnitPrice = item.ListPrice;
            item.part_of_donation__c = false;
        }
        update lstDonationItems;
    }

    public static void addError(String errorMsg){
        if(Trigger.isExecuting)
            Trigger.new[0].addError(errorMsg);
    }

    /**
     * Saves the date, if the sap_inquiry_no__c gets changed
     * SAFBIO-1311
     *
     * @param	mapNewOrder, map of all modified orders
     * @param   mapOldOrder, map of all orders before they got modified
     * @author	Sumit
     */
    private void updateReimportDate(Map<Id, Order> mapNewOrder, Map<Id, Order> mapOldOrder){
        for(Order ord : mapNewOrder.values()){
            if(ord.sap_inquiry_no__c <> mapOldOrder.get(ord.id).sap_inquiry_no__c)
                ord.mdrf_reimport_timestamp__c = Datetime.now();
        }
    }
}