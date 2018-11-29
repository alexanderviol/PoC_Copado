/**
 * Tests the function to update user information based on the existence of a ServiceResource record.
 * Also covers ServiceTerritoryMemberHandler
 * 
 * @author			Florian Heer <f.heer@conciscon.de>
 * @created			2018-08-07
 * @systemLayer    	Test
 *  
*/


@isTest
public class ServiceResourceHandler_Test {
    public static final String MY_USER_LASTNAME = 'A_9876TestUser';
    public static final String MY_SERVICE_TERRITORY = 'A_9876ServiceTerritory';
    
    @testSetup
    public static void setupEnvironment() {
        List<Profile> p = [SELECT Id FROM Profile WHERE Name = 'Sales'];
        System.assertEquals(1, p.size());
        User u = TestDataFactory.createUser(p[0].Id);
        u.LastName = MY_USER_LASTNAME;
        insert u;
        PermissionSet ps = [SELECT ID From PermissionSet WHERE Name = 'FSL_Agent_License'];
        insert new PermissionSetAssignment(AssigneeId = u.id, PermissionSetId = ps.Id );
        
        ps = [SELECT ID From PermissionSet WHERE Name = 'FSL_Agent_Permissions'];
        insert new PermissionSetAssignment(AssigneeId = u.id, PermissionSetId = ps.Id );
        
        
    }
	
    @isTest
    public static void testUserServiceResource() {
        OperatingHours oh = new OperatingHours(Name = 'My dummy operating hours');
        insert oh;
        
        ServiceTerritory st = new ServiceTerritory(IsActive = true, Name = MY_SERVICE_TERRITORY, OperatingHoursId = oh.id);
        insert st;

        Schema.Location myLoc = new Schema.Location(sap_company_code__c = '5500', Name = 'My Dummy Location', IsInventoryLocation = True, IsMobile = True);
        insert myLoc;
        
        User u = [SELECT Id FROM User WHERE LastName = :MY_USER_LASTNAME LIMIT 1];
        ServiceResource sr = new ServiceResource (RelatedRecordId = u.Id, IsActive = true, Name = MY_USER_LASTNAME, LocationId = myLoc.Id);
        User ru = [SELECT is_service_resource__c FROM User WHERE Id = :u.Id LIMIT 1];
        System.assertEquals(false, ru.is_service_resource__c);
        Test.startTest();
        insert sr;
        ru = [SELECT is_service_resource__c FROM User WHERE Id = :u.Id LIMIT 1];
        System.assertEquals(false, ru.is_service_resource__c);
        
        ServiceTerritoryMember stm = new ServiceTerritoryMember(ServiceResourceId = sr.id, TerritoryType = 'P', 
                                                                ServiceTerritoryId = st.id, EffectiveStartDate = Date.today());
        insert stm;
        
        sr.IsActive = false;
        update sr;
        sr.IsActive = true;
        update sr;
        ru = [SELECT is_service_resource__c FROM User WHERE Id = :u.Id LIMIT 1];
        System.assertEquals(true, ru.is_service_resource__c);
        
        
        sr.IsActive = false;
        update sr;
        Test.stopTest();
        ru = [SELECT is_service_resource__c FROM User WHERE Id = :u.Id LIMIT 1];
        System.assertEquals(false, ru.is_service_resource__c);
    }
}