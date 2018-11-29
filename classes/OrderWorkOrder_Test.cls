/* Tests functionality in the WorkOrder to Order roundtrip
 * Includes
 *  - Transmission WorkOrder->Order
 *  - Adding products on Order
 */

@isTest
public class OrderWorkOrder_Test {
    public static final String PB_NAME_STANDARD = 'Standard';
    public static final String PB_NAME_CUSTOM   = 'Custom Pricebook';
    public static final String PROD_NAME_PM     = 'A_TestProduct_PM';
    public static final String PROD_NAME_LEAD1  = 'A_TestProduct_Lead1';
    public static final String PROD_NAME_LEAD2  = 'A_TestProduct_Lead2';
    public static final String ACC_NAME_PATIENT = 'A_Patient-Account';
    public static final String ACC_NAME_IMPLANT = 'A_Implanting Facility Inc.';
    public static final String CON_NAME_PATIENT = 'A_TestPatient';
    public static final String CON_NAME_REFERRING_PHYSICIAN = 'A_TestReferrer';
    public static final String CON_NAME_IMPLANTING_PHYSICIAN = 'A_TestImplanter';
    public static final String LOC_NAME         = 'A_TestLocation';
    public static final String WO_SUBJECT       = 'A_TestWorkOrder';
    public static final String ORDER_NAME       = 'A_Test Order';
    public static final String ORDER_STATUS     = 'Not Submitted';
    
    public static final String SER_NO_PRODPM	= '1234567';
    public static final String SER_NO_PRODLEAD1	= '2345678';
    public static final String SER_NO_PRODLEAD2	= '3456789';
    
    
    public static final Decimal QUANT_PROD_PM       = 1.0;
    public static final Decimal QUANT_PROD_LEAD1    = 1.0;
    public static final Decimal QUANT_PROD_LEAD2    = 4.0;

    public static final String RT_ORDER_IMPLANT     = 'Implant Order';

