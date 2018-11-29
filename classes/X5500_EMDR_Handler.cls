/*
Handler class to support process of submitting Complaint data to US FDA in EMDR format
Contains callout to BIOTRONIK webservice for EMDR intake.
@author	Mike Tribble
@revised 06/20/18 created
@revised 07/29/18 fixes for re-submission of failed reports
@revised 08/20/18 getComplaints(): changed c.asset__r.Product2.manufacturer_account__r.shippingcountry/shippingstate to c.asset__r.Product2.manufacturer_account__r.shippingcountrycode/shippingstatecode
*/
public class X5500_EMDR_Handler {

	//runtime configs
	private final String configName = 'EMDR_Config';
	private X5500_EMDRConfig__mdt config;
	private final String msgSuccess = 'success';
	private Class EMDRException extends Exception{}
	public boolean testException {get;set;}

	public X5500_EMDR_Handler() {
		//set runtime configs
		this.config= [SELECT x.Id, x.DeveloperName,
			x.analysis_report_emdr_rectype__c, x.g1_contact_city__c, x.g1_contact_country_code__c,
			x.g1_contact_facility_name__c, x.g1_contact_state_code__c, x.g1_contact_street__c,
			x.g1_contact_telecom__c, x.g1_contact_zip_code__c, x.mdr_prefix__c,
			x.status_fda_pass__c, x.status_fda_fail__c,
			x.status_final_fail__c, x.status_final_pass__c, x.status_submit_to_emdr_fail__c,
			x.status_submit_to_emdr_ok__c, x.analysis_report_status_submitted__c,
			x.status_submit_to_emdr_ready__c, x.ws_endpoint_fdastatus__c, x.ws_endpoint_submit__c,
			x.ws_password__c, x.ws_username__c, x.occupation__c
			From X5500_EMDRConfig__mdt x
			WHERE x.DeveloperName =: this.configName];

		this.testException = false;
	}

	/*
	Specific date formatting for Web service
	*/
	public static String formatEMDRDate(Date inDate) {
		String outDate;
		String dy = String.valueOf(inDate.day());
		dy = (dy.length()<2 ? dy = '0'+dy : dy);
		integer iMo = inDate.month();
		String mo = (iMo == 1 ? 'JAN' : iMo == 2 ? 'FEB' : iMo == 3 ? 'MAR' : iMo == 4 ? 'APR' : iMo == 5 ? 'MAY' : iMo == 6 ? 'JUN' : iMo == 7 ? 'JUL' : iMo == 8 ? 'AUG' : iMo == 9 ? 'SEP' : iMo == 10 ? 'OCT' : iMo == 11 ? 'NOV' : 'DEC' );
		String yr = String.valueOf(inDate.year());
		outDate = yr + '-' + mo + '-' + dy;
		return outDate;
	}

