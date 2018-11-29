/**
 * Handles the function to update user information based on the existence of a ServiceTerritoryMember record.
 * 
 * @author			Florian Heer <f.heer@conciscon.de>
 * @created			2018-08-17
 * @systemLayer    	Trigger
 *  
*/
public class ServiceTerritoryMemberHandler {
    public static void handleServiceTerritoryMemberChange (List <ServiceTerritoryMember> stms) {
        List<Id> affectedServiceResources = new List<Id>();
        for(ServiceTerritoryMember stm : stms) {
            affectedServiceResources.add(stm.ServiceResourceId);
        }
        List<ServiceResource> srs = [SELECT Id, RelatedRecordId, IsActive FROM ServiceResource WHERE Id IN :affectedServiceResources];
        if(srs.size() > 0) {
            ServiceResourceHandler.handleUserServiceResource(srs);
        }
        
    }

}