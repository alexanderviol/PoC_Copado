@isTest
global class API_OrderIntegration_Mock implements WebServiceMock {
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
        API_OrderIntegration.MDRF_Order_Resp respElement = new API_OrderIntegration.MDRF_Order_Resp();
        respElement.SF_RecordId = 'Mock_SF_RecordId';
        respElement.Document_Type = 'Inquiry';
        respElement.Document = '999_999_999';
        respElement.PO_No = '';
        respElement.Message = '';
        respElement.SAP_BB = '10';

        response.put('response_x', respElement);
    }
}