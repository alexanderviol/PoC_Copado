/**************************************************************************************************************
* Asset_Selector - Selector class for Asset Object
* @author Gokul Palagiri
* @CreatedDate -    10.10.2018
* Gokul Palagiri:   10.10.2018 : Initial Version
****************************************************************************************************************/
public with sharing class Asset_Selector extends BaseSelector {

    @TestVisible private String getObjectApiName() {
        return Asset.SObjectType.getDescribe().getName();
    }

    public List<Asset> getById(Set<Id> keyIds, Set<String> fields) {
        if(keyIds.isEmpty()) {
            return new List<Asset>();
        }
        String query = 'SELECT ' + constructFieldString(fields) + ' FROM ' + getObjectApiName() + ' WHERE Id IN ' + constructInClauseString(keyIds);
        return Database.Query(query);
    }

    public List<Asset> getByIdAndRecordTypeName(Set<Id> keyIds, Set<String> recordTypeNames, Set<String> fields) {
        if(keyIds.isEmpty() || recordTypeNames.isEmpty()) {
            return new List<Asset>();
        }
        String query = 'SELECT ' + constructFieldString(fields) + ' FROM ' + getObjectApiName() + ' WHERE Id IN ' + constructInClauseString(keyIds)
                        + ' AND RecordType.DeveloperName IN ' + constructInClauseString(recordTypeNames);
        return Database.Query(query);
    }


}