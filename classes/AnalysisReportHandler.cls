public with sharing class AnalysisReportHandler {


    @TestVisible private static final String DUPLICATE_ANALYSIS_REPORT_ERROR = 'DUPLICATE_ANALYSIS_REPORT';
    private static final String ANALYSIS_REPORT_TRIGGER_FIELDSET_NAME = 'analysis_report_duplicate_check';

    /*
     * Checks if an identical Analysis Result exists already for the related complaint
     * if so, the newly inserted row is rejected
     */
    public void checkDuplicates(List<Analysis_Report__c> analysisReports) {
        Set<Id> complaintIds = new Set<Id>();
        Map<Id, List<Analysis_Report__c>> analysisReportsByComplaintId = new Map<Id, List<Analysis_Report__c>>();

        for (Analysis_Report__c ar : analysisReports) {
            if (ar.complaint__c == NULL) {
                continue;
            }
            complaintIds.add(ar.complaint__c);
            if(!analysisReportsByComplaintId.containsKey(ar.complaint__c)){
                analysisReportsByComplaintId.put(ar.complaint__c, new List<Analysis_Report__c>());
            }
            analysisReportsByComplaintId.get(ar.complaint__c).add(ar);
        }

        List<String> fieldNames = getFieldsToCompare();
        String queryFields = buildQueryFields(fieldNames);

        String query = 'SELECT Id, (SELECT ' +  queryFields + ' FROM Analysis_Reports__r) FROM complaint__c WHERE Id IN :complaintIds';
        List<complaint__c> complaintsWithResults = Database.query(query);

        for (complaint__c complaint : complaintsWithResults) {
            // no analysis reports - no duplicates possible
            if (complaint.Analysis_Reports__r.isEmpty()) {
                continue;
            }

            for(Analysis_Report__c newAnalysisReport : analysisReportsByComplaintId.get(complaint.Id)) {

                // check against all existing reports on the  complaint
                for (Analysis_Report__c oldAnalysisReport : complaint.Analysis_Reports__r) {

                    Boolean isDuplicate = isDuplicate(oldAnalysisReport, newAnalysisReport, fieldNames);
                    if (isDuplicate) {
                        newAnalysisReport.addError(DUPLICATE_ANALYSIS_REPORT_ERROR);
                        break;
                    }
                }
            }
        }

    }
    private Boolean isDuplicate(Analysis_Report__c oldAnalysisReport, Analysis_Report__c newAnalysisReport, List<String> fieldNames) {
        if(oldAnalysisReport == NULL || newAnalysisReport == NULL){
            return false;
        }
        for (String fieldName : fieldNames) {

            System.debug(oldAnalysisReport);
            System.debug(newAnalysisReport);
            System.debug(fieldName);
            System.debug(oldAnalysisReport.get(fieldName));
            System.debug(newAnalysisReport.get(fieldName));

            if (oldAnalysisReport.get(fieldName) != newAnalysisReport.get(fieldName)) {
                // at least one field differs - so its not a duplicate! => early return
                return false;
            }
        }
        return true;
    }

    private List<String> getFieldsToCompare() {
        // fields to be compared are stored in a fieldset to make changes easier to maintain
        List<String> fields = new List<String>();

        for (Schema.FieldSetMember member : Schema.SObjectType.Analysis_Report__c.fieldSets.getMap().get(ANALYSIS_REPORT_TRIGGER_FIELDSET_NAME).getFields()) {
            fields.add(member.getFieldPath());
        }

        return fields;
    }

    private String buildQueryFields(List<String> fieldNames){
        return String.join(fieldNames, ', ');
    }
}