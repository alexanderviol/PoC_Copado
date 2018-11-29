trigger UserTerritory2AssociationTrigger on UserTerritory2Association (before insert, after insert, before delete) {
    UserTerritory2AssociationHandler objUserTerritoryAssociation = new UserTerritory2AssociationHandler();
    if (System.Trigger.isAfter){
        if (System.Trigger.isInsert){
            objUserTerritoryAssociation.onAfterInsert(Trigger.newMap);   
        }
    }
    if (System.Trigger.isBefore){
        if (System.trigger.isDelete){
            objUserTerritoryAssociation.onBeforeDelete(Trigger.oldMap);
        }    
    }
}