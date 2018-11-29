/* Created by Florian Heer <f.heer@conciscon.de>
 * 
 * This controller decouples the SystemPricing page into 2 steps. Before system pricing is invoked,
 * we have to reset existing systems. This cannot be done in the same step as creating a new system 
 * due to potential race conditions with queries.
 */
public without sharing class SystemPricingPreController {
    ApexPages.StandardController stdController;
    
    public Id ourOrder;
    
    public SystemPricingPreController (ApexPages.StandardController stdController) {
        ourOrder = ApexPages.currentPage().getParameters().get('id');
        this.stdController = stdController;
    }

    
    public PageReference initInfo() {
        // Check if there was already a system. If so, reset all system / pricing
        SystemPricingController_Helper.resetPossibleSystem(ourOrder);
        PageReference p = Page.SystemPricing;
        p.getParameters().put('id', ourOrder);
        return p;
    }

}