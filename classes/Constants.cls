/**
* @author:			arwe
*					T-Systems Multimedia Solutions GmbH
*					Riesaer Strasse 5,
*					01129 Dresden
*					www.t-systems-mms.com
*
* @description      Common used constants
*
*
* @date             25.09.2018
*/

public with sharing class Constants {
	
    // User Role
    public final static String ROLE_BINC_MDR = 'BINC_Medical_Device_Reporting'; 
    
    // Account Record Types
    public final static String RECORD_TYPE_NAME_ACCOUNT_MANUFACTURER = 'Manufacturer_Account';
    public final static String RECORD_TYPE_NAME_ACCOUNT_PATIENT = 'patient_account';
    public final static String RECORD_TYPE_NAME_ACCOUNT_PHYSICIAN = 'Physician_Account';
    public final static String RECORD_TYPE_NAME_ACCOUNT_US = 'x5500_us_account';

    // Contact Record Types
    public final static String RECORD_TYPE_NAME_CONTACT_US_PHYSICIAN = 'us_physician';
    public final static String RECORD_TYPE_NAME_CONTACT_US_PATIENT = 'us_patient';
    public final static String RECORD_TYPE_NAME_CONTACT_OTHER = 'Other_Contact';
    public final static String RECORD_TYPE_NAME_CONTACT_EMPLOYEE = 'X5500_Employee_Contact';

    // Order Record Types
    public final static String RECORD_TYPE_NAME_ORDER_MDRF = 'mdrf_order';
    public final static String RECORD_TYPE_NAME_ORDER_CARDIO_MESSENGER = 'cardio_messenger_order';

    // Asset Record Types
    public final static String RECORD_TYPE_NAME_ASSET_SYSTEM = 'System';
    public final static String RECORD_TYPE_NAME_ASSET_US_COMPETITOR = 'US_CompetitorAsset';
    public final static String RECORD_TYPE_NAME_ASSET_US_BIOTRONIK = 'US_BIOAsset';

    // Asset OOS Reason Picklist values
    public static final String PICKLIST_VALUE_OOS_REASON_ERI = 'ERI';
    public static final String PICKLIST_VALUE_OOS_REASON_PATIENT_DEATH = 'Patient Death';
    public static final String PICKLIST_VALUE_OOS_REASON_UPGRADE = 'Upgrade';

    // Product Record Types
    public final static String RECORD_TYPE_NAME_PRODUCT = 'Product';
    public final static String RECORD_TYPE_NAME_PRODUCT_SERVICE = 'Service';
    public final static String RECORD_TYPE_NAME_PRODUCT_SYSTEM = 'System';
    
    //ProductItem Record Types
    public final static String RECORD_TYPE_NAME_PRODUCT_ITEM = 'biotronik_product';

    //Complaint Record Types
    public final static String RECORD_TYPE_NAME_COMPLAINT_OUS = 'OUS_OEM_Report';


    // Picklist Values for Product Types
    public static final String PICKLIST_VALUE_PRODUCT_TYPE_ACCESSORY ='Accessory';
    public static final String PICKLIST_VALUE_PRODUCT_TYPE_ADAPTER ='Adapter';
    public static final String PICKLIST_VALUE_PRODUCT_TYPE_CARDIO_MESSENGER = 'Cardio Messenger';
    public static final String PICKLIST_VALUE_PRODUCT_TYPE_CRT_D = 'CRT-D';
    public static final String PICKLIST_VALUE_PRODUCT_TYPE_CRT_P = 'CRT-P';
    public static final String PICKLIST_VALUE_PRODUCT_TYPE_LOOP_RECORDER = 'Loop Recorder';
    public static final String PICKLIST_VALUE_PRODUCT_TYPE_SYSTEM_DEVICE = 'System';
    public static final String PICKLIST_VALUE_PRODUCT_TYPE_ICD = 'ICD';
    public static final String PICKLIST_VALUE_PRODUCT_TYPE_LEAD ='Lead';
    public static final String PICKLIST_VALUE_PRODUCT_TYPE_BRADY_LEAD ='Brady Lead';
    public static final String PICKLIST_VALUE_PRODUCT_TYPE_TACHY_LEAD ='Tachy Lead';
    public static final String PICKLIST_VALUE_PRODUCT_TYPE_LV_LEAD ='LV Lead';
    public static final String PICKLIST_VALUE_PRODUCT_TYPE_PACEMAKER = 'Pacemaker';
    public static final String PICKLIST_VALUE_PRODUCT_TYPE_PLUG = 'Plug';

    // @deprecated Inactive, but still in Use for tests
    public static final String PICKLIST_VALUE_PRODUCT_TYPE_DEVICE = 'Device';
    public static final String PICKLIST_VALUE_PRODUCT_TYPE_HOME_MONITORING_SERVICE = 'Home Monitoring Service';

    public static final String PICKLIST_VALUE_PRODUCT_TYPE_PROGRAMMER = 'Programmer';
    public static final String PICKLIST_VALUE_PRODUCT_TYPE_SERVICE = 'Service';

    // Picklist Values for Order Status (global Picklist)
    public static final String PICKLIST_VALUE_STATUS_CANCELLED = 'Cancelled';
    public static final String PICKLIST_VALUE_STATUS_INVOICED = 'Invoiced';
    public static final String PICKLIST_VALUE_STATUS_NOT_SUBMITTED = 'Not Submitted';
    public static final String PICKLIST_VALUE_STATUS_ORDER_CLEARING_QUEUE = 'Order Clearing Queue';
    public static final String PICKLIST_VALUE_STATUS_PROCESSING = 'Processing';
    public static final String PICKLIST_VALUE_STATUS_SUBMITTED = 'Submitted';
    public static final String PICKLIST_VALUE_STATUS_UNDELIVERABLE = 'Undeliverable';
    public static final String PICKLIST_VALUE_STATUS_SUCCESSFFUL = 'Successful';
    public static final String PICKLIST_VALUE_STATUS_SHIPPED = 'Shipped';
    public static final String PICKLIST_VALUE_STATUS_SOE_HOLD = 'SOE Hold';
    public static final String PICKLIST_VALUE_STATUS_REP_PROVIDED_CM = 'Rep Provided CM';
    public static final String PICKLIST_VALUE_STATUS_READY_TO_VERIFY = 'Ready to verify';
    public static final String PICKLIST_VALUE_STATUS_READY_TO_SHIP = 'Ready to ship';
    public static final String PICKLIST_VALUE_STATUS_NOT_REGISTERED = 'Not registered';
    public static final String PICKLIST_VALUE_STATUS_NEW_REQUEST = 'New request';
    public static final String PICKLIST_VALUE_STATUS_EXCEPTIONS = 'Exceptions';
    public static final String PICKLIST_VALUE_STATUS_ADDRESS_PENDING = 'Address pending';

    // Picklist Values for Order Status
    public static final String PICKLIST_VALUE_ORDER_STATUS_NOT_SUBMITTED = 'Not Submitted';
    public static final String PICKLIST_VALUE_ORDER_STATUS_SUBMITTED_PROCESSING = 'Submitted for Processing';
    public static final String PICKLIST_VALUE_ORDER_STATUS_PENDING_HMSC = 'Pending HMSC Registration';
    public static final String PICKLIST_VALUE_ORDER_STATUS_PENDING_REVIEW = 'Pending Review';
    public static final String PICKLIST_VALUE_ORDER_STATUS_PENDING_SAP = 'Pending SAP Submission';
    public static final String PICKLIST_VALUE_ORDER_STATUS_SAP_SUBMISSION_BLOCKED = 'SAP Submission Blocked';
    public static final String PICKLIST_VALUE_ORDER_STATUS_SAP_ERROR = 'SAP Error Review';
    public static final String PICKLIST_VALUE_ORDER_STATUS_PROCESSED_SAP = 'Processed to SAP';
    public static final String PICKLIST_VALUE_ORDER_STATUS_INVOICED = 'Invoiced';
    public static final String PICKLIST_VALUE_ORDER_STATUS_SHIPPED = 'Shipped';
    public static final String PICKLIST_VALUE_ORDER_STATUS_CANCELED = 'Canceled';

    // Picklist Values for Order Item Stock Type
    public static final String PICKLIST_VALUE_ORDER_ITEM_STOCK_TYPE_BULK = 'B';

    // Picklist Values for Order Item Price Discrepancy Reason
    public static final String PICKLIST_VALUE_ORDER_ITEM_DISCREPANY_REASON_BULKSWAP = 'Bulk Swap';
    public static final String PICKLIST_VALUE_ORDER_ITEM_DISCREPANY_OTHER = 'Other';
    public static final String PICKLIST_VALUE_ORDER_ITEM_DISCREPANCY_REASON_DONATION = PICKLIST_VALUE_ORDER_ITEM_DISCREPANY_OTHER;
	
    // Picklist Values for order Item Status 
    public static final String PICKLIST_STATUS_ORDER_ITEM_IMPLANTED = 'Implanted';
    public static final String PICKLIST_STATUS_ORDER_ITEM_NOT_IMPLANTABLE_PRODUCT = 'Not Implantable Product';
    
    // Picklist Values for Contact Status
    public static final String PICKLIST_VALUE_CONTACT_STATUS_ACTIVE = 'Active';
    public static final String PICKLIST_VALUE_CONTACT_STATUS_CHANGE = 'Change';
    public static final String PICKLIST_VALUE_CONTACT_STATUS_DECEASED = 'Deceased';
    public static final String PICKLIST_VALUE_CONTACT_STATUS_DUPLICATE = 'Duplicate';
    public static final String PICKLIST_VALUE_CONTACT_STATUS_INACTIVE = 'Inactive';
    public static final String PICKLIST_VALUE_CONTACT_STATUS_NEW = 'New';
    public static final String PICKLIST_VALUE_CONTACT_STATUS_RETIREMENT = 'Retirement';
    public static final String PICKLIST_VALUE_CONTACT_STATUS_UNKNOWN = 'Unknown';

    // Picklist Values for Lead_Tip_location
    public static final String PICKLIST_VALUE_LEAD_TIP_LOCATION_UNKNOWN = 'UNKNOWN';
    
    // Values for WorkOrder Status Picklist
    public static final String PICKLIST_STATUS_VALUE_WORK_ORDER_NOT_SUBMITTED = 'Not Submitted';
    public static final String PICKLIST_STATUS_VALUE_WORK_ORDER_TRANSMITTED = 'Transmitted';
    public static final String PICKLIST_STATUS_VALUE_WORK_ORDER_CANCELED = 'Canceled';
    
    // Values for WorkOrder lineItem Status Picklist
    public static final String PICKLIST_STATUS_VALUE_WORK_ORDER_LINE_ITEM_NOT_SUBMITTED = 'Not Submitted';
    public static final String PICKLIST_STATUS_VALUE_WORK_ORDER_LINE_ITEM_TRANSMITTED = 'Transmitted';
    public static final String PICKLIST_STATUS_VALUE_WORK_ORDER_LINE_ITEM_CANCELED = 'Canceled';
    
    // Values for asset Status Picklist
    public static final String PICKLIST_STATUS_ASSET_IMPLANTED = 'Implanted';
    public static final String PICKLIST_STATUS_ASSET_NOT_IMPLANTABLE_PRODUCT = 'Not Implantable Product';

    // Values for Product Type Validation Categories
    public static final String VALI_CAT_LEAD 				= 'Lead';
    public static final String VALI_CAT_DEVICE 				= 'Device';
    public static final String VALI_CAT_LOOP_RECORDER		= 'Loop Recorder';
    public static final String VALI_CAT_SYSTEM				= 'System';
    public static final String VALI_CAT_CARDIO_MESSENGER	= 'Cardio Messenger';
    public static final String VALI_CAT_NA					= 'n/a';


    // Temporary Values for implant status. Changes to Constants-Class which are not yet merged, might contain these values in different constants.
    public static final String IMPLANT_STATUS_IMPLANTED = 'Implanted';
    public static final String IMPLANT_STATUS_EXPLANTED = 'Explanted';
    public static final String IMPLANT_STATUS_CAPPED = 'Capped';
    public static final String IMPLANT_STATUS_PARTIALLYCAPPED = 'Partially Capped';
    public static final String IMPLANT_STATUS_DECEASED = 'Patient Deceased';
    public static final String IMPLANT_STATUS_DISCARDED = 'Discarded';
    public static final Set<String> OOS_STATUS = new Set<String> {IMPLANT_STATUS_EXPLANTED, IMPLANT_STATUS_DISCARDED, IMPLANT_STATUS_CAPPED};

    // Biotronik hard coded references
    public static final String HOME_MONITORING_SERVICE_SAP_EXTERNAL_ID = '5500_358364';
    public static final String HOME_MONITORING_SERVICE_SAP_MODEL = '358364';
    public static final String STANDARD_PRICEBOOKS_NAMING_SUBSTRING = '_STANDARD_';

    // Account Shipping States
    public static final String ACCOUNT_SHIPPING_STATE_PUERTO_RICO = 'Puerto Rico';

    // Profile Names
    public static final String PROFILE_NAME_SALES = 'Sales';
    public static final String PROFILE_NAME_SYSTEM_ADMIN = 'System Administrator';
    public static final String PROFILE_NAME_SYSTEM_MMS_FUNC = 'MMS FUNC';
    public static final String PROFILE_NAME_SYSTEM_MMS_INSIDE_SALES = 'Inside Sales';
    public static final String PROFILE_NAME_SYSTEM_MMS_LIMITED_ACCESS = 'Limited Access';
    public static final String PROFILE_NAME_HMSC = 'HMSC';

    // User Role Names
    public static final String USER_ROLE_NAME_CS = 'BINC_Customer_Solutions';
    public static final String USER_ROLE_NAME_SO = 'BINC_Sales_Operations';

    // Referenced fields
    public static final String PRICEBOOK_FIELDS_ON_ACCOUNT = 'crm_pricebook__c,pvi_pricebook__c,cvi_pricebook__c';

    // Sharing Access Level
    public static final String SHARING_ACCESS_LEVEL_READ = 'Read';
    public static final String SHARING_ACCESS_LEVEL_EDIT = 'Edit';

    // Validation Reason
    public static final String PICKLIST_VALIDATION_REASON_NONE = 'None';
    public static final String PICKLIST_VALIDATION_REASON_MORE_THAN_ONE_DEVICE_ON_MDRF = 'More than 1 Device on MDRF';
    public static final String PICKLIST_VALIDATION_REASON_ZERO_DOLLAR_PRODUCT_OUTSIDE_SYSTEM = '$0 Product outside System';
    public static final String PICKLIST_VALIDATION_REASON_BULK_PRODUCT_WITH_PRICE_GREATER_ZERO = 'Bulk Product with Price > $0';
    public static final String PICKLIST_VALIDATION_REASON_PART_OF_SYSTEM_AND_PRICE_GREATER_ZERO = 'Part of System & Price > $0';
    public static final String PICKLIST_VALIDATION_REASON_DONATION = 'Donation**';
    public static final String PICKLIST_VALIDATION_REASON_IMPLANTING_FACILITY_IN_PUERTO_RICO = 'Implanting facility in Puerto Rico**';
    public static final String PICKLIST_VALIDATION_REASON_DEVICE_WITH_NO_LEADS = 'Device with no leads';
    public static final String PICKLIST_VALIDATION_REASON_DEVICE_WITH_ONLY_ONE_LEAD = 'Device with only one Lead';
    public static final String PICKLIST_VALIDATION_REASON_LEAD_WITH_NO_DEVICE = 'Lead with no Device';
    public static final String PICKLIST_VALIDATION_REASON_PRICE_DISCREPANCY_REASON_BULK_SWAP = 'Price Discrepancy Reason = Bulk swap';
	
    // Order Types
    public final static String CRM_ORDER = 'CRM'; 
    public final static String CVI_ORDER = 'CVI'; 
    public final static String PVI_ORDER = 'PVI'; 

    // Mappings
    public static final Map<String, String> ACCOUNT_FIELD_TO_PRICEBOOK_TYPE = new Map<String, String> {
            'crm_pricebook__c' => 'CRM', 'pvi_pricebook__c' => 'PVI', 'cvi_pricebook__c' => 'CVI'
    };

}