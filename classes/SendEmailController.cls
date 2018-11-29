/* 
 *  Description  - Class to get Contact and User Information
 *  Created Date - 4/2/2018
 *  Created by   - susi
 */
public with sharing class SendEmailController {
    /* 
     *  Description  - Method that returns contact and User Info. 
     *  @param    recId    Id of contact record
     *  @return   wrapper  Contact and User Info wrapped together 
     */
    @AuraEnabled
    public static wrapper getRecords(String recId) {
        wrapper wrp;
        try {
            User usr = [SELECT Id, Email 
                        FROM User 
                        WHERE id =: UserInfo.getUserId()];
            Contact con = [SELECT Id, Email 
                            FROM Contact 
                            WHERE id =: recId];
            wrp = new wrapper(usr, con);
            
        } catch(Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
        return wrp;
    }
    
    /*
     * Wrapper class to bind User and contact information together
     */
    public class wrapper {
        @testVisible @AuraEnabled User u {get;set;}
        @testVisible @AuraEnabled Contact c {get;set;}
        public wrapper(User usr, Contact con) {
            u = usr;
            c= con;
        }
    }
    
    /* 
     *  Description  - Method that returns lookupfields from Workorder AND Order. 
     *  @param    recId    Id of Workorder/Order record
     *  @return   List<sObject>    List of workorder/order records
     */
    @AuraEnabled
    public static List<KeyValueWrapper> getlookupFieldValues(String recId) {
        sObject sObj;
        Map<String, String> fieldsMap;
        Id recordId = (Id)recId;
        List<KeyValueWrapper> wrapperList = new List<KeyValueWrapper>();  
        String objName = recordId.getSObjectType().getDescribe().getName();
        Map<String, Schema.SObjectField> objectFields = Schema.getGlobalDescribe().get(objName).getDescribe().fields.getMap();
        if(objName.equalsIgnoreCase('Workorder')) {
            fieldsMap = new Map<String, String>{'id' => 'id', 
                								'ContactId' => 'Contact.name', 
                								'following_physician__c' => 'following_physician__r.name',
                								'implanting_physician__c' => 'implanting_physician__r.name', 
                								'patient__c' => 'patient__r.Name',
                								'referring_physician__c' => 'referring_physician__r.name'
                                               };
        } else {
            fieldsMap = new Map<String, String>{'id' => 'id',  
                								'BillToContactId' => 'BillToContact.name', 
                                                'CustomerAuthorizedById' => 'CustomerAuthorizedBy.name',
                        						'patient__c' => 'patient__r.name',
                								'referring_physician__c' => 'referring_physician__r.name',
                        						'ShipToContactId' => 'ShipToContact.name'
        									   };
        }
        Set<String> fields = new Set<String>();
        fields.addAll(fieldsMap.keySet());
        fields.addAll(fieldsMap.values());
        List<String> strList = new List<String>(fields);
        String queryString = 'SELECT ' +  String.join(strList, ', ') + ' FROM ' + objName + ' WHERE Id =: recId';
        sObj = database.query(queryString);
        for(String key : fieldsMap.keySet()) {
            if (fieldsMap.get(key) != null && sObj.get(key) != null && !key.equalsIgnoreCase('Id')) {
                List<String> tempList = String.valueOf(fieldsMap.get(key)).split('\\.');
                if(tempList.size() > 1)
                	wrapperList.add(new KeyValueWrapper(key, (String)sObj.get(key), (String)sObj.getsObject(tempList[0]).get(tempList[1]), objectFields.get(key).getDescribe().getlabel()));
            }  
        }
        return wrapperList;        
    } 
    
    /*
     * Wrapper class to bind User and contact information together
     */
    public class KeyValueWrapper {
        @testVisible @AuraEnabled String key {get;set;}
        @testVisible @AuraEnabled String Id {get;set;}
        @testVisible @AuraEnabled String val {get;set;}
        @testVisible @AuraEnabled String label {get;set;}
        public KeyValueWrapper(String keyItem, String recId, String nameValue, String lbl) {
            key = keyItem;
            Id = recId;
            val = nameValue;
            label = lbl;
        }
    }   
}