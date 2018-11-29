/**************************************************************************************************************
* Product2_Selector - Selector class for Product2 Object
* @author Gokul Palagiri
* @CreatedDate -    10.10.2018
* Gokul Palagiri:   10.10.2018 : Initial Version
****************************************************************************************************************/
public with sharing class Product2_Selector extends BaseSelector {

    private String getObjectApiName() {
        return Product2.SObjectType.getDescribe().getName();
    }

    public List<Product2> getById(Set<Id> keyIds, Set<String> fields) {
        if(keyIds.isEmpty()) {
            return new List<Product2>();
        }
        String query = 'SELECT ' + constructFieldString(fields) + ' FROM ' + getObjectApiName() + ' WHERE Id IN ' + constructInClauseString(keyIds);
        return Database.Query(query);
    }
}