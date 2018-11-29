/*
 * UserTerritory2Association Handler
 * 
 * Include auto Adding/removing User from public group 
 * whenever a user is added or removed from territory.
 * 
 * @author			emma
 * @created			2018-09-27
 * @systemLayer		Handler 
 * 
 */ 
public class UserTerritory2AssociationHandler {
    /*
     * This method controlls which functions gets called in case of after insert trigger event
     * uta -> short term for UserTerritory2Association
     * 
     * @param 	mapNewUta, contains all new UserTerritory2Association with their values from the trigger
     * @author  emma 
     */ 
    public void onAfterInsert(Map<Id,UserTerritory2Association> mapNewUta){
    	autoAddUserProcess (mapNewUta);   
    }
    /*
     * This method controlls which functions gets called on before delete trigger event
     * uta -> short term for UserTerritory2Association
     * 
     * @param	mapOldUta, Contains all UserTerritory2Association record from before delete	
     * @author  emma
     */ 
    public void onBeforeDelete(Map<Id,UserTerritory2Association> mapOldUta){
		autoDeleteUserProcess(mapOldUta);  	    
    }
    /*
     * During adding users to the territory, this method should run to add the same users 
     * to the public group having the same name as the territory 
     * 
     * @param   mapNewUta
     * @author  emma
     */ 
    public void autoAddUserProcess(Map<Id,UserTerritory2Association> mapNewUta){
        
        Set<Id> setTerritoryIds = new Set<Id>();
        Set<Id> setUserId = new Set<Id>();
        Set<String> devName =new Set<String>();
        
        list<groupMember> groupMembers = new list<groupMember>();
        
        for (UserTerritory2Association  objUta: mapNewUta.values()){
            if(objUta.Territory2Id !=null){
                setTerritoryIds.add(objUta.Territory2Id);
            }
            if (objUta.UserId != null ){
                 setUserId.add(objUta.UserId);
                system.debug('setUserId----------------->'+ setUserId);
             }
        } 
        devName = getTerritoriesName(setTerritoryIds);
        List<Group> grp = [select Id from Group where DeveloperName IN:devName AND Type='Regular'];
        List<User> us = [select Id from User where Id IN: setUserId];
        
        For(User u :us ){ 
            For(Group g : grp){
                groupMember gp = new groupMember(groupId = g.Id);
                gp.UserOrGroupId = u.Id;
                groupMembers.add(gp);
            }
        }
        if(groupMembers !=null){
            insert groupMembers;
        }
    }
    /*
     * When removing users from a territory, tha same users should be removed
     * from the public group having the same name as the territory 
     * 
     * @param	mapOldUta
     * @author  emma
     */
    public void autoDeleteUserProcess(Map<Id,UserTerritory2Association> mapOldUta){
        
        Set<Id> setTerritoryIds = new Set<Id>();
        Set<Id> setUserId = new Set<Id>();
        Set<Id> setGroupIds = new Set<Id>();
        Set<String> setTerritoryName = new Set<String>();
        
        List <Group> groups= new List<Group>();
        List<groupMember> groupMembers = new List<groupMember>();
        
        for (UserTerritory2Association  objUta: mapOldUta.values()){
            if(objUta.Territory2Id !=null){
                setTerritoryIds.add(objUta.Territory2Id);
            }
            if (objUta.UserId != null ){
                setUserId.add(objUta.UserId);
            }
            system.debug('--j->'+ setUserId);
        }
        
        setTerritoryName = getTerritoriesName(setTerritoryIds);
        groups = [SELECT Id, DeveloperName, Name 
                         FROM Group
                         WHERE DeveloperName IN:setTerritoryName
                         AND Type='Regular'];
        
        if (groups !=null){
            system.debug('--1->'+ groups);
            For(Group gp:groups){
                if (gp.Id !=null){
                    setGroupIds.add(gp.Id);   
                }
            }    
        }
        system.debug('--2->'+ setGroupIds);
        groupMembers = [SELECT Id, GroupId, UserOrGroupId
                       FROM  GroupMember 
                       Where GroupId IN: setGroupIds
                       AND   UserOrGroupId IN: setUserId];
        
        if (groupMembers!= null){
            system.debug('--3->'+ groupMembers);
            delete groupMembers;
        }
    }
    /*
     * Select a set of territories Names of the given territory Ids 
     *  
     * @param	setTerritoryIds
     * @author  emma
     */ 
    private static Set<String> getTerritoriesName (Set<Id> setTerritoryIds){
    	Set<String> territoriesName = new Set<String>();
        List <Territory2> territories = new List<Territory2>();
        territories =[SELECT Id, Name, DeveloperName 
                                        FROM Territory2 where Id IN : setTerritoryIds];
        for(Territory2 tr: territories){
        	territoriesName.add(tr.DeveloperName);   
        }
        return territoriesName;  
    }
}