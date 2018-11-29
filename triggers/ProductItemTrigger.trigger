/* Created 2018-09-24 Florian Heer <f.heer@conciscon.de>
 * Delegates ProductItem events to ProductItemHandler
 */
trigger ProductItemTrigger on ProductItem (before update) {
    if(Trigger.isBefore) {
        if(Trigger.isUpdate) {
            ProductItemHandler.checkAndPreventQuantityOnHand(Trigger.newMap, Trigger.oldMap);
        }
    }
}