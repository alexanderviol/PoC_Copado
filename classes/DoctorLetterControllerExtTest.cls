/**
 * Test class for DoctorLetterController
 *
 * @author         emma
 * @created        2018-04-23
 * @modified       2018-08-14
 * @systemLayer    Test
 *
 **/
@isTest
public class DoctorLetterControllerExtTest {
    static DoctorLetterControllerExt ext;
    static Asset objAsset;
    static Account objAccount;
    static Case  cases;
    static complaint__c complaints;
    static list<asset> assetList = new list<asset>();

    private static void init(){
        cases = TestDataFactory.createCase();
        insert cases;

        objAccount = TestDataFactory.createAccount();
        insert objAccount;

        objAsset = TestDataFactory.createAsset(objAccount.id);
        assetList.add(objAsset);
        insert objAsset;

        complaints  = TestDataFactory.createComplaint(cases.id);
        complaints.recordtypeid = Utility.getRecordTypeId ('complaint__c', ComplaintHandler.OOS_COMPLAINT);
        complaints.asset__c = objAsset.id;
    }
    static testMethod void validateDoctorLettr(){
        init();

        PageReference pref = Page.DoctorLetter;
        pref.getParameters().put('id',complaints.id);
        Test.setCurrentPage(pref);
        ApexPages.StandardController con = new ApexPages.StandardController(complaints);

        Test.startTest();
        ext = new DoctorLetterControllerExt(con);
        Test.stopTest();

        System.debug('**'+ext.complaints.Id );
        System.assertEquals(ext.complaints.Id, complaints.Id);
    }
    static testMethod void validatePhysicianDetails(){
        init ();
        Contact physician = new Contact(FirstName = 'Doctor_01',
                                        LastName = 'First',
                                        Salutation = 'Dr.',
                                        RecordTypeId = Utility.getRecordTypeId(Contact.SObjectType, Constants.RECORD_TYPE_NAME_CONTACT_US_PHYSICIAN),
                                        MailingStreet ='Street flower',
                                        MailingPostalCode ='01069',
                                        MailingCity ='Dresden',
                                        MailingState = 'Florida',
                                        MailingCountry = 'United States',
                                        hmsc_registration__c = false,
                                        AccountId = objAccount.Id
                                       );
        insert physician;
        Complaint_Relationships__c compRelation = new Complaint_Relationships__c (complaint__c	= complaints.id,
                                                                                  type_of_contact__c = DoctorLetterControllerExt.DOCTOR_RECIPIENT,
                                                                                  contact__c = physician.Id);
        insert compRelation;

        PageReference pref = Page.DoctorLetter;
        pref.getParameters().put('id',complaints.id);
        Test.setCurrentPage(pref);
        ApexPages.StandardController con = new ApexPages.StandardController(complaints);

        Test.startTest();
        ext = new DoctorLetterControllerExt(con);
        Test.stopTest();
        system.debug('asd'+ext);

        list<Contact> contactDetails = [SELECT Id,
                                        	   Salutation,
                                        	   Name,
                                        	   MailingStreet, MailingPostalCode, MailingCity, MailingState,
                                        	   MailingCountry
                                  		From Contact
                                        where Id =:physician.Id];

        system.assertEquals(ext.physicianDetails, contactDetails);

    }

