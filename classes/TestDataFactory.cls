/**
 * Test Data factory for test classes 
 * 
 * @author            SNPA
 * @created           2018-04-10
 * @systemLayer       TestDataFactory 
 *  
 */
@isTest
public class TestDataFactory {

    /** 
     * Method to create an Account instance
     *
     * @return     Account  Return an instance of Account    
     * @author     SNPA 
     */
    public static Account createAccount() {
        Account objAccount = new Account(Name = 'Test Account',
                sap_company_code__c = '5500',
                status__c = 'active');
        return objAccount;
    }

    /** 
     * Method to create an Auto Running Number custom setting instance
     * 
     * @param      pYear  Takes current year as an Integer   
     * @return     Auto_running_numbers__c  returns an instance of autonumber setting
     * @author     SNPA 
     */
    public static Auto_Running_Numbers__c createAutoNumberSetting(Integer pYear) {
        return new Auto_Running_Numbers__c(Name = 'Auto Running Numbers',
                CI_Number__c = 2,
                MDR_Number__c = 31,
                RP_Number__c = 14,
                Running_Number_Year__c = pYear
        );
    }

    /** 
     * Method to create an instance of User with given Profile
     * 
     * @param      profileId    Id of Profile  
     * @return     User      returns an instance of User
     * @author     SNPA 
     */
    public static User createUser(Id profileId, String userAlias) {
        if(userAlias.length() > 8) throw new TestDataFactoryException('userAlias can only be 8 characters max.');
        
        return new User(Alias = userAlias,
                Email = userAlias + '@testorg.com',
                EmailEncodingKey = 'UTF-8',
                LastName = 'Testing' + userAlias,
                LanguageLocaleKey = 'en_US',
                FirstName = 'TEST',
                LocaleSidKey = 'en_US',
                ProfileId = profileId,
                Country = 'United States',
                Phone = '2439834',
                MobilePhone = '84589568546',
                Title = 'CEO',
                Department = 'Bio',
                Street = 'Test Street',
                City = 'Test City',
                State = 'California',
                PostalCode = '12345',
                TimeZoneSidKey = 'America/Los_Angeles',
                Username = userAlias + '@testorg.com',
                sap_company_code__c = '5500');
    }
    
    public static User createUser (Id profileId) {
        // Florian Heer <f.heer@conciscon.de>
        // Allows to create more than one user in a session
        Blob b = Crypto.generateAesKey(128);
        String nameSuffix = EncodingUtil.convertToHex(b).left(4);

        return createUser(profileId, 'user' + nameSuffix);
    }

    /** 
     * Method to create an instance of Case
     * 
     * @return     Case      returns an instance of Case
     * @author     SNPA 
     */
    public static Case createCase() {
        Case objCase = new Case(Status = 'New',
                Origin = 'Phone',
                CurrencyIsoCode = 'USD');
        return objCase;
    }

    /** 
     * Method to create an instance of Compalaint for a Case
     * 
     * @param      caseId        Id of Case
     * @return     Complaint__c    Returns an instance of Complaint record
     * @author     SNPA 
     */
    public static complaint__c createComplaint(Id caseId) {
        complaint__c objComplaint = new complaint__c(case__c = caseId, date_info_received_by_manufacturer__c = system.today());
        return objComplaint;
    }

    /** 
     * @deprecated use createOrder(Id accountId, Id pricebookId, Id physicianId, Id patientId)
     * ! consumes DML statements !
     * Method to create an instance of Order
     * Only use if you want to create ONE Order and don't care about other Objects
     * 
     * @param      accountId    Id of Account
     * @return     Order        Returns an instance of Order
     * @author     SNPA 
     */
    public static Order createOrder(Id accountId) {
        Contact patient = createPatient(true);

        Contact physician = createPhysician(false);
        physician.AccountId = accountId;
        insert physician;
        Id pricebookId = Test.getStandardPricebookId();

        return createOrder(accountId, pricebookId, physician.Id, patient.Id);
    }

