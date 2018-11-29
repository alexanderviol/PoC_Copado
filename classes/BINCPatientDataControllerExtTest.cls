@isTest
public class BINCPatientDataControllerExtTest {
	private static String IMPLANTING_ACCOUNT_NAME = 'TestAccount';
    private static String PATIENT_LAST_NAME = 'PatientLastName';
    private static String IMPLANTING_PHYSICIAN_LAST_NAME = 'ImplantingPhysicianLastName';
    private static String MANUFACTURER_BIOTRONIK = 'BIOTRONIK';
    private static String MANUFACTURER_OTHER = '5500_SRN';
    
    @testSetup
    public static void setupEnvironment () {
        Pricebook2 pb = new Pricebook2(Name = 'TestPB', CurrencyIsoCode = 'USD');
        insert pb;
        Account acc = TestDataFactory.createAccount ();
        acc.Name = IMPLANTING_ACCOUNT_NAME;
        acc.crm_pricebook__c = pb.Id;
        insert acc;
        
        List<Product2> products2Insert = new List<Product2> ();
        
        Product2 crtdProd = TestDataFactory.createProduct ('Product');
        crtdProd.product_type__c = Constants.PICKLIST_VALUE_PRODUCT_TYPE_CRT_D;
        crtdProd.manufacturer__c = MANUFACTURER_BIOTRONIK;
        products2Insert.add (crtdProd);

        Product2 leadProd = TestDataFactory.createProduct ('Product');
        leadProd.product_type__c = Constants.PICKLIST_VALUE_PRODUCT_TYPE_LEAD;
        leadProd.manufacturer__c = MANUFACTURER_BIOTRONIK;
        products2Insert.add (leadProd);

        Product2 oLeadProd = TestDataFactory.createProduct ('Product');
        oLeadProd.product_type__c = Constants.PICKLIST_VALUE_PRODUCT_TYPE_LEAD;
        oLeadProd.manufacturer__c = MANUFACTURER_OTHER;
        products2Insert.add (oLeadProd);

        Product2 accProd = TestDataFactory.createProduct ('Product');
        accProd.product_type__c = Constants.PICKLIST_VALUE_PRODUCT_TYPE_ACCESSORY;
        accProd.manufacturer__c = MANUFACTURER_BIOTRONIK;
        products2Insert.add (accProd);

        Product2 adaProd = TestDataFactory.createProduct ('Product');
        adaProd.product_type__c = Constants.PICKLIST_VALUE_PRODUCT_TYPE_ADAPTER;
        adaProd.manufacturer__c = MANUFACTURER_BIOTRONIK;
        products2Insert.add (adaProd);

        Product2 cmProd = TestDataFactory.createProduct ('Product');
        cmProd.product_type__c = Constants.PICKLIST_VALUE_PRODUCT_TYPE_CARDIO_MESSENGER;
        cmProd.manufacturer__c = MANUFACTURER_BIOTRONIK;
        products2Insert.add (cmProd);
        
        insert products2Insert;
        

        List<PricebookEntry> pbes2Insert = new List<PricebookEntry> ();
        
        PricebookEntry pbe = TestDataFactory.createPricebookEntry (Test.getStandardPricebookId(), crtdProd.Id);
        pbe.CurrencyIsoCode = 'USD';
        pbe.UnitPrice = 6000;
        pbes2Insert.add (pbe);

        PricebookEntry crtdPbe = TestDataFactory.createPricebookEntry (pb.Id, crtdProd.Id);
        crtdPbe.CurrencyIsoCode = 'USD';
        crtdPbe.UnitPrice = 6000;
        pbes2Insert.add (crtdPbe);

        
        pbe = TestDataFactory.createPricebookEntry (Test.getStandardPricebookId(), leadProd.Id);
        pbe.CurrencyIsoCode = 'USD';
        pbe.UnitPrice = 400;
        pbes2Insert.add (pbe);
        
        PricebookEntry leadPbe = TestDataFactory.createPricebookEntry (pb.Id, leadProd.Id);
        leadPbe.CurrencyIsoCode = 'USD';
        leadPbe.UnitPrice = 400;
        pbes2Insert.add (leadPbe);

        
        pbe = TestDataFactory.createPricebookEntry (Test.getStandardPricebookId(), oLeadProd.Id);
        pbe.CurrencyIsoCode = 'USD';
        pbe.UnitPrice = 350;
        pbes2Insert.add (pbe);
        
        PricebookEntry oLeadPbe = TestDataFactory.createPricebookEntry (pb.Id, oLeadProd.Id);
        oLeadPbe.CurrencyIsoCode = 'USD';
        oLeadPbe.UnitPrice = 400;
        pbes2Insert.add (oLeadPbe);

        
        pbe = TestDataFactory.createPricebookEntry (Test.getStandardPricebookId(), adaProd.Id);
        pbe.CurrencyIsoCode = 'USD';
        pbe.UnitPrice = 35;
        pbes2Insert.add (pbe);

        PricebookEntry adaPbe = TestDataFactory.createPricebookEntry (pb.Id, adaProd.Id);
        adaPbe.CurrencyIsoCode = 'USD';
        adaPbe.UnitPrice = 25;
        pbes2Insert.add (adaPbe);
      
        
        pbe = TestDataFactory.createPricebookEntry (Test.getStandardPricebookId(), accProd.Id);
        pbe.CurrencyIsoCode = 'USD';
        pbe.UnitPrice = 500;
        pbes2Insert.add (pbe);

        PricebookEntry accPbe = TestDataFactory.createPricebookEntry (pb.Id, accProd.Id);
        accPbe.CurrencyIsoCode = 'USD';
        accPbe.UnitPrice = 500;
        pbes2Insert.add (accPbe);

        
        pbe = TestDataFactory.createPricebookEntry (Test.getStandardPricebookId(), cmProd.Id);
        pbe.CurrencyIsoCode = 'USD';
        pbe.UnitPrice = 0;
        pbes2Insert.add (pbe);

        PricebookEntry cmPbe = TestDataFactory.createPricebookEntry (pb.Id, cmProd.Id);
        cmPbe.CurrencyIsoCode = 'USD';
        cmPbe.UnitPrice = 0;
        pbes2Insert.add (cmPbe);
        
        insert pbes2Insert;
        
        
        List<Contact> contacts2Insert = new List<Contact> ();
        
        Contact patient = TestDataFactory.createPatient (false);
        patient.LastName = PATIENT_LAST_NAME;
        Id patientRT = Utility.getRecordTypeId ('Contact', 'us_patient');
        patient.RecordTypeId = patientRT;
        contacts2Insert.add (patient);
           
        Contact physician = TestDataFactory.createPhysician (false);
        physician.LastName = IMPLANTING_PHYSICIAN_LAST_NAME;
        contacts2Insert.add (physician);
            
        insert contacts2Insert;    

        
		// Create Order
        Order o = TestDataFactory.createOrder(acc.Id, pb.Id, physician.Id, patient.Id);
        o.implant_date__c = Date.today();
        insert o;
            
        
        List<Asset> assets2Insert = new List<Asset> ();
        
        Id assetBioRT = Utility.getRecordTypeId('Asset', 'US_BIOAsset');
        Id assetCompRT = Utility.getRecordTypeId('Asset', 'US_CompetitorAsset');
        
        Asset tAsset;
        // ========== Explanted Assets ============
        tAsset = TestDataFactory.createAsset (acc.Id, crtdProd.Id);
        tAsset.patient__c = patient.Id;
        tAsset.Explant_Date__c = Date.today ();
        tAsset.Status = Constants.IMPLANT_STATUS_EXPLANTED;
        tAsset.manufacturer__c = MANUFACTURER_OTHER;
        tAsset.RecordTypeId = assetCompRT;
        tAsset.product_type__c = crtdProd.product_type__c;
        
        System.assert(Utility.isDeviceForPrinting(tAsset.product_type__c));
        assets2Insert.add (tAsset);
        
        // This explanted lead was explanted one day ago.
        // => explanted on patient, not related to current Order.
        tAsset = TestDataFactory.createAsset (acc.Id, leadProd.id);
        tAsset.patient__c = patient.Id;
        tAsset.Explant_Date__c = Date.today ().addDays (-1);
        tAsset.Status = Constants.IMPLANT_STATUS_CAPPED;
        tAsset.manufacturer__c = MANUFACTURER_BIOTRONIK;
        tAsset.RecordTypeId = assetBioRT;
        tAsset.product_type__c = leadProd.product_type__c;
        assets2Insert.add (tAsset);
        System.assert (!Utility.isDeviceForPrinting (tAsset.product_type__c));
        System.assert (Utility.isExplantedDeviceStatus (tAsset.Status), 'This lead should be explanted.');
        System.assertEquals (Constants.VALI_CAT_LEAD, Utility.getValidationCategory (tAsset.product_type__c), 'This lead should be of a lead type.');

        // This explanted lead was explanted today.
        // => explanted on patient and current Order.
        tAsset = TestDataFactory.createAsset (acc.Id, leadProd.id);
        tAsset.patient__c = patient.Id;
        tAsset.Explant_Date__c = Date.today ();
        tAsset.Status = Constants.IMPLANT_STATUS_CAPPED;
        tAsset.manufacturer__c = MANUFACTURER_BIOTRONIK;
        tAsset.RecordTypeId = assetBioRT;
        tAsset.product_type__c = leadProd.product_type__c;
        assets2Insert.add (tAsset);
        System.assert (!Utility.isDeviceForPrinting (tAsset.product_type__c));
        System.assert (Utility.isExplantedDeviceStatus (tAsset.Status), 'This lead should be explanted.');
        System.assertEquals (Constants.VALI_CAT_LEAD, Utility.getValidationCategory (tAsset.product_type__c), 'This lead should be of a lead type.');


        // ========== Implanted Assets ============
        Asset crtdAss = TestDataFactory.createAsset (acc.Id, crtdProd.Id);
        crtdAss.patient__c = patient.Id;
        crtdAss.InstallDate = Date.today ();
        crtdAss.Status = Constants.IMPLANT_STATUS_IMPLANTED;
        crtdAss.manufacturer__c = MANUFACTURER_BIOTRONIK;
        crtdAss.RecordTypeId = assetBioRT;
        crtdAss.product_type__c = crtdProd.product_type__c;
        crtdAss.order__c = o.Id;
        assets2Insert.add (crtdAss);
        System.assert(Utility.isDeviceForPrinting(crtdAss.product_type__c));

        
        Asset leadAss = TestDataFactory.createAsset (acc.Id, leadProd.Id);
        leadAss.patient__c = patient.Id;
        leadAss.InstallDate = Date.today ();
        leadAss.Status = Constants.IMPLANT_STATUS_IMPLANTED;
        leadAss.manufacturer__c = MANUFACTURER_BIOTRONIK;
        leadAss.RecordTypeId = assetBioRT;
        leadAss.product_type__c = leadProd.product_type__c;
        leadAss.order__c = o.Id;
        assets2Insert.add (leadAss);
        System.assert (!Utility.isDeviceForPrinting (leadAss.product_type__c));


        Asset oLeadAss = TestDataFactory.createAsset (acc.Id, oLeadProd.Id);
        oLeadAss.patient__c = patient.Id;
        oLeadAss.InstallDate = Date.today ();
        oLeadAss.Status = Constants.IMPLANT_STATUS_IMPLANTED;
        oLeadAss.manufacturer__c = MANUFACTURER_OTHER;
        oLeadAss.RecordTypeId = assetCompRT;
        oLeadAss.product_type__c = oLeadProd.product_type__c;
        oLeadAss.order__c = o.Id;
        assets2Insert.add (oLeadAss);
        System.assert (!Utility.isDeviceForPrinting (oLeadAss.product_type__c));

        Asset adaAss = TestDataFactory.createAsset (acc.Id, adaProd.Id);
        adaAss.patient__c = patient.Id;
        adaAss.InstallDate = Date.today ();
        adaAss.Status = Constants.IMPLANT_STATUS_IMPLANTED;
        adaAss.manufacturer__c = MANUFACTURER_BIOTRONIK;
        adaAss.RecordTypeId = assetBioRT;
        adaAss.product_type__c = adaProd.product_type__c;
        adaAss.order__c = o.Id;
        assets2Insert.add (adaAss);
        System.assert (!Utility.isDeviceForPrinting (oLeadAss.product_type__c));
        
        Asset accAss = TestDataFactory.createAsset (acc.Id, accProd.Id);
        accAss.patient__c = patient.Id;
        accAss.InstallDate = Date.today ();
        accAss.Status = Constants.IMPLANT_STATUS_IMPLANTED;
        accAss.manufacturer__c = MANUFACTURER_BIOTRONIK;
        accAss.RecordTypeId = assetBioRT;
        accAss.product_type__c = accProd.product_type__c;
        accAss.order__c = o.Id;
        assets2Insert.add (accAss);
        System.assert (!Utility.isDeviceForPrinting (accAss.product_type__c));

        Asset cmAss = TestDataFactory.createAsset (acc.Id, cmProd.Id);
        cmAss.patient__c = patient.Id;
        cmAss.InstallDate = Date.today ();
        cmAss.Status = Constants.IMPLANT_STATUS_IMPLANTED;
        cmAss.manufacturer__c = MANUFACTURER_BIOTRONIK;
        cmAss.RecordTypeId = assetBioRT;
        cmAss.product_type__c = accProd.product_type__c;
        cmAss.order__c = o.Id;
        assets2Insert.add (cmAss);
        System.assert (!Utility.isDeviceForPrinting (cmAss.product_type__c));
        
        insert assets2Insert;
        
        List<OrderItem> ois2Insert = new List<OrderItem> ();
        
        System.assertNotEquals(null, crtdPbe.Id);
        OrderItem crtdOI = TestDataFactory.createOrderItem (o.Id, crtdPbe.Id);
        crtdOI.implant_date__c = Date.today ();
        crtdOI.asset__c = crtdAss.Id;

        ois2Insert.add (crtdOI);
        
        System.assertNotEquals(null, leadPbe.Id);
        OrderItem leadOI = TestDataFactory.createOrderItem (o.Id, leadPbe.Id);
        leadOI.implant_date__c = Date.today ();
        leadOI.asset__c = leadAss.Id;
        ois2Insert.add (leadOI);

        System.assertNotEquals(null, oLeadPbe.Id);
        OrderItem oLeadOI = TestDataFactory.createOrderItem (o.Id, oLeadPbe.Id);
        oLeadOI.implant_date__c = Date.today ();
        oLeadOI.asset__c = oLeadAss.Id;
        ois2Insert.add (oLeadOI);
        
        System.assertNotEquals(null, accPbe.Id);
        OrderItem accOI = TestDataFactory.createOrderItem (o.Id, accPbe.Id);
        accOI.implant_date__c = Date.today ();
        accOI.asset__c = accAss.Id;
        ois2Insert.add (accOI);

        System.assertNotEquals(null, cmPbe.Id);
        OrderItem cmOI = TestDataFactory.createOrderItem (o.Id, cmPbe.Id);
        cmOI.implant_date__c = Date.today ();
        cmOI.asset__c = cmAss.Id;
        ois2Insert.add (cmOI);

		insert ois2Insert;        
        
    }
    
