/**
 *
 *  This class contain methods required to generate permanent ID card as well as updates 'Patient id card created' field on contact.
 * 
 * @author				Sumit
 * @created             2018-04-08
 * @systemLayer    		Extension
 *  
 */
public with sharing class PermanentIdcardGenerator {
    public List<PatientAndAssetInfo> patAndAssetInfoList{get;set;}
    public List<Contact> conList{get;set;}
    public String contType{get;set;}
    public boolean renderPanel{get;set;}
    public Integer noOfContacts{get;set;}
    public String conIds{get;set;}
    public String  isFLSExceptionOccured{get;set;}
    
    /**
     * Class Constructor  
     * @param     stdController     Standard Set controller
     * @author    Sumit
     */
    public PermanentIdcardGenerator(ApexPages.StandardSetController controller) {
        isFLSExceptionOccured = 'false';
		conList = (List<Contact>) controller.getSelected();
        conIds = '';
        for(Contact c : conList) {
        	conIds += c.Id + ',';	    
        }
        contType = '';
        renderPanel = false;
        PatAndAssetInfoList = new List<PatientAndAssetInfo>();
        noOfContacts = conList.size();
    }
    
    /**
     * Class Constructor  
     * @param     stdController     Standard controller
     * @author    Sumit
     */
    public PermanentIdcardGenerator(ApexPages.StandardController stdController) {
        isFLSExceptionOccured = 'false';
        String id = stdController.getId();
        Contact cont = (Contact)stdController.getRecord();
        conList = new List<Contact>{cont};
        conIds = cont.id;
        renderPanel = false;
        PatAndAssetInfoList = new List<PatientAndAssetInfo>();
        noOfContacts = conList.size();
    }

    /**
     * Method that updates patient_id_card_created__c field on contact
     * @return     pagereference     Returns page reference.
     * @author    Sumit
     */
    public pagereference updatePrintDate() {
        Savepoint sp;
        List<Contact> conListToupdate = new List<Contact>();
        List<String> patientIds = new List<String>();
        renderPanel = true;
		Date today = Date.today();
        for(Contact con : conList) {
            con.patient_id_card_created__c = today;
			conListToupdate.add(con);
            patientIds.add(((String)(con.id)).trim());
        }      
        try {          
            if(conListToupdate != null && conListToupdate.size() > 0) {
                
                if(!FLSEnforcer.isUpdatable('Contact', new List<String>{'patient_id_card_created__c'})) {
                    isFLSExceptionOccured = 'true';
                	ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, System.Label.NO_PERMISSION_TO_UPDATE));
                    return null;
                }
            	   
                try {
                    update conListToupdate;    
                } catch (Exception e) {
                    throw e;
                }
 
            	PatAndAssetInfoList = getPatientInformation(patientIds);
            	contType = 'application/msword#PermanentIdCards.doc';    
            }	
        } catch(Exception e) {
            //Rollback update if any exception happens while generating the word document
            if(sp != null) {
                Database.rollback(sp);
            }
            throw e;
        }
        return null;
    }
    
    /**
     * Method that check whether all selected records are patient or not?
     * @return     String     Returns a string flag after validating the input.
     * @author    Sumit
     */
	@RemoteAction
    public static String isAllPatients(String conIds) {
        String strToReturn = 'No Records Selected';
        if(conIds == null || conIds == '' ) {
            return strToReturn;
        } 
        conIds = (conIds.contains('[') && conIds.contains(']')) ? conIds.substring(1, conIds.length()-1) : conIds;
        if(conIds == null || conIds == '' || conIds.trim() == null || conIds.trim() == '') {
            return strToReturn;
        }
        List<String> contactIds = new List<String>();
        List<String> tempIds = conIds.split(',');
        for(String cid : tempIds) {
            contactIds.add(cid.trim());
        }
        strToReturn = String.valueof(contactIds.size());
		List<Contact> patientList = [SELECT id, recordtype.developerName 
                                     FROM Contact 
                                     WHERE id IN : contactIds 
                                     AND recordtype.developerName =: Constants.RECORD_TYPE_NAME_CONTACT_US_PATIENT];
        if(patientList.size() != contactIds.size()) {
            strToReturn = 'Not All Patients';           
        }
        return strToReturn;      
    } 
    
    /** 
	 * Method that returns the records to display on permanent Id card Visualforce Page
	 * @param	patientids	List holding patient record Ids 
	 * @return	contList	List of contact records
	 * @author    Sumit
	 */
    private List<PatientAndAssetInfo> getPatientInformation(List<String> patientids) {
        Map<id, List<Asset>> assetMap = new Map<Id,List<Asset>>();
        Set<String> deviceTypes = Utility.getDevicesForPrinting ();
        //Selecting the 'Lead' Assets and putting them into a map
        for(Asset ast : [SELECT 
                         	ContactId, 
                         	Name, 
                         	SerialNumber,
                         	InstallDate,
                         	patient__c
                         FROM Asset 
                         WHERE patient__c IN : patientids 
                         AND product_type__c  =: Constants.VALI_CAT_LEAD
                         AND Status =: Constants.IMPLANT_STATUS_IMPLANTED
                         Order by patient__c]) {
        	if(assetMap.containsKey(ast.patient__c)) {
            	assetMap.get(ast.patient__c).add(ast);
            } else {
            	assetMap.put(ast.patient__c, new List<Asset>{ast});
            }
        }
        
        //only one Parent Asset per contact
        for( Contact cont : [SELECT id, 
                             		firstName, 
                             		middlename, 
                             		lastName, 
                             		MailingStreet, 
                             		MailingCity, 
                             		MailingState, 
                             		MailingCountry, 
                             		MailingPostalCode, 
                             		Phone, 
                             		Birthdate,
                                 	following_physician__r.firstName, 
                             		following_physician__r.middlename, 
                             		following_physician__r.lastName,
                                  	following_physician__r.MailingStreet, 
                             		following_physician__r.MailingCity, 
                             		following_physician__r.MailingState, 
                             		following_physician__r.MailingCountry, 
                             		following_physician__r.MailingPostalCode,
                                  	following_physician__r.Phone,
                                 	(SELECT 
                                         id, 
                                         Name, 
                                         SerialNumber, 
                                         InstallDate,
                                     	 product_type__c
                                     FROM Assets 
                                  	 WHERE Status =: Constants.IMPLANT_STATUS_IMPLANTED
                                     AND product_type__c IN : deviceTypes)
                            FROM Contact 
                         	WHERE id IN : patientids]) { 
                                    
			List<Asset> tempList = new List<Asset>();
            if(assetMap != null && assetMap.get(cont.id) != null ) {
            	tempList = assetMap.get(cont.id);	    
            }   
            patAndAssetInfoList.add(new PatientandAssetInfo(cont,
                                                            cont.Phone == null ? null : Utility.FormatPhone(cont.Phone),
                                                            cont.following_physician__c == null ? 
                                                            	null : Utility.FormatPhone(cont.following_physician__r.phone),
                                                            (5 - ( ((tempList == null || tempList.size() == null) ? 0 : tempList.size()) + 
                                                                  (cont.Assets == null ?  0 : cont.Assets.size()))), 
                                                            tempList));                                
        }
        return patAndAssetInfoList;
    }
     
	//Wrapper Class
    public class PatientAndAssetInfo {
        public Contact con {get;set;}
        public string patientPhone {get;set;}
        public string physicianPhone {get;set;}
        public integer totalSpaces {get;set;}
        public List<Asset> assetList {get;set;}
        public PatientAndAssetInfo(Contact cont, string pPatientPhone,string pPhysicianPhone,integer pTotalSpaces, List<Asset> aList) {
            con = cont;
            patientPhone = pPatientPhone;
            physicianPhone = pPhysicianPhone ;
            totalSpaces = pTotalSpaces;
            assetList = aList;
        }
    }
}