    /**
     * Method to create an instance of Order
     *
     * @param accountId Id of Account
     * @param pricebookId Id of Pricebook
     * @param physicianId Contact Id of physician
     * @param patientId Contact Id of patient
     *
     * @return Returns an instance of Order
     * @author ARWE
     */
    public static Order createOrder(Id accountId, Id pricebookId, Id physicianId, Id patientId) {
        Order order = new Order(AccountId = accountId,
                Status = Constants.PICKLIST_VALUE_ORDER_STATUS_NOT_SUBMITTED,
                EffectiveDate = System.today(),
                rep_for_credit__c = UserInfo.getUserId(),
                patient__c = patientId,
                rep_at_implant__c = UserInfo.getUserId(),
                Pricebook2Id = pricebookId,
                referring_physician__c = physicianId
        );
        return order;
    }

    /**
     * @deprecated use createAsset(Id accountId, Id productId)
     * ! consumes DML statements !
     * Method to create an implanted asset for given account
     * 
     * @param      accountId    Id of Account
     * @return     Asset        Returns an instance of Asset
     * @author     SNPA 
     */
    public static Asset createAsset(Id accountId) {
        Product2 prod = new Product2(Name = 'ICD');
        insert prod;
        return createAsset(accountId, prod.Id);
    }

    /**
     * Method to create an implanted asset for given account
     *
     * @param accountId Id of Account
     * @param productId Id product2 to be implanted
     *
     * @return Returns an instance of Asset
     * @author ARWE
     */
    public static Asset createAsset(Id accountId, Id productId) {
        Asset objAsset = new Asset(Name = 'test asset',
                CurrencyIsoCode = 'USD',
                manufacturer__c = 'BIOTRONIK',
                AccountId = accountId,
                InstallDate = System.today().addDays(-365),
                batch_no__c = '22',
                Product2Id = productId,
                model_no__c = '23721',
                SerialNumber = '2355',
                date_of_manufacture__c = System.today().addDays(-565),
                Status = 'Implanted',
                oos_additional_information__c = 'test description',
                expiration_date_ubd__c = System.today().addDays(1565),
                UDI__c = '123',
                product_type__c = Constants.PICKLIST_VALUE_PRODUCT_TYPE_ICD
        );
        return objAsset;
    }

    /**
     * @deprecated use createOrder(Id accountId, Id pricebookId, Id physicianId, Id patientId)
     * ! consumes DML statements !
     * Method to create OrderItem
     * 
     * @param      orderId      Id of Order
     * @return     OrderItem    Returns an instance of OrderItem
     * @author     FH 
     */
    public static OrderItem createOrderItem(Id orderId) {
        Product2 prod = new Product2(Name = 'ICD');
        insert prod;
        Id pricebookId = Test.getStandardPricebookId();
        PricebookEntry standardPrice = createPricebookEntry(pricebookId,prod.Id);
        insert standardPrice;

        return createOrderItem(orderId, standardPrice.Id);
    }

    /**
     * Method to create a PricebookEntry
     *
     * @param pricebookId Id of Pricebook
     * @param productId Id of Product
     *
     * @return Returns an instance of PricebookEntry
     * @author ARWE
     */
    public static PricebookEntry createPricebookEntry(Id pricebookId, Id productId){
        return new PricebookEntry(Pricebook2Id = pricebookId, Product2Id = productId, UnitPrice = 10000, IsActive = true);
    }

    /**
     * Method to create OrderItem
     *
     * @param orderId Id of Order
     * @param pricebookEntryId Id of pricebookEntry
     *
     * @return Returns an instance of OrderItem
     * @author ARWE
     */
    public static OrderItem createOrderItem(Id orderId, Id pricebookEntryId) {
        OrderItem objOrderItem = new OrderItem(
                OrderId = orderId,
                Quantity = 1,
                UnitPrice = 10,
                PricebookEntryId = pricebookEntryId,
                status__c = 'Implanted',
                expiration_date_ubd__c = Date.today().addDays(20),
                udi__c = '6254879552412397745',
                serial_number__c = '62547891332154'
        );
        return objOrderItem;
    }


