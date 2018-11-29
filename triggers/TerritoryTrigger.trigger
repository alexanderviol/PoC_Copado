trigger TerritoryTrigger on Territory2 (before insert, after insert, after delete) {
	TerritoryHandler ObjTerritory = new TerritoryHandler();
    if(System.Trigger.isAfter) {
        if (System.Trigger.isInsert){
            ObjTerritory.onAfterInsert(Trigger.newMap);
        }
        if (System.trigger.isDelete){
            ObjTerritory.onAfterDelete(Trigger.oldMap);
        }
    }
}