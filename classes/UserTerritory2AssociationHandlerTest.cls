/*
 * Test class for the UserTerritory2Association Handler
 * @author			emma
 * @created			2018-09-28
 * @systemLayer		Test
 * 
 */ 
@isTest
public class UserTerritory2AssociationHandlerTest {
	static UserTerritory2Association objUta;
    static Group objGroup;
    static GroupMember objGroupMember;
    static User testUser;
    static Territory2Model objTerritoryModel;
    static list<Territory2Type> objTerritoryType;
    static Territory2 objTerritory;
    @isTest
    private static void init(){
    	testUser = TestDataFactory.createUser(UserInfo.getProfileId(),'Auser');
        objTerritoryModel = TestDataFactory.createTerritoryModel();
        insert objTerritoryModel;
        objTerritoryType = TestDataFactory.getTerritoryType();
         if (objTerritoryType.size()>0){
                objTerritory= TestDataFactory.createTerritory(objTerritoryType[0].Id, objTerritoryModel, 'AnyString');
                insert objTerritory;    
            }
        System.runAs(testUser){
            objUta = new UserTerritory2Association (UserId = testUser.Id, 
                                                    Territory2Id = objTerritory.Id);
            insert objUta;
    	}
        }
    @isTest
    private static void testAddUserProcess(){
        init();
        Id groupId = [Select Id, DeveloperName, Name from Group where DeveloperName =:ObjTerritory.DeveloperName].Id;
        if (groupId != null && testUser.Id!= null){
        	List<GroupMember> newGroupMember= [SELECT Id, GroupId, UserOrGroupId
                             From GroupMember 
                             Where GroupId =: groupId
                             AND   UserOrGroupId =: testUser.Id];
            for(GroupMember gpm:newGroupMember){
            	 System.assertEquals(gpm.UserOrGroupId, objUta.UserId);
            }
        }  
    }
    @isTest
    private static void testRemoveProcess(){
    	init();
        List<UserTerritory2Association> uta = [SELECT Id, UserId, Territory2Id 
                                               FROM UserTerritory2Association
                                               WHERE UserId =: testUser.Id 
                                               AND Territory2Id =: objTerritory.Id];
        system.debug('uta' +uta);
        if (uta!=null || uta.size()>0){
            delete uta; 
        }
        Id groupId = [Select Id, DeveloperName, Name from Group where DeveloperName =:ObjTerritory.DeveloperName].Id;
        List<GroupMember> newGroupMember= [SELECT Id, GroupId, UserOrGroupId
                             From GroupMember 
                             Where GroupId =: groupId
                             AND   UserOrGroupId =: testUser.Id];
        system.assertEquals(0, newGroupMember.size());
        
    }  
}