    /** 
     * Creates an OrderItem for a specific product;
     * PricebookEntry is taken from the standard pricebook
     * 
     * @param      orderId      Id of Order
     * @param      productId    Id of Product
     * @param      currencyIsoCode  currency code
     * @return     OrderItem    Returns an instance of OrderItem
     * @author     FH 
     */
    public static OrderItem createOrderItem(Id orderId, Id productId, String currencyIsoCode) {
        return createOrderItem(orderId, productId, currencyIsoCode, Test.getStandardPricebookId());
    }

    /** 
     * Creates an OrderItem for a specific product;
     * PricebookEntry is taken from the standard pricebook
     * 
     * @param      orderId      Id of Order
     * @param      productId    Id of Product
     * @param      currencyIsoCode  currency code
     * @return     OrderItem    Returns an instance of OrderItem
     * @author     FH 
     */
    public static OrderItem createOrderItem(Id orderId, Id productId, String currencyIsoCode, Id pricebookId) {
        OrderItem oi;

        List<Product2> products = [SELECT Id, product_type__c, sap_model_no__c FROM Product2 WHERE Id = :productId];

        List<PricebookEntry> pbes = [
                SELECT Id, UnitPrice, Product2.Name
                FROM PricebookEntry
                WHERE Product2Id = :productId
                AND Pricebook2Id = :pricebookId AND IsActive = TRUE
                AND CurrencyIsoCode = :currencyIsoCode
        ];
        if (pbes.size() > 0) {
            System.debug('PricebookEntry: ' + pbes[0].Id + ' - ' + pbes[0].UnitPrice + ' - ' + pbes[0].Product2.Name);

            oi = new OrderItem(
                    OrderId = orderId,
                    Quantity = 1,
                    serial_number__c = 'test',
                    PricebookEntryId = pbes[0].Id,
                    status__c = 'Implanted',
                    expiration_date_ubd__c = Date.today().addDays(20)
                    , UnitPrice = pbes[0].UnitPrice
                    , product_type__c = products[0].product_type__c
                    , model_no__c = products[0].sap_model_no__c
            );
        } else {
            throw new TestDataFactoryException('Cannot find the product in the pricebook');
        }
        return oi;

    }

    /**
       * Creates an Location instance
       *
       * @param      locsName       Name of Location
       * @return     Schema.location   Returns an instance of Location
       * @author     FH
       */
    public static Schema.Location createLocation(String locsName) {
        Schema.Location objLocation = new Schema.Location();
        objLocation.Name = locsName;
        objLocation.LocationType = 'Warehouse';
        return objLocation;
    }

    /** 
     * Creates Contact with Patient record type
     * 
     * @param      bInsert       boolean to specify if the record is to be inserted
     * @param      idAccount     Id of related Account
     * @return     Contact       Returns an instance of Contact
     * @author     FH 
     */
    public static Contact createPatient(Boolean bInsert, Id idAccount) {
        Contact con = createPatient(false);
        con.AccountId = idAccount;

        if (bInsert) {
            insert con;
        }
        return con;
    }

    /** 
     * Creates Contact with Patient record type
     * 
     * @param      bInsert      boolean to specify if the record is to be inserted
     * @return     Contact       Returns an instance of Contact
     * @author     FH 
     */
    public static Contact createPatient(Boolean bInsert) {
        Contact con = new Contact();

        // Florian Heer <f.heer@conciscon.de> 2018-07-24
        // Prevents duplicate check from firing
        Blob b = Crypto.generateAesKey(128);
        String nameSuffix = EncodingUtil.convertToHex(b).left(8);

        con.FirstName = 'John';
        con.LastName = 'Doe' + nameSuffix;
        con.RecordTypeId = Utility.getRecordTypeId(Contact.SObjectType, Constants.RECORD_TYPE_NAME_CONTACT_US_PATIENT);

        con.declined_to_provide_address__c = true;
        con.declined_to_provide_dob__c = true;
        con.declined_to_provide_phone__c = true;
        con.declined_to_provide_ssn__c = true;

        con.sap_company_code__c = ' 0100';
        con.hmsc_registration__c = false;

        if (bInsert) {
            insert con;
        }
        return con;
    }
    
