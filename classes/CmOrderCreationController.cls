/**
 * Created 2018-07-10 Florian Heer <f.heer@conciscon.de>
 * SAFBIO-1363
 * Creates a CMOrder, prefilling all possible data from the known state
 * 
 *
 * @modified       emma
 * @modified date  2018-11-05
 * @systemLayer    Controller | Extension
 * 
 * Controller for the process of the Cardio Messenger Order Creation
 * modified by emma to be adjusted to a lightning component 
 *
 **/
public with sharing class CmOrderCreationController {

    public static final String CM_ORDER_DIRECT_HANDOUT = 'Direct Hand-out';
    public static final String CM_ORDER_DIRECT_SHIP = 'Direct Ship';
    public static final String CM_ORDER_DIRECT_SHIP_REPLACEMENT = 'Direct Ship Replacement';
    public static final String CMO_SETTING_NAME_DEFAULT_ACCOUNT = 'DefaultSAPAccountID';
    //public static final String ORDER_INITIAL_STATUS = Constants.PICKLIST_VALUE_STATUS_NOT_SUBMITTED;
    //public static final String ORDER_FINAL_STATUS_DIRECT_SHIP = Constants.PICKLIST_VALUE_ORDER_STATUS_PENDING_HMSC; 
    //public static final String ORDER_FINAL_STATUS_DIRECT_HANDOUT = Constants.PICKLIST_VALUE_ORDER_STATUS_SAP_SUBMISSION_BLOCKED; 
    
    public static final String ORDER_INITIAL_STATUS = Constants.PICKLIST_VALUE_STATUS_NOT_SUBMITTED;
    public static final String ORDER_FINAL_STATUS_DIRECT_SHIP = 'Pending HMSC Registration'; /*'Submitted for Processing'*/
    public static String ORDER_FINAL_STATUS_DIRECT_HANDOUT = Constants.PICKLIST_VALUE_ORDER_STATUS_PENDING_SAP; /* Status : Pending SAP Submission, Added by Sumit || SAFBIO-2315 */
    
    public static final String PO_NUMBER_HANDOUT = 'CM';
    public static final String PO_NUMBER_SHIP = 'CMDS';
    public static final String PO_NUMBER_SHIP_REPLACE = 'CMDSR';
    public static final String PRODUCT_TYPE_CARDIO_MESSENGER = Constants.PICKLIST_VALUE_PRODUCT_TYPE_CARDIO_MESSENGER;
    public static final String PATIENT_DECEASED = Constants.PICKLIST_VALUE_CONTACT_STATUS_DECEASED;
    
    @AuraEnabled
    public Contact contacts {get;set;}
    public Id contactId {get;set;}
    public Id recordId {get;set;}
    public String sObjectName{get;set;}
    
    public CmOrderCreationController (ApexPages.StandardController controller){
    	contacts = (Contact)controller.getRecord();
        contactId = contacts.Id;
        recordId = ApexPages.currentPage().getParameters().get('id');
        sObjectName = controller.getRecord().getSObjectType().getDescribe().getName();
    }
    
    @AuraEnabled
    public static Contact getContact(Id recordId, String sObjectName){
       Id contactId;
        if (sObjectName == 'complaint__c'){ 
        	complaint__c com = [SELECT Id, asset__c, MDRF_Order__c FROM complaint__c WHERE Id = :recordId];
            if (com.asset__c != null){
                List<Asset> assets = [SELECT Id, patient__c, product_type__c FROM Asset WHERE Id = :com.asset__c];
                if (assets.size() > 0){
                	contactId = assets[0].patient__c;
                    
                }
            }else if(com.MDRF_Order__c != null) {
            	List<Order> orders = [SELECT Id, patient__c FROM Order WHERE Id = :com.MDRF_Order__c];
                if(orders.size() > 0) {
                    contactId = orders[0].patient__c;   
                }
            }
        }else if (sObjectName == 'Contact'){
        	contactId =  recordId; 
        }
    	Contact patientAdd =  [SELECT Id, Name, FirstName, LastName, Status__c, MailingAddress, declined_to_provide_address__c
                          , MailingStreet, MailingPostalCode, MailingCity, MailingState, MailingStateCode, MailingCountry, MailingCountryCode
                          , OtherStreet, OtherPostalCode, OtherCity, OtherState, OtherStateCode, OtherCountryCode
                          , OtherCountry, shipping_street__c, shipping_zip_postal_code__c, shipping_city__c, shipping_state_province__c, shipping_country__c
                          
                          FROM Contact WHERE Id = :contactId];
        return patientAdd;
    }
    
    @AuraEnabled
    public static String getOrderType(String sObjectName){
    	String orderType;
        if (sObjectName == 'complaint__c'){
        	orderType = CM_ORDER_DIRECT_SHIP_REPLACEMENT;    
        }else if(sObjectName == 'Contact'){
            orderType = CM_ORDER_DIRECT_HANDOUT;    
        }
        return orderType;
    }
    
    @AuraEnabled
    public static Boolean isPatientDceased (Id recordId, String sObjectName){
        
    	Boolean patientDead = false;
        Contact contacts = getContact(recordId, sObjectName);
        if (contacts.Status__c == PATIENT_DECEASED){
            patientDead = true;
        }
        return patientDead;
    }
    
    @AuraEnabled
    public static List<ProductItem> searchProductItems(String serialNumber, String inventoryName){
    	List<ProductItem> productItems = new List<ProductItem>() ;
        
        if(serialNumber != null && serialNumber.length() > 0) {  
            productItems = [SELECT Id, Product2.Name, SerialNumber FROM ProductItem WHERE SerialNumber = :serialNumber AND QuantityOnHand > 0 AND product_type__c = : PRODUCT_TYPE_CARDIO_MESSENGER];
        }else if(inventoryName != null && inventoryName.length() > 0) {
        	String searchString = '%' + inventoryName + '%';
            List<ServiceResource> serviceRessources = [Select LocationId FROM ServiceResource WHERE RelatedRecordId = :UserInfo.getUserId() LIMIT 1];
            if(serviceRessources.size() > 0) {
            	productItems = [SELECT Id, Product2.Name, SerialNumber FROM ProductItem WHERE Product2.Name LIKE :searchString AND LocationId = :serviceRessources[0].LocationId AND QuantityOnHand > 0 AND product_type__c = : PRODUCT_TYPE_CARDIO_MESSENGER];
            }else {
                throw new CreateCMOrderException(Label.ccmo_No_Service_Resource_for_current_User);
            } 
        }
        return productItems;
    }
   
    @AuraEnabled 
    public static List<ProductItem> getAvailableProduct(String orderType, String serialNumber, String inventoryName){
        system.debug('am I here orderType is ?? debut '+ orderType);
		List<ProductItem> retval = new List<ProductItem>();
        List<ProductItem> avlCMProducts = searchProductItems(serialNumber, inventoryName);
        Account implantingFacility = getImplantinFacility();
            
        if(orderType == CM_ORDER_DIRECT_HANDOUT) {
            retval = avlCMProducts;
        }
        return retval; 
    }
    @AuraEnabled
    public static List<ProductHolder> getavailableProd (String orderType){
        List<ProductHolder> retval = new List<ProductHolder> ();
        Account implantingFacility = getImplantinFacility();
        if(orderType != CM_ORDER_DIRECT_HANDOUT) {
        	System.debug('Implanting facility: ' + implantingFacility.Id + ' crm_pricebook: ' + implantingFacility.crm_pricebook__c
                        + ' CurrencyIsoCode: ' + implantingFacility.CurrencyIsoCode + ' product_type: ' + Constants.PICKLIST_VALUE_PRODUCT_TYPE_CARDIO_MESSENGER);
        	List<PricebookEntry> pbes = [SELECT Id, Product2.Id, Product2.Name FROM PricebookEntry WHERE Pricebook2Id = :implantingFacility.crm_pricebook__c
                                        AND CurrencyISOCode = :implantingFacility.CurrencyIsoCode
                                        AND IsActive=True
                                        AND Product2.product_type__c = :Constants.PICKLIST_VALUE_PRODUCT_TYPE_CARDIO_MESSENGER
                                        ORDER BY Product2.Name];
        	for(PricebookEntry pbe : pbes ) {
            	retval.add(new ProductHolder(pbe.Product2.Id, pbe.Product2.Name));
        	}    
        }
        return retval;
    }
    
    /* Retrieves the latest implanted device (ICD, Pacemaker) from a patient.
     * Either returns an Asset or throws an Exception.
     */
    @AuraEnabled
    public static Asset getLastDeviceFromPatient(Contact con) {
        List<String> deviceProductTypes = new List<String>();
        deviceProductTypes = Utility.getContainedProductTypes(Constants.VALI_CAT_DEVICE);
        // SAFBIO-2533
        deviceProductTypes.add (Constants.PICKLIST_VALUE_PRODUCT_TYPE_LOOP_RECORDER);
        List<Asset> assets = [SELECT Id, AccountId, implanting_physician__c, order_product__c FROM Asset WHERE 
                              product_type__c IN :deviceProductTypes 
                              AND patient__c = :con.Id
                              AND Status = :Constants.IMPLANT_STATUS_IMPLANTED
                              ORDER BY InstallDate LIMIT 1];
        if(assets.size() < 1) {

            throw new CreateCMOrderException (Label.ERR_CREATE_CM_ORDER_EXCEPTION_MESSAGE);
        }
        return assets[0];
    }

    @AuraEnabled
    public static List<AddressHolder> getPatientAddress (Id recordId, String sObjectName){
        
        List<AddressHolder> patientAddresses = new List<AddressHolder> ();
        Contact patientAdd = getContact(recordId, sObjectName);

        String Name = 'Mailing Address';
        String Street = patientAdd.MailingStreet;
        String PostalCode = patientAdd.MailingPostalCode;
        String City = patientAdd.MailingCity;
        String StateProvince = patientAdd.MailingState;
        String Country = patientAdd.MailingCountry;
        String label = (Street + ' ' +City + ' ' +PostalCode + ' ' + StateProvince+' ' + Country).replace('null','');
        patientAddresses.add(new AddressHolder (Name, Street, City, StateProvince, PostalCode, Country, label));

        String sName = 'Shipping Address';
        String sStreet = patientAdd.OtherStreet;
        String sPostalCode = patientAdd.OtherPostalCode;
        String sCity = patientAdd.OtherCity;
        String sStateProvince = patientAdd.OtherState;
        String sCountry = patientAdd.OtherCountry;
        String slabel = (sStreet + ' ' +sCity + ' ' +sPostalCode + ' ' + sStateProvince+' ' + sCountry).replace('null','');
        patientAddresses.add(new AddressHolder (sName, sStreet, sCity, sStateProvince, sPostalCode, sCountry, slabel));
        
        String oName = 'Other Address';
        String oStreet = patientAdd.shipping_street__c;
        String oPostalCode = patientAdd.shipping_zip_postal_code__c;
        String oCity = patientAdd.shipping_city__c;
        String oStateProvince = patientAdd.shipping_state_province__c;
        String oCountry = patientAdd.shipping_country__c;
        String olabel = (oStreet + ' ' +oCity + ' ' +oPostalCode + ' ' + oStateProvince+' ' + oCountry).replace('null','');
        patientAddresses.add(new AddressHolder (oName, oStreet, oCity, oStateProvince, oPostalCode, oCountry, olabel));
        
        return patientAddresses;
    }
    
    @AuraEnabled
    public static Account getImplantinFacility (){
        Account implantingFacility;
    	User usr = [SELECT Id, sap_company_code__c FROM User WHERE Id = :UserInfo.getUserId() LIMIT 1];
        
        List<cmo_settings__c> cmos = cmo_settings__c.getAll().values();
        cmo_settings__c ourSetting;
        System.debug('cmo_settings: ' + cmos.size());
        for(cmo_settings__c cmo : cmos) {
            System.debug('cmo setting: sap_company_code__c: ' + cmo.sap_company_code__c
                         + ' usr.sap_company_code__c: ' + usr.sap_company_code__c
                         + ' key__c: ' + cmo.key__c + ' value__c: ' + cmo.value__c);
            if(cmo.key__c == CMO_SETTING_NAME_DEFAULT_ACCOUNT && cmo.sap_company_code__c == usr.sap_company_code__c) {
                ourSetting = cmo;
                String sapAccountId = cmo.value__c;
                List<Account> accs = [SELECT Id, crm_pricebook__c, CurrencyIsoCode FROM Account WHERE sap_no__c = :sapAccountId];
                if(accs.size() > 0) {
                    implantingFacility = accs[0];
                }
                break;
            }
        }
        if (ourSetting == null) {
            throw new CreateCMOrderException (Label.ERR_CREATE_CM_ORDER_SETTINGS_MISSING);
        }
        if(implantingFacility == null) {
            throw new CreateCMOrderException(Label.ERR_CREATE_CM_ORDER_ACCOUNT_MISSING);
        }
        return implantingFacility;
    }
    
    @AuraEnabled
    public static Contact prepareOrder(String selectedAddress, Contact patientAdd, String address) {
        Contact tempContact;
        tempContact = new Contact();
        //tempContact.MailingCountryCode = 'US';
        //
        for(Schema.PicklistEntry p : Order.ShippingCountryCode.getDescribe().getPicklistValues()) {
            if(tempContact.MailingCountryCode <> null && p.getValue() == tempContact.MailingCountryCode) {
            	tempContact.MailingCountry = p.getLabel(); 
                break;
            }	    
        }        
        if(selectedAddress == 'Mailing Address') {
            system.debug('is it a mailing address');
            tempContact.MailingStreet = patientAdd.MailingStreet;
            tempContact.MailingCity = patientAdd.MailingCity;
            tempContact.MailingPostalCode = patientAdd.MailingPostalCode;
            tempContact.MailingStateCode = patientAdd.MailingStateCode;
            tempContact.MailingCountryCode = patientAdd.MailingCountryCode;
            tempContact.MailingState = patientAdd.MailingState;
            tempContact.MailingCountry = patientAdd.MailingCountry;
            tempContact.declined_to_provide_address__c = false;
            
        }
        else if(selectedAddress == 'Shipping Address') {
             system.debug('is it a shipping address');
            tempContact.MailingStreet = patientAdd.OtherStreet;
            tempContact.MailingCity = patientAdd.OtherCity;
            tempContact.MailingPostalCode = patientAdd.OtherPostalCode;
            tempContact.MailingStateCode = patientAdd.OtherStateCode;
            tempContact.MailingCountryCode = patientAdd.OtherCountryCode;
            tempContact.MailingState = patientAdd.OtherState;
            tempContact.MailingCountry = patientAdd.OtherCountry;
            
        }
        else if(selectedAddress == 'Other Address') {
            
            tempContact.MailingStreet = patientAdd.shipping_street__c;
            tempContact.MailingCity = patientAdd.shipping_city__c;
            tempContact.MailingPostalCode = patientAdd.shipping_zip_postal_code__c;
            tempContact.MailingState = patientAdd.shipping_state_province__c;
            tempContact.MailingCountry = patientAdd.shipping_country__c;
             
        } 
        else if (selectedAddress == null){
            system.debug('here iam selected address null');
            if (address != null){ 
                List <AddressHolder> adr = (List<AddressHolder>) JSON.deserialize(address ,List <AddressHolder>.class);
                if (adr.size()>0){
                    tempContact.declined_to_provide_address__c = false;
                    tempContact.MailingStreet = adr[0].street;
                    tempContact.MailingCity = adr[0].city;
                    tempContact.MailingPostalCode = adr[0].postalcode;
                    tempContact.MailingCountryCode = string.valueOf(adr[0].Country);
                    tempContact.MailingStateCode = adr[0].statecode;
                    
                    for(Schema.PicklistEntry cd : Contact.MailingCountryCode.getDescribe().getPicklistValues()) {
                        if (cd.getValue() == tempContact.MailingCountryCode){
                            tempContact.MailingCountry = cd.getLabel();
                        }
                    }
                }  
            } 
        }
        system.debug('tempContact is '+tempContact);
        return tempContact;
    }
    
    @AuraEnabled
    public static Product2 get_ourProduct (String orderType, Id selectedCMProduct){
    	Product2 ourProduct;
        if(orderType != CM_ORDER_DIRECT_HANDOUT) {
            ourProduct = [SELECT Id, Name, product_type__c, sap_model_no__c  FROM Product2 WHERE Id = :selectedCMProduct];
        }
        return ourProduct;
    }
    
    @AuraEnabled
    public static ProductItem get_ourProductItem(String orderType, Id selectedCMProduct){
        ProductItem ourProductItem;
        if(orderType == CM_ORDER_DIRECT_HANDOUT) {
            ourProductItem = [SELECT Id, Product2.Name, SerialNumber FROM ProductItem WHERE Id = :selectedCMProduct];
        }
        return ourProductItem;
    }

    @AuraEnabled
    public static Boolean repSelectionNeeded (Id recordId, String sObjectName){
        Boolean collectRep = false;
        
        Contact patient = getContact(recordId, sObjectName);
        Asset lastDeviceImplant = getLastDeviceFromPatient(patient);
        
        Id orderId = getRelatedOrder (lastDeviceImplant);
        List<Order> orders = [SELECT Id, rep_for_credit__c, rep_for_credit__r.sap_company_code__c
                                  , rep_for_credit__r.Name, rep_for_credit__r.IsActive FROM Order
                                  WHERE Id = :orderId LIMIT 1];
        if(Utility.getProfileNameById (UserInfo.getProfileId()) == Constants.PROFILE_NAME_SALES 
           || (orders.size() > 0 && orders[0].rep_for_credit__c != null && orders[0].rep_for_credit__r.IsActive)) {
            collectRep = false;
        }
        else {
            collectRep = true;  
        }
        return collectRep;    
    }
    
    @AuraEnabled
    public static List<User> getAvailableRepForCredit (){
    	List<User> repForCredit;
        String sap_companyCode;
        List<User> usrs = [SELECT sap_company_code__c FROM User WHERE Id = :UserInfo.getUserId ()];
        if (usrs.size () > 0) {
           if (usrs [0].sap_company_code__c != null) {
               sap_companyCode = usrs [0].sap_company_code__c;
       	   }
        }
        Id profileId = [SELECT Id, Name FROM Profile WHERE Name = : Constants.PROFILE_NAME_SALES].Id;
        repForCredit = [SELECT Id, Name, sap_company_code__c, IsActive, ProfileId FROM User WHERE sap_company_code__c = : sap_companyCode AND  IsActive = : True AND ProfileId = : profileId ORDER BY Name ASC ];
        System.debug('repForCredit'+repForCredit);
        return repForCredit;
    }
    
    @AuraEnabled
    public static Order createOrder (String orderType, Id recordId, String sObjectName, Id selectedCMProduct, String selectedAddress, Contact patientAdd, String selectedAddressToUpdate, String addrss, String selectedRep){
        Order ourCreatedOrder;
        Id orderRtId = Utility.getRecordTypeId(Order.SObjectType, Constants.RECORD_TYPE_NAME_ORDER_CARDIO_MESSENGER);
        Contact patient = getContact(recordId, sObjectName);
        Asset lastDeviceImplant = getLastDeviceFromPatient(patient);
        
        Id implantingPhysicianId = lastDeviceImplant.implanting_physician__c;
        Id implantingFacilityId = lastDeviceImplant.AccountId;
        Account implantingFacility = getImplantinFacility();
        
        Id repForCredit;
        String repForCreditName;
        //String sapCompanyCode;
        
        String xSapCompanyCode;
        
        Id orderId = getRelatedOrder (lastDeviceImplant);
        // FH 2018-11-09: setting a sane value to the company code
        List<User> usrs = [SELECT sap_company_code__c FROM User WHERE Id = :UserInfo.getUserId ()];
        if (usrs.size () > 0) {
           if (usrs [0].sap_company_code__c != null) {
               xSapCompanyCode = usrs [0].sap_company_code__c;
       	   }
        }
        System.debug ('Checking User profile');
        // SAFBIO-2253: If current user is Sales User, they are the rep for credit.
        if(Utility.getProfileNameById (UserInfo.getProfileId()) == Constants.PROFILE_NAME_SALES) {
            System.debug('User is sales');
            repForCredit = UserInfo.getUserId();
            repForCreditName = UserInfo.getUserName();
            System.debug('CCC-1 sapCompanyCode: ' + xSapCompanyCode);
        }
        else {
            List<Order> orders = [SELECT Id, rep_for_credit__c, rep_for_credit__r.sap_company_code__c
                                  , rep_for_credit__r.Name, rep_for_credit__r.IsActive FROM Order
                                  WHERE Id = :orderId LIMIT 1];
            System.debug('CCC1 sapCompanyCode: ' + xSapCompanyCode);

            if (orders.size() > 0 && orders[0].rep_for_credit__c != null && orders[0].rep_for_credit__r.IsActive) {
                repForCreditName = orders[0].rep_for_credit__r.Name;
                repForCredit = orders[0].rep_for_credit__c;
                
                if (orders[0].rep_for_credit__r.sap_company_code__c != null) {
            		xSapCompanyCode = orders[0].rep_for_credit__r.sap_company_code__c;
       			}
                System.debug('CCC2 sapCompanyCode: ' + xSapCompanyCode);
            }
            else {
                // No code here, just for full clarification: repForCredit intentionally left blank.
                // Needs to be selected by the current user.
                repForCredit = selectedRep;
                if (repForCredit != null){
                    User salesRepUser = [SELECT Id, Name, sap_company_code__c FROM User WHERE Id = : selectedRep];
                    repForCreditName = salesRepUser.Name;
                    xSapCompanyCode = salesRepUser.sap_company_code__c;
                }
                System.debug('CCC3 sapCompanyCode: ' + xSapCompanyCode);
            }
        }

        ProductItem ourProductItem = get_ourProductItem(orderType, selectedCMProduct);
        Product2 ourProduct = get_ourProduct(orderType, selectedCMProduct);
        Contact tempContact = prepareOrder(selectedAddress, patientAdd, addrss);
        
        If(orderType == CM_ORDER_DIRECT_HANDOUT) {
            // Okay, we are dealing with an actual physical device. So we have to create a WorkOrder
            // Additionally, we don't care about addresses. Just create the Order and fire this.
            // QUESTION: Any rule checking here?
            WorkOrder wo = createWorkOrder(implantingPhysicianId, patient.Id, repForCredit, repForCredit, implantingFacilityId, UserInfo.getDefaultCurrency());
            WorkOrderLineItem woli =  createWorkOrderLineItem(wo);
            System.debug('AAA ccmo Currency WorkOrder: ' + wo.CurrencyIsoCode + ' User: ' + UserInfo.getDefaultCurrency());
            // If it is direct Handout, Setting the status to 'Pending SAP Submission' 
            WorkOrderConversion.DEFAULT_ORDER_STATUS = ORDER_FINAL_STATUS_DIRECT_HANDOUT;
            ourCreatedOrder = WorkOrderConversion.convertToOrder(wo.id, orderRtId, getSapCompanyCode (xSapCompanyCode));
            
            //ourCreatedOrder.sap_company_code__c = sapCompanyCode;
            // After creating the order, resetting the class variable
            WorkOrderConversion.DEFAULT_ORDER_STATUS = Constants.PICKLIST_VALUE_STATUS_NOT_SUBMITTED;
            if(ourCreatedOrder == null) {
                throw new CreateCMOrderException ('Not created an Order');
            }
            
            // Creating Custom Setting to Skip validations || SAFBIO-2315
            insertCustomSettings(ourCreatedOrder.id);
            
            System.debug('AAA ccmo orderId: ' + ourCreatedOrder.Id + ' Currency: ' + ourCreatedOrder.CurrencyIsoCode);
            Asset newCMEntry = AddProdManually.consumeProduct('' + ourProductItem.Id, '1', '' + ourCreatedOrder.Id, true);
            List<OrderItem> cmOrderItems = [SELECT Id, related_asset__c FROM OrderItem WHERE asset__c = :newCMEntry.Id];
            for(OrderItem oi : cmOrderItems) {
                oi.related_asset__c = lastDeviceImplant.Id;
            }
            update cmOrderItems;
        }
        else {
            // We are only putting in this request for a Cardio Messenger to be sent. We do not deal with ProductItems, not with WorkOrder, just Products.
            // The related Account - and therefore the Pricebook (0$) - is the general distribution center.
            // To find this, we need to know what areas / company code the user belongs to
            
            System.debug ('XVC 3');
            System.debug ('Creating our order. SAP Company Code: ' + xSapCompanyCode);
            ourCreatedOrder = new Order (RecordTypeId = orderRtId
                                        , PriceBook2Id = implantingFacility.crm_pricebook__c
                                        , AccountId = implantingFacility.Id
                                        , EffectiveDate = Date.today()
                                         , CurrencyIsoCode = implantingFacility.CurrencyIsoCode
                                        , Status = ORDER_INITIAL_STATUS
                                         , patient__c = patient.id
                                         , rep_for_credit__c = repForCredit
                                         , ship_to__c = orderType
                                         //, sap_company_code__c = sapCompanyCode
                                         , sap_company_code__c = getSapCompanyCode (xSapCompanyCode)
                                       );
            
            insert ourCreatedOrder;
            
            //SAFBIO-2539
            insertCustomSettings(ourCreatedOrder.id);
            List<PricebookEntry> pbes = [SELECT Id, UnitPrice FROM PricebookEntry WHERE Product2Id = :ourProduct.Id AND Pricebook2Id = :implantingFacility.crm_pricebook__c
                                        AND CurrencyIsoCode = :implantingFacility.CurrencyIsoCode];
            System.debug('AAA ProductId: ' + ourProduct.Id + ' PricebookId: ' + implantingFacility.crm_pricebook__c + ' Currency: ' + implantingFacility.CurrencyIsoCode);
            System.debug('AAA ImplantingFacility: ' + implantingFacility);
            System.debug('AAA Currency (implantingFacility): ' + implantingFacility.CurrencyIsoCode);
            System.debug('AAA Currency (order): ' + ourCreatedOrder.CurrencyIsoCode);
            System.debug('AAA orderId: ' + ourCreatedOrder.Id);
            
            if(pbes.size() == 0) throw new CreateCMOrderException (Label.ERROR_CREATE_CM_ORDER_NO_PRICEBOOK_ENTRY);
            OrderItem oi = new OrderItem(Product2Id = ourProduct.Id
                                         , OrderId = ourCreatedOrder.Id
                                         , Quantity = 1
                                         , PricebookEntryId = pbes[0].Id
                                         , UnitPrice = pbes[0].UnitPrice
                                         , related_asset__c = lastDeviceImplant.Id
										 , product_type__c = ourProduct.product_type__c
                                         , model_no__c = ourProduct.sap_model_no__c
                                         , status__c = Constants.PICKLIST_STATUS_ORDER_ITEM_NOT_IMPLANTABLE_PRODUCT
                                        );
            
            insert oi;
            
            Id idRecordType = Utility.getRecordTypeId(Asset.SObjectType, Constants.RECORD_TYPE_NAME_ASSET_US_BIOTRONIK);

            Asset ass = new Asset(Product2Id = ourProduct.Id
                                  , order_product__c = oi.Id
                                  , serialnumber_external_id__c = ourCreatedOrder.Id + '_CM'
                                  , product_type__c = ourProduct.product_type__c
                                  , Name = ourProduct.Name
                                  , AccountId = implantingFacility.Id
                                  , ContactId = patient.Id
                                  , patient__c = patient.Id
                                  , RecordTypeId = idRecordType
                                  , order__c = oi.OrderId
                                  //, sap_company_code__c = sapCompanyCode
                                  , sap_company_code__c = getSapCompanyCode (xSapCompanyCode)
                                  , model_no__c = ourProduct.sap_model_no__c
                                  , quantity=1
                                  , quantity_unit_of_measure__c= 'PC'
                                  , Status = Constants.PICKLIST_STATUS_ASSET_NOT_IMPLANTABLE_PRODUCT
                                  );
            
            if (orderType == CM_ORDER_DIRECT_SHIP 
                || orderType == CM_ORDER_DIRECT_SHIP_REPLACEMENT){
               		ass.shipped__c  = true;
            }
            else {
                    ass.shipped__c  = false;
            } 
            
            insert ass;
            oi.asset__c = ass.id;
            update oi;   
        }
        if(orderType == CM_ORDER_DIRECT_HANDOUT) {
            ourCreatedOrder.PoNumber = PO_NUMBER_HANDOUT;
        }
        else if(orderType == CM_ORDER_DIRECT_SHIP) {
            ourCreatedOrder.PoNumber = PO_NUMBER_SHIP;
        }
        else if(orderType == CM_ORDER_DIRECT_SHIP_REPLACEMENT) {
            ourCreatedOrder.PoNumber = PO_NUMBER_SHIP_REPLACE;
        }
        ourCreatedOrder.ShippingCity = tempContact.MailingCity;
        ourCreatedOrder.ShippingCountryCode = tempContact.MailingCountryCode;
        ourCreatedOrder.ShippingCountry = tempContact.MailingCountry;
        ourCreatedOrder.ShippingPostalCode = tempContact.MailingPostalCode;
        ourCreatedOrder.ShippingStateCode = tempContact.MailingStateCode;
        ourCreatedOrder.ShippingStreet = tempContact.MailingStreet;

        update ourCreatedOrder;

        Order odr = [SELECT id, ShippingCountry, Status, ShippingState  FROM Order WHERE id =: ourCreatedOrder.id];
        if(orderType == CM_ORDER_DIRECT_HANDOUT) {
            odr.Status = ORDER_FINAL_STATUS_DIRECT_HANDOUT;
        }
        else {
        	odr.Status = ORDER_FINAL_STATUS_DIRECT_SHIP;
        }

        update odr;
        
        if (selectedAddressToUpdate != null && selectedAddressToUpdate == 'Other_Address' ){
            if (odr.ShippingState != null){
                tempContact.MailingState = odr.ShippingState;
            }
        }
        updatePatientAddress(patient, tempContact, selectedAddressToUpdate);
        
        return ourCreatedOrder;
        
    }
    @AuraEnabled
    public static void createOrderReally(String orderType, Id recordId, String sObjectName, Id selectedCMProduct, String selectedAddress, Contact patientAdd, String selectedAddressToUpdate, String addrss, String selectedRep){
        Order order = createOrder(orderType, recordId, sObjectName, selectedCMProduct, selectedAddress, patientAdd, selectedAddressToUpdate, addrss, selectedRep);
        Utility.removeValidationSkip(order.id);
    }

    public static WorkOrder createWorkOrder(Id implantingPhysicianId, Id patientId, Id repAtImplantId,
                                                Id repForCreditId, Id accountId, String currencyCode){
        WorkOrder retVal = new WorkOrder(Status = ORDER_INITIAL_STATUS
                                         , AccountId = accountId
                                         , ContactId = implantingPhysicianId
                                         , implanting_physician__c = implantingPhysicianId
                                         , rep_at_implant__c = repAtImplantId
                                         , no_rep_present_at_implant__c = (repAtImplantId == null)
                                         , rep_for_credit__c = repForCreditId
                                         , patient__c = patientId
                                         , CurrencyIsoCode = currencyCode
                                        );
        insert retVal;
        
        return retVal;
    }
    public static WorkOrderLineItem createWorkOrderLineItem(WorkOrder wo){
   
        WorkOrderLineItem woli = new WorkOrderLineItem();
        woli.workOrderId = wo.Id;
        insert woli;
        return woli;
    }
        
    /* Retrieves the Order related to the last implanted device
     */
    public static Id getRelatedOrder (Asset lastImplantDevice) {
        Id retval;
        String orderProduct = (String)lastImplantDevice.get ('order_product__c');
        if (orderProduct != null) {
            List<OrderItem> ois = [SELECT Order.Id FROM OrderItem WHERE Id = :orderProduct];
            if (ois.size() > 0) {
               retval = ois[0].Order.Id; 
            }
        }
            
        return retval;
    }
    /*
     * --------------------------------------------------------------------------
     * Ticket number |   SAFBIO-2315
     * Updated by    |   Sumit
     * Date          |   04.09.2018                                               
     * Description   |   To insert the custom settings 
     * --------------------------------------------------------------------------
     */
    public static void insertCustomSettings(String orderId) {
    	Utility.insertValidationSkip(orderId);    
    }
        
    /*
     * --------------------------------------------------------------------------
     * Ticket number |   SAFBIO-1983
     * Updated by    |   Sumit
     * Date          |   04.09.2018                                               
     * Description   |   To get different address of Patient 
     * --------------------------------------------------------------------------
     */
  
    public static List<SelectOption> getAddressPicklist() {
        List<SelectOption> addressOptions = new List<SelectOption> {
            new SelectOption('none','--None--'),
            new SelectOption('Shipping_Address','Shipping Address'),
            new SelectOption('Mailing_Address','Mailing Address'),
            new SelectOption('Other_Address','Other Address')
        };
        return addressOptions;
    }
    
    /*
     * --------------------------------------------------------------------------
     * Ticket number |   SAFBIO-1983
     * Updated by    |   Sumit
     * Date          |   04.09.2018                                               
     * Description   |   To update Patient's mailing/shipping/other addresses 
     * --------------------------------------------------------------------------
     */
    @AuraEnabled
    public static void updatePatientAddress(Contact patient, Contact conFromVf, String selectedAddressToUpdate) {
        SObject sObj = null;
        if(selectedAddressToUpdate == null || selectedAddressToUpdate.equalsIgnoreCase('none')){
            return; 
        }  
        if(selectedAddressToUpdate.equalsIgnoreCase('Mailing_Address')) {
            sObj = setAddress(new List<String>{'MailingStreet', 'MailingCity', 'MailingPostalCode', 'MailingState', 'MailingCountry', 'MailingStateCode', 'MailingCountryCode', 'declined_to_provide_address__c'} , patient, conFromVf);	    	
        } else if(selectedAddressToUpdate.equalsIgnoreCase('Other_Address')) {
        	sObj = setAddress(new List<String>{'shipping_street__c', 'shipping_city__c', 'shipping_zip_postal_code__c', 'shipping_state_province__c', 'shipping_country__c' } , patient, conFromVf);    
        } else if(selectedAddressToUpdate.equalsIgnoreCase('Shipping_Address')) {
        	sObj = setAddress(new List<String>{'OtherStreet', 'OtherCity', 'OtherPostalCode', 'OtherState', 'OtherCountry', 'OtherStateCode', 'OtherCountryCode'} , patient, conFromVf);     
        } 
        if(sObj <> null) {
            
            try {
            	update sObj;
            }
            catch(Exception e) {
                throw e;
            }
        }	
    }
    
    /*
     * --------------------------------------------------------------------------
     * Ticket number |   SAFBIO-1983
     * Updated by    |   Sumit
     * Date          |   04.09.2018                                               
     * Description   |   To set Patient's mailing/shipping/other addresses 
     * --------------------------------------------------------------------------
     */    
    public static SObject setAddress(List<String> fields, Contact patient, Contact contactFromVF) {
        List<String> tempList = new List<String>{'MailingStreet', 'MailingCity', 'MailingPostalCode', 'MailingState', 'MailingCountry', 'MailingStateCode', 'MailingCountryCode', 'declined_to_provide_address__c'};
        sObject sObj = (Contact) patient;
        sObject sObjFromVF = (Contact) contactFromVF;
        Integer counter = 0;
        for(String flds : fields) {
            System.debug('CCC ccmo Field: ' + flds);
        	sObj.put(flds, sObjFromVF.get(tempList[counter++]));		    
            System.debug('CCC ccmo value on patient: ' + sObj.get(flds));
        } 
        return sObj;
    }

    public class CreateCMOrderException extends Exception {}
    
        
    public class AddressHolder {
        @AuraEnabled public String Name {get;set;}
        @AuraEnabled public String Street {get;set;}
        @AuraEnabled public String City {get;set;}
        @AuraEnabled public String StateProvince {get;set;}
        @AuraEnabled public String PostalCode {get;set;}
        @AuraEnabled public String Country {get;set;}
        @AuraEnabled public String statecode {get;set;}
        @AuraEnabled public String countrycode {get;set;}
        @AuraEnabled public String lbl_address {get;set;}
        
        
        public AddressHolder (String Name, String Street, String City, String StateProvince, String PostalCode, String Country, String lbl_address){
        	this.Name = Name;
            this.Street = Street;
            this.City = City;
            this.StateProvince = StateProvince;
            this.PostalCode = PostalCode;
            this.Country = Country;
            this.lbl_address = lbl_address;
        }
    }
    
    public class ProductHolder {
      @AuraEnabled
      public String Id {get;set;}
      @AuraEnabled
      public String Name {get;set;} 
      
        public ProductHolder(String Id, String Name){
            this.Id = Id;
            this.Name= name;
        }  
    }
/**
* used to get the picklist value for the lightning component.
*/ 
    public class picklistWrapper {
        @AuraEnabled
        public String strValue {get;set;}
        @AuraEnabled
        public String strLabel {get;set;}
        
        public picklistWrapper(String strValue, String strLabel) {
            this.strValue = strValue;
            this.strLabel = strLabel;
        }  
    }

    /*
     * get the country picklist value 
     */ 
    @AuraEnabled
	public static List<picklistWrapper> getPicklistValues() {

        List<picklistWrapper> lstPWrapper = new List<picklistWrapper>();
        Schema.DescribeFieldResult fieldResult = Contact.MailingCountryCode.getDescribe();
        
        for(Schema.PicklistEntry f : fieldResult.getPicklistValues()) {
            if (f.isActive()) {
              lstPWrapper.add(new picklistWrapper( f.getValue(), f.getLabel()));  
            }
        }
        return lstPWrapper;
   }
    /*
     * get the state picklist value 
     */
    
   @AuraEnabled
	public static List<picklistWrapper> getStatPicklistValues(String countrycode) {
       List<picklistWrapper> lstPWrapper = new List<picklistWrapper>();
        Schema.DescribeFieldResult fieldResult = User.statecode.getDescribe();
        
        for(Schema.PicklistEntry f : fieldResult.getPicklistValues()) {
            lstPWrapper.add(new picklistWrapper(f.getValue(), f.getLabel()));
        }
        return lstPWrapper;
   }
    @AuraEnabled 
       public static List<picklistWrapper> getRegonPiklistValues(String country){
           
        system.debug('I am here from region'+ country);
        Map<String,List<picklistWrapper>> objResults = new Map<String,List<picklistWrapper>>();
        /* get all country codes */
        List<String>countryCodes = new List<String>();//list that holds the country code
        
        Schema.DescribeFieldResult fieldResultCountry = Contact.MailingCountryCode.getDescribe();//get country code 
        List<Schema.PicklistEntry> contrEntries = fieldResultCountry.getPicklistValues();//parse country code to list
        
        /*get all state codes */
        List<String>stateCodes = new List<String>();//list that holds the state code
        Schema.DescribeFieldResult fieldResultState = Contact.MailingStateCode.getDescribe();//get state code 
        List<Bitset.PicklistEntryWrapper> depEntries = Bitset.wrapPicklistEntries(fieldResultState.getPicklistValues());
        
        List<String> controllingValues = new List<String>();
        
        for (Schema.PicklistEntry ple : contrEntries) {
            String valueStr = ple.getValue();
            //String labelStr = ple.getLabel();
            objResults.put(valueStr, new List<picklistWrapper>());
            controllingValues.add(valueStr);
        }
        
        for (Bitset.PicklistEntryWrapper plew : depEntries) {
            String value = plew.value;
            String label = plew.label;
            String validForBits = Bitset.base64ToBits(plew.validFor);
            for (Integer i = 0; i < validForBits.length(); i++) {
                // For each bit, in order: if it's a 1, add this label to the dependent     list for the corresponding controlling value
                String bit = validForBits.mid(i, 1);
                if (bit == '1') {
                  objResults.get(controllingValues.get(i)).add(new picklistWrapper(value, label));
                  //objResults.get(controllingValues.get(i)).add(value);
                }
            }
        }
           system.debug('objResults.get(country)'+objResults.get(country));
        return objResults.get(country);
        
    }//countryStateCodeStrac
    
    private static String getSapCompanyCode (String xSapCompanyCode) {
       return xSapCompanyCode;
    }
}