/**************************************************************************************************************
* Contact_Selector - Selector class for Contact Object
* @author Gokul Palagiri
* @CreatedDate -    10.10.2018
* Gokul Palagiri:   10.10.2018 : Initial Version
****************************************************************************************************************/
public with sharing class Contact_Selector extends BaseSelector {

    private String getObjectApiName() {
        return Contact.SObjectType.getDescribe().getName();
    }

    public List<Contact> getById(Set<Id> keyIds, Set<String> fields) {
        if(keyIds.isEmpty()) {
            return new List<Contact>();
        }
        String query = 'SELECT ' + constructFieldString(fields) + ' FROM ' + getObjectApiName() + ' WHERE Id IN ' + constructInClauseString(keyIds);
        return Database.Query(query);
    }


}