    /**
     * Creates Analysis Report for Complaint
     *
     * @param      idAccount     		Id of Complaint
     * @return     Analysis_Report__c   Returns an instance of Analysis_Report__c
     * @author     snpa
    */
    public static Analysis_Report__c createAnalysisReport(Id complaintId) {
        Analysis_Report__c analysisReport = new Analysis_Report__c(complaint__c = complaintId,
                                                                   date_sent_to_fda__c = system.today(), 
                                                                   device_evaluated_by_manufacturer__c = 'Yes',
                                                                   method_code__c = '77: DO NOT USE',
                                                                   result_code__c = '102: Incompatible Component/ Accessory',
                                                                   conclusion_code__c = '27: Cause Traced to Training');
        return analysisReport;
    }
    
    /**
     * Creates Contact with Physician record type
     *
     * @param      idAccount     Id of related Account
     * @return     Contact       Returns an instance of Contact
     * @author     ARWE
    */
    public static Contact createPhysician(Id idAccount) {
        Contact con = createPhysician(false);
        con.AccountId = idAccount;
        return con;
    }

    /** 
     * Creates Contact with Physician record type
     * 
     * @param      bInsert      boolean to specify if the record is to be inserted
     * @return     Contact       Returns an instance of Contact
     * @author     FH 
     */
    public static Contact createPhysician(Boolean bInsert) {
        Contact con = new Contact();

        // Florian Heer <f.heer@conciscon.de> 2018-07-24
        // Prevents duplicate check from firing
        Blob b = Crypto.generateAesKey(128);
        String nameSuffix = EncodingUtil.convertToHex(b).left(8);

        con.FirstName = 'John';
        con.LastName = 'Doe' + nameSuffix;
        con.RecordTypeId = Utility.getRecordTypeId(Contact.SObjectType, Constants.RECORD_TYPE_NAME_CONTACT_US_PHYSICIAN);

        con.MailingStreet = 'Test';
        con.MailingCity = 'Los Angeles';
        con.MailingCountry = 'United States';
        con.MailingPostalCode = '11111';
        con.MailingCountryCode = 'US';
        con.MailingStateCode = 'CA';

        con.declined_to_provide_dob__c = true;
        con.declined_to_provide_phone__c = true;
        con.declined_to_provide_ssn__c = true;

        //con.sap_company_code__c = '0100';
        con.hmsc_registration__c = false;

        if (bInsert) {
            insert con;
        }
        return con;
    }

    /** 
     * Method checks if Order was submitted for review to CAS queue
     * and is not submitted to SAP
     * 
     * @param      orderId    Id or Order     * 
     * @author     FH 
     */
    public static void assertOnOrder(Id orderId) {
        Order objOrder = [
                SELECT submit_to_sap__c,
                        OwnerId
                FROM Order
                WHERE Id = :orderId
        ];
        System.assertEquals(false, objOrder.submit_to_sap__c);
    }

    /** 
     * TODO arwe
     * Returns a custom pricebook. Will either return an existing one or create (insert) one.
     * If the name is empty, it will give any active custom Pricebook.
     * 
     * @param      pricebookName    Name of Pricebook
     * @return     Pricebook2       Instance of Pricebook
     * @author     FH 
     */
    public static Pricebook2 findOrCreateCustomPricebook(String pricebookName) {
        Pricebook2 customPb;
        List<Pricebook2> pbs;
        if (pricebookName == null || pricebookName.length() == 0) {
            pbs = [SELECT Id FROM Pricebook2 WHERE IsStandard = FALSE AND IsActive = TRUE];
            pricebookName = 'Custom Test Pricebook';
        } else {
            pbs = [SELECT Id FROM Pricebook2 WHERE IsStandard = FALSE AND IsActive = TRUE AND Name = :pricebookName];
        }
        if (pbs.size() == 0) {
            customPb = new Pricebook2(Name = pricebookName, IsActive = true);
            insert customPb;
        } else {
            customPb = pbs[0];
        }
        return customPb;

    }

