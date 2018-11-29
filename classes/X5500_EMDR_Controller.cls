/**
controller behind EMDR submit button
@author Mike Tribble
@revised 06/20/18 created
*/
public with sharing class X5500_EMDR_Controller {

	/*
	submit manually from lightning button
	*/
	@AuraEnabled
	public static String submitFromButton() {
		String status = 'success';
		try {
			X5500_EMDR_Handler handler = new X5500_EMDR_Handler();
			handler.submitEMDRs();
		} catch(Exception exc) {
			System.debug('X5500_EMDR_Controller.submitFromButton(): an exception occurred: ' + exc.getMessage());
			status = 'fail: ' + exc.getMessage();
		}
		return status;
	}

	/*
	submit single record manually from lightning button
	*/
	@AuraEnabled
	public static String submitSingleFromButton(Id complaintId) {
		String status = 'success';
		try {
			X5500_EMDR_Handler handler = new X5500_EMDR_Handler();
			handler.submitEMDR(complaintId);
		} catch(Exception exc) {
			System.debug('X5500_EMDR_Controller.submitSingleFromButton(): an exception occurred: ' + exc.getMessage());
			status = 'fail: ' + exc.getMessage();
		}
		return status;
	}

	/*
	submit EMDR on some event
	*/
	@future(callout=true)
	public static void submitFromTrigger() {
		try {
			X5500_EMDR_Handler handler = new X5500_EMDR_Handler();
			handler.submitEMDRs();
		} catch(Exception exc) {
			System.debug('X5500_EMDR_Controller.submitFromTrigger(): exception occurred: ' + exc.getMessage());
		}
	}

	/*
	get EMDR status on button click
	*/
	@AuraEnabled
	public static String getStatus() {
		String status = 'success';
		try {
			X5500_EMDR_Handler handler = new X5500_EMDR_Handler();
			handler.getEMDRStatus();
		} catch(Exception exc) {
			System.debug('X5500_EMDR_Controller.getStatus(): exception occurred: ' + exc.getMessage());
			status = 'fail: ' + exc.getMessage();
		}
		return status;
	}

	/*
	get single EMDR status on button click
	*/
	@AuraEnabled
	public static String getStatusSingleFromButton(Id complaintId) {
		String status = 'success';
		try {
			X5500_EMDR_Handler handler = new X5500_EMDR_Handler();
			handler.getEMDRStatusSingle(complaintId);
		} catch(Exception exc) {
			System.debug('X5500_EMDR_Controller.getStatus(): exception occurred: ' + exc.getMessage());
			status = 'fail: ' + exc.getMessage();
		}
		return status;
	}

	/*
	get EMDR status on some event
	*/
/*
	@future(callout=true)
	public static void getStatusFromTrigger() {
		try {
			X5500_EMDR_Handler handler = new X5500_EMDR_Handler();
			handler.getEMDRStatus();
		} catch(Exception exc) {
			System.debug('X5500_EMDR_Controller.getStatus(): exception occurred: ' + exc.getMessage());
		}
	}
*/
}