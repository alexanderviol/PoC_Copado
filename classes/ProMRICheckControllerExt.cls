public with sharing class ProMRICheckControllerExt {
    
	public List<Contact> conList{get;set;}
    public Integer contNb{get;set;}
    public String patient{get;set;}
    public List<Id> contactIds{get;set;}
    public String RecId {get;set;}
    public Contact contacts{get;set;}
    
    public ProMRICheckControllerExt (ApexPages.StandardSetController controller) {
        conList = (List<Contact>) controller.getSelected();
        contNb = conList.size();
        
        contacts = (Contact)controller.getRecord();
        RecId = contacts.Id;
        //get list of Ids
        List<Id>  contactI = new list<Id>();
        for (Contact cnt: conList ){
            if (cnt.Id != null){
                contactI.add(cnt.Id);            
            }
        }
        contactIds = contactI;
        patient = allPatient(contactIds);
    }
    public static String allPatient(List <Id> ContactIds){
        String strToReturn = '';

        strToReturn = String.valueof(contactIds.size());
		List<Contact> patientList = [SELECT 
                                     	id,recordtype.developerName 
                                     FROM 
                                     	Contact 
                                     WHERE 
                                     	id IN : contactIds 
                                     AND 
                                     	recordtype.developerName =: Constants.RECORD_TYPE_NAME_CONTACT_US_PATIENT];
        if(patientList.size() != contactIds.size()) {
            strToReturn = 'Not All Patients';           
        }
        return strToReturn;  
    }
    @RemoteAction
    public static String CheckProMRI (string ContactId){
        String response = '';
        String str = ContactId.replace('[', '').replace(']', '');
        List<String> res = str.split(',');
        List<Id> idList = new List<Id>();
        for (Integer i = 0 ; i<res.size(); i++){
            String idValue = Id.valueOf(res[i].replaceAll( '\\s+', ''));	
            idList.add(idValue);
        }
        if (res.size()> 0){
           response = ProMRICalloutHelper.doCheck(idList); 
        }
        return response;
    }
    
    @AuraEnabled
    public static String checkProMRIFromRecord(string rec) {
        String str = rec.replace('[', '').replace(']', '');
        String idValue = Id.valueOf(str);
        ProMRICalloutHelper.doCheck(new List<String>{idValue});
        return [Select id, toLabel(promri_check_status__c) FROM Contact WHERE Id =: idValue].promri_check_status__c;
    }
}