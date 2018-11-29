/**
 * Handler Class for Complaint Trigger
 * - Updates the checkbox on Asset 'Has attached oos Complaints' when OOS or Returned product complaint 
 *   exists on an Asset record.
 * - Updates submit to CAN checkbox when a Complaint is created or updated
 * - RP Number is added to returned products on creation be Manager and MDR Users
 * 
 * @author            SNPA
 * @created           2018-05-11
 * @systemLayer       Handler 
 *  
 */
public class ComplaintHandler {

	public static final string OOS_COMPLAINT = 'oos_report';
	public static final string RETURNED_PRODUCT_COMPLAINT = 'Returned_Product_Report';
	private static final String METADATA_NAME_CAN_SAP_USER = 'CAN_SAP_USER';
	
    /** 
     * Before Insert method on Complaint
     *
     * @param      newComplaintList    List of new values of Complaints records
     * @return     void    
     * @author     SNPA 
     */
	public void onBeforeInsert(list<complaint__c> newComplaintList) {
        assignRPNumber (newComplaintList);
		updateSubmitToCan(newComplaintList, null);
	}

    /** 
     * Method called on before update of Complaints
     *
     * @param     newComplaintList    List of new values of Complaints records
     * @param     oldComplaintMap     Map of old values of Complaints records
     * @return    void    
     * @author    SNPA 
     */
	public void onBeforeUpdate(list<complaint__c> newComplaintList,
			map<id, complaint__c> oldComplaintMap) {
		updateSubmitToCan(newComplaintList, oldComplaintMap);
	}

    /** 
     * Method called on after insert of Complaints
     *
     * @param     newComplaintMap    Map of new values of Complaints records
     * @return    void    
     * @author    SNPA 
     */
	public void onAfterInsert(map<id, complaint__c> newComplaintMap) {
		updateOosComplaintOnAsset(newComplaintMap, null);
	}

    /** 
     * Method called on after update of Complaints
     *
     * @param     newComplaintMap    Map of new values of Complaints records
     * @param     oldComplaintMap    Map of old values of Complaints records
     * @return    void    
     * @author    SNPA 
     */
	public void onAfterUpdate(map<id, complaint__c> newComplaintMap,
			map<id, complaint__c> oldComplaintMap) {
		updateOosComplaintOnAsset(newComplaintMap, oldComplaintMap);
	}

    /** 
     * Method called on after delete of Complaints
     *
     * @param     newComplaintMap    Map of new values of Complaints records
     * @param     oldComplaintMap    Map of old values of Complaints records
     * @return    void    
     * @author    SNPA 
     */
	public void onAfterDelete(map<id, complaint__c> newComplaintMap,
			map<id, complaint__c> oldComplaintMap) {
		updateOosComplaintOnAsset(newComplaintMap, oldComplaintMap);
	}

    /** 
     * Method called on after undelete of Complaints
     *
     * @param     newComplaintMap    Map of new values of Complaints records
     * @param     oldComplaintMap    Map of old values of Complaints records
     * @return    void    
     * @author    SNPA 
     */
	public void onAfterUndelete(map<id, complaint__c> newComplaintMap,
			map<id, complaint__c> oldComplaintMap) {
		updateOosComplaintOnAsset(newComplaintMap, oldComplaintMap);
	}
	
    /** 
     * Method called on insert ro assign RP to returned products
     *
     * @param     newComplaintList   List of new values of Complaints records
     * @return    void    
     * @author    SNPA 
     */
    public void assignRPNumber (List<complaint__c> newComplaintList) {
        
        List<User> loggedInUser = [SELECT Id, Name, UserRoleId, Email, Profile.Name, UserRole.DeveloperName FROM User WHERE Id = :UserInfo.getUserId() ];
        
        if(String.isNotBlank(loggedInUser[0].UserRoleId) && loggedInUser[0].UserRole.DeveloperName == Constants.ROLE_BINC_MDR) {
            
            GenerateAutoNumbersController.prefix = GenerateAutoNumbersController.RP_PREFIX + System.today().year() + '-';
            GenerateAutoNumbersController.fieldName = GenerateAutoNumbersController.RP_FIELDNAME;
            GenerateAutoNumbersController.runningNoFieldName = GenerateAutoNumbersController.RP_RUNNINGFIELDNAME;
            GenerateAutoNumbersController.calculateRunningNumber();
            for (complaint__c objComplaint: newComplaintList) {
                if(objComplaint.RecordTypeId == Utility.getRecordTypeId (complaint__c.SObjectType, ComplaintHandler.RETURNED_PRODUCT_COMPLAINT)) {
                    objComplaint.RP_Number__c = GenerateAutoNumbersController.getFieldValue();
                    objComplaint.RP_Running_Number__c = GenerateAutoNumbersController.runningNumber;
                    GenerateAutoNumbersController.runningNumber ++;
                }
            }
            GenerateAutoNumbersController.incrementValue  = false;
            GenerateAutoNumbersController.updateSettings();
            GenerateAutoNumbersController.calculateRunningNumber();
        }
    }
    
