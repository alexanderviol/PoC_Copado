/**************************************************************************************************************
* Contact_SelectorTest - Test Class for Contact_Selector class
* @author Gokul Palagiri
* @CreatedDate -    11.10.2018
* Gokul Palagiri:   11.10.2018 : Initial Version
****************************************************************************************************************/
@IsTest
private class Contact_SelectorTest {
    static final String SALES_PROFILE = 'Sales';
    static Account objAccount;
    static Contact objContact;
    static user testUser;
    static Set<Id> contactIds = new Set<Id>();

    @IsTest
    private static void Test_getById(){
        if(contactIds.isEmpty()){createTestData();}
        List<Contact> sObjectContacts = new Contact_Selector().getById(contactIds, new Set<String>{Contact.Id.getDescribe().getName()});
        System.assert(sObjectContacts.size() > 0, 'Incorrect number of sObjects returned');

        List<Contact> sObjectContactsNull = new Contact_Selector().getById(new Set<Id>(), new Set<String>{Contact.Id.getDescribe().getName()});
        System.assertEquals(0, sObjectContactsNull.size(), 'Incorrect number of sObjects returned');
    }

    private static void createTestData() {
        Profile p = [SELECT Id, Name FROM Profile WHERE Name = :SALES_PROFILE];
        testUser = TestDataFactory.createUser(p.id);
        insert testUser;

        System.runAs(testUser) {
            objAccount = TestDataFactory.createAccount();
            insert objAccount;

            Id idPateintRecordType = [SELECT Id, Name, DeveloperName FROM RecordType WHERE Name = 'Patient'].Id;
            objContact = new Contact(firstname='TEST', lastname= 'CONTACT',
                    Birthdate = System.today().addYears(-29),
                    declined_to_provide_address__c = true,
                    declined_to_provide_phone__c = true,
                    declined_to_provide_ssn__c = true,
                    accountid = objAccount.Id,
                    recordTypeId = idPateintRecordType);
            insert objContact;
            contactIds.add(objContact.Id);
        }
    }


}