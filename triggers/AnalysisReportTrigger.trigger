trigger AnalysisReportTrigger on Analysis_Report__c (before insert) {

    /*
    * This trigger checks if the analysis report is identical to the latest report on the parent complaint
    * and will reject it
    */
    AnalysisReportHandler objHandler = new AnalysisReportHandler();

    if(Trigger.isInsert && Trigger.isBefore){
        objHandler.checkDuplicates(Trigger.new);
    }
}