    /* Helps finding an appropriate product.
     * Tries an exact match first, then substring, else returns null
     * 
     * TODO: This functionality also exists in SystemPricing_Helper => merge this!
     */
    public static Product2 findProduct(String nameSubstring) {
        Product2 returnValue = null;
        List<Product2> products = [SELECT Id, Name FROM Product2 WHERE Name = :nameSubstring];
        if(products.size() > 0) {
            returnValue = products[0];
        }
        else {
            nameSubstring = '%' + nameSubstring + '%';
            products = [SELECT Id, Name FROM Product2 WHERE Name LIKE :nameSubstring LIMIT 1];
            if(products.size() > 0) {
                returnValue = products[0];
            }
        }
        return returnValue;
    }

    
    /* Setup the environment
     * 
     */
    @testSetup
    public static void setupEnvironment() {
        // We need pricebooks
        Pricebook2 standardPb;
        Pricebook2 customPb;
        
        
        // Standard Pricebook
        List<Pricebook2> pbs;
        
        pbs = [SELECT Id FROM Pricebook2 WHERE IsStandard = True];
        if (pbs.size() == 0) {
            // No standard pricebook?
            //standardPb = new Pricebook2(Name = PB_NAME_STANDARD, IsStandard = true, IsActive = True);

            // IsStandard is not writeable. All Organisations can only have on standard Pricebook. So let's assume and hope that
            // the very first created Pricebook is the standard Pricebook
            standardPb = new Pricebook2(Name = PB_NAME_STANDARD, IsActive = True, CurrencyISOCode = 'USD');
            insert standardPb;
        }
        else {
            standardPb = pbs[0];
        }

        Id standardPbId = Test.getStandardPricebookId();
        // Id standardPbId = standardPb.Id;

        
        // Our Custom pricebook
        customPb = TestDataFactory.findOrCreateCustomPricebook(PB_NAME_CUSTOM);
        
        // We will need products
        List<Product2> prodsToInsert = new List<Product2>();

        Product2 prodPM = findProduct(PROD_NAME_PM);
        if (prodPM == null) {
            prodPM = new Product2 (Name = PROD_NAME_PM, ProductCode = '12345', IsActive = True
                                   // Florian Heer <f.heer@conciscon.de> 2018-07-23 Circumventing issues with ProMRI future call
                                   // Test methods cannot use future calls, but there is no provisioned way to ignore that call in AssetHandler
                                   , product_type__c = Constants.PICKLIST_VALUE_PRODUCT_TYPE_CRT_D, manufacturer__c = 'BIOTRONIK');
                                   // , product_type__c = 'Raw Material');
            prodsToInsert.add(prodPM);
        }
        
        Product2 prodLead1 = findProduct(PROD_NAME_LEAD1);
        if (prodLead1 == null) {
            prodLead1 = new Product2 (Name = PROD_NAME_LEAD1, ProductCode = '23456', IsActive = True
                                   // Florian Heer <f.heer@conciscon.de> 2018-07-23 Circumventing issues with ProMRI future call
                                   // Test methods cannot use future calls, but there is no provisioned way to ignore that call in AssetHandler
                                   , product_type__c = Constants.PICKLIST_VALUE_PRODUCT_TYPE_LEAD, manufacturer__c = 'BIOTRONIK');
                                   // , product_type__c = 'Raw Material');
            prodsToInsert.add(prodLead1);
        }

        Product2 prodLead2 = findProduct(PROD_NAME_LEAD2);
        if (prodLead2 == null) {
            prodLead2 = new Product2 (Name = PROD_NAME_LEAD2, ProductCode = '34567', IsActive = True
                                   // Florian Heer <f.heer@conciscon.de> 2018-07-23 Circumventing issues with ProMRI future call
                                   // Test methods cannot use future calls, but there is no provisioned way to ignore that call in AssetHandler
                                   , product_type__c = Constants.PICKLIST_VALUE_PRODUCT_TYPE_LEAD, manufacturer__c = 'BIOTRONIK');
                                   // , product_type__c = 'Raw Material');
            prodsToInsert.add(prodLead2);
        }
        
        if(prodsToInsert.size() > 0) insert prodsToInsert;
        
        List<Id> prodIds = new List<Id>();
        prodIds.add(prodPM.Id);
        prodIds.add(prodLead1.Id);
        prodIds.add(prodLead2.Id);
        
        // The products need a standard price and a custom price
        List<PricebookEntry> standardPrices = [SELECT Id, UnitPrice, Product2Id, Pricebook2Id FROM PricebookEntry 
                                               WHERE Product2Id IN :prodIds AND Pricebook2Id = :standardPbId];
        List<Id> pIds = new List<Id>(prodIds);
        for(PricebookEntry pbe : standardPrices) {
            pIds.remove(pIds.indexOf(pbe.Product2Id));
        }
        if(pIds.size() > 0) {
            Integer bogusPrice = 1000;
            List<PricebookEntry> pbe2Insert = new List<PricebookEntry>();
            for(Id pId : pIds) {
                pbe2Insert.add(new PricebookEntry(UnitPrice = bogusPrice, Product2Id = pid, Pricebook2Id = standardPbId, 
                                                 UseStandardPrice = false, CurrencyISOCode = 'USD'));
                bogusPrice += 1000;
            }
            insert pbe2Insert;
        }
        
        // custom price
        List<PricebookEntry> customPrices = [SELECT Id, UnitPrice, Product2Id, Pricebook2Id FROM PricebookEntry 
                                               WHERE Product2Id IN :prodIds AND Pricebook2Id = :customPb.Id];
        pIds = new List<Id>(prodIds);
        List<PricebookEntry> pbe2Insert = new List<PricebookEntry>();
        for(PricebookEntry pbe : customPrices) {
            pIds.remove(pIds.indexOf(pbe.Product2Id));
        }
        if(pIds.size() > 0) {
            Integer bogusPrice = 1000;
            for(Id pId : pIds) {
                pbe2Insert.add(new PricebookEntry(UnitPrice = bogusPrice, Product2Id = pid, Pricebook2Id = customPb.Id, CurrencyISOCode = 'USD'));
                bogusPrice += 1000;
            }
        }
        
        insert pbe2Insert;
        
        // We need 2 Accounts - one to assign to the patient (Assets cannot be related to a Contact which is not
        // related to an Account) and one for the implanting facility
        List<String> accNames = new List<String>();
        accNames.add(ACC_NAME_PATIENT);
        accNames.add(ACC_NAME_IMPLANT);
        Account accPatient, accImplant;
        
        List<Account> accs = [SELECT Id, Name FROM Account WHERE Name IN :accNames];
        if(accs.size() != accNames.size()) {
            for(Account acc : accs) {
                accNames.remove(accNames.indexOf(acc.Name));
            }
            List<Account> accsToInsert = new List<Account>();
            for(String accName : accNames) {
                Account a;
                if(accName == ACC_NAME_PATIENT) {
                    a = new Account (Name = accName, status__c = 'active');
                    accPatient = a;
                }
                else if(accName == ACC_NAME_IMPLANT) {
                    a = new Account (Name = accName, crm_pricebook__c = customPb.Id, status__c = 'active');
                    accImplant = a;
                }
                
                accsToInsert.add(a);
            }
            insert accsToInsert;
            accs.addAll (accsToInsert);
        }
        
        for(Account acc : accs) {
            if(acc.Name == ACC_NAME_PATIENT) accPatient = acc;
            else if(acc.Name == ACC_NAME_IMPLANT) accImplant = acc;
        }
        
        
        // We need 3 contacts, one patient and 2 physicians
        List<RecordTypeInfo> contactRTs = Schema.SObjectType.Contact.getRecordTypeInfos();
        Id rtPatientId = Utility.getRecordTypeId(Contact.SObjectType, Constants.RECORD_TYPE_NAME_CONTACT_US_PATIENT);
        Id rtPhysicianId = Utility.getRecordTypeId(Contact.SObjectType, Constants.RECORD_TYPE_NAME_CONTACT_US_PHYSICIAN);

//        public static final String CON_NAME_PATIENT = 'TestPatient';
//        public static final String CON_NAME_REFERRING_PHYSICIAN = 'TestReferrer';
//        public static final String CON_NAME_IMPLANTING_PHYSICIAN = 'TestImplanter';
        List<String> conNames = new List<String>();
        conNames.add(CON_NAME_PATIENT);
        conNames.add(CON_NAME_REFERRING_PHYSICIAN);
        conNames.add(CON_NAME_IMPLANTING_PHYSICIAN);
        Contact conPatient, conReferring, conImplanting;

        List<Contact> cons = [SELECT Id, LastName FROM Contact WHERE LastName IN :conNames];
        for(Contact con : cons) {
            if(con.LastName == CON_NAME_PATIENT) conPatient = con;
            else if(con.LastName == CON_NAME_REFERRING_PHYSICIAN) conReferring = con;
            else if(con.LastName == CON_NAME_IMPLANTING_PHYSICIAN) conImplanting = con;
        }
        if(cons.size() != conNames.size()) {
            for(Contact con : cons) {
                conNames.remove(conNames.indexOf(con.LastName));
            }
            List<Contact> consToInsert = new List<Contact>();
            for(String conName : conNames) {
                Contact c;
                if(conName == CON_NAME_PATIENT) {
                    c = new Contact (FirstName = 'Capital_letter', LastName = conName, AccountId = accPatient.Id,
                                     declined_to_provide_address__c = True, declined_to_provide_dob__c = True, 
                                     //declined_to_provide_fname__c  = True, SAFBIO 1365
                                     declined_to_provide_phone__c = True, 
                                     declined_to_provide_ssn__c  = True,
                                     RecordTypeId = rtPatientId,
//                                     MailingCountry = 'United States',
                                     status__c = 'Active');
                    conPatient = c;
                }
                else if (conName == CON_NAME_REFERRING_PHYSICIAN) {
                    c = new Contact (FirstName = 'Capital_letter', LastName = conName,
                                    RecordTypeId = rtPhysicianId, MailingCity = 'Sometown', MailingStreet = 'Some Backalley',
                                    MailingCountryCode = 'US', MailingStateCode = 'OR', MailingPostalCode = '998877', status__c = 'Active',
                                    AccountId = accImplant.Id);
                    conReferring = c;
                }
                else if (conName == CON_NAME_IMPLANTING_PHYSICIAN) {
                    c = new Contact (FirstName = 'Capital_letter', LastName = conName, AccountId = accImplant.Id,
                                    RecordTypeId = rtPhysicianId, MailingCity = 'Sometown', MailingStreet = 'Some Backalley',
                                    MailingCountryCode = 'US', MailingStateCode = 'OR', MailingPostalCode = '998877', status__c = 'Active');
                    conImplanting = c;
                }
                        
                consToInsert.add(c);
            }
            insert consToInsert;
            cons.addAll (consToInsert);
        }
        
        // Location
        
        Schema.Location loc = new Schema.Location(IsInventoryLocation = True,
                                    Name = LOC_NAME,
                                    LocationType = 'Warehouse'        
        );
        insert loc;
        
        System.debug('accImplant: ' + accImplant);
        
        // WorkOrder
        WorkOrder wo = new WorkOrder(AccountId = accImplant.Id,
// Address
// Asset
// BusinessHours
// Case
                                    Contact = conImplanting,
                                     CurrencyIsoCode = 'USD',
// Description
// Discount
// Duration
// DurationType
// EndDate
// IsClosed

// !!!
                                     Location = loc,
// MaintenancePlan
// MinimumCrewSize
// Pricebook2
// Priority
// RecommendedCrewSize
// ReturnOrder
// ReturnOrderLineItem
// RootWorkOrder
// ServiceAppointmentCount
// ServiceReportTemplate
// ServiceTerritory
                                     StartDate = Date.today(),
                                     Status = 'Not submitted',
// StatusCategory
                                     Subject = WO_SUBJECT
// Subtotal
// SuggestedMaintenanceDate
// Tax
// TotalPrice
// WorkOrderNumber
// WorkType

// one_hb__c
// two_hb__c
// three_hb_chb__c
// afib__c
// atrial_tachycadria__c
// brady_tachy_syndrome__c
// chf__c
// sap_company_code__c
// division__c
// donation__c
// following_physician__c
// implanting_physician__c
// mi__c
                                     , no_rep_present_at_implant__c = true
// npi__c
// order__c
// ous_patient__c
// patient__c
// referring_physician__c
// rep_at_implant__c
// rep_for_credit__c
// scd__c
// sick_sinus_syndrome__c
// sinus_arrest__c
// sinus_bradycardia__c
// vf__c
// vt__c
                                    , patient__c = conPatient.Id
                                    );
        insert wo;

        System.assert(wo.AccountId != null);
        
        WorkOrderLineItem woli = new WorkOrderLineItem(WorkOrderId = wo.id);
        insert woli;
        
        // ProductItems
        List<ProductItem> pisToInsert = new List<ProductItem>();
        ProductItem piPM = new ProductItem(Product2Id = prodPM.Id, QuantityOnHand = QUANT_PROD_PM, LocationId = loc.Id,
                                            SerialNumber = SER_NO_PRODPM, product_type__c = Constants.PICKLIST_VALUE_PRODUCT_TYPE_CRT_D, Manufacturer__c = 'BIOTRONIK');
        ProductItem piLead1 = new ProductItem (Product2Id = prodLead1.Id, QuantityOnHand = QUANT_PROD_LEAD1,
                                               LocationId = loc.Id, SerialNumber = SER_NO_PRODLEAD1, product_type__c = Constants.PICKLIST_VALUE_PRODUCT_TYPE_LEAD, Manufacturer__c = 'BIOTRONIK');
        ProductItem piLead2 = new ProductItem (Product2Id = prodLead2.Id, QuantityOnHand = QUANT_PROD_LEAD2,
                                               LocationId = loc.Id, SerialNumber = SER_NO_PRODLEAD2, product_type__c = Constants.PICKLIST_VALUE_PRODUCT_TYPE_LEAD, Manufacturer__c = 'BIOTRONIK');
        pisToInsert.add(piPM);
        pisToInsert.add(piLead1);
        pisToInsert.add(piLead2);
        insert pisToInsert;
        System.assertEquals(QUANT_PROD_LEAD2, piLead2.QuantityOnHand);
    }

