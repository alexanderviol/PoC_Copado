/**
 *
 * Handler for AssetTrigger
 * 
 * @author          snpa 
 * @modifiedBy      ilu_pkas
 * @created         2018-04-10
 * @modified        2018-08-30
 * @systemLayer     Handler 
 *  
*/
public class AssetHandler {

    /**
     * Method called on before insert of assets
     *
     * @param   newAssets, list with the new inserted asset records
     */
    public void onBeforeInsert(List<Asset> newAssets) {
        synchContactAndAccountFields(newAssets);
    }

    /**
     * Method called on after insert of assets
     *
    * @param    newAssetsById, map with the new inserted asset records
     */
    public void onAfterInsert(Map<Id, Asset> newAssetsById) {
        if(!newAssetsById.keySet().isEmpty()){
            updatePatientForNewProduct(newAssetsById);
            performProMRICheck(newAssetsById);
        }

    }

    /**
    * Method called on before update of assets
    *
    * @param    newAssets, list with the new inserted asset records
    */
    public void onBeforeUpdate(List<Asset> newAssets) {
        synchContactAndAccountFields(newAssets);
    }


    /**
     * Method called on after update of assets
     * 
     * @param   newAssetsById, map with the updated asset records
     * @param   oldAssetsById, map with the old values of the updated asset records
     */
    public void onAfterUpdate(Map<Id, Asset> newAssetsById, Map<Id, Asset> oldAssetsById) {
        if(!oldAssetsById.keySet().isEmpty()){
            updatePatientForNewProduct(newAssetsById, oldAssetsById);
            updatePatientForStatusChange(newAssetsById, oldAssetsById);
            performProMRICheck(newAssetsById, oldAssetsById);
            updateHMSCRegistrationForPatient(newAssetsById, oldAssetsById);
            updateMDRFReimportTimestamp(newAssetsById, oldAssetsById);
        }

    }

    /**
     * Method called on after deletion of assets
     * 
     * @param   oldAssetMap, map with the old values of the deleted asset records
     */
    public void onAfterDelete(Map<Id, Asset> oldAssetMap) {
        performProMRICheck(oldAssetMap);
    }


    /**
     * To update 'MDRF reimport timestamp field on Order. || SAFBIO-1311
     * 
     * @param   newAssetMap, map with the updated asset records
     * @param   oldAssetMap, map with the old values of the updated asset records
     * 
     * @author  Sumit
     */
    public void updateMDRFReimportTimestamp(Map<Id, Asset> newAssetsById, Map<Id, Asset> oldAssetsById) {
        Set<Id> orderIds = new Set<Id>();
//        Map<Id, Asset> assetMap = new Map<Id,Asset>([SELECT id, order_product__r.OrderId FROM Asset WHERE Id IN : newAssetsById.keySet()]);
        Map<Id, Asset> assetMap = new Map<Id,Asset>(new Asset_Selector().getById(newAssetsById.keySet()
                , new Set<String>{
                        Asset.Id.getDescribe().getName(),
                        Asset.order_product__c.getDescribe().getRelationshipName() +'.'+OrderItem.OrderId.getDescribe().getName(),
                        Asset.order_product__c.getDescribe().getName()
                }));
        for (Asset asst : newAssetsById.values()) {
            Asset oldAsset = oldAssetsById.get(asst.Id);
            if (asst.ous_asset__c == false
                    && asst.product_type__c == Constants.VALI_CAT_LEAD
                    && (oldAsset.sap_company_code__c <> asst.sap_company_code__c
                    || oldAsset.manufacturer__c <> asst.manufacturer__c
                    || oldAsset.model_no__c <> asst.model_no__c
                    || oldAsset.SerialNumber <> asst.SerialNumber
                    || oldAsset.InstallDate <> asst.InstallDate
                    || oldAsset.brady_channel__c <> asst.brady_channel__c
                    || oldAsset.Tachy_Channel__c <> asst.Tachy_Channel__c
                    || oldAsset.Explant_Date__c <> asst.Explant_Date__c
                    || oldAsset.AccountId <> asst.AccountId
                    || oldAsset.patient__c <> asst.patient__c
                    || oldAsset.status <> asst.status
                    || oldAsset.Lead_Tip_Location__c <> asst.Lead_Tip_Location__c
                    || oldAsset.Name <> asst.Name
                    || oldAsset.Product2Id <> asst.Product2Id)) {
                if(assetMap.get(asst.Id).order_product__c != null && assetMap.get(asst.Id).order_product__r.OrderId != null ) {
                    orderIds.add(assetMap.get(asst.Id).order_product__r.OrderId);
                }
            }
        }
        if (orderIds != null && orderIds.size() > 0) {
            List<Order> orderListToUpdate = new List<Order>();
//            for (Order odr : [SELECT Id, mdrf_reimport_timestamp__c FROM Order WHERE Id IN :orderIds]) {
            for (Order odr : new Order_Selector().getById(orderIds, new Set<String>{
                    Order.Id.getDescribe().getName(),
                    Order.mdrf_reimport_timestamp__c.getDescribe().getName()})) {
                odr.mdrf_reimport_timestamp__c = Datetime.now();
                orderListToUpdate.add(odr);
            }
            if (orderListToUpdate != null && orderListToUpdate.size() > 0 && FLSEnforcer.isUpdatable('Order', new List<String>{'mdrf_reimport_timestamp__c'})) {
                update orderListToUpdate;
            }
        }
    }

