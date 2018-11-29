/* Created 2018-07-10 Florian Heer <f.heer@conciscon.de>
 * SAFBIO-1363
 * Creates a CMOrder, prefilling all possible data from the known state
 */ 

public class CreateCMOrder {
    ApexPages.StandardController stdController;

    public static final String CM_ORDER_DIRECT_HANDOUT = 'Direct Hand-out';
    public static final String CM_ORDER_DIRECT_SHIP = 'Direct Ship';
    public static final String CM_ORDER_DIRECT_SHIP_REPLACEMENT = 'Direct Ship Replacement';
    public static final String RT_ORDER_CARDIO_MESSENGER_DN = 'cardio_messenger_order';
    public static final String CMO_SETTING_NAME_DEFAULT_ACCOUNT = 'DefaultSAPAccountID';
    public static final String ORDER_INITIAL_STATUS = Constants.PICKLIST_VALUE_STATUS_NOT_SUBMITTED;
    public static final String ORDER_FINAL_STATUS_DIRECT_SHIP = 'Pending HMSC Registration'; /*'Submitted for Processing'*/
    public static String ORDER_FINAL_STATUS_DIRECT_HANDOUT = Constants.PICKLIST_VALUE_ORDER_STATUS_PENDING_SAP; /* Status : Pending SAP Submission, Added by Sumit || SAFBIO-2315 */
    public static final String PO_NUMBER_HANDOUT = 'CM';
    public static final String PO_NUMBER_SHIP = 'CMDS';
    public static final String PO_NUMBER_SHIP_REPLACE = 'CMDSR';
    public static final String PRODUCT_TYPE_CARDIO_MESSENGER = Constants.PICKLIST_VALUE_PRODUCT_TYPE_CARDIO_MESSENGER;
    
    
    Contact patient;
    public Contact patientAdd {get;set;}
    public Contact tempContact {get;set;} 
    Asset lastDeviceImplant;
    Id implantingFacilityId; // Account Id
    Account implantingFacility;
    public Id repForCredit {get; set;} // User-Id
    String repForCreditName; // Displaying purposes
    String xSapCompanyCode;
    Id implantingPhysicianId;
    Id ourId;
    Public ProductItem ourProductItem {get;set;}
    Public Product2 ourProduct {get;set;}
    public String orderType {get;set;} // Direct handout, Direct Ship, Direct Ship replacement
    public List<SelectOption> orderTypeItems {get;set;}
    public String selectedCMProduct {get;set;}
    public List<SelectOption> avlCMProducts;
    public List<AddressHolder> patientAddresses {get; set;}
    AddressHolder mailingAdd, shippingAdd, otherAdd;
    public Boolean showAddressInput {get;set;}
    public Boolean stillInInput {get;set;}
    public Boolean showSummary {get;set;}
    public Boolean showResult {get;set;}
    public Boolean patientDead {get;set;}
    
    public String barcode {get; set;}
    public String inventoryName {get;set;}
    public String selectedAddress {get;set;}
    public String selectedAddressToUpdate {get;set;}
    private Contact conFromVf{get;set;}
    List<String> deviceProductTypes;
    
