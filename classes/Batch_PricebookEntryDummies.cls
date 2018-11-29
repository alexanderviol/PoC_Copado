/** Creates dummy entries for all products defined in their parent 'Standard' Pricebook.
 *
 * 
 * @author      Florian Heer <f.heer@conciscon.de>
 * @modified    arwe
 * @created     2018-10-03
 * @systemLayer Batch 
 *  
*/

global class Batch_PricebookEntryDummies implements Database.Batchable<SObject>, Database.Stateful, Schedulable {

    private static List<String> PRICEBOOK_FIELDS = Constants.PRICEBOOK_FIELDS_ON_ACCOUNT.split(',');

    // members that will live the hole batch execution
    private List<Pricebook2> standardPBs;
    private String pricebookPattern;

    global Batch_PricebookEntryDummies() {
        // will be filled once
        pricebookPattern = '%' + Constants.STANDARD_PRICEBOOKS_NAMING_SUBSTRING + '%';
        standardPBs = [SELECT Id, last_update__c, Name FROM Pricebook2 WHERE Name LIKE :pricebookPattern];
    }

    /** Selects all accounts whose pricebooks have not been processed yet.
     * The selections compares the last update of the 'standard' pricebooks and the marker field
     * on the accounts.
     */
    global Database.QueryLocator start(Database.BatchableContext BC) {

        Datetime newestUpdate = null;
        for (Pricebook2 pb : standardPBs) {
            if (newestUpdate == null || newestUpdate < pb.last_update__c) {
                newestUpdate = pb.last_update__c;
            }
        }

        if (newestUpdate == null) {
            newestUpdate = Datetime.newInstance(1950, 1, 1, 1, 1, 1);
        }

        String updateTime = newestUpdate.formatGmt('yyyy-MM-dd\'T\'HH:mm:ss.SSSZ');
        List<String> pricebookFields = new List <String> (Constants.ACCOUNT_FIELD_TO_PRICEBOOK_TYPE.keySet ());
        String soqlString = 'SELECT Id, sap_company_code__c, sap_no__c,' + Constants.PRICEBOOK_FIELDS_ON_ACCOUNT +
                ' FROM Account ' +
                ' WHERE (dummy_pb_update__c < ' + updateTime + ' OR dummy_pb_update__c = null) AND (';
        Boolean isFirst = true;
        for (String pbField : pricebookFields) {
            if (isFirst) {
                isFirst = false;
            } else {
                soqlString += ' OR ';
            }
            soqlString += pbField + ' <> null ';
        }
        soqlString += ')';
        System.debug('QueryLocator query: ' + soqlString);

        return Database.getQueryLocator(soqlString);
    }

    /** For all accounts, checks the pricebooks referred in the pricebook fields, and inserts missing dummy entries.
     * 
     * Assumptions: for any Account there are only Pricebook Entries in one Currency.
     */
    global void execute(Database.BatchableContext BC, List<Account> scope) {

        //create id Set of pricebook entries
        Set<Id> stdPricebookIdSet = new Map<Id, Pricebook2>(standardPBs).keySet();

        //get standard Pricebook entries
        Map<Id, List<PricebookEntry>> standardPBEntries = getPricebookEntriesMap(stdPricebookIdSet);

        Map<String, Pricebook2> standardPbMap = new Map<String, Pricebook2> ();

        for (Pricebook2 pb : standardPBs) {
            String pbSuffix = pb.Name.right(3);
            standardPbMap.put(pbSuffix, pb);
        }

        //first gather all existing Pricebook2Id from the fields that are in the scope
        Set<Id> pricebookIds = getPricebookIsByAccount(scope, PRICEBOOK_FIELDS);

        // then query the existing entries
        Map<Id, Set<Id>> pricebookEntryProductIds = getProductIdByPricebookEntriesByIds(pricebookIds);

        Set<String> allradyInInsertScope = new Set<String>();

        List<PricebookEntry> pbesToInsert = new List<PricebookEntry> ();

        // ... and then the changes can be done
        for (Account acc : scope) {

            for (String pbField : PRICEBOOK_FIELDS) {
                String pricebookId = (String) acc.get(pbField);
                if (pricebookId != null) {
                    String pbSuffix = Constants.ACCOUNT_FIELD_TO_PRICEBOOK_TYPE.get(pbField);
                    Pricebook2 stdPb = standardPbMap.get(pbSuffix);
                    Set<Id> existing = pricebookEntryProductIds.get(pricebookId);

                    List<PricebookEntry> neededProdEntries = standardPBEntries.get(stdPb.Id);

                    String pricebookName = neededProdEntries[0].Pricebook2.Name;

                    for (PricebookEntry needed : neededProdEntries) {
                        if ((existing == null || !existing.contains(needed.Product2Id)) && !allradyInInsertScope.contains(concatId(pricebookId, needed.Product2Id))) {
                            PricebookEntry newPricebookEntry = new PricebookEntry(
                                    Product2Id = needed.Product2Id,
                                    Pricebook2Id = pricebookId,
                                    IsActive = true,
                                    sap_company_code__c = acc.sap_company_code__c,
                                    CurrencyIsoCode = needed.CurrencyIsoCode,
                                    Division__c = needed.Division__c,  // ?
                                    dummy__c = true,
                                    external_id__c = acc.sap_no__c + '_' + pbSuffix + '_'+ acc.sap_company_code__c + '_' + needed.model_no__c,
                                    UnitPrice = needed.UnitPrice,
                                    // ProductCode = needed.ProductCode,  // Not writable?
                                    UseStandardPrice = false
                            );
                            pbesToInsert.add(newPricebookEntry);
                            allradyInInsertScope.add(concatId(newPricebookEntry.Pricebook2Id, newPricebookEntry.Product2Id));

                        }
                    }
                }
            }
            acc.dummy_pb_update__c = Datetime.now();
        }

        System.debug('PricebookEntry to Insert' + pbesToInsert);

        insert pbesToInsert;
        update scope;

        Utility.printLimits();

    }

    private static String concatId(Id firstId, Id secondId) {
        return firstId + '-' + secondId;

    }


    /**
     * method the get all pricebooks that are in field list
     *
     * @param accounts List of accounts
     * @param pricebookFields Lookup field Names as a List
     *
     * @return Set of pricebook Ids
     */
    private static Set<Id> getPricebookIsByAccount(List<Account> accounts, List<String> pricebookFields) {
        Set<Id> pricebookIds = new Set<Id>();

        for (Account acc : accounts) {
            for (String pbField : pricebookFields) {
                String pricebookId = (String) acc.get(pbField);
                if (pricebookId != null) {
                    pricebookIds.add(pricebookId);
                }
            }
        }
        return pricebookIds;
    }

    /**
     * method to build up a map with ProductIds as value Set and pricebookId as key
     *
     * @param pricebookIdSet  Set of pricebook Ids
     *
     * @return a map consists of pricebookIds as key and a Set of Pricebook2Id as value
     */
    private static Map<Id, Set<Id>> getProductIdByPricebookEntriesByIds(Set<Id> pricebookIdSet) {

        Map<Id, Set<Id>> pricebookEntryProductIds = new Map<Id, Set<Id>>();
        Map<Id, List<PricebookEntry>> pricebookEntries = getPricebookEntriesMap(pricebookIdSet);
        for (Id pricebookId : pricebookEntries.keySet()) {
            Set<Id> product2Ids = new Set<Id>();
            for (PricebookEntry pricebookEntry : pricebookEntries.get(pricebookId)) {
                product2Ids.add(pricebookEntry.Product2Id);
            }
            pricebookEntryProductIds.put(pricebookId, product2Ids);
        }
        return pricebookEntryProductIds;
    }

    /**
     *  to get all entries from Pricebooks in Map by pricebookId
     *
     * @param pricebookIdSet a Set of priceBookIds
     *
     * @return a map consists of pricebookIds as key and a List of PricebookEntries as value
     */
    private static Map<Id, List<PricebookEntry>> getPricebookEntriesMap(Set<Id> pricebookIdSet) {
        Map<Id, List<PricebookEntry>> pricebookEntries = new Map<Id, List<PricebookEntry>>();

        for (PricebookEntry pricebookEntry : [SELECT Product2Id, CurrencyIsoCode, UnitPrice, ProductCode, Division__c, Pricebook2Id, Pricebook2.Name, model_no__c FROM PricebookEntry WHERE Pricebook2Id IN :pricebookIdSet]) {
            if (!pricebookEntries.containsKey(pricebookEntry.Pricebook2Id)) {
                pricebookEntries.put(pricebookEntry.Pricebook2Id, new List<PricebookEntry>());
            }
            pricebookEntries.get(pricebookEntry.Pricebook2Id).add(pricebookEntry);
        }
        return pricebookEntries;
    }


    global void finish(Database.BatchableContext BC) {
        // because it is possible that job is not complete on finish and no future is allowed do a schedule to check if Job failed

        // Create new scheduled job in 5min
        Datetime dt = System.now().addMinutes(5);
        Integer minute = dt.minute();
        Integer hour = dt.hour();
        String cronExpression = '0 ' + minute + ' ' + hour + ' * * ?';
        System.schedule('Check Job ' + BC.getJobId(), cronExpression, new PriceBookDummiesCheckBatchSchedule(BC.getJobId()));
    }

    global void execute(SchedulableContext SC) {
        Integer batchSize = Integer.valueOf(Utility.getSettingValue('BATCH_PRICEBOOK_ENTRY_DUMMIES_BATCH_SIZE','1'));
        Database.executeBatch(new Batch_PricebookEntryDummies(), batchSize);
    }
}