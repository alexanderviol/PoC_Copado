/*
 * This class contain methods required to select and submit Complaints to CAN
 * Created by EMMA
 * Created Date 31.05.2018
 */
public with sharing class SubmitComplaintToCANcontrollerExt {

    public List <complaint__c> complaints { get; private set; }
    public List <InvalidComplaint> invalidComplaints { get; private set; }
    public String can_username { get; set; }
    public String can_password { get; set; }
    public Boolean success { get; private set; }
    public Boolean isAuthRequired { get; private set; }

    private CanAuthentication auth;


    public SubmitComplaintToCANcontrollerExt(ApexPages.StandardSetController controller) {
        isAuthRequired = true;
        success = false;
        auth = new CanAuthentication();

        Set<Id> selectedComplaintIds = new Set<Id>();
        for(complaint__c complaint : (List<complaint__c>) controller.getSelected()) {
            selectedComplaintIds.add(complaint.Id);
        }

        complaints = [
                SELECT
                        Id,
                        Name,
                        Submit_to_Can__c,
                        ci_number__c,
                        asset_model_name__c,
                        patient_identifier__c,
                        is_locked__c,
                        RecordType.DeveloperName
                FROM
                        complaint__c
                WHERE
                        Id IN :selectedComplaintIds
        ];


        if (complaints == null || complaints.isEmpty()) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, Label.CAN_SUBMISSION_SELECTED_ERROR_NOTHINGSELECTED));
        }

        validateComplaints();

        String authId = auth.getUserSession();

        if (authId != null && String.isNotEmpty(authId) && auth.validateUserSession(authId)) {
            isAuthRequired = false;
        }
    }

    public Boolean auth() {
        Boolean result = auth.authenticateUser(can_username, can_password);
        System.debug(result);
        if (result) {
            isAuthRequired = false;
        } else {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.WARNING, Label.CAN_SUBMISSION_ERROR_AUTH_FAILED));
        }

        return result;
    }


    public PageReference authenticate() {
        this.auth();
        return null;
    }

    public PageReference submit() {
        if (!Test.isRunningTest()) {
            ComplaintSubmissionService.submitComplaints(complaints);
        }
        success = true;
        return null;
    }


    private void validateComplaints(){

        List<complaint__c> validComplaints = new List<complaint__c>();
        List<InvalidComplaint> invalidComplaints = new List<InvalidComplaint>();

        for(complaint__c complaint : this.complaints){
            if(complaint.Submit_to_Can__c == FALSE){
                invalidComplaints.add(createInvalidComplaint(complaint, Label.CAN_SUBMISSION_SELECTED_ERROR_SUBMITTOCAN));
            }
            else if(complaint.is_locked__c == true){
                invalidComplaints.add(createInvalidComplaint(complaint, Label.CAN_SUBMISSION_SELECTED_ERROR_ISLOCKED));
            }
            else if(String.isBlank(complaint.ci_number__c) && complaint.RecordType.DeveloperName != Constants.RECORD_TYPE_NAME_COMPLAINT_OUS) {
                invalidComplaints.add(createInvalidComplaint(complaint, Label.CAN_SUBMISSION_SELECTED_ERROR_MISSING_CINUMBER));
            }
            else {
                validComplaints.add(complaint);
            }
        }

        this.complaints = validComplaints;
        this.invalidComplaints = invalidComplaints;

    }

    private InvalidComplaint createInvalidComplaint(complaint__c complaint, String message) {
        InvalidComplaint ic = new InvalidComplaint();
        ic.complaint = complaint;
        ic.message = message;
        return ic;
    }

    public class InvalidComplaint{
        public complaint__c complaint {get; private set;}
        public String message {get; private set;}
    }


}