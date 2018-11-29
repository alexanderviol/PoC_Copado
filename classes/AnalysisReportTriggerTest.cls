@isTest
public with sharing class AnalysisReportTriggerTest {


    public static testMethod void testDuplicate() {

        Case c = TestDataFactory.createCase();
        insert c;

        complaint__c complaint = TestDataFactory.createComplaint(c.Id);
        complaint.RecordTypeId = [SELECT Id FROM RecordType WHERE SobjectType = 'complaint__c' AND DeveloperName = 'cardiomessenger_report' LIMIT 1].Id;
        insert complaint;

        Analysis_Report__c ar1 = new Analysis_Report__c();
        ar1.complaint__c = complaint.Id;
        ar1.RecordTypeId = [SELECT Id FROM RecordType WHERE SobjectType = 'Analysis_Report__c' AND DeveloperName = 'CAN_Analysis_Report' LIMIT 1].Id;
        ar1.conclusion_code__c = '110';

        insert ar1;

        // reset id and re-insert should result in an error
        String msg;
        ar1.Id = null;
        Test.startTest();
        try {
            insert ar1;
        }
        catch (DmlException e){
            msg = e.getDmlMessage(0);
        }
        Test.stopTest();

        System.assertEquals(AnalysisReportHandler.DUPLICATE_ANALYSIS_REPORT_ERROR, msg);
        System.assertEquals(1, [SELECT Id FROM Analysis_Report__c WHERE complaint__c =: complaint.Id].size());
    }

    public static testMethod void testNoDuplicate() {

        Case c = TestDataFactory.createCase();
        insert c;

        complaint__c complaint = TestDataFactory.createComplaint(c.Id);
        complaint.RecordTypeId = [SELECT Id FROM RecordType WHERE SobjectType = 'complaint__c' AND DeveloperName = 'cardiomessenger_report' LIMIT 1].Id;
        insert complaint;

        Analysis_Report__c ar1 = new Analysis_Report__c();
        ar1.complaint__c = complaint.Id;
        ar1.RecordTypeId = [SELECT Id FROM RecordType WHERE SobjectType = 'Analysis_Report__c' AND DeveloperName = 'CAN_Analysis_Report' LIMIT 1].Id;
        ar1.conclusion_code__c = '110';
        insert ar1;


        Analysis_Report__c ar2 = new Analysis_Report__c();
        ar2.complaint__c = complaint.Id;
        ar2.RecordTypeId = [SELECT Id FROM RecordType WHERE SobjectType = 'Analysis_Report__c' AND DeveloperName = 'CAN_Analysis_Report' LIMIT 1].Id;
        ar2.conclusion_code__c = '111';

        Test.startTest();
        insert ar2;
        Test.stopTest();

        System.assertEquals(2, [SELECT Id FROM Analysis_Report__c WHERE complaint__c =: complaint.Id].size());

    }

    public static testMethod void testDuplicateBulk() {

        Case c = TestDataFactory.createCase();
        insert c;

        complaint__c complaint = TestDataFactory.createComplaint(c.Id);
        complaint.RecordTypeId = [SELECT Id FROM RecordType WHERE SobjectType = 'complaint__c' AND DeveloperName = 'cardiomessenger_report' LIMIT 1].Id;
        insert complaint;

        Analysis_Report__c ar1 = new Analysis_Report__c();
        ar1.complaint__c = complaint.Id;
        ar1.RecordTypeId = [SELECT Id FROM RecordType WHERE SobjectType = 'Analysis_Report__c' AND DeveloperName = 'CAN_Analysis_Report' LIMIT 1].Id;
        ar1.conclusion_code__c = '110';

        Analysis_Report__c ar2 = new Analysis_Report__c();
        ar2.complaint__c = complaint.Id;
        ar2.RecordTypeId = [SELECT Id FROM RecordType WHERE SobjectType = 'Analysis_Report__c' AND DeveloperName = 'CAN_Analysis_Report' LIMIT 1].Id;
        ar2.conclusion_code__c = '111';

        insert new List<Analysis_Report__c>{ar1, ar2};

        // reset ids and re-insert should result in errors
        String msg;
        ar1.Id = null;
        ar2.Id = null;

        Test.startTest();
        List<Database.SaveResult> results =  database.insert(new List<Analysis_Report__c>{ar1, ar2}, false);
        Test.stopTest();

        System.assertEquals(2, [SELECT Id FROM Analysis_Report__c WHERE complaint__c =: complaint.Id].size());

        for(Database.SaveResult result : results){
            System.assertEquals(false, result.isSuccess());
            for(Database.Error err : result.getErrors()){
                System.assertEquals(AnalysisReportHandler.DUPLICATE_ANALYSIS_REPORT_ERROR, err.getMessage());
            }
        }

    }
}