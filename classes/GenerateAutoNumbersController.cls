/**
 * Controller to create and assign running Auto Numbers for CI, RP and MDR number
 * 
 * @author            SNPA
 * @created           2018-04-26
 * @systemLayer       Controller 
 *  
 */
public class GenerateAutoNumbersController {

    private static complaint__c objComplaint;
    public static list<auto_running_numbers__c> autoRunningNumbers = auto_running_numbers__c.getall().values();
    private static final string ERR_NOEXISTS = Label.ERR_NO_EXISTS;
    @testVisible private static final string CI_PREFIX = Label.CI_NO_PREFIX;
    @testVisible private static final string MDR_PREFIX = Label.MDR_NO_PREFIX;
    private static boolean yearChanged = false;    
    private static final string CI_FIELDNAME = 'ci_number__c';
    private static final string MDR_FIELDNAME = 'mdr_number__c';    
    
    private static final string CI_RUNNINGFIELDNAME = 'ci_running_Number__c';
    private static final string MDR_RUNNINGFIELDNAME = 'mdr_running_number__c';
    public static string prefix;
    public static Decimal runningNumber;
    public static string fieldName;
    public static string runningNoFieldName;
    public static final string RP_PREFIX = Label.RP_NO_PREFIX;
    public static final string RP_FIELDNAME = 'rp_number__c';
    public static final string RP_RUNNINGFIELDNAME = 'rp_running_number__c';
    public static boolean incrementValue = true;
    
    public GenerateAutoNumbersController() {}
    
    /** 
     * Action method called for assigning CI Number
     *
     * @param     recordId    Id of Complaint
     * @return     void    
     * @author     SNPA 
     */
    @AuraEnabled
    public static void assignCiNumber(id recordId) {
        prefix = CI_PREFIX + System.Today().year() + '-';
        fieldName = CI_FIELDNAME;
        runningNoFieldName = CI_RUNNINGFIELDNAME;
        getComplaint(recordId);
        assignAutoNumber();
    }
    
    /** 
     * Method checks if the Auto number already exists. If yes, then 
     * throws an error
     *
     * @param     autoNumberField    Name of field
     * @return     void    
     * @author     SNPA 
     */
    @AuraEnabled
    public static void checkIsError(string autoNumberField) {
        if(autoNumberField != null && autoNumberField != '') {
            AuraHandledException e = new AuraHandledException(ERR_NOEXISTS);
            e.setMessage(ERR_NOEXISTS);
            system.debug(e);
            throw e;
        }
    }  
        
    /** 
     * Method called for assigning RP Number
     *
     * @param     recordId    Id of Complaint
     * @return    void    
     * @author    SNPA 
     */
    @AuraEnabled
    public static void assignRpNumber(id recordId) {
        prefix = RP_PREFIX + System.Today().year() + '-';
        fieldName = RP_FIELDNAME;
        runningNoFieldName = RP_RUNNINGFIELDNAME;
        getComplaint(recordId);
        assignAutoNumber();
    }
    
    /** 
     * Method called for assigning MDR Number
     *
     * @param     recordId    Id of Complaint
     * @return    void    
     * @author    SNPA 
     */
    @AuraEnabled
    public static void assignMdrNumber(id recordId) {
        prefix = MDR_PREFIX + System.Today().year() + '-';
        fieldName = MDR_FIELDNAME;
        runningNoFieldName = MDR_RUNNINGFIELDNAME;
        getComplaint(recordId);
        assignAutoNumber();
    } 
    
    /** 
     * Method populates complaint record for given id
     *
     * @param     recordId    Id of Complaint
     * @return    void    
     * @author    SNPA 
     */
    private static void getComplaint(id recordId) {
        objComplaint = [SELECT rp_number__c, 
                                    ci_number__c, 
                                    mdr_number__c,
                                    rp_running_number__c, 
                                    ci_running_Number__c, 
                                    mdr_running_number__c
                            FROM complaint__c
                                WHERE id = :recordId];    
    }
    
