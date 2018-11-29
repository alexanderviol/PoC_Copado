/*
This file is generated and isn't the actual source code for this
managed global class.
This read-only file shows the class's global constructors,
methods, variables, and properties.
To enable code to compile, all methods return null.
*/
global class VR_Monitoring_BATCH_IMS implements Database.AllowsCallouts, Database.Batchable<SObject>, Database.Stateful {
    global Id valRequestId {
        get;
        set;
    }
    global void execute(Database.BatchableContext batchContext, List<QIDC__Validation_Request_ims__c> validationRequestlist) {

    }
    global void finish(Database.BatchableContext batchContext) {

    }
    global Database.QueryLocator start(Database.BatchableContext batchContext) {
        return null;
    }
}
