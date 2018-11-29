/*
 * This class contain methods required display the selected documsnts.
 *  Created Date - April 8, 2018
 *  Created by   - susi
 *  
 * Revision History - 
 * Date             | Developer Name                | Version               | Changes/Ticket Number 
 * ================================================================================================      
 *  
 */
public with sharing class PrintDocumentController {
    public boolean renderMdrf{get;set;}
    public boolean renderSv{get;set;}
    public boolean renderPr{get;set;}
    public boolean renderDr{get;set;}
    public boolean renderPds{get;set;}
    public boolean renderOos{get;set;}
    public boolean renderTpid{get;set;}
    public boolean renderDc{get;set;}
    
    public PrintDocumentController() {
        try {
            renderMdrf = Boolean.valueOf(Apexpages.currentPage().getParameters().get('mdrf'));
            renderSv = Boolean.valueOf(Apexpages.currentPage().getParameters().get('sv'));
            renderPr = Boolean.valueOf(Apexpages.currentPage().getParameters().get('pr'));
            renderDr = Boolean.valueOf(Apexpages.currentPage().getParameters().get('dr'));
            renderPds = Boolean.valueOf(Apexpages.currentPage().getParameters().get('pds'));
            renderOos = Boolean.valueOf(Apexpages.currentPage().getParameters().get('oos'));
            renderTpid = Boolean.valueOf(Apexpages.currentPage().getParameters().get('tpid'));
            renderDc = Boolean.valueOf(Apexpages.currentPage().getParameters().get('dc'));
        } catch (Exception e) {
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR,e.getMessage());
            ApexPages.addMessage(myMsg);   
        }    
    }

    @AuraEnabled
    public static String insertFile(String url) {

        //Deleting content document
        string pathOnClient = 'MdrfDocs_' + UserInfo.getUserId() + '.pdf';
        List<ContentVersion> tempList = [Select ContentDocumentId from ContentVersion where pathOnClient =: pathOnClient];
        if(tempList != null && tempList.size() >0) {
            //Enforcing FLS
            if(!FLSEnforcer.isdeleteable('ContentDocument')) {
                throw new AuraHandledException(System.Label.NO_PERMISSION_TO_DELETE);
            }
            delete [Select id from ContentDocument where id =: tempList[0].ContentDocumentId];
        }

        PageReference pg = new PageReference(url);
        ContentVersion cv = new ContentVersion();
        
        //Enforcing FLS
        if(!FLSEnforcer.isCreatable('ContentVersion', new List<String>{'versionData', 'title', 'pathOnClient'})) {
            throw new AuraHandledException(System.Label.NO_CREATABLE_PERMISSION);
        }
        blob pdfBody;
        if(Test.isRunningTest()) { 
          pdfBody = blob.valueOf('Test');
        } else {
          pdfBody = pg.getContentAsPDF();
        }  
        cv.versionData = pdfBody;
        cv.title = 'MdrfDocs_' + UserInfo.getUserId() + '.pdf';
        cv.pathOnClient = 'MdrfDocs_' + UserInfo.getUserId() + '.pdf';
       
        try {
            insert cv;    
        } catch (Exception e) {
            throw e;   
        }  
        return [Select ContentDocumentId FROM ContentVersion WHERE id =: cv.id].ContentDocumentId;
    }
}