/* Stores product and asset information for system pricing.
 * 
 */
public without sharing class SystemPricing_ProductHolder {
    public Product2 theProduct;
    public OrderItem anOrderItem;
    public String productName {get;set;}
    public SystemPricing_ProductHolder(Product2 prod) {
        if(prod == null) throw new ProductHolderException('Product is null');
        theProduct = prod;
        productName = theProduct.Name;
    }
    public SystemPricing_ProductHolder(Product2 prod, OrderItem oi) {
        if(prod == null) throw new ProductHolderException('Product is null');
        if(oi == null) throw new ProductHolderException('OrderItem is null');
        theProduct = prod;
        productName = theProduct.Name;
        anOrderItem = oi;
    }
    /* Delivers a property from the stored product entry.
     * Availability of the requested property needs to be guaranteed by the querying entity.
     */
    public Object getProdProp(String fieldName) {
        System.debug('Syspri: requested field name = \'' + fieldName + '\'');
        Object result = theProduct.get(fieldName);
        System.debug('Syspri: result = ' + result);
        return result;
    }
    
    public class ProductHolderException extends Exception {}
}