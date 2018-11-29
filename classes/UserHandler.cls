/**
 * Trigger Handler for User Trigger to create and update Employee Contact on create and update of User record
 *
 * @author         snpa
 * @created        2018-05-09
 * @systemLayer    Handler
 *
 **/
public class UserHandler {

    @testVisible
    private static final String CONTACT_OBJ = 'Contact';
    private static final String ACCOUNT_OBJ = 'Account';
    private static final String ACCOUNT_NAMES = 'Biotronik Manufacturer';
	private static final Id manufacturerRecordType = Utility.getRecordTypeId(ACCOUNT_OBJ, Constants.RECORD_TYPE_NAME_ACCOUNT_MANUFACTURER);
    
    /**
     * Method called on after insert operation of User record
     * @param     userList    List of newly inserted Users
     * @return    void
     * @author    snpa
     *
     **/
    public void onAfterInsert(list<User> userList) {
        Set<Id> userIds = new Set<Id>();
        Set<String> sapCompanyCodes = new Set<String>();

        for( User objUser : userList) {
            userIds.add(objUser.id);
            if(objUser.sap_company_code__c != null) {
                sapCompanyCodes.add(objUser.sap_company_code__c);
            }
        }
        upsertContacts(userIds, sapCompanyCodes);
    }

    /**
     * Method called on after update of User record
     * @param     userList    List of updated User records
     * @return    void
     * @author    snpa
     *
     **/
    public void onAfterUpdate(map<id, User> userMap, map<id, User> oldUserMap) {
        Set<Id> userIds = new Set<Id>();
        Set<Id> changedManagerUsers = new Set<Id>();
        Set<String> sapCompanyCodes = new Set<String>();
        for( User objUser : userMap.values()) {
            userIds.add(objUser.id);
            if(objUser.sap_company_code__c != null) {
                sapCompanyCodes.add(objUser.sap_company_code__c);
            }
            if(objUser.managerId != oldUserMap.get(objUser.id).managerId || 
               objUser.manager_vi__c != oldUserMap.get(objUser.id).manager_vi__c) {
            	changedManagerUsers.add(objUser.id);    
            }
        }
        updateContactsOnUserChange(userIds, sapCompanyCodes);
        // Get related orders and call batch for sharing
        getOrdersAndCallBatch(oldUserMap, usermap, changedManagerUsers);
    }
	
    private void getOrdersAndCallBatch(map<id, User> oldUserMap, map<id, User> usermap, set<Id> userIds) {
        if(userIds != null && userIds.size() > 0) {
            Map<Id,Order> orderMap = new Map<Id,Order> ([SELECT id,
                                            rep_at_implant__c,
                                            rep_for_credit__c,
                                            pricebook__c
                                            FROM Order 
                                        WHERE rep_at_implant__c IN :userIds OR 
                                          rep_for_credit__c IN :userIds
                                                         ]);
            
            if(orderMap != null && orderMap.size() > 0) {
				BatchAllocateOrderSharing orderSharingBatch = new BatchAllocateOrderSharing(oldUserMap, usermap, orderMap.keySet());
				Database.executeBatch(orderSharingBatch);
			}
        }
    }
    
    /**
     * Asynchronous method to populate required data types to invoke changes to the Employee
     * Contact on change of the related User
     *
     * @param     userIds            Set of updated user ids
     * @param     sapCompanyCodes    Set of company code for the changed User records
     * @return    void
     * @author    snpa
     *
     **/
    @future
    private static void updateContactsOnUserChange(Set<Id> userIds, Set<String> sapCompanyCodes) {
        List<User> userList = getUserList(userIds);

        Map<id, contact> contactMap = new Map<Id, Contact>();
        for(contact objContact : [SELECT id, related_user__c
                                    FROM contact
                                  WHERE related_user__c IN :userIds]) {

            contactMap.put(objContact.related_user__c, objContact);
        }
        upsertContacts(userList, contactMap, sapCompanyCodes);
    }

    /**
     * Asynchronous method to invoke creation of Employee Contacts on creation of new Users
     *
     * @param     userIds            Set of inserted user ids
     * @param     sapCompanyCodes    Set of company code for the created User
     * @return    void
     * @author    snpa
     *
     **/
    @future
    private static void upsertContacts(Set<Id> userIds, Set<String> sapCompanyCodes){
        List<User> userList = getUserList(userIds);
        upsertContacts(userList, null, sapCompanyCodes);
    }


