//Generated by wsdl2apex

public class CanBiotronikComInterfacesAuthentication {
    public class AuthenticateResponseType {
        public String authenticationId;
        private String[] authenticationId_type_info = new String[]{'authenticationId','http://ws.can.biotronik.com/interfaces/authentication/AuthenticationServiceMessages/v1_0',null,'1','1','false'};
        private String[] apex_schema_type_info = new String[]{'http://ws.can.biotronik.com/interfaces/authentication/AuthenticationServiceMessages/v1_0','true','false'};
        private String[] field_order_type_info = new String[]{'authenticationId'};
    }
    public class AuthenticateType {
        public CanBiotronikComDataCommonMetaElement.BusinessMessageHeaderType requestHeader;
        public String username;
        public String password;
        public String callbackAddress;
        private String[] requestHeader_type_info = new String[]{'requestHeader','http://ws.can.biotronik.com/interfaces/authentication/AuthenticationServiceMessages/v1_0',null,'1','1','false'};
        private String[] username_type_info = new String[]{'username','http://ws.can.biotronik.com/interfaces/authentication/AuthenticationServiceMessages/v1_0',null,'1','1','false'};
        private String[] password_type_info = new String[]{'password','http://ws.can.biotronik.com/interfaces/authentication/AuthenticationServiceMessages/v1_0',null,'0','1','false'};
        private String[] callbackAddress_type_info = new String[]{'callbackAddress','http://ws.can.biotronik.com/interfaces/authentication/AuthenticationServiceMessages/v1_0',null,'0','1','false'};
        private String[] apex_schema_type_info = new String[]{'http://ws.can.biotronik.com/interfaces/authentication/AuthenticationServiceMessages/v1_0','true','false'};
        private String[] field_order_type_info = new String[]{'requestHeader','username','password','callbackAddress'};
    }
    public class AuthenticationServiceV10Port {
        public String endpoint_x = 'https://can-test.biotronik.com:8443/can-ws/services/authenticationService_v1';
        public Map<String,String> inputHttpHeaders_x;
        public Map<String,String> outputHttpHeaders_x;
        public String clientCertName_x;
        public String clientCert_x;
        public String clientCertPasswd_x;
        public Integer timeout_x;
        private String[] ns_map_type_info = new String[]{'http://ws.can.biotronik.com/data/authentication/AuthenticationTypes/v1', 'CanBiotronikComDataAuthentication', 'http://ws.can.biotronik.com/interfaces/authentication/AuthenticationServiceMessages/v1_0', 'CanBiotronikComInterfacesAuthentication', 'http://ws.can.biotronik.com/interfaces/authentication/AuthenticationService/v1', 'CanBiotronikComInterfacesAuthentication', 'http://ws.can.biotronik.com/data/common/ServiceInfo/v1', 'CanBiotronikComDataCommonService', 'http://ws.can.biotronik.com/data/common/FaultTypes/v1', 'CanBiotronikComDataCommonFaultty', 'http://ws.can.biotronik.com/data/common/MetaElements/v1', 'CanBiotronikComDataCommonMetaElement'};
        public String authenticate(CanBiotronikComDataCommonMetaElement.BusinessMessageHeaderType requestHeader,String username,String password,String callbackAddress) {
            CanBiotronikComInterfacesAuthentication.AuthenticateType request_x = new CanBiotronikComInterfacesAuthentication.AuthenticateType();
            request_x.requestHeader = requestHeader;
            request_x.username = username;
            request_x.password = password;
            request_x.callbackAddress = callbackAddress;
            CanBiotronikComInterfacesAuthentication.AuthenticateResponseType response_x;
            Map<String, CanBiotronikComInterfacesAuthentication.AuthenticateResponseType> response_map_x = new Map<String, CanBiotronikComInterfacesAuthentication.AuthenticateResponseType>();
            response_map_x.put('response_x', response_x);
            WebServiceCallout.invoke(
              this,
              request_x,
              response_map_x,
              new String[]{endpoint_x,
              '',
              'http://ws.can.biotronik.com/interfaces/authentication/AuthenticationServiceMessages/v1_0',
              'authenticate',
              'http://ws.can.biotronik.com/interfaces/authentication/AuthenticationServiceMessages/v1_0',
              'authenticateResponse',
              'CanBiotronikComInterfacesAuthentication.AuthenticateResponseType'}
            );
            response_x = response_map_x.get('response_x');
            return response_x.authenticationId;
        }
        public CanBiotronikComDataCommonService.ServiceInfoType getServiceInfo() {
            CanBiotronikComDataCommonService.GetServiceInfoType request_x = new CanBiotronikComDataCommonService.GetServiceInfoType();
            CanBiotronikComDataCommonService.GetServiceInfoResponseType response_x;
            Map<String, CanBiotronikComDataCommonService.GetServiceInfoResponseType> response_map_x = new Map<String, CanBiotronikComDataCommonService.GetServiceInfoResponseType>();
            response_map_x.put('response_x', response_x);
            WebServiceCallout.invoke(
              this,
              request_x,
              response_map_x,
              new String[]{endpoint_x,
              '',
              'http://ws.can.biotronik.com/data/common/ServiceInfo/v1',
              'getServiceInfo',
              'http://ws.can.biotronik.com/data/common/ServiceInfo/v1',
              'getServiceInfoResponse',
              'CanBiotronikComDataCommonService.GetServiceInfoResponseType'}
            );
            response_x = response_map_x.get('response_x');
            return response_x.serviceInfo;
        }
    }
}