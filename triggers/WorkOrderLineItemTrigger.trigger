trigger WorkOrderLineItemTrigger on WorkOrderLineItem (before delete, after update) {

    WorkOrderLineItemHandler objHandler = new WorkOrderLineItemHandler();
    if(Trigger.isBefore){
        if(Trigger.isDelete){
            objHandler.onBeforeDelete(Trigger.oldMap);
        }
    }
    else if (Trigger.isAfter) {
        if(Trigger.isUpdate) {
            objHandler.onAfterUpdate(Trigger.oldMap, Trigger.newMap);
        }
    }
}