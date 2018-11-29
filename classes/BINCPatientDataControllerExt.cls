/** Class provides data for most MDRF-related documents.
 * All patient- / order-centered documents are served. Documents can currently be produced from Order or patient.
 * All order-related data will take the newest Order for a patient, if the documents are creatd from a patient.
 * Planned use for now is that Id card and Patient data sheet can be created from a patient;
 * these only consider Assets
 * 
 * Created 2018-10-11 Florian Heer <f.heer@conciscon.de>
 */

public without sharing class BINCPatientDataControllerExt {
    // @testVisible private static final String PATIENTDECEASED = 'Patient Deceased';
    public static final Integer NUM_ROWS_DEVICES = 7;
    public static final Integer NUM_ROWS_ACCESSORIES = 14;
    public static final Integer NUM_LEADS_IN_MDRF = 5;
    public static final Integer NUM_EXPLANTED_LEADS_IN_MDRF = 3;
    
    public Order currentOrder { get; private set;}
    public List<asset> currentOrderBiotronikImplantedDeviceList { get; private set;}

    public Asset currentOrderImplatedDevice { get; private set; }
    public Asset currentOrderExplantedDev { get; private set; }

    public List<Asset> currentOrderExplantedDevices {get; private set; }
    public List<Asset> currentOrderExplantedLeads { get; private set; }
    public List<Asset> currentOrderImplantedLeadsAndAdaptersList { get; private set;}
    public List<OrderItem> currentOrderDevicesAndLeads { get; private set;}
    public List<OrderItem> currentOrderAccessories { get; private set; }

    public List<Asset> patientImplantedDeviceList { get; private set;}
    public Asset patientImplantedDevice { get; private set; }
    public List<Asset> patientImplantedLeads { get; private set;}
    public List<Asset> patientImplantedLeadsAndAdapters { get; private set; }
    public list<Asset> patientExplantedDeviceList { get; private set;}
    public list<Asset> patientExplantedLeadsAndAdaptersList { get; private set;}
    public List<Asset> patientExplantedItems { get; private set;}
    
    public Boolean isLoopRecorder { get; private set; }
    public Boolean isICD { get; private set;}
    
	public String indications { get; private set; }

    public List<Integer> remainingAccessoryRows {get; private set;}
    public List<Integer> remainingDeviceRows {get; private set;}
    public List<Integer> dummyLeadAndAdapterList { get; private set; }
    public List<Integer> dummyOosList { get; private set; }

    private PrintPdfHelper pdfHelper;

    /* Constructor that should receive a standard controller for Order or Contact
     */
    public BINCPatientDataControllerExt (ApexPages.StandardController stdController) {
        //Can be contact OR Order
        sObject sObj = stdController.getRecord();
        
        // Initialising lists, avoiding NullPointers
        currentOrderBiotronikImplantedDeviceList = new List<Asset> ();
        patientImplantedDeviceList = new List<Asset> ();
        currentOrderExplantedDevices = new List<Asset> ();
        currentOrderImplantedLeadsAndAdaptersList = new List<Asset> ();
        patientImplantedLeads = new List<Asset> ();
        
        Schema.SObjectType objType = Id.valueOf(stdController.getId()).getSobjectType();

        System.debug('ObjectType: ' + String.valueOf(objType));
        
        Id patientId = null;
        Id orderId = null;
        
        // We need a patient id. Do we get this from the order or from the contact?
        if(String.valueOf(objType) == 'order') {
        	currentOrder = (Order)sObj;
            orderId = currentOrder.Id;
        } 
        else if(String.valueOf(objType) == 'contact') {
			patientId = stdController.getId();
            // Let's find the newest Order related to the patient. Some data is only stored there.
            // 
            List<Order> tOrders = [SELECT Id FROM Order WHERE patient__c = :patientId ORDER BY CreatedDate DESC LIMIT 1];
            if(tOrders.size () > 0) {
                orderId = tOrders[0].Id;
            }
        }
        else {
            throw new BINCPatientDataControllerExtException ('You can only print these documents from an Order or a Contact (patient).');
        }
        
        
        // Reading an Order (either the one chosen by the user or the newest on the patient)
        List<order> tempOrders = [SELECT Id,
                                  patient__r.LastName,
                                  patient__r.FirstName,
                                  patient__r.MiddleName,
                                  patient__r.Name,
                                  patient__r.MailingCity,
                                  patient__r.MailingStateCode,
								  patient__r.MailingState,
                                  patient__r.MailingStreet,
                                  patient__r.MailingPostalCode,
                                  patient__r.Phone,
                                  patient__r.MobilePhone,
                                  patient__c,
                                  patient__r.declined_to_provide_address__c,
                                  patient__r.BirthDate, patient__r.gender__c, patient__r.ssn__c,
                                  
                                  Account.Name,
                                  Account.BillingStreet,
                                  Account.BillingCity,
                                  Account.BillingState,
                                  Account.BillingPostalCode,
                                  Account.Phone,
                                  Account.ShippingStreet, Account.ShippingCity, Account.ShippingState, Account.ShippingStateCode,
                                  Account.ShippingCountry, Account.ShippingCountryCode, Account.ShippingPostalCode,
                                  Account.mobile__c, 
                                  
                                  following_physican__r.LastName,
                                  following_physican__r.FirstName,
                                  following_physican__r.Name,
                                  following_physican__r.MailingStreet,
                                  following_physican__r.MailingCity,
                                  following_physican__r.MailingStateCode,
								  following_physican__r.MailingState,
                                  following_physican__r.MailingPostalCode,
                                  following_physican__r.MobilePhone,
                                  following_physican__r.Phone,
                                  
                                  implanting_physician__r.Name,
                                  implanting_physician__r.FirstName,
                                  implanting_physician__r.LastName,
                                  implanting_physician__r.MailingStreet,
                                  implanting_physician__r.MailingCity,
                                  implanting_physician__r.MailingStateCode,
								  implanting_physician__r.MailingState,
                                  implanting_physician__r.MailingPostalCode,
                                  implanting_physician__r.MobilePhone,
                                  implanting_physician__r.Phone,
                                  
                                  rep_at_implant__r.FirstName,
                                  rep_at_implant__r.LastName,
                                  
                                  sick_sinus_syndrome__c,
                                  sinus_arrest__c,
                                  sinus_bradycardia__c,
                                  brady_tachy_syndrome__c,
                                  atrial_tachycadria__c,
                                  chf__c,
                                  mi__c,
                                  vf__c,
                                  afib__c,
                                  one_hb__c,
                                  two_hb__c,
                                  three_hc_chb__c,
                                  scd__c,
                                  vt__c,
                                  implant_date__c,
                                  Description,
                                  medical_record_no__c
                                  FROM Order
                                  WHERE Id = :orderId
                                  ORDER BY CreatedDate DESC LIMIT 1];
        if (tempOrders != null && tempOrders.size() > 0) {
            currentOrder = tempOrders[0];
        }
        
        if(order.patient__c <> null)
            patientId = currentOrder.patient__c;

        
        pdfHelper = new PrintPdfHelper(currentOrder); 

        // Build a presentation string containing the indications
		indications = '';
        if(currentOrder != null) {
            if (currentOrder.sick_sinus_syndrome__c) { indications += 'Sick Sinus Syndrome, '; }
            if (currentOrder.sinus_arrest__c) { indications += 'Sinus Arrest, '; }
            if (currentOrder.sinus_bradycardia__c) { indications += 'Sinus Bradycardia, '; }
            if (currentOrder.brady_tachy_syndrome__c) { indications += 'Brady/Tachy Syndrome, '; }
            if (currentOrder.atrial_tachycadria__c) { indications += 'Atrial Tachycardia, '; }
            if (currentOrder.afib__c) { indications += 'AFIB, '; }
            if (currentOrder.one_hb__c) { indications += '1° HB, '; }
            if (currentOrder.two_hb__c) { indications += '2° HB, '; }
            if (currentOrder.three_hc_chb__c) { indications += '3° HB/CHB, '; }
            if (currentOrder.chf__c) { indications += 'CHF, '; }
            if (currentOrder.mi__c) { indications += 'MI, '; }
            if (currentOrder.vt__c) { indications += 'VF, '; }
            if (currentOrder.scd__c) { indications += 'SCD, '; }
            if (currentOrder.scd__c) { indications += 'VT, '; }
            //        if (currentOrder.sick_sinus_syndrome__c) { indications += 'Sick Sinus Syndrome, '; }
            //        if (currentOrder.sick_sinus_syndrome__c) { indications += 'Sick Sinus Syndrome, '; }
            //        if (currentOrder.sick_sinus_syndrome__c) { indications += 'Sick Sinus Syndrome, '; }
            if(indications.length() > 0) indications = indications.left(indications.length() -2); // Remove excess comma
        }        
        
        
        // implantingPhysicianContact = new Contact();
        // followingPhysicianContact = new Contact();
        // this.getPhysicians();
        
        currentOrderBiotronikImplantedDeviceList = pdfHelper.getCurrentOrderBiotronikImplantedDevices();
        if (currentOrderBiotronikImplantedDeviceList.size() > 0) {
            currentOrderImplatedDevice = currentOrderBiotronikImplantedDeviceList[0];
            isLoopRecorder = Utility.getValidationCategory (currentOrderImplatedDevice.product_type__c) == Constants.VALI_CAT_LOOP_RECORDER;
            isICD = Utility.isProductTypeICD (currentOrderImplatedDevice.product_type__c);
            
        }
        currentOrderImplantedLeadsAndAdaptersList = pdfHelper.getCurrentOrderImplantedLeadsAndAdapter ();
        currentOrderExplantedDevices = pdfHelper.getCurrentOrderExplantedDevices ();
        if (currentOrderExplantedDevices.size () > 0) {
        	currentOrderExplantedDev = currentOrderExplantedDevices[0];
        }
        currentOrderExplantedLeads = pdfHelper.getCurrentOrderExplantedLeads ();
        
        currentOrderDevicesAndLeads = pdfHelper.getCurrentOrderDevicesAndLeads();
        for(OrderItem o : currentOrderDevicesAndLeads) {
            System.debug('devices and leads contains: ' + o.Product2.product_type__c);
        }

        currentOrderAccessories = pdfHelper.getCurrentOrderAccesories();
        
        patientImplantedDeviceList = pdfHelper.getAllImplantedDevices();
        if (patientImplantedDevicelist.size() > 0) {
            patientImplantedDevice = patientImplantedDeviceList [0];
        }
        patientImplantedLeads = pdfHelper.getAllImplantedLeads();
        patientImplantedLeadsAndAdapters = pdfHelper.getAllImplantedLeadsAndAdapters();
        
        patientExplantedDeviceList = pdfHelper.getAllOOSDevices();

        patientExplantedLeadsAndAdaptersList = pdfHelper.getAllOOSLeadsAndAdapters ();
        patientExplantedItems = pdfHelper.getAllOOSItems ();
        
        remainingAccessoryRows = new List<Integer> ();
        remainingDeviceRows = new List<Integer> ();
        
        //Generating dummy rows for Assessories, used in SalesVoucher and Delivery Confirmation.
        Integer totalRemaining = (currentOrderAccessories.size() >= NUM_ROWS_ACCESSORIES) ? 0 : (NUM_ROWS_ACCESSORIES-currentOrderAccessories.size());
        for(Integer i=0;i<totalRemaining;i++){
            remainingAccessoryRows.add(i);        
        }
        
        //Generating dummy rows for device And Leads, used in SalesVoucher and Delivery Confirmation.
        totalRemaining = (currentOrderDevicesAndLeads.size() >= NUM_ROWS_DEVICES) ? 0 : (NUM_ROWS_DEVICES-currentOrderDevicesAndLeads.size());
        for(Integer i=0;i <totalRemaining; i++){
            remainingDeviceRows.add(i);        
        }

        // Generating dummy rows for leads and adapters, used in MDRF
        dummyLeadAndAdapterList = new List<Integer> ();
        for (Integer i = patientImplantedLeadsAndAdapters.size(); i < NUM_LEADS_IN_MDRF; i++) {
            dummyLeadAndAdapterList.add(i);
        }
        dummyOosList = new List<Integer> ();
        for (Integer i = currentOrderExplantedLeads.size(); i < NUM_EXPLANTED_LEADS_IN_MDRF; i++) {
            dummyOosList.add(i);
        }

    }
    
    public class BINCPatientDataControllerExtException extends Exception {}
}