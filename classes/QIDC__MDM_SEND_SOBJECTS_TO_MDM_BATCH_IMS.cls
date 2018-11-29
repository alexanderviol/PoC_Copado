/*
This file is generated and isn't the actual source code for this
managed global class.
This read-only file shows the class's global constructors,
methods, variables, and properties.
To enable code to compile, all methods return null.
*/
global class MDM_SEND_SOBJECTS_TO_MDM_BATCH_IMS implements Database.AllowsCallouts, Database.Batchable<SObject>, Database.Stateful {
    global Map<String,String> entityUriToQueryMap;
    global QIDC__MDM_Job_Setting_ims__c jobSetting;
    global String jobStatus;
    global String objectURI;
    global String queryString;
    global Integer scheduledBatchSize;
    global String scheduledJobId;
    global MDM_SEND_SOBJECTS_TO_MDM_BATCH_IMS(Map<String,String> pEntityUriToQueryMap, String pJobId, Integer pScheduledBatchSize, String pStatus) {

    }
    global void execute(Database.BatchableContext BC, List<SObject> sObjectList) {

    }
    global void finish(Database.BatchableContext BC) {

    }
    global Database.QueryLocator start(Database.BatchableContext BC) {
        return null;
    }
}
