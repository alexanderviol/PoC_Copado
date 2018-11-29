/*
This file is generated and isn't the actual source code for this
managed global class.
This read-only file shows the class's global constructors,
methods, variables, and properties.
To enable code to compile, all methods return null.
*/
global class OK_RELATIONS_PARENTID_CACHE_BATCH_IMS implements Database.AllowsCallouts, Database.Batchable<SObject>, Database.Stateful {
    global Integer maxNbOfRelations;
    global Integer maxNbOfTimesToRun;
    global Integer minNbOfRelations;
    global String queryString;
    global OK_RELATIONS_PARENTID_CACHE_BATCH_IMS(String pQuery, Integer pMinNbOfRelations, Integer pMaxNbOfRelations, Integer pMaxNbOfTimesToRun) {

    }
    global void execute(Database.BatchableContext batchContext, List<QIDC__OK_RelationsParentIdsCache_ims__c> parentIdsCache) {

    }
    global void finish(Database.BatchableContext batchContext) {

    }
    global Database.QueryLocator start(Database.BatchableContext batchContext) {
        return null;
    }
}
