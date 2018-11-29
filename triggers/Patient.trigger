trigger Patient on Contact (before insert, after insert, before update, after update, after delete) {
    Map<ID, Schema.RecordTypeInfo> rtMap = Schema.SObjectType.Contact.getRecordTypeInfosById();

    if(Trigger.isBefore && (Trigger.isUpdate || Trigger.isInsert)){    
    	for (contact c : Trigger.New){
            // Never rely on a returned object not to be null... FH 2018-06-11
            // if(rtMap.get(c.recordtypeId).getName() == 'Patient') {
            RecordTypeInfo rti = rtMap.get(c.recordtypeId);            
            if(rti != null && rti.getName() == 'Patient') {
                c.trig_dob__c = string.ValueOf(c.Birthdate);
            }
            
            //copying hmsc_registration__c field value to HMSC_Registration_StringVal__c
            if(Trigger.isInsert)
                c.HMSC_Registration_StringVal__c = (c.hmsc_registration__c) ? 'yes' : 'no' ;
        }     
	}
    if(Trigger.isInsert && Trigger.isAfter) {
        //Inserting Account for patients
        ContactTriggerHandler.checkAndAddAccount(Trigger.newMap);
   } 
    
    if(Trigger.isUpdate && Trigger.isBefore){
        ContactTriggerHandler.onBeforeUpdate(Trigger.newMap, Trigger.oldMap);
    }
    if(Trigger.isUpdate && Trigger.isAfter){
        ContactTriggerHandler.onAfterUpdate(Trigger.newMap, Trigger.oldMap);
    }
    //Deleting the account
    if(Trigger.isDelete && Trigger.isAfter) {
		ContactTriggerHandler.deleteAccount(Trigger.old);   
    }
}