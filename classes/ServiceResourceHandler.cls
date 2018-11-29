/**
 * Handles the function to update user information based on the existence of a ServiceResource record.
 * 
 * @author			Florian Heer <f.heer@conciscon.de>
 * @created			2018-08-07
 * @systemLayer    	Trigger
 *  
*/
public without sharing class ServiceResourceHandler {
    /* Changes the flag "is service resource" on users referenced in the Service Resources, as necessary
     */
    public static void handleUserServiceResource (List<ServiceResource> sResources) {
        List<Id> affectedUserIds = getAffectedUserIds(sResources);
        List<Id> affectedResourceIds = getAffectedResourceIds(sResources);
        List<ServiceTerritoryMember> terriMembers = [SELECT Id, ServiceResourceId FROM ServiceTerritoryMember WHERE TerritoryType = 'P' AND ServiceTerritoryId <> null
                                                     AND ServiceResourceID IN :affectedResourceIds];
        Map<Id, ServiceTerritoryMember> serviceResourceIdTerritoryMember = new Map<Id, ServiceTerritoryMember>();
        for(ServiceTerritoryMember stm : terriMembers) {
            serviceResourceIdTerritoryMember.put(stm.ServiceResourceId, stm);
        }
        List<User> affectedUsers = [SELECT Id, is_service_resource__c FROM User WHERE Id IN :affectedUserIds];
        List<User> usersToUpdate = new List<User>();
        Map<Id, User> idUser = new Map<Id, User>();
        for(User u : affectedUsers) {
            idUser.put(u.id, u);
        }
        for(ServiceResource sr : sResources) {
            User u = idUser.get(sr.RelatedRecordId);
            if(u.is_service_resource__c != sr.IsActive) {
                u.is_service_resource__c = (sr.IsActive && serviceResourceIdTerritoryMember.get(sr.id) != null); // It is only a viable servicee resource if it is a primary member of a Service Territory
                usersToUpdate.add(u);
            }
            
        }
        if(usersToUpdate.size() > 0) {
            update usersToUpdate;
        }
    }
    
    /* Returns affected user ids from a list of service resources
     */
    private static List<Id> getAffectedUserIds(List<ServiceResource> sResources) {
        Set<Id> affectedUserIds = new Set<Id>();
        for(ServiceResource sr : sResources) {
            affectedUserIds.add(sr.RelatedRecordId);
        }
        return new List<Id> (affectedUserIds);
    }
    
    /* Returns affected resource ids from a list of service resources
     */
    private static List<Id> getAffectedResourceIds(List<ServiceResource> sResources) {
        Set<Id> affectedResourceIds = new Set<Id>();
        for(ServiceResource sr : sResources) {
            affectedResourceIds.add(sr.Id);
        }
        return new List<Id> (affectedResourceIds);
        
    }
}