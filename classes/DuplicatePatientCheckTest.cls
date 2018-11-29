/**************************************************************************************************************
* DuplicatePatientCheckTest - Test Class for DuplicatePatientCheck class
* @author Gokul Palagiri
* @CreatedDate -    18.10.2018
* Gokul Palagiri:   18.10.2018 : Initial Version
****************************************************************************************************************/

@isTest
private class DuplicatePatientCheckTest {
    @isTest
    private static void Test_getDuplicateContacts(){
        List<Contact> contactList = new List<Contact>();
        List<String> testResult;
        Contact objContact = new Contact();
        Account objAccount = TestDataFactory.createAccount();
        insert objAccount;
        Id idPateintRecordType = [SELECT Id, Name, DeveloperName FROM RecordType WHERE Name = 'Patient'].Id;
        objContact = new Contact(firstname='TEST', lastname= 'TEST_CONTACT',
                Birthdate = System.today().addYears(-72),
                declined_to_provide_address__c = true,
                declined_to_provide_phone__c = true,
                ssn__c = '123456789',
                accountid = objAccount.Id,
                recordTypeId = idPateintRecordType);
        insert objContact;
        contactList.add(objContact);

        testResult = DuplicatePatientCheck.getDuplicateContacts(contactList);
        System.assertEquals(testResult[0], '0', 'Incorrect value returned, check if patient duplicate rule exists before running this test');
    }

}