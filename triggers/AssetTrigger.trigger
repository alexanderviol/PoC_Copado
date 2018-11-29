trigger AssetTrigger on Asset (after insert, after update, after delete, before delete, before insert, before update) {
    
    AssetHandler objHandler= new AssetHandler();
    if(trigger.isAfter) {
        if(trigger.isInsert) {
        	objHandler.onAfterInsert(trigger.newMap);    
        } else if(trigger.isUpdate) {
        	objHandler.onAfterUpdate(trigger.newMap, trigger.oldMap);     
        } else if(trigger.isDelete){
            objHandler.onAfterDelete(trigger.oldMap);
        }
    } 
    else { 
        if(trigger.isBefore){
            if(trigger.isDelete){
                objHandler.onBeforeDelete(trigger.oldMap);
            }
            else if (trigger.isUpdate) {
                objHandler.onBeforeUpdate(trigger.new);
            }
            else if(Trigger.isInsert) {
                objHandler.onBeforeInsert(trigger.new);
            }
        }
    }
}