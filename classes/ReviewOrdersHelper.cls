/* 
 *  Description  - Helper class to review order creation,
 * 				   used in OrderHandler and AssetHandler 
 *  Created Date - 10.04.2018
 *  Created by   - snpa
 */
public without sharing class ReviewOrdersHelper {
	
    public static final String PACEMAKER = 'Pacemaker';
    public static final String ICD = 'ICD';
    public static final String DEVICE = 'Device';
    public static final String SALES_PROFILE = 'Sales';

    public static final list<Group> groupList = [SELECT id 
                                                  	FROM Group 
                                                  WHERE Type = 'Queue' 
                                                         AND developername = 'order_review_cas'];
    public static profile loggedInUSerProfile = [SELECT name
                                                        FROM profile
                                                      WHERE id =: userinfo.getProfileId()];

    /**
     * Method to change order owner to CAS queue and block submission to SAP 
     */
    public static order blockOrderSubmission(order objOrder) {
    	objOrder.submit_to_sap__c = false;
        if (groupList != null && groupList.size() > 0) {
        	objOrder.OwnerId = groupList[0].id;    
        }
        return objOrder;
    }

    /**
     * Method checkes if logged in User is Sales rep
     */
    public static boolean isLoggedInUserRep(string loggedInUserProfile) {
        if(loggedInUserProfile == SALES_PROFILE) {
            return true;
        }
        return false;
    }
}