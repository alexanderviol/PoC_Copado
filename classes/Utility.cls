/**
 * Utility class for common methods
 * 
 * @author            SNPA
 * @created           2018-04-10
 * @systemLayer       Util 
 *  
 */
public class Utility {

    // static map to hold RecordTypes by developer Name if loaded
    private static Map<String, RecordType> recordTypes = new Map<String, RecordType>();

    // static map to hold UserRoles
    private static Map<Id, UserRole> userRoles = new Map<Id, UserRole>();

    // static map to hold ProfileIds
    private static Map<String, Profile> profilesByName = new Map<String, Profile>();

    //static map to hold Settings
    private static  Map<String,Setting__mdt> settings = new Map<String, Setting__mdt>();

    /**
     * get Profile Id by name
     *
     * @param name Name of Profile
     *
     * @return profile Id if existing; else null
     */
    public static Id getProfileId(String name) {
        loadProfiles();
        if (profilesByName.containsKey(name)) {
            return profilesByName.get(name).Id;
        }
        return null;
    }

    /**
     * get Profile name by Id
     *
     * @param id
     *
     * @return
     */
    public static String getProfileNameById(Id id) {
        loadProfiles();
        for (Profile profile : profilesByName.values()) {
            if (profile.id == id) {
                return profile.Name;
            }
        }
        return null;
    }

    /**
    * get Role name by Id
    *
    * @param id
    *
    * @return the User Role Name
    */
    public static String getUserRoleNameById(Id id) {
        loadUserRoles();
        if (userRoles.containsKey(id)) {
            return userRoles.get(id).DeveloperName;
        }
        return null;
    }

    /**
     * get Role name by Id
     *
     * @param developerName unique User Role Developer name
     *
     * @return the User Role Id
     */
    public static Id getUserRoleIdByName(String developerName) {
        loadUserRoles();
        for (UserRole userRole : userRoles.values()) {
            if (userRole.DeveloperName == developerName) {
                return userRole.id;
            }
        }
        return null;
    }

    /**
     * get Profile Id by name
     *
     * @param name Name of Profile
     *
     * @return profile Id if existing; else null
     */
    public static Set<Id> getProfileIds(List <String> names) {
        loadProfiles();
        Set<Id> ids = new Set<Id>();
        for (String name : names) {
            Id profId = getProfileId(name);
            if (profId == null) {
                ids.add(profId);
            }
        }
        return ids;
    }

    /**
     * To get all sub roles.
     *
     * @param     roleIds     Set of Role Ids
     * @return    Set<ID>     ids of current roles
     * @author     ARWE
     */
    public Static Set<ID> getAllSubRoleIds(Set<ID> roleIds) {

        loadUserRoles();

        Set<ID> currentRoleIds = new Set<ID>();

        // get all of the roles underneath the passed roles
        for (UserRole userRole : userRoles.values()) {
            if (roleIds.contains(userRole.ParentRoleId) && userRole.ParentRoleId != null) {
                currentRoleIds.add(userRole.id);
            }
        }

        // go fetch some more rolls!
        if (currentRoleIds.size() > 0) {
            currentRoleIds.addAll(getAllSubRoleIds(currentRoleIds));
        }

        return currentRoleIds;
    }

    private static void loadUserRoles() {
        if (userRoles.isEmpty()) {
            // get all of the parent roles.
            for (UserRole ur : [SELECT Id, ParentRoleId, DeveloperName FROM UserRole]) {
                userRoles.put(ur.Id, ur);
            }
        }
    }

    private static void loadProfiles() {
        if (profilesByName.isEmpty()) {
            for (Profile profile : [SELECT Id, Name FROM Profile]) {
                profilesByName.put(profile.Name, profile);
            }
        }
    }

