public class BINCAssetDataControllerExt {
    private Asset ourAsset;
    private Asset fullerAsset;
    private complaint__c newestComplaint;
    private String oosReason;
    private complaint_relationships__c drLetterRecipient;
    private complaint_relationships__c eventPhysician;
    private Case newestCase;
    
    
    
    public BINCAssetDataControllerExt (ApexPages.StandardController stdController) {
        // Can only be an Asset
        ourAsset = (Asset)stdController.getRecord();
        
        readRelatedData ();
    }
    
    private void readRelatedData () {
        List<Asset> assets = [SELECT Id
                              , patient__r.FirstName, patient__r.MiddleName, patient__r.LastName
                              , patient__r.ssn__c, patient__r.BirthDate
                              , patient__r.Status__c, patient__r.date_of_death__c
                              // , patient__r.cause_of_death__c
                              , explanting_physician__r.FirstName, explanting_physician__r.MiddleName, explanting_physician__r.LastName
                              , explanting_physician__r.MailingStreet, explanting_physician__r.MailingCity
                              , explanting_physician__r.MailingStateCode, explanting_physician__r.MailingPostalCode
                              , explanting_physician__r.Phone
                              , explanting_facility__r.Name, explanting_facility__r.Phone
                              , explanting_facility__r.ShippingStreet, explanting_facility__r.ShippingCity
                              , explanting_facility__r.ShippingStateCode, explanting_facility__r.ShippingPostalCode
                              , event_reason__c, Name, SerialNumber, InstallDate, oos_date__c
                              , Status
                             
                              FROM Asset WHERE Id = :ourAsset.Id
                             ];
        if (assets.size () > 0) {
            fullerAsset = assets[0];
        }
        
        List<complaint__c> complaints = [SELECT Id, doctors_letter_required__c
                                         , death_device_related__c, case__c 
                                         FROM complaint__c WHERE asset__c = :ourAsset.Id ORDER BY CreatedDate DESC LIMIT 1];
        if (complaints.size() > 0) {
            newestComplaint = complaints[0];
        }
        
        List<Case> cases = [SELECT Id, Contact.Name, Contact.Phone FROM Case WHERE Id = :newestComplaint.case__c];
        if (cases.size() > 0) {
            newestCase = cases[0];
        }
        
        List<complaint_relationships__c> furtherContacts =  [SELECT contact__r.FirstName, contact__r.MiddleName, contact__r.LastName
                                                             , contact__r.MailingStreet, contact__r.MailingCity, contact__r.MailingStateCode
                                                             , contact__r.Phone, contact__r.MailingPostalCode
                                                             , type_of_contact__c
                                                                FROM complaint_relationships__c 
                                                                WHERE complaint__c = :newestComplaint.Id 
                                                                AND type_of_contact__c IN ('Dr Letter Recipient')
                                            ];
        if (furtherContacts.size () > 0) {
            for (complaint_relationships__c cr : furtherContacts) {
                if (cr.type_of_contact__c == 'Dr Letter Recipient') {
                    drLetterRecipient = cr;
                }
            }
        }
        
        
        
    }
    
    public Asset getCurrentAsset () {
        return fullerAsset;
    }
    
    public String getOOSReason () {
        return fullerAsset.event_reason__c == null ? '' : fullerAsset.event_reason__c;
    }
    
    public complaint__c getNewestComplaint () {
        return newestComplaint;
    }
 
    public complaint_relationships__c getDLRecipient () {
        return drLetterRecipient;
    }
    public complaint_relationships__c getEventPhysician () {
        return eventPhysician;
    }
    public String getCurrUserName () {
        return UserInfo.getName();
    }

    public Case getNewestCase () {
        return newestCase;
    }

}