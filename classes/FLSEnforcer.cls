/*
 *  Generic class to check FLS Permissions 
 *  Created Date - May 31, 2018
 *  Created by   - susi
 * 
 * Revision History - 
 * Date				| Developer Name				| Version				| Changes/Ticket Number 
 * ================================================================================================ 	 
 *  
 */
public without sharing class FLSEnforcer {
	
   /*
    * To check whether user has permission to create or not?
    * @param    objAPIName    object API name
    * @param    filedsNameList    List of object fields
    * @return   flag    boolean value
    */
    public Static boolean isCreatable(String objAPIName, List<String> filedsNameList) {
        boolean flag = true;
        Map<String, SObjectField> objectFields = getFieldsMap(objAPIName, filedsNameList);
        for(String field : filedsNameList) {
            if(!objectFields.get(field).getDescribe().isCreateable())  {
                return false;
            }   
        }
        return flag;
    }
    
   /*
    * To check whether user has permission to update or not?
    * @param    objAPIName    object API name
    * @param    filedsNameList    List of object fields
    * @return   flag    boolean value
    */
    public Static boolean isUpdatable(String objAPIName, List<String> filedsNameList) {
        boolean flag = true;
        Map<String, SObjectField> objectFields = getFieldsMap(objAPIName, filedsNameList);
        for(String field : filedsNameList) {
            if(!objectFields.get(field).getDescribe().isUpdateable())  {
                return false;
            }   
        }
        return flag;
    }
    
    /*
    * To check whether user has permission to delete or not?
    * @param    objAPIName    object API name
    * @return   flag    boolean value
    */
    public Static boolean isdeleteable(String objAPIName) {
    	SObjectType objToken = Schema.getGlobalDescribe().get(objAPIName);
        DescribeSObjectResult objDef = objToken.getDescribe();
        return objDef.isDeletable();
    }
       
   /*
    *  Returns sObject field map.
    * @param    objAPIName    object API name
    * @param    filedsNameList    List of object fields
    * @return   flag    sObject field map
    */
    private static Map<String, SObjectField> getFieldsMap(String objAPIName, List<String> filedsNameList) {
    	SObjectType objToken = Schema.getGlobalDescribe().get(objAPIName);
        DescribeSObjectResult objDef = objToken.getDescribe();
        return objDef.fields.getMap();    
    }
    
}