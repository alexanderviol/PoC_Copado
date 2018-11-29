/**
 *
 * This batch job checks if the patient has a hmsc registrations and processes the cm orders based on the result
 * 
 * @author         ilu_pkas 
 * @modifiedBy     ilu_pkas
 * @created        2018-MM-DD
 * @modified       2018-08-29
 * @systemLayer    Batch 
 *  
*/
global class HmscRegistrationCheckBatch  implements Database.Batchable<Order>, Schedulable{
    @testVisible private static final String REGISTRATIONPENDING = 'Pending HMSC Registration';
    @testVisible private static final String READYTOSAPSUBMIT = 'Pending SAP Submission';
    @testVisible private static final String CANCELED = 'Canceled';
    /**
     * Identifiere for the configuration of this batch job
     */
    @testVisible private static final String IDENTIFIER_HMSC_BATCH_CONFIG = 'ContacHmscRegistrationCheckBatchHmscRegi';
    
    @testVisible 
    private static final List<Group> submitToSapQueueList = [SELECT Id 
                                                            FROM Group 
                                                          WHERE Type = 'Queue' 
                                                            AND DeveloperName = 'submit_mdrf_orders_to_sap_worklist'];
    
    /**
     * Collects all orders, which are in the status registration pending and where submitted in a defined timeframe
     * 	The timeframe can be alterd over the custom setting hmsc_registration
     * 
     * @return a iterable that contains the order records passed to the job
     */
	global Iterable<Order> start(Database.BatchableContext BC){

        Integer intDaysToCheck = Integer.valueOf(Utility.getSettingValue(IDENTIFIER_HMSC_BATCH_CONFIG,'60'));
        List<Order> lstOrders = new List<Order>();
        
        String strQueryFields 	= 'SELECT Id, Status, patient__c, patient__r.hmsc_registration__c, 	date_cm_submitted__c';
        String strQueryObject 	= ' FROM Order ';
        String strQueryWhere 	= ' WHERE Status = \''+REGISTRATIONPENDING+'\' AND date_cm_submitted__c = LAST_N_DAYS:'+intDaysToCheck+2;
        
        String strQuery = strQueryFields + strQueryObject + strQueryWhere;
        
        lstOrders = Database.query(strQuery);
        
      	return lstOrders;
   	}
    
    /**
     * Checks for all order inside the scope, if the patient has a hmsc registration or if the time to register is over.
     * 	If the patient got a registration in time, the order is pushed to the next status (ReadyToSapSubmit)
     * 	If the patient didn't got a registration in time, the order is cancelled
     * 
     * @param	scope, a list with all order that need to be checked for the registration
     */
    global void execute(Database.BatchableContext BC, List<Order> scope){
        List<SObject> lstChangedObjects = new List<SObject>();
        Set<Id> setOrderIds = new Set<Id>();
        Date dateToday = Date.today();

        Integer intDaysToCheck = Integer.valueOf(Utility.getSettingValue(IDENTIFIER_HMSC_BATCH_CONFIG,'60'));
        
        for(Order ord :scope){
            Date startDate = ord.date_cm_submitted__c;
            Integer numberDaysDue = startDate.daysBetween(dateToday);
            
            // System.debug('Patient reg: '+ord.patient__r.hmsc_registration__c);
            // System.debug('Days due: ' +numberDaysDue+ ' Days allowed: '+intDaysToCheck);
                
            if(ord.patient__r.hmsc_registration__c){
                ord.Status = READYTOSAPSUBMIT;
                ord.date_cm_approved__c = Date.today();
                ord.OwnerId = submitToSapQueueList.get(0).Id;
                lstChangedObjects.add(ord);
                
                setOrderIds.add(ord.Id);
            }else if(numberDaysDue >= intDaysToCheck){
                ord.Status = CANCELED;
                lstChangedObjects.add(ord);
            }
        }
        
        if(!lstChangedObjects.isEmpty())
        	update lstChangedObjects;
        }
    
    
    global void finish(Database.BatchableContext BC){
   	}
    
    global void execute(SchedulableContext SC) {
    	Database.executeBatch(new HmscRegistrationCheckBatch(), 100); 
   	}
}