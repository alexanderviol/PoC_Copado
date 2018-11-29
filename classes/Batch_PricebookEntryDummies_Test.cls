@isTest
public class Batch_PricebookEntryDummies_Test {
    public static final Integer NUM_PRODUCTS = 50;
    public static final Integer NUM_CRM_ENTRIES = 30;
    public static final Integer OFFSET_CRM = 0;
    public static final Integer NUM_CVI_ENTRIES = 30;
    public static final Integer OFFSET_CVI = 10;
    public static final Integer NUM_PVI_ENTRIES = 30;
    public static final Integer OFFSET_PVI = 20;
    // Maximum Batch size is 60 anyways
    public static final Integer NUM_ACCOUNTS = 150;


    /**
     * Creating test data
     * 
     * Need (many!):
     * - Product2
     * - Account
     * - (SAP-Standard) Pricebook2
     * - Pricebook2
     * - PricebookEntry
     * 
     */
    @TestSetup
    public static void setupEnvironment() {
        List<Product2> prod2Insert = new List<Product2>();
        Product2 templateProduct = TestDataFactory.createProduct(Constants.RECORD_TYPE_NAME_PRODUCT);
        templateProduct.manufacturer__c = 'BIOTRONIK';
        templateProduct.product_type__c = Constants.PICKLIST_VALUE_PRODUCT_TYPE_CRT_D;
        templateProduct.IsActive = true;
        Product2 cloneProd;
        for (Integer i = 0; i < NUM_PRODUCTS; i++) {
            cloneProd = templateProduct.clone();
            cloneProd.Name = 'TestProduct_' + i;
            cloneProd.sap_model_no__c = '' + i;
            prod2Insert.add(cloneProd);
        }
        insert prod2Insert;

        List<PricebookEntry> pbes2Insert = new List<PricebookEntry>();
        Id pbId = Test.getStandardPricebookId();
        for (Product2 currProd : prod2Insert) {
            pbes2Insert.add (
                    new PricebookEntry (
                            Product2Id = currProd.Id,
                            Pricebook2Id = pbId,
                            isActive = True,
                            CurrencyIsoCode = 'USD',
                            UnitPrice = 0,
                            external_id__c = '5500__Test_' + currProd.Id
                    )
            );
        }

        insert pbes2Insert;
        pbes2Insert = new List<PricebookEntry>();

        List<Pricebook2> pbs = new List<Pricebook2>();

        Pricebook2 crmPB = new Pricebook2(
                isActive = true,
                currency__c = 'USD',
                Name = '5500' + Constants.STANDARD_PRICEBOOKS_NAMING_SUBSTRING + 'CRM',
                last_update__c = DateTime.now()
        );
        pbs.add(crmPB);

        Pricebook2 cviPB = new Pricebook2(
                isActive = true,
                currency__c = 'USD',
                Name = '5500' + Constants.STANDARD_PRICEBOOKS_NAMING_SUBSTRING + 'CVI',
                last_update__c = DateTime.now()
        );
        pbs.add(cviPB);

        Pricebook2 pviPB = new Pricebook2(
                isActive = true,
                currency__c = 'USD',
                Name = '5500' + Constants.STANDARD_PRICEBOOKS_NAMING_SUBSTRING + 'PVI',
                last_update__c = DateTime.now()
        );
        pbs.add(pviPB);

        insert pbs;

        pbId = crmPB.Id;
        Integer counter = 0;
        for (Product2 currProd : prod2Insert) {
            if (counter >= OFFSET_CRM) {
                pbes2Insert.add (
                        new PricebookEntry (
                                Product2Id = currProd.Id,
                                Pricebook2Id = pbId,
                                isActive = True,
                                sap_company_code__c = '5500',
                                CurrencyIsoCode = 'USD',
                                UnitPrice = 0,
                                UseStandardPrice = true
                        )
                );
            }
            counter++;
            if (counter >= (OFFSET_CRM + NUM_CRM_ENTRIES)) break;
        }

        pbId = cviPB.Id;
        counter = 0;
        for (Product2 currProd : prod2Insert) {
            if (counter >= OFFSET_CVI) {
                pbes2Insert.add (
                        new PricebookEntry (
                                Product2Id = currProd.Id,
                                Pricebook2Id = pbId,
                                isActive = True,
                                sap_company_code__c = '5500',
                                CurrencyIsoCode = 'USD',
                                UnitPrice = 0,
                                UseStandardPrice = true
                        )
                );
            }
            counter++;
            if (counter >= (OFFSET_CVI + NUM_CVI_ENTRIES)) break;
        }

        pbId = pviPB.Id;
        counter = 0;
        for (Product2 currProd : prod2Insert) {
            if (counter >= OFFSET_PVI) {
                pbes2Insert.add (
                        new PricebookEntry (
                                Product2Id = currProd.Id,
                                Pricebook2Id = pbId,
                                isActive = True,
                                sap_company_code__c = '5500',
                                CurrencyIsoCode = 'USD',
                                UnitPrice = 0,
                                UseStandardPrice = true
                        )
                );
            }
            counter++;
            if (counter >= (OFFSET_PVI + NUM_PVI_ENTRIES)) break;
        }

        insert pbes2Insert;

        List<Pricebook2> pricebook2s = new List<Pricebook2>();

        Pricebook2 crm = new Pricebook2(
                isActive = true,
                currency__c = 'USD',
                Name = '5500_CRM'
        );
        pricebook2s.add(crm);

        Pricebook2 cvi = new Pricebook2(
                isActive = true,
                currency__c = 'USD',
                Name = '5500_CVI'
        );
        pricebook2s.add(cvi);

        Pricebook2 pvi = new Pricebook2(
                IsActive = true,
                currency__c = 'USD',
                Name = '5500_PVI'
        );
        pricebook2s.add(pvi);

        insert pricebook2s;

        List<Account> accs2Insert = new List<Account>();
        Account templateAccount = TestDataFactory.createAccount();
        templateAccount.crm_pricebook__c = crm.Id;
        templateAccount.cvi_pricebook__c = cvi.Id;
        templateAccount.pvi_pricebook__c = pvi.Id;

        for (Integer i = 0; i < NUM_ACCOUNTS; i++) {
            Account aClone = templateAccount.clone();
            aClone.Name = 'TestAccount_' + i;
            aClone.sap_no__c = 'sap_no_' + i;
            accs2Insert.add(aClone);

            if (accs2Insert.size () > 9000) {
                insert accs2Insert;
                accs2Insert = new List<Account>();
            }

        }

        insert accs2Insert;

    }

