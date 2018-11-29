/**
*
* Helper class to generate PDFs.
*
* @author				Sumit
* @created             2018-05-02
* @refactored			2018-10-21 Florian Heer <f.heer@conciscon.de>
* @systemLayer    		Helper
*
*/
public without sharing class PrintPdfHelper {
    private List<Asset> currentOrderExplantedDevices = new List<Asset> ();
    private List<Asset> currentOrderExplantedLeads = new List<Asset> ();
    private List<Asset> currentOrderImplantedBiotronikDevices = new List<Asset> ();
    private List<Asset> currentOrderImplantedLeadsAndAdapter = new List<Asset> ();
    private List<Asset> allImplantedDevices = new List<Asset> ();
    private List<Asset> allImplantedLeads = new List<Asset> ();
    private List<Asset> allImplantedAdapters = new List<Asset> ();
    private List<Asset> allImplantedLeadsAndAdapters = new List<Asset> ();
    private List<Asset> allOosLeadsAndAdapter = new List<Asset> ();
    private List<Asset> allOosDevices = new List<Asset> ();
    private List<Asset> allOosItems = new List<Asset> ();
    private List<OrderItem> currentOrderDevicesAndLeads = new List<OrderItem> ();
    private List<OrderItem> currentOrderAccessories = new List<OrderItem> ();
    
    @testVisible private static final string BIOTRONIK = 'Biotronik';
    
    /** Constructor to be called when documents are printed from an Order
	 *
	 * @param     odr     Order as a starting point to fill internal lists.
     */
    public printPdfHelper(Order odr) {
        readAssets (odr.patient__c, odr); 
        readOrderItems (odr);
    }
    
    /** Constructor to be called when documents are printed from an patient
	 *
	 * @param     patient     Contact as a starting point to fill internal lists.
     */
    public printPdfHelper (Contact patient) {
        readAssets (patient.Id, null);
    }
    
    /** Only filled, if called from an Order.
     *  Contains all devices and leads related to the Order.
     */
    public List<OrderItem> getCurrentOrderDevicesAndLeads() {
        return currentOrderDevicesAndLeads;
    }

    /** Only filled, if called from an Order.
     *  Contains all accessories related to the Order.
     */
    public List<OrderItem> getCurrentOrderAccesories() {
        return currentOrderAccessories;
    }
    
    /** Only filled, if called from an Order.
     *  Contains all devices that have been explanted from the current patient on the implant day of the order.
     */
    public List<Asset> getCurrentOrderExplantedDevices () {
        return currentOrderExplantedDevices;   
    }

    /** Only filled, if called from an Order.
     *  Contains all Leads that have been explanted from the current patient on the implant day of the order.
     */
    public List<Asset> getCurrentOrderExplantedLeads () {
        return currentOrderExplantedLeads;
    }

    
    /** Contains all items that are explanted from the patient.
     */
    public List<Asset> getAllOOSItems () {
        return allOosItems;
    }

	/** Contains all devices that are explanted from the patient.
	 */
    public List<Asset> getAllOOSDevices () {
        return allOosDevices;
    }
    
	/** Contains all leads and adapters that are explanted from the patient.
	 */
    public List<Asset> getAllOOSLeadsAndAdapters () {
        return allOosLeadsAndAdapter;
    }
    
    
    /** Contains all devices that were implanted in relation to the current Order.
     */
    public List<Asset> getCurrentOrderBiotronikImplantedDevices() {
        return currentOrderImplantedBiotronikDevices;   
    }

    /** Contains all leads and adapters that were implanted in relation to the current Order.
     */
    public List<Asset> getCurrentOrderImplantedLeadsAndAdapter() {
        return currentOrderImplantedLeadsAndAdapter;   
    }
    
    
	/** Contains all devices implanted in the current patient.
	 */    
    public List<Asset> getAllImplantedDevices() {
        return allImplantedDevices;
    }
    
    /** Contains all leads implanted in the current patient.
     */
    public List<Asset> getAllImplantedLeads () {
        return allImplantedLeads;
    }

    /** Contains all adapters implanted in the current patient.
     */
    public List<Asset> getAllImplantedAdapters () {
        return allImplantedAdapters;
    }

    /** Contains all leads and adapters implanted in the current patient.
     */
    public List<Asset> getAllImplantedLeadsAndAdapters () {
        return allImplantedLeadsAndAdapters;
    }
    
    // ====================================================================================================================
    
    /** Reads all Assets related to a patient.
	 * Sorts these assets into various lists which are stored in this object.
	 *
	 * @param	patientId the referenced patient - may not be null
	 * @param   currOrder the current Order, if existent, controls association of Assets with some lists - may be null.
	 */
    private void readAssets(Id patientId, Order currOrder) {
        if(patientId == null) {
			throw new PrintPdfHelperException ('PrintPdfHelper.getAssets() called without a valid patient Id.')            ;
        }
        
        Id orderId;
        Date orderImplantDate;
        
        if (currOrder != null) {
        	orderId = currOrder.Id;
            orderImplantDate = currOrder.implant_date__c;
        }

        
        for( Asset ast : [SELECT 
                          id,
                          Name,
                          recordType.Name,
                          recordType.DeveloperName,
                          product_type__c,
                          status,
                          dft__c,
                          UDI__c,
                          installdate,
                          productcode,
                          product2.name,
                          serialnumber,
                          manufacturer__c,
                          mode__c,
                          model_no__c,
                          mode_switch__c,
                          lower_rate__c,
                          upper_rate__c,
                          av_delay_pace__c,
                          event_reason__c,
                          oos_date__c,
                          oos_additional_information__c,
                          shock_impedance__c,
                          charge_time__c,
                          lead_tip_location__c,
                          p_amp__c,
                          r_amp__c,
                          pulse_width__c,
                          threshold__c,
                          impedance__c,
                          pulse_amplitude_v_atrium__c,
                          pulse_amplitude_v_lv__c,
                          pulse_amplitude_v_rv__c,
                          pulse_width_ms_atrium__c,
                          pulse_width_ms_lv__c,
                          pulse_width_ms_rv__c,
                          sensitivity_mv_atrium__c,
                          sensitivity_mv_lv__c,
                          sensitivity_mv_rv__c,
                          slew_rate__c,
                          polarity__c,
                          polarity_sensing_atrium__c,
                          polarity_sensing_lv__c,
                          polarity_sensing_rv__c,
                          polarity_pacing_atrium__c,
                          polarity_pacing_lv__c,
                          polarity_pacing_rv__c,
                          order__c,
                          Explant_Date__c,
                          pace_sense__c,
                          defib__c
                          FROM Asset 
                          WHERE patient__c = :patientId
                          ORDER BY Createddate DESC]) {
                                  
                              // Collect all Out of Service Assets
                              // Used in Patient Data Sheet - Historical Products
                              if(Utility.isExplantedDeviceStatus (ast.Status)) {
                                  allOosItems.add(ast);
                                  if (Utility.getValidationCategory (ast.product_type__c) == Constants.VALI_CAT_DEVICE) {
                                      allOosDevices.add(ast);
                                  }
                                  else if (Utility.isLeadOrAdapterForPrinting (ast.product_type__c)) {
                                      //Adding OOS Leads/Adapter
                                      allOosLeadsAndAdapter.add(ast);
                                  }
                              }
                              else {
                                  if (Utility.isDeviceForPrinting (ast.product_type__c)) {
                                      allImplantedDevices.add (ast);
                                  }
                                  if (Utility.getValidationCategory (ast.product_type__c) == Constants.VALI_CAT_LEAD) {
                                      allImplantedLeads.add (ast);
                                  }
                                  if (ast.product_type__c == Constants.PICKLIST_VALUE_PRODUCT_TYPE_ADAPTER) {
                                      allImplantedAdapters.add (ast);
                                  }
                                  
                              }
                              
                              
                              if(ast.order__c != null && ast.order__c == orderId) {
                                  if(Utility.isDeviceForPrinting(ast.product_type__c)
                                     && ast.Status == Constants.IMPLANT_STATUS_IMPLANTED
                                     && ast.manufacturer__c == BIOTRONIK) 
                                  {
                                      //Adding Biotronik Implanted device
                                      currentOrderImplantedBiotronikDevices.add(ast);
                                  } 
                                  else if (ast.Status == Constants.IMPLANT_STATUS_IMPLANTED
                                           && Utility.isLeadOrAdapterForPrinting (ast.product_type__c)) 
                                  {
                                      //Adding Implanted Leads/Adapters
                                      currentOrderImplantedLeadsAndAdapter.add(ast);
                                  }
                              }
                              
                              if (ast.Explant_Date__c <> null 
                                 && orderImplantDate <> null
                                 && ast.Explant_Date__c == orderImplantDate
                                 && Utility.isExplantedDeviceStatus (ast.status)) {
                                     if (Utility.isDeviceForPrinting (ast.product_type__c)) {
                                         //Adding Explanted device of the current Order
                                         currentOrderExplantedDevices.add (ast);
                                     }
                                     else if (Utility.getValidationCategory (ast.product_type__c) == Constants.VALI_CAT_LEAD) {
                                         currentOrderExplantedLeads.add (ast);
                                     }
                                 }
                          }
        allImplantedLeadsAndAdapters.addAll (allImplantedLeads);
        allImplantedLeadsAndAdapters.addAll (allImplantedAdapters);
    } 
    
    /** Reads order items from the current order and sorts them into lists.
     */
    private void readOrderItems(Order currentOrder) {
        Decimal temptotal = 0;
        Set<String> deviceTypes = Utility.getDevicesForPrinting ();
        System.debug('deviceTypes: ' + deviceTypes);
        List<String> leadTypes = Utility.getContainedProductTypes(Constants.VALI_CAT_LEAD);
        System.debug('leadTypes: ' + leadTypes);
        List<String> addTypes = new List<String> {Constants.PICKLIST_VALUE_PRODUCT_TYPE_ACCESSORY, Constants.PICKLIST_VALUE_PRODUCT_TYPE_ADAPTER};
/*        List<String> productTypesWeCareAbout = deviceTypes;
        productTypesWeCareAbout.addAll (leadTypes);
        productTypesWeCareAbout.addAll (addTypes);
        productTypesWeCareAbout.add (Constants.PICKLIST_VALUE_PRODUCT_TYPE_SYSTEM_DEVICE);
        productTypesWeCareAbout.add (Constants.PICKLIST_VALUE_PRODUCT_TYPE_CARDIO_MESSENGER);
        productTypesWeCareAbout.add (Constants.PICKLIST_VALUE_PRODUCT_TYPE_HOME_MONITORING_SERVICE);
        productTypesWeCareAbout.add (Constants.PICKLIST_VALUE_PRODUCT_TYPE_LOOP_RECORDER);
*/
        
        List<OrderItem> deviceOIs = new List<OrderItem>();
        List<OrderItem> leadOIs  = new List<OrderItem>();
        List<OrderItem> systemOIs  = new List<OrderItem>();
        OrderItem cardioMessenger, homeMonitoringService;
        
        for(OrderItem oi : [SELECT
                            id, 
                            serial_number__c,
                            Product2.sap_model_no__c,
                            Product2.product_type__c, 
                            Product2.name, 
                            Quantity,
                            UnitPrice
                            FROM OrderItem 
                            WHERE OrderId = :currentOrder.id
                            AND Product2Id != null
                            ])
                            //            on Sales Voucher ALL OrderItems must appear
                            // AND (Product2.product_type__c IN :productTypesWeCareAbout)
        {
            if(oi.Product2 != null) {
                if (deviceTypes.contains(oi.Product2.product_type__c)) {
                    System.debug ('Sorted ' + oi.Product2.product_type__c + ' to deviceOIs.');
                    deviceOIs.add(oi);
                } 
                else if (leadTypes.contains(oi.Product2.product_type__c)) {
                    System.debug ('Sorted ' + oi.Product2.product_type__c + ' to leadOIs.');
                    leadOIs.add(oi);
                }
                else if (oi.Product2.product_type__c == Constants.PICKLIST_VALUE_PRODUCT_TYPE_SYSTEM_DEVICE) {
                    System.debug ('Sorted ' + oi.Product2.product_type__c + ' to systemOIs.');
                    systemOIs.add(oi);
                }
                else if (oi.Product2.product_type__c == Constants.PICKLIST_VALUE_PRODUCT_TYPE_CARDIO_MESSENGER) {
                    System.debug ('Sorted ' + oi.Product2.product_type__c + ' to cardioMessengerOIs.');
                    cardioMessenger = oi;
                    currentOrderAccessories.add(oi);
                }
                else if (oi.Product2.product_type__c == Constants.PICKLIST_VALUE_PRODUCT_TYPE_HOME_MONITORING_SERVICE) {
                    System.debug ('Sorted ' + oi.Product2.product_type__c + ' to homeMonitoringOIs.');
                    homeMonitoringService = oi;
                    currentOrderAccessories.add(homeMonitoringService);
                }
                // Everything that is not specifically classified goes in here
                // OrderItems must all be included in Sales Voucher
                else {
                    System.debug ('Sorted ' + oi.Product2.product_type__c + ' to the rest.');
                    currentOrderAccessories.add(oi);
                }
                
            }
        }
        
        // Making sure the OrderItems are available in the right order
        currentOrderDevicesAndLeads.addAll(deviceOIs);
        currentOrderDevicesAndLeads.addAll(leadOIs);
        currentOrderDevicesAndLeads.addAll(systemOIs);
    }
    
    public class PrintPdfHelperException extends Exception {}
    
}