/* Created 2018-09-24 Florian Heer <f.heer@conciscon.de>
 * Tests ProductItemHandler
 */
@isTest
public class ProductItemHandler_Test {
	/* We need
	 * - Product
	 * - ProductItem
	 * - Location
	 * - WorkOrder
	 */
    
    @isTest
    public static void testProductItemRaiseOfQuantity () {
        Schema.Location myLoc = TestDataFactory.createLocation ('locsName');
        myLoc.IsInventoryLocation = true;
        insert myLoc;
        Product2 myProduct = TestDataFactory.createProduct(Constants.RECORD_TYPE_NAME_PRODUCT);
        myProduct.serialized_item__c = true;
        insert myProduct;
        ProductItem myPI = TestDataFactory.createProductItem(myProduct.Id, myLoc.Id, 'biotronik_product');
        myPI.QuantityOnHand = 1;
        insert myPI;
        
        Test.startTest();
        ProductItem testPI = [SELECT Id, QuantityOnHand FROM ProductItem WHERE Id = :myPI.Id];
        System.assertEquals(1, testPI.QuantityOnHand);
        
        // Without a ProductConsumed, all changes should be accepted.
        testPI.QuantityOnHand = 0;
        update testPI;
        testPI = [SELECT Id, QuantityOnHand FROM ProductItem WHERE Id = :myPI.Id];
        System.assertEquals(0, testPI.QuantityOnHand);
        testPI.QuantityOnHand = 2;
        update testPI;
        
        testPI = [SELECT Id, QuantityOnHand FROM ProductItem WHERE Id = :myPI.Id];
        System.assertEquals(2, testPI.QuantityOnHand);
        
        // Let's add a ProductConsumed
        WorkOrder wo = TestDataFactory.createWorkOrder();
        insert wo;
        ProductConsumed myPC = TestDataFactory.createProductConsumed(myPI.Id, wo.Id, 2);
        insert myPC;

        // We have consumed all that is there
        testPI = [SELECT Id, QuantityOnHand FROM ProductItem WHERE Id = :myPI.Id];
        System.assertEquals(0, testPI.QuantityOnHand);
        
        testPI.QuantityOnHand = 2;
        update testPI;
        // The system should not have accepted the raise of the quantity.
        testPI = [SELECT Id, QuantityOnHand FROM ProductItem WHERE Id = :myPI.Id];
        System.assertEquals(0, testPI.QuantityOnHand);
        
        myProduct.serialized_item__c = false;
        update myProduct;
        
        testPI.QuantityOnHand = 2;
        update testPI;
        // The system should now have accepted the raise of the quantity.
        testPI = [SELECT Id, QuantityOnHand FROM ProductItem WHERE Id = :myPI.Id];
        System.assertEquals(2, testPI.QuantityOnHand);
        
    }
    
}