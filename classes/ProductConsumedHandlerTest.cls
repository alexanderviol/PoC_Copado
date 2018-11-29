@isTest
public class ProductConsumedHandlerTest {
    private static String LAST_NAME_TESTUSER = 'HopefullyThisIsUniqe';
    
	@testSetup
    public static void createTestEnvironment () {
        Id profileId = Utility.getProfileId(Constants.PROFILE_NAME_SALES);
        User testUser = TestDataFactory.createUser(profileId);
        testUser.LastName = LAST_NAME_TESTUSER;
        insert testUser;
        
        List<PermissionSet> psets = [SELECT Id FROM PermissionSet WHERE Name = 'FSL_Agent_Permissions'];
        System.assertEquals(1, psets.size(), 'We expected exactly 1 permission set');
        
        List<PermissionSetAssignment> psas = new List<PermissionSetAssignment>();
        for(PermissionSet ps : psets) {
        	psas.add(new PermissionSetAssignment (PermissionSetId = ps.id, AssigneeId = testUser.Id));
        }
        insert psas;

    }
    
/* This test method does not work. See ProductConsumedHandler line 19    
 * FH 2018-10-22
    @isTest
    static void productConsumedDeletionNonCas(){
        Product2 prod = new Product2(Name = 'ICD');
        insert prod;
		Id pricebookId = Test.getStandardPricebookId();
        PricebookEntry standardPrice = new PricebookEntry(
            Pricebook2Id = pricebookId, Product2Id = prod.Id,
            UnitPrice = 10000, IsActive = true);
        insert standardPrice;
        
        WorkOrder objWorkOrder = new WorkOrder();
        objWorkOrder.StartDate = Date.today();
        objWorkOrder.EndDate = Date.today();
        objWorkOrder.Pricebook2Id = pricebookId;
        objWorkORder.rep_at_implant__c = UserInfo.getUserId();
        insert objWorkOrder;
        
        ProductConsumed item = new ProductConsumed();
        item.WorkOrderId = objWorkOrder.Id;
        item.PricebookEntryId = standardPrice.Id;
        item.QuantityConsumed = 2;
        insert item;
                
        Boolean bException = false;
        Integer intCountItemsBefore = [SELECT count() FROM ProductConsumed];
        Test.startTest();        
        try{
            delete item;
        }catch(Exception e){
            bException = true;
        }                
        Test.stopTest();
        
        Integer intCountItemsAfter = [SELECT count() FROM ProductConsumed];
        System.assertEquals(true, bException);
        System.assertEquals(intCountItemsBefore,intCountItemsAfter); 
    }
*/
    
    @isTest
    public static void testImplantDateSetting () {
        Id salesProfileId = Utility.getProfileId(Constants.PROFILE_NAME_SALES);
		User testUser = [SELECT Id, name FROM User WHERE ProfileId = :salesProfileId AND LastName = :LAST_NAME_TESTUSER];
        
        Schema.Location loc = TestDataFactory.createLocation ();
        loc.sap_company_code__c = '5500';
        loc.isInventoryLocation = true;
        loc.LocationType = 'Van';
        loc.IsMobile = true;
        
        insert loc;
        
        ServiceResource sr = TestDataFactory.createServiceResource (testUser.Id, loc.Id);
        sr.Name = testUser.Name + '_SR';
        insert sr;
        
        OperatingHours oh = TestDataFactory.createOperatingHours();
        insert oh;
        
        ServiceTerritory st = TestDataFactory.createServiceTerritory (oh.id);
        insert st;
        
        ServiceTerritoryMember stm = TestDataFactory.createServiceTerritoryMember (sr.id, st.id);
        insert stm;
        
        WorkOrder wo = TestDataFactory.createWorkOrder();
        insert wo;
        WorkOrderLineItem woli = TestDataFactory.createWorkOrderLineItem (wo.Id);
        insert woli;
        
        DateTime testDateTime = DateTime.newInstanceGmt(2017, 12, 24);
        
        ServiceAppointment sa = TestDataFactory.createServiceAppointment (woli.id);
        sa.SchedEndTime = testDateTime;
        sa.SchedStartTime = testDateTime;
        insert sa;
        
        Product2 prod = TestDataFactory.createProduct(Constants.RECORD_TYPE_NAME_PRODUCT);
        insert prod;
        
        ProductItem pi = TestDataFactory.createProductItem(prod.Id, loc.Id, 'biotronik_product');
        pi.QuantityOnHand = 5;
        insert pi;
        
        ProductConsumed pc = TestDataFactory.createProductConsumedWOLI(wo.Id, woli.Id, pi.Id,  1);
        insert pc;
        
        List<ProductConsumed> pcs = [SELECT Id, implant_date__c FROM ProductConsumed WHERE Id = :pc.Id];
        System.assertEquals(1, pcs.size());
        for(ProductConsumed p : pcs) {
            System.assertEquals(testDateTime.dateGMT(), p.implant_date__c, 'Original date is not propagated.');
        }
        
        // Let's change the date on the Service Appointment.
        testDateTime = testDateTime.addDays(30);
        sa.SchedEndTime = testDateTime;
        update sa;
        
        pc = TestDataFactory.createProductConsumedWOLI(wo.Id, woli.Id, pi.Id,  1);
        insert pc;
        
        pcs = [SELECT Id, implant_date__c FROM ProductConsumed WHERE Id = :pc.Id];
        System.assertEquals(1, pcs.size());
        for(ProductConsumed p : pcs) {
            System.assertEquals(testDateTime.dateGMT(), p.implant_date__c, 'Changed date is not propagated.');
        }
        
        // Let's change the dates again and write it to the actual end.
        testDateTime = testDateTime.addDays(-3);
        sa.ActualEndTime = testDateTime;
        update sa;
        
        System.debug ('Changed actual to ' + testDateTime);
        System.debug ('Service Appointment shows: ' + sa.ActualEndTime);
        List<ServiceAppointment> sxx = [SELECT ActualEndTime FROM ServiceAppointment WHERE Id = :sa.id];
        System.debug ('Service Appointment reread: ' + sxx[0].ActualEndTime);
        Date expectedDate = sxx[0].ActualEndTime.dateGMT ();
        System.debug ('So, we expect ' + expectedDate);
        System.assertNotEquals(null, expectedDate);
        pc = TestDataFactory.createProductConsumedWOLI(wo.Id, woli.Id, pi.Id,  1);
        insert pc;
        
        pcs = [SELECT Id, implant_date__c FROM ProductConsumed WHERE Id = :pc.Id];
        System.assertEquals(1, pcs.size());
        for(ProductConsumed p : pcs) {
            System.assertEquals(testDateTime.dateGMT(), p.implant_date__c, 'Actual date is not propagated.');
        }

    }
}