    /**
     * Testing the synching for products
     */
    @IsTest
    public static void testProductTypeSyncing() {
        Test.startTest();
        Batch_PricebookEntryDummies pbeDummies = new Batch_PricebookEntryDummies();
        Database.executeBatch(pbeDummies);
        Test.stopTest();

        String accName = 'TestAccount_15';
        Account acc = [SELECT Id, crm_pricebook__c, cvi_pricebook__c, pvi_pricebook__c FROM Account WHERE Name = :accName];
        Integer entryCountCRM = [SELECT COUNT() FROM PricebookEntry WHERE Pricebook2Id = :acc.crm_pricebook__c AND dummy__c = TRUE];
        System.assertEquals(NUM_CRM_ENTRIES, entryCountCRM);

        accName = 'TestAccount_35';
        acc = [SELECT Id, crm_pricebook__c, cvi_pricebook__c, pvi_pricebook__c FROM Account WHERE Name = :accName];
        Integer entryCountCVI = [SELECT COUNT() FROM PricebookEntry WHERE Pricebook2Id = :acc.cvi_pricebook__c AND dummy__c = TRUE];
        System.assertEquals(NUM_CVI_ENTRIES, entryCountCVI);

        accName = 'TestAccount_45';
        acc = [SELECT Id, crm_pricebook__c, cvi_pricebook__c, pvi_pricebook__c FROM Account WHERE Name = :accName];
        Integer entryCountPVI = [SELECT COUNT() FROM PricebookEntry WHERE Pricebook2Id = :acc.pvi_pricebook__c AND dummy__c = TRUE];
        System.assertEquals(NUM_PVI_ENTRIES, entryCountPVI);

    }

    /**
     * Testing the error mail on syncing fail
     */
    @IsTest
    public static void testProductTypeSyncingCheckSchedulable() {

        Batch_PricebookEntryDummies pbeDummies = new Batch_PricebookEntryDummies();
        Id pbeDummiesBatchJob;

        Test.startTest();
        pbeDummiesBatchJob = Database.executeBatch(pbeDummies);

        Test.stopTest();

        //Cron trigger is allrady removed
        List<CronTrigger> cronTriggers = [SELECT Id, CronJobDetail.Id, CronJobDetail.Name, CronJobDetail.JobType FROM CronTrigger WHERE CronJobDetail.Name LIKE '%Check Job%'];
        System.assertEquals(0,cronTriggers.size());

        //but run flag should have been set
        System.assertEquals(PriceBookDummiesCheckBatchSchedule.state, 'run');

    }

}