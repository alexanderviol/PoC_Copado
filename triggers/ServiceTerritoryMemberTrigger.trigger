/* 2018-08-21 Florian Heer <f.heer@conciscon.de>
 * Delegates Trigger events to the ServiceTerritoryMemberHandler
 */
trigger ServiceTerritoryMemberTrigger on ServiceTerritoryMember (after insert, after update) {
    if(Trigger.isAfter) {
        if(Trigger.isInsert || Trigger.isUpdate) {
            ServiceTerritoryMemberHandler.handleServiceTerritoryMemberChange(Trigger.New);
        }
    }
}