public with sharing class ProMRICalloutHelper {


    /*
     * Status	Text
     * 1	MR Conditional - Successful
     * 2	not MR Conditional -Product Combination not valid
     * 3	not MR Conditional - Competitor Product implanted
     * 4	not MR Conditional - No Country Code set
     * 5	Data Error – please proceed another check for details
     * 6	proMRI call failed - Webservice not available
     * 7	not MR Conditional - (Partially) Capped Lead/Device
     * 8	not MR Conditional - No Device implanted
     * 9	manual override by APS (set by Flow)
     */


    private static final String CONTACT_STATUS_DECEASED = 'Deceased';
    private static final String RECORDTYPE_DEVELOPERNAME_ASSET_COMPETITORPRODUCT = 'US_CompetitorAsset';
    private static final String METADATA_NAME_PROMRI_CRED = 'PROMRI_NAMEDCREDENTIAL';

    // @TODO SAP Company Code is actually a (numeric) string! casting to int removes leading zeroes what could cause side effects
    private static final Map <Integer, String> countryIsoCodeBySapCompanyCode = new Map <Integer, String>();

    @Future(Callout=true)
    public static void futureMriCheck(List<Id> contactIds) {
        doCheck(contactIds);
    }

    @InvocableMethod(Label='Instant ProMRI Check')
    public static void instantMriCheck(List<Id> contactIds) {
        doCheck(contactIds);
    }

    public static String doCheck(List<Id> contactIds) {

        for (country_code_mapping__mdt countryMapping : [
                SELECT
                        country_code__c,    // @TODO rename to sap_company_code__c
                        country_initials__c // @TODO rename to country_iso_code__c
                FROM
                        country_code_mapping__mdt
        ]) {
            countryIsoCodeBySapCompanyCode.put(integer.valueOf(countryMapping.country_code__c), countryMapping.country_initials__c);
        }


        Map<Id, List<Asset>> assetsByPatientIds = new Map<Id, List<Asset>>();
        for (Asset a : [
                SELECT Id,
                        Status,
                        Product2.sap_model_no__c,
                        Product2.product_type__c,
                        patient__r.shipping_country__c,
                        patient__r.Id,
                        patient__r.MailingCountryCode,
                        patient__r.sap_company_code__c,
                        RecordType.DeveloperName
                FROM Asset
                WHERE patient__c IN :contactIds AND Status IN (:Constants.IMPLANT_STATUS_IMPLANTED,
                        :Constants.IMPLANT_STATUS_CAPPED,
                        :Constants.IMPLANT_STATUS_PARTIALLYCAPPED)
        ]) {
            Id patientId = a.patient__c;
            if (!assetsByPatientIds.containsKey(patientId)) {
                assetsByPatientIds.put(patientId, new List<Asset>());
            }
            assetsByPatientIds.get(patientId).add(a);
        }

        List<promri__c> newPromris = new List<promri__c>();
        Map<Id, Contact> contactsById = new Map<Id, Contact>();

        for (Id patientId : contactIds) {

            HttpResponse response;
            List<Object> parsedResponse;

            Contact contact;
            if (assetsByPatientIds.containsKey(patientId) && assetsByPatientIds.get(patientId).size() > 0) {
                contact = assetsByPatientIds.get(patientId).get(0).Patient__r;
            } else {
                contact = new Contact(Id = patientId);
            }
            contact.promri_check_date__c = System.now();
            contact.mr_conditional_status__c = false;
            contact.override_by_aps__c = false;
            contact.reason_for_aps_override__c = '';

            contactsById.put(contact.Id, contact);

            List<Asset> assets = assetsByPatientIds.get(patientId);

            if (validatePatientData(contact, assets) == false) {
                continue;
            }

            assets = removeNotImplantedAssets(assets);

            // re-check if there are assets left after filtering
            // No Assets on patient -> Status 5
            if (assets.isEmpty()) {
                contact.promri_check_status__c = '5';
                continue;
            }

            try {

                /* Sample response:
                 * [ {  "identifier": "4028b881568e818401568e872a6602c5",  "mrScannerCondition": {   "identifier": "4028b881568e818401568e8711864f99",   "exclusionZone": "FULL_BODY",   "specificAbsorptionRate": 4,   "magneticFieldStrength": 1.5,   "slewRate": 200  },  "serialNumberConstraint": null }, {  "identifier": "4028b881568e818401568e872ccb5780",  "mrScannerCondition": {   "identifier": "4028b881568e818401568e8711864f94",   "exclusionZone": "HIP_EYE",   "specificAbsorptionRate": 2,   "magneticFieldStrength": 3,   "slewRate": 200  },  "serialNumberConstraint": 66237095 }, {  "identifier": "4028b881568e818401568e872e10763d",  "mrScannerCondition": {   "identifier": "4028b881568e818401568e8711864f95",   "exclusionZone": "HIP_EYE",   "specificAbsorptionRate": 2,   "magneticFieldStrength": 3,   "slewRate": 125  },  "serialNumberConstraint": null }, {  "identifier": "4028b881568e818401568e87238516da",  "mrScannerCondition": {   "identifier": "4028b881568e818401568e8711864f98",   "exclusionZone": "HIP_EYE",   "specificAbsorptionRate": 2,   "magneticFieldStrength": 1.5,   "slewRate": 125  },  "serialNumberConstraint": 66237095 }]
                 */
                response = mriSystemCallout(prepareCalloutParams(assets));

            } catch (Exception e) {
                // some unexpected error occured (timeout etc.) while doing the callout -> Status 6
                contact.promri_check_status__c = '6';
                continue;
            }


            if (response.getStatusCode() == 200) {

                if (String.isEmpty(response.getBody())) {
                    // empty response = check successful, but not proMRI ready -> Status 2
                    contact.promri_check_status__c = '2';

                    continue;
                }

                try {
                    parsedResponse = (List<Object>) JSON.deserializeUntyped(response.getBody());

                } catch (Exception e) {
                    // some unexpected error occured while unserializing JSON -> Status 6
                    contact.promri_check_status__c = '6';
                    continue;
                }

                // SAFBIO-2343 - HTTP 200 + empty json = not proMRI ready
                if (parsedResponse.isEmpty()) {
                    // empty JSON response = check successful, but not proMRI ready -> Status 2
                    contact.promri_check_status__c = '2';

                    continue;
                }

                //check successful, proMRI ready -> status 1
                contact.promri_check_status__c = '1';
                contact.mr_conditional_status__c = true;

                // create proMRI records
                for (Object o : parsedResponse) {
                    Map<String, Object> objectsByStrings = (Map<String, Object>) o;

                    promri__c promri = new promri__c();
                    promri.patient__c = patientId;
                    promri.promri_ready__c = true;
                    Map<String, Object> mrScannerCondition = (Map<String, Object>) objectsByStrings.get('mrScannerCondition');
                    Decimal fieldStrength = (Decimal) mrScannerCondition.get('magneticFieldStrength');
                    if (fieldStrength == 1.5) {
                        promri.field_strength__c = '1.5 T';
                    } else if (fieldStrength == 3) {
                        promri.field_strength__c = '3.0 T';
                    }
                    promri.isocenter_position__c = String.valueOf(mrScannerCondition.get('exclusionZone'));
                    promri.slewrate__c = (Decimal) mrScannerCondition.get('slewRate');
                    promri.whole_body_sar__c = (Decimal) mrScannerCondition.get('specificAbsorptionRate');
                    newPromris.add(promri);

                }
            } else {
                // unexpected HTTP status returned -> Status 6
                contact.promri_check_status__c = '6';
                continue;
            }

        }

        Savepoint sp = Database.setSavepoint();
        try {
            // remove old proMRI records
            deleteOldData(contactIds);
            // insert new proMRI records
            if (newPromris.size() > 0) {
                insert newPromris;
            }
            // update patient contacts
            update contactsById.values();
        } catch (Exception e) {
            database.rollback(sp);
        }
        return '';
    }

    private static void deleteOldData(List<Id> contactIds) {
        List<promri__c> oldPromris = [SELECT Id FROM promri__c WHERE patient__c IN :contactIds];
        if (oldPromris.size() > 0) {
            delete oldPromris;
        }
    }

    private static String prepareCalloutParams(List<Asset> assets) {

        String country = '';
        List<String> deviceSapNumbers = new List<String>();
        List<String> leadSapNumbers = new List<String>();

        for (Asset a : assets) {
            if (isDevice(a)) {
                deviceSapNumbers.add(a.Product2.sap_model_no__c);
            } else if (a.Product2 != null && !String.isBlank(a.Product2.product_type__c) &&
                    a.Product2.product_type__c.equals(Constants.PICKLIST_VALUE_PRODUCT_TYPE_LEAD)) {
                leadSapNumbers.add(a.Product2.sap_model_no__c);
            }
        }

        Contact patientContact = assets.get(0).patient__r;
        if (!countryIsoCodeBySapCompanyCode.isEmpty()
                && patientContact != null
                && patientContact.sap_company_code__c != null
                && countryIsoCodeBySapCompanyCode.containsKey(integer.valueOf(patientContact.sap_company_code__c))) {
            country = countryIsoCodeBySapCompanyCode.get(integer.valueOf(patientContact.sap_company_code__c));
        }

        String params = '?countryIsoCode=' + country;
        for (String s : deviceSapNumbers) {
            params += '&deviceSapNr=' + s;
        }
        for (String s : leadSapNumbers) {
            params += '&leadSapNr=' + s;
        }
        return params;
    }

    private static HttpResponse mriSystemCallout(String params) {
        HttpRequest request = new HttpRequest();
        request.setEndpoint('callout:' + getNamedCredentialNameProMRI() + '/system' + params);

        request.setMethod('GET');
        Http http = new Http();
        HttpResponse response = http.send(request);

        return response;
    }


    private static boolean validatePatientData(Contact contact, List<Asset> assets) {

        /*
         * 3	not MR Conditional - Competitor Product implanted
         * 4	not MR Conditional - No Country Code set
         * 5	Data Error – please proceed another check for details
         *      Patient should not be deceased
         *      Metadata Type ‘Country Code Mapping’ should have mappings for the SAP company code to Country Initials
         *      Related ‘Implanted’ Asset for this Patient with valid Product data. The product should contain sap Model No as this is sent in parameters for deviceSapNr or LeadSapNr
         * 7	not MR Conditional - (Partially) Capped Lead/Device
         * 8	not MR Conditional - No Device implanted
       */

        if (countryIsoCodeBySapCompanyCode.isEmpty()) {
            // Country Code Mapping table empty -> Status 5
            contact.promri_check_status__c = '5';
            return false;
        } else if (assets == NULL || assets.isEmpty()) {
            // No Assets on patient -> Status 5
            contact.promri_check_status__c = '5';
            return false;
        } else if (String.isBlank(contact.sap_company_code__c)) {
            // Missing SAP Company Code -> Status 4
            contact.promri_check_status__c = '4';
            return false;
        } else if (contact.Status__c == CONTACT_STATUS_DECEASED) {
            // patient deceased -> status 5
            contact.promri_check_status__c = '5';
            return false;
        }

        Boolean hasDeviceImplanted = false;

        for (Asset a : assets) {
            if (a.Status.equals(Constants.IMPLANT_STATUS_CAPPED) || a.Status.equals(Constants.IMPLANT_STATUS_PARTIALLYCAPPED)) {
                // Patient has a capped device/lead -> status 7
                contact.promri_check_status__c = '7';
                return false;
            }
            if (a.Status.equals(Constants.IMPLANT_STATUS_IMPLANTED) && a.RecordType.DeveloperName == RECORDTYPE_DEVELOPERNAME_ASSET_COMPETITORPRODUCT) {
                // Patient has an implanted competitor product -> status 3
                contact.promri_check_status__c = '3';
                return false;
            }
            if (a.Product2 == null || String.isBlank(a.Product2.sap_model_no__c)) {
                // patient has an asset without sap no
                contact.promri_check_status__c = '5';
                return false;
            }
            if (a.Status.equals(Constants.IMPLANT_STATUS_IMPLANTED) && isDevice(a)) {
                hasDeviceImplanted = true;
            }
        }

        if (!hasDeviceImplanted) {
            // patient has no implanted device -> status 8
            contact.promri_check_status__c = '8';
            return false;
        }

        return true;

    }

    private static List<Asset> removeNotImplantedAssets(List<Asset> assets) {
        List<Asset> filteredAssets = new List<Asset>();
        for (Asset a : assets) {
            if (a.Status.equals(Constants.IMPLANT_STATUS_IMPLANTED)) {
                filteredAssets.add(a);
            }
        }
        return assets;
    }

    private static Boolean isDevice(Asset a) {
        List<String> applicableCategories = new List<String>{
                Constants.VALI_CAT_DEVICE,
                Constants.VALI_CAT_LOOP_RECORDER
        };
        if (
                a.Product2 != null &&
                        !String.isBlank(a.Product2.product_type__c) &&
                        applicableCategories.contains(Utility.getValidationCategory(a.Product2.product_type__c))
                ) {
            return true;
        }
        return false;
    }


    private static String getNamedCredentialNameProMRI() {
        return  [SElECT Value__c FROM Setting__mdt WHERE DeveloperName = :METADATA_NAME_PROMRI_CRED LIMIT 1].Value__c;
    }
}