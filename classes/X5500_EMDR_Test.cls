/**
EMDR-related test methods
@author	Mike Tribble
@revised 06/20/18 created
*/
@isTest
private class X5500_EMDR_Test {

	static X5500_EMDRConfig__mdt getConfig() {
		X5500_EMDRConfig__mdt cfg = [
			SELECT x.Id, x.DeveloperName, x.admin_email__c, x.analysis_report_emdr_rectype__c,
			x.analysis_report_status_submitted__c, x.emdr_rec_type_test__c, x.g1_contact_city__c,
			x.g1_contact_country_code__c, x.g1_contact_facility_name__c, x.g1_contact_state_code__c,
			x.g1_contact_street__c, x.g1_contact_telecom__c, x.g1_contact_zip_code__c, x.mdr_prefix__c,
			x.patient_rec_type__c, x.status_submit_to_emdr_fail__c, x.status_submit_to_emdr_ok__c,
			x.status_submit_to_emdr_ready__c, x.test_emdr_recordids__c,
			x.ws_endpoint_submit__c, x.ws_password__c, x.ws_username__c
			From X5500_EMDRConfig__mdt x
			WHERE x.DeveloperName =: 'EMDR_Config'];
		return cfg;
	}

	static testMethod void submitFromButton() {
		insertTestSubmitRecords();
		Test.startTest();
		Test.setMock(WebServiceMock.class, new X5500_EMDR_Submit_Callout_Mock());
		boolean success = true;
		try {
			//start with lightning component
			String result = X5500_EMDR_Controller.submitFromButton();
			System.debug('X5500_EMDR_Test.submitFromButton(): result is ' + (result != null ? result : ''));
		} catch(Exception exc) {
			System.debug('X5500_EMDR_Test.submitFromButton(): exception occurred: ' + exc.getMessage());
			if (exc.getMessage() != 'test') success = false;
		}
		System.assertEquals(true, success);
		Test.stopTest();
	}

	/*
	 * get coverage on controller future pass-through method
	*/
	static testMethod void controllerGetStatusTest() {
		insertTestStatusRecords();
		Test.startTest();
        Test.setMock(WebServiceMock.class, new X5500_EMDR_Status_Callout_Mock());
		boolean success = true;
		try {
			String result = X5500_EMDR_Controller.getStatus();
			System.debug('X5500_EMDR_Test.getStatus(): result is ' + (result != null ? result : ''));
		} catch(Exception exc) {
			System.debug('X5500_EMDR_Test.getStatusTest(): exception occurred: ' + exc.getMessage());
			if ( exc.getMessage().indexOf('test') == -1 && exc.getMessage().indexOf('FDA validation') == -1) success = false;
		}
		System.assertEquals(true, success);
		Test.stopTest();
	}

	/*
	test straight to handler
	*/
	static testMethod void handlerGetStatusTest() {
		insertTestStatusRecords();
		Test.startTest();
		Test.setMock(WebServiceMock.class, new X5500_EMDR_Status_Callout_Mock());
		boolean success = true;
		try {
			X5500_EMDR_Handler handler = new X5500_EMDR_Handler();
			handler.getEMDRStatus();
		} catch(Exception exc) {
			System.debug('X5500_EMDR_Test.getStatusTestExc(): exception occurred: ' + exc.getMessage());
			if ( exc.getMessage().indexOf('test') == -1 && exc.getMessage().indexOf('FDA validation') == -1) success = false;
		}
		System.assertEquals(true, success);
		Test.stopTest();
	}

	static testMethod void submitFromTrigger() {
		insertTestSubmitRecords();
		Test.startTest();
		Test.setMock(WebServiceMock.class, new X5500_EMDR_Submit_Callout_Mock());
		boolean success = true;
		try {
			X5500_EMDR_Controller.submitFromTrigger();
		} catch(Exception exc) {
			System.debug('X5500_EMDR_Test.submitFromTrigger(): exception occurred: ' + exc.getMessage());
			if (exc.getMessage() != 'test') success = false;
		}
		System.assertEquals(true, success);
		Test.stopTest();
	}

