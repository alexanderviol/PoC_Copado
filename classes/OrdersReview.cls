/**
* @author:			arwe
*					T-Systems Multimedia Solutions GmbH
*					Riesaer Strasse 5,
*					01129 Dresden
*					www.t-systems-mms.com
*
* @description      
*                  
*
* @date             15.10.2018
* 
*/

public with sharing class OrdersReview {

    private static final Id idRecordTypeMdrfOrder = Utility.getRecordTypeId(Order.SObjectType, Constants.RECORD_TYPE_NAME_ORDER_MDRF);
    public Map<Id, Account> accountMap;
    public Map<Id, Contact> contactMap;

    private Map<Id, List<OrderItem>> orderOrderItemMap = new Map<Id, List<OrderItem>>();
    private Map<Id, List<Asset>> orderAssetMap = new Map<Id, List<Asset>>();

    public Map<Id, List<OrderItem>> getOrderOrderItemMap(){
        return this.orderOrderItemMap;
    }

    public Map<Id, List<Asset>> getOrderAssetMap(){
        return this.orderAssetMap;
    }

    public OrdersReview(List<Order> newOrderLis) {
        accountMap = new Map<Id, Account>();
        contactMap = new Map<Id, Contact>();
        setData(newOrderLis);
    }

    private void setData(List<Order> newOrderList) {

        Set<Id> processedOrdersId = new Set<Id>();
        Set<Id> setIdPatients = new Set<Id>();
        Set<Id> accountIds = new Set<Id>();
        Set<Id> contactIds = new Set<Id>();

        for (Order objOrder : newOrderList) {
            if (idRecordTypeMdrfOrder == objOrder.RecordTypeId) {
                if (!Trigger.isInsert) {
                    processedOrdersId.add(objOrder.Id);
                }
                setIdPatients.add(objOrder.patient__c);
                accountIds.add(objOrder.AccountId);
                contactIds.addAll(new Set<Id>{
                        objOrder.implanting_physician__c, objOrder.patient__c, objOrder.following_physican__c
                });
            }
        }
        accountMap = getAccounts(accountIds);
        contactMap = OrderHelper.getContactMap(contactIds);
        if (!processedOrdersId.isEmpty()) {
            orderOrderItemMap = OrderHelper.getOrderItemsFromOrder(processedOrdersId);
            orderAssetMap = getAssetsFromPatient(setIdPatients);
        }

    }

    /**
     *  Selects the account id and the ShippingState for the given account ids
     *
     * @param	setAccountIds, Ids from the accounts, which should be selected
     * @return	Map<Id, Account>, the selected accounts mapped by their Id
     */
    private static Map<Id, Account> getAccounts(Set<Id> setAccountIds) {
        return new Map<Id, Account>([
                SELECT Id, ShippingState
                        FROM Account
                        WHERE Id IN :setAccountIds
        ]);
    }

    /**
    * Select all the Asset information related to the given patient
    *
    * @param	setPatientIds, Ids from the patients, for which the assets should be selected#
    * @return	Map<Id, List<Asset>>, a Map with a list of all assets, mapped by their patient id
    */
    private static Map<Id, List<Asset>> getAssetsFromPatient(Set<Id> setPatientIds) {
        Map<Id, List<Asset>> mapAssetsByPatient = new Map<Id, List<Asset>>();
        for(Asset objAsset :  [SELECT Id,
                patient__c,
                part_of_system_price__c,
                Price,
                order__c,
                LocationId,
                Location.Name,
                product_type__c,
                Status,
                Lead_Tip_Location__c,
                UDI__c,
                SerialNumber,
                batch_no__c,
                model_no__c,
                explanting_physician__c,
                explanting_physician__r.Name,
                explanting_physician__r.Phone,
                explanting_physician__r.MailingAddress
                FROM Asset
                WHERE patient__c IN :setPatientIds]) {

            if(mapAssetsByPatient.isEmpty() || !mapAssetsByPatient.containsKey(objAsset.patient__c)) {
                mapAssetsByPatient.put(objAsset.patient__c, new List<Asset>{objAsset});
            } else {
                mapAssetsByPatient.get(objAsset.patient__c).add(objAsset);
            }
        }
        return mapAssetsByPatient;
    }

}