	/*
	get list of EMDRs to submit
	*/
	public List<X5500_EMDR> getEMDRList() {
		//get complaints approved for submission
		List<Complaint__c> comList = getComplaints(this.config.status_submit_to_emdr_ready__c);
		List<X5500_EMDR> emdrList = new List<X5500_EMDR>();
		for (complaint__c thisCom : comList) {
			//get most recent analysis report attached to the complaint
			Analysis_Report__c thisAR = new Analysis_Report__c();
			// @TODO SOQL in loop! bad practice, could be solved by a subquery in getComplaints method!
			List<Analysis_Report__c> theseAR = [SELECT
					a.Id, a.additional_manufacturer_narrative__c, a.analysis_results__c, a.complaint__c,
					a.conclusion_code__c,a.date_mdr_prepared__c,
					//a.date_of_last_transmission_to_can__c, //has been deleted SAFBIO-2073- point 4
					a.date_sent_to_fda__c, a.device_evaluated_by_manufacturer__c,
					a.evaluated_by_manufacturer_explanation__c, a.external_id__c,
					a.method_code__c,
					a.result_code__c
			FROM Analysis_Report__c a
			WHERE a.RecordType.DeveloperName !=: this.config.analysis_report_emdr_rectype__c
			AND a.complaint__c =: thisCom.Id
			ORDER BY a.LastModifiedDate desc
			LIMIT 1];
			thisAR = (theseAR == null  || theseAR.isEmpty() ? thisAR : theseAR[0]);
			X5500_EMDR thisEMDR = new X5500_EMDR(thisCom, thisAR, this.config);
			emdrList.add(thisEMDR);
		}
		return emdrList;
	}
	/*
	get a list with a specific single EMDR to submit
	*/
	public List<X5500_EMDR> getSingleEMDRList(Id complaintId) {
		//get complaints approved for submission
		List<Complaint__c> comList = getComplaint(complaintId, this.config.status_submit_to_emdr_ready__c);
		List<X5500_EMDR> emdrList = new List<X5500_EMDR>();
		for (complaint__c thisCom : comList) {
			//get most recent analysis report attached to the complaint
			Analysis_Report__c thisAR = new Analysis_Report__c();
			List<Analysis_Report__c> theseAR = [SELECT
					a.Id, a.additional_manufacturer_narrative__c, a.analysis_results__c, a.complaint__c,
					a.conclusion_code__c,a.date_mdr_prepared__c,
					//a.date_of_last_transmission_to_can__c, //has been deleted SAFBIO-2073- point 4
					a.date_sent_to_fda__c, a.device_evaluated_by_manufacturer__c,
					a.evaluated_by_manufacturer_explanation__c, a.external_id__c,
					a.method_code__c,
					a.result_code__c
			FROM Analysis_Report__c a
			WHERE a.RecordType.DeveloperName !=: this.config.analysis_report_emdr_rectype__c
			AND a.complaint__c =: thisCom.Id
			ORDER BY a.LastModifiedDate desc
			LIMIT 1];
			thisAR = (theseAR == null  || theseAR.isEmpty() ? thisAR : theseAR[0]);
			X5500_EMDR thisEMDR = new X5500_EMDR(thisCom, thisAR, this.config);
			emdrList.add(thisEMDR);
		}
		return emdrList;
	}

	/*
	get list of complaint records of specified status
	Limit to 20 at a time due to governor limits
	*/
	private List<complaint__c> getComplaints(String status) {
		List<complaint__c> complaintList = [SELECT c.approval_status__c,
				//Medwatch Section A
				c.patient_identifier__c, c.date_of_birth__c, c.gender__c, c.patient_weight__c, c.ethnicity__c, c.race__c,
				//Medwatch Section B
				c.adverse_event__c, c.product_problem__c,
				c.date_of_death__c, c.outcome_attributed_to_adverse_event__c,
				c.date_of_event__c, c.report_date__c, c.followup_report_date__c, c.mdr_event_description__c,
				//Medwatch Section D
				c.asset__r.Name, c.asset__r.product_type__c,
				//c.asset__r.Product2.Family,
				c.asset__r.Product2.ProductCode,
				c.asset__r.Product2.manufacturer_account__r.Name,
				c.asset__r.Product2.manufacturer_account__r.shippingcity,
				c.asset__r.Product2.manufacturer_account__r.shippingstatecode,
				c.asset__r.Product2.manufacturer_account__r.shippingpostalcode,
				c.asset__r.Product2.manufacturer_account__r.shippingcountrycode,
				c.asset_model_number__c, c.asset_lot_number__c, c.expiration_date__c, c.asset_serial_number__c, c.asset__r.UDI__c,
				c.asset_implant_date__c, c.explant_date__c, c.device_available_for_evaluation__c,
				c.date_product_returned_to_manufacturer__c,
				//Medwatch Section E
				c.initial_reporter_user__r.CompanyName, c.initial_reporter_user__r.FirstName,
				c.initial_reporter_user__r.LastName,
				c.initial_reporter_user__r.Street, c.initial_reporter_user__r.City,
				c.initial_reporter_user__r.StateCode, c.initial_reporter_user__r.PostalCode,
				c.initial_reporter_user__r.CountryCode, c.initial_reporter_user__r.health_professional__c,
				c.initial_reporter_user__r.title,
				c.initial_reporter_also_sent_report_to_fda__c,
				//Medwatch Section F
				c.patient_code_global__c, c.device_code_global__c,
				//Medwatch Section G
				c.mdr_report_date__c, c.type_of_report__c, mdr_decision__c,
				c.report_source__c, c.pma_510k__c, date_info_received_by_manufacturer__c,
				//Medwatch Section H
				c.type_of_report_follow_up__c, c.mdr_number__c,
				c.type_of_reportable_event__c,
				c.if_follow_up_what_type__c,
				c.evaluation_summary_attached__c, c.date_of_manufacture__c, c.labeled_for_single_use__c, remedial_action_type__c,
				c.usage_of_device__c, c.additional_manufacturer_narrative__c, c.corrected_data_comment__c
		FROM complaint__c c
		WHERE c.approval_status__c =: status
		ORDER BY c.LastModifiedDate DESC
		LIMIT 20];
		return complaintList;
	}