    /** 
     * TODO arwe
     * Returns a PricebookEntry. Will either return an existing one or create (insert) one.
     * This function only works on the standard pricebook
     * 
     * @param      productId    Id of Product
     * @param      price        Unit Price for Pricebook
     * @return     PricebookEntry   Instance of PricebookEntry
     * @author     FH 
     */
    public static PricebookEntry upsertPricebookEntry(Id productId, Decimal price) {
        Id standardPBId = Test.getStandardPricebookId();
        PricebookEntry retval;
        List<PricebookEntry> standardPrices = [
                SELECT Id, UnitPrice, Product2Id, Pricebook2Id
                FROM PricebookEntry
                WHERE Product2Id = :productId AND Pricebook2Id = :standardPBId
                AND IsActive = TRUE
        ];
        if (standardPrices.size() == 0) {
            retval = new PricebookEntry(UnitPrice = price, Product2Id = productId, Pricebook2Id = standardPBId,
                    UseStandardPrice = false, IsActive = true);
            insert retval;
        } else {
            retval = standardPrices[0];
            for (PricebookEntry pbe : standardPrices) {
                pbe.UnitPrice = price;
                update pbe;
            }
        }
        return retval;

    }

    /**
    * TODO arwe
    * Returns a PricebookEntry. Will either return an existing one or create (insert) one.
    * This function takes care of the standard price book as well as the supplied custom Pricebook.
    *
    * @param      productId    Id of Product
    * @param      price        Unit Price for Pricebook
    * @param      pricebook2Id    Id of Pricebook
    * @return     PricebookEntry   Instance of PricebookEntry
    * @author     FH
    */
    public static PricebookEntry upsertPricebookEntry(Id productId, Decimal price, Id pricebook2Id) {
        PricebookEntry retval;
        upsertPricebookEntry(productId, price);
        // custom price
        List<PricebookEntry> customPrices = [
                SELECT Id, UnitPrice, Product2Id, Pricebook2Id
                FROM PricebookEntry
                WHERE Product2Id = :productId AND Pricebook2Id = :pricebook2Id AND IsActive = TRUE
        ];
        if (customPrices.size() == 0) {
            retval = new PricebookEntry(UnitPrice = price, Product2Id = productId, Pricebook2Id = pricebook2Id,
                    UseStandardPrice = false, IsActive = true);
            insert retval;
        } else {
            retval = customPrices[0];
            for (PricebookEntry pbe : customPrices) {
                pbe.UnitPrice = price;
                update pbe;
            }
        }
        return retval;
    }
    /*
     * 	Select a dummy territory type created for test purpose
     *  because Territory2 object doesn't allow DML operation
     * 
     * @return	 lstterritoryType list of territory Type
     * @author   emma 
     */ 
    public static list<Territory2Type> getTerritoryType() {
        list<Territory2Type> lstterritoryType   = [SELECT id, DeveloperName from Territory2Type where  DeveloperName = 'Territory'];
        system.debug('lstterritoryType'+lstterritoryType);
        return lstterritoryType;
    }
    /*
     * 	Create a territory Model instance with a given Priority
     * 
     * @return	 territoryType
     * @author   emma 
     */ 
    public static Territory2Model createTerritoryModel(){
    	Territory2Model territoryModel;
        territoryModel = new Territory2Model(DeveloperName ='myTerritoryModel' ,
                                             Name ='myTerritoryModel');
        return territoryModel;
    }
    /*
     * Create a territory instance with a given territoryType and territoryModel
     * 
     * @param	 territoryType	Territory2Type
     * @param	 territoryModel	Territory2Model
     * @return	 territory
     * @author   emma 
     */ 
    public static Territory2 createTerritory(Id Territory2TypeId, Territory2Model territoryModel, String devName){
    	Territory2 territory;
        territory = new Territory2(name = 'myTerritory'+devName,
                                   DeveloperName = 'myTerritory'+devName,
                                   Territory2TypeId= Territory2TypeId,
                                   Territory2ModelId = territoryModel.Id);
        return territory;
    }