    /**
     * To get all Parent Roles.
     *
     * @param     roleIds     Set of Role Ids
     * @return    Set<ID>     ids of current roles
     * @author     FH
     */
    public static Set<Id> getParentRoleId(Set<Id> roleIds) {

        loadUserRoles();

        Set<Id> currentRoleIds = new Set<Id>();

        for (Id roleId : roleIds) {
            Id parentRole = userRoles.get(roleId).ParentRoleId;
            if (parentRole != null) {
                currentRoleIds.add(parentRole);
            }
        }

        // go fetch some more rolls!
        if (currentRoleIds.size() > 0) {
            currentRoleIds.addAll(getParentRoleId(currentRoleIds));
        }

        return currentRoleIds;
    }

    /**
     * @deprecated objectName is not needed anymore
     * Reusable method to get the record type id for given object and developer name
     *
     * @param     objectName   API Name of Object
     * @param     devName      Developer name of record type
     * @return    id           Id of record type
     * @author    ARWE
     */
    public static Id getRecordTypeId(String objectName, String devName) {
        return getRecordTypeId(devName);
    }

    /**
     * Returns RecordTypeId if existing; else null
     * and will not consume any queries
     *
     * @param sObjectType the Schema.SObjectType of the object
     * @param developerName unique name of record type
     * @author ARWE
     */
    public static Id getRecordTypeId(Schema.SObjectType sObjectType, String developerName) {
        try {
            return sObjectType.getDescribe().getRecordTypeInfosByDeveloperName().get(developerName).getRecordTypeId();
        } catch (NullPointerException e) {
            // do nothing only return null
        }
        return null;
    }

    /**
     * Returns RecordTypeId from static cash
     * Queries RecordTypes if not allrady done
     *
     * @param developerName unique name of record type
     *
     * @return Id of the RecordType
     * @author ARWE
     */
    public static Id getRecordTypeId(String developerName) {

        if (recordTypes.isEmpty()) {
            recordTypes = new Map<String, RecordType>();
            for (RecordType recordType : [SELECT id, DeveloperName FROM RecordType]) {
                recordTypes.put(recordType.DeveloperName, recordType);
            }
        }

        if (recordTypes.containsKey(developerName)) {
            return recordTypes.get(developerName).Id;
        }
        return null;

    }

    /**
     * Rutruns value of the Custom Metatdata Setting
     * Queries Settings__mdt if not allrady done
     * @param Name Developer Name of the Setting
     * @param defaultValue Value if Metadata is not existing
     *
     * @return value of the Custom Metatdata Setting
     */
    public static String getSettingValue(String Name, String defaultValue ){
        if(settings.isEmpty()){
            for( Setting__mdt  setting : [SELECT Id, DeveloperName, value__c  FROM Setting__mdt]){
                settings.put(setting.DeveloperName, setting);
            }
        }

        Setting__mdt prop = settings.get(Name);
        if (prop == null || String.isBlank(prop.value__c)) {
            return defaultValue;
        }
        return prop.value__c;
    }

    /**
     * Checks if 'Allow users to relate a contact to multiple accounts' is enabled in the org or not
     *
     * @return  boolean		indicates whether 'Allow users to relate a contact to multiple accounts' setting is enabled or not?
     * @author	Sumit
     */
    public static Boolean isContToMultipleAccountsEnabled() {
        return Schema.getGlobalDescribe().keyset().contains('accountcontactrelation');
    }

    /* Returns the validation category a product type belongs to
     *
     * @param productType the product type in question
     * @return String containing the category or null
     * @author Florian Heer <f.heer@conciscon.de> 2018-09-25 SAFBIO-2178
     */
    public static String getValidationCategory(String productType) {
        List<String> validationCategories = new List<String>{
                Constants.VALI_CAT_LEAD, Constants.VALI_CAT_DEVICE, Constants.VALI_CAT_CARDIO_MESSENGER, Constants.VALI_CAT_SYSTEM
                , Constants.VALI_CAT_NA, Constants.VALI_CAT_LOOP_RECORDER
        };

        for (String cat : validationCategories) {
            if (getContainedProductTypes(cat).contains(productType)) {
                return cat;
            }
        }
        return null;
    }

