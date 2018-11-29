/* Created by Florian Heer <f.heer@conciscon.de>
 * 
 */ 

public without sharing class SystemPricingController  {
    // Define which fields can be used for rule matching
    //public static final String PRODUCT_FIELDS_TO_QUERY = 'Name,product_type__c';
    ApexPages.StandardController stdController;
    
	List<SystemPricing_SystemRuleBucket> mainBuckets = new List<SystemPricing_SystemRuleBucket>();	
    Set<Id> relatedProducts = new Set<Id>();
    public Id ourOrder;
    private Id systemAssetRTId;
    transient public  String selectedSystemId {get; set; }
    
    public SystemPricingController (ApexPages.StandardController stdController) {
        // Checking Pre-Conditions
/*
         If (!(Schema.SObjectType.Asset.isCreateable() 
              && Schema.SObjectType.OrderItem.isCreateable()
              && Schema.SObjectType.Asset.isDeletable())) {
			throw new SystemPricingException('You do not have sufficient rights on Asset or OrderItem to perform this function. Please contact your Salesforce administrator.');
              }
*/
ourOrder = ApexPages.currentPage().getParameters().get('id');
        this.stdController = stdController;
        systemAssetRTId = Utility.getRecordTypeId(Asset.SObjectType,Constants.RECORD_TYPE_NAME_ASSET_SYSTEM);
        processOrderInformation(ourOrder);
    }
    
    public void processOrderInformation (Id orderId) {
        // Determine the Pricebook
        List<Order> pricebooks = [SELECT Contract.Pricebook2Id, Pricebook2Id, CurrencyIsoCode FROM Order WHERE Id = :orderId LIMIT 1];
        Id pricebookId;
        if(pricebooks.size() == 1) {
            pricebookId = pricebooks[0].Pricebook2Id;
            if(pricebookId == null) {
                pricebookId = pricebooks[0].Contract.Pricebook2Id;
            }
            if(pricebookId == null) {
                throw new SystemPricingException('Cannot execute. Missing a linked price book.');
            }
        }
        else {
            throw new SystemPricingException('Cannot execute. Missing a linked price book.');
        }
        // Okay, basic setup seems to work.
        
  		// Read all products on this order.
		List<SystemPricing_ProductHolder> allLinkedProducts = SystemPricingController_Helper.readAllProducts(orderId, relatedProducts);

        
        // Read all applicable rules and fill the mainBuckets list.
        SystemPricingController_Helper.populateRuleBuckets(mainBuckets, relatedProducts, pricebookId, pricebooks[0].CurrencyIsoCode);
        If(mainBuckets.size() == 0) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.FATAL, 'No System rules found!'));
        }
        
        // Now try and match the products
        // There can be more than one possible system
        for (SystemPricing_SystemRuleBucket currBucket : mainBuckets) {
            for(SystemPricing_ProductHolder curr : allLinkedProducts) {
				currBucket.checkAndAddProduct(curr);                
            }

            // The SystemRuleBucket should have been filled now (if applicable)
            // So we clean out the excessive amounts. 
			currBucket.removeExcess();
        }
    }

    public List<SystemPricing_SystemRuleBucket> getMatchedSystems() {
        System.debug('getMatchedSystems - ' + mainBuckets.size());
        List<SystemPricing_SystemRuleBucket> filledBuckets = new List<SystemPricing_SystemRuleBucket>();
        for(SystemPricing_SystemRuleBucket bucket : mainBuckets) {
            if(bucket.getNumberOfMatchedProducts() > 0) {
                filledBuckets.add(bucket);
            }
        }
        return filledBuckets;
    }
    
    public String getCurrency() {
        return SystemPricingController.getCurrencySymbol(stdController.getRecord());
    }
    
    public PageReference selectSystem() {
        // TODO: Correctly implement post-processing
		selectedSystemId = System.currentPageReference().getParameters().get('sysId');
        System.debug('Syspri: selected System Id : ' + selectedSystemId);
        
        SystemPricing_SystemRuleBucket selectedBucket = null;
        for(SystemPricing_SystemRuleBucket bucket : mainBuckets) {
            if(bucket.getRule().Id == selectedSystemId) {
                selectedBucket = bucket;
            }
        }
        
        OrderItem systemOrderItem;
        
        if(selectedBucket != null)
            // && Schema.SObjectType.Asset.isCreateable() && Schema.SObjectType.OrderItem.isCreateable()) 
            {
            Order ord = (Order)stdController.getRecord();
            Order o = [SELECT Id, AccountId FROM Order WHERE Id = :ord.Id];
			
            //Added by Sumit || SAFBIO-1951
            Product2 selectedProd = [SELECT id, ProductCode, sap_model_no__c, product_type__c, manufacturer__c FROM Product2 where id =: selectedBucket.getRule().system_product__c];    
            // FIXME! manufacturer is hard-coded at the moment.
            systemOrderItem = new OrderItem(OrderId = o.id, Product2Id = selectedBucket.getRule().system_product__c, UnitPrice = selectedBucket.systemPrice,
                                           Quantity = 1, PricebookEntryId = selectedBucket.thePricebookEntry.Id, 
                                           //date_of_manufacture__c = Date.today(), expiration_date_ubd__c = Date.today().addDays(356), //Commented by Sumit || SAFBIO-1951
                                           product_type__c = selectedProd.product_type__c, product_code__c = selectedProd.ProductCode, 
                                           model_no__c = selectedProd.sap_model_no__c);
/*            systemOrderItem = new OrderItem(name = selectedBucket.systemName, order__c = o.id, 
                                          Product2Id = selectedBucket.getRule().system_product__c, sap_price__c = selectedBucket.systemPrice, 
                                          AccountId = o.AccountId, Status='Implanted', manufacturer__c = 'Biotronik');
*/
            insert systemOrderItem;
            
            systemOrderItem = [SELECT OrderId, Product2Id, UnitPrice, Quantity, PricebookEntryId, Product2.Name FROM OrderItem WHERE Id = :systemOrderItem.Id];
            
            Asset systemAsset = new Asset (order_product__c = systemOrderItem.Id, Product2Id = selectedBucket.getRule().system_product__c, 
                                           Name = systemOrderItem.Product2.Name, AccountId = o.AccountId, RecordTypeId = systemAssetRTId
                                          );
            
            insert systemAsset;
            
            List<OrderItem> orderItems = new List<OrderItem>();
            // First, get the OrderItem for the driving product (PM, ICD ...)
            OrderItem drivingOI = [SELECT Id, ParentId__c, part_of_system_price__c, ListPrice, UnitPrice FROM OrderItem 
                                   WHERE Product2Id = :selectedBucket.getRule().product__c 
                                   AND OrderId = :o.Id
                                   LIMIT 1];

            drivingOI.ParentId__c = systemOrderItem.Id;
            drivingOI.part_of_system_price__c = true;
            drivingOI.UnitPrice = 0;
            orderItems.add(drivingOI);
            
            for(SystemPricing_ProductHolder ph : selectedBucket.getMatchedProducts()) {
                ph.anOrderItem.ParentId__c = systemOrderItem.Id;
                ph.anOrderItem.part_of_system_price__c = true;
                ph.anOrderItem.UnitPrice = 0;
                orderItems.add(ph.anOrderItem);
            }
            System.debug('Syspri: collected ' + orderItems.size() + ' assets to update.');
            update orderItems;
            
            List<Asset> componentAssets = [SELECT Id, ParentId FROM Asset WHERE order_product__c IN :orderItems];
            for (Asset ass:componentAssets) {
                ass.ParentId = systemAsset.Id;
            }
            update componentAssets;
            
            
            /*PageReference orderItemPage = new ApexPages.StandardController(systemOrderItem).view();
            orderItemPage.setRedirect(true);
            return orderItemPage;*/
                
            // SAFBIO-1948 - after applying system price, user will be taken back to the order not to the order Item 
            PageReference orderPage = new ApexPages.StandardController(stdController.getRecord()).view();
    		orderPage.setRedirect(true);
    		return orderPage;

        }
        else ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.FATAL, 'No System selected?!'));
        return null;
    }

    public PageReference cancelSystem () {
        PageReference orderPage = new ApexPages.StandardController(stdController.getRecord()).view();
    	orderPage.setRedirect(true);
    	return orderPage;

    }    
    
    public static String getCurrencyIsoCode(SObject someObject){
        // TODO: fix this
        // String currencyIso = UserInfo.isMultiCurrencyOrganization() ? (String) someObject.get('CurrencyIsoCode') : UserInfo.getDefaultCurrency();
        String currencyIso = UserInfo.getDefaultCurrency();
        return currencyIso;
    }

    public static String getCurrencySymbol(SObject someObject) {
        return getCurrencySymbolFromIso(getCurrencyIsoCode(someObject));
    }

    public static String getCurrencySymbolFromIso(String Iso) {
         String currencySymbol = 
           ('USD' == Iso ? '$' : 
           ('CAD' == Iso ? '$' : 
           ('EUR' == Iso ? '€' : 
           ('GBP' == Iso ? '£' : 
           ('JPY' == Iso ? '¥' : 
           ('KRW' == Iso ? '₩' : 
           ('CNY' == Iso ? '元' : 
           Iso)))))));
           return currencySymbol;
    }
    
    
    public class SystemPricingException extends Exception {}
    
}