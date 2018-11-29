/* Stores virtually all information needed for system pricing.
 * Matches incoming products to its rules and stores or declines them.
 */
public without sharing class SystemPricing_SystemRuleBucket {
    private system_rule__c sysRule;
    
    @TestVisible
    private SystemPricing_SystemRuleBucket parBucket;
    
    public Decimal systemPrice {get;set;}
    public String systemName {get;set;}
    public PricebookEntry thePricebookEntry;
    
    // all products/assets that fit the system rule.
    private List<SystemPricing_ProductHolder> matchedProducts = new List<SystemPricing_ProductHolder>();
    // for easier access, parents and children know each other
    private List<SystemPricing_SystemRuleBucket> children = new List<SystemPricing_SystemRuleBucket>();
    
    /* Constructor for top-level bucket.
     * @param rule the rule for this bucket, adding products filters by this rule
     * @param sysPrice the price of the resulting system
     * @param sysName the name of the resulting system
     * @param pricebookEntry the pricebook entry that is used for the system.
     */
    public SystemPricing_SystemRuleBucket(system_rule__c rule, Decimal sysPrice, String sysName, PricebookEntry pricebookEntry) {
        if(rule.parent_rule__c == null) {
            sysRule = rule;
        }
        else {
            throw new SystemPricingBucketException('Cannot create SystemRuleBucket without parent bucket if the system rule has a parent.');
        }
        systemPrice = sysPrice;
        systemName = sysName;
        thePricebookEntry = pricebookEntry;
    }
    
    /* Constructor for lower level bucket.
     * @param rule the rule for this bucket, adding products filters by this rule
     * @param parentBucket the parent for this rule bucket.
     */
    public SystemPricing_SystemRuleBucket(system_rule__c rule, SystemPricing_SystemRuleBucket parentBucket) {
        if(rule.parent_rule__c != null) {
            sysRule = rule;
            parBucket = parentBucket;
            parBucket.addChild(this);
        }
        else {
            throw new SystemPricingBucketException('Cannot create SystemRuleBucket with parent bucket if the system rule does not have a parent.');
        }            
    }
    
    /* Convenience method.
     * @return the number of products/assets that matched this rule bucket.
     */
    public Integer getNumberOfMatchedProducts() {
        return matchedProducts.size();
    }
    
    /* Delivers a list of all products that match our criteria.
     * Most useful on the top-level bucket, as the reliable list will only be available there.
     */
    public List<SystemPricing_ProductHolder> getMatchedProducts() {
        return matchedProducts;
    }
    
    /*
     * Not used at the moment. Maybe later. If there were A LOT of possible fields to query in the picklist, this might help reduce loads.
     * 
    public Set<String> getProductFieldsInRules() {
        Set<String> prodFields = new Set<String>();
        prodFields.add(sysRule.rule_field__c);
        for (SystemPricing_SystemRuleBucket curr : children) {
            prodFields.addAll(curr.getProductFieldsInRules());
        }
        return prodFields;
    }
*/
    
    public system_rule__c getRule() {
        return sysRule;
    }
    public String getRuleName () {
        return sysRule.name__c;
    }
    
    /* If the product matches the System Rule, it will be added to the internal matching list. 
     * First we test if our rule fits, if so, ask any children. If there are children and
     * none of them accepts the product, we reject it. If there are no children and
     * we have a match, the product is accepted.
     * If there are child rules, the product will be propagated.
     * 
     * @return true if the product is matched and 'consumed'
     */
    public boolean checkAndAddProduct(SystemPricing_ProductHolder productToAdd) {
        Boolean productIsConsumed = false;
        
        String ruleField = sysRule.rule_field__c;
        String ruleValue = sysRule.rule_value__c;
        String prodFieldValue;
        if(ruleField != null && ruleField.length() != 0) {
            prodFieldValue = (String)productToAdd.getProdProp(sysRule.rule_field__c);
            // Shouldn't happen, but let's make sure we aren't surprised.
            if(prodFieldValue == null) {
                prodFieldValue = '';
            }
        }
        
        if(ruleField == null || ruleField.length() == 0 || (prodFieldValue != null && prodFieldValue.containsIgnoreCase(ruleValue))) {
            // So, we either just have a maximum count rule or the filter applies.
            // Let's ask the kids       
            if(children.size() > 0) {
                for(SystemPricing_SystemRuleBucket curr : children) {
                    productIsConsumed = curr.checkAndAddProduct(productToAdd);
                    if(productIsConsumed) {
                        // This rule matches, if also a child rule matches.
                        matchedProducts.add(productToAdd);
                        break;
                    }
                }
            }
            else {
                productIsConsumed = true;
                matchedProducts.add(productToAdd);
            }
        }

        return productIsConsumed;
    }

    private void addChild(SystemPricing_SystemRuleBucket child) {
        children.add(child);
    }
    
    /* Checks if the maximum number of accessories (leads) has been exceeded in this or any child bucket.
     */
    public Boolean areThereExcessiveNumbersOfProducts() {
        Decimal maximumQuantity = sysRule.max_quantity__c;
        Boolean foundExcess = false;
        
        if(maximumQuantity != 0) {
            foundExcess = matchedProducts.size() > maximumQuantity;
        }
        
        if(!foundExcess) {
            // Any child exceeding the quantity?
            for(SystemPricing_SystemRuleBucket child : children) {
                if(child.areThereExcessiveNumbersOfProducts()) {
                    foundExcess = true;
                    break;
                }
            }
        }
            
        return foundExcess;
    }
    
    /* If there is an excessive numer of accessories, this removes the cheapest
     * excessive products.
     * This is done recursively, removal of entries only propagates up. So the sum of all matched 
     * products in bottom-level children may be higher than on the top-level.
	 */
    public Boolean removeExcess() {
        Boolean childProductsRemoved = false;
        while (areThereExcessiveNumbersOfProducts()) {
            childProductsRemoved = false;
            for(SystemPricing_SystemRuleBucket kid : children) {
                if(areThereExcessiveNumbersOfProducts () && kid.areThereExcessiveNumbersOfProducts()) {
                    childProductsRemoved = kid.removeExcess();
                    break;
                }
            }
            if(!childProductsRemoved && areThereExcessiveNumbersOfProducts()) {
                // We remove the products from our own matching list.
                // This does mean that child-Lists are out of synch with ours
                // So, removing excessive numbers of products must be the 
                // last thing that is done.
                // As adding and removing products is normally propagated from bottom
                // to top, we can then ask the topmost bucket for the list of products.
                System.debug('Syspri: remove: go to removeCheapestProduct(), removed before: ' + childProductsRemoved);
                childProductsRemoved = removeCheapestProduct();
                System.debug('Syspri: remove: after removeCheapestProduct(), removed after: ' + childProductsRemoved);
            }
            System.debug('Syspri: remove: removed: ' + childProductsRemoved + ' maxQ: ' + sysRule.max_quantity__c 
                        + ' matchedRemain: ' + matchedProducts.size());
            
        }
        return childProductsRemoved;
    }
    
    
    
    /* Identify the cheapest product we have matched for this rule and remove it.
     */
    public Boolean removeCheapestProduct() {
        Boolean wasRemoved = false;
        Decimal lowestPrice;
        Boolean priceSet = false;
        SystemPricing_ProductHolder prodToRemove;
        for(SystemPricing_ProductHolder curr : matchedProducts) {
            if(!priceSet) {
                // TODO: ensure there is always an OrderItem object
                lowestPrice = curr.anOrderItem.ListPrice;
                priceSet = true;
                prodToRemove = curr;
            }
            else if(curr.anOrderItem.ListPrice < lowestPrice) {
                lowestPrice = curr.anOrderItem.ListPrice;
                prodToRemove = curr;
            }
        }
        if(prodToRemove != null) {
            wasRemoved = removeProduct(prodToRemove);
        }
        System.debug('Syspri: cheapest: priceSet: ' + priceSet + ' lowestPrice: ' + lowestPrice + ' prodToRemove: ' + prodToRemove);
        return wasRemoved;
        
    }
    
    /* Removes a product from the chain. Propagates upward
     */
    private boolean removeProduct(SystemPricing_ProductHolder prodToRemove) {
        System.debug('Syspri: remove: start, currently ' + matchedProducts.size() + ' matches in store.');
        Integer index = 0;
        Boolean wasRemoved = false;
        for(SystemPricing_ProductHolder curr : matchedProducts) {
            if(curr == prodToRemove) {
                System.debug('Syspri: remove: match found.');
                matchedProducts.remove(index);
                wasRemoved = true;
                System.debug('Syspri: remove: going to parent...');
                if(parBucket != null) {
                    parBucket.removeProduct(prodToRemove);
                }
                else {
                    System.debug('Syspri: remove: No parent.');
                }
                break;
            }
            index++;
        }
        if(!wasRemoved) {
            // We must have a logic error here. This should only be called from
            // ourself or a child. If the product was not found and therefore not
            // removed, there is actually an error in the data.
            System.debug('Syspri: remove: Could not remove requested product!');
            System.debug(prodToRemove);
        }
        System.debug('Syspri: remove: end, currently ' + matchedProducts.size() + ' matches in store.');
        
        return wasRemoved;
    }
    
    /* Outputs interesting fields on the full hierarchy. Not used in production.
     */
    
/*    public void debugHierarchy(Integer level) {
        String theData = 'field: ' + sysRule.rule_field__c + ' value: ' + sysRule.rule_value__c 
            + ' maxQ: ' + sysRule.max_quantity__c + ' matched: ' + matchedProducts.size();
        String theBlanks = '';
        for(Integer i = 0; i<level; i++) {
            theBlanks += '  ';
        }
        System.debug('Syspri: hierarchy ' + theBlanks + theData);
        for(SystemPricing_SystemRuleBucket kid:children) {
            kid.debugHierarchy(level+1);
        }
    }
*/
    
        public class SystemPricingBucketException extends Exception {}
}