    public CreateCMOrder (ApexPages.StandardController stdController) {
        ourId = ApexPages.currentPage().getParameters().get('id');
        this.stdController = stdController;
        SObject ourRecord = stdController.getRecord();
        deviceProductTypes = new List<String>(); 
        deviceProductTypes = Utility.getContainedProductTypes(Constants.VALI_CAT_DEVICE);
        // SAFBIO-2533
        deviceProductTypes.add (Constants.PICKLIST_VALUE_PRODUCT_TYPE_LOOP_RECORDER);
        tempContact = new Contact();
        //Added by Sumit || SAFBIO-2256
        tempContact.MailingCountryCode = 'US';
        showAddressInput = false;
        stillInInput = true; showSummary = false; showResult = false; patientDead = false;
        
        orderTypeItems = new List<SelectOption>();
        orderTypeItems.add(new SelectOption(CM_ORDER_DIRECT_HANDOUT,          CM_ORDER_DIRECT_HANDOUT));
        orderTypeItems.add(new SelectOption(CM_ORDER_DIRECT_SHIP,             CM_ORDER_DIRECT_SHIP));
        orderTypeItems.add(new SelectOption(CM_ORDER_DIRECT_SHIP_REPLACEMENT, CM_ORDER_DIRECT_SHIP_REPLACEMENT));
        
        
        // Have we been started from a complaint?
        if(ourRecord.getSObjectType().getDescribe().getName() == 'complaint__c') {
            orderType = CM_ORDER_DIRECT_SHIP_REPLACEMENT;
            Boolean dataFound = false;
            complaint__c com = [SELECT Id, asset__c, MDRF_Order__c FROM complaint__c WHERE Id = :ourId];
            if(com.asset__c != null) {
                List<Asset> assets = [SELECT Id, patient__c, product_type__c FROM Asset WHERE Id = :com.asset__c];
                if(assets.size() > 0) {
                
                    patientAdd = [SELECT Id, Name, FirstName, LastName, Status__c
                                  , MailingStreet, MailingPostalCode, MailingCity, MailingState, MailingStateCode, MailingCountry, MailingCountryCode
                                  , OtherStreet, OtherPostalCode, OtherCity, OtherState, OtherStateCode, OtherCountryCode
                                  , OtherCountry, shipping_street__c, shipping_zip_postal_code__c, shipping_city__c, shipping_state_province__c, shipping_country__c
                                  
                                  FROM Contact WHERE Id = :assets[0].patient__c];
                    patient = patientAdd;
                    dataFound = true;
                }
            }
            else if(com.MDRF_Order__c != null) {
                List<Order> orders = [SELECT Id, patient__c FROM Order WHERE Id = :com.MDRF_Order__c];
                if(orders.size() > 0) {
                    patientAdd = [SELECT Id, Name, FirstName, LastName, Status__c
                                  , MailingStreet, MailingPostalCode, MailingCity, MailingState, MailingStateCode, MailingCountry, MailingCountryCode
                                  , OtherStreet, OtherPostalCode, OtherCity, OtherState, OtherStateCode, OtherCountryCode
                                  , OtherCountry, shipping_street__c, shipping_zip_postal_code__c, shipping_city__c, shipping_state_province__c, shipping_country__c
                                  
                                  FROM Contact WHERE Id = :orders[0].patient__c];
                    patient = patientAdd;
                    dataFound = true;
                    
                }
            }
                
        }
        
        // Have we been started from a contact?
        else if(ourRecord.getSObjectType().getDescribe().getName() == 'Contact') {
            orderType = CM_ORDER_DIRECT_HANDOUT;
            patient = (Contact)ourRecord;
            patientAdd = [SELECT Id, Name, FirstName, LastName, Status__c
                          , MailingStreet, MailingPostalCode, MailingCity, MailingState, MailingStateCode, MailingCountry, MailingCountryCode
                          , OtherStreet, OtherPostalCode, OtherCity, OtherState, OtherStateCode, OtherCountryCode
                          , OtherCountry, shipping_street__c, shipping_zip_postal_code__c, shipping_city__c, shipping_state_province__c, shipping_country__c
                          
                          FROM Contact WHERE Id = :ourRecord.Id];
        }
        if(patientAdd.Status__c == 'Deceased'){
            stillInInput = false;
            patientDead = true;
			ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.INFO, Label.LBL_CM_ORDER_PATIENT_DEAD));
            return;
        }
        
        lastDeviceImplant = getLastDeviceFromPatient (patient, deviceProductTypes);
        implantingPhysicianId = lastDeviceImplant.implanting_physician__c;
        implantingFacilityId = lastDeviceImplant.AccountId;
        Id orderId = getRelatedOrder (lastDeviceImplant);

        // FH 2018-11-09: setting a sane value to the company code
        List<User> usrs = [SELECT sap_company_code__c FROM User WHERE Id = :UserInfo.getUserId ()];
        if (usrs.size () > 0) {
            setSapCompanyCode (usrs [0].sap_company_code__c);
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
                setSapCompanyCode (orders[0].rep_for_credit__r.sap_company_code__c);
                System.debug('CCC2 sapCompanyCode: ' + xSapCompanyCode);
            }
            else {
                // No code here, just for full clarification: repForCredit intentionally left blank.
                // Needs to be selected by the current user.                
            }
        }
        
        
        patientAddresses = new List<AddressHolder>();
        mailingAdd = new AddressHolder();
        mailingAdd.Name = 'Mailing Address';
        mailingAdd.Street = patientAdd.MailingStreet;
        mailingAdd.PostalCode = patientAdd.MailingPostalCode;
        mailingAdd.City = patientAdd.MailingCity;
        mailingAdd.StateProvince = patientAdd.MailingState;
        mailingAdd.Country = patientAdd.MailingCountry;
        
        patientAddresses.add(mailingAdd);
        shippingAdd = new AddressHolder();
        shippingAdd.Name = 'Shipping Address';
        shippingAdd.Street = patientAdd.OtherStreet;
        shippingAdd.PostalCode = patientAdd.OtherPostalCode;
        shippingAdd.City = patientAdd.OtherCity;
        shippingAdd.StateProvince = patientAdd.OtherState;
        shippingAdd.Country = patientAdd.OtherCountry;
        patientAddresses.add(shippingAdd);
        
        otherAdd = new AddressHolder();
        otherAdd.Name = 'Other Address';
        otherAdd.Street = patientAdd.shipping_street__c;
        otherAdd.PostalCode = patientAdd.shipping_zip_postal_code__c;
        otherAdd.City = patientAdd.shipping_city__c;
        otherAdd.StateProvince = patientAdd.shipping_state_province__c;
        otherAdd.Country = patientAdd.shipping_country__c;
        
        patientAddresses.add(otherAdd);
        
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
            throw new CreateCMOrderException (Label.ERR_CREATE_CM_ORDER_ACCOUNT_MISSING);
        }
    }
    

    public void searchProductItems() {
        List<ProductItem> pis;
        if(barcode != null && barcode.length() > 0) {
            pis = [SELECT Id, Product2.Name, SerialNumber FROM ProductItem WHERE SerialNumber = :barcode AND QuantityOnHand > 0 AND product_type__c = : PRODUCT_TYPE_CARDIO_MESSENGER];
        }
        else if(inventoryName != null && inventoryName.length() > 0) {
            String searchString = '%' + inventoryName + '%';
            List<ServiceResource> sRes = [Select LocationId FROM ServiceResource WHERE RelatedRecordId = :UserInfo.getUserId() LIMIT 1];
            if(sRes.size() > 0) {
            	pis = [SELECT Id, Product2.Name, SerialNumber FROM ProductItem WHERE Product2.Name LIKE :searchString AND LocationId = :sRes[0].LocationId AND QuantityOnHand > 0 AND product_type__c = : PRODUCT_TYPE_CARDIO_MESSENGER];
            }
            else {
                throw new CreateCMOrderException(Label.ccmo_No_Service_Resource_for_current_User);
            }
        }
        avlCMProducts = new List<SelectOption>();
        if(pis != null && pis.size() > 0) {
            for(ProductItem pi : pis) {
                avlCMProducts.add(new SelectOption (pi.Id, (pi.Product2.Name + '(' + pi.SerialNumber + ')')));
        
            }
        }
    }    
    
    public List<SelectOption> getAvailableCMProducts() {
        List<SelectOption> retval;
        // ApexPages.addMessage(new ApexPages.message (ApexPages.severity.INFO, 'orderType = ' + orderType));
        if(orderType == CM_ORDER_DIRECT_HANDOUT) {
            retval = avlCMProducts;
        }
        else {
            System.debug('Implanting facility: ' + implantingFacility.Id + ' crm_pricebook: ' + implantingFacility.crm_pricebook__c
                        + ' CurrencyIsoCode: ' + implantingFacility.CurrencyIsoCode + ' product_type: ' + Constants.PICKLIST_VALUE_PRODUCT_TYPE_CARDIO_MESSENGER);
            
            retval = new List<SelectOption>();
            List<PricebookEntry> pbes = [SELECT Id, Product2.Id, Product2.Name FROM PricebookEntry WHERE Pricebook2Id = :implantingFacility.crm_pricebook__c
                                        AND CurrencyISOCode = :implantingFacility.CurrencyIsoCode
                                        AND IsActive=True
                                        AND Product2.product_type__c = :Constants.PICKLIST_VALUE_PRODUCT_TYPE_CARDIO_MESSENGER
                                        ORDER BY Product2.Name];
            for(PricebookEntry pbe : pbes ) {
                retval.add(new SelectOption(pbe.Product2.Id, pbe.Product2.Name));
            }
        }
        
        if(retval == null) retval = new List<SelectOption>();
        return retval;
    }
    
    public PageReference goBack() {
/*           String hostname = ApexPages.currentPage().getHeaders().get('Host');
           String optyURL2 = 'https://'+hostname+'/'+'/00Q/e?nooverride=1';
           pagereference pageref = new pagereference(optyURL2);
           pageref.setredirect(true);
           return pageref;
*/
        PageReference pr = new ApexPages.standardController(stdController.getRecord()).view();
        pr.setRedirect(true);
        return pr;
    }
    
    public PageReference createOrder () {
        Order order = reallyCreateOrder();

        // Deleting custom Settings || SAFBIO-2315
        // delete [SELECT id FROM skip_validation__c LIMIT 10000];
        Utility.removeValidationSkip(order.id);

        return null;
    }
    
    public Order reallyCreateOrder() {
        Order ourCreatedOrder;
        System.debug ('XVC 1');
        Id orderRtId = Utility.getRecordTypeId(Order.SObjectType, Constants.RECORD_TYPE_NAME_ORDER_CARDIO_MESSENGER);
		System.debug ('orderType: ' + orderType);
        System.debug ('XVC 2');
        If(orderType == CM_ORDER_DIRECT_HANDOUT) {
            // Okay, we are dealing with an actual physical device. So we have to create a WorkOrder
            // Additionally, we don't care about addresses. Just create the Order and fire this.
            // QUESTION: Any rule checking here?
            WorkOrder wo = createWorkOrder(implantingPhysicianId, patient.Id, repForCredit, repForCredit, implantingFacilityId, UserInfo.getDefaultCurrency());
            WorkOrderLineItem woli =  createWorkOrderLineItem(wo);
            System.debug('AAA ccmo Currency WorkOrder: ' + wo.CurrencyIsoCode + ' User: ' + UserInfo.getDefaultCurrency());
            // If it is direct Handout, Setting the status to 'Pending SAP Submission' 
            WorkOrderConversion.DEFAULT_ORDER_STATUS = ORDER_FINAL_STATUS_DIRECT_HANDOUT;
            ourCreatedOrder = WorkOrderConversion.convertToOrder(wo.id, orderRtId, getSapCompanyCode ());
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
                                         , sap_company_code__c = getSapCompanyCode ()
                                       );
            
            insert ourCreatedOrder;

			//SAFBIO-2539
            insertCustomSettings(ourCreatedOrder.id);
            System.debug ('XVC 4');

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
                                         // SAFBIO-1986 || Setting product type and model number
										 , product_type__c = ourProduct.product_type__c
                                         , model_no__c = ourProduct.sap_model_no__c
                                         //SAFBIO-1893//CM Order creation will set the auto created Order Item/Asset records to the status "Not Implantable product".
                                         , status__c = Constants.PICKLIST_STATUS_ORDER_ITEM_NOT_IMPLANTABLE_PRODUCT
                                        );
            insert oi;
            
            
            // SAFBIO-1989 - Asset needs to be created so that SAP can update the serial number
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
                                  , sap_company_code__c = getSapCompanyCode ()
                                  , model_no__c = ourProduct.sap_model_no__c
                                  , quantity=1
                                  , quantity_unit_of_measure__c= 'PC'
								  //SAFBIO-1893//CM Order creation will set the auto created Order Item/Asset records to the status "Not Implantable product".
                                  , Status = Constants.PICKLIST_STATUS_ASSET_NOT_IMPLANTABLE_PRODUCT
                                  );
            
            //SAFBIO-1893 // (Asset related to a CM Order which PO# equals CMDS or CMDSR) have a flag (not visible the user) on the Asset record
            // so it is excluded from the validation upon the creation if this flag is set to true
            
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
        // SAFBIO-2050
        if(orderType == CM_ORDER_DIRECT_HANDOUT) {
            ourCreatedOrder.PoNumber = PO_NUMBER_HANDOUT;
        }
        else if(orderType == CM_ORDER_DIRECT_SHIP) {
            ourCreatedOrder.PoNumber = PO_NUMBER_SHIP;
        }
        else if(orderType == CM_ORDER_DIRECT_SHIP_REPLACEMENT) {
            ourCreatedOrder.PoNumber = PO_NUMBER_SHIP_REPLACE;
        }
        
        System.debug('Shipping City: ' + tempContact.MailingCity);
        ourCreatedOrder.ShippingCity = tempContact.MailingCity;
        System.debug('Shipping Country: ' + tempContact.MailingCountryCode);
        ourCreatedOrder.ShippingCountryCode = tempContact.MailingCountryCode;
        ourCreatedOrder.ShippingCountry = tempContact.MailingCountry;
        ourCreatedOrder.ShippingPostalCode = tempContact.MailingPostalCode;
        ourCreatedOrder.ShippingStateCode = tempContact.MailingStateCode;
        ourCreatedOrder.ShippingStreet = tempContact.MailingStreet;
		if(orderType <> CM_ORDER_DIRECT_HANDOUT) 
			ourCreatedOrder.Status = ORDER_FINAL_STATUS_DIRECT_SHIP;
        update ourCreatedOrder;
        
        showSummary = false;
        showResult = true;
        
        //Added by Sumit || SAFBIO-1983 
        updatePatientAddress(patient, conFromVf);
        
        return ourCreatedOrder;
    }
    
    public void setAddress() {
        selectedAddress = System.currentPagereference().getParameters().get('selAddress');
        System.debug('Address selected is "' + selectedAddress + '"');
    }
    
    public void newAddress() {
        showAddressInput = true;
        selectedAddress = '';
    }
    
    public void prepareOrder() {
        
		// Added by Sumit SAFBIO-1916 || To show selected country values on the final cardio messanger order page.
        for(Schema.PicklistEntry p : Order.ShippingCountryCode.getDescribe().getPicklistValues()) {
            if(tempContact.MailingCountryCode <> null && p.getValue() == tempContact.MailingCountryCode) {
            	tempContact.MailingCountry = p.getLabel(); 
                break;
            }	    
        }  
        conFromVf = tempContact;
        selectedAddress = System.currentPagereference().getParameters().get('selAddress');
        
        if(selectedAddress == 'Mailing Address') {
            // newShippingAddress = mailingAdd;
            
            tempContact.MailingStreet = patientAdd.MailingStreet;
            tempContact.MailingCity = patientAdd.MailingCity;
            tempContact.MailingPostalCode = patientAdd.MailingPostalCode;
            tempContact.MailingStateCode = patientAdd.MailingStateCode;
            tempContact.MailingCountryCode = patientAdd.MailingCountryCode;
            tempContact.MailingState = patientAdd.MailingState;
            tempContact.MailingCountry = patientAdd.MailingCountry;
            
        }
        else if(selectedAddress == 'Shipping Address') {
            // newShippingAddress = shippingAdd;
            tempContact.MailingStreet = patientAdd.OtherStreet;
            tempContact.MailingCity = patientAdd.OtherCity;
            tempContact.MailingPostalCode = patientAdd.OtherPostalCode;
            tempContact.MailingStateCode = patientAdd.OtherStateCode;
            tempContact.MailingCountryCode = patientAdd.OtherCountryCode;
            tempContact.MailingState = patientAdd.OtherState;
            tempContact.MailingCountry = patientAdd.OtherCountry;
            
        }
        else if(selectedAddress == 'Other Address') {
            // newShippingAddress = otherAdd; 
            tempContact.MailingStreet = patientAdd.shipping_street__c;
            tempContact.MailingCity = patientAdd.shipping_city__c;
            tempContact.MailingPostalCode = patientAdd.shipping_zip_postal_code__c;
            tempContact.MailingState = patientAdd.shipping_state_province__c;
            tempContact.MailingCountry = patientAdd.shipping_country__c;
             
        }
        
        stillInInput = false;
        showSummary = true;
        
        if(orderType == CM_ORDER_DIRECT_HANDOUT) {
            ourProductItem = [SELECT Id, Product2.Name, SerialNumber FROM ProductItem WHERE Id = :selectedCMProduct];
        }
        else {
            ourProduct = [SELECT Id, Name, product_type__c, sap_model_no__c  FROM Product2 WHERE Id = :selectedCMProduct];
        }
    }
    
    public static WorkOrder createWorkOrder(Id implantingPhysicianId, Id patientId, Id repAtImplantId,
                                                Id repForCreditId, Id accountId, String currencyCode)
    {
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
    public WorkOrderLineItem createWorkOrderLineItem(WorkOrder wo){
   
    WorkOrderLineItem woli = new WorkOrderLineItem();
    woli.workOrderId = wo.Id;
    insert woli;
    return woli;
    }

    
    /* Retrieves the latest implanted device (ICD, Pacemaker) from a patient.
     * Either returns an Asset or throws an Exception.
     */
    public static Asset getLastDeviceFromPatient (Contact con, List<String> deviceProductTypes) {
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
     * Ticket number |   SAFBIO-1983
     * Updated by    |   Sumit
     * Date          |   04.09.2018                                               
     * Description   |   To get different address of Patient 
     * --------------------------------------------------------------------------
     */
    public List<SelectOption> getAddressPicklist() {
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
    @testVisible
    private void updatePatientAddress(Contact patient, Contact conFromVf) {
        SObject sObj = null;
        if(selectedAddressToUpdate == null || selectedAddressToUpdate.equalsIgnoreCase('none'))
            return;
        if(selectedAddressToUpdate.equalsIgnoreCase('Mailing_Address')) {
            sObj = setAddress(new List<String>{'MailingStreet', 'MailingCity', 'MailingPostalCode', 'MailingState', 'MailingCountry', 'MailingStateCode', 'MailingCountryCode'} , patient, conFromVf);	    	
        } else if(selectedAddressToUpdate.equalsIgnoreCase('Other_Address')) {
        	sObj = setAddress(new List<String>{'shipping_street__c', 'shipping_city__c', 'shipping_zip_postal_code__c', 'shipping_state_province__c', 'shipping_country__c' } , patient, conFromVf);    
        } else if(selectedAddressToUpdate.equalsIgnoreCase('Shipping_Address')) {
        	sObj = setAddress(new List<String>{'OtherStreet', 'OtherCity', 'OtherPostalCode', 'OtherState', 'OtherCountry', 'OtherStateCode', 'OtherCountryCode'} , patient, conFromVf);     
        } 
        
		System.debug('BBB ccmo mailingstreet (2up): ' + sObj.get('MailingStreet') + ' fromVF: ' + conFromVf.MailingStreet);
        System.debug('BBB ccmo mailingstatecode (2up): ' + sObj.get('MailingStateCode') + ' fromVF: ' + conFromVf.MailingStateCode);
        System.debug('BBB ccmo mailingCountrycode (2up): ' + sObj.get('MailingCountryCode') + ' fromVF: ' + conFromVf.MailingCountryCode);
        System.debug('BBB ccmo declined address (2up): ' + sObj.get('declined_to_provide_address__c') + ' fromVF: ' + conFromVf.declined_to_provide_address__c);
        
        if(sObj <> null) {
            try {
            	update sObj;
            }
            catch(Exception e) {
                System.debug('BBB ccmo mailingstreet (2up): ' + sObj.get('MailingStreet') + ' fromVF: ' + conFromVf.MailingStreet);
                System.debug('BBB ccmo mailingstatecode (2up): ' + sObj.get('MailingStateCode') + ' fromVF: ' + conFromVf.MailingStateCode);
                System.debug('BBB ccmo mailingCountrycode (2up): ' + sObj.get('MailingCountryCode') + ' fromVF: ' + conFromVf.MailingCountryCode);
                System.debug('BBB ccmo declined address (2up): ' + sObj.get('declined_to_provide_address__c') + ' fromVF: ' + conFromVf.declined_to_provide_address__c);
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
    private SObject setAddress(List<String> fields, Contact patient, Contact contactFromVF) {
        List<String> tempList = new List<String>{'MailingStreet', 'MailingCity', 'MailingPostalCode', 'MailingState', 'MailingCountry', 'MailingStateCode', 'MailingCountryCode'};
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
    
    /*
     * --------------------------------------------------------------------------
     * Ticket number |   SAFBIO-2315
     * Updated by    |   Sumit
     * Date          |   04.09.2018                                               
     * Description   |   To insert the custom settings 
     * --------------------------------------------------------------------------
     */
    public void insertCustomSettings(String orderId) {
        Utility.insertValidationSkip(orderId);
    	//skip_validation__c skipValidation = new skip_validation__c(name=orderId,to_skip_validation__c=true);
        //insert skipValidation;
    }

    public class CreateCMOrderException extends Exception {}

    public class AddressHolder {
        public String Name {get;set;}
        public String Street {get;set;}
        public String City {get;set;}
        public String StateProvince {get;set;}
        public String PostalCode {get;set;}
        public String Country {get;set;}
    } 
    
    private String getSapCompanyCode () {
        return xSapCompanyCode;
    }
    
    private void setSapCompanyCode (String newCode) {
        if (newCode != null) {
            xSapCompanyCode = newCode;
        }
    }
}