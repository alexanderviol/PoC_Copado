/*
 * Test class for Territory Trigger and the TerritoryHandler
 * @author			emma
 * @created			2018-09-26
 * @systemLayer		Test
 * 
 */ 
@isTest
public class TerritoryHandlerTest {
    static Territory2 objTerritory;
    static Territory2Model objTerritoryModel;
    static list<Territory2Type> objTerritoryType;
    static User testUser;
    
    
    private static void init() {
        testUser = TestDataFactory.createUser(UserInfo.getProfileId(), 'myUserTR');
        
        objTerritoryModel = TestDataFactory.createTerritoryModel();
        insert objTerritoryModel;
        
        objTerritoryType = TestDataFactory.getTerritoryType();
        
        System.runAs(testUser){
            if (objTerritoryType.size()>0){
                objTerritory= TestDataFactory.createTerritory(objTerritoryType[0].Id, objTerritoryModel,'Test');
                insert objTerritory;    
            }
        }
    }
    
    @isTest
    private static void testCreateGroup(){
        init();
        List<group> groups = [Select Id, DeveloperName, Name from Group where DeveloperName =:objTerritory.DeveloperName];
        System.assertEquals(groups.size(), 1);
        for (Group gp : groups){
            System.assertEquals(gp.DeveloperName, objTerritory.DeveloperName); 
        }        
    }

    @isTest
    private static void testDeleteGroup(){
        init();
        Map<Id, Territory2> myMap = new Map<Id, Territory2>();
        myMap.put(objTerritory.Id,objTerritory);
        
        Test.startTest();
        TerritoryHandler.deletePublicGroup(myMap);
        Test.stopTest();
        
        List<Group> grp = [select Id,  DeveloperName from Group where DeveloperName =:objTerritory.DeveloperName];
        System.assertEquals(grp.size(), 0); 
    }
}