/* 2018-07-24 Florian Heer <f.heer@conciscon.de>
 * Handles Trigger events for OrderItems.
 *
 * Currently this only adds a Home Monitoring Service if a Cardio Messenger is added.
 */
public class OrderItemHandler {

    public static List<Product2> getHomeMonitoringServiceProducts() {
        return [SELECT Id, sap_model_no__c FROM Product2 WHERE ExternalId = :Constants.HOME_MONITORING_SERVICE_SAP_EXTERNAL_ID];
    }
    
    /* Updates all Orders to include a Home Monitoring Service if there is not already one present.
     */
    public static void afterInsert(List<OrderItem> newItems) {
        List<OrderItem> toBeConsidered = new List<OrderItem>();
        for(OrderItem oi : newItems) {
            if(Utility.getValidationCategory(oi.product_type__c) == Constants.VALI_CAT_CARDIO_MESSENGER 
               && (oi.asset__c == null || oi.asset__r.stock_type__c != 'B')) {
                toBeConsidered.add(oi);
            }
        }
        
        Set<Id> orderIDsToProcess = getOrderIDsForProductType(toBeConsidered, Constants.PICKLIST_VALUE_PRODUCT_TYPE_CARDIO_MESSENGER);
        
        if(orderIDsToProcess.size() > 0) {

            List<Product2> hmProducts = getHomeMonitoringServiceProducts();
            if(hmProducts.size() > 0) {
                List<Order> ordersToProcess = [SELECT Id, num_hm_products__c, CurrencyIsoCode, Pricebook2Id
                                               FROM Order WHERE Id IN :orderIDsToProcess AND num_hm_products__c = 0
                                               ];
                List<OrderItem> orderItemsToAdd = new List<OrderItem>();
                
                Map<Id, PricebookEntry> pb2pbe = new Map<Id, PricebookEntry>();
                List<Id> pricebookIds = new List<Id>();
                List<String> currencies = new List<String>();
                
                for(Order o : ordersToProcess) {
                    pricebookIds.add(o.Pricebook2Id);
                    currencies.add(o.CurrencyIsoCode);
                }
                List<PricebookEntry> pbes = [SELECT Id, UnitPrice, CurrencyIsoCode, Pricebook2Id 
                                             FROM PricebookEntry WHERE Product2Id = :hmProducts[0].Id
                                             AND CurrencyIsoCode IN :currencies
                                             AND IsActive = true
                                             AND Pricebook2Id IN :pricebookIds];
                
                
                
                
                for(Order o:ordersToProcess) {
                    PricebookEntry usablePBE = null;
                    for(PricebookEntry pbe : pbes) {
                        if(pbe.CurrencyIsoCode == o.CurrencyIsoCode && pbe.Pricebook2Id == o.Pricebook2Id) {
                            usablePBE = pbe;
                        }
                    }
                    if(usablePBE != null) {
                        orderItemsToAdd.add (new OrderItem (OrderId = o.Id,
                                                            PricebookEntryId = usablePBE.Id
                                                            , Quantity = 1
                                                            , UnitPrice = usablePBE.UnitPrice
                                                            , model_no__c = hmProducts[0].sap_model_no__c
                                                            , product_type__c = Constants.PICKLIST_VALUE_PRODUCT_TYPE_HOME_MONITORING_SERVICE
                                                           ));
                    }
                    else {
                        // TBD: what happens if there is no home monitoring in this Pricebook?
                        System.debug('Add Home Monitoring Service: Cannot find Home Monitoring Service in the current Pricebook.');
                        
                    }
                }
                if(orderItemsToAdd.size() > 0) {
                    insert orderItemsToAdd;
                }
            }
            else {
                // TBD: what happens if there is no home monitoring in the products?
                System.debug('Add Home Monitoring Service: Cannot find Home Monitoring Service in the products');
            }
        }
    }

    public static Set<Id> getOrderIDsForProductType(List<OrderItem> ourItems, String productType) {
        Set<Id> retval = new Set<Id>();
        for(OrderItem oi : ourItems) {
            if(Utility.getValidationCategory(oi.product_type__c) == Constants.VALI_CAT_CARDIO_MESSENGER) {
                retval.add(oi.OrderId);
            }
        }
        return retval;

    }
    
    /* Updates all Orders to remove a Home Monitoring Service if there is no Cardio Messenger left.
     */
    public static void afterDelete(List<OrderItem> oldItems) {
        Set<Id> orderIDsToProcess = getOrderIDsForProductType(oldItems, Constants.PICKLIST_VALUE_PRODUCT_TYPE_CARDIO_MESSENGER);
        
        if(orderIDsToProcess.size() > 0) {

            List<Product2> hmProducts = getHomeMonitoringServiceProducts();
            if(hmProducts.size() > 0) {
                List<Order> ordersToProcess = [SELECT Id, num_hm_products__c, num_cm_products__c, CurrencyIsoCode, Pricebook2Id
                                               FROM Order WHERE Id IN :orderIDsToProcess AND num_hm_products__c > 0
                                              ];
                List<OrderItem> orderItemsToDelete = new List<OrderItem>();
                List<Id> orderIDs = new List<Id>();
                for(Order o:ordersToProcess) {
                    if(o.num_hm_products__c > 0 && o.num_cm_products__c == 1) {
                        orderIDs.add(o.Id);
                    }
                }
                
                if(orderIDs.size() > 0) {
                    orderItemsToDelete.addAll([SELECT Id FROM OrderItem WHERE OrderId IN :orderIDs 
                                               AND model_no__c = :Constants.HOME_MONITORING_SERVICE_SAP_MODEL]);
                }
                
                if(orderItemsToDelete.size() > 0) {
                    delete orderItemsToDelete;
                }
            }
            else {
                // TBD: what happens if there is no home monitoring in the products?
                System.debug('Add Home Monitoring Service: Cannot find Home Monitoring Service in the products');
            }
        }
        
    }

}