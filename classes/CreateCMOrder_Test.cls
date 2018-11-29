@isTest
public class CreateCMOrder_Test {
    public static final String TEST_PRODUCT_PACEMAKER = 'My testing Pacemaker';
    public static final String TEST_PRODUCT_CARDIOMESSENGER = 'My testing CMessenger';
    public static final String PI_RT_CARDIO_MESSENGER = Constants.RECORD_TYPE_NAME_PRODUCT_ITEM;

    public static final String ASSET_RT_NAME = 'US_BIOAsset';
    public static final String SAP_ACCOUNT_ID_FOR_DISTRIBUTION_CENTER = '987654321';
    public static final String TEST_USER_LASTNAME = 'Salesyreppy';
	public static final String TEST_USER_PROFILE = 'Sales'; 
    public static final String TEST_USER_PERMISSION_SET2 = 'FSL_Agent_Permissions';
    public static final String TEST_CURRENCY = 'USD';
    public static final String INSIDE_SALES_PROFILE = Constants.PROFILE_NAME_SYSTEM_MMS_INSIDE_SALES;
    public static final String CS_ROLE = Constants.User_ROLE_NAME_CS;
    
    @testSetup
    public static void setupTestForCMOrder() {
        // We need
        // - A patient
        // - several Implanted Devices
        // - Order for the newest implanted device, as we need the account and doctor from there
        // - Implanting facility
        // - Physician
        
        List<Profile> profiles = [SELECT Id, Name FROM Profile WHERE Name = :TEST_USER_PROFILE];
        System.assertEquals(1, profiles.size(), 'Not exactly 1 user profile of the name ' + TEST_USER_PROFILE + '?');
        User salesRep = TestDataFactory.createUser(profiles[0].Id);
        salesRep.sap_company_code__c = '5500';
        salesRep.LastName = TEST_USER_LASTNAME;
        salesRep.CurrencyIsoCode = TEST_CURRENCY;
        salesRep.DefaultCurrencyIsoCode = TEST_CURRENCY;
        salesRep.is_service_resource__c = true;
        insert salesRep;

        Pricebook2 customPB = getCustomPricebook();

        Id accountRecordType = Utility.getRecordTypeId(Account.SObjectType, Constants.RECORD_TYPE_NAME_ACCOUNT_US);
        Account acc = new Account(RecordTypeId = accountRecordType
                                  , Name = 'Dummy Account'
                                  , status__c = 'Active'
                                  , crm_pricebook__c = customPB.Id
                                  , OwnerId = salesrep.Id
                                  , CurrencyIsoCode = TEST_CURRENCY
                                 );
        insert acc;
        System.debug('AAA acc: ' + acc);

        
        Id patientRTId = Utility.getRecordTypeId(Contact.SObjectType, Constants.RECORD_TYPE_NAME_CONTACT_US_PATIENT);
        Id physicianRTId = Utility.getRecordTypeId(Contact.SObjectType, Constants.RECORD_TYPE_NAME_CONTACT_US_PHYSICIAN);

        System.assertNotEquals(null, patientRTId, 'Cannot find contact record type for Patient');
        System.assertNotEquals(null, physicianRTId, 'Cannot find contact record type for Physician');
       
        Contact patient = new Contact(FirstName = 'Patient'
                                  , LastName = 'Patient'
                                  , RecordTypeId = patientRTId
                                  , BirthDate = Date.today().addDays(-1)
                                  , declined_to_provide_address__c = true
                                  , declined_to_provide_phone__c = true
                                  , declined_to_provide_ssn__c = true
                                  , status__c = 'Active'
                                  , OwnerId = salesrep.Id
                                 );
        insert patient;

        Contact physician = TestDataFactory.createPhysician(acc.Id);

        insert physician;

        
        Product2 pmProduct = produceProduct(TEST_PRODUCT_PACEMAKER, 50000, 'biotronik_product', false, Constants.PICKLIST_VALUE_PRODUCT_TYPE_PACEMAKER );
        produceProduct(TEST_PRODUCT_CARDIOMESSENGER, 0, PI_RT_CARDIO_MESSENGER, true, Constants.PICKLIST_VALUE_PRODUCT_TYPE_CARDIO_MESSENGER);

        Date implantDate = Date.today().addDays(-180);
        
        Id mdrfRecordType = Utility.getRecordTypeId('Order', Constants.RECORD_TYPE_NAME_ORDER_MDRF);
        System.assertNotEquals(null, mdrfRecordType);
        Order o = new Order(RecordTypeId = mdrfRecordType
                            , AccountId = acc.id
                            , EffectiveDate = implantDate
                            , implant_date__c = implantDate
                            , no_rep_present_at_implant__c = false
                            , rep_at_implant__c = salesrep.id
                            , Status = 'Not Submitted'
                            , Pricebook2Id = customPB.Id
                            , patient__c = patient.Id
                            , CurrencyIsoCode = TEST_CURRENCY
                           );
        insert o;
        
        List<PricebookEntry> pbes =  [SELECT Id FROM PricebookEntry WHERE Pricebook2Id = :customPB.Id AND Product2Id = :pmProduct.Id AND IsActive = True];
        System.assert(pbes.size() > 0, 'Cannot find a pricebookentry for my pacemaker.');
        
        OrderItem oi = new OrderItem( OrderId = o.id
                                     , Product2Id = pmProduct.Id
                                     , PricebookEntryId = pbes[0].Id
                                     , Quantity = 1
                                     , UnitPrice = 2000
                                    );
        insert oi;

        Id assetRTId;
        List<Schema.RecordTypeInfo> assetRTs = Schema.SObjectType.Asset.getRecordTypeInfos();
        for (Schema.RecordTypeInfo rti : assetRTs) {
            if(rti.getDeveloperName() == ASSET_RT_NAME) {
                assetRTId = rti.getRecordTypeId();
                break;
            }
        }

        
        // for pmProduct we now have to create Assets linked to the patient we created.
        Asset a = new Asset(ContactId = patient.Id
                            , AccountId = acc.Id
                            , Product2Id = pmProduct.Id
                            , Name = TEST_PRODUCT_PACEMAKER
                            , RecordTypeId = assetRTId
                            , patient__c = patient.id
                            , IsCompetitorProduct = false
                            , InstallDate = implantDate
                            , Price = 50000
                            , Quantity = 1
                            , Status = 'Implanted'
                            , product_type__c = 'Pacemaker'
                            , order_product__c = oi.Id
                            , implanting_physician__c = physician.Id
                            , UDI__c = '34324323444'
                            , manufacturer__c = 'Biotronik'
                            , serialNumber = '12345'
                            , sap_company_code__c = '5500'
                            , OwnerId = salesrep.Id
                           );
        insert a;
        // TODO: create more of these to test if only the correct one is found.

        
        // Ensure that the custom setting exists and the referenced Account for the Cardio Messenger Distribution Center
        Boolean foundSetting = false;
        String sapAccountId;
        Account orderAcc;
        List<cmo_settings__c> cmos = cmo_settings__c.getAll().values();
        for(cmo_settings__c cmo : cmos) {
            if(cmo.key__c == CreateCMOrder.CMO_SETTING_NAME_DEFAULT_ACCOUNT && cmo.sap_company_code__c == salesRep.sap_company_code__c) {
                foundSetting = true;
                sapAccountId = cmo.value__c;
                List<Account> accs = [SELECT Id, crm_pricebook__c FROM Account WHERE sap_no__c = :sapAccountId];
                if(accs.size() > 0) {
                    orderAcc = accs[0];
                }
                break;
            }
        }
        if(!foundSetting) {
            // Insert the custom setting... 
            sapAccountId = SAP_ACCOUNT_ID_FOR_DISTRIBUTION_CENTER;
            upsert new cmo_settings__c (
                Name = 'Test CMO Setting'
                , sap_company_code__c = salesRep.sap_company_code__c
                , key__c = CreateCMOrder.CMO_SETTING_NAME_DEFAULT_ACCOUNT
                , value__c = sapAccountId
            );
        }

        if(orderAcc == null) {
            Account distribution = new Account(Name = 'Cardio Messenger Distribution Center'
                                               , sap_no__c = sapAccountId
                                               , RecordTypeId = accountRecordType
                                               , status__c = 'Active'
                                               , OwnerId = salesrep.Id
                                               , crm_pricebook__c = customPB.Id
                                              );
            insert distribution;
        }

        
    }
    
