/* Created 2018-09-24 Florian Heer <f.heer@conciscon.de>
 * Handles events on ProductItem records
 */
public class ProductItemHandler {
    
    /* Florian Heer <f.heer@conciscon.de>
    * SAFBIO-2023: If a serialized Product Item is updated from QuantityOnHand = 0 to QuantityOnHand > 0 and there is a ProductConsumed
    * existing, silently ignore the update.
    */ 
    public static void checkAndPreventQuantityOnHand(Map<id, ProductItem> newMap, Map<Id, ProductItem> oldMap) {
        List<Id> productItemsToCheckForProductConsumed = new List<Id>();
        for(ProductItem pi : newMap.values()) {
            if(pi.serialized_item__c) {
                ProductItem oldPi = oldMap.get(pi.Id);
                if(oldPi.QuantityOnHand == 0 && pi.QuantityOnHand > 0) {
                    productItemsToCheckForProductConsumed.add(pi.Id);
                }
            }
        }
        // So here we have a list of ProductItem-IDs, which are serialized, had a Quantity of 0 and are to be updated.
        // Let's narrow it down to those that have ProductConsumed records attached. Those that don't do not concern us.
        List<ProductConsumed> pisToNotAcceptUpdatesOn = [SELECT ProductItemId FROM ProductConsumed WHERE ProductItemId IN :productItemsToCheckForProductConsumed];
        for(ProductConsumed pc: pisToNotAcceptUpdatesOn) {
            ((ProductItem)Trigger.newMap.get(pc.ProductItemId)).QuantityOnHand = 0;
        }
    }
}