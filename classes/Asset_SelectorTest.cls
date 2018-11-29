/**************************************************************************************************************
* Asset_SelectorTest - Test Class for Asset_Selector class
* @author Gokul Palagiri
* @CreatedDate -    11.10.2018
* Gokul Palagiri:   11.10.2018 : Initial Version
****************************************************************************************************************/
@isTest
private class Asset_SelectorTest {
    static final String SALES_PROFILE = 'Sales';
    static Account objAccount;
    static Contact objContact;
    static Order objOrder;
    static OrderItem objOrderItem;
    static user testUser;
    static Asset objAsset;
    static Set<Id> assetIds = new Set<Id>();
    static Set<String> assetRtNames = new Set<String>();

    @isTest
    private static void Test_getObjectApiName(){
        String objApiName = new Asset_Selector().getObjectApiName();
        System.assertEquals('Asset', objApiName, 'Incorrect Object');
    }

    @isTest
    private static void Test_getById(){
        if(assetIds.isEmpty()){createTestData();}
        List<Asset> sObjectAssets = new Asset_Selector().getById(assetIds, new Set<String>{Asset.Id.getDescribe().getName()});
        System.assert(sObjectAssets.size() > 0, 'Incorrect number of sObjects returned');

        List<Asset> sObjectAssetsNull = new Asset_Selector().getById(new Set<Id>(), new Set<String>{Asset.Id.getDescribe().getName()});
        System.assertEquals(0, sObjectAssetsNull.size(), 'Incorrect number of sObjects returned');
    }

    @isTest
    private static void Test_getByIdAndRecordTypeName(){
        List<Asset> sObjectAssetsNull = new Asset_Selector().getByIdAndRecordTypeName(new Set<Id>(), new Set<String>(), new Set<String>{Asset.Id.getDescribe().getName()});
        System.assertEquals(0, sObjectAssetsNull.size(), 'Incorrect number of sObjects returned');
    }

    private static void createTestData() {
        Profile p = [SELECT Id, Name FROM Profile WHERE Name = :SALES_PROFILE];
        testUser = TestDataFactory.createUser(p.id);
        insert testUser;

        System.runAs(testUser) {
            objAccount = TestDataFactory.createAccount();
            insert objAccount;

            Id orderRtId =  Utility.getRecordTypeId (Order.SObjectType, Constants.RECORD_TYPE_NAME_ORDER_MDRF);
            objOrder = TestDataFactory.createOrder(objAccount.Id);
            objOrder.status = Constants.PICKLIST_VALUE_STATUS_NOT_SUBMITTED;
            objOrder.recordTypeId = orderRtId;
            objOrder.submit_to_sap__c = true;
            objOrder.PoNumber = '1234';
            objOrder.OwnerId = testUser.Id;
            insert objOrder;

            objOrderItem = TestDataFactory.createOrderItem(objOrder.Id);
            Insert objOrderItem;

            Id idPateintRecordType = [SELECT Id, Name, DeveloperName FROM RecordType WHERE Name = 'Patient'].Id;
            objContact = new Contact(firstname='TEST', lastname= 'CONTACT',
                    Birthdate = System.today().addYears(-29),
                    declined_to_provide_address__c = true,
                    declined_to_provide_phone__c = true,
                    declined_to_provide_ssn__c = true,
                    accountid = objAccount.Id,
                    recordTypeId = idPateintRecordType);
            insert objContact;

            Product2 prod = new Product2(Name = Constants.PICKLIST_VALUE_PRODUCT_TYPE_ICD);
            prod.product_type__c = Constants.PICKLIST_VALUE_PRODUCT_TYPE_ICD;
            insert prod;

            objAsset = TestDataFactory.createAsset(objAccount.Id);
            objAsset.product_type__c = Constants.PICKLIST_VALUE_PRODUCT_TYPE_ICD;
            objAsset.order__c = objOrder.Id;
            objAsset.order_product__c = objOrderItem.Id;
            objAsset.Status = Constants.IMPLANT_STATUS_IMPLANTED;
            objAsset.patient__c = objContact.Id;
            objAsset.Product2Id = prod.Id;
            insert objAsset;
            assetIds.add(objAsset.Id);
            assetRtNames.add(Constants.RECORD_TYPE_NAME_ASSET_SYSTEM);

        }
    }

}