    @isTest
    public static void testPrintingController () {
        List<Account> accs = [SELECT Id FROM Account WHERE Name = :IMPLANTING_ACCOUNT_NAME];
        System.assertEquals (1, accs.size(), 'Could not find my test account');
        
        List<Order> implantOrders = [SELECT id,
                                  patient__r.LastName,
                                  patient__r.FirstName,
                                  patient__r.MailingCity,
                                  patient__r.MailingState,
                                  patient__r.MailingStreet,
                                  patient__r.MailingPostalCode,
                                  patient__r.Phone,
                                  patient__c,
                                  
                                  account.Name,
                                  account.BillingStreet,
                                  account.BillingCity,
                                  account.BillingState,
                                  account.BillingPostalCode,
                                  account.Phone,
                                  
                                  following_physican__r.LastName,
                                  following_physican__r.FirstName,
                                  following_physican__r.MailingStreet,
                                  following_physican__r.MailingCity,
                                  following_physican__r.MailingState,
                                  following_physican__r.MailingPostalCode,
                                  following_physican__r.Phone,
                                  
                                  implanting_physician__r.Name,
                                  implanting_physician__r.mailingstreet,
                                  implanting_physician__r.mailingcity,
                                  implanting_physician__r.mailingstate,
                                  implanting_physician__r.mailingpostalcode,
                                  implanting_physician__r.phone,
                                  
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
                                  
                                  implant_date__c FROM Order WHERE AccountId = :accs[0].Id];
        
        System.assertEquals (1, implantOrders.size (), 'Cannot find my test order again.');
        Order myOrder = implantOrders[0];
        
        ApexPages.StandardController sc = new ApexPages.StandardController (myOrder);
        BINCPatientDataControllerExt controller = new BINCPatientDataControllerExt (sc);
        
        System.assertEquals (myOrder.Id, controller.currentOrder.Id, 'Orders differ');
        System.assertEquals (2, controller.currentOrderAccessories.size (), 'OrderItems: Accessories');
        System.assertEquals (1, controller.currentOrderBiotronikImplantedDeviceList.size (), 'Asset: implanted devices');
        System.assertEquals (3, controller.currentOrderDevicesAndLeads.size (), 'OrderItems: devices and leads');
        System.assertEquals (1, controller.currentOrderExplantedDevices.size (), 'Assets: explanted devices');
        System.assertEquals (1, controller.currentOrderExplantedLeads.size (), 'Assets: explanted leads');
        System.assertEquals (3, controller.currentOrderImplantedLeadsAndAdaptersList.size (), 'OrderItems: implanted leads and adapters');
        System.assertEquals (1, controller.patientExplantedDeviceList.size (), 'Assets: explanted devices');
        System.assertEquals (3, controller.patientExplantedItems.size (), 'Assets: explanted items');
        System.assertEquals (2, controller.patientExplantedLeadsAndAdaptersList.size (), 'Assets: explanted leads and adapters');
        System.assertEquals (1, controller.patientImplantedDeviceList.size (), 'Assets: implanted devices');
        System.assertEquals (2, controller.patientImplantedLeads.size (), 'Assets: implanted leads');
        System.assertEquals (3, controller.patientImplantedLeadsAndAdapters.size (), 'Assets: implanted leads and adapters');
        
    }
}