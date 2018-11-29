/*
 * Territory2 handler
 * 
 * Include deletion creation of public groups on creation deletion of territory
 * 
 * @author			emma
 * @created			2018-09-25
 * @systemLayer		Handler 
 * 
 */ 
public class TerritoryHandler {
     /**
     * This method controlls which functions gets called in case of a After insert trigger event
     * 
     * @param mapNewTerritory, contains all new created Territories from the trigger
     * @author	emma
     */
    public void onAfterInsert(Map<Id, Territory2> mapNewTerritory){
    	createPublicGroup (mapNewTerritory); 
    }
    /**
     * This method controlls which functions gets called in case of a Before Delete trigger event
     * 
     * @param mapOldTerritory, contains all Territories records with their values from After Delete
     * @author	emma
     */
    public void onAfterDelete(Map<Id, Territory2> mapOldTerritory){
       deletePublicGroup(mapOldTerritory);
    }
    /*
     * During the creation of a territoy, this method should run to create a public group 
     * with the same name of the territory.
     * 
     * @param mapNewTerritory, contains all territories record for which the trigger should run
     * @author emma
     */ 
    public static void createPublicGroup(Map<Id, Territory2> mapNewTerritory){
        Set<String> devName = new Set<String>();
        //Group groups;
        List<Group> groups = new List<group>();
        if (!mapNewTerritory.isEmpty()){
            for (Territory2 newTerritory :mapNewTerritory.values()){
                if (newTerritory.DeveloperName != null){
                    devName.add(newTerritory.DeveloperName);
                }	    
            }    
        } 
        if (!devName.isEmpty()){
            for (String name : devName){
                groups.add(new Group(DeveloperName = name, 
                                   Name = name,
                                   DoesIncludeBosses = true));     
            }    
        }
        if (groups !=null){
        	insert groups;    
        }   
    }
    
    /*
     * During the deletion of a territoy, this method should run to delete public group 
     * with the same name of the territory.
     * 
     * @param mapOldTerritory, contains all territories record for which the trigger should run on  Delete
     * @author emma
     */ 
    public static void deletePublicGroup(Map<Id, Territory2> mapOldTerritory){
        List<Group> groupsToDelete = new List<Group>();
        Map <String, List<Group>> groupMapbyName = new Map <String, List<Group>>();
        Set<String> SetTerritoryName = new Set<String>();
        for (Territory2 oldTerritory : mapOldTerritory.values()){
            if (oldTerritory.DeveloperName != null){
            	SetTerritoryName.add(oldTerritory.DeveloperName);   
            }			    
        }
        groupsToDelete =  [SELECT Id, DeveloperName
                           FROM Group 
                           WHERE DeveloperName IN: SetTerritoryName ]; 
        
       	if ( groupsToDelete !=null ){
        		delete groupsToDelete;    
        }    
    }
}