	/*
	induce exception for code coverage
	*/
	static testMethod void submitTestExc() {
		Test.startTest();
		Test.setMock(WebServiceMock.class, new X5500_EMDR_Submit_Callout_Mock());
		boolean success = true;
		try {
			X5500_EMDR_Handler handler = new X5500_EMDR_Handler();
			handler.testException = true;
			handler.submitEMDRs();
		} catch(Exception exc) {
			System.debug('X5500_EMDR_Handler_Test.submitEMDRsTest(): exception occurred: ' + exc.getMessage());
			if (exc.getMessage() != 'test') success = false;
		}
		System.assertEquals(true, success);
		Test.stopTest();
	}

	/*
	induce exception for code coverage
	*/
	static testMethod void getStatusTestExc() {
		insertTestStatusRecords();
		Test.startTest();
		Test.setMock(WebServiceMock.class, new X5500_EMDR_Status_Callout_Mock());
		try {
			X5500_EMDR_Handler handler = new X5500_EMDR_Handler();
			handler.testException = true;
			handler.getEMDRStatus();
		} catch(Exception exc) {
			System.debug('X5500_EMDR_Test.getStatusTestExc(): exception occurred: ' + exc.getMessage());
		}
		Test.stopTest();
	}

	static void insertTestSubmitRecords() {

		X5500_EMDRConfig__mdt config = getConfig();
		String batchNo = '12345';
		Date manDate = System.today().addYears(-10);
		String manufacturer = 'BIOTRONIK';
		Date expireDate = System.today().addYears(-1);
		Date explantDate = System.today().addMonths(-1);
		Date oosDate = System.today().addDays(-15);
		String assetStatus = 'Explanted';
		List<User> users = new List<User>();

		User theUser = new User (
			Alias = 'testusr1',
			CompanyName = UserInfo.getOrganizationName(),
			Email = 'fake1@fake.com',
			EmailEncodingKey = 'UTF-8',
			FirstName = 'Test1',
			LanguageLocaleKey = 'en_US',
			LastName = 'User1',
			LocaleSidKey = 'en_US',
			ProfileId = [SELECT Id FROM Profile WHERE Name = 'System Administrator'].Id,
			TimeZoneSidKey = 'America/Los_Angeles',
			Title = 'Test User',
			Username = 'fake1@fake.com' + System.currentTimeMillis()
			//UserRoleId = role.id
		);
		users.add(theUser);

		User notherUser = new User (
			Alias = 'testusr2',
			CompanyName = UserInfo.getOrganizationName(),
			Email = 'fake2@fake.com',
			EmailEncodingKey = 'UTF-8',
			FirstName = 'Test2',
			LanguageLocaleKey = 'en_US',
			LastName = 'User2',
			LocaleSidKey = 'en_US',
			ManagerId = theUser.Id,
			ProfileId = [SELECT Id FROM Profile WHERE Name = 'System Administrator'].Id,
			TimeZoneSidKey = 'America/Los_Angeles',
			Title = 'Test User 2',
			Username = 'fake2@fake.com' + System.currentTimeMillis()
			//UserRoleId = role.id
		);
		users.add(notherUser);
		insert users;

		List<Account> testAccts = new List<Account>();
        Account theAcct = new Account(
			Name = 'test account',
			ShippingPostalCode = 'zip12345',
			ShippingCity = 'test city',
			ShippingStateCode = 'OR',
			ShippingCountryCode = 'US',
			status__c = 'active'            
		);
		testAccts.add(theAcct);

		Account notherAcct = new Account(
			Name = 'test account 2',
			ShippingPostalCode = 'zip12345',
			ShippingCity = 'test city',
			ShippingStateCode = 'OR',
			ShippingCountryCode = 'US',
			status__c = 'active'
		);
		testAccts.add(notherAcct);
		insert testAccts;
        
		List<Product2> prodList = new List<Product2>();
		Product2 prod = new Product2(
			pma__c = 'TEST123',
			ProductCode = '123',
			Family = 'TEST',
			Name = 'TEST 123',
			manufacturer_account__c = theAcct.Id,
			product_type__c = 'Pacemaker',
			sap_model_no__c = 'TEST_123'
		);
		prodList.add(prod);	        
		//insert prod;

        Product2 notherProd = new Product2(
			pma__c = 'TEST345',
			ProductCode = '345',
			Family = 'TEST2',
			Name = 'TEST 345',
			manufacturer_account__c = notherAcct.Id,
			product_type__c = 'Pacemaker',
			sap_model_no__c = 'TEST_345'
		);
		prodList.add(notherProd);
		insert prodList;

		List<Contact> patients = new List<Contact>();

		Contact patient = new Contact(
			FirstName='Test',
			Lastname= 'Patient1',
			Birthdate = System.today().addYears(-60),
			declined_to_provide_phone__c = true,
			declined_to_provide_ssn__c = true,
			gender__c = 'Male',
			MailingCountryCode='US',
			MailingStateCode='OR',
			RecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get(config.patient_rec_type__c).getRecordTypeId()
		);
		patients.add(patient);

		Contact notherPatient = new Contact(
			FirstName='Test',
			Lastname= 'Patient2',
			Birthdate = System.today().addYears(-61),
			declined_to_provide_phone__c = true,
			declined_to_provide_ssn__c = true,
			gender__c = 'Male',
			MailingCountryCode='US',
			MailingStateCode='OR',
			RecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get(config.patient_rec_type__c).getRecordTypeId()
		);
		patients.add(notherPatient);

		insert patients;

		List<Asset> assets = new List<Asset>();
		Asset theAsset = new Asset(
			AccountId = theAcct.Id,
			batch_no__c = batchNo,
			biosmart_id__c = '12345',
			date_of_manufacture__c = manDate,
			explant_date__c = explantDate,
			expiration_date_ubd__c = expireDate,
			//hmsc_external_id__c = '12345',
			manufacturer__c = manufacturer,
			model_no__c = prod.ProductCode,
			Name = prod.Name,
			oos_date__c = oosDate,
			patient__c = patient.Id,
			Product2Id = prod.Id,
			SerialNumber = '12345',
			Status = assetStatus
		);
		assets.add(theAsset);

		Asset notherAsset = new Asset(
			AccountId = notherAcct.Id,
			batch_no__c = batchNo,
			biosmart_id__c = '67890',
			date_of_manufacture__c = manDate,
			explant_date__c = explantDate,
			expiration_date_ubd__c = expireDate,
			//hmsc_external_id__c = '67890',
			manufacturer__c = manufacturer,
			model_no__c = notherProd.ProductCode,
			Name = notherProd.Name,
			oos_date__c = oosDate,
			patient__c = notherPatient.Id,
			Product2Id = notherProd.Id,
			SerialNumber = '67890',
			Status = assetStatus
		);
		assets.add(notherAsset);
		insert assets;

		List<Case> cases = new List<Case>();
		Case theCase = new Case(
			AccountId = theAcct.Id,
			AssetId = theAsset.Id,
			patient__c = patient.Id
		);
		cases.add(theCase);

		Case notherCase = new Case(
			AccountId = notherAcct.Id,
			AssetId = notherAsset.Id,
			patient__c = notherPatient.Id
		);
		cases.add(notherCase);
		insert cases;

		List<complaint__c> coms = new List<complaint__c>();
		complaint__c theCom = new complaint__c(
			asset_manufacturer__c = manufacturer,
			asset_model_name__c = prod.Name,
			asset_model_number__c = prod.ProductCode,
			case__c = theCase.Id,
			initial_approver__c = theUser.Id,
			out_of_service_date__c = oosDate,
			procode__c = prod.ProductCode,
			RecordTypeId = Schema.SObjectType.complaint__c.getRecordTypeInfosByDeveloperName().get(config.emdr_rec_type_test__c).getRecordTypeId(),
			//RecordTypeId = testRecType.Id,
			OwnerId = UserInfo.getUserId(),
			device_asset_status__c = assetStatus,
            ci_number__c = 'CI-2018-77777',
			mdr_number__c = 'MDR-102832-2018-77777',
			patient_identifier__c = '01',
			date_of_birth__c = patient.BirthDate,//Date.newInstance(1961, 04, 03),
			gender__c = patient.gender__c,
			//patient_weight__c = null,
			ethnicity__c = null,
			race__c = null,
			//section B
			adverse_event__c = true,
			product_problem__c = false,
			outcome_attributed_to_adverse_event__c = 'Hospitalization',
			date_of_death__c = null,
			date_of_event__c = Date.newInstance(2018, 06, 05),
			report_date__c = system.today(),
			mdr_event_description__c = 'test test test',
			//section D
			asset__c = theAsset.Id,
			asset_lot_number__c = batchNo,
			expiration_date__c = expireDate,
			asset_serial_number__c = theAsset.SerialNumber,
			asset_implant_date__c = Date.newInstance(2012, 06, 01),
			explant_date__c = explantDate,//Date.newInstance(2018, 06, 01),
			device_available_for_evaluation__c = 'yes',
			date_product_returned_to_manufacturer__c = Date.newInstance(2018, 06, 02),

	        //Medwatch Section E
			initial_reporter_user__c = Userinfo.getUserId(),
			initial_reporter_also_sent_report_to_fda__c = 'NO',

			//Medwatch Section F
			patient_code_global__c = null,
			device_code_global__c = null,
			//Medwatch Section G
			report_source__c = 'HealthProfessional',
			pma_510k__c = prod.pma__c,
			type_of_report__c = 'Initial',
			type_of_report_follow_up__c = 0,
			//Medwatch Section H
			type_of_reportable_event__c = 'Malfunction',
			if_follow_up_what_type__c = 'AdditionalInformationReport',
			evaluation_summary_attached__c = false,
			date_of_manufacture__c = manDate,//Date.newInstance(2009, 01, 01),
			labeled_for_single_use__c = true,
			usage_of_device__c = 'InitialUsage',
			additional_manufacturer_narrative__c = null,
			corrected_data_comment__c = null,
			mdr_decision__c = 'File MDR within 30 calendar day.'
		);
		coms.add(theCom);

		complaint__c notherCom = theCom.clone();
		notherCom.asset_model_name__c = notherProd.Name;
		notherCom.asset_model_number__c = notherProd.ProductCode;
		notherCom.asset__c = notherAsset.Id;
		notherCom.case__c = notherCase.Id;
		notherCom.date_of_birth__c = notherPatient.BirthDate;
		notherCom.ci_number__c = 'CI-2018-77778';
		notherCom.gender__c = notherPatient.gender__c;
		notherCom.mdr_number__c = 'MDR-102832-2018-77778';
		notherCom.pma_510k__c = notherProd.pma__c;
		notherCom.procode__c = notherProd.ProductCode;
		notherCom.asset_serial_number__c = notherAsset.SerialNumber;

		coms.add(notherCom);
		insert coms;

		List<Analysis_Report__c> ars = new List<Analysis_Report__c>();      
		Analysis_Report__c ar = new Analysis_Report__c(
			complaint__c = theCom.Id,
			additional_manufacturer_narrative__c = true,
			analysis_results__c = 'test',
			conclusion_code__c = null,
			device_evaluated_by_manufacturer__c = 'Yes',
			evaluated_by_manufacturer_explanation__c = 'test',
			external_id__c = '1028232-2018-799395',
			manufacturer_event_description__c = 'test test',
			date_sent_to_fda__c = null,
			method_code__c = null,
			result_code__c = null
		);
		ars.add(ar);
		Analysis_Report__c ar2 = ar.clone();
		ar2.complaint__c = notherCom.Id;
		ar2.external_id__c = '1028232-2018-7998007';
		ars.add(ar2);
		insert ars;
		//need to update complaints because downstream logic has changed status
		for (complaint__c com : coms) {
			com.approval_status__c = config.status_submit_to_emdr_ready__c;
		}
		update coms;
	}

