/*
 * Test class for PrintDocumentController
 *  Created Date - April 13, 2018
 *  Created by   - susi
 */
@isTest
private class PrintDocumentControllerTest {
    public static testMethod void testUpdatePrintDate() {
        initTestData();
        System.assertEquals(ApexPages.currentPage().getParameters().get('dr'), 'false');
    }
    
    private static testMethod void testInsertFile() {
        Account acc = TestDataFactory.createAccount();
        Order odr = TestDataFactory.createOrder(acc.id);
        
        ContentVersion cv = new ContentVersion();
        cv.versionData = blob.valueOf('Test');
        cv.title = 'MdrfDocs_' + UserInfo.getUserId() + '.pdf';
        cv.pathOnClient = 'MdrfDocs_' + UserInfo.getUserId() + '.pdf';
        insert cv;
        
        ContentVersion cVer = [Select id, title FROM ContentVersion where id =: cv.id];
        System.assertEquals(cVer.title, 'MdrfDocs_' + UserInfo.getUserId() + '.pdf');
        PrintDocumentController.insertFile('/apex/PrintPdfDocuments?id='+odr.id+'&mdrf=true&sv=true');      
    }
    
    private static void initTestData() {
        Test.setCurrentPageReference(new PageReference('Page.PrintDocuments'));
        System.currentPageReference().getParameters().put('mdrf', 'true');
        System.currentPageReference().getParameters().put('sv', 'true');
        System.currentPageReference().getParameters().put('pr', 'true');
        System.currentPageReference().getParameters().put('dr', 'false');
        System.currentPageReference().getParameters().put('pds', 'true');
        System.currentPageReference().getParameters().put('oos', 'false');
        System.currentPageReference().getParameters().put('tpid', 'true');
        System.currentPageReference().getParameters().put('dc', 'false');
        PrintDocumentController pdc = new PrintDocumentController();  
        System.assertEquals(ApexPages.currentPage().getParameters().get('dr'), 'false');
    }
}