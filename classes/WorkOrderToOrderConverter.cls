public class WorkOrderToOrderConverter {
    private static final String DEFAULT_ORDER_STATUS = 'Not Submitted';
    
    public static Order convertToOrder(WorkOrder objWorkOrder){
        Order orderNew = new Order();
        
        orderNew.AccountId                  = objWorkOrder.AccountId;
        orderNew.BillingCity                = objWorkOrder.City;
        orderNew.BillingCountry             = objWorkOrder.Country;
        orderNew.BillingPostalCode          = objWorkOrder.PostalCode;
        orderNew.BillingState               = objWorkOrder.State;
        orderNew.BillingStreet              = objWorkOrder.Street;
        orderNew.brady_tachy_syndrome__c    = objWorkOrder.brady_tachy_syndrome__c;
        
        orderNew.chf__c             = objWorkOrder.chf__c;
        //SAFBIO-1890 orderNew.donation__c        = objWorkOrder.donation__c;
        
        Datetime dtEndDate = objWorkOrder.EndDate;
        orderNew.EndDate            = date.newinstance(dtEndDate.year(), dtEndDate.month(), dtEndDate.day()); 
        orderNew.Status             = DEFAULT_ORDER_STATUS;
        orderNew.mi__c              = objWorkOrder.mi__c;
        orderNew.one_hb__c          = objWorkOrder.one_hb__c;
        
        orderNew.referring_physician__c = objWorkOrder.referring_physician__c;
        orderNew.rep_at_implant__c  = objWorkOrder.rep_at_implant__c;
        orderNew.rep_for_credit__c  = objWorkOrder.rep_for_credit__c;
        //orderNew.sap_company_code__c = objWorkOrder.sap_company_code__c;
        
        orderNew.patient__c         = objWorkOrder.patient__c;
        orderNew.Pricebook2Id       = objWorkOrder.Pricebook2Id;    
        
        return orderNew;
    }
    
    public static List<Order> convertToOrder(List<WorkOrder> lstWorkOrder){
        List<Order> lstNewOrder = new List<Order>();
        
        for(WorkOrder wo :lstWorkOrder){
            lstNewOrder.add(convertToOrder(wo));
        }
        
        return lstNewOrder;
    }
}