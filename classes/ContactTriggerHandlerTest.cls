/* 
 *  Description  - Test class for ContactTriggerHandler 
 *  Created Date - 30.04.2018
 *  Created by   - ilum_pka
 */
/*
 * Updated by : emma
 * created date : 22.05.2018
 */ 
@isTest
public class ContactTriggerHandlerTest {
    static Account objAccount;
    static Contact objPatient;
    static Contact objPhysician;
    
     private static void init(){
        objAccount = TestDataFactory.createAccount();
        insert objAccount;
    }
	
    @isTest
    static void resetFlagsAfterIdCardCreation(){
        init();
        objPatient = TestDataFactory.createPatient(false,objAccount.Id);
        objPatient.patient_id_card_created__c = System.today();
        objPatient.implanted_product_changed__c = true;
        objPatient.following_physician_phone_changed__c = true;
        insert objPatient;       
        
        Test.startTest();
        	objPatient.patient_id_card_created__c = objPatient.patient_id_card_created__c.addDays(1);
        	update objPatient;
        Test.stopTest();
        
        objPatient = [SELECT Id, implanted_product_changed__c, implanted_product_new_patient__c, following_physician_phone_changed__c FROM Contact WHERE Id = :objPatient.Id];
        System.assertEquals(false, objPatient.implanted_product_changed__c);
        System.assertEquals(false, objPatient.implanted_product_new_patient__c);
        System.assertEquals(false, objPatient.following_physician_phone_changed__c);
    }
    
    @isTest
    static void setPatientFlagAfterPhyPhoneChange(){
        init();

        objPhysician = TestDataFactory.createPhysician(objAccount.Id);
        objPhysician.Birthdate = System.today().addYears(-29);
        objPhysician.Phone = '123456789';
        insert objPhysician;

        objPatient = TestDataFactory.createPatient(false,objAccount.Id);
        objPatient.following_physician__c = objPhysician.Id;
        insert objPatient;
        
        Test.startTest();
        	objPhysician.Phone = '987654321';
        	update objPhysician;
        Test.stopTest();
        
        objPatient = [SELECT Id, following_physician_phone_changed__c FROM Contact WHERE Id = :objPatient.id];
        System.assertEquals(true, objPatient.following_physician_phone_changed__c);
    }
    
    static testMethod void ValidateContactTriggerHandler(){

        Account account1 = TestDataFactory.createAccount();
        account1.Name = 'The account';
        insert account1;

        Contact phy = TestDataFactory.createPhysician(account1.id);
        phy.FirstName = 'Phy';
        phy.LastName = 'Ba';
        phy.sap_company_code__c = '5500';
        phy.MailingCity = 'Dresden';
        phy.MailingStreet = 'Res';
        phy.MailingPostalCode = '11090';
        insert phy;

        Contact patient = TestDataFactory.createPatient(false, account1.Id);
        patient.FirstName = 'Test';
        patient.LastName = 'CONTACTPatient';
        patient.sap_company_code__c = '0100';
        patient.following_physician__c = phy.Id;
        patient.date_of_death_unknown__c = false;
        insert patient;
        
        Test.startTest();

        Contact patientAssert = [SELECT Id, date_of_death_unknown__c from Contact where Id =:patient.Id];

        Asset objAsset = TestDataFactory.createAsset(account1.Id);
        objAsset.patient__c = patientAssert.Id;
        insert objAsset;

        patientAssert.date_of_death_unknown__c = true;
        update patientAssert;
        Test.stopTest();

        objAsset = [SELECT Id, status from Asset where Id=:objAsset.Id];
        System.debug('Asset status after the trigger :' +objAsset.status);
        System.assertEquals('Patient Deceased', objAsset.status);

    }
}