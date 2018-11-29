/**
Simulate return from remote web service for code coverage
@author	Mike Tribble
@revised 07/09/18 created
*/
@isTest
global class X5500_EMDR_Status_Callout_Mock implements WebServiceMock {

    global void doInvoke(
		Object stub,
		Object request,
		Map<String, Object> response,
		String endpoint,
		String soapAction,
		String requestName,
		String responseNS,
		String responseName,
		String responseType) {

		X5500_EMDRConfig__mdt config = [SELECT x.Id,
			x.test_emdr_recordids__c
			From X5500_EMDRConfig__mdt x
			WHERE x.DeveloperName =: 'EMDR_Config'];

		List<String> recIds = config.test_emdr_recordids__c.split(';');

		// mock response to return when unit testing
		X5500_EMDR_Status_Callout.Resp_Message response_x = new X5500_EMDR_Status_Callout.Resp_Message();
		response_x.row = new List<X5500_EMDR_Status_Callout.Resp_Element>();
		//set up pretend responses to correspond to the test records inserted
		Integer i = 0;
		for (String recId : recIds) {
			i++;
            X5500_EMDR_Status_Callout.Resp_Element re = new X5500_EMDR_Status_Callout.Resp_Element();
			re.recordid=recId;
			re.reportid='test';
			re.sourceid=recId;
            re.submit_status = 'Submitted';
			re.submit_number = String.valueOf(i);
			re.esg_status = (math.mod(i,2)==1 ? 'Passed' : 'failed');
			re.fda_final_status = (math.mod(i,2)==1 ? 'Passed' : 'failed');
			re.date_emdr_initialized = String.valueOf(system.now().addMinutes(-30));
			re.date_sent_to_fda = String.valueOf(system.now().addMinutes(-20));
			re.date_fda_response = String.valueOf(system.now().addMinutes(-10));
			response_x.row.add(re);
		}
		response.put('response_x', response_x);
	}
}