/**
Simulate return from remote web service for code coverage
@author	Mike Tribble
@revised 06/20/18 created
*/
@isTest
global class X5500_EMDR_Submit_Callout_Mock implements WebServiceMock {
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
			x.status_submit_to_emdr_ready__c
			From X5500_EMDRConfig__mdt x
			WHERE x.DeveloperName =: 'EMDR_Config'];

		List<complaint__c> comList = [SELECT Id
			FROM complaint__c
			WHERE approval_status__c =: config.status_submit_to_emdr_ready__c];

        // mock response to return when testing
		X5500_EMDR_Submit_Callout.Resp_Message response_x = new X5500_EMDR_Submit_Callout.Resp_Message();
		response_x.rows = new List<X5500_EMDR_Submit_Callout.resp_element>();
		//set up pretend responses to correspond to the test records inserted
		Integer i = 0;
		for (complaint__c com : comList) {
			i++;
			X5500_EMDR_Submit_Callout.resp_element re = new X5500_EMDR_Submit_Callout.resp_element();
			re.emdr_recordid=com.Id;
			//fail every other message
			re.message = (math.mod(i,2)==1 ? 'success:recordid='+i : 'fail:because why not');
			response_x.rows.add(re);
		}
		response.put('response_x', response_x);
	}
}