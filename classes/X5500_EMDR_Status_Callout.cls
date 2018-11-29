/*
WSDL2Apex Generated class from SAP PI webservice used for retrieving FDA Response data from BIOTRONIK EMDR database.
@author	Mike Tribble
@revised 07/09/18 created
*/
public class X5500_EMDR_Status_Callout {

    /*
     * The request message
	*/
//	public class EMDRStatus_Req {
	public class Req_Message {
		public X5500_EMDR_Status_Callout.Req_Element[] row;
		private String[] row_type_info = new String[]{'row','http://SFDC.biotronik.com',null,'1','-1','false'};
		private String[] apex_schema_type_info = new String[]{'http://SFDC.biotronik.com','false','false'};
		private String[] field_order_type_info = new String[]{'row'};
	}

	/*
	* request message element
	*/
	public class Req_Element {
		public String emdrid;
		private String[] emdrid_type_info = new String[]{'emdrid','http://SFDC.biotronik.com',null,'1','1','false'};
		private String[] apex_schema_type_info = new String[]{'http://SFDC.biotronik.com','false','false'};
		private String[] field_order_type_info = new String[]{'emdrid'};
	}

	/*
	The response message
	*/
	public class Resp_Message {
		public X5500_EMDR_Status_Callout.Resp_Element[] row;
		private String[] row_type_info = new String[]{'row','http://SFDC.biotronik.com',null,'0','-1','false'};
		private String[] apex_schema_type_info = new String[]{'http://SFDC.biotronik.com','false','false'};
		private String[] field_order_type_info = new String[]{'row'};
	}

	/*
	response message element
	*/
	public class Resp_Element {
		public String recordid;//record id in EMDR system
		public String reportid;//report id from complaint
		public String sourceid;//sfdc record id
		public String submit_number;//the submit ordinal for the report
		public String submit_status;//submit status of record in EMDR system
		public String esg_status;//status of EMDR with FDA gateway (ack 1)
		public String fda_final_status;//status of EMDR with FDA CDRH (ack 3)
		//salesforce unable to handle date values in incoming data, change to string
		public String date_emdr_initialized;//create datetime of record in EMDR system
		public String date_sent_to_fda;//datetime record submitted to FDA
		public String date_fda_response;//datetime of FDA final response (ack3)

		private String[] recordid_type_info = new String[]{'RECORDID','http://SFDC.biotronik.com',null,'0','1','false'};
		private String[] reportid_type_info = new String[]{'REPORTID','http://SFDC.biotronik.com',null,'0','1','false'};
		private String[] sourceid_type_info = new String[]{'SOURCEID','http://SFDC.biotronik.com',null,'0','1','false'};
		private String[] submit_number_type_info = new String[]{'SUBMIT_NUMBER','http://SFDC.biotronik.com',null,'0','1','false'};
		private String[] submit_status_type_info = new String[]{'SUBMIT_STATUS','http://SFDC.biotronik.com',null,'0','1','false'};
		private String[] esg_status_type_info = new String[]{'ESG_STATUS','http://SFDC.biotronik.com',null,'0','1','false'};
		private String[] fda_final_status_type_info = new String[]{'FDA_FINAL_STATUS','http://SFDC.biotronik.com',null,'0','1','false'};
		private String[] date_emdr_initialized_type_info = new String[]{'DATE_EMDR_INITIALIZED','http://SFDC.biotronik.com',null,'0','1','false'};
		private String[] date_sent_to_fda_type_info = new String[]{'DATE_SENT_TO_FDA','http://SFDC.biotronik.com',null,'0','1','false'};
		private String[] date_fda_response_type_info = new String[]{'DATE_FDA_RESPONSE','http://SFDC.biotronik.com',null,'0','1','false'};
		private String[] apex_schema_type_info = new String[]{'http://SFDC.biotronik.com','false','false'};
		private String[] field_order_type_info = new String[]{'RECORDID','REPORTID','SOURCEID','SUBMIT_NUMBER','SUBMIT_STATUS','ESG_STATUS','FDA_FINAL_STATUS','DATE_EMDR_INITIALIZED','DATE_SENT_TO_FDA', 'DATE_FDA_RESPONSE'};
	}

	public class HTTPS_Port {
		public String endpoint_x;// = 'https://r5628:58501/XISOAPAdapter/MessageServlet?senderParty=Salesforce&senderService=EMDR&receiverParty=&receiverService=&interface=osFDA_Message&interfaceNamespace=http%3A%2F%2FSFDC.biotronik.com';
		public Map<String,String> inputHttpHeaders_x;
		public Map<String,String> outputHttpHeaders_x;
		public String clientCertName_x;
		public String clientCert_x;
		public String clientCertPasswd_x;
		public Integer timeout_x;
		private String[] ns_map_type_info = new String[]{'http://SFDC.biotronik.com', 'X5500_EMDRStatus_Callout'};

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
		input: request message request_x populated with a list of Req_Element(s)
		output: response message response_x populated with a list of Res_Element(s)
		*/
        public X5500_EMDR_Status_Callout.Resp_Message osFDA_Message(X5500_EMDR_Status_Callout.Req_Message request_x) {
			X5500_EMDR_Status_Callout.Resp_Message response_x;
			Map<String, X5500_EMDR_Status_Callout.Resp_Message> response_map_x = new Map<String, X5500_EMDR_Status_Callout.Resp_Message>();
			response_map_x.put('response_x', response_x);
			WebServiceCallout.invoke(
				this,
				request_x,
				response_map_x,
				new String[] {
					endpoint_x,
					'http://sap.com/xi/WebService/soap1.1',
					'http://SFDC.biotronik.com',
					'FDA_MessageRequest',
					'http://SFDC.biotronik.com',
					'FDA_MessageResponse',
					'X5500_EMDR_Status_Callout.Resp_Message'
				}
			);
			response_x = response_map_x.get('response_x');
			return response_x;
		}
	}
}