    /* Returns a Set of Strings that contain all product types for a validation category
     *
     * @param validationCategory the category to be queried.
     * @return List with product types in the validation category
     * @author Florian Heer <f.heer@conciscon.de> 2018-09-25 SAFBIO-2178
     */
    public static List<String> getContainedProductTypes(String validationCategory) {
        List<String> retVal = new List<String>();
        if (validationCategory == Constants.VALI_CAT_DEVICE) {
            retVal.add(Constants.PICKLIST_VALUE_PRODUCT_TYPE_CRT_D);
            retVal.add(Constants.PICKLIST_VALUE_PRODUCT_TYPE_CRT_P);
            retVal.add(Constants.PICKLIST_VALUE_PRODUCT_TYPE_ICD);
            retVal.add(Constants.PICKLIST_VALUE_PRODUCT_TYPE_PACEMAKER);
        } else if (validationCategory == Constants.VALI_CAT_CARDIO_MESSENGER) {
            retVal.add(Constants.PICKLIST_VALUE_PRODUCT_TYPE_CARDIO_MESSENGER);
        } else if (validationCategory == Constants.VALI_CAT_SYSTEM) {
            retVal.add(Constants.PICKLIST_VALUE_PRODUCT_TYPE_SYSTEM_DEVICE);
        } else if (validationCategory == Constants.VALI_CAT_LOOP_RECORDER) {
            retVal.add (Constants.PICKLIST_VALUE_PRODUCT_TYPE_LOOP_RECORDER);
        } else if (validationCategory == Constants.VALI_CAT_LEAD) {
            retVal.add(Constants.PICKLIST_VALUE_PRODUCT_TYPE_LEAD);
            retVal.add(Constants.PICKLIST_VALUE_PRODUCT_TYPE_BRADY_LEAD);
            retVal.add(Constants.PICKLIST_VALUE_PRODUCT_TYPE_TACHY_LEAD);
            retVal.add(Constants.PICKLIST_VALUE_PRODUCT_TYPE_LV_LEAD);
        }
        else if (validationCategory == Constants.VALI_CAT_NA) {
            retVal.add(Constants.PICKLIST_VALUE_PRODUCT_TYPE_ACCESSORY);
            retVal.add(Constants.PICKLIST_VALUE_PRODUCT_TYPE_PLUG);
            retVal.add(Constants.PICKLIST_VALUE_PRODUCT_TYPE_ADAPTER);
            retVal.add('Cardiac Device Envelope');
            retVal.add('CVI');
            retVal.add('External Diagnostic');
            retVal.add('External pacemaker');
            retVal.add(Constants.PICKLIST_VALUE_PRODUCT_TYPE_HOME_MONITORING_SERVICE);
            retVal.add(Constants.PICKLIST_VALUE_PRODUCT_TYPE_PROGRAMMER);
            retVal.add('PVI');
            retVal.add('Zero Gravity');
            retVal.add('Zero Gravity Drapes');
        }

        return retVal;
    }
    
    /** tests, if a product type is an ICD
     * @param productType name of the product type in question
     */
    public static Boolean isProductTypeICD (String productType) {
        return productType == Constants.PICKLIST_VALUE_PRODUCT_TYPE_ICD 
            || productType == Constants.PICKLIST_VALUE_PRODUCT_TYPE_CRT_D;
    }
    
    
    /** Informs, if a product type is implantable and can be serialized.
     * 
     * @param productType name of the product type in question
     */
    private static Set<String> implantableSerializedProductTypes;
    
