/* Florian Heer <f.heer@conciscon.de>
 * 2018-07-24 Adds Home Monitoring Service if a Cardio Messenger is added to an Order
 */

trigger OrderItemTrigger on OrderItem (after insert, after delete) {
    If(Trigger.isAfter) {
        if(Trigger.isInsert) {
            OrderItemHandler.afterInsert(Trigger.new);
        }
        if(Trigger.isDelete) {
            OrderItemHandler.afterDelete(Trigger.old);
        }
    }
}