	/*
	get a specific complaint
	@TODO refactor - duplicate code!
	*/
	private List<complaint__c> getComplaint(Id complaintId, String status) {
		List<complaint__c> complaintList = [SELECT c.approval_status__c,
				//Medwatch Section A
				c.patient_identifier__c, c.date_of_birth__c, c.gender__c, c.patient_weight__c, c.ethnicity__c, c.race__c,
				//Medwatch Section B
				c.adverse_event__c, c.product_problem__c,
				c.date_of_death__c, c.outcome_attributed_to_adverse_event__c,
				c.date_of_event__c, c.report_date__c, c.followup_report_date__c, c.mdr_event_description__c,
				//Medwatch Section D
				c.asset__r.Name, c.asset__r.product_type__c,
				//c.asset__r.Product2.Family,
				c.asset__r.Product2.ProductCode,
				c.asset__r.Product2.manufacturer_account__r.Name,
				c.asset__r.Product2.manufacturer_account__r.shippingcity,
				c.asset__r.Product2.manufacturer_account__r.shippingstatecode,
				c.asset__r.Product2.manufacturer_account__r.shippingpostalcode,
				c.asset__r.Product2.manufacturer_account__r.shippingcountrycode,
				c.asset_model_number__c, c.asset_lot_number__c, c.expiration_date__c, c.asset_serial_number__c, c.asset__r.UDI__c,
				c.asset_implant_date__c, c.explant_date__c, c.device_available_for_evaluation__c,
				c.date_product_returned_to_manufacturer__c,
				//Medwatch Section E
				c.initial_reporter_user__r.CompanyName, c.initial_reporter_user__r.FirstName,
				c.initial_reporter_user__r.LastName,
				c.initial_reporter_user__r.Street, c.initial_reporter_user__r.City,
				c.initial_reporter_user__r.StateCode, c.initial_reporter_user__r.PostalCode,
				c.initial_reporter_user__r.CountryCode, c.initial_reporter_user__r.health_professional__c,
				c.initial_reporter_user__r.title,
				c.initial_reporter_also_sent_report_to_fda__c,
				//Medwatch Section F
				c.patient_code_global__c, c.device_code_global__c,
				//Medwatch Section G
				c.mdr_report_date__c, c.type_of_report__c, mdr_decision__c,
				c.report_source__c, c.pma_510k__c, date_info_received_by_manufacturer__c,
				//Medwatch Section H
				c.type_of_report_follow_up__c, c.mdr_number__c,
				c.type_of_reportable_event__c,
				c.if_follow_up_what_type__c,
				c.evaluation_summary_attached__c, c.date_of_manufacture__c, c.labeled_for_single_use__c, remedial_action_type__c,
				c.usage_of_device__c, c.additional_manufacturer_narrative__c, c.corrected_data_comment__c
		FROM complaint__c c
		WHERE Id = :complaintId AND c.approval_status__c =: status
		LIMIT 1];
		return complaintList;
	}

	/*
	call this method from relevant events
	such as complaint approval, submit EMDR button
	*/
	public void submitEMDRs() {
		X5500_EMDR_Submit_Callout.HTTPS_Port emdrws = new X5500_EMDR_Submit_Callout.HTTPS_Port(this.config.ws_endpoint_submit__c, this.config.ws_username__c, this.config.ws_password__c);
		try {
			X5500_EMDR_Submit_Callout.Req_Message req = new X5500_EMDR_Submit_Callout.Req_Message();
			List<X5500_EMDR> inputList = getEMDRList();
			if (inputList.size() > 0) {
				req.rows = inputList;
				//callout to web service
				X5500_EMDR_Submit_Callout.Resp_Message resp = emdrws.osEMDR(req);
				processSubmitCallOutReturn(resp);
			}
			if (this.testException) throw new EMDRException('test');
		} catch(EMDRException exc) {
			//create task for running user with exception details
			Task notice = new Task(
					OwnerId =UserInfo.getUserId(),
					ActivityDate = Date.today(),
					Status = 'Not Started',
					Subject = 'EMDR Transmission Failure',
					Description = 'EMDR transmissions failed.\n\nDetail:\n' + exc.getMessage(),
					Priority = 'High'
			);
			throw new EMDRException(exc.getMessage());
		}
	}


