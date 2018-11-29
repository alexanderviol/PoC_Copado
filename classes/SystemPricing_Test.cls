@isTest
public class SystemPricing_Test {

    public static final Boolean DO_PRINTLINE_DEBUGGING = false;
    
    public static final String ORDER_NAME = 'MyTestOrder';
    public static final Integer NUMBER_OF_RULES_IN_TEST = 5;
    public static final String RT_CONTACT_PATIENT   = 'us_patient';
    public static final String RT_CONTACT_PHYSICIAN = 'us_physician';

    public static final String ASS_MANUFACTURER = 'BIOTRONIK';

    static String namePrefix = '';
    
    @testSetup
    public static void setupSystemPricingEnvironment () {
        // We need
        // - An Account
        // - An Order
        // - -Assets
        // - + OrderItem
        // - Products
        // - System Rules
        
        System.debug('Syspri: Generate UUID');
        
        Blob b = Crypto.GenerateAESKey(128);
        namePrefix = EncodingUtil.ConvertTohex(b).left(8);
        
        Id stdPbId = Test.getStandardPricebookId();
        if(DO_PRINTLINE_DEBUGGING) { System.debug('Syspri: StandardPriceBookId = ' + stdPbId); }
        Pricebook2 pb = new Pricebook2(Name = namePrefix + ' Testing Pricebook', CurrencyIsoCode = 'USD');
        insert pb; 
        if(DO_PRINTLINE_DEBUGGING) { System.debug('Syspri: PriceBookId = ' + pb.Id); }

        System.debug('Syspri: Generate Account');
        Account acc = new Account (Name = namePrefix + 'Account', status__c = 'Active', crm_pricebook__c = pb.Id);
        insert acc;
        Id AccountId = acc.Id;

        
        Id rtIdPatient = Utility.getRecordTypeId(Contact.SObjectType, Constants.RECORD_TYPE_NAME_CONTACT_US_PATIENT);

        
        Contact c = new Contact (FirstName = 'Capital_letter', LastName = 'ConName',
                                     declined_to_provide_address__c = True, declined_to_provide_dob__c = True, 
                                     //declined_to_provide_fname__c  = True, SAFBIO 1365
                                     declined_to_provide_phone__c = True, 
                                     declined_to_provide_ssn__c  = True,
                                    RecordTypeId = rtIdPatient,
                                    MailingCountry = null, status__c = 'Active');
        
        insert c;
        
        System.debug('Syspri: Generate Order');
        Order o = new Order (Name = ORDER_NAME, AccountId = acc.Id, EffectiveDate = Date.today().addDays(-5),
                             Status = 'Draft', Pricebook2Id = pb.Id
                             , no_rep_present_at_implant__c = true, patient__c = c.id
                            );
        insert o;
        System.debug('Syspri: Generate products');
        // -------------- products ------------------
        List<Product2> products = new List<Product2>();
        Product2 prodPM = new Product2 (Name = namePrefix + 'TestProduct_PM', product_type__c = 'Pacemaker', IsActive = true, manufacturer__c = ASS_MANUFACTURER);
        products.add(prodPM);
        
        Product2 prodLead1 = new Product2 (Name = namePrefix + 'TestProduct_Lead1', product_type__c = 'Lead', IsActive = true, manufacturer__c = ASS_MANUFACTURER);
        products.add(prodLead1);
        
        Product2 prodLead2 = new Product2 (Name = namePrefix + 'TestProduct_Lead2', product_type__c = 'Lead', IsActive = true, manufacturer__c = ASS_MANUFACTURER);
        products.add(prodLead2);

        Product2 prodLead3 = new Product2 (Name = namePrefix + 'TestProduct_Lead3', product_type__c = 'Lead', IsActive = true, manufacturer__c = ASS_MANUFACTURER);
        products.add(prodLead3);
        
        Product2 prodSystem1 = new Product2 (Name = namePrefix + 'TestSystemProduct_1', product_type__c = 'System', IsActive = true, manufacturer__c = ASS_MANUFACTURER);
        products.add(prodSystem1);
        
        Product2 prodSystem2 = new Product2 (Name = namePrefix + 'TestSystemProduct_2', product_type__c = 'System', IsActive = true, manufacturer__c = ASS_MANUFACTURER);
        products.add(prodSystem2);
        
        Product2 prodSystem3 = new Product2 (Name = namePrefix + 'TestSystemProduct_3', product_type__c = 'System', IsActive = true, manufacturer__c = ASS_MANUFACTURER);
        products.add(prodSystem3);
        
        Product2 prodSystem4 = new Product2 (Name = namePrefix + 'TestSystemProduct_4', product_type__c = 'System', IsActive = true, manufacturer__c = ASS_MANUFACTURER);
        products.add(prodSystem4);
        
        System.debug('Syspri: Insert products');
        insert products;

        System.assert(prodPM.Id != null, 'Pacemaker Product has no ID');
        
        List<PricebookEntry> pbes = new List<PricebookEntry>();
        
        if(DO_PRINTLINE_DEBUGGING) { 
            System.debug('Syspri: PricebookEntry - system1 = ' + prodSystem1.Id);
            System.debug('Syspri: PricebookEntry - system2 = ' + prodSystem2.Id);
            System.debug('Syspri: PricebookEntry - system3 = ' + prodSystem3.Id);
            System.debug('Syspri: PricebookEntry - system4 = ' + prodSystem4.Id);
        }
        
        System.debug('Syspri: Creating PricebookEntries');
        // StandardPricebooks
        pbes.add(new PricebookEntry(IsActive = true, Product2Id = prodSystem1.Id, Pricebook2Id = stdPbId, UnitPrice = 10000, CurrencyIsoCode = 'USD'));
        pbes.add(new PricebookEntry(IsActive = true, Product2Id = prodSystem2.Id, Pricebook2Id = stdPbId, UnitPrice = 12000, CurrencyIsoCode = 'USD'));
        pbes.add(new PricebookEntry(IsActive = true, Product2Id = prodSystem3.Id, Pricebook2Id = stdPbId, UnitPrice = 14000, CurrencyIsoCode = 'USD'));
        pbes.add(new PricebookEntry(IsActive = true, Product2Id = prodSystem4.Id, Pricebook2Id = stdPbId, UnitPrice = 16000, CurrencyIsoCode = 'USD'));
        pbes.add(new PricebookEntry(IsActive = true, Product2Id = prodPM.Id, Pricebook2Id = stdPbId, UnitPrice = 10000, CurrencyIsoCode = 'USD'));
        pbes.add(new PricebookEntry(IsActive = true, Product2Id = prodLead1.Id, Pricebook2Id = stdPbId, UnitPrice = 10000, CurrencyIsoCode = 'USD'));
        pbes.add(new PricebookEntry(IsActive = true, Product2Id = prodLead2.Id, Pricebook2Id = stdPbId, UnitPrice = 5000, CurrencyIsoCode = 'USD'));
        pbes.add(new PricebookEntry(IsActive = true, Product2Id = prodLead3.Id, Pricebook2Id = stdPbId, UnitPrice = 6000, CurrencyIsoCode = 'USD'));
        
        // Custom Pricebooks
        pbes.add(new PricebookEntry(IsActive = true, Product2Id = prodSystem1.Id, Pricebook2Id = pb.Id, UnitPrice = 10000, CurrencyIsoCode = 'USD'));
        pbes.add(new PricebookEntry(IsActive = true, Product2Id = prodSystem2.Id, Pricebook2Id = pb.Id, UnitPrice = 12000, CurrencyIsoCode = 'USD'));
        pbes.add(new PricebookEntry(IsActive = true, Product2Id = prodSystem3.Id, Pricebook2Id = pb.Id, UnitPrice = 14000, CurrencyIsoCode = 'USD'));
        pbes.add(new PricebookEntry(IsActive = true, Product2Id = prodSystem4.Id, Pricebook2Id = pb.Id, UnitPrice = 16000, CurrencyIsoCode = 'USD'));
        pbes.add(new PricebookEntry(IsActive = true, Product2Id = prodPM.Id, Pricebook2Id = pb.Id, UnitPrice = 40000, CurrencyIsoCode = 'USD'));
        pbes.add(new PricebookEntry(IsActive = true, Product2Id = prodLead1.Id, Pricebook2Id = pb.Id, UnitPrice = 100, CurrencyIsoCode = 'USD'));
        pbes.add(new PricebookEntry(IsActive = true, Product2Id = prodLead2.Id, Pricebook2Id = pb.Id, UnitPrice = 5000, CurrencyIsoCode = 'USD'));
        pbes.add(new PricebookEntry(IsActive = true, Product2Id = prodLead3.Id, Pricebook2Id = pb.Id, UnitPrice = 6000, CurrencyIsoCode = 'USD'));
        
        System.debug('Syspri: inserting Pricebook2Entry');
        insert pbes;

        List<PricebookEntry> ourPbEs = [SELECT Id, Product2Id, UnitPrice FROM PricebookEntry WHERE Pricebook2Id = :pb.Id];
        Map<Id, PricebookEntry> pbMap = new Map<Id, PricebookEntry> ();
        for(PricebookEntry pbE : ourPbEs) {
            pbMap.put(pbE.Product2Id, pbE);
        }
        
        System.debug('Syspri: Generate OrderItems ');
        // -------------- assets ------------------
        List<OrderItem> orderItems = new List<OrderItem>();
        
        PricebookEntry currEntry = pbMap.get(prodPM.Id);
        // TODO: Create associated Assets!
        orderItems.add(new OrderItem (OrderId = o.id, Product2Id = prodPM.Id, Quantity = 1, PricebookEntryId = currEntry.Id, UnitPrice = currEntry.UnitPrice));
        currEntry = pbMap.get(prodLead1.Id);
        orderItems.add(new OrderItem (OrderId = o.id, Product2Id = prodLead1.Id, Quantity = 1, PricebookEntryId = currEntry.Id, UnitPrice = currEntry.UnitPrice));
        orderItems.add(new OrderItem (OrderId = o.id, Product2Id = prodLead1.Id, Quantity = 1, PricebookEntryId = currEntry.Id, UnitPrice = currEntry.UnitPrice));
        orderItems.add(new OrderItem (OrderId = o.id, Product2Id = prodLead1.Id, Quantity = 1, PricebookEntryId = currEntry.Id, UnitPrice = currEntry.UnitPrice));
        orderItems.add(new OrderItem (OrderId = o.id, Product2Id = prodLead1.Id, Quantity = 1, PricebookEntryId = currEntry.Id, UnitPrice = currEntry.UnitPrice));
        currEntry = pbMap.get(prodLead2.Id);
        orderItems.add(new OrderItem (OrderId = o.id, Product2Id = prodLead2.Id, Quantity = 1, PricebookEntryId = currEntry.Id, UnitPrice = currEntry.UnitPrice));
        orderItems.add(new OrderItem (OrderId = o.id, Product2Id = prodLead2.Id, Quantity = 1, PricebookEntryId = currEntry.Id, UnitPrice = currEntry.UnitPrice));
        orderItems.add(new OrderItem (OrderId = o.id, Product2Id = prodLead3.Id, Quantity = 1, PricebookEntryId = currEntry.Id, UnitPrice = currEntry.UnitPrice));
        System.debug('Syspri: Insert OrderItems (');
        insert orderItems;
        
        List<Asset> assets = new List<Asset>();
        Integer assIdx = 0;
        assets.add(new Asset(order_product__c = orderItems.get(assIdx++).Id, Product2Id = prodPM.Id, product_type__c = prodPM.product_type__c,
                            manufacturer__c = ASS_MANUFACTURER, SerialNumber = '123456',
                                           Name = prodPM.Name, AccountId = o.AccountId, Status = 'Implanted'));
        assets.add(new Asset(order_product__c = orderItems.get(assIdx++).Id, Product2Id = prodLead1.Id, product_type__c = prodLead1.product_type__c,
                            manufacturer__c = ASS_MANUFACTURER, SerialNumber = '123456',
                                           Name = prodLead1.Name, AccountId = o.AccountId, Status = 'Implanted'));
        assets.add(new Asset(order_product__c = orderItems.get(assIdx++).Id, Product2Id = prodLead1.Id, product_type__c = prodLead1.product_type__c,
                            manufacturer__c = ASS_MANUFACTURER, SerialNumber = '123456',
                                           Name = prodLead1.Name, AccountId = o.AccountId, Status = 'Implanted'));
        assets.add(new Asset(order_product__c = orderItems.get(assIdx++).Id, Product2Id = prodLead1.Id, product_type__c = prodLead1.product_type__c,
                            manufacturer__c = ASS_MANUFACTURER, SerialNumber = '123456',
                                           Name = prodLead1.Name, AccountId = o.AccountId, Status = 'Implanted'));
        assets.add(new Asset(order_product__c = orderItems.get(assIdx++).Id, Product2Id = prodLead1.Id, product_type__c = prodLead1.product_type__c,
                            manufacturer__c = ASS_MANUFACTURER, SerialNumber = '123456',
                                           Name = prodLead1.Name, AccountId = o.AccountId, Status = 'Implanted'));
        assets.add(new Asset(order_product__c = orderItems.get(assIdx++).Id, Product2Id = prodLead2.Id, product_type__c = prodLead2.product_type__c,
                            manufacturer__c = ASS_MANUFACTURER, SerialNumber = '123456',
                                           Name = prodLead2.Name, AccountId = o.AccountId, Status = 'Implanted'));
        assets.add(new Asset(order_product__c = orderItems.get(assIdx++).Id, Product2Id = prodLead2.Id, product_type__c = prodLead2.product_type__c,
                            manufacturer__c = ASS_MANUFACTURER, SerialNumber = '123456',
                                           Name = prodLead2.Name, AccountId = o.AccountId, Status = 'Implanted'));
        assets.add(new Asset(order_product__c = orderItems.get(assIdx++).Id, Product2Id = prodLead3.Id, product_type__c = prodLead3.product_type__c,
                            manufacturer__c = ASS_MANUFACTURER, SerialNumber = '123456',
                                           Name = prodLead2.Name, AccountId = o.AccountId, Status = 'Discarded',
                            event_reason__c = 'Upgrade')); // OOS_Reason__c necessary because of Flow restrictions introduced later in the game.
        insert assets;
        
        // -------------- system rules ------------------
        
        
        // Allow 2 of "Name contains Lead1"
        system_rule__c sr_1 = new system_rule__c(system_product__c = prodSystem1.Id, product__c = prodPM.Id, max_quantity__c = 5,
                                                 rule_field__c = 'Name', rule_value__c = 'Lead1',
                                                 name__c = namePrefix + '_sr_1');
        insert sr_1;
        
        // Allow 3 of either "Name contains Lead1" or "Name contains Lead2"
        system_rule__c sr_2 = new system_rule__c(system_product__c = prodSystem2.Id, product__c = prodPM.Id, max_quantity__c = 3,
                                                 name__c = namePrefix + '_sr_2');
        insert sr_2;
        system_rule__c sr_2_1 = new system_rule__c(parent_rule__c = sr_2.Id, rule_field__c = 'Name', rule_value__c = 'Lead1');
        insert sr_2_1;
        system_rule__c sr_2_2 = new system_rule__c(parent_rule__c = sr_2.Id, rule_field__c = 'Name', rule_value__c = 'Lead2');
        insert sr_2_2;
        
        // Allow 2 of either "Name contains Lead1" or "Name contains Lead2"
        system_rule__c sr_3 = new system_rule__c(system_product__c = prodSystem3.Id, product__c = prodPM.Id, max_quantity__c = 2,
                                                 name__c = namePrefix + '_sr_3');
        insert sr_3;
        system_rule__c sr_3_1 = new system_rule__c(parent_rule__c = sr_3.Id, rule_field__c = 'Name', rule_value__c = 'Lead1');
        insert sr_3_1;
        system_rule__c sr_3_2 = new system_rule__c(parent_rule__c = sr_3.Id, rule_field__c = 'Name', rule_value__c = 'Lead2');
        insert sr_3_2;
        
        // Allow any number of "Name contains Lead3"
        system_rule__c sr_4 = new system_rule__c(system_product__c = prodSystem4.Id, product__c = prodPM.Id, max_quantity__c = 2,
                                                 rule_field__c = 'Name', rule_value__c = 'Lead3',
                                                 name__c = namePrefix + '_sr_4');
        insert sr_4;
        
        // Complicated rule for deep excess test
        system_rule__c sr_5 = new system_rule__c(system_product__c = prodSystem3.Id, product__c = prodPM.Id, max_quantity__c = 1,
                                                 name__c = namePrefix + '_sr_5');
        insert sr_5;
        
        system_rule__c sr_5_1 = new system_rule__c(parent_rule__c = sr_5.Id, rule_field__c = 'Name', rule_value__c = 'Lead');
        insert sr_5_1;
        
        system_rule__c sr_5_1_1 = new system_rule__c(parent_rule__c = sr_5_1.Id);
        insert sr_5_1_1;
        
        system_rule__c sr_5_1_1_1 = new system_rule__c(parent_rule__c = sr_5_1_1.Id);
        insert sr_5_1_1_1;
        
        system_rule__c sr_5_1_1_1_1 = new system_rule__c(parent_rule__c = sr_5_1_1_1.Id, rule_field__c = 'Name', rule_value__c = 'Lead1',
                                                         max_quantity__c = 1);
        insert sr_5_1_1_1_1;
        
    }
    

