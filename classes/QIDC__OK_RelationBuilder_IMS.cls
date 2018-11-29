/*
This file is generated and isn't the actual source code for this
managed global class.
This read-only file shows the class's global constructors,
methods, variables, and properties.
To enable code to compile, all methods return null.
*/
global class OK_RelationBuilder_IMS implements Database.Batchable<SObject>, Database.Stateful {
    global OK_RelationBuilder_IMS() {

    }
    global void execute(Database.BatchableContext batchContext, List<QIDC__OK_Relation_Caching_ims__c> relationCachingList) {

    }
    global Map<String,Set<QIDC.OK_RelationBuilder_IMS.DeactivateRelations>> fetchExistingRelations(List<String> parentSFIDs, String relatedSObjectName, List<String> requiredFields) {
        return null;
    }
    global QIDC__Refresh_My_OneKey_Statistics_ims__c fetchJobStatisticsRecordByJobId(String JobId) {
        return null;
    }
    global Map<String,String> fetchRelatedSFIDs(List<String> relatedOnekeyIDs, String relatedSObjectName, String relatedFieldName) {
        return null;
    }
    global void finish(Database.BatchableContext BC) {

    }
    global Map<String,List<Integer>> gettingRelationRecords() {
        return null;
    }
    global Database.QueryLocator start(Database.BatchableContext BC) {
        return null;
    }
    global void upsertRelationsJobStatistics(Map<String,List<Integer>> jobInDetailRecord, Map<String,Object> dataResult, Map<String,Integer> numberOfRelation) {

    }
global class DeactivateRelations {
    global DeactivateRelations() {

    }
}
}