    /**
     * Whenever ICD OR Pacemaker device status changes from 'implanted' to 'explanted', update Patient_HMSC_Registration to FALSE.
     * 
     * SAFBIO-1678
     * 
     * @param   newAssetsById, map with the updated asset records
     * @param   oldAssetsById, map with the old values of the updated asset records
     * 
     * @author  Sumit
     */
    public void updateHMSCRegistrationForPatient(Map<Id, Asset> newAssetsById, Map<Id, Asset> oldAssetsById) {
        List<Contact> conListToUpdate = new List<Contact>();
        Set<Id> conIdSet = new Set<Id>();
        for (Asset asst : newAssetsById.values()) {
            Asset oldAsset = oldAssetsById.get(asst.Id);
            if ((Utility.getValidationCategory(asst.product_type__c) == Constants.VALI_CAT_DEVICE)
                && oldAsset.Status == Constants.IMPLANT_STATUS_IMPLANTED
                && asst.status != Constants.IMPLANT_STATUS_IMPLANTED
                && (asst.Status != oldAsset.Status) && asst.patient__c != null) {
                conIdSet.add(asst.patient__c);
            }
        }
//        for (Contact con : [SELECT Id, hmsc_registration__c, HMSC_Registration_StringVal__c FROM Contact WHERE Id IN :conIdSet]) {
        for (Contact con : new Contact_Selector().getById(conIdSet, new Set<String>{
                Contact.Id.getDescribe().getName(),
                Contact.hmsc_registration__c.getDescribe().getName(),
                Contact.HMSC_Registration_StringVal__c.getDescribe().getName()})) {
            con.HMSC_Registration_StringVal__c = 'no';
            conListToUpdate.add(con);
        }
        if (conListToUpdate != null && conListToUpdate.size() > 0) {
            update conListToUpdate;
        }
    }

    /**
     * Method called on before delete of assets
     * 
     * @param   oldAssetsById, map with the old values of the deleted asset records
     */
    public void onBeforeDelete(Map<Id, Asset> oldAssetsById) {
        // Do not check on system-Assets for now.
        // Deletion of these may be restricted later, but on different criteria
        Map<Id, Asset> filteredAssetsById;
//        List<Asset> assets = [SELECT Id FROM Asset WHERE Id IN :oldAssetsById.values() AND RecordType.DeveloperName = :Constants.RECORD_TYPE_NAME_ASSET_SYSTEM];
        List<Asset> assets = new Asset_Selector().getByIdAndRecordTypeName(oldAssetsById.keySet(), new Set<String>{Constants.RECORD_TYPE_NAME_ASSET_SYSTEM}, new Set<String>{Asset.Id.getDescribe().getName()});
        if (assets.size() > 0) {
            filteredAssetsById = new Map<Id, Asset>();
            for (Asset a : oldAssetsById.values()) {
                if (assets.contains(a)) {
                    filteredAssetsById.put(a.Id, a);
                }
            }
        } else {
            filteredAssetsById = oldAssetsById;
        }
        checkForSalesFcsDeletion(filteredAssetsById);
    }

    /**
     * Flaggs the patients if their got a new ICD or Pacemaker
     * 
     * @param   newAssetsById, map containing all updated asset records by Id
     */
    private void updatePatientForNewProduct(Map<Id, Asset> newAssetsById) {
        Set<Id> patientContactIds = new Set<Id>();

        for (Asset asst : newAssetsById.values()) {
            if (asst.patient__c != null
                    && Utility.getValidationCategory(asst.product_type__c) == Constants.VALI_CAT_DEVICE) {
                patientContactIds.add(asst.patient__c);
            }
        }

//        List<Contact> patientContacts = [SELECT Id, implanted_product_new_patient__c, implanted_product_changed__c FROM Contact WHERE Id IN :patientContactIds];
        List<Contact> patientContacts = new Contact_Selector().getById(patientContactIds, new Set<String>{
                Contact.Id.getDescribe().getName(),
                Contact.implanted_product_new_patient__c.getDescribe().getName(),
                Contact.implanted_product_changed__c.getDescribe().getName()});
        for (Contact con : patientContacts) {
            con.implanted_product_new_patient__c = true; // SAFBIO-838
            con.implanted_product_changed__c = true; // SAFBIO-839
        }
        if (!patientContacts.isEmpty()) {
            update patientContacts;
        }
    }

