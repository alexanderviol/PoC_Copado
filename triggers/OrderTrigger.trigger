trigger OrderTrigger on Order (before insert, after insert, before update, after update) {
    OrderHandler objHandler = new OrderHandler();
    if (Trigger.isBefore) {
        if (Trigger.isInsert) {
            objHandler.onBeforeInsert(Trigger.new);
        } else if (Trigger.isUpdate) {
            objHandler.onBeforeUpdate(Trigger.new, Trigger.old, Trigger.newMap, Trigger.oldMap);
        }
    } else if (System.Trigger.isAfter) {
        if (System.Trigger.isUpdate) {
            objHandler.onAfterUpdate(Trigger.newMap, Trigger.oldMap);
        } else if (Trigger.isInsert) {
            objHandler.onAfterInsert(Trigger.new);
        }
    }
}