    /**
     * Method create or updates Employee Contacts on creation or updation of Users
     *
     * @param     userIds            Set of inserted / updated user ids
     * @param     contactMap         Map of Employees that are to be updated
     * @param     sapCompanyCodes    Set of company code for the created / updated User
     * @return    void
     * @author    snpa
     *
     **/
    private static void upsertContacts(List<User> userList,
                                        Map<id, contact> contactMap,
                                        Set<String> sapCompanyCodes) {
        List<Contact> contactList = new List<Contact>();
        Map<String, account> sapCompanyCodeAccountMap = getAccountsByCompany(sapCompanyCodes);
        Map<Contact, Account> contactsWithNewManufactuer = new Map<Contact, Account>();

        Id employeeRecordType = Utility.getRecordTypeId(CONTACT_OBJ, Constants.RECORD_TYPE_NAME_CONTACT_EMPLOYEE);
        
        for( user objUser : userList) {
            contact objContact;
            if(contactMap!= null && contactMap.containsKey(objUser.id)) {
                objContact = contactMap.get(objUser.id);
            }
            if(objContact == null) {
                objContact = new Contact();
            }
            objContact.firstname = objUser.firstname;
            objContact.middlename = objUser.middlename;
            objContact.lastname = objUser.lastname;
            objContact.email = objUser.email;
            objContact.fax = objUser.fax;
            objContact.phone = objUser.phone;
            objContact.related_user__c = objUser.id;
            objContact.recordTypeId = employeeRecordType;
            objContact.title = objUser.title;
            objContact.mobilephone = objUser.mobilephone;
            objContact.department = objUser.department;
            objContact.mailingstreet = objUser.street;
            objContact.mailingcity = objUser.city;
            objContact.mailingstate = objUser.state;
            objContact.mailingpostalcode = objUser.postalcode;
            objContact.mailingcountry = objUser.country;

            //  Assign Manufacturer Account to the Contact based on sap_company_code__c, if it
            // doesn't exist create a new Manufacturer for that company code
            if(!String.isBlank(objUser.sap_company_code__c) &&
                    sapCompanyCodeAccountMap != null &&
                    sapCompanyCodeAccountMap.containsKey(objUser.sap_company_code__c)) {

                objContact.accountId = sapCompanyCodeAccountMap.get(objUser.sap_company_code__c).id;
            } else if(!String.isBlank(objUser.sap_company_code__c)){
                Account newManufacturer = new Account(name = ACCOUNT_NAMES + ' ' +objUser.sap_company_code__c,
                                                        recordtypeid = manufacturerRecordType,
                                                        sap_company_code__c = objUser.sap_company_code__c
                                                     );
                contactsWithNewManufactuer.put(objContact, newManufacturer);
            }
            contactList.add(objContact);
        }
        try {
            if(!contactsWithNewManufactuer.isEmpty() && contactsWithNewManufactuer.size() > 0) {
                insert contactsWithNewManufactuer.values();
                for ( Contact employee : contactsWithNewManufactuer.keySet()) {
                    employee.accountId =  contactsWithNewManufactuer.get(employee).id;
                }
            }
            if(!contactList.isEmpty() && contactList.size() > 0) {
                upsert contactList;
            }
        } catch(Exception dmlException) {
            system.debug('An Exception has occured, Error : ' + dmlException.getMessage());
        }
    }

    /**
     * Method returns list of Users for given Ids
     *
     * @param     userIds            Set of inserted / updated user ids
     * @return    List<User>         Returns list of Users for given Ids
     * @author    snpa
     *
     **/
    private static List<User> getUserList(Set<Id> userIds) {
        return [SELECT id, firstname, middlename, lastname,
                        email, fax, phone, title, mobilephone,
                        department, street, city, postalcode,
                        country, state, sap_company_code__c
                    FROM User
                WHERE Id in :userIds];
    }

    /**
     * Method returns map of Company codes for Biotronik and related manufacturer Account for these codes
     *
     * @param     sapCompanyCodes            Set of users company code
     * @return    Map<String, Account>       Map of company codes and related Accounts
     * @author    snpa
     *
     **/
    private static Map<String, Account> getAccountsByCompany(Set<String> sapCompanyCodes) {
        Map<string, account> sapCompanyCodeAccountMap = new Map<String, Account>();
        for (Account objAccount : [SELECt id,
                                          sap_company_code__c
                                     FROM Account
                                   WHERE sap_company_code__c IN :sapCompanyCodes AND
                                  			recordtypeid = :manufacturerRecordType]) {
            sapCompanyCodeAccountMap.put(objAccount.sap_company_code__c, objAccount);
        }
        return sapCompanyCodeAccountMap;
    }
}