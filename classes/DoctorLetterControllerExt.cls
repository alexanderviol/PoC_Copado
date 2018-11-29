/**
 * Controller to generate Doctors Letter file
 *
 * @author         emma
 * @created        2018-04-23
 * @systemLayer    Controller | Extension
 *
 **/
public with sharing class DoctorLetterControllerExt {

    public static final String DOCTOR_RECIPIENT = 'Dr Letter Recipient';
    public complaint__c complaints{get;set;}
    
    public boolean renderPanel{get;set;}
    public Date currentDate{get; set;}
    public String contentType{get; set;}
    
    public List<String> analysis {get;set;}
    public list<Contact> physicianDetails {get;set;}
    public Integer nbr{get; set;}
    
    //Labels for the template, so we can translate them.
    public String doctorLetterContent{get;set;}
    public String doctorLetterWarrantyContent{get;set;}
    public String doctorLetterWarrantyContentpart2{get;set;}
    public String patientName{get;set;} 
    public String explantDate{get;set;}
    public String implantDate{get;set;}
    public String deviceDescription{get;set;}
    public String reasonForAnalysis{get;set;}
    public String dear{get;set;}
    public String introduction{get;set;}
    public String sincerely {get;set;}
    public String salesRepresentative {get;set;}
    public String areaSalesDirector {get;set;}
    public String areaSalesVicePresident {get;set;}
    public String content {get;set;}
	public String msgLabel {get;set;}
	public String titleLabel {get;set;}
    /* 
	 * Standard controller / Constructor
	 */
    public DoctorLetterControllerExt(ApexPages.StandardController controller) {
		complaints = (complaint__c)controller.getRecord();
        Id idcom = complaints.Id;
       
        renderPanel = false;
        currentDate = sysdate();
        
        doctorLetterContent = System.Label.DOCTOR_LETTER_CONTENT;
        doctorLetterWarrantyContent = System.Label.DOCTOR_LETTER_WARRANTY_CONTENT;
        doctorLetterWarrantyContentpart2= System.Label.DOCTOR_LETTER_WARRANTY_CONTENT_2;
        patientName = System.Label.Patient_Name;
        explantDate = System.Label.Explant_Date;
        implantDate = System.Label.IMPLANT_DATE;
        deviceDescription = System.Label.Device_Description;
        reasonForAnalysis = System.Label.Reason_for_Analysis;
        dear = System.Label.dear_contact;
        introduction = System.Label.intoduction_to_device_description;
        sincerely = System.Label.sincerely;
        salesRepresentative = System.Label.Sales_Representative;
        areaSalesDirector = System.Label.Area_Sales_Director;
        areaSalesVicePresident = System.Label.Area_Sales_Vice_President;
        content = System.Label.content;
        msgLabel = System.Label.DOCTOR_LETTER_CREATED;
        titleLabel = System.Label.DOCTOR_LETTER_CREATION_PROCCES;
        
        
		//display analysis results
        map <Id,List<Analysis_Report__c>> analysisMap = new map <Id,List<Analysis_Report__c>>();
        analysisMap = getAnalysisFromComplaints(idcom);
        if (analysisMap.size() > 0){
            analysis = getListOfAnalysis(analysisMap.containsKey(idcom)?analysisMap.get(idcom) : null);
        }else{
            String msg = 'No Analysis available';
            list<String> noAnalysis = new list<String>{msg};
            analysis= noAnalysis;
        }
        
        //display the physician info (name and address)
        Set<Id> RecipientIdSet = new Set<Id>();
        try {
        	RecipientIdSet = getDoctorRecipients(idcom);
            physicianDetails = getPhysiciansDetails(RecipientIdSet);    
			nbr = physicianDetails.size();
        }catch(Exception e) {
           System.debug('Error'); 
        }  
    }

    //Current date  
    private Date sysdate(){
        Date today = Date.today();
        return today;
    }
    
    /**
     * Method to get all Ids physician with contact type DOCTOR_RECIPIENT 
     * from Complaint_Relationships__c
     * 
     * @param     complaint Id
     * @return    Set<Id>(contact)
     * @author    emma
     *
     **/
    @TestVisible
     private static Set<Id> getDoctorRecipients (Id complaintId){
    	Set <Id> physicianIdSet = new Set<Id>();
        for (Complaint_Relationships__c complaintsRelationship: [SELECT Id, 
                                                                 type_of_contact__c,
                                                                 complaint__c,
                                                                 contact__c
                                                                 FROM Complaint_Relationships__c
                                                                 WHERE
                                                                 complaint__c =:complaintId
                                                                 AND 
                                                                 type_of_contact__c =: DOCTOR_RECIPIENT]){   
                                                                     
                                physicianIdSet.add(complaintsRelationship.contact__c);
       } 
        return physicianIdSet;
    }
    
    
    /**
     * Method to get contact details needed for the template mapping
     * @param     Set<Id> (Contact)
     * @return    list<contact>
     * @author    emma
     *
     **/
    
    private list<Contact> getPhysiciansDetails (Set<Id> physicianIdSet){
        list <Contact> contactList = new list<Contact>();
        for (Contact contacts : [SELECT Id, 
                                 Name,
                                 Salutation,
                                 MailingStreet, 
                                 MailingPostalCode, 
                                 MailingCity, 
                                 MailingState, 
                                 MailingCountry
                                 FROM
                                 Contact
                                 WHERE
                                 Id IN : physicianIdSet]){
                                     contactList.add(contacts);  
                                 }
        return contactList;
    }
    
    /**
     * Helper Method,This map is to get all analysis report from the complaint
     * @param     complaint Id
     * @return    Map
     * @author    emma
     *
     **/
    private map <Id,List<Analysis_Report__c>> getAnalysisFromComplaints (Id complaintId){
        map <Id,List<Analysis_Report__c>> analysisReportMap = new map <Id,List<Analysis_Report__c>>();
        for (Analysis_Report__c analysisReportList : [SELECT Id, 
                                                      analysis_results__c,
                                                      complaint__c
                                                      FROM
                                                      Analysis_Report__c
                                                      WHERE
                                                      complaint__c =:complaintId
                                                      AND recordTypeId =:Utility.getRecordTypeId('Analysis_Report__c', 'CAN_Analysis_Report')
                                                      ORDER BY Id DESC
                                                      LIMIT 1]){
                                                          if (analysisReportMap.isEmpty()|| !analysisReportMap.containsKey(analysisReportList.complaint__c)){
                                                              analysisReportMap.put(analysisReportList.complaint__c, new list<Analysis_Report__c>{analysisReportList});
                                                          }else {
                                                              analysisReportMap.get(analysisReportList.complaint__c).add(analysisReportList); 
                                                          }
                                                                                                           
                                                      }
        return analysisReportMap;
    }
    
    /**
     * Method to get the list of analysis_ results related to the complaint 
     * that need to be displayed on the doctorLetter
     * 
     * @param     list of analysis report
     * @return    List of string
     * @author    emma
     *
     **/
    // get the list of analysis_ results related to the complaint that need to be displayed on the doctorLetter
    private List<String> getListOfAnalysis(List<Analysis_Report__c> analysisReportList){ 
        List<String> analysisList = new List<String>();
        if (analysisReportList !=null){
            for(Analysis_Report__c ans :analysisReportList){
                if (ans.analysis_results__c !=null){
                    analysisList.add(ans.analysis_results__c);
                }
            }    
        }
        return analysisList;
    }
    
    /**
     * @AuraEnabled Method Called from the component  Doctor letter selection
     * it check if there is doctors related to the complaint or not to generate the letter for them
     * 
     * @param     complaint Id
     * @return    string
     * @author    emma
     *
     **/
    
    @AuraEnabled
    public static String getErrorMsg(Id complaintId){
        
        Set<Id> RecipientIdSet = new Set<Id>();
        RecipientIdSet = getDoctorRecipients(complaintId);
        
        Integer recipientNbr = RecipientIdSet.size();
        String msg='';
            
        if (recipientNbr == 0){
            msg=System.Label.NO_DOCTOR_RECIPIENT_IS_FOUND;
        }else{
            msg = System.Label.DOCTOR_LETTER_CREATED;
        }
        return msg;
    }
    
}