	/*
	submits a single complaint
	*/
	public void submitEMDR(Id complaintId) {
		X5500_EMDR_Submit_Callout.HTTPS_Port emdrws = new X5500_EMDR_Submit_Callout.HTTPS_Port(this.config.ws_endpoint_submit__c, this.config.ws_username__c, this.config.ws_password__c);
		try {
			X5500_EMDR_Submit_Callout.Req_Message req = new X5500_EMDR_Submit_Callout.Req_Message();
			List<X5500_EMDR> inputList = getSingleEMDRList(complaintId);
			if (inputList.size() > 0) {
				req.rows = inputList;
				//callout to web service
				X5500_EMDR_Submit_Callout.Resp_Message resp = emdrws.osEMDR(req);
				processSubmitCallOutReturn(resp);
			}
			if (this.testException) throw new EMDRException('test');
		} catch(EMDRException exc) {
			//create task for running user with exception details
			Task notice = new Task(
					OwnerId = UserInfo.getUserId(),
					ActivityDate = Date.today(),
					Status = 'Not Started',
					Subject = 'EMDR Transmission Failure',
					Description = 'EMDR transmissions failed.\n\nDetail:\n' + exc.getMessage(),
					Priority = 'High'
			);
			throw new EMDRException(exc.getMessage());
		}
	}

	/*
	Process results of call to web service
	1) parse through messages received in EMDR_Resp
		ws returns three pieces of data:
			A) the id of the originating complaint
			B) status of the requested operation (success/fail)
			C) database id of record in EMDR system (if successful)
	2) write status to new Analysis Report for parent complaint
	3) if success update parent status to approved by FDA
	*/
	private void processSubmitCallOutReturn(X5500_EMDR_Submit_Callout.Resp_Message results) {
		boolean success = true;
		String failures = '';
		for (X5500_EMDR_Submit_Callout.resp_element result : results.rows) {
			String complaintId = (result.emdr_recordid != null ? result.emdr_recordid : '');
			complaint__c com = [SELECT Id, approval_status__c, emdr_record_ids__c, mdr_number__c, OwnerId
			FROM complaint__c
			WHERE Id =: complaintId];
			List<String> msg_part = (result.message != null ? result.message.split(':') : new List<String> {null,null});
			if (msg_part[0] != null && msg_part[0] == 'success') {//emdr successfully transmitted
				//remote system record id has to be parsed out of the message
				String recordId = msg_part[1].split('=')[1];
				//set approval status to submitted (to emdr system)
				com.approval_status__c = config.status_submit_to_emdr_ok__c;
				//get the ids of the records in the remote system
				com.emdr_record_ids__c = (com.emdr_record_ids__c == null || com.emdr_record_ids__c.length() == 0 ?  recordId : com.emdr_record_ids__c + ';' + recordId);

				//Attach Analysis Report with EMDR details
				Analysis_Report__c ar = new Analysis_Report__c(
						external_id__c = recordId,
						date_sent_to_fda__c = System.now(),
						complaint__c = complaintId,
						RecordTypeId = Schema.SObjectType.Analysis_Report__c.getRecordTypeInfosByDeveloperName().get(config.analysis_report_emdr_rectype__c).getRecordTypeId(),
						EMDR_Status__c = config.analysis_report_status_submitted__c
				);
				//use upsert to cover re-submission case
				upsert ar;

			} else {//transmission failed
				success = false;
				String reason = (msg_part[1] != null ? msg_part[1] : '');
				failures = failures + (failures.length()>0?'|':'') + 'complaintId:'+complaintId+'reason:'+reason;
				com.approval_status__c = config.status_submit_to_emdr_fail__c;
				//notify complaint owner
				Task notice			= new Task(
						OwnerId			= com.OwnerId,
						ActivityDate	= Date.today(),
						Status			= 'Not Started',
						Subject			= 'EMDR Submission Failure',
						Description		= 'EMDR Sysem reported a failure on submission of report # '+ com.mdr_number__c +'.\n\nDetail:\n' + failures,
						Priority		= 'High'
				);
			}
			update com;
			if (!success) throw new EMDRException('Remote system failed to process one or more transmitted records: ' + failures);
		}
	}

