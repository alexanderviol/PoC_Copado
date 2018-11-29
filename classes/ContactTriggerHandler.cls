public class ContactTriggerHandler {
    private static final String PENDING_HMSC_REGISTRATION = 'Pending HMSC Registration';
    private static final String PENDING_SAP_SUBMISSION = 'Pending SAP Submission';

    private static final String ACCOUNT_OBJECT_NAME = 'Account';
    private static Map<ID, Schema.RecordTypeInfo> rtMap = Schema.SObjectType.Contact.getRecordTypeInfosById();
    private static Map<ID, Schema.RecordTypeInfo> accountRtMap = Schema.SObjectType.Account.getRecordTypeInfosById();
    private static String UserCountryCode = [SELECT id, sap_company_code__c FROM User WHERE Id =: UserInfo.getUserId() LIMIT 1].sap_company_code__c;
    private static Id patientAccountRTId = Utility.getRecordTypeId(Constants.RECORD_TYPE_NAME_ACCOUNT_PATIENT);
    private static Id physicianAccountRTId = Utility.getRecordTypeId(Constants.RECORD_TYPE_NAME_ACCOUNT_PHYSICIAN);
    private static Id patientRTId = Utility.getRecordTypeId(Contact.sObjectType, Constants.RECORD_TYPE_NAME_CONTACT_US_PATIENT);
    private static Id physicianRTId = Utility.getRecordTypeId(Contact.sObjectType, Constants.RECORD_TYPE_NAME_CONTACT_US_PHYSICIAN);

    public static void onBeforeUpdate(Map<Id,Contact> newContactMap, Map<Id, Contact> oldContactMap) {
        resetPatientFlagsAfterIdCardCreation(newContactMap, oldContactMap);
        setPatientFlagAfterPhyPhoneChanged(newContactMap, oldContactMap);
        checkAndUpdateAccount(newContactMap, oldContactMap);
    }
    
    public static void onAfterUpdate(Map<Id,Contact> newContactMap, Map<Id, Contact> oldContactMap){
        updateHmscRegistration(newContactMap ,oldContactMap);
        changeAssetStatusValue(newContactMap);
        changeProductConsumedStatusValue(newContactMap);
    }

    private static void resetPatientFlagsAfterIdCardCreation(Map<Id,Contact> newContactMap, Map<Id, Contact> oldContactMap) {
        for(Contact con :newContactMap.values()) {
            if(rtMap.get(con.recordtypeId).getName() == 'Patient') {
                if(oldContactMap.get(con.id).patient_id_card_created__c != newContactMap.get(con.id).patient_id_card_created__c) {
                        con.following_physican_changed__c = false;
                        con.implanted_product_changed__c = false;
                        con.implanted_product_new_patient__c = false;
                        con.following_physician_phone_changed__c= false;
                        con.patient_name_changed__c = false;
                        con.implanted_product_qualified_promri__c = false;
                }
                //Added by Sumit || SAFBIO-1956
                if(oldContactMap.get(con.id).following_physician__c != newContactMap.get(con.id).following_physician__c) {
                    con.following_physican_changed__c = true;       
                }
                
                //Added by Sumit || To sync 'HMSC_Registration_StringVal__c' and 'hmsc_registration__c' field.
                if(oldContactMap.get(con.id).hmsc_registration__c != con.hmsc_registration__c)
                    con.HMSC_Registration_StringVal__c = (con.hmsc_registration__c == true) ? 'yes' : 'no';
      			else if(oldContactMap.get(con.id).HMSC_Registration_StringVal__c != con.HMSC_Registration_StringVal__c)
                	con.hmsc_registration__c = (con.hmsc_registration_stringval__c == 'yes') ? true : false;    
            }
        }  
    }
    
    private static void setPatientFlagAfterPhyPhoneChanged(Map<Id,Contact> newContactMap, Map<Id, Contact> oldContactMap){
        Set<Id> setPhysiciansUpdated = new Set<Id>();
        
        for(Contact con : newContactMap.values()) {
            if(oldContactMap.get(con.id).   Phone != newContactMap.get(con.id). Phone
                && rtMap.get(con.recordtypeId).getName() == 'Physician'){
                    
                    setPhysiciansUpdated.add(con.Id);
            }
        }
        
        List<Contact> lstPatientsToUpdate = [SELECT Id, following_physician_phone_changed__c 
                                                FROM Contact
                                                WHERE following_physician__c in :setPhysiciansUpdated];
        
        for(Contact patient :lstPatientsToUpdate){
            patient.following_physician_phone_changed__c = true;
        } 
        update lstPatientsToUpdate;
    }
    
    /*
     * --------------------------------------------------------------------------
     * Ticket number |   SAFBIO-611                                               
     * Updated by    |   emma
     * Date          |   17.05.2018                                               
     * Description   |   When a field in Patient record is updated a corresponding                 
     *               |   field in all the Patient related Asset and Product Item
     *               |   records should be updated.
     * --------------------------------------------------------------------------
     */
    
    /*
     * methode to get all assetrelated list from contact
     */
    private static map<id, list<asset>> getAssetsFromContact(List<String> contactId) {
        map<id,list<asset>> contactAssetMap = new map<id, list<asset>>();
        for(asset objAsset :  [SELECT patient__c,
                                      status
                               FROM   asset 
                               WHERE  patient__c IN : contactId]) {
                                   
                                   if(contactAssetMap.isEmpty() || !contactAssetMap.containsKey(objAsset.patient__c)) {
                                       contactAssetMap.put(objAsset.patient__c, new list<asset>{objAsset});
                                   } else {
                                       contactAssetMap.get(objAsset.patient__c).add(objAsset);
                                   }
                               }
        return contactAssetMap;
    }
    /*
     * methode to get all product consumed related list from contact
     */ 
    private static map<id, list<ProductConsumed>> getProductConsFromContact (List <string> contactId) {
        map<id, list<ProductConsumed>> productConsMap = new map<id,list<ProductConsumed>>();
        for (ProductConsumed prodConsObject : [Select patient__c,
                                                      status__c
                                               from   ProductConsumed
                                               where  patient__c IN : contactId ] ){
                                                  if(productConsMap.isEmpty() || !productConsMap.containsKey(prodConsObject.patient__c)) {
                                                      productConsMap.put(prodConsObject.patient__c, new list<ProductConsumed>{prodConsObject});
                                                  } else {
                                                      productConsMap.get(prodConsObject.patient__c).add(prodConsObject);
                                                  }
                                              }
        return productConsMap;
    }
    /*
     * use the asset related list to contact to change the status to Patient Deceased if a death occure 
     */ 
    
    private static void changeAssetStatusValue(Map<Id, Contact> newContactMap){
        
        List<Asset> assetToUpdate = new list <Asset>();
        List <String> contactIds = new List<string>();

        for (Contact cnt: newContactMap.values()) {
            contactIds.add(((String)(cnt.id)).trim());
        }
        map<id,list<asset>> assetMap = getAssetsFromContact(contactIds);
        
        for (Contact cn: newContactMap.values()) {
            try{
                if (((cn.date_of_death__c != null)||(cn.date_of_death_unknown__c == true))&& rtMap.get(cn.recordtypeId).getName() == 'Patient'){
                   
                    if(assetMap != null && assetMap.get(cn.Id) !=null){
                        for (Asset ast : assetMap.get(cn.Id)){  
                            ast.Status = 'Patient Deceased';
                            assetToUpdate.add(ast);
                        }
                    }
                }
            }catch(Exception e){
                System.debug('Error');
            }
        } 
        try{
            if (Schema.sObjectType.Asset.fields.Status.isUpdateable()) {
             update assetToUpdate;
            }
        }catch(Exception e){
            System.debug('Error');
        }
    } 
    /*
     * use the productconsumed related list to contact to change the status to Patient Deceased if a death occure 
     */ 
    private static void changeProductConsumedStatusValue(Map<Id, Contact> newContactMap){
        
        list<ProductConsumed> productsToUpdate = new list <ProductConsumed>();
        List <String> contactIds = new List<string>();

        for (Contact cnt: newContactMap.values()) {
            contactIds.add(((String)(cnt.id)).trim());
        }
        map<id,list<ProductConsumed>> prodConsumedMap = getProductConsFromContact(contactIds);
        
        for (Contact cn: newContactMap.values()) {

            try{
                if (((cn.date_of_death__c != null)||(cn.date_of_death_unknown__c == true))&& rtMap.get(cn.recordtypeId).getName() == 'Patient'){
                    if (prodConsumedMap !=null && prodConsumedMap.get(cn.Id) != null){
                        for(ProductConsumed prod :prodConsumedMap.get(cn.Id)){
                            prod.status__c = 'Patient Deceased';
                            productsToUpdate.add(prod);
                        } 
                    }                   
                }
            }catch(Exception e){
                System.debug('Error');
            }
        }
        try{
            if (Schema.sObjectType.ProductConsumed.fields.status__c.isUpdateable()) {
              update productsToUpdate;
            }
        }catch(Exception e){
            System.debug('Error');
        }

    } 
    
    /*
     * ---------------------------------------------------------------------------------
     * Ticket number |   SAFBIO-1450, SAFBIO-2141                                          
     * Updated by    |   Sumit
     * Date          |   July 30, 2018                                               
     * Description   |   Update patient account whenever patient record is updated
     * ---------------------------------------------------------------------------------
     */  
    public static void checkAndUpdateAccount(Map<Id,Contact> newContactMap, Map<Id,Contact> oldContactMap) { 
        List<Account> accountsToUpdate = new List<Account>();
        Map<Id, Contact> conMap = new map<Id, Contact>();

        for(Contact con : newContactMap.Values()) {
            if((con.recordTypeId == patientRTId || con.recordTypeId == physicianRTId) && con.AccountId <> null 
               && (con.firstName <> oldContactMap.get(con.Id).firstName || con.lastName <> oldContactMap.get(con.Id).lastName || con.sap_company_code__c <> oldContactMap.get(con.Id).sap_company_code__c))
                conMap.put(con.AccountId, con);                          
        }
        if(conMap != null && conMap.keySet().size() > 0) {
            for(Account acc : [SELECT id, name 
                               FROM Account 
                               WHERE Id IN : conMap.keySet()
                              AND (recordTypeId =: patientAccountRTId OR recordTypeId =: physicianAccountRTId)]) {
                acc.name = conMap.get(acc.id).FirstName + ' ' + conMap.get(acc.id).LastName + ((conMap.get(acc.id).recordTypeId == patientRTId) ? ' Patient' : ' Physician') + ' Account';
                accountsToUpdate.add(acc);  
            }    
        }
        if(!accountsToUpdate.isEmpty())
            update accountsToUpdate;
    }

    /* Florian Heer <f.heer@conciscon.de>
     * 2018-06-20
     * Creates an Account for each Patient
     */
    public static void checkAndAddAccount(Map<Id,Contact> newContactMap) {
        List<Account> accountsToInsert = new List<Account>();
        for(Contact con : newContactMap.values()) {
            if((con.recordTypeId == patientRTId || con.recordTypeId == physicianRTId) && (con.AccountId == null || con.created_by_flow__c == true )) {
                String recTypeId = (con.recordTypeId == patientRTId) ? patientAccountRTId : physicianAccountRTId ;  
				accountsToInsert.add(new Account(RecordTypeId = recTypeId, 
                                                 Name = con.FirstName + ' ' + con.LastName + ((con.recordTypeId == patientRTId) ? ' Patient' : ' Physician') + ' Account',
                                                 //Populating Sap Company code from Current login User || Added by Sumit
                                                 sap_company_code__c = UserCountryCode, 
                                                 status__c = 'Active' // FH 2018-07-03 added to satisfy new lookup-filter
                                    ));
            }                           
        }
        
        if(!accountsToInsert.isEmpty()) {
            List<AccountContactRelation> acrToUpdate = new List<AccountContactRelation>();
            //Selecing AccountContact Relations Record.
            for(AccountContactRelation acr : [SELECT id, contactId, AccountId, contact.created_by_flow__c FROM AccountContactRelation WHERE contactId IN : newContactMap.keyset()]) {
                if(acr.contact.created_by_flow__c == true) {
                	acr.Roles = 'Decision Maker';
                    acrToUpdate.add(acr);
                }
            }
            if(!acrToUpdate.isEmpty())
            	update acrToUpdate;

            //Inserting Accounts
            insert accountsToInsert;

            //Updating the contacts.
            List<Contact> contactsToUpdate = new List<Contact>();
            Integer ctr = 0;
            for(Contact con : [SELECT id, AccountId FROM Contact WHERE Id IN : newContactMap.keySet()]) {
				con.AccountId = accountsToInsert[ctr++].Id;
                contactsToUpdate.add(con);
            }
            if(!contactsToUpdate.isEmpty())
                update contactsToUpdate;
        }
    }
         /*
     * --------------------------------------------------------------------------
     * Ticket number |   SAFBIO-943
     * Updated by    |   Sumit
     * Date          |   12.06.2018                                               
     * Description   |   To delete account wherever patient is deleted 
     * --------------------------------------------------------------------------
     */
    public static void deleteAccount(List<Contact> oldContacts) {
        if(!oldContacts.isEmpty()) {
            Set<Id> accountsToDelete = new Set<Id>();
            for(Contact con : oldContacts)
                accountsToDelete.add(con.AccountId);
            
            if(FLSEnforcer.isdeleteable(ACCOUNT_OBJECT_NAME))
				delete [Select id FROM Account WHERE recordtype.developerName =: Constants.RECORD_TYPE_NAME_ACCOUNT_PATIENT AND Id  IN : accountsToDelete];
        }
    }

    /*
     * --------------------------------------------------------------------------
     * Ticket number |   SAFBIO-943
     * Updated by    |   ilu_pka - 05.07.2018
     * Updated by    |   Sumit - 09.19.2017 || SAFBIO-2005
     * Description   |   Update hmsc registration form patient to order
     * --------------------------------------------------------------------------
     */
    public static void updateHmscRegistration(Map<Id, Contact> mapNewCon, Map<Id, Contact> mapOldCon) {
        List<Order> ordersToUpdate = new List<Order>();
        for(Contact con : [SELECT id, 
								hmsc_registration__c,                           
                           	    (SELECT id, 
                                 	Status, 
                                 	date_cm_approved__c 
                                FROM Orders2__r
                                WHERE (status =: PENDING_HMSC_REGISTRATION OR status =: PENDING_SAP_SUBMISSION)
                                AND recordType.developerName =: Constants.RECORD_TYPE_NAME_ORDER_CARDIO_MESSENGER
                                ORDER BY Createddate DESC)
                           FROM Contact 
                           WHERE Id IN : mapNewCon.keySet()]) {
                               for(Order odr : con.Orders2__r) {
                                   if(mapOldCon <> null  && (mapOldCon.get(con.Id).hmsc_registration__c <> mapNewCon.get(con.Id).hmsc_registration__c)) {
                                       if(con.hmsc_registration__c == true && odr.status == PENDING_HMSC_REGISTRATION) {
                                            odr.date_cm_approved__c = Date.today();
                                            odr.status = PENDING_SAP_SUBMISSION; 
                                            ordersToUpdate.add(odr);
                                            break;
                                       }  else if (con.hmsc_registration__c == false && odr.status == PENDING_SAP_SUBMISSION) {
                                            odr.date_cm_approved__c = null;
                                            odr.status = PENDING_HMSC_REGISTRATION;
                                            ordersToUpdate.add(odr);
                                       } 
                                   }                
                               }
        }
        if(!ordersToUpdate.isEmpty())
            try {
				update ordersToUpdate;                     
            } catch(Exception e) {
                String exceptionMsg = e.getMessage();
                exceptionMsg = exceptionMsg.contains('FIELD_CUSTOM_VALIDATION_EXCEPTION') ? exceptionMsg.split(',')[1] : exceptionMsg;
                exceptionMsg = exceptionMsg.contains(':') ? exceptionMsg.split(':')[0] : exceptionMsg;
                mapNewCon.values()[0].addError(exceptionMsg);		    
           }
    }
    
}