	static void insertTestStatusRecords() {
		X5500_EMDRConfig__mdt config = getConfig();
		String batchNo = '12345';
		Date manDate = System.today().addYears(-10);
		String manufacturer = 'BIOTRONIK';
		Date expireDate = System.today().addYears(-1);
		Date explantDate = System.today().addMonths(-1);
		String assetStatus = 'Explanted';
		Date oosDate = System.today().addDays(-15);
		List<User> users = new List<User>();

		User theUser = new User (
			Alias = 'testusr1',
			CompanyName = UserInfo.getOrganizationName(),
			Email = 'fake1@fake.com',
			EmailEncodingKey = 'UTF-8',
			FirstName = 'Test1',
			LanguageLocaleKey = 'en_US',
			LastName = 'User1',
			LocaleSidKey = 'en_US',
			ProfileId = [SELECT Id FROM Profile WHERE Name = 'System Administrator'].Id,
			TimeZoneSidKey = 'America/Los_Angeles',
			Title = 'Test User',
			Username = 'fake1@fake.com' + System.currentTimeMillis()
			//UserRoleId = role.id
		);
		users.add(theUser);

		User notherUser = new User (
			Alias = 'testusr2',
			CompanyName = UserInfo.getOrganizationName(),
			Email = 'fake2@fake.com',
			EmailEncodingKey = 'UTF-8',
			FirstName = 'Test2',
			LanguageLocaleKey = 'en_US',
			LastName = 'User2',
			LocaleSidKey = 'en_US',
			ManagerId = theUser.Id,
			ProfileId = [SELECT Id FROM Profile WHERE Name = 'System Administrator'].Id,
			TimeZoneSidKey = 'America/Los_Angeles',
			Title = 'Test User 2',
			Username = 'fake2@fake.com' + System.currentTimeMillis()
			//UserRoleId = role.id
		);
		users.add(notherUser);
		insert users;

		List<Account> testAccts = new List<Account>();
        Account theAcct = new Account(
			Name = 'test account',
			ShippingPostalCode = 'zip12345',
			ShippingCity = 'test city',
			ShippingStateCode = 'OR',
			ShippingCountryCode = 'US',
			status__c = 'active'            
		);
		testAccts.add(theAcct);

		Account notherAcct = new Account(
			Name = 'test account 2',
			ShippingPostalCode = 'zip12345',
			ShippingCity = 'test city',
			ShippingStateCode = 'OR',
			ShippingCountryCode = 'US',
			status__c = 'active'
		);
		testAccts.add(notherAcct);
		insert testAccts;
        
		List<Product2> prodList = new List<Product2>();
		Product2 prod = new Product2(
			pma__c = 'TEST123',
			ProductCode = '123',
			Family = 'TEST',
			Name = 'TEST 123',
			manufacturer_account__c = theAcct.Id,
			sap_model_no__c = 'TEST_123'
		);
		prodList.add(prod);	        

        Product2 notherProd = new Product2(
			pma__c = 'TEST345',
			ProductCode = '345',
			Family = 'TEST2',
			Name = 'TEST 345',
			manufacturer_account__c = notherAcct.Id,
			sap_model_no__c = 'TEST_345'
		);
        prodList.add(notherProd);
		insert prodList;        

		List<Contact> patients = new List<Contact>();

		Contact patient = new Contact(
			FirstName='Test',
			Lastname= 'Patient1',
			Birthdate = System.today().addYears(-60),
			declined_to_provide_phone__c = true,
			declined_to_provide_ssn__c = true,
			gender__c = 'Male',
			MailingCountryCode='US',
			MailingStateCode='OR',
			RecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get(config.patient_rec_type__c).getRecordTypeId()
		);
		patients.add(patient);

		Contact notherPatient = new Contact(
			FirstName='Test',
			Lastname= 'Patient2',
			Birthdate = System.today().addYears(-61),
			declined_to_provide_phone__c = true,
			declined_to_provide_ssn__c = true,
			gender__c = 'Male',
			MailingCountryCode='US',
			MailingStateCode='OR',
			RecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get(config.patient_rec_type__c).getRecordTypeId()
		);
		patients.add(notherPatient);

		insert patients;

		List<Asset> assets = new List<Asset>();
		Asset theAsset = new Asset(
			AccountId = theAcct.Id,
			batch_no__c = batchNo,
			biosmart_id__c = '12345',
			date_of_manufacture__c = manDate,
			expiration_date_ubd__c = expireDate,
			explant_date__c = explantDate,
			//hmsc_external_id__c = '12345',
			manufacturer__c = manufacturer,
			model_no__c = prod.ProductCode,
			Name = prod.Name,
			oos_date__c = oosDate,
			patient__c = patient.Id,
			Product2Id = prod.Id,
			SerialNumber = '12345',
			Status = assetStatus
		);
		assets.add(theAsset);

		Asset notherAsset = new Asset(
			AccountId = notherAcct.Id,
			batch_no__c = batchNo,
			biosmart_id__c = '67890',
			date_of_manufacture__c = manDate,
			expiration_date_ubd__c = expireDate,
			explant_date__c = explantDate,
			//hmsc_external_id__c = '67890',
			manufacturer__c = manufacturer,
			model_no__c = notherProd.ProductCode,
			Name = notherProd.Name,
			oos_date__c = oosDate,
			patient__c = notherPatient.Id,
			Product2Id = notherProd.Id,
			SerialNumber = '67890',
			Status = assetStatus
		);
		assets.add(notherAsset);
		insert assets;

		List<Case> cases = new List<Case>();
		Case theCase = new Case(
			AccountId = theAcct.Id,
			AssetId = theAsset.Id,
			patient__c = patient.Id
		);
		cases.add(theCase);

		Case notherCase = new Case(
			AccountId = notherAcct.Id,
			AssetId = notherAsset.Id,
			patient__c = notherPatient.Id
		);
		cases.add(notherCase);
		insert cases;

		List<complaint__c> coms = new List<complaint__c>();
		complaint__c theCom = new complaint__c(
			asset_manufacturer__c = manufacturer,
			asset_model_name__c = prod.Name,
			asset_model_number__c = prod.ProductCode,
			case__c = theCase.Id,
			initial_approver__c = theUser.Id,
			out_of_service_date__c = oosDate,
			procode__c = prod.ProductCode,
			RecordTypeId = Schema.SObjectType.complaint__c.getRecordTypeInfosByDeveloperName().get(config.emdr_rec_type_test__c).getRecordTypeId(),
			//RecordTypeId = testRecType.Id,
			OwnerId = UserInfo.getUserId(),
			device_asset_status__c = assetStatus,
            ci_number__c = 'CI-2018-77777',
			mdr_number__c = 'MDR-102832-2018-77777',
			patient_identifier__c = '01',
			date_of_birth__c = patient.BirthDate,
			gender__c = patient.gender__c,
			//patient_weight__c = null,
			ethnicity__c = null,
			race__c = null,
			//section B
			adverse_event__c = true,
			product_problem__c = false,
			outcome_attributed_to_adverse_event__c = 'Hospitalization',
			date_of_death__c = null,
			date_of_event__c = Date.newInstance(2018, 06, 05),
			report_date__c = system.today(),
			mdr_event_description__c = 'test test test',
			//section D
			asset__c = theAsset.Id,
			asset_lot_number__c = batchNo,
			expiration_date__c = expireDate,
			asset_serial_number__c = theAsset.SerialNumber,
			asset_implant_date__c = Date.newInstance(2012, 06, 01),
			explant_date__c = explantDate,//Date.newInstance(2018, 06, 01),
			device_available_for_evaluation__c = 'yes',
			date_product_returned_to_manufacturer__c = Date.newInstance(2018, 06, 02),

	        //Medwatch Section E
			initial_reporter_user__c = Userinfo.getUserId(),
			initial_reporter_also_sent_report_to_fda__c = 'NO',

			//Medwatch Section F
			patient_code_global__c = null,
			device_code_global__c = null,
			//Medwatch Section G
			report_source__c = 'HealthProfessional',
			pma_510k__c = prod.pma__c,
			type_of_report__c = 'Initial',
			type_of_report_follow_up__c = 0,
			//Medwatch Section H
			type_of_reportable_event__c = 'Malfunction',
			if_follow_up_what_type__c = 'AdditionalInformationReport',
			evaluation_summary_attached__c = false,
			date_of_manufacture__c = manDate,//Date.newInstance(2009, 01, 01),
			labeled_for_single_use__c = true,
			usage_of_device__c = 'InitialUsage',
			additional_manufacturer_narrative__c = null,
			corrected_data_comment__c = null,
			mdr_decision__c = 'File MDR within 30 calendar day.'
		);
		coms.add(theCom);
		complaint__c notherCom = theCom.clone();
        notherCom.asset__c = notherAsset.Id;
		notherCom.asset_model_name__c = notherProd.Name;
		notherCom.asset_model_number__c = notherProd.ProductCode;
		notherCom.case__c = notherCase.Id;
		notherCom.ci_number__c = 'CI-2018-77778';
		notherCom.date_of_birth__c = notherPatient.BirthDate;
		notherCom.gender__c = notherPatient.gender__c;
		notherCom.mdr_number__c = 'MDR-102832-2018-77778';
		notherCom.pma_510k__c = notherProd.pma__c;
		notherCom.procode__c = notherProd.ProductCode;
		notherCom.asset_serial_number__c = notherAsset.SerialNumber;

		coms.add(notherCom);
		insert coms;

		List<Analysis_Report__c> ars = new List<Analysis_Report__c>();
        List<String> recIds = config.test_emdr_recordids__c.split(';');
		Analysis_Report__c ar = new Analysis_Report__c(
			RecordTypeId = Schema.SObjectType.Analysis_Report__c.getRecordTypeInfosByDeveloperName().get(config.analysis_report_emdr_rectype__c).getRecordTypeId(),
			complaint__c = theCom.Id,
            external_id__c = recIds[0],
			additional_manufacturer_narrative__c = true,
			analysis_results__c = 'test',
			conclusion_code__c = null,
			device_evaluated_by_manufacturer__c = 'Yes',
			EMDR_Status__c = config.analysis_report_status_submitted__c,
            evaluated_by_manufacturer_explanation__c = 'test',
			//external_id__c = '1028232-2018-799395',
			if_follow_up_what_type__c = null,
			manufacturer_event_description__c = 'test test',
			date_sent_to_fda__c = null,
			method_code__c = null,
			result_code__c = null
		);
		ars.add(ar);
		Analysis_Report__c ar2 = ar.clone();
		ar2.complaint__c = notherCom.Id;
		ar2.external_id__c = recIds[1];//'1028232-2018-7998007';
        ars.add(ar2);
		insert ars;
        for (complaint__c com : coms) {
            //do something
			com.approval_status__c = config.status_submit_to_emdr_ok__c;
        }
        update coms;
	}
}