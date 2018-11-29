public without sharing class SystemPricingController_Helper {
    
    /* Retrieves a comma-separated list of fields that we might need to match to.
     * The result is used in the SOQL querying Product2
     */
    public static String getRuleFieldValuesForSOQL () {
        List<String> fieldValues = new List<String>();
        Schema.DescribeFieldResult fieldResult = System_Rule__c.rule_field__c.getDescribe();
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
        for( Schema.PicklistEntry f : ple) {
            fieldValues.add(f.getValue());
        }
        String resultString = String.join(fieldValues, ', ');
        return resultString;
    }
    
    /* Reads all OrderItems and their products related to the given Order.
     * @param orderId the Id of the current Order object
     * @param relatedProducts is used to store / return a unique list of all Product2-records that are related to the current Order
     * @return a List of SystemPricing_ProductHolder objects representing a combination of the OrderItems and their related Products
     */
    public static List<SystemPricing_ProductHolder> readAllProducts(Id orderId, Set<Id> relatedProducts) {
        List<SystemPricing_ProductHolder> pHolder = new List<SystemPricing_ProductHolder>();
        List<Asset> linkedImplantedAssets = [SELECT Id, order_product__r.Id FROM Asset WHERE Status = 'Implanted' 
                                             AND order_product__r.OrderId = :orderId AND stock_type__c <> 'B'];
        List<Id> oiIds = new List<Id>();
        for(Asset lia : linkedImplantedAssets) {
            oiIds.add(lia.order_product__r.Id);
        }
        // Probably the condition on the order is useless....
        List<OrderItem> linkedOIs = [SELECT Id, Product2Id, ListPrice, Product2.Name FROM OrderItem WHERE OrderId = :orderId AND Id IN :oiIds];
        System.debug('Syspri: found ' + LinkedOIs.size() + ' linked OrderItems for Order ' + orderId);
        
        
        String additionalProductFields = SystemPricingController_Helper.getRuleFieldValuesForSOQL();
        //FIXME Brute force and ignorance...
        //TODO: define what fields are necessary from product...
        for(OrderItem oi : linkedOIs) {
            if(oi.Product2Id != null) {
                String soql = 'SELECT Id,' + additionalProductFields + ' FROM Product2 WHERE Id = \'' + oi.Product2Id + '\' LIMIT 1';
                System.debug ('Syspri: SOQL = ' + soql);
                Product2 prod = (Product2)Database.query(soql);
                System.debug('Syspri: product for OrderItem ' + oi.Id + ': ' + prod);
                
                pHolder.add(new SystemPricing_ProductHolder(prod,oi));
                relatedProducts.add(prod.Id);
            }
            else {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.WARNING, 'The included product "' + oi.product2.Name + '" is not linked to a Product2-record. Cannot be considered.'));
            }
        }
        
        // TODO: read further related products from Order, not only the assets.
        // Question: is there a real need to have Products? Check if CM is actually part of a system in terms of matching.
        
        return pHolder;
            
    }
    
    /* Builds a bucket for matching.
     * @param theRule the rule according to which this bucket should accept products/assets
     * @param parentBucket in parallel to the rule-structure, a bucket can be below another
     * @param unitPrice stores the price of the resulting system. Only necessary and sensible when the top-level bucket is created
     * @param systemName stores the name of the resulting system. Only sensible on top level.
     * @param pricebook stores the pricebook. Only sensible on top level.
     */
    public static SystemPricing_SystemRuleBucket createRuleBucket (system_rule__c theRule, SystemPricing_SystemRuleBucket parentBucket, Decimal unitPrice, String systemName,
                                                                  PricebookEntry pricebookEntry) {
        SystemPricing_SystemRuleBucket myBucket = null;
        if(parentBucket != null) {
        	myBucket = new SystemPricing_SystemRuleBucket(theRule, parentBucket);
        }
        else {
            myBucket = new SystemPricing_SystemRuleBucket(theRule, unitPrice, systemName, pricebookEntry);
        }
        
        if(theRule.no_subrules__c > 0) {
            List<system_rule__c> subRules = [SELECT Id, max_quantity__c, no_subrules__c, parent_rule__c, product__c, 
                                          rule_field__c, rule_type__c, rule_value__c, system_product__c, name__c 
                                          FROM system_rule__c WHERE parent_rule__c = :theRule.Id];
            for (system_rule__c curr : subRules) {
                SystemPricing_SystemRuleBucket bucket = createRuleBucket (curr, myBucket, 0, null, null);
            }
        }
        return myBucket;
    }
    
    /* Fills the list mainBuckets with hierarchical rule buckets. Rules are read in relation to realtedProducts.
     * @param mainBuckets stores the resulting top-level rule buckets.
     * @param relatedProducts contains the products which may be linked to a rule
     * @param pricebookId contains the pricebook that shall be used for determining system prices
     * @param currencyIsoCode String representation of a currency used on the order.
     */    
    public static void populateRuleBuckets(List<SystemPricing_SystemRuleBucket> mainBuckets, Set<Id> relatedProducts, Id pricebookId,
                                          String currencyIsoCode) {
        System.debug('Related Products: ');
        for(Id prodId : relatedProducts) {
            System.debug(prodId);
        }
        List<System_Rule__c> mainRules = [SELECT Id, max_quantity__c, no_subrules__c, parent_rule__c, product__c, 
                                          rule_field__c, rule_type__c, rule_value__c, system_product__c, name__c,
                                          system_product__r.Name
                                          FROM System_Rule__c WHERE product__c IN :relatedProducts];
        
        for (System_Rule__c curr : mainRules) {
            System.debug('Syspri: PricebookEntry = ' + curr.system_product__c + ' pricebookId = ' + pricebookId + ' Currency = ' + currencyIsoCode);
            // TODO! Currencies!
            List<PricebookEntry> pbes = [SELECT id, UnitPrice FROM PricebookEntry WHERE Product2Id = :curr.system_product__c 
                                         AND Pricebook2Id = :pricebookId AND CurrencyIsoCode = :currencyIsoCode];
            if(pbes.size() > 0) {
                PricebookEntry pbe = pbes[0];
                SystemPricing_SystemRuleBucket bucket = SystemPricingController_Helper.createRuleBucket (curr, (SystemPricing_SystemRuleBucket)null, pbe.UnitPrice, curr.system_product__r.Name, pbe);
                mainBuckets.add (bucket);
            }
            else {
                // Florian Heer <f.heer@conciscon.de> 2018-07-20 SAFBIO-1684
				// Wrong assumption. Not all system products must be in all pricebooks. We ignore rules where we can't find the price for 
                // the system product.
                // 
                // throw new SystemPricingController_HelperException('Cannot find the price for the system product (prod: ' 
                //                                                   + curr.system_product__c + ', pricebook: ' + pricebookId + ' Currency: ' + currencyIsoCode);

            }
        }
    }
    
    /** Resets all system information on an order, if any
     * Checks all OrderItems. If a system had been chosen
     * - Remove System-OrderItem
     * - Remove associated System-Asset
     * - Remove Parent-Linkage in OrderItems and Assets
     * - Reset all prices to list prices
     * - Remove Part Of System Price checkbox
     * 
     * @param orderId Id of the Order to be processed.
     */    
    public static Boolean resetPossibleSystem(Id ourOrderId) {
    	// Read all related OrderItems
    	List<OrderItem> allRelatedOI = [SELECT Id, ListPrice, UnitPrice, part_of_system_price__c, parentid__c FROM OrderItem WHERE OrderId = :ourOrderId];
        Id systemId;
        List<OrderItem> oi2Update = new List<OrderItem>();
        List<Asset> ass2Update = new List<Asset>();
        List<OrderItem> oi2Delete = new List<OrderItem>();
        List<Asset> ass2Delete = new List<Asset>();
        

        for(OrderItem currOI : allRelatedOI) {
            System.debug('syspr - related UnitPrice: ' + currOI.UnitPrice + ' ListPrice: ' + currOI.ListPrice + ' part_of_system: ' 
                         + currOI.part_of_system_price__c + ' parentid__c: ' + currOI.parentid__c + ' OverAllSystemId: ' + systemId);
            if(currOI.ListPrice != currOI.UnitPrice) {
                currOI.UnitPrice = currOI.ListPrice;
                oi2Update.add(currOI);
            }
            if(currOI.part_of_system_price__c == true) {
                currOI.part_of_system_price__c = false;
              	oi2Update.add(currOI);  
            }
            
            if(currOI.parentid__c != null) {
                systemId = currOI.parentid__c;
                currOI.parentid__c = null;
                oi2Update.add(currOI);  
            }
        }
        
        if(systemId != null) {
            oi2Delete.addAll([SELECT Id FROM OrderItem WHERE Id = :systemId]);
            ass2Delete.addAll([SELECT Id FROM Asset WHERE order_product__c = :systemId]);
            ass2Update.addAll([SELECT Id, ParentId FROM Asset WHERE order_product__c IN :oi2Update]);
            for(Asset ass : ass2Update) {
                ass.ParentId = null;
            }
            
            if(oi2Update.size() > 0) {
                oi2Update = (List<OrderItem>)uniquifyList(oi2Update);
                update oi2Update;
            }
            if(ass2Update.size() > 0) {
                ass2Update = (List<Asset>)uniquifyList(ass2Update);
                update ass2Update;
            }
            if(ass2Delete.size() > 0) {
                ass2Delete = (List<Asset>)uniquifyList(ass2Delete);
                delete ass2Delete;
            }
            if(oi2Delete.size() > 0) {
                oi2Delete = (List<OrderItem>)uniquifyList(oi2Delete);
                delete oi2Delete;
            }
            return true;
        }
        return false;
    }
    
    public static List<SObject> uniquifyList (List<SObject> orig) {
        Set<SObject> theSet = new Set<SObject>();
        theSet.addAll(orig);
        List<SObject> retVal = new List<SObject>();
        retVal.addAll(theSet);
        return retVal;
    }

    public class SystemPricingController_HelperException extends Exception {}

}