    /** 
     * Method to update 'Submit to can' checkbox on a Complaint everytime a Complaint is created
	 * and updated
     *
     * @param     newComplaintList    List of new values of Complaints records
     * @param     oldComplaintMap     Map of old values of Complaints records
     * @return    void    
     * @author    Simon 
     */
	private void updateSubmitToCan(List<complaint__c> newComplaintList,
			Map<Id, complaint__c> oldComplaintMap) {

		// API Updates from CAN (SAP/PI) should not trigger a re-submission - exclude these user(s)
		if (isCanApiUser()) {
			return;
		}

		for (complaint__c objComplaint : newComplaintList) {
			if (oldComplaintMap == null || (oldComplaintMap != null && objComplaint != oldComplaintMap.get(objComplaint.Id))) {
				objComplaint.Submit_to_Can__c = true;
			}
		}
	}
    
    /** 
     * Method to check if OOS or Returned product complaint exist on an Asset record and
	 * updates the checkbox on Asset
     *
     * @param     newComplaintMap     Map of new values of Complaints records
     * @param     oldComplaintMap     Map of old values of Complaints records
     * @return    void    
     * @author    SNPA 
     */
	private void updateOosComplaintOnAsset(map<id, complaint__c> newComplaintMap,
			map<id, complaint__c> oldComplaintMap
	) {
		set<id> assetIdSet = new set<id>();

		if (newComplaintMap != null) {
			for (complaint__c objComplaint : newComplaintMap.values()) {
				if (oldComplaintMap == null ||
						(oldComplaintMap != null &&
								(oldComplaintMap.get(objComplaint.id).asset__c != objComplaint.asset__c ||
										oldComplaintMap.get(objComplaint.id).recordTypeId != objComplaint.recordTypeId
								)
						)) {
					if (objComplaint.asset__c != null) {
						assetIdSet.add(objComplaint.asset__c);
					}
				}
			}
		}
		if (oldComplaintMap != null) {
			for (complaint__c objComplaint : oldComplaintMap.values()) {
				if (oldComplaintMap != null &&
						oldComplaintMap.get(objComplaint.id).asset__c != null) {
					assetIdSet.add(oldComplaintMap.get(objComplaint.id).asset__c);
				}
			}
		}
		if (assetIdSet != null && !assetIdSet.isEmpty()) {
			list<asset> assetList = new list<asset>();
            list<asset> queriedAssetList = [ SELECT id,
                                                has_attached_oos_complaints__c, (
                                                SELECT id,
                                                        recordtype.developername
                                                FROM complaints__r
                                                WHERE recordtype.developername = :OOS_COMPLAINT
                                                OR recordtype.developername = :RETURNED_PRODUCT_COMPLAINT
                                                    )
                                                    FROM asset
                                                    WHERE id IN :assetIdSet
                                            ];   // List used to resolve aggregate result limitation to use it dirctly in for loop
			for (asset objAsset : queriedAssetList) {

				if (objAsset.complaints__r != null &&
						objAsset.complaints__r.size() > 0 &&
						!objAsset.has_attached_oos_complaints__c
						) {
					assetList.add(new asset(id = objAsset.id,
							has_attached_oos_complaints__c = true
					));
				} else if ((objAsset.complaints__r == null ||
						objAsset.complaints__r.size() == 0) &&
						objAsset.has_attached_oos_complaints__c
						) {
					assetList.add(new asset(id = objAsset.id,
							has_attached_oos_complaints__c = false
					));
				}
			}
			if (assetList != null && assetList.size() > 0) {
				update assetList;
			}
		}
	}

    /** 
     * Method to to check if logged in user is Can SAP User
     *
     * @return    Boolean     
     * @author    Simon  	 
     */
	private Boolean isCanApiUser() {
		String canApiUsersCommaSeparated = [SElECT Value__c 
                                            	FROM Setting__mdt 
                                            WHERE DeveloperName = :METADATA_NAME_CAN_SAP_USER LIMIT 1].Value__c;

		if (String.isEmpty(canApiUsersCommaSeparated)) {
			return false;
		}
		List<String> canApiUsers = canApiUsersCommaSeparated.split(',');
		if (canApiUsers.isEmpty()) {
			return false;
		}
		return canApiUsers.contains(UserInfo.getUserName());
	}
}