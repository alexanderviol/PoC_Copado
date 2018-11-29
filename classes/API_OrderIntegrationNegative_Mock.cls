@isTest
global class API_OrderIntegrationNegative_Mock implements WebServiceMock {
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
        respElement.SF_RecordId = '';
        respElement.Document_Type = '';
        respElement.Document = '';
        respElement.PO_No = '';
        respElement.Message = 'Mock_Error';
        respElement.SAP_BB = '';

        response.put('response_x', respElement);
    }
}