/*
 *  This class contains the methods used to fetch the user record based on differnt criteria
 *  Created Date - April 8, 2018
 *  Created by   - Sumit
 * 
 * Revision History - 
 * Date             | Developer Name                | Version               | Changes/Ticket Number 
 * ================================================================================================      
 *  
 */
public class customLookUpController {
   
   /*
    * This method fetch the user record based on Territory and returns the records to the lightning component.
    * @param    recordId    Workorder record Id.
    * @param    searchKeyWord    Searched username on UI
    * @param    ObjectName    Name of object
    * @param    rep    Type of representative
    * @return   List<sObject>    List of sObject records to be returned 
    *
    */
    @AuraEnabled
    public static List <sObject> fetchLookUpValues(String recordId, String searchKeyWord, String ObjectName, String rep) {
        Set<Id> userIdSet = new Set<Id>();
        Set<Id> territoryIdSet = new Set<Id>(); 
        for(ObjectTerritory2Association objTARecord : [SELECT Territory2Id
                                                        FROM ObjectTerritory2Association 
                                                        WHERE ObjectId =: [SELECT AccountId FROM WorkOrder WHERE id =: recordId].AccountId ]) {
            territoryIdSet.add(objTARecord.Territory2Id);
        }
        for(UserTerritory2Association userTARecord : [SELECT UserId 
                                                        FROM UserTerritory2Association
                                                        WHERE Territory2Id IN : territoryIdSet]) {
            userIdSet.add(userTARecord.UserId);
        } 
        String searchKey = searchKeyWord + '%';
        
        String sQuery = '';

        sQuery =  'select id, Name from ' + ObjectName + ' where Name LIKE: searchKey AND Id IN : userIdSet order by createdDate DESC limit 5';
                    
        return Database.query(sQuery);
    }
}