    private static Pricebook2 getCustomPricebook() {
        List<Pricebook2> pbs = [SELECT Id, Name FROM Pricebook2 WHERE IsActive = true AND IsStandard = false];
        if(pbs.size() > 0) {
            return pbs[0];
        }
        
        Pricebook2 pb = new Pricebook2(Name = 'Custom Pricebook', CurrencyISOCode = TEST_CURRENCY, IsActive = true);
        insert pb;
        return pb;
    }

    private static Product2 produceProduct(String productName, Decimal price, String productItemRecordType, Boolean createProductItem, String productType) {
        Product2 prod;
        Pricebook2 customPB = getCustomPricebook();
        Id standardPBId;
        List<Pricebook2> pbs = [SELECT Id FROM Pricebook2 WHERE IsStandard = True];
        if(pbs.size() == 0) {
            standardPBId = Test.getStandardPricebookId();
        }
        else {
            standardPBId = pbs[0].Id;
        }

        List<Product2> prods = [SELECT Id, product_type__c FROM Product2 WHERE Name = :productName AND IsActive = true];
        if(prods.size() > 0) {
            prod = prods[0];
        }
        else {
            prod = new Product2(Name = productName, IsActive = true, product_type__c = productType, manufacturer__c = 'Biotronik');
            insert prod;
        }
        
        List<PricebookEntry> standardPrices = [SELECT Id, UnitPrice, Product2Id, Pricebook2Id FROM PricebookEntry 
                                               WHERE Product2Id = :prod.Id AND Pricebook2Id = :standardPBId
                                               AND CurrencyIsoCode = :TEST_CURRENCY
                                               AND IsActive = True];
        List<PricebookEntry> pbes2Insert = new List<PricebookEntry>();
        List<PricebookEntry> pbes2Update = new List<PricebookEntry>();
        
        if(standardPrices.size() == 0) {
                pbes2Insert.add(new PricebookEntry(UnitPrice = price, Product2Id = prod.id, Pricebook2Id = standardPBId, 
                                                  UseStandardPrice = false, IsActive=True, CurrencyIsoCode = TEST_CURRENCY));
        }
        else {
            for(PricebookEntry pbe : standardPrices) {
                pbe.UnitPrice = price;
                pbes2Update.add(pbe);
            }
        }

        // custom price
        List<PricebookEntry> customPrices = [SELECT Id, UnitPrice, Product2Id, Pricebook2Id FROM PricebookEntry 
                                             WHERE Product2Id = :prod.Id AND Pricebook2Id = :customPB.Id AND IsActive=True
                                             AND CurrencyIsoCode = :TEST_CURRENCY];
        if(customPrices.size() == 0) {
                pbes2Insert.add(new PricebookEntry(UnitPrice = price, Product2Id = prod.id, Pricebook2Id = customPB.Id, 
                                                  UseStandardPrice = false, IsActive = True, CurrencyIsoCode = TEST_CURRENCY));
        }
        else {
            for(PricebookEntry pbe : customPrices) {
                pbe.UnitPrice = price;
                pbes2Update.add(pbe);
            }
        }
        
        if(pbes2Update.size() > 0) update pbes2Update;
        if(pbes2Insert.size() > 0) insert pbes2Insert;
        
        // ProductItems
        
        //  - Locations
        Schema.Location loc;
        List<Schema.Location> locs = [SELECT Id FROM Location LIMIT 20];
        if(locs.size() == 0) {
            loc = new Schema.Location(Name = 'FH Dummy Location', IsInventoryLocation = true, IsMobile = true);
            insert loc;
        }
        else {
            loc = locs[0];
        }
        
        if(createProductItem) {
            List<ProductItem> pis2Update = new List<ProductItem>();
            List<ProductItem> pis2Insert = new List<ProductItem>();
            List<RecordType> piRT = [SELECT Id FROM RecordType WHERE SObjectType = 'ProductItem' AND DeveloperName = :productItemRecordType];
            System.assertNotEquals(0, piRT.size(), 'RecordType "' + productItemRecordType + '" cannot be found for ProductItem');
            
            List<ProductItem> pis = [SELECT Id, QuantityOnHand FROM ProductItem WHERE Product2Id = :prod.id];
            if(pis.size() > 0) {
                for(ProductItem pi : pis) {
                    if(pi.QuantityOnHand < 1) {
                        pi.QuantityOnHand = 1;
                        pis2Update.add(pi);
                    }
                }
            }
            else {
                ProductItem pi = new ProductItem (QuantityOnHand = 1, Product2Id = prod.id, LocationId = loc.Id, expiration_date_ubd__c = Date.today().addDays(-1),
                                                 RecordTypeId = piRT[0].Id, SerialNumber = '123456789', product_type__c = prod.product_type__c);
                pis2Insert.add(pi);
            }
            
            if(pis2Insert.size() > 0) insert pis2Insert;
            if(pis2Update.size() > 0) update pis2Update;
        }
        
        return prod;
    }

