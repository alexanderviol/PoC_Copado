@isTest 
private class WorkOrderUpdatorTest {
        
    static testMethod void updateWorkOrderredordsTest() {
        workorder wodr = createWorkorder();
        
        //Verifying the rep at Implant and rep at credit are null.
        System.assertEquals(wodr.rep_at_implant__c, null);
        System.assertEquals(wodr.rep_for_credit__c, null);
        
        User u1 =  createUser('test@Testsdsssdsdsds.com');
        User u2 =  createUser('test@Tppppppyyy.com');
        workorder wo = new workorder();
        wo.rep_at_implant__c = u1.id;
        wo.rep_for_credit__c   = u2.id;
        wo.no_rep_present_at_implant__c = false;
        //Updating rep at Implant and rep at credit for a wororder record
        WorkOrderUpdator.updateWorkOrderredords(wo, wodr.id);
        //Verifying the rep at Implant and rep at credit are updated
        workorder wr = [SELECT id,rep_at_implant__c, rep_for_credit__c FROM workorder where id =: wodr.id];
        System.assertEquals(wr.rep_at_implant__c, u1.id);
        System.assertEquals(wr.rep_for_credit__c, u2.id);
        try{
            //Will throw exception 
            wo.no_rep_present_at_implant__c = true;
            WorkOrderUpdator.updateWorkOrderredords(wo, wodr.id);
        } catch(Exception e) {
            System.assertNotEquals(e.getMessage(), null);
        }
        
    }
    
    private static User createUser(String userName) {
        User u = TestDataFactory.createUser(Utility.getProfileId(Constants.PROFILE_NAME_SALES));
        u.Username =  userName;
        insert u;
        return u;
    }
    
    private static WorkOrder createWorkorder() {

        Account acc = new Account();
        acc.Name = 'Testing Acc';
        acc.status__c = 'active';
        insert acc;

        Contact con = TestDataFactory.createPhysician(acc.Id);
        con.FirstName = 'Test';
        con.LastName = 'Cont';
        insert con;

        WorkOrder wo = TestDataFactory.createWorkOrder();
        wo.implanting_physician__c = con.Id;
        insert wo;
        return wo;
    }
}