	/*
	return list of remote EMDR system ids given status of Analysis Result objects
	*/
	private List<String> getEMDRIdsByStatus(String status) {
		List<String> recIds = new List<String>();
		List<Analysis_Report__c> arList = [Select Id, complaint__c, external_id__c
		From Analysis_Report__c
		WHERE EMDR_Status__c =: status
		AND RecordType.DeveloperName =: this.config.analysis_report_emdr_rectype__c
		ORDER BY LastModifiedDate
		LIMIT 20];

		for (Analysis_Report__c ar : arList) {
			recIds.add(ar.external_id__c);
		}
		return recIds;
	}

	/*
	return list of remote EMDR system ids given status of Analysis Result objects
	*/
	private String
	getExternalIdByComplaintId(Id complaintId) {
		List<String> recIds = new List<String>();
		List<Analysis_Report__c> arList = [Select external_id__c
		From Analysis_Report__c
		WHERE complaint__c = :complaintId
		AND RecordType.DeveloperName =: this.config.analysis_report_emdr_rectype__c
		ORDER BY LastModifiedDate
		LIMIT 1];

		for (Analysis_Report__c ar : arList) {
			return ar.external_id__c;
		}
		return null;
	}

	/*
	get status of remote EMDR records via web service callout
	then write back results to Analysis Report record
	*/
	public void getEMDRStatus() {
		X5500_EMDR_Status_Callout.HTTPS_Port ws = new X5500_EMDR_Status_Callout.HTTPS_Port(this.config.ws_endpoint_fdastatus__c, this.config.ws_username__c, this.config.ws_password__c);
		try {
			//get list of records that need updates
			if (this.testException) throw new EMDRException('test');
			List<String> recIds = getEMDRIdsByStatus(this.config.analysis_report_status_submitted__c);
			//compose ws request message
			X5500_EMDR_Status_Callout.Req_Message req = new X5500_EMDR_Status_Callout.Req_Message();
			List<X5500_EMDR_Status_Callout.Req_Element> req_els = new List<X5500_EMDR_Status_Callout.Req_Element>();
			for (String recId : recIds) {
				X5500_EMDR_Status_Callout.req_element re = new X5500_EMDR_Status_Callout.req_element();
				re.emdrid = recId;
				req_els.add(re);
			}
			req.row = req_els;
			//callout to web service
			X5500_EMDR_Status_Callout.Resp_Message resp = ws.osFDA_Message(req);
			processStatusCallOutReturn(resp);
		} catch(EMDRException exc) {
			//create task for running user with exception details
			Task notice = new Task(
					OwnerId =UserInfo.getUserId(),
					ActivityDate = Date.today(),
					Status = 'Not Started',
					Subject = 'EMDR Status Interface Failure',
					Description = 'An exception occurred in the EMDR Status interface. Please notify the administrator.\n\nDetail:\n' + exc.getMessage(),
					Priority = 'High'
			);
			throw new EMDRException(exc.getMessage());
		}
	}


	/*
	get status of a single remote EMDR record via web service callout
	then write back results to Analysis Report record
	SAFBIO-2410
	*/
	public void getEMDRStatusSingle(Id complaintId) {
		X5500_EMDR_Status_Callout.HTTPS_Port ws = new X5500_EMDR_Status_Callout.HTTPS_Port(this.config.ws_endpoint_fdastatus__c, this.config.ws_username__c, this.config.ws_password__c);
		try {
			//get list of records that need updates
			if (this.testException) throw new EMDRException('test');
			String externalId = getExternalIdByComplaintId(complaintId);

			if(externalId == null){
				throw new EMDRException('No Analysis Result found!');
			}
			//compose ws request message
			X5500_EMDR_Status_Callout.Req_Message req = new X5500_EMDR_Status_Callout.Req_Message();

			List<X5500_EMDR_Status_Callout.Req_Element> req_els = new List<X5500_EMDR_Status_Callout.Req_Element>();
			X5500_EMDR_Status_Callout.req_element re = new X5500_EMDR_Status_Callout.req_element();
			re.emdrid = externalId;
			req_els.add(re);

			req.row = req_els;
			//callout to web service
			X5500_EMDR_Status_Callout.Resp_Message resp = ws.osFDA_Message(req);
			processStatusCallOutReturn(resp);
		} catch(EMDRException exc) {
			//create task for running user with exception details
			Task notice = new Task(
					OwnerId =UserInfo.getUserId(),
					ActivityDate = Date.today(),
					Status = 'Not Started',
					Subject = 'EMDR Status Interface Failure',
					Description = 'An exception occurred in the EMDR Status interface. Please notify the administrator.\n\nDetail:\n' + exc.getMessage(),
					Priority = 'High'
			);
			throw new EMDRException(exc.getMessage());
		}
	}

