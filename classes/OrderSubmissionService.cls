public with sharing class OrderSubmissionService {


    private static final String RECORDTYPE_DEVELOPERNAME_ORDER_CARDIOMESSENGER = 'cardio_messenger_order';
    private static final String PONUMBER_CARDIOMESSENGER_DIRECTSHIP = 'CMDS';
    private static final String METADATA_NAME_ORDERSUBMISSION_CRED = 'ORDERSUBMISSION_NAMEDCREDENTIAL';
    @TestVisible private static final String NPI_FALLBACK = 'NONPIFORDR';

    public static void submitOrders(List<Order> orders){
        if(orders == null || orders.isEmpty()){
            return;
        }
        for(Order o: orders){
            o.is_locked__c = true;
            o.sap_error_message__c = null;
            if(o.submission_attempts__c == null){
                o.submission_attempts__c = 1;
            }else {
                o.submission_attempts__c = o.submission_attempts__c + 1;
            }
        }

        update orders;

        for(Order o: orders){
            OrderSubmissionService.submitOrder(o.Id);

        }
    }

    @Future(Callout=true)
    public static void submitOrder(Id orderId) {


        /*
         * 2018-08-31 Simon Becker, Lilax Solutions
         * SAFBIO-1720 - Replaced Shipping address
         *  //patient__r.shipping_street__c, patient__r.shipping_zip_postal_code__c,
         *  //patient__r.shipping_city__c, patient__r.shipping_state_province__c, patient__r.shipping_country__c,
         */

        Order order = [
                SELECT Id, sap_company_code__c, PoNumber, sap_billing_block__c, ShippingStreet, ShippingPostalCode,
                        ShippingCity, ShippingStateCode, ShippingCountryCode, division_number_mdrf__c,
                        RecordType.DeveloperName,
                        Account.sap_no__c,
                        rep_for_credit__r.sap_no__c,
                        rep_at_implant__r.sap_no__c,
                        patient__r.LastName, patient__r.FirstName, patient__r.MiddleName, patient__r.Phone,
                        patient__r.Birthdate, patient__r.gender__c,
                        implanting_physician__r.LastName, implanting_physician__r.FirstName,
                        implanting_physician__r.MiddleName, implanting_physician__r.npi__c,
                        referring_physician__r.npi__c
                FROM Order
                WHERE Id = :orderId
                LIMIT 1
        ];
        try {
            //API_OrderIntegration orderIntegration = new API_OrderIntegration();

            List<OrderItem> orderItems = [
                    SELECT Id, ParentId__c, serial_number__c, batch_no__c, implant_date__c, Quantity, UnitPrice,
                            stock_type__c, CurrencyIsoCode, location__r.external_id__c,  product_type__c, replenish__c,
                            Status__c,
                            Product2.product_hierarchy__c, Product2.sap_model_no__c, Product2.serialized_item__c,
                            Product2.batched_item__c
                    FROM OrderItem
                    WHERE OrderId = :order.Id
                    ORDER BY ParentId__c NULLS FIRST // SAFBIO-1951
            ];
            Map<Id, Integer> itemNumberById = new Map<Id, Integer>();


            Integer nextItemNumber = 10;
            for (OrderItem oi : orderItems) {
                itemNumberById.put(oi.Id, nextItemNumber);
                nextItemNumber += 10;
            }

            List<API_OrderIntegration.Items_element> apiItems = new List<API_OrderIntegration.Items_element>();

            List<String> applicableCategories = new List<String> {
                Constants.VALI_CAT_DEVICE, Constants.VALI_CAT_LOOP_RECORDER, Constants.VALI_CAT_CARDIO_MESSENGER
            };
            for (OrderItem oi : orderItems) {
                API_OrderIntegration.Items_element element = new API_OrderIntegration.Items_element();
                element.Item_No = itemNumberById.get(oi.Id);
                if (oi.ParentID__c != null) {
                    element.Part_of_System = itemNumberById.get(oi.ParentID__c);
                }
                element.Model_No = (oi.Product2 == null ? '' : oi.Product2.sap_model_no__c);

                /*
                 * 2018-09-12 SIMON EBCKER, Lilax Solutions
                 * SAFBIO-2019 RB: Batch information being transmitted in order to SAP as serial number
                 * batchNo and serialNo are only submitted to SAP when related flag on product2 is set.
                 */
                if (oi.Product2 != null && oi.Product2.serialized_item__c) {
                    element.Serial_No = oi.serial_number__c;
                }
                if (oi.Product2 != null && oi.Product2.batched_item__c) {
                    element.Batch = oi.batch_no__c;
                }

                element.Impl_Date = String.valueOf(oi.implant_date__c);
                element.Quantity = String.valueOf(oi.Quantity);
                element.Price = String.valueOf(oi.UnitPrice);
                element.Cons_flag = getConsFlag(oi.stock_type__c);
                element.Currency_x = oi.CurrencyIsoCode;
                element.StockLocation = (oi.location__r == null) ? '' : getLocationCode(oi.location__r.external_id__c);
                element.DoNotReplenish = !oi.Replenish__c;
                element.ImplantStatus = oi.status__c;

                apiItems.add(element);
            }


            API_OrderIntegration.ShipToParty_element shipToPartyElement = new API_OrderIntegration.ShipToParty_element();
            /*
             * 2018-09-10 Simon Becker, Lilax Solutions
             * SAFBIO-2044 - The shipToPartyElement in the 'OrderSubmissionService' APEX class must only be created for
             * CM direct ship and CM direct ship replacement orders.
             */
            if(
                order.PoNumber != null &&
                order.PoNumber.containsIgnoreCase(PONUMBER_CARDIOMESSENGER_DIRECTSHIP) &&
                order.RecordType.DeveloperName.equals(RECORDTYPE_DEVELOPERNAME_ORDER_CARDIOMESSENGER)
            ) {
                shipToPartyElement.Customer = order.Account.sap_no__c;
                shipToPartyElement.Name1 = order.patient__r.LastName + ', ' + val(order.patient__r.FirstName) + '; ' + val(order.patient__r.MiddleName);
                shipToPartyElement.Name2 = '';
                shipToPartyElement.Street = order.ShippingStreet;
                shipToPartyElement.Street2 = '';
                shipToPartyElement.Zipcode = order.ShippingPostalCode;
                shipToPartyElement.City = order.ShippingCity;
                shipToPartyElement.Region = order.ShippingStateCode;
                shipToPartyElement.Country = order.ShippingCountryCode;
                shipToPartyElement.phone = order.patient__r.Phone;
                shipToPartyElement.DateOfBirth = String.valueOf(order.patient__r.Birthdate);
                shipToPartyElement.Gender = order.patient__r.gender__c;
                shipToPartyElement.BIOShippingNotice = '';
            }

            String npi = NPI_FALLBACK;
            if(order.implanting_physician__r != null && String.isNotBlank(order.implanting_physician__r.npi__c)){
                npi = order.implanting_physician__r.npi__c;
            }
            String refnpi = NPI_FALLBACK;
            if(order.referring_physician__r != null && String.isNotBlank(order.referring_physician__r.npi__c)){
                refnpi = order.referring_physician__r.npi__c;
            }

            API_OrderIntegration.HTTPS_Port port = new API_OrderIntegration.HTTPS_Port();
            port.endpoint_x = 'callout:' + getNamedCredentialNameOrderSubmission();
            port.timeout_x = 60000; // request timeout in milliseconds


            API_OrderIntegration.MDRF_Order_Resp response = port.osMDRF_Order(
                    order.sap_company_code__c,    //String Tenant_No,
                    (order.Account == null ? '' : order.Account.sap_no__c),    // String Customer,
                    order.Id,    // String SF_RecordId,
                    (order.rep_for_credit__r == null ? '' : order.rep_for_credit__r.sap_no__c),    // String Rep,
                    (order.rep_at_implant__r == null ? '' : order.rep_at_implant__r.sap_no__c),    // String RepAtImplant,
                    order.division_number_mdrf__c,    // String LoB,
                    order.PoNumber,    // String PO,
                    order.sap_billing_block__c,    // String Billing_Block,
                    order.patient__r.LastName + ', ' + val(order.patient__r.FirstName) + '; ' + val(order.patient__r.MiddleName),   // String Patient,
                    (order.implanting_physician__r == null ? '' : order.implanting_physician__r.LastName + ', ' + val(order.implanting_physician__r.FirstName) + '; ' + val(order.implanting_physician__r.MiddleName)),    // String Doctor,
                    '',    // String HM_Flag,
                    npi,    // String NPI,
                    refnpi,    // String REFNPI,
                    shipToPartyElement,    // API_OrderIntegration.ShipToParty_element ShipToParty,
                    apiItems    // API_OrderIntegration.Items_element[] Items
            );

            if (response.Message != null && String.isNotBlank(response.Message)) {
                order.sap_error_message__c = response.Message;
                order.Status = 'SAP Error Review';
                System.debug(response.Message);

            } else {
                order.sap_inquiry_no__c = response.Document;
                order.sap_billing_block__c = response.SAP_BB;
                order.submitted_date__c = Datetime.now();
                order.Status = 'Processed to SAP';
            }
        }
        catch(Exception e){
            order.sap_error_message__c = 'Unhandled SFDC Error: ' + e.getMessage();
        }
        finally {
            order.is_locked__c = false;
            order.submit_to_sap__c = false;
            update order;
        }
    }

    private static String val(String text){
        if(text == null){
            return '';
        }
        return text;
    }

    /*
     * 2018-08-17 Simon Becker | Lilax Solutions
     * SAFBIO-1530 - element.StockLocation need to be number of SAP stock location not record ID
     * >> element.StockLocation in OrderSubmissionService APEX class needs to be number of SAP stock location not record ID.
     * >> Can be retrieved from Locations external ID (Last 4 digits).
     */
    private static String getLocationCode(String locationExternalId){
        if(locationExternalId == null || locationExternalId.length() < 4){
            return '';
        }

        return locationExternalId.right(4);
    }

    /*
     * 2018-08-23 Simon Becker @ Lilax Solutions
     * SAFBIO-1807 - RB: Issues with Order - missing storage location, no rep at implant, no invoice number
     * >> If stock_type = 'C' -> cons_flag = 'X'
     */
    private static String getConsFlag(String stockType){
        if(stockType != null && stockType.equals('C')){
            return 'X';
        }
        return '';
    }

    private static String getNamedCredentialNameOrderSubmission() {
        return  [SElECT Value__c FROM Setting__mdt WHERE DeveloperName = :METADATA_NAME_ORDERSUBMISSION_CRED LIMIT 1].Value__c;
    }
}