    public static Boolean isImplantableSerialized (String productType) {
        if (implantableSerializedProductTypes == null || implantableSerializedProductTypes.size() == 0) {
            implantableSerializedProductTypes = new Set<String> ();
            implantableSerializedProductTypes.add(Constants.PICKLIST_VALUE_PRODUCT_TYPE_PLUG);
            implantableSerializedProductTypes.add(Constants.PICKLIST_VALUE_PRODUCT_TYPE_ADAPTER);
            implantableSerializedProductTypes.add(Constants.PICKLIST_VALUE_PRODUCT_TYPE_CRT_D);
            implantableSerializedProductTypes.add(Constants.PICKLIST_VALUE_PRODUCT_TYPE_CRT_P);
            implantableSerializedProductTypes.add(Constants.PICKLIST_VALUE_PRODUCT_TYPE_ICD);
            implantableSerializedProductTypes.add(Constants.PICKLIST_VALUE_PRODUCT_TYPE_CRT_P);
            implantableSerializedProductTypes.add(Constants.PICKLIST_VALUE_PRODUCT_TYPE_LEAD);
            implantableSerializedProductTypes.add(Constants.PICKLIST_VALUE_PRODUCT_TYPE_BRADY_LEAD);
            implantableSerializedProductTypes.add(Constants.PICKLIST_VALUE_PRODUCT_TYPE_TACHY_LEAD);
            implantableSerializedProductTypes.add(Constants.PICKLIST_VALUE_PRODUCT_TYPE_LV_LEAD);
            implantableSerializedProductTypes.add(Constants.PICKLIST_VALUE_PRODUCT_TYPE_LOOP_RECORDER);
            implantableSerializedProductTypes.add(Constants.PICKLIST_VALUE_PRODUCT_TYPE_PACEMAKER);
        }
        
        return implantableSerializedProductTypes.contains(productType);
    }

    /** Checks if a product type belongs to the group 'device' when it comes to printing. 
     * This is only partly related to validation categories.
     */
    private static Set<String> deviceDefinitionsForPrinting;
    
    public static Boolean isDeviceForPrinting (String productType) {
        if(deviceDefinitionsForPrinting == null || deviceDefinitionsForPrinting.size() == 0) {
            deviceDefinitionsForPrinting = new Set<String> ();
            deviceDefinitionsForPrinting.addAll (getContainedProductTypes (Constants.VALI_CAT_DEVICE));
            deviceDefinitionsForPrinting.addAll (getContainedProductTypes (Constants.VALI_CAT_LOOP_RECORDER));
        }
        
        return deviceDefinitionsForPrinting.contains(productType);
    }
    
    public static Set<String> getDevicesForPrinting () {
        if (deviceDefinitionsForPrinting == null) isDeviceForPrinting('init, please');
        return deviceDefinitionsForPrinting;
    }
    
    /** Checks if a product type belongs to leads or adapters - common category for documents
     */
    private static Set<String> leadsOrAdaptersDefinitionsForPrinting;
    
    public static Boolean isLeadOrAdapterForPrinting (String productType) {
        if(leadsOrAdaptersDefinitionsForPrinting == null ||leadsOrAdaptersDefinitionsForPrinting.size () == 0) {
            leadsOrAdaptersDefinitionsForPrinting = new Set<String> ();
            leadsOrAdaptersDefinitionsForPrinting.addAll (getContainedProductTypes (Constants.VALI_CAT_LEAD));
            leadsOrAdaptersDefinitionsForPrinting.add (Constants.PICKLIST_VALUE_PRODUCT_TYPE_ADAPTER);
        }
        
        return leadsOrAdaptersDefinitionsForPrinting.contains (productType);
        
    }
    
    /** Checks if a product status is one of the explanted.
     */
	private static Set<String> explantedDeviceStatus;
    