    public static Order insertOrder(WorkOrder wo, Account accImplant, Pricebook2 customPb, Contact conPatient,
                                  Contact conReferring) 
    {
        // Order
        
        Id orderRtId;
        List<RecordTypeInfo> orderRTs = Schema.SObjectType.Order.getRecordTypeInfos();
        for(RecordTypeInfo rti : orderRTs) {
            if(rti.getName() == RT_ORDER_IMPLANT) orderRtId = rti.getRecordTypeId();
        }
        
        Order o = new Order(Account = accImplant,
                            Pricebook2Id = customPb.Id,
                            Description = 'Test Order',
                            Name = ORDER_NAME,
                            // order_status__c = ORDER_STATUS,
                            patient__c = conPatient.Id,
                            referring_physician__c = conReferring.Id,
                            AccountId = accImplant.Id,
                            EffectiveDate = Date.today(),
                            Status = ORDER_STATUS,
                            RecordTypeId = orderRtId,
                            no_rep_present_at_implant__c = true
                            
                           );
        
        insert o;
        
        wo.order__c = o.Id;
        update wo;
        
        return o;
    }

    public static void setupWOLIs(WorkOrder wo, Order o) {
        List<WorkOrderLineItem> wolis = [SELECT Id, OrderId FROM WorkOrderLineItem WHERE WorkOrderId = :wo.Id];
        for (WorkOrderLineItem woli : wolis) {
            woli.OrderId = o.Id;
        }
        update wolis;
    }
    

