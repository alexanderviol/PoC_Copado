@isTest

public class TestPatient {
    @isTest static void TestInsertNewPatient(){
        RecordType rt = [SELECT id, name FROM RecordType where name = 'Physician'];
        Contact contph = new Contact(FirstName='Phy', LastName='Ba', Birthdate = Date.today()-2, sap_company_code__c = '5500',
                                   recordTypeId=rt.id, MailingCity = 'Dresden', MailingStreet = 'Res', MailingPostalCode = '11090',
                                   MailingCountryCode ='US',MailingStateCode='LA'
                 
                                  );
        insert contph;
        
        RecordType rtt = [SELECT id, name FROM RecordType where name = 'Patient'];
        Contact cont = new Contact(FirstName='Emna', LastName='Masmoudi', Birthdate = Date.today()-2, sap_company_code__c = '5500',
                                   recordTypeId=rtt.id, MailingCity = 'Dresden', MailingStreet = 'Res', MailingPostalCode = '11090',
                                   MailingCountryCode ='US',MailingStateCode='LA',
                                   declined_to_provide_phone__c = True,
                                   declined_to_provide_ssn__c = True,
                                   following_physician__c = contph.Id
                                  );
        insert cont;
        
        Test.startTest();
        String dateOfBirth = [SELECT Id,trig_dob__c From Contact where Id =:cont.Id ].trig_dob__c;
        System.assertEquals(dateOfBirth, string.ValueOf(Date.today()-2));
        Test.stopTest();
        

    }
}