    /**
     * Flaggs the patients if their got a new ICD or Pacemaker
     * 
     * @param   newAssetsById, containing all updated asset records by Id
     * @param   oldAssetsById, containing all old valuesfor the updated asset records by Id
     */
    private void updatePatientForNewProduct(Map<Id, Asset> newAssetsById, Map<Id, Asset> oldAssetsById) {
        Map<Id, Asset> filteredAssetsById = new Map<Id, Asset>();
        for (Asset asst : newAssetsById.values()) {
            if (asst.patient__c != oldAssetsById.get(asst.Id).patient__c) {
                filteredAssetsById.put(asst.Id, asst);
            }
        }
        updatePatientForNewProduct(filteredAssetsById);
    }

    /**
     * Flaggs the patients if the status changed on a related asset
     * 
     * @param   newAssetsById, containing all updated asset records by Id
     * @param   oldAssetsById, containing all old valuesfor the updated asset records by Id
     */
    private void updatePatientForStatusChange(Map<Id, Asset> newAssetsById, Map<Id, Asset> oldAssetsById) {
        Set<Id> patientContactIds = new Set<Id>();

        for (Asset asst : newAssetsById.values()) {
            if (asst.patient__c != null
                    && Utility.getValidationCategory(asst.product_type__c) == Constants.VALI_CAT_DEVICE
                    && asst.Status != oldAssetsById.get(asst.Id).Status) {
                patientContactIds.add(asst.patient__c);
            }
        }

//        List<Contact> patientContacts = [SELECT Id, implanted_product_new_patient__c, implanted_product_changed__c FROM Contact WHERE Id IN :patientContactIds];
        List<Contact> patientContacts = new Contact_Selector().getById(patientContactIds, new Set<String>{
                Contact.Id.getDescribe().getName(),
                Contact.implanted_product_new_patient__c.getDescribe().getName(),
                Contact.implanted_product_changed__c.getDescribe().getName()});
        for (Contact con : patientContacts) {
            con.implanted_product_changed__c = true; // SAFBIO-839
        }
        if (!patientContacts.isEmpty()) {
            update patientContacts;
        }
    }

    /**
     * Triggers a proMRI check if needed for updated assets
     *
     * @param   newAssetsById, containing all updated asset records by Id
     * @param   oldAssetsById, containing all old valuesfor the updated asset records by Id
     */
    private void performProMRICheck(Map<Id, Asset> newAssetsById, Map<Id, Asset>oldAssetsById) {
        Set<Id> productIds = new Set<Id>();
        for (Asset newAsset : newAssetsById.values()) {
			if(newAsset.Product2Id != null){
				productIds.add(newAsset.Product2Id);
			}
        }

//        Map<Id, Product2> product2sById = new Map<Id, Product2>([SELECT Id, product_type__c FROM Product2 WHERE Id IN :productIds]);
        List<Product2> product2s = new Product2_Selector().getById(productIds, new Set<String>{
                Product2.Id.getDescribe().getName(),
                Product2.product_type__c.getDescribe().getName()});
        Map<Id, Product2> product2sById = (product2s.isEmpty() || product2s.size() == 0 ) ? new Map<Id, Product2>() : new Map<Id, Product2>(product2s);

        List<Id> patientContactIds = new List<Id>();

        for (Asset newAsset : newAssetsById.values()) {

            Asset oldAsset = oldAssetsById.get(newAsset.Id);

            // no relevant data have changed - skip
            if ((newAsset.Status == oldAsset.Status) && (newAsset.patient__c == oldAsset.patient__c)) {
                continue;
            }

            Product2 product;
            if (newAsset.Product2Id != null && product2sById.containsKey(newAsset.Product2Id)) {
                product = product2sById.get(newAsset.Product2Id);
            }

            if (proMRICheckNeeded(newAsset, product)) {

                if (newAsset.patient__c != null) {
                    patientContactIds.add(newAsset.patient__c);
                }
                if (newAsset.patient__c != oldAsset.patient__c && oldAsset.patient__c != null) {
                    patientContactIds.add(oldAsset.patient__c);
                }
            }
        }

        if (patientContactIds.size() > 0 && !Test.isRunningTest()) {
            ProMRICalloutHelper.futureMriCheck(patientContactIds);
        }
    }