    /* Tests adding products manually to an Order
     * 
     */    

    /* Test method needed to be split in parts as Process Builder flows eat up the SOQL statements
     * 
     */
    @isTest
    public static void testAddProducts_pt1() {
        WorkOrder wo = [SELECT Id, order__c FROM WorkOrder WHERE Subject = :WO_SUBJECT LIMIT 1];
        
        Account accImplant = [SELECT Id FROM Account WHERE Name = :ACC_NAME_IMPLANT LIMIT 1];
        Pricebook2 customPb = TestDataFactory.findOrCreateCustomPricebook(PB_NAME_CUSTOM);
        Contact conPatient = [SELECT Id FROM Contact WHERE LastName = :CON_NAME_PATIENT LIMIT 1];
        Contact conReferring = [SELECT Id FROM Contact WHERE LastName = :CON_NAME_REFERRING_PHYSICIAN LIMIT 1];
        
        Order o = insertOrder(wo, accImplant, customPb, conPatient, conReferring);
        
        Product2 pmProd = [SELECT Id FROM Product2 WHERE Name = :PROD_NAME_PM];
        Product2 lead2Prod = [SELECT Id FROM Product2 WHERE Name = :PROD_NAME_LEAD2];
        List<Order> orders = [SELECT Id FROM Order WHERE Name = :ORDER_NAME];
        System.assert(orders.size() > 0, 'Cannot find my own Order object');
        Id orderId = orders[0].Id;
        
        Test.startTest();
        List<OrderItem> oItems;
        List<ProductItem> pis;

        pis = AddProdManually.searchForProductItems(SER_NO_PRODPM, orderId);
        System.assertEquals(1,pis.size(), 'After inserting one ProductItem ( SerialNumber ' + SER_NO_PRODPM + ') it is not correctly there.');
        ProductItem pmPI = [SELECT Id, QuantityOnHand FROM ProductItem WHERE Id = :pis[0].Id LIMIT 1];
        System.assertEquals(QUANT_PROD_PM, pmPI.QuantityOnHand, 'Have we not inserted the right amount?');

        try {
            AddProdManually.consumeProduct(pmPI.Id, 'Not a number', '' + orderId);
            System.assert(false, 'should not reach this.');
        }
        catch (Exception e) {}
        
        
        AddProdManually.consumeProduct(pmPI.Id, '1', '' + orderId);
        pmPI = [SELECT Id, QuantityOnHand FROM ProductItem WHERE Id = :pis[0].Id LIMIT 1];
        System.assertEquals(0, pmPI.QuantityOnHand, 'Have we not consumed as many items as there were?');
        oItems = [SELECT Id, Quantity FROM OrderItem WHERE Product2Id = :pmProd.Id AND OrderId = :orderId];
        System.assertEquals(1, oItems.size(), 'Consumed this product, but the number of entries is wrong');
        System.assertEquals(1, oItems[0].Quantity, 'Consumed this quantity, but it does not show?');
        
        pis = AddProdManually.searchForProductItems(SER_NO_PRODLEAD2, orderId);

        System.assertEquals(1,pis.size(), 'After inserting Lead, SerialNumber ' + SER_NO_PRODLEAD2 + ', it is not correctly there.');
        ProductItem lead2PI  = [SELECT Id, QuantityOnHand FROM ProductItem WHERE Id = :pis[0].Id LIMIT 1];
        
        System.assertEquals(QUANT_PROD_LEAD2, lead2PI.QuantityOnHand, 'Have we not inserted the right amount?');
        Integer usedAmountLead2 = 2;
        AddProdManually.consumeProduct(lead2PI.Id, '' + usedAmountLead2, '' + orderId);
        lead2PI = [SELECT Id, QuantityOnHand FROM ProductItem WHERE Id = :pis[0].Id LIMIT 1];
        System.assertEquals(QUANT_PROD_LEAD2 - usedAmountLead2, lead2PI.QuantityOnHand, 'Have we not consumed the right amount of items?');
        oItems = [SELECT Id, Quantity FROM OrderItem WHERE Product2Id = :lead2Prod.Id AND OrderId = :orderId];
        System.assertEquals(1, oItems.size());
        System.assertEquals(QUANT_PROD_LEAD2 - usedAmountLead2, oItems[0].Quantity);
    }
        