    static testMethod void validateAnalysisResult(){
        init ();
        
        List<string> result = new list<string>();

        case objCase = TestDataFactory.createCase();
        insert objCase;

        complaint__c cmp = TestDataFactory.createComplaint(objCase.id);
        cmp.recordtypeid =
            Utility.getRecordTypeId ('complaint__c', ComplaintHandler.OOS_COMPLAINT);
        cmp.asset__c = objAsset.id;
        insert cmp;

        Analysis_Report__c analysis = new Analysis_Report__c(complaint__c = cmp.id,
                                                             analysis_results__c = 'This is the text of the analysis report .... and ....',
                                                             RecordTypeId = Utility.getRecordTypeId('Analysis_Report__c', 'CAN_Analysis_Report'),
                                                             conclusion_code__c = '110');
        Analysis_Report__c analysis2 = new Analysis_Report__c(complaint__c = cmp.id,
                                                              analysis_results__c = 'This is the text of the analysis report2 .... and ....',
                                                              RecordTypeId = Utility.getRecordTypeId('Analysis_Report__c', 'FDA_EMDR_Response'),
                                                              conclusion_code__c = '110');
		
        List<Analysis_Report__c> lstAnalysis =  new List<Analysis_Report__c>{analysis, analysis2};
        
        insert lstAnalysis;
		
        PageReference pref = Page.DoctorLetter;
        pref.getParameters().put('id',cmp.id);
        Test.setCurrentPage(pref);
        ApexPages.StandardController con = new ApexPages.StandardController(cmp);

        Test.startTest();
        ext = new DoctorLetterControllerExt(con);
        Test.stopTest();

        system.debug('asd'+ext);

        for(Analysis_Report__c ans :lstAnalysis){
            if (ans.RecordTypeId == Utility.getRecordTypeId('Analysis_Report__c', 'CAN_Analysis_Report')){

            	result.add(ans.analysis_results__c);
            }
        }
        System.assertEquals(ext.analysis, result);
    }
    static testMethod void validateAttachement(){
        init();
        case objCase = TestDataFactory.createCase();
        insert objCase;

        complaint__c cmp = TestDataFactory.createComplaint(objCase.id);
        cmp.recordtypeid =
            Utility.getRecordTypeId ('complaint__c', ComplaintHandler.OOS_COMPLAINT);
        cmp.asset__c = objAsset.id;
        insert cmp;

        Attachment attach=new Attachment();
        attach.parentId=cmp.Id;
        attach.Name='Unit Test Attachment';
        Blob bodyBlob=Blob.valueOf('Unit Test Attachment Body');
        attach.body=bodyBlob;
        attach.ContentType = 'application/msword#DoctorLetter.doc';
        attach.IsPrivate = false;
        attach.Description = 'Test';
        insert attach;
        System.debug('Inserted: '+ attach.Id);

        PageReference pref = Page.DoctorLetter;
        pref.getParameters().put('id',cmp.id);
        system.debug('');
        Test.setCurrentPage(pref);
        ApexPages.StandardController con = new ApexPages.StandardController(cmp);

        Test.startTest();
        ext = new DoctorLetterControllerExt(con);
        Test.stopTest();

        List<Attachment> attachments=[select id, name, ContentType from Attachment where parent.id=:cmp.Id];
        System.assertEquals(1, attachments.size());

        String conType=[select id, name, ContentType from Attachment where parent.id=:cmp.Id].ContentType;
        System.assertEquals('application/msword#DoctorLetter.doc', conType);
    }
    static testMethod void validateGetError(){
     	init();
        case objCase = TestDataFactory.createCase();
        insert objCase;

        complaint__c cmp = TestDataFactory.createComplaint(objCase.id);
        cmp.recordtypeid =
            Utility.getRecordTypeId ('complaint__c', ComplaintHandler.OOS_COMPLAINT);
        cmp.asset__c = objAsset.id;
        insert cmp;
         Contact physician = new Contact(FirstName = 'Doctor_01',
                                        LastName = 'First',
                                        RecordTypeId = Utility.getRecordTypeId(Contact.SObjectType, Constants.RECORD_TYPE_NAME_CONTACT_US_PHYSICIAN),
                                        MailingStreet ='Street flower',
                                        MailingPostalCode ='01069',
                                        MailingCity ='Dresden',
                                        MailingState = 'Florida',
                                        MailingCountry = 'United States',
                                        hmsc_registration__c = false,
                                        AccountId = objAccount.Id
                                       );
        insert physician;
        Complaint_Relationships__c compRelation = new Complaint_Relationships__c (complaint__c	= cmp.id,
                                                                                  type_of_contact__c = DoctorLetterControllerExt.DOCTOR_RECIPIENT,
                                                                                  contact__c = physician.Id);
        insert compRelation;
        String msgReturn;
        Test.startTest();
        	msgReturn = DoctorLetterControllerExt.getErrorMsg(cmp.id);
        Test.stopTest();
        system.assertEquals(System.Label.DOCTOR_LETTER_CREATED, msgReturn);

    }


}