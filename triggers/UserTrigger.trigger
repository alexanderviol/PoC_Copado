trigger UserTrigger on User (after insert, after update) {
    UserHandler objHandler = new UserHandler();
    if(trigger.isAfter) {
        if(trigger.isInsert) {
            objHandler.onAfterInsert(trigger.new);
        } else if(trigger.isUpdate) {
            objHandler.onAfterUpdate(trigger.newMap, trigger.oldMap);
        }
    }
}