        @isTest
    public static void testAddProducts_pt2() {
        WorkOrder wo = [SELECT Id, order__c FROM WorkOrder WHERE Subject = :WO_SUBJECT LIMIT 1];
        
        Account accImplant = [SELECT Id FROM Account WHERE Name = :ACC_NAME_IMPLANT LIMIT 1];
        Pricebook2 customPb = TestDataFactory.findOrCreateCustomPricebook(PB_NAME_CUSTOM);
        Contact conPatient = [SELECT Id FROM Contact WHERE LastName = :CON_NAME_PATIENT LIMIT 1];
        Contact conReferring = [SELECT Id FROM Contact WHERE LastName = :CON_NAME_REFERRING_PHYSICIAN LIMIT 1];

        Order o = insertOrder(wo, accImplant, customPb, conPatient, conReferring);
        
        Product2 pmProd = [SELECT Id FROM Product2 WHERE Name = :PROD_NAME_PM];
        Product2 lead2Prod = [SELECT Id FROM Product2 WHERE Name = :PROD_NAME_LEAD2];
        List<Order> orders = [SELECT Id FROM Order WHERE Name = :ORDER_NAME];
        System.assert(orders.size() > 0, 'Cannot find my own Order object');
        Id orderId = orders[0].Id;
        
        Test.startTest();
        List<ProductItem> pis = AddProdManually.searchForProductItems(SER_NO_PRODLEAD2, orderId);
        System.assertEquals(1, pis.size());
        ProductItem lead2PI = [SELECT Id, QuantityOnHand FROM ProductItem WHERE Id = :pis[0].Id LIMIT 1];

        AddProdManually.consumeProduct(lead2PI.Id, '1', '' + orderId);
        List<OrderItem> oItems = [SELECT Id, Quantity FROM OrderItem WHERE Product2Id = :lead2Prod.Id AND OrderId = :orderId];
        System.assertEquals(1, oItems.size());

        setupWOLIs(wo, o);
        AddProdManually.consumeProduct(lead2PI.Id, '1', '' + orderId);
        oItems = [SELECT Id, Quantity FROM OrderItem WHERE Product2Id = :lead2Prod.Id AND OrderId = :orderId];
        System.assertEquals(2, oItems.size());
        

        Test.stopTest();
    }
    