    /**
     * Creates a Product
     *
     * @param recordTypeDevName Developer Name ob Record Type
     *
     * @return a Product
     */
    public static Product2 createProduct(String recordTypeDevName) {
        Id rtId = Utility.getRecordTypeId(Product2.getSObjectType(), recordTypeDevName);
        Blob b = Crypto.generateAesKey(128);
        String name = 'testProduct_' + EncodingUtil.convertToHex(b).left(4);
        return new Product2(RecordTypeId = rtid, Name = name);
    }

    public static ProductConsumed createProductConsumed(Id productItemId, Id workOrderId, Decimal consumedQuantity) {
        return new ProductConsumed(WorkOrderId = workOrderId, ProductItemId = productItemId, QuantityConsumed = consumedQuantity);
    }
    public static ProductConsumed createProductConsumedWOLI(Id workOrderId, Id workOrderLineItemId, Id productItemId, Decimal consumedQuantity) {
        return new ProductConsumed (WorkOrderId = workOrderId, WorkOrderLineItemId = workOrderLineItemId, 
                                    ProductItemId = productItemId, QuantityConsumed = consumedQuantity);
    }

    public static WorkOrder createWorkOrder() {
        return new WorkOrder(no_rep_present_at_implant__c = true);
    }

    public static WorkOrderLineItem createWorkOrderLineItem  (Id workOrderId) {
        WorkOrderLineItem woli = new WorkOrderLineItem ( WorkOrderId = workOrderId);
        return woli;
    }
    
    public static ProductItem createProductItem (Id productId, Id locationID, String recordTypeDevName) {
        Id rtId = Utility.getRecordTypeId(ProductItem.SObjectType, recordTypeDevName);
        return new ProductItem(Product2Id = productId, LocationId = locationId, RecordTypeId = rtId);
    }

    public static ServiceResource createServiceResource (Id userId, Id locationId) {
        ServiceResource sr = new ServiceResource (RelatedRecordId = userId, LocationId = locationId,
                                                 isActive = true);
        return sr;
    }
 
    public static Schema.Location createLocation () {
        Blob b = Crypto.generateAesKey(128);
        String nameSuffix = EncodingUtil.convertToHex(b).left(4);

        Schema.Location loc = new Schema.Location(Name = 'TestLocation_' + nameSuffix);
	
        return loc;
    }
    
    public static OperatingHours createOperatingHours () {
        Blob b = Crypto.generateAesKey(128);
        String nameSuffix = EncodingUtil.convertToHex(b).left(4);
        OperatingHours oh = new OperatingHours (Name = 'OpHours_' + nameSuffix);
        return oh;
    }
    
    public static ServiceTerritory createServiceTerritory (Id operatingHoursId) {
        Blob b = Crypto.generateAesKey(128);
        String nameSuffix = EncodingUtil.convertToHex(b).left(4);

        // Name is not required on the object, but FSL.TR0023_ServiceTerritoryUtils.handleTerritoryNamesDuplicates fails otherwise with
        // a Nullpointer Exception.
        ServiceTerritory st = new ServiceTerritory (OperatingHoursId = operatingHoursId, Name = nameSuffix, isActive = true);
        return st;
    }
    
    public static ServiceTerritoryMember createServiceTerritoryMember (Id serviceResourceId, Id serviceTerritoryId) {
        Date startDate = Date.today();
        startDate.addYears(-2);
        ServiceTerritoryMember stm = new ServiceTerritoryMember (EffectiveStartDate = startDate, ServiceTerritoryId = serviceTerritoryId,
                                                                ServiceResourceId = serviceResourceId);
        return stm;
    }
    
    public static ServiceAppointment createServiceAppointment (Id parentId) {
        ServiceAppointment sa = new ServiceAppointment (ParentRecordId = parentId);
        return sa;
    }
    
    public class TestDataFactoryException extends Exception {
    }

}