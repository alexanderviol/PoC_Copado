trigger WorkOrderTrigger on WorkOrder (before Update, after Update) {
    if(System.Trigger.isAfter) {
        if(System.Trigger.isUpdate) {
            System.debug('AfterUpdate WorkOrder');
            WorkOrderHandler.checkAndPerformTransmissionToOrder(System.Trigger.oldMap, System.Trigger.newMap);
            WorkOrderHandler.checkAndPerformWorkOrderCancellation(System.Trigger.newMap, System.Trigger.oldMap); // added by emma -- 25.06.2018 -- SAFBIO--1307
            WorkOrderHandler.updatePatientWithFollowingPhysician(System.Trigger.newMap); //SAFBIO-1847
            Utility.printLimits();
        } else if (System.Trigger.isInsert) {
            System.debug('AfterInsert WorkOrder');
            WorkOrderHandler.updatePatientWithFollowingPhysician(System.Trigger.newMap); //SAFBIO-1847
            Utility.printLimits();
        }
    }
    else if (System.Trigger.isBefore){
        if (System.Trigger.isUpdate){
           System.debug('BeforeUpdate WorkOrder');
           WorkOrderHandler.OnBeforeUpdate(System.Trigger.newMap, System.Trigger.oldMap);
           Utility.printLimits();
        }
    }
}