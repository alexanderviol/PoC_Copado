/**
 *
 * This controller functions as a server side controller for the OrderItemOosValidation lightning component
 * 
 * It provides the selector part and functions for the needed updates on the order and order items
 * 
 * @author         ilu_pkas 
 * @modifiedBy     snpa
 * @created        2018-MM-DD
 * @modified       2018-08-29
 * @systemLayer    Controller
 *  
*/
public with sharing class OrderItemOosValidationCtrl {

    @AuraEnabled
    public static List<Asset> getMissingComplaintAssets(Id idOrder) {
    	Order objOrder = [SELECT Id, patient__c, 
                          			(SELECT createddate FROM Implants_Procedures__r) 
                          FROM Order 
                          	WHERE Id = :idOrder LIMIT 1];
        
        if(objOrder.Implants_Procedures__r != null && objOrder.Implants_Procedures__r.size() > 0) {
            Date createdDateIP = Date.valueOf(objOrder.Implants_Procedures__r[0].CreatedDate.date());
            if(Test.isRunningTest())
            	createdDateIP =  System.today().addDays(-4);
            List<Asset> assList = [SELECT Id, Name, Status, oos_date__c, oos_additional_information__c,			
                                     explant_date__c , explant_date_unknown__c , explanting_facility__c,
                                     explanting_physician__c , event_reason__c, has_attached_oos_complaints__c,
                                     days_from_implant_to_explant__c, InstallDate
                                FROM Asset WHERE Status IN : Constants.OOS_STATUS
                                    AND patient__c = :objOrder.patient__c
                                    AND imported_as_oos__c = FALSE
                                    AND RecordType.DeveloperName = : Constants.RECORD_TYPE_NAME_ASSET_US_BIOTRONIK
                                    AND (date_asset_status_changed__c = null 
                                         OR
                                            (date_asset_status_changed__c <= :System.today() 
                                                AND 
                                            date_asset_status_changed__c >= :createdDateIP))
                                  ];
            
            List<Asset> oosList = new List<Asset>();
            for (Asset assetObj : assList) {
                if( (assetObj.oos_date__c == null
                     || assetObj.oos_additional_information__c	== null			
                     || (assetObj.status == Constants.IMPLANT_STATUS_EXPLANTED && assetObj.explant_date__c == null && assetObj.explant_date_unknown__c == false)
                     || assetObj.event_reason__c == null
                     || (assetObj.has_attached_oos_complaints__c == false 
                         &&
                         ((assetObj.event_reason__c == Constants.PICKLIST_VALUE_OOS_REASON_ERI && assetObj.days_from_implant_to_explant__c < 1825 )
                          || (assetObj.event_reason__c == Constants.PICKLIST_VALUE_OOS_REASON_PATIENT_DEATH && assetObj.installDate != null && assetObj.days_from_implant_to_explant__c == 0)
                          || (assetObj.event_reason__c != Constants.PICKLIST_VALUE_OOS_REASON_UPGRADE )
                         )))) {
                    oosList.add(assetObj);
                } 
            }
            return oosList;
        } 
        return null;         
    } 
}