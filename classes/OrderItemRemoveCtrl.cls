/**
 *
 * This class provides the feature to change the owner of an order as a bulk operation from a list view
 * 
 * @author         ilu_pkas 
 * @modifiedBy     ilu_pkas
 * @created        2018-MM-DD
 * @modified       2018-11-19
 * @systemLayer    Service 
 *  
*/
public class OrderItemRemoveCtrl {
    private ApexPages.StandardController ctrl;
    private Id systemId;
    private OrderItem item;
    private Id orderId;
    private List<OrderItem> allOrderItems;
    private Boolean tryingToDeleteSystemLine;
	    
    /**
     * Constructor, gathers all necessary informations from the order
     * 	
     * @param	controller, the order StandardController reference
     */
    public OrderItemRemoveCtrl(ApexPages.StandardController controller){
        ctrl = controller;
        List<OrderItem> potentialItems = [SELECT Id, part_of_system_price__c, OrderId, product_consumed__c FROM OrderItem WHERE ID = :ctrl.getId() LIMIT 1];
        if (potentialItems.size () == 1) {
            item = potentialItems [0];
            orderId = item.OrderId;
            allOrderItems = [SELECT Id, part_of_system_price__c, OrderId, product_consumed__c, parentid__c FROM OrderItem WHERE OrderId = :orderId];
            for (OrderItem oi : allOrderItems) {
            
                if (oi.parentid__c != null) {
                    systemId = oi.parentid__c;
                }
            }
            tryingToDeleteSystemLine = systemId == item.Id;
            System.debug ('Deleting Id ' + item.Id + ' part of system: ' + item.part_of_system_price__c + ' Is it the system: ' + tryingToDeleteSystemLine);
        }
    }
    
    /**
     * Checks how order item can be removed, and deletes it.
     * This method is called the moment the page is loaded
     */
    public PageReference checkForDeletion () {
        if (tryingToDeleteSystemLine || item.part_of_system_price__c) {
            SystemPricingController_Helper.resetPossibleSystem(item.OrderId);
        }

        if (!tryingToDeleteSystemLine) {
        	removeOrderItem(item);
        }

		// Bringing the user back to the Order        
        Order objOrder = [SELECT Id FROM Order WHERE Id = :orderId LIMIT 1];
        ApexPages.StandardController sc = new ApexPages.StandardController(objOrder);
        PageReference pageOrder = sc.view();
        pageOrder.setRedirect(true);        
        return pageOrder;
    }
    
    
    /**
     * Removes the order item and all related records from the order, dosen't work for order items which are part of a system.
     * 
     * @param	item, the OrderItem which should be reseted and is not part of a system
     */
    public void removeOrderItem(OrderItem item){
        // free related Asset
        List<Asset> lstAsset = [SELECT Id, order__c, order_product__c FROM Asset WHERE order_product__c = :item.Id LIMIT 1];
        if(lstAsset.size() > 0){
            Asset objAsset = lstAsset.get(0);
                      
            // free Product Consumed
            List<ProductConsumed> lstProd = [SELECT Id FROM ProductConsumed WHERE asset__c = :objAsset.Id OR Id = :item.product_consumed__c];
            if(lstProd.size() > 0)
            	delete lstProd;
            delete objAsset;
        }
        
        delete item;
    }
}