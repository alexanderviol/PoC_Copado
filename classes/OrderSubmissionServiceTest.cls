@IsTest
global class OrderSubmissionServiceTest {
    global Static Boolean testOrderSubmissionSchedulableRunning = false;
    @IsTest
    static void testOrderSubmissionSchedulable() {

        testOrderSubmissionSchedulableRunning = true;

        User testuser = [SELECT Id, Profile.Name FROM User WHERE Alias = 'testfunc'].get(0);
        System.assertEquals('MMS FUNC', testuser.Profile.Name);
        System.runAs(testuser) {

            Test.startTest();

            OrderSubmissionSchedulable sched = new OrderSubmissionSchedulable();
            String cronExp = '0 0 2 * * ?';
            system.schedule(OrderSubmissionSchedulable.JOB_NAME, cronExp, sched);

            // there should be one job that we just created
            List<CronTrigger> cjd = [SELECT Id FROM CronTrigger  WHERE CronJobDetail.Name = :OrderSubmissionSchedulable.JOB_NAME];
            System.assertEquals(1, cjd.size());


            Test.stopTest();

            // now as the job was running, it should have re.scheduked itself, so the ID should be different
            List<CronTrigger> cjd2 = [SELECT Id FROM CronTrigger  WHERE CronJobDetail.Name = :OrderSubmissionSchedulable.JOB_NAME];
            System.assertEquals(1, cjd2.size());
            System.assertNotEquals(cjd.get(0).Id, cjd2.get(0).Id);
        }
    }


    @IsTest
    static void testOrderSubmission() {

        User testuser = [SELECT Id, Profile.Name FROM User WHERE Alias = 'testfunc'].get(0);
        System.assertEquals('MMS FUNC', testuser.Profile.Name);
        System.runAs(testuser) {
            Order orderTest;

            Product2 product = new Product2();
            product.Name = 'Testproduct';
            insert product;

            PricebookEntry pbe = new PricebookEntry();
            pbe.Product2Id = product.Id;
            pbe.UnitPrice = 42;
            pbe.Pricebook2Id = Test.getStandardPricebookId();
            insert pbe;

            Account account = TestDataFactory.createAccount();
            account.Name = 'Testaccount';
            account.sap_no__c = '0000464464';
            account.RecordTypeId = [SELECT Id FROM RecordType WHERE SobjectType = 'Account' AND DeveloperName = 'x5500_us_account' LIMIT 1].Id;
            insert account;

            Contact patientContact = TestDataFactory.createPatient(false, account.Id);
            insert patientContact;

            Order order = new Order();
            order.AccountId = account.id;
            order.EffectiveDate = System.today();
            order.Status = 'Pending SAP Submission';
            order.Pricebook2Id = Test.getStandardPricebookId();
            order.no_rep_present_at_implant__c = true;
            order.patient__c = patientContact.Id;
            insert order;


            OrderItem oi = new OrderItem();
            oi.OrderId = order.Id;
            oi.Product2Id = product.Id;
            oi.PricebookEntryId = pbe.Id;
            oi.Quantity = 1;
            oi.UnitPrice = 42;
            oi.expiration_date_ubd__c = System.Today();
            oi.model_no__c = '123';
            oi.product_type__c = '123';
            oi.product_code__c = '123';
            oi.product_type__c = 'Pacemaker';
            insert oi;

            order.submit_to_sap__c = true;
            order.submission_attempts__c = 1;
            order.is_locked__c = true;
            update order;

            orderTest = [SELECT submission_attempts__c, submitted_date__c, sap_error_message__c, is_locked__c FROM Order WHERE Id = :order.Id];
            System.assertEquals(1, orderTest.submission_attempts__c);
            System.assertEquals(NULL, orderTest.sap_error_message__c);
            System.assertEquals(NULL, orderTest.submitted_date__c);
            System.assertEquals(true, orderTest.is_locked__c);


            Test.startTest();

            Test.setMock(WebServiceMock.class, new API_OrderIntegration_Mock());

            OrderSubmissionService.submitOrder(order.Id);


            Test.stopTest();


            orderTest = [SELECT submission_attempts__c, submitted_date__c, sap_error_message__c, is_locked__c FROM Order WHERE Id = :order.Id];
            System.assertEquals(1, orderTest.submission_attempts__c);
            System.assertEquals(false, orderTest.is_locked__c);
            System.assertEquals(NULL, orderTest.sap_error_message__c);
            System.assertNotEquals(NULL, orderTest.submitted_date__c);
        }
    }


    @IsTest
    static void testOrderSubmissionError() {

        User testuser = [SELECT Id, Profile.Name FROM User WHERE Alias = 'testfunc'].get(0);
        System.assertEquals('MMS FUNC', testuser.Profile.Name);
        System.runAs(testuser) {
            Order orderTest;

            Product2 product = new Product2();
            product.Name = 'Testproduct';
            insert product;

            PricebookEntry pbe = new PricebookEntry();
            pbe.Product2Id = product.Id;
            pbe.UnitPrice = 42;
            pbe.Pricebook2Id = Test.getStandardPricebookId();
            insert pbe;

            Account account = TestDataFactory.createAccount();
            account.Name = 'Testaccount';
            account.sap_no__c = '0000464464';
            account.RecordTypeId = [SELECT Id FROM RecordType WHERE SobjectType = 'Account' AND DeveloperName = 'x5500_us_account' LIMIT 1].Id;
            insert account;

            Contact patientContact = TestDataFactory.createPatient(false, account.Id);
            insert patientContact;

            Order order = new Order();
            order.AccountId = account.id;
            order.EffectiveDate = System.today();
            order.Status = 'Pending SAP Submission';
            order.Pricebook2Id = Test.getStandardPricebookId();
            order.no_rep_present_at_implant__c = true;
            order.patient__c = patientContact.Id;
            insert order;


            OrderItem oi = new OrderItem();
            oi.OrderId = order.Id;
            oi.Product2Id = product.Id;
            oi.PricebookEntryId = pbe.Id;
            oi.Quantity = 1;
            oi.UnitPrice = 42;
            oi.expiration_date_ubd__c = System.Today();
            oi.model_no__c = '123';
            oi.product_type__c = '123';
            oi.product_code__c = '123';
            oi.product_type__c = 'Pacemaker';
            insert oi;

            order.submit_to_sap__c = true;
            order.submission_attempts__c = 1;
            order.is_locked__c = true;
            update order;

            orderTest = [SELECT submission_attempts__c, submitted_date__c, sap_error_message__c, is_locked__c FROM Order WHERE Id = :order.Id];
            System.assertEquals(1, orderTest.submission_attempts__c);
            System.assertEquals(NULL, orderTest.sap_error_message__c);
            System.assertEquals(NULL, orderTest.submitted_date__c);
            System.assertEquals(true, orderTest.is_locked__c);


            Test.startTest();

            Test.setMock(WebServiceMock.class, new API_OrderIntegrationNegative_Mock());

            OrderSubmissionService.submitOrder(order.Id);


            Test.stopTest();


            orderTest = [SELECT submission_attempts__c, submitted_date__c, sap_error_message__c, is_locked__c FROM Order WHERE Id = :order.Id];
            System.assertEquals(1, orderTest.submission_attempts__c);
            System.assertEquals(false, orderTest.is_locked__c);
            System.assertEquals('Mock_Error', orderTest.sap_error_message__c);
            System.assertEquals(NULL, orderTest.submitted_date__c);
        }
    }

    @testSetup
    public static void setupOrderSubmissionUser () {
        User u = TestDataFactory.createUser(Utility.getProfileId(Constants.PROFILE_Name_System_MMS_FUNC));
        u.FirstName = 'Test';
        u.LastName = 'Test';
        u.Username = 'test_mms_func@example.com';
        u.Email = 'test_mms_func@example.com';
        u.Alias = 'testfunc';
        u.CommunityNickname = 'test_mms_func@example.com';
        u.TimeZoneSidKey = 'Europe/Berlin';
        u.LocaleSidKey = 'en_US';
        u.EmailEncodingKey = 'UTF-8';
        u.LanguageLocaleKey ='en_US';
        u.Country = 'United States';
        insert u;
    }
}