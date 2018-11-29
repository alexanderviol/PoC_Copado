/**************************************************************************************************************
* Order_Selector - Selector class for Order Object
* @author Gokul Palagiri
* @CreatedDate -    10.10.2018
* Gokul Palagiri:   10.10.2018 : Initial Version
****************************************************************************************************************/
public with sharing class Order_Selector extends BaseSelector {

    private String getObjectApiName() {
        return Order.SObjectType.getDescribe().getName();
    }

    public List<Order> getById(Set<Id> keyIds, Set<String> fields) {
        if(keyIds.isEmpty()) {
            return new List<Order>();
        }
        String query = 'SELECT ' + constructFieldString(fields) + ' FROM ' + getObjectApiName() + ' WHERE Id IN ' + constructInClauseString(keyIds);
        return Database.Query(query);
    }


}