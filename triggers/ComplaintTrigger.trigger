trigger ComplaintTrigger on complaint__c (before insert,
                                          before update,
                                          after insert, 
                                          after update,
                                          after delete, 
                                          after undelete) {
    
	ComplaintHandler handler = new ComplaintHandler();	
    if(trigger.isBefore) {
        if(trigger.isInsert) {
        	handler.onBeforeInsert(trigger.new);    
        } else if(trigger.isUpdate) {
        	handler.onBeforeUpdate(trigger.new, trigger.oldMap);        
        }        
    } else if(trigger.isAfter) {
        if(trigger.isInsert) {
            handler.onAfterInsert(trigger.newMap);    
        } else if(trigger.isUpdate) {
            handler.onAfterUpdate(trigger.newMap, trigger.oldMap);    
        } else if(trigger.isDelete) {
            handler.onAfterDelete(trigger.newMap, trigger.oldMap);    
        } else if(trigger.isUndelete) {
            handler.onAfterUndelete(trigger.newMap, trigger.oldMap);    
        }
    }
}