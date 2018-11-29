/**
 * Tests synchronizing product type information from a Product2 record to a ProductItem,
 * as provided by Batch_ProductTypeSynch
 * 
 * SAFBIO-1331
 * 
 * @author         f.heer
 * @modifiedBy     ilu_pkas (comments)
 * @created        2018-06-25
 * @modified       2018-08-30
 * @systemLayer    Test 
 *  
*/

@isTest
public class Batch_ProductTypeSynch_Test {
    public static final String PREFIX_TEST_NAMES = 'b_pts_';
    
    /**
     * Creating test data
     * 
     * Need:
     * - Product2
     * - ProductItem
     * 
     * - Check all product_types on both - ensure picklist-validity
     */
    @TestSetup
    public static void setupEnvironment() {
        List<Product2> prods2Insert = new List<Product2> ();
        Schema.DescribeFieldResult fieldResult = Product2.product_type__c.getDescribe();
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues(); 
        for (PicklistEntry pe : ple) {
            System.debug('Product2.product_type__c: label: ' + pe.getLabel() + ', value: ' + pe.getValue());
            prods2Insert.add(new Product2(name = PREFIX_TEST_NAMES + pe.getValue(), product_type__c = pe.getValue()));
        }
        insert prods2Insert;

        String searchText = PREFIX_TEST_NAMES + '%';
        List<Product2> prodsInDB = [SELECT Id, Name, product_type__c FROM Product2 WHERE Name LIKE :searchText];
        Map<String, Product2> type2Product = new Map<String, Product2>();
        for (Product2 prod : prodsInDB) {
            type2Product.put(prod.product_type__c, prod);
        }
        
        Schema.Location loc = new Schema.Location(Name = PREFIX_TEST_NAMES + 'Location', IsInventoryLocation = true);
        insert loc;
        
        List<ProductItem> pis2Insert = new List<ProductItem>();
        Schema.DescribeFieldResult fieldResultPI = ProductItem.product_type__c.getDescribe();
        List<Schema.PicklistEntry> plePI = fieldResultPI.getPicklistValues(); 
        for (PicklistEntry pe : plePI) {
            Product2 refProd = type2Product.get(pe.getValue());
            if(refProd == null) {
                throw new Batch_ProductTypeSynch.Batch_ProductTypeSynchException('Cannot find Product for product_type__c: "' + pe.getValue() + '"');
            }
            pis2Insert.add(new ProductItem(Product2Id = refProd.Id, QuantityOnHand = 1.0,
                                          LocationId = loc.Id));
        }
        insert pis2Insert;
    }
    
    /**
     * Testing the synching for products
     */
    @isTest
    public static void testProductTypeSynching() {
        Test.startTest();
            Batch_ProductTypeSynch prodTypeSynch = new Batch_ProductTypeSynch();
            DataBase.executeBatch(prodTypeSynch); 
        Test.stopTest();
        
        String search = PREFIX_TEST_NAMES + '%';
        List<ProductItem> pis = [SELECT Id, product_type__c, Product2.product_type__c FROM ProductItem WHERE Product2.Name LIKE :search];
        
        for(ProductItem pi : pis) {
            System.assertEquals(pi.Product2.product_type__c, pi.product_type__c);
        }
    }
    
    /**
     * Providing coverage for the salesforce.com scheduel function.
     * 	No asserts needed since this is a salesforce functionality
     */
    @isTest
    private static void testScheduel(){
        Test.startTest();
            Batch_ProductTypeSynch myClass = new Batch_ProductTypeSynch();   
            String chron = '0 0 23 * * ?';        
            System.schedule('Test Sched', chron, myClass);
        Test.stopTest();
    }
}