    /* Tests conversion from WorkOrder to Order
     */
    @isTest
    public static void testWorkOrderToOrder() {
        List<WorkOrder> workOrders = [SELECT Id, AccountId, Subject, Status FROM WorkOrder WHERE order__c = null];
        System.debug('# of WorkOrders: ' + workOrders.size());
        for(WorkOrder wo : workOrders) {
            System.debug('wo: ' + wo);
            System.assert(wo.AccountId != null);
        }
        
        String workOrderId = workOrders[0].Id;
        
        List<ProductItem> pis = [SELECT Id, QuantityOnHand FROM ProductItem];
        List<ProductConsumed> pc2Insert = new List<ProductConsumed> ();
        for(ProductItem pi : pis) {
            pc2Insert.add(new ProductConsumed(WorkOrderId = workOrderId, QuantityConsumed = pi.QuantityOnHand, ProductItemId = pi.id));
        }
        insert pc2Insert;
        
        Test.startTest();
        // Don't need the test direkt like this, we'll use the opportunity to test the trigger
        // List<Order> orders = WorkOrderConversion.convertToOrder(workOrders);
        for(WorkOrder wo : workOrders) {
            wo.Status = WorkOrderHandler.TRANSMISSION_TRIGGER_STATUS;
        }
        update workOrders;
        
        try {
            Order order = WorkOrderConversion.convertToOrder(workOrders[0].Id);
            System.assert(false, 'Should not reach this, this WorkOrder has already been converted.');
        }
        catch(Exception e) {}
        
        try {
            Order o = WorkOrderConversion.convertToOrder('0WO7E0000008000000');
            System.assert(false, 'Should not reach this, there is no such WorkOrder.');
        }
        catch(Exception e) {}
        
        Test.stopTest();            
    }
}