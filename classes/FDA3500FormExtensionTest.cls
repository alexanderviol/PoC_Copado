/**
 * Test class for FDA3500FormExtension
 * 
 * @author            SNPA
 * @created           2018-10-26
 * @systemLayer       Test Class 
 *  
 */
@isTest
private class FDA3500FormExtensionTest {

    private static Complaint__c objComplaint;
    
    private static void init() {
        account objAccount = TestDataFactory.createAccount();
        insert objAccount;
        
        Asset objectAsset = TestDataFactory.createAsset(objAccount.id);
        insert objectAsset;
        
        Case objCase = TestDataFactory.createCase();
        insert objCase;
        
        objComplaint = TestDataFactory.createComplaint(objCase.id);
        objComplaint.asset__c = objectAsset.id;
        insert objComplaint;
        
        Analysis_Report__c analysisReport = TestDataFactory.createAnalysisReport(objComplaint.id);
        insert analysisReport;
        
        Analysis_Report__c analysisReportLatest = TestDataFactory.createAnalysisReport(objComplaint.id);
        analysisReportLatest.date_sent_to_fda__c = system.today().addDays(-1);
        insert analysisReportLatest;        
    }
    
    /**
     * Test method for FDA form creation
     *
     * @return     void    
     * @author     SNPA 
     */    
    private static testMethod void testFDAFormCreation() {
        init();
        
        test.startTest();
        ApexPages.StandardController sc = new ApexPages.StandardController(objComplaint);
        FDA3500FormExtension formExtension = new FDA3500FormExtension(sc);
        
        PageReference pageRef = Page.FDA3500Form;
        pageRef.getParameters().put('id',objComplaint.id );
        Test.setCurrentPage(pageRef);
        
        FDA3500FormExtension.attachAsPdf(objComplaint.Id);
        test.stopTest();
        
        ContentDocumentLink conDoc = [SELECT Id FROM ContentDocumentLink WHERE LinkedEntityId =:objComplaint.Id];
        system.assert(conDoc != null);
        system.assert(formExtension.complaint != null);
        system.assert(formExtension.analysisResult != null && formExtension.analysisResult.date_sent_to_fda__c == system.today().addDays(-1));       
        
    }
}