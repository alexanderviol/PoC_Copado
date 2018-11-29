/*
WSDL2Apex Generated class from SAP PI webservice used for intake of EMDR data.
@author	Mike Tribble
@revised 06/20/18 created
*/
public with sharing class X5500_EMDR_Submit_Callout {

	/*
	container that is sent to the endpoint
	*/
	public class Req_Message {
		public X5500_EMDR[] rows;
		private String[] rows_type_info = new String[]{'rows','http://SFDC.biotronik.com',null,'1','-1','false'};
		private String[] apex_schema_type_info = new String[]{'http://SFDC.biotronik.com','false','false'};
		private String[] field_order_type_info = new String[]{'rows'};
	}

	/*
	container (EMDR) payload
	see X5500_EMDR
	*/

	/*
	response from remote procedure
	*/
	public class Resp_Message {
		public X5500_EMDR_Submit_Callout.resp_element[] rows;
		private String[] rows_type_info = new String[]{'rows','http://SFDC.biotronik.com',null,'1','-1','false'};
		private String[] apex_schema_type_info = new String[]{'http://SFDC.biotronik.com','false','false'};
		private String[] field_order_type_info = new String[]{'rows'};
	}

	/*
	response elements
	*/
	public class resp_element {
		public String emdr_recordid;//complaint record id
		public String message;//result message of the procedure (success/fail + remote record id)
		private String[] emdr_recordid_type_info = new String[]{'emdr_recordid','http://SFDC.biotronik.com',null,'0','1','false'};
		private String[] message_type_info = new String[]{'message','http://SFDC.biotronik.com',null,'0','1','false'};
		private String[] apex_schema_type_info = new String[]{'http://SFDC.biotronik.com','false','false'};
		private String[] field_order_type_info = new String[]{'emdr_recordid','message'};
	}

	public class HTTPS_Port {
		public String endpoint_x;
		public Map<String,String> inputHttpHeaders_x;
		public Map<String,String> outputHttpHeaders_x;
		public String clientCertName_x;
		public String clientCert_x;
		public String clientCertPasswd_x;
		public Integer timeout_x;
		private String[] ns_map_type_info = new String[]{'http://SFDC.biotronik.com', 'X5500_EMDR_Submit_Callout'};

		/*
		constructor to add Basic authentication to http header
		*/
		public HTTPS_PORT(String endpoint, String username, String password) {
			this.endpoint_x = endpoint;
			this.inputHttpHeaders_x = new Map<String, String>();
			String strAuth = username + ':' + password;
			Blob bAuth = Blob.valueOf(strAuth);
			String strHeaderAuth = 'Basic ' + EncodingUtil.base64Encode(bAuth);
			this.inputHttpHeaders_x.put('Authorization', strHeaderAuth);
		}

		/*
		Send Request to Endpoint (callout)
		*/
		//public X5500_EMDR_Submit_Callout.Resp_Message osEMDR(X5500_EMDR[] rows) {
		public X5500_EMDR_Submit_Callout.Resp_Message osEMDR(X5500_EMDR_Submit_Callout.Req_Message request_x) {
			//X5500_EMDR_Submit_Callout.EMDR request_x = new X5500_EMDR_Submit_Callout.EMDR();
			//request_x.rows = rows;
			X5500_EMDR_Submit_Callout.Resp_Message response_x;
			Map<String, X5500_EMDR_Submit_Callout.Resp_Message> response_map_x = new Map<String, X5500_EMDR_Submit_Callout.Resp_Message>();
			response_map_x.put('response_x', response_x);
			WebServiceCallout.invoke(this,
				request_x,
				response_map_x,
				new String[]{endpoint_x,
					'http://sap.com/xi/WebService/soap1.1',
					'http://SFDC.biotronik.com',
					'EMDR',
					'http://SFDC.biotronik.com',
					'EMDR_Resp',
					'X5500_EMDR_Submit_Callout.Resp_Message'
				}
			);
			response_x = response_map_x.get('response_x');
			return response_x;
		}
	}
}