    public static void testSystemPricing() {
        List<SystemPricing_SystemRuleBucket> mainBuckets = new List<SystemPricing_SystemRuleBucket>();  
        Set<Id> relatedProducts = new Set<Id>();
        
        // Find our Order...
        List<Order> orders = [SELECT Id FROM Order WHERE Name = :ORDER_NAME];
        System.assertEquals(1, orders.size(), 'Cannot reliably find my test Order');
        
        Test.startTest();
        
        // Read all products which are related to the order
        List<SystemPricing_ProductHolder> allLinkedProducts = SystemPricingController_Helper.readAllProducts(orders[0].Id, relatedProducts);
        System.assertEquals(7, allLinkedProducts.size());
        System.assertEquals(3, relatedProducts.size());
        
        // Read all applicable rules and fill the mainBuckets list.
        System.debug('Syspri: StandardPriceBookId = ' + Test.getStandardPricebookId());

        if(DO_PRINTLINE_DEBUGGING) { 
            List<PricebookEntry> pbes = [SELECT Id, Product2Id, Pricebook2Id FROM PricebookEntry WHERE Pricebook2Id = :Test.getStandardPricebookId()];
            for(PricebookEntry pbe : pbes) {
                System.debug('Syspri: PricebookEntry ProdId = ' + pbe.Product2Id + ' PB-Id: ' + pbe.Pricebook2Id);
            }
        }

        SystemPricingController_Helper.populateRuleBuckets(mainBuckets, relatedProducts, Test.getStandardPricebookId(), 'USD');
        
        System.assertEquals(NUMBER_OF_RULES_IN_TEST, mainBuckets.size(), 
                            'We created ' + NUMBER_OF_RULES_IN_TEST + ' rules, but got ' + mainBuckets.size() + ' buckets back.');
        
        // Now try and match the products
        // There can be more than one possible system
        for (SystemPricing_SystemRuleBucket currBucket : mainBuckets) {
            for(SystemPricing_ProductHolder curr : allLinkedProducts) {
                System.debug ('checkAndAddProduct(' + curr + ')');
                currBucket.checkAndAddProduct(curr);                
            }
            
            System.debug('Syspri: current bucket (' + currBucket.getRuleName() + ') holds ' + currBucket.getNumberOfMatchedProducts() + ' before removal.');
            If(currBucket.areThereExcessiveNumbersOfProducts()) { System.debug('Syspri: current bucket has excess.');  }
            // The SystemRuleBucket should have been filled now (if applicable)
            // So we clean out the excessive amounts. 
            
            currBucket.removeExcess();

            System.debug('Syspri: current bucket (' + currBucket.getRuleName() + ') holds ' + currBucket.getNumberOfMatchedProducts() + ' after removal.');
            If(currBucket.areThereExcessiveNumbersOfProducts()) { System.debug('Syspri: current bucket STILL has excess.');  }
            // Printline debugging...
            // currBucket.debugHierarchy(0);
            
            // Now check if the results are what we expected
            // For each rule - hopefully there are no rules for our special device other than those we created - we check
            // for overall count as well as the specific type matches.
            if(currBucket.getRule().name__c.containsIgnoreCase('_sr_1')) {
                System.assertEquals(4,currBucket.getNumberOfMatchedProducts(),'Expected all the 4 Lead1 products.');
                Integer prodCount = 0;
                for(SystemPricing_ProductHolder ph : currBucket.getMatchedProducts()) {
                    System.assert(((String)ph.getProdProp('Name')).containsIgnoreCase('Lead1'), 'There should only be Lead1 Products');
                    prodCount++;
                }
                System.assertEquals(4,prodCount, 'Recount does not match.');
            }
            else if(currBucket.getRule().name__c.containsIgnoreCase('_sr_2')) {
                System.assertEquals(3,currBucket.getNumberOfMatchedProducts(),'Expected 3 products.');
                Integer lead1Count = 0, lead2Count = 0;
                for(SystemPricing_ProductHolder ph : currBucket.getMatchedProducts()) {
                    String prodName = (String)ph.getProdProp('Name');
                    if(prodName.containsIgnoreCase('Lead1')) {
                        lead1Count++;
                    }
                    if(prodName.containsIgnoreCase('Lead2')) {
                        lead2Count++;
                    }
                }
                System.assertEquals(2, lead2Count);
                System.assertEquals(1, lead1Count);
                
            }
            else if(currBucket.getRule().name__c.containsIgnoreCase('_sr_3')) {
                System.assertEquals(2,currBucket.getNumberOfMatchedProducts(),'Expected 2 products.');
                Integer lead1Count = 0, lead2Count = 0;
                for(SystemPricing_ProductHolder ph : currBucket.getMatchedProducts()) {
                    String prodName = (String)ph.getProdProp('Name');
                    if(prodName.containsIgnoreCase('Lead1')) {
                        lead1Count++;
                    }
                    if(prodName.containsIgnoreCase('Lead2')) {
                        lead2Count++;
                    }
                }
                System.assertEquals(2, lead2Count);
                System.assertEquals(0, lead1Count);
                
            }
            else if(currBucket.getRule().name__c.containsIgnoreCase('_sr_4')) {
                // Even though rulke 4 matches 'Lead3' and we have inserted an entry, the asssociated Asset is set to 'discarded' - this should not be 
                // matching!
                System.assertEquals(0,currBucket.getNumberOfMatchedProducts(),'Expected no products.');
            }
            else if(currBucket.getRule().name__c.containsIgnoreCase('_sr_5')) {
                System.assertEquals(1,currBucket.getNumberOfMatchedProducts(),'Expected 1 product.');
                System.assert(((String)currBucket.getMatchedProducts()[0].getProdProp('Name')).containsIgnoreCase('Lead1'), 'There should only be Lead1 Products');
                
            }
            
            
        }
        
        
        // Up to here we have tested that the logic itself seems to work as designed.
        // Now for testing the page in combination with its controller.
        // This is mostly smoke testing, but it makes sure that the page gets all necessary information
        // from the controller.
        
        PageReference pref = Page.SystemPricing;
        
        pref.getParameters().put('id',orders[0].id);
        
        Test.setCurrentPage(pref);
        
        System.debug('Syspri: testing controller');
        ApexPages.StandardController con = new ApexPages.StandardController(orders[0]);
        SystemPricingPreController preExt = new SystemPricingPreController(con);
        SystemPricingController ext = new SystemPricingController(con);

        ext.getCurrency();
        List<SystemPricing_SystemRuleBucket> buckets = ext.getMatchedSystems();
        if(buckets.size() > 0) {
            System.currentPageReference().getParameters().put('sysid', buckets[0].getRule().Id);
        }
        ext.selectSystem();
        preExt.initInfo();
        ext.cancelSystem();

        // And now for pure percentage raising, aka SmokeTest
        Product2 tprod = [SELECT Id, Name FROM Product2 WHERE Name LIKE '%TestProduct%' LIMIT 1];
        SystemPricing_ProductHolder ph = new SystemPricing_ProductHolder(tprod);
        system_rule__c sr = new system_rule__c(parent_rule__c = orders[0].Id);
        SystemPricing_SystemRuleBucket srb;
        try {
            srb = new SystemPricing_SystemRuleBucket(sr, 200, 'Syspri Test System', null);
            System.assert(false);
        }
        catch(Exception e) {
            System.assert(true);
        }
        sr.parent_rule__c = null;
        srb = new SystemPricing_SystemRuleBucket(sr, 200, 'Syspri Test System', null);
        srb.parBucket = srb;
        try {
            srb = new SystemPricing_SystemRuleBucket(sr, srb);
            System.assert(false);
        }
        catch(Exception e) {
            System.assert(true);
        }
        
        

    }

