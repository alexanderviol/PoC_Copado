/**
 * Trigger to update user information based on the existence of a ServiceResource record.
 * 
 * @author			Florian Heer <f.heer@conciscon.de>
 * @created			2018-08-07
 * @systemLayer    	Trigger
 *  
*/

trigger ServiceResourceTrigger on ServiceResource (after insert, after update) {
    if(Trigger.isAfter) {
        if(Trigger.isInsert || Trigger.isUpdate) {
            ServiceResourceHandler.handleUserServiceResource (Trigger.new);
        }
    }
    
}