    @isTest
    public static void testGeneralSetup() {
        List<String> permissionSetNames = new List<String> {
        	// TEST_USER_PERMISSION_SET1
            TEST_USER_PERMISSION_SET2
        };
        
        List<User> salesreps = [SELECT Id, CurrencyIsoCode FROM User WHERE LastName=:TEST_USER_LASTNAME];
        System.assertEquals(1, salesreps.size());
        System.assertEquals(TEST_CURRENCY, salesreps[0].CurrencyIsoCode, 'User should have been created with the Currrency ' + TEST_CURRENCY);

        List<PermissionSet> psets = [SELECT Id FROM PermissionSet WHERE Name IN :permissionSetNames];
        System.assertEquals(permissionSetNames.size(), psets.size(), 'We expected an exact number of Permission Sets ' + permissionSetNames);
        
        List<PermissionSetAssignment> psas = new List<PermissionSetAssignment>();
        for(PermissionSet ps : psets) {
        	psas.add(new PermissionSetAssignment (PermissionSetId = ps.id, AssigneeId = salesreps[0].Id));
        }
        insert psas;
        System.assert(Schema.sObjectType.ProductConsumed.isCreateable(), 'ProductConsumed cannot be created by the current user.');
        System.runAs(salesreps[0]) {
            System.assertEquals(salesreps[0].Id, UserInfo.getUserId());
            System.assertEquals(TEST_CURRENCY, UserInfo.getDefaultCurrency());
            System.assert(Schema.sObjectType.ProductConsumed.isCreateable(), 'ProductConsumed cannot be created by the test user.');
        }

    }

    
    @isTest
    public static void testDirectHandout() {
        List<Contact> cons = [SELECT Id FROM Contact WHERE LastName='Patient' AND Firstname='Patient'];
        System.assertEquals(1, cons.size(), 'Cannot find my test contact again.');
        
        List<String> permissionSetNames = new List<String> {
        	// TEST_USER_PERMISSION_SET1
            TEST_USER_PERMISSION_SET2
        };
        
        List<User> salesreps = [SELECT Id FROM User WHERE LastName=:TEST_USER_LASTNAME];
        System.assertEquals(1, salesreps.size());

        List<PermissionSet> psets = [SELECT Id FROM PermissionSet WHERE Name IN :permissionSetNames];
        System.assertEquals(permissionSetNames.size(), psets.size(), 'We expected an exact number of Permission Sets ' + permissionSetNames);
        
        List<PermissionSetAssignment> psas = new List<PermissionSetAssignment>();
        for(PermissionSet ps : psets) {
        	psas.add(new PermissionSetAssignment (PermissionSetId = ps.id, AssigneeId = salesreps[0].Id));
        }
        insert psas;

        List<Asset> assets = [SELECT Id, AccountId, order_product__r.Order.Id,
                              product_type__c, patient__c, Status, order_product__c
                              FROM Asset];
        for(Asset a : assets) {
            System.debug(a);
        }
        
        List<RecordType> piRT = [SELECT Id FROM RecordType WHERE SObjectType = 'ProductItem' AND DeveloperName = :PI_RT_CARDIO_MESSENGER];
        System.debug('AAA piRT: ' + piRT);

        List<ProductItem> cmPIs = [SELECT Id FROM ProductItem WHERE RecordTypeId = :piRT[0].Id];
        System.debug('AAA cmPIs: ' + cmPIs);
        List<ProductItem> allPIs = [SELECT Id, RecordTypeId, Product2.Name FROM ProductItem];
        System.debug('AAA allPIs: ' + allPIs);

        psas = [SELECT p.Id, p.Assignee.Name, p.Assignee.Profile.Name, p.PermissionSet.Label, p.AssigneeId, p.PermissionSetId
											  FROM PermissionSetAssignment p
											  WHERE p.Assignee.Profile.Name = 'Sales'
                                              ORDER BY p.AssigneeId, p.PermissionSetId];
		System.debug('BBB');
        System.debug(psas);
        
        System.runAs(salesreps[0]) {
            
            ApexPages.StandardController sc = new ApexPages.standardController(cons[0]);
            CreateCMOrder ccmo = new CreateCMOrder(sc);
            ccmo.OrderType = CreateCMOrder.CM_ORDER_DIRECT_HANDOUT;
            ccmo.selectedCMProduct = cmPIs[0].Id;
            Test.startTest();
            ccmo.selectedAddress = 'Mailing Address';
            ccmo.prepareOrder();
            Order cOrder = ccmo.reallyCreateOrder();
            System.assertNotEquals(null, cOrder.sap_company_code__c);
            Test.stopTest();
        }
                    
        
    }

