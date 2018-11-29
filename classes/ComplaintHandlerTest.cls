/**
 * Test class for ComplaintTrigger
 * 
 * @author            SNPA
 * @created           2018-05-19
 * @systemLayer       Test Class 
 *  
 */
@isTest
private class ComplaintHandlerTest {
    static list<asset> assetList = new list<asset>();
    static list<complaint__c> complaintList = new list<complaint__c>();
	static complaint__c objComplaint;
    
    static asset objAsset;	
    static asset objectAsset;
    static case objCase;
    /** 
     * Method to initialize test data
     *
     * @return     void    
     * @author     SNPA 
     */
    private static void init() {
    	account objAccount = TestDataFactory.createAccount();
        insert objAccount;
        
        objAsset = TestDataFactory.createAsset(objAccount.id);
        assetList.add(objAsset);
        
        objectAsset = TestDataFactory.createAsset(objAccount.id);
        assetList.add(objectAsset);
        
        insert assetList;
        
        objCase = TestDataFactory.createCase();
        insert objCase;
        
        objComplaint = TestDataFactory.createComplaint(objCase.id);
        objComplaint.recordtypeid =
            Utility.getRecordTypeId ('complaint__c', ComplaintHandler.OOS_COMPLAINT);
        objComplaint.asset__c = objAsset.id;
        complaintList.add(objComplaint);
        
        complaint__c secComplaint = TestDataFactory.createComplaint(objCase.id);
        secComplaint.recordtypeid =
            Utility.getRecordTypeId ('complaint__c', ComplaintHandler.OOS_COMPLAINT);
        secComplaint.asset__c = objectAsset.id;
        complaintList.add(secComplaint);        
    }
     
    /* Method checks if has OOS complaints checkbox is marked on 
     * creation of complaint with oos_report record type
     *
     * @return     void    
     * @author     SNPA 
     */    
    private static testMethod void testComplaintInsert() {
        init();
        
        
        test.startTest();
        	insert complaintList;
        test.stopTest();
               
        set<id> idSet = new set<id>();
        for(complaint__c objComplaint : complaintList) {
        	idSet.add(objComplaint.id);    
        }
        
        list<complaint__c> complaintList = [SELECT id,
                                            	   asset__c,
                                            	   asset__r.has_attached_oos_complaints__c
                                                FROM complaint__c
                                             WHERE id IN :idSet];
        for(complaint__c objComplaint : complaintList) {
            system.assert(objComplaint.asset__r.has_attached_oos_complaints__c == true);
        }        
    }
    
    /**
     * Method checks bulk RP number assignment to a valid Complaint
     *
     * @return     void    
     * @author     SNPA 
     */ 
    private static testMethod void testBulkRpAssignment() {
                
        Profile p = [SELECT id FROM Profile WHERE name='System Administrator'];

        list<UserRole> mdrRole = [SELECT id FROM UserRole WHERE DeveloperName = :Constants.ROLE_BINC_MDR];
        User objUser = TestDataFactory.createUser(p.id);
        if(mdrRole != null && mdrRole.size() > 0 )
        	objUser.UserRoleId = mdrRole[0].id;
       
        System.runAs(objUser) {    
            init();
            for(integer i=0; i<=200; i++) {
                complaint__c objComplaint = TestDataFactory.createComplaint(objCase.id);
                objComplaint.recordtypeid = Utility.getRecordTypeId ('complaint__c', ComplaintHandler.RETURNED_PRODUCT_COMPLAINT);
                objComplaint.asset__c = objAsset.id;
                objComplaint.date_product_received_by_mdr_team__c = system.today();
                complaintList.add(objComplaint);
            }        
            
            test.startTest();
                insert complaintList;
            test.stopTest();
        }
        
        set<id> idSet = new set<id>();
        for(complaint__c objComplaint : complaintList) {
        	idSet.add(objComplaint.id);    
        }
        
        list<complaint__c> complaintList = [SELECT id,
                                            	   rp_number__c,
                                            	   rp_running_number__c
                                                FROM complaint__c
                                             WHERE id IN :idSet AND
                                            recordtypeid = :Utility.getRecordTypeId ('complaint__c', ComplaintHandler.RETURNED_PRODUCT_COMPLAINT)
                                           ORDER by rp_running_number__c  ];
        list<auto_running_numbers__c> autoRunningNumbers = auto_running_numbers__c.getall().values();
        
        decimal i=1;
        for(complaint__c objComplaint : complaintList) { 
            system.assertEquals( i, objComplaint.rp_running_number__c , 'RP Running number Mismatch');
            system.assertEquals( GenerateAutoNumbersController.prefix + i.format().leftPad(5, '0').replaceAll(',',''),objComplaint.rp_number__c, 'RP Number Mismatch');
            i++;
        }  
        system.assert(autoRunningNumbers.size() > 0 && autoRunningNumbers[0].rp_number__c == i);
    }
    
    /**
     * Method checks if has OOS complaints checkbox is marked on 
     * updation of complaint with oos_report record type
     *
     * @return     void    
     * @author     SNPA 
     */
    private static testMethod void testComplaintUpdate() {
    	init();
        insert objComplaint;
        
        test.startTest();
        	objComplaint.asset__c = objectAsset.id;
        	update objComplaint;
        test.stopTest();
        
        objAsset = [SELECT id,
							has_attached_oos_complaints__c
                        FROM asset
                     WHERE id = :objAsset.id];
    	objectAsset = [SELECT id,
							has_attached_oos_complaints__c
                        FROM asset
                     WHERE id = :objectAsset.id];
        system.assert(objAsset.has_attached_oos_complaints__c == false);
        system.assert(objectAsset.has_attached_oos_complaints__c == true);
    }
    
    /**
     * Method checks if has OOS complaints checkbox is updated on 
     * deletion of complaint with oos_report record type
     *
     * @return     void    
     * @author     SNPA 
     */
    private static testMethod void testComplaintDelete() {
    	init();
        insert complaintList;
        
        test.startTest();
        	delete complaintList;
        test.stopTest();
        
        set<id> idSet = new set<id>();
        for(asset objAsset : assetList) {
        	idSet.add(objAsset.id);    
        }
        assetList = [SELECT id,
							has_attached_oos_complaints__c
                        FROM asset
                     WHERE id IN :idSet];
        for(asset objAsset : assetList) {
            system.assert(objAsset.has_attached_oos_complaints__c == false);
        }
                
    }
    
    /**
     * Method checks if has OOS complaints checkbox is updated on 
     * undelete of complaint with oos_report record type
     *
     * @return     void    
     * @author     SNPA 
     */
    private static testMethod void testComplaintUndelete() {
    	init();
        insert complaintList;
        delete complaintList;
        
        test.startTest();
        	undelete complaintList;	
        test.stopTest();
        
        set<id> idSet = new set<id>();
        for(asset objAsset : assetList) {
        	idSet.add(objAsset.id);    
        }
        assetList = [SELECT id,
							has_attached_oos_complaints__c
                        FROM asset
                     WHERE id IN :idSet];
        for(asset objAsset : assetList) {
            system.assert(objAsset.has_attached_oos_complaints__c == true);
        }
    }
}