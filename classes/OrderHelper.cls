/* Created 2018-07-02
 * Florian Heer <f.heer@conciscon.de>
 * Helper class for an Order is used to assist in providing some functionality
 *
 */
public class OrderHelper {

    /**
     * This Method checks if there are Order Status changes
     *
     * @param newOrderList new List of orders
     * @param mapOldOrder old map of orders
     *
     * @return records where status has changed
     */
    public static List<Order> filterStatusChangeRecords(List<Order> newOrderList, Map<Id, Order> mapOldOrder){
        List <Order> statusChangedOrders = new List<Order>();

        for (Order order : newOrderList){
            if(mapOldOrder != null){
                if( order.Status == mapOldOrder.get(order.id).Status){
                    continue;
                }
                statusChangedOrders.add(order);
            }
        }
        return statusChangedOrders;
    }

    /**
 * Selects contacts details (patient/physician) for all given contact ids
 *
 * @param contactIds, Ids from the contacts, which should be selected
 *
 * @return Map<Id, Contact>, the selected contacts mapped by their Id
 */
    public static Map<Id, Contact> getContactMap(Set<Id> contactIds){
        Map<Id, Contact> contactMap = new Map<Id, Contact>([
                SELECT Id, Phone, Name, Status__c, hmsc_registration__c, MailingAddress, following_physician__c,
                        following_physician__r.Phone, following_physician__r.Name, following_physician__r.MailingAddress, CreatedDate
                        FROM Contact
                        WHERE Id IN :contactIds]);
        return contactMap;
    }

    /**
    * Select all the OrderItem information related to the given orders
    *
    * @param	setOrderIds, Ids from the orders, for which the order items should be selected
    * @return	Map<Id, List<OrderItem>>, a Map with a list of all order items, mapped by their order id
    */
    public static Map<Id, List<OrderItem>> getOrderItemsFromOrder(Set<Id> setOrderIds) {
        Map<Id,List<OrderItem>> mapOrderItems = new Map<Id, List<OrderItem>>();

        for(OrderItem objOrderItem :  [SELECT Id, part_of_system_price__c, UnitPrice, ListPrice, OrderId, product_type__c, status__c, price_discrepancy_reason__c, Product2.Name, udi__c,
                serial_number__c, batch_no__c, model_no__c, stock_type__c, Product2.sub_group_4__c, asset__c, product_consumed__c
                FROM OrderItem
                WHERE OrderId IN :setOrderIds]) {
            if(!mapOrderItems.containsKey(objOrderItem.OrderId)) {
                mapOrderItems.put(objOrderItem.OrderId, new List<OrderItem>{objOrderItem});
            } else {
                mapOrderItems.get(objOrderItem.OrderId).add(objOrderItem);
            }
        }
        return mapOrderItems;
    }

}