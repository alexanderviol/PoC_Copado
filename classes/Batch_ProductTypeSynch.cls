/**
 *
 * This batch job checks if the product item has a product type and if not, 
 * 		it'll pull the information from the related product if possible
 * 
 * @author         ilu_pkas 
 * @modifiedBy     ilu_pkas
 * @created        2018-MM-DD
 * @modified       2018-08-29
 * @systemLayer    Batch 
 *  
*/
global class Batch_ProductTypeSynch implements Database.Batchable<sObject>, Schedulable {
    
    global Batch_ProductTypeSynch (){ }
    
    /**
     * Selects all product items without a product type, if the related product has a product type
     * 
     * @return a iterable that contains the product item records passed to the job
     */
    global Database.QueryLocator start(Database.BatchableContext BC){
        return Database.getQueryLocator('SELECT Id, product_type__c, Product2.product_type__c FROM ProductItem WHERE product_type__c = null AND Product2.product_type__c != null');
    }
    
    /**
     * Copies the product type from the related product to the product item.
     * 
     * @param	scope, a list with all product items, where the product type needs to be set
     */
    global void execute(Database.BatchableContext BC, List<sObject>scope){
        List<ProductItem> pis = (List<ProductItem>) scope;
        for(ProductItem pi : pis) {
            pi.product_type__c = pi.Product2.product_type__c;
        }
        update pis;
    }
    
    global void finish(Database.BatchableContext BC){ }

    public class Batch_ProductTypeSynchException extends Exception { }
    
	global void execute(SchedulableContext SC) {
    	Database.executeBatch(new Batch_ProductTypeSynch()); 
   	}
}