    @isTest
    public static void testDirectShip() {
        List<Contact> cons = [SELECT Id FROM Contact WHERE LastName='Patient' AND Firstname='Patient'];
        System.assertEquals(1, cons.size(), 'Cannot find my test patient again.');
        
        List<String> permissionSetNames = new List<String> {
        	// TEST_USER_PERMISSION_SET1
            TEST_USER_PERMISSION_SET2
        };
         Id  userRoleIds  = [SELECT Id FROM UserRole WHERE DeveloperName = :CS_ROLE LIMIT 1].Id;
         Id  profilesId = [SELECT Id, Name FROM Profile WHERE Name = :INSIDE_SALES_PROFILE].Id;

        List<User> salesreps = [SELECT Id, UserRoleId FROM User WHERE LastName=:TEST_USER_LASTNAME];
        System.assertEquals(1, salesreps.size());
        // Only user with CAS or CS profile can change the status of the order
        // I added the role to the user
        For (User us:salesreps){
            us.UserRoleId = userRoleIds;
            us.ProfileId = profilesId;
        }
        update salesreps;
		System.debug('****User with role cas '+ salesreps);

        List<PermissionSet> psets = [SELECT Id FROM PermissionSet WHERE Name IN :permissionSetNames];
        System.debug('here is permissionset '+ psets);
        System.assertEquals(permissionSetNames.size(), psets.size(), 'We expected an exact number of Permission Sets ' + permissionSetNames);
        
        List<PermissionSetAssignment> psas = new List<PermissionSetAssignment>();
        for(PermissionSet ps : psets) {
        	psas.add(new PermissionSetAssignment (PermissionSetId = ps.id, AssigneeId = salesreps[0].Id));
        }
        insert psas;
        System.debug('here is psas '+ psas);
        List<Asset> assets = [SELECT Id, AccountId, order_product__r.Order.Id,
                              product_type__c, patient__c, Status, order_product__c
                              FROM Asset];
        for(Asset a : assets) {
            System.debug(a);
        }
        
        List<Product2> ourProducts = [SELECT Id, product_type__c, sap_model_no__c, Name
                                      FROM Product2 WHERE Name = :TEST_PRODUCT_CARDIOMESSENGER];
        System.debug('AAA ourProducts[0]: ' + ourProducts[0]);
        Pricebook2 customPB = getCustomPricebook();
        List<PricebookEntry> pbes = [SELECT Id, CurrencyIsoCode FROM PricebookEntry WHERE Pricebook2Id = :customPB.Id AND Product2Id = :ourProducts[0].Id];
        System.debug('AAA pricebookentries: ' + pbes);
        
        System.runAs(salesreps[0]) {
            ApexPages.StandardController sc = new ApexPages.standardController(cons[0]);
            CreateCMOrder ccmo = new CreateCMOrder(sc);
            ccmo.OrderType = CreateCMOrder.CM_ORDER_DIRECT_SHIP;
            ccmo.ourProduct = ourProducts[0];
            Test.startTest();
            Order cOrder = ccmo.reallyCreateOrder();
            System.assertNotEquals(null, cOrder.sap_company_code__c);
            Test.stopTest();
        }
        
    }
    