    @isTest
    public static void testAsSales() {
        List<Profile> profs = [Select Name, id FROM profile WHERE Name = 'Sales'];
        System.assertEquals(1, profs.size());
        Id salesProfileId = profs[0].Id;

        System.assertNotEquals(null, salesProfileId);

        List<Order> orders = [SELECT Id, OwnerId FROM Order WHERE Name = :ORDER_NAME];
        System.assertEquals(1, orders.size(), 'Cannot reliably find my test Order');

        User salesUser = TestDataFactory.createUser(salesProfileId, 'myS');
        insert salesUser;

        orders[0].OwnerId = salesUser.Id;
        update orders;

        System.runAs(salesUser) {
            testSystemPricing();
        }
    }

    @isTest
    public static void testAsInsidesales() {
        List<Profile> profs = [Select Name, id FROM profile WHERE Name = 'Inside Sales'];
        System.assertEquals(1, profs.size());
        Id insidesalesProfileId = profs[0].Id;

        System.assertNotEquals(null, insidesalesProfileId);

        List<Order> orders = [SELECT Id, OwnerId FROM Order WHERE Name = :ORDER_NAME];
        System.assertEquals(1, orders.size(), 'Cannot reliably find my test Order');

        User insidesalesUser = TestDataFactory.createUser(insidesalesProfileId, 'myIS');
        insert insidesalesUser;

        orders[0].OwnerId = insidesalesUser.Id;
        update orders;

        System.runAs(insidesalesUser) {
            testSystemPricing();
        }

    }

    /* Tests accessibility for all necessary fields.
     *
     */
/*    @isTest
    public static void testAccessControl() {
        List<Profile> profs = [Select Name, id FROM profile WHERE Name like '%Sales%'];
        Id salesProfileId, insidesalesProfileId;
        for(Profile p : profs) {
            if(p.Name == 'Sales') {
                salesProfileId = p.Id;
            }
            else if (p.name == 'Inside Sales') {
                insidesalesProfileId = p.Id;
            }
        }

        System.assertNotEquals(null, salesProfileId);
        System.assertNotEquals(null, insidesalesProfileId);

        User salesUser = TestDataFactory.createUser(salesProfileId);
        User insidesalesUser = TestDataFactory.createUser(insidesalesProfileId);


        List<String> objCreate = new List<String> { 'OrderItem', 'Asset' };

            List<String> objDelete = new List<String> {
                        'OrderItem', 'Asset'
                    };

                        List<String> objUpdate = new List<String> {
                            'OrderItem', 'Asset'
                                };

                    List<String> objRead = new List<String> {
                        'Order', 'OrderItem', 'Asset'
        };

            System.runAs(salesUser) {


            }


        List<String> fieldsRW = new List<String> {

        };


    }
*/
}