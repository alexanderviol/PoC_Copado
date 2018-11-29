trigger ProductConsumedTrigger on ProductConsumed (before delete, before insert) {
	
    ProductConsumedHandler objHandler = new ProductConsumedHandler();
    if (Trigger.isBefore) {
        if (Trigger.isDelete) {
            objHandler.onBeforeDelete (Trigger.oldMap);
        }
        if (Trigger.isInsert) {
            ProductConsumedHandler.onBeforeInsert (Trigger.new);
        }
    }
}