    /**
     * Triggers a proMRI check if needed for created/deleted assets
     *
     * @param   assetsByIds, containing all asset records by Id
     */
    private void performProMRICheck(Map<Id, Asset> assetsByIds) {
        if(assetsByIds.keySet().isEmpty()){return;}
        Set<Id> productIds = new Set<Id>();
        for (Asset asset : assetsByIds.values()) {
            if(asset.Product2Id != null){
                productIds.add(asset.Product2Id);
            }
        }
//        Map<Id, Product2> product2sById = new Map<Id, Product2>([SELECT Id, product_type__c FROM Product2 WHERE Id IN :productIds]);
        List<Product2> product2s = new Product2_Selector().getById(productIds, new Set<String>{
                Product2.Id.getDescribe().getName(),
                Product2.product_type__c.getDescribe().getName()});
        Map<Id, Product2> product2sById = (product2s.isEmpty() || product2s.size() == 0 ) ? new Map<Id, Product2>() : new Map<Id, Product2>(product2s);
        List<Id> patientContactIds = new List<Id>();
        for (Asset asset : assetsByIds.values()) {

            Product2 product;
            if (asset.Product2Id != null && product2sById.containsKey(asset.Product2Id)) {
                product = product2sById.get(asset.Product2Id);
            }

            if (proMRICheckNeeded(asset, product)) {
                patientContactIds.add(asset.patient__c);
            }
        }
        if (patientContactIds.size() > 0 && !Test.isRunningTest()) {
            ProMRICalloutHelper.futureMriCheck(patientContactIds);
        }
    }

    private void checkForSalesFcsDeletion(Map<Id, Asset> oldAssetsById) {
        /* SAFBIO-914 - More clarifcation needed - by F.Heer
        if(isUserCasOrCs())
            return;
        
        for(Asset asst :oldAssetsById.values()){
            if(asst.order__r.status != ORDERSTATUS_NOTSUBMITTED){
                asst.addError('Deletion of this asset is not allowed, depending on the order status');
            }
        }
    
    private boolean isUserCasOrCs(){
        Id idUser = UserInfo.getUserId();
        User usrCurrent = [SELECT Id, UserRole.DeveloperName FROM User WHERE Id = :idUser];
        
        Boolean bResult = usrCurrent.UserRole.DeveloperName == 'BINC_Customer_Solutions' || usrCurrent.UserRole.DeveloperName == 'BINC_Sales_Operations';
        
        return bResult;
    }
        */
    }


    /**
     * Make sure Contact and Account are filled correctly.
     * Contact just needs to contain the data of patient__c, Account is either the
     * implanting facility or the explanting facility.
     * 
     * @param   newAssets, list of assets which should be updated
     */
    public void synchContactAndAccountFields(List<Asset> newAssets) {
        for (Asset ass : newAssets) {

            if (ass.patient__c != null) {
                ass.ContactId = ass.patient__c;
            }

            //To populate HMSC_External_Id__c field, SAFBIO-1045
            if (ass.SerialNumber != null) {
                ass.serialnumber_external_id__c = ass.SerialNumber;
            }

            //To populate cm_active__c field, SAFBIO-1045
            if (ass.termination_date__c <> null) {
                ass.cm_active__c = false;
            } else if (ass.last_med_message__c <> null) {
                ass.cm_active__c = true;
            }
        }
    }


    /**
     * Helper Method to check if a proMRI check is required for an asset
     *
     * @param   asset, Asset to be checked
     * @param   product, product to be checked against
     */
    private Boolean proMRICheckNeeded(Asset asset, Product2 product) {

        if (String.isBlank(asset.Status)) {
            return false;
        }
        if (asset.patient__c == null) {
            return false;
        }
        if (product == null) {
            return proMRICheckNeededForProductType(asset.product_type__c);
        } else {
            return proMRICheckNeededForProductType(product.product_type__c);
        }
    }

    /**
     * Helper Method to check if a proMRI check is required for an asset
     *
     * @param   productType, productType of asset or product to be checked
     */
    private Boolean proMRICheckNeededForProductType(String productType) {

        if (String.isBlank(productType)) {
            return false;
        }
        List<String> applicableValidationCategories = new List<String> {
            Constants.VALI_CAT_DEVICE, Constants.VALI_CAT_LEAD, Constants.VALI_CAT_SYSTEM, Constants.VALI_CAT_LOOP_RECORDER
        };
        return applicableValidationCategories.contains(Utility.getValidationCategory(productType));
    }

}