    public static Boolean isExplantedDeviceStatus (String statusString) {
        if (explantedDeviceStatus == null || explantedDeviceStatus.size() == 0) 
        {
            explantedDeviceStatus = new Set<String> 
            {
                Constants.IMPLANT_STATUS_EXPLANTED, Constants.IMPLANT_STATUS_DECEASED, 
                    Constants.IMPLANT_STATUS_CAPPED, Constants.IMPLANT_STATUS_DISCARDED
             };
		}
        
        System.debug ('List: ' + explantedDeviceStatus);
        System.debug ('Type to check: ' + statusString);
        
        return explantedDeviceStatus.contains (statusString);
    }

    
    /**
    * This method compares two sets of Stings
    *
    * @param firstSet one Set
    * @param secondSet a other set
    *
    * @return Set of Strings that are containing in both input sets
    */
    public static Set<String> containsInBoth(Set<String> firstSet, Set<String> secondSet) {

        Set<String> containedInBoth = new Set<String>();

        if (firstSet != null && secondSet != null ) {

            for (String key : firstSet) {
                if (secondSet.contains(key)) {
                    containedInBoth.add(key);
                }
            }
        }

        return containedInBoth;
    }
	
    public static String FormatPhone(String Phone) {
      string nondigits = '[^0-9]';
      string PhoneDigits;
      
      // remove all non numeric
      PhoneDigits = Phone.replaceAll(nondigits,'');
      
      // 10 digit: reformat with dashes
      if (PhoneDigits.length() == 10) 
        return '(' + PhoneDigits.substring(0,3) + ') ' +
               PhoneDigits.substring(3,6) + '-' +
               PhoneDigits.substring(6,10);
      // 11 digit: if starts with 1, format as 10 digit 
      if (PhoneDigits.length() == 11) {
        if (PhoneDigits.substring(0,1) == '1') {
          return  '(' + PhoneDigits.substring(1,4) + ') ' +
                  PhoneDigits.substring(4,7) + '-' +
                  PhoneDigits.substring(7,11);
        }
      }
     
      // if it isn't a 10 or 11 digit number, return the original because
      // it may contain an extension or special information
      return( Phone );
    }
    
    /**
     * removes entries from a map by a given set of Strings
     *
     * @param map A map with String values as Key
     * @param toDelete set of entries you want to remove
    */
    public static void removeFromMap(Map<String, Object> mapToReduce, Set<String> toDelete){
        for (String key : toDelete){
            mapToReduce.remove(key);
        }
    }

    /**
     * Only for printing out Limits to Debug
     */
    public static void printLimits(){
        System.debug('################# Limits #################');
        System.debug('Queries           : '+  Limits.getQueries()+ '/' + Limits.getLimitQueries());
        System.debug('Query Rows        : '+  Limits.getQueryRows()+ '/' + Limits.getLimitQueryRows());
        System.debug('Aggregate Queries : '+  Limits.getAggregateQueries()+ '/' + Limits.getLimitAggregateQueries());
        System.debug('Dml Rows          : '+  Limits.getDmlRows()+ '/' + Limits.getLimitDmlRows());
        System.debug('Dml Statements    : '+  Limits.getDmlStatements()+ '/' + Limits.getLimitDmlStatements());
        System.debug('HeapSize          : '+  Limits.getHeapSize()+ '/' + Limits.getLimitHeapSize());
        System.debug('CPU Time          : '+  Limits.getCpuTime() + '/' + Limits.getLimitCpuTime());
        System.debug('##########################################');
    }
    
    /**
     * To get custom Setting value
     * @param orderId Id of Order rec.
     */
    public static Boolean toSkipValidation(String orderId) {
      return skip_validation__c.getValues(orderId) == null ? false : skip_validation__c.getValues(orderId).to_skip_validation__c;
    }

    public static void insertValidationSkip(String orderId) {
        skip_validation__c skipValidation = new skip_validation__c(Name = orderId, to_skip_validation__c = true);
        insert skipValidation;
    }

    public static void removeValidationSkip(String orderId) {
        skip_validation__c skipValidation = skip_validation__c.getValues(orderId);
        if(skipValidation != null) {
            delete skipValidation;
        }
    }
}