    /** 
     * Method assigns running number to Complaint record
     *
     * @return    void    
     * @author    SNPA 
     */
    public static void assignAutoNumber() {
        try {    
            sObject complaintSobject = (sObject)objComplaint;
            checkIsError((string)complaintSobject.get(fieldName));
            calculateRunningNumber();
            complaintSobject.put(fieldName , getFieldValue());  
            complaintSobject.put(runningNoFieldName , runningNumber); 
            update objComplaint;        
            updateSettings();
        } catch(DMLException dmlExc) {
            throw new AuraHandledException(dmlExc.getDmlMessage(0));
        }
        catch(Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }   
     
    /** 
     * Method updates the running number and saves it in custom setting
     *
     * @return    void    
     * @author    SNPA 
     */
    public static void updateSettings() {
		autoRunningNumbers = auto_running_numbers__c.getall().values();      
        sObject autoNumberSetting;
        if(autoRunningNumbers != null && autoRunningNumbers.size() > 0) {
            autoNumberSetting = (sObject)autoRunningNumbers[0];
        } else {
            autoNumberSetting = createAutoNumberSetting();            
        }
        
        autoNumberSetting.put(fieldName, incrementValue ? runningNumber + 1 : runningNumber);
        autoNumberSetting.put('Running_Number_Year__c', System.Today().year());
        
        if(yearChanged) {
            // if year has changed then reset values for other two vars
            if(fieldName != RP_FIELDNAME) {
                    
                decimal latestNumber = queryFromComplaint(RP_RUNNINGFIELDNAME, 
                                                          RP_PREFIX + System.Today().year() + '-', 
                                                          RP_FIELDNAME) ;
                autoNumberSetting.put(RP_FIELDNAME,latestNumber); 
            }
            if(fieldName != CI_FIELDNAME) {
                decimal latestNumber = queryFromComplaint(CI_RUNNINGFIELDNAME, 
                                                          CI_PREFIX + System.Today().year() + '-', 
                                                          CI_FIELDNAME) ;
                autoNumberSetting.put(CI_FIELDNAME,latestNumber);
            }
            if(fieldName != MDR_FIELDNAME) {
                autoNumberSetting.put(MDR_FIELDNAME,1); 
                decimal latestNumber = queryFromComplaint(MDR_RUNNINGFIELDNAME, 
                                                          MDR_PREFIX + System.Today().year() + '-', 
                                                          MDR_FIELDNAME) ;
                autoNumberSetting.put(MDR_FIELDNAME,latestNumber);
            }
              
        }
        System.debug('***autoNumberSetting**'+autoNumberSetting);
        
        upsert autoNumberSetting;
    }   
    
    /** 
     * Method to create an instance of auto_running_numbers__c custom setting
     *
     * @return    sObject  auto_running_numbers__c Custom setting record     
     * @author    SNPA 
     */
    private static sObject createAutoNumberSetting() {
        sObject autoNumberSetting = Schema.getGlobalDescribe().get('auto_running_numbers__c').newSObject() ;  
        autoNumberSetting.put('name' , 'Auto Running Numbers') ;  
        return autoNumberSetting;
    }
        
    /** 
     * Method returns the field valueto be assigned
     *
     * @return    string  running number string    
     * @author    SNPA 
     */
    public static string getFieldValue() {
        Integer runningInteger = Integer.valueOf(runningNumber); 
        return prefix + String.valueof(runningInteger).leftPad(5, '0') ;
    } 
    
    /** 
     * Method calculates running number
     *
     * @return    void
     * @author    SNPA 
     */
    public static void calculateRunningNumber() {
        integer runningYear;
        for (sObject runningNo : (list<sObject>) autoRunningNumbers) {          
            if(runningNo.get('Running_Number_Year__c') != null) {
                runningYear = integer.valueOf(runningNo.get('Running_Number_Year__c'));
                if( runningYear == System.Today().year()) {
                    runningNumber = (Decimal)runningNo.get(fieldName);
                } else {
                    yearChanged = true;
                }        
            }
        }
        if (runningNumber == null) {
            runningNumber = queryFromComplaint(runningNoFieldName, prefix, fieldName);
        }
    }
    
    /** 
     *  Method to query latest Number from database
     *  @param     pRunningNoFieldName    Field name for running number with only no. does not contain prefix 
     *  @param     pPrefix             	 Prefix for current number  
     *  @param     pFieldName             Actual field name with prefix
     *  @return    decimal				 Actual nomber without prefix
     *  @author    SNPA 
     */
    private static decimal queryFromComplaint(string pRunningNoFieldName, string pPrefix, string pFieldName) {
        string queryString = 'SELECT max('+ pRunningNoFieldName + ') maxVal FROM complaint__c ';
        string val ='\'' + String.escapeSingleQuotes(pPrefix.trim()) + '%\'';
        queryString += 'WHERE ' + pFieldName + ' LIKE ' + val;
        
        decimal latestNumber;
        //Add where number starts with add current year 
        List<AggregateResult> maxFieldName = database.query(queryString);
        if(maxFieldName != null && maxFieldName.size() > 0 &&
           maxFieldName[0].get('maxVal') != null && 
           maxFieldName[0].get('maxVal') != '' ) {
            latestNumber = (Decimal)maxFieldName[0].get('maxVal') + 1; 
        }
        if(latestNumber == null) {
            latestNumber = 1;        
        }
        return latestNumber;
    }
}