    @isTest
    public static void testRemainingFunctions() {
        List<Contact> cons = [SELECT Id FROM Contact WHERE LastName='Patient' AND Firstname='Patient'];
        System.assertEquals(1, cons.size(), 'Cannot find my test patient again.');
        
        List<String> permissionSetNames = new List<String> {
        	// TEST_USER_PERMISSION_SET1
            TEST_USER_PERMISSION_SET2
        };
        
        List<User> salesreps = [SELECT Id FROM User WHERE LastName=:TEST_USER_LASTNAME];
        System.assertEquals(1, salesreps.size());

        List<PermissionSet> psets = [SELECT Id FROM PermissionSet WHERE Name IN :permissionSetNames];
        System.assertEquals(permissionSetNames.size(), psets.size(), 'We expected an exact number of Permission Sets ' + permissionSetNames);
        
        List<PermissionSetAssignment> psas = new List<PermissionSetAssignment>();
        for(PermissionSet ps : psets) {
        	psas.add(new PermissionSetAssignment (PermissionSetId = ps.id, AssigneeId = salesreps[0].Id));
        }
        insert psas;
        
        List<Asset> assets = [SELECT Id, AccountId, order_product__r.Order.Id,
                              product_type__c, patient__c, Status, order_product__c
                              FROM Asset];
        for(Asset a : assets) {
            System.debug(a);
        }
        
        List<Product2> ourProducts = [SELECT Id, product_type__c, sap_model_no__c, Name
                                      FROM Product2 WHERE Name = :TEST_PRODUCT_CARDIOMESSENGER];
        System.debug('AAA ourProducts[0]: ' + ourProducts[0]);
        Pricebook2 customPB = getCustomPricebook();
        List<PricebookEntry> pbes = [SELECT Id, CurrencyIsoCode FROM PricebookEntry WHERE Pricebook2Id = :customPB.Id AND Product2Id = :ourProducts[0].Id];
        System.debug('AAA pricebookentries: ' + pbes);
        
        System.runAs(salesreps[0]) {
            ApexPages.StandardController sc = new ApexPages.standardController(cons[0]);
            CreateCMOrder ccmo = new CreateCMOrder(sc);
            ccmo.OrderType = CreateCMOrder.CM_ORDER_DIRECT_SHIP;
            ccmo.ourProduct = ourProducts[0];
            Test.startTest();
            ccmo.barcode = '123456789';
            ccmo.searchProductItems();
            System.assert(ccmo.getAvailableCMProducts().size() > 0);
            ccmo.goBack();
            ccmo.barcode = null;
            ccmo.inventoryName = 'My testing CMessenger';
            try {
            	ccmo.searchProductItems();
                System.assert(false, 'Should not reach this. The Test user is not setup as a Service Resource');
            }
            catch(CreateCMOrder.CreateCMOrderException e) {
                
            }
            System.assertEquals(1, ccmo.avlCMProducts.size());
            Test.stopTest();
        }
        
    }
    
