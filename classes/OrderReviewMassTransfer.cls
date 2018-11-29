public with sharing class OrderReviewMassTransfer {
	PageReference cancel;
    Order[] records;
    
    /**
     * Checks which order are selected in the list view to 
     * 
     * @param	controller, reference to the Order StandardSetController
     */
    public OrderReviewMassTransfer(ApexPages.StandardSetController controller) {
        records = (Order[])controller.getSelected();
        cancel = controller.cancel();
    }
    
    /**
     * Updates the owner value of all selected orders from the list view to the current running user.
     * 
     * @return	the PageReference of the cancelation method from the StandardSetController.cancel method
     */
    public PageReference updateOrders() {
        for(Order record: records) {
            record.OwnerId = UserInfo.getUserId();
        }
        
        update records;
        return cancel.setRedirect(true);
    }
}