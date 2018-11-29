@IsTest
private class ProMRICalloutHelperTest {
    @IsTest
    static void testBehavior() {

        Product2 deviceProduct = new Product2();
        deviceProduct.Name = 'Testproduct';
        deviceProduct.sap_model_no__c = '123';
        deviceProduct.product_type__c = 'Pacemaker';
        insert deviceProduct;

        Product2 leadProduct = new Product2();
        leadProduct.Name = 'Testproduct';
        leadProduct.sap_model_no__c = '456';
        leadProduct.product_type__c = 'Lead';
        insert leadProduct;

        Account account = new Account();
        account.Name = 'Testaccount';
        account.status__c = 'Active';
        insert account;

        Contact patient = new Contact();
        patient.RecordTypeId = [SELECT Id FROM RecordType WHERE DeveloperName = : Constants.RECORD_TYPE_NAME_CONTACT_US_PATIENT LIMIT 1].Id;
        patient.FirstName = 'Tester';
        patient.LastName = 'Testcontact';
        patient.Birthdate = system.today().addYears(-29);
        patient.MailingCity = 'TestCity';
        patient.MailingCountryCode = 'US';
        patient.MailingStateCode = 'AK';
        patient.MailingStreet = 'TestStreet';
        patient.MailingPostalCode = 'Test123';
        patient.Phone = '1234';
        patient.ssn__c = '123456789';
        patient.sap_company_code__c = '5500';
        insert patient;

        Id assetRecType = Utility.getRecordTypeId(Asset.SObjectType, Constants.RECORD_TYPE_NAME_ASSET_US_BIOTRONIK);

        Asset deviceAsset = new Asset();
        deviceAsset.RecordTypeId = assetRecType;
        deviceAsset.Name = 'TestDevice';
        deviceAsset.Product2Id = deviceProduct.Id;
        deviceAsset.CurrencyIsoCode = 'USD';
        deviceAsset.AccountId = account.Id;
        deviceAsset.Status = 'Implanted';
        deviceAsset.patient__c = patient.Id;
        deviceAsset.product_type__c = 'Pacemaker';
        deviceAsset.manufacturer__c = 'BIOTRONIK';
        deviceAsset.SerialNumber = '9999';
        deviceAsset.udi__c = '123';
        insert deviceAsset;

        Asset leadAsset = new Asset();
        leadAsset.RecordTypeId = assetRecType;
        leadAsset.Name = 'TestLead';
        leadAsset.Product2Id = leadProduct.Id;
        leadAsset.CurrencyIsoCode = 'USD';
        leadAsset.AccountId = account.Id;
        leadAsset.Status = 'Implanted';
        leadAsset.patient__c = patient.Id;
        leadAsset.product_type__c = 'Lead';
        leadAsset.manufacturer__c = 'BIOTRONIK';
        leadAsset.SerialNumber = '9999';
        leadAsset.udi__c = '234';
        insert leadAsset;

        promri__c promri = new promri__c();
        promri.patient__c = patient.Id;
        insert promri;

        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new ProMRICalloutMock());
        ProMRICalloutHelper.futureMriCheck(new List<Id>{patient.Id});
        Test.stopTest();

        Contact testPatient = [SELECT mr_conditional_status__c, override_by_aps__c, reason_for_aps_override__c, promri_check_status__c, promri_check_date__c FROM Contact WHERE Id = :patient.Id LIMIT 1];

        system.debug(testPatient);
        system.debug(testPatient.promri_check_status__c);
        System.assertEquals(true, testPatient.mr_conditional_status__c);
        System.assertEquals(false, testPatient.override_by_aps__c);
        System.assert(String.isEmpty(testPatient.reason_for_aps_override__c), 'reason_for_aps_override__c is not empty: ' + testPatient.reason_for_aps_override__c);
        System.assertEquals('1', testPatient.promri_check_status__c);
        System.assertNotEquals(NULL, testPatient.promri_check_date__c);

        List<promri__c> promris = [SELECT Id FROM promri__c];
        System.assertEquals(4, promris.size());

    }

    public class ProMRICalloutMock implements HttpCalloutMock{


        public HttpResponse respond(HttpRequest req) {
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');
            res.setBody('[ {  "identifier": "4028b881568e818401568e872a6602c5",  "mrScannerCondition": {   "identifier": "4028b881568e818401568e8711864f99",   "exclusionZone": "FULL_BODY",   "specificAbsorptionRate": 4,   "magneticFieldStrength": 1.5,   "slewRate": 200  },  "serialNumberConstraint": null }, {  "identifier": "4028b881568e818401568e872ccb5780",  "mrScannerCondition": {   "identifier": "4028b881568e818401568e8711864f94",   "exclusionZone": "HIP_EYE",   "specificAbsorptionRate": 2,   "magneticFieldStrength": 3,   "slewRate": 200  },  "serialNumberConstraint": 66237095 }, {  "identifier": "4028b881568e818401568e872e10763d",  "mrScannerCondition": {   "identifier": "4028b881568e818401568e8711864f95",   "exclusionZone": "HIP_EYE",   "specificAbsorptionRate": 2,   "magneticFieldStrength": 3,   "slewRate": 125  },  "serialNumberConstraint": null }, {  "identifier": "4028b881568e818401568e87238516da",  "mrScannerCondition": {   "identifier": "4028b881568e818401568e8711864f98",   "exclusionZone": "HIP_EYE",   "specificAbsorptionRate": 2,   "magneticFieldStrength": 1.5,   "slewRate": 125  },  "serialNumberConstraint": 66237095 }]');
            res.setStatusCode(200);
            return res;

        }
    }
}