    //Added by Sumit
    @isTest
    public static void getAddressPicklistTest() {
        List<Contact> cons = [SELECT Id, MailingStreet, OtherStreet FROM Contact WHERE LastName='Patient' AND Firstname='Patient'];
        List<User> salesreps = [SELECT Id FROM User WHERE LastName=:TEST_USER_LASTNAME];
        System.assertEquals(1, salesreps.size());

        System.runAs(salesreps[0]) {
        ApexPages.StandardController sc = new ApexPages.standardController(cons[0]);
        CreateCMOrder ccmo = new CreateCMOrder(sc);
        Test.startTest();
        	ccmo.getAddressPicklist();   
        	System.assertEquals(4, ccmo.getAddressPicklist().size());
        Test.stopTest();
        }
    } 
    
    //Added by Sumit
/*    @isTest
    public static void updatePatientAddressTest() {
        List<Contact> cons = [SELECT Id, MailingStreet, OtherStreet FROM Contact WHERE LastName='Patient' AND Firstname='Patient'];
        
        Contact conFromVf = TestDataFactory.createPatient(false);
        
        List<User> salesreps = [SELECT Id FROM User WHERE LastName=:TEST_USER_LASTNAME];
        System.assertEquals(1, salesreps.size());

        System.runAs(salesreps[0]) {

            ApexPages.StandardController sc = new ApexPages.standardController(cons[0]);
            CreateCMOrder ccmo = new CreateCMOrder(sc);
            
            Contact con = TestDataFactory.createPatient(true);
            Contact patient = [Select id, MailingStreet, MailingCity, MailingCountryCode, MailingStateCode, MailingPostalCode, declined_to_provide_address__c, OtherStreet FROM Contact where id =: con.id];
            patient.MailingStreet = 'Initial Street';
            patient.MailingCity = 'Initial City';
            patient.MailingCountryCode = 'US';
            patient.MailingStateCode = 'OR';
            patient.MailingPostalCode = '97035';
            patient.declined_to_provide_address__c = false;
            ccmo.tempContact = conFromVf.clone();
            

            Integer counter = 0;
            
            conFromVf.MailingStreet = 'Street-' + counter;
            conFromVf.MailingCity = 'City-' + counter;
            conFromVf.MailingCountryCode = 'US';
            conFromVf.MailingStateCode = 'OR';
            conFromVf.MailingPostalCode = '97035';
            conFromVf.declined_to_provide_address__c = false;
            
            Test.startTest();
            
            ccmo.selectedAddressToUpdate = 'Shipping_Address';
            ccmo.updatePatientAddress(patient, conFromVf);   
            System.assertEquals('Street-' + counter, patient.OtherStreet);
            System.assertEquals('City-' + counter, patient.OtherCity);

            patient = [Select id, MailingStreet, MailingCity, MailingCountryCode, MailingStateCode, MailingPostalCode, declined_to_provide_address__c, 
                       OtherStreet, OtherCity, shipping_street__c, shipping_city__c FROM Contact where id =: patient.id];
            
            counter++;
            conFromVf.MailingStreet = 'Street-' + counter;
            conFromVf.MailingCity = 'City-' + counter;
            conFromVf.MailingCountryCode = 'US';
            conFromVf.MailingStateCode = 'OR';
            conFromVf.MailingPostalCode = '97035';
            patient.MailingCountryCode = 'US';
            patient.MailingStateCode = 'OR';
            patient.MailingPostalCode = '97035';
            
            ccmo.selectedAddressToUpdate = 'Mailing_Address';
            ccmo.updatePatientAddress(patient, conFromVf);   
            System.assertEquals('Street-' + counter, patient.MailingStreet);
            System.assertEquals('City-' + counter, patient.MailingCity);

            patient = [Select id, MailingStreet, MailingCity, MailingCountryCode, MailingStateCode, MailingPostalCode, declined_to_provide_address__c, 
                       OtherStreet, OtherCity, shipping_street__c, shipping_city__c FROM Contact where id =: patient.id];

            counter++;
            conFromVf.MailingStreet = 'Street-' + counter;
            conFromVf.MailingCity = 'City-' + counter;
            conFromVf.MailingCountryCode = 'US';
            conFromVf.MailingStateCode = 'OR';
            conFromVf.MailingPostalCode = '97035';
            patient.MailingCountryCode = 'US';
            patient.MailingStateCode = 'OR';
            patient.MailingPostalCode = '97035';
            
            ccmo.selectedAddressToUpdate = 'Other_Address';
            ccmo.updatePatientAddress(patient, conFromVf);   
            System.assertEquals('Street-' + counter, patient.shipping_street__c);
            System.assertEquals('City-' + counter, patient.shipping_city__c);
            
            Test.stopTest();
        }
    }
*/
}