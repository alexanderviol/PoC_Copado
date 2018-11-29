public class CanAuthentication {

    private static final String METADATA_NAME_CAN_AUTH_CRED = 'CAN_AUTH_NAMEDCREDENTIAL';
    private static final String METADATA_NAME_CAN_CRED = 'CAN_NAMEDCREDENTIAL';


    public String getUserSession() {
        list<User> userObj = [SELECT id, can_session_id__c FROM USER WHERE id =:UserInfo.getUserId()];
        if(userObj != null && userObj[0].can_session_id__c != null) {
            return userObj[0].can_session_id__c;
        }
        return null;
    }



    public Boolean authenticateUser(String username, String password) {
        CanBiotronikComInterfacesAuthentication.AuthenticationServiceV10Port port = new CanBiotronikComInterfacesAuthentication.AuthenticationServiceV10Port();
        CanBiotronikComDataCommonMetaElement.BusinessMessageHeaderType header = new CanBiotronikComDataCommonMetaElement.BusinessMessageHeaderType();

        port.endpoint_x = 'callout:' + getNamedCredentialNameCanAuth();


        String result;
        try {
            result = port.authenticate(header, username, password, '');
        }
        catch(Exception e){
            System.debug(e);
            return false;
        }

        if(result == null || String.isEmpty(result)){
            System.debug('empty result');
            return false;
        }

        User u = new User();
        u.Id = UserInfo.getUserId();
        u.can_session_id__c = result;
        update u;

        return true;
    }


    public Boolean validateUserSession(String canSessionId) {
        wsCanBiotronikComInterfacesComplain.SfdcComplaintServiceV10Port port = new wsCanBiotronikComInterfacesComplain.SfdcComplaintServiceV10Port();

        port.endpoint_x = 'callout:' + getNamedCredentialNameCan();


        wsCanBiotronikComInterfacesComplain.SfdcGetServiceInfoResponseType result;
        try {
            result = port.getServiceInfo(canSessionId);
            if(!result.state.success){
                resetUserToken();
            }
        }
        catch(Exception e){
            System.debug(e);

            resetUserToken();

            return false;
        }

        return true;
    }


    private void resetUserToken(){
        User u = new User();
        u.Id = UserInfo.getUserId();
        u.can_session_id__c = null;
        update u;
    }

    private String getNamedCredentialNameCanAuth() {

        return Utility.getSettingValue(METADATA_NAME_CAN_AUTH_CRED,null);

    }
    private String getNamedCredentialNameCan() {
        return Utility.getSettingValue(METADATA_NAME_CAN_CRED,null);
    }

}