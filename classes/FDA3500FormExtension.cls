/**
 * Extension class for FDA3500Form
 * 
 * @author            SNPA
 * @created           2018-10-26
 * @systemLayer       Controller Extension
 *  
 */
public class FDA3500FormExtension {
    
    public final Complaint__c complaint {get; private set;}    
    public Analysis_Report__c analysisResult {get; set;}
    public integer ageOfDevice {get; private set;}
     
    public FDA3500FormExtension(ApexPages.StandardController stdController) {
        this.complaint = getComplaint(((Complaint__c)stdController.getRecord()).id);
       	analysisResult = new Analysis_Report__c();
        
        if(this.complaint.date_of_manufacture__c != null) {
        	ageOfDevice = this.complaint.date_of_manufacture__c.daysBetween(system.today());    
        }
        list<Analysis_Report__c> analysisResultList = getAnalysisResults(this.complaint.Id);
        if(analysisResultList != null && analysisResultList.size() > 0) {
            analysisResult = analysisResultList[0];
        }
    }
    
    @auraEnabled
	public static void attachAsPdf(string parentId) {
		
        list<complaint__c> complaintList = [SELECT id, 
                                            	   name 
                                            FROM complaint__c 
                                            	WHERE id = :parentId];
        PageReference pdf = Page.FDA3500Form;
        pdf.getParameters().put('id',parentId); 
        Blob body;    
        try {    
            body = pdf.getContentAsPDF(); 
        } catch (Exception e) {
            body = Blob.valueOf('Error...');
        }    
        
        ContentVersion conVer = new ContentVersion();
        conVer.ContentLocation = 'S'; // S specify this document is in SF, use E for external files
        conVer.PathOnClient = 'FDA3500.pdf'; 
        conVer.Title = 'FDA 3500A'+ '-' + complaintList[0].name +'-' +system.now(); 
        conVer.VersionData = body;
        insert conVer;
        
		Id conDoc = [SELECT ContentDocumentId FROM ContentVersion WHERE Id =:conVer.Id].ContentDocumentId;
        ContentDocumentLink cDe = new ContentDocumentLink();
        cDe.ContentDocumentId = conDoc;
        cDe.LinkedEntityId = parentId; 
        cDe.ShareType = 'V'; 
        insert cDe;
  	}
	
    /** 
     * Method returns latest Analysis result for a Complaint
     *
     * @param      id     						id of Complaint
     * @return     list<Analysis_Report__c>    	Analysis result for the given complaint
     * @author     snpa 
     */
    private list<Analysis_Report__c> getAnalysisResults(id complaintId) {
    	return [SELECT id, 
                	   date_sent_to_fda__c, 
                	   device_evaluated_by_manufacturer__c,
               		   method_code__c,
                	   result_code__c,
                	   conclusion_code__c
               FROM Analysis_Report__c 
               	WHERE complaint__c = :complaintId
               		ORDER BY CreatedDate desc LIMIT 1];  
    }
    
    
    /** 
     * Method returns Complaint details required to generate FDA form
     *
     * @param      id 					Id of complaint
     * @return     Complaint__c   	    complaint for given id
     * @author     snpa 
     */
    private Complaint__c getComplaint(id complaintId) {
    	return [SELECT id, 
                		initial_reporter_user__c,
                		initial_reporter_user__r.firstName,
                		initial_reporter_user__r.lastName,
                		initial_reporter_user__r.email,
                		initial_reporter_user__r.fax,
                		initial_reporter_user__r.phone,
                		initial_reporter_user__r.street,
                		initial_reporter_user__r.city,
                		initial_reporter_user__r.state,
                		initial_reporter_user__r.postalcode,
                		initial_reporter_user__r.country,
                		patient_identifier__c,
                		case__r.patient__r.patient_weight__c,
                		asset_lot_number__c,
                		asset__r.ous_asset__c,
                		case__c, 
                		case__r.patient__r.name,
                		case__r.patient__r.Birthdate ,
                		case__r.patient__r.gender__c,
                		adverse_event__c,
                		product_problem__c,
                		outcome_attributed_to_adverse_event__c,
                		additional_adverse_event_information__c,
                		date_of_event__c,
                		report_date__c,
                		mdr_event_description__c,
                		asset__r.name,
                		asset__r.product_type__c,
                		procode__c,
                		asset__r.product2.manufacturer_account__r.name,
                		asset__r.product2.manufacturer_account__r.shippingstreet,
                		asset__r.product2.manufacturer_account__r.shippingcity,
                		asset__r.product2.manufacturer_account__r.shippingcountry,
                		asset__r.product2.manufacturer_account__r.shippingstate,
                		asset__r.product2.manufacturer_account__r.shippingpostalCode,
                		asset__r.model_no__c,
                		asset__r.serialNumber,
                		asset__r.expiration_date_ubd__c,
                		asset__r.udi__c,
                		asset__r.installdate,
                		asset__r.explant_date__c,
                		device_available_for_evaluation__c,                		
                		initial_reporter_also_sent_report_to_fda__c,
                		type_of_report__c,
                		device_code_global__c ,
                		patient_code_global__c,
                		other_location__c,
                		location_where_event_occurred__c,
               		 	asset__r.product2.manufacturer_account__r.Phone,
                		report_source__c,
                		Other_Report_Source_Comment__c,
                		date_info_received_by_manufacturer__c,
                		pma_510k__c,
                		combination_product__c,
                		mdr_decision__c,
                		mdr_number__c,
                		type_of_reportable_event__c,
                		type_of_reportable_event_other__c,
                		if_follow_up_what_type__c,
                		date_of_manufacture__c,
                		labeled_for_single_use__c,
                		remedial_action_type__c,
                		usage_of_device__c,
                		additional_manufacturer_narrative__c
                	FROM Complaint__c 
                WHERE Id = :complaintId][0];
    }
}