	/*
	Process results of call to EMDR Status web service
	for each message in response:
		1) retrieve the Analysis Result and parent Complaint records to update
		2) Update status fields on Analysis Result and Complaint records
		3) If failure notify owner of complaint record
	*/
	private void processStatusCallOutReturn(X5500_EMDR_Status_Callout.Resp_Message results) {
		boolean success = true;
		String failures = '';
		for (X5500_EMDR_Status_Callout.resp_element result : results.row) {

			Analysis_Report__c ar = [SELECT complaint__c, EMDR_Status__c,
					fda_response__c, fda_response_date__c, Id, LastModifiedDate
			FROM Analysis_Report__c
			WHERE external_id__c =: result.recordid];

			complaint__c com = [SELECT Id, LastModifiedDate,
					approval_status__c, mdr_number__c, OwnerId
			FROM complaint__c
			WHERE Id =: ar.complaint__c];

			//update Analysis Report with status summary
			//only update status if final results in
			ar.EMDR_Status__c		= (ar.fda_response__c  != null ? result.submit_status : ar.EMDR_Status__c);
			//apex doesn't like milliseconds
			ar.date_sent_to_fda__c	= (result.date_sent_to_fda == null || result.date_sent_to_fda.length() < 8 ? null : result.date_sent_to_fda.indexOf('//.') != -1 ? Datetime.valueOf( result.date_sent_to_fda.split('\\.')[0]) : Datetime.valueOf( result.date_sent_to_fda));
			ar.fda_response_date__c	= (result.date_fda_response == null || result.date_fda_response.length() < 8 ? null : result.date_fda_response.indexOf('//.') != -1 ? Datetime.valueOf( result.date_fda_response.split('\\.')[0]) : Datetime.valueOf( result.date_fda_response));
			ar.fda_response__c		= result.fda_final_status;
			update ar;

			//attach a note with full status detail
			Note theNote = new Note(
					ParentId = ar.Id,
					Title = 'EMDR Status Detail ' + String.valueOf(System.now())
			);
			String detail = 'EMDR Status Detail as of :' + String.valueOf(system.now()) + '\n';
			detail += '\nSubmit Number:\t' + (result.submit_number == null ? '' : result.submit_number);
			detail += '\nSubmit Status:\t' + (result.submit_status == null ? '' : result.submit_status);
			detail += '\nESG Status:\t' + (result.esg_status == null ? '' : result.esg_status);
			detail += '\nFDA Final Status:\t' + (result.fda_final_status == null ? '' : result.fda_final_status);
			detail += '\nDate EMDR Created:\t' + (result.date_emdr_initialized == null ? '' : result.date_emdr_initialized);
			detail += '\nDate Sent to FDA:\t' + (result.date_sent_to_fda == null ? '' : result.date_sent_to_fda);
			detail += '\nDate FDA Responded:\t' + (result.date_fda_response == null ? '' : result.date_fda_response);
			theNote.Body = detail;
			insert theNote;

			//notify complaint owner if FDA rejects submissions
			if (result.fda_final_status == this.config.status_final_fail__c) {
				success = false;
				failures = failures + (failures.length()>0?'|':'') + 'EMDR Record Id:'+result.sourceid;
				com.approval_status__c = this.config.status_fda_fail__c;
				Task notice = new Task(
						OwnerId = com.OwnerId,
						ActivityDate = Date.today(),
						Status = 'Not Started',
						Subject = 'EMDR Rejected By FDA',
						Description = 'The FDA has rejected your recent EMDR submission of report #.' + com.mdr_number__c + ' Please see the Analysis Result record for details.',
						Priority = 'High'
				);
			} else if (result.fda_final_status == this.config.status_final_pass__c) {
				com.approval_status__c = this.config.status_fda_pass__c;
			}
			update com;
		}
		if (!success) throw new EMDRException('One or more EMDRs did not pass FDA validation: ' + failures);
	}
}