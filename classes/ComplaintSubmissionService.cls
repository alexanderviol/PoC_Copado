public with sharing class ComplaintSubmissionService {

    private static final String PATIENT_STATUS_DEAD = 'Deceased';
    private static final String PATIENT_STATUS_ALIVE = 'Active';

    private static final String METADATA_NAME_CAN_CRED = 'CAN_NAMEDCREDENTIAL';


    public static void submitComplaints(List<complaint__c> complaints) {
        // nothing to do? -> early return
        if (complaints == NULL || complaints.isEmpty()) {
            return;
        }

        // check if user already has a token
        CanAuthentication auth = new CanAuthentication();
        String authId = auth.getUserSession();

        // check if token is still valid
        if(!auth.validateUserSession(authId)){
            return;
        }

        // lock complaints, reset error message
        for (complaint__c c : complaints) {
            c.is_locked__c = true;
            c.can_error_message__c = null;
        }
        update complaints;

        // start submission for each complaint. needs to be a @future, as callouts after DML is not allowed.
        for (complaint__c c : complaints) {
            ComplaintSubmissionService.createComplaint(c.Id, authId);

        }
    }


    // complaint submission. needs to be a @future, as callouts after DML is not allowed.
    @Future(callout=true)
    public static void createComplaint(Id complaintId, String authId) {

        // get required fields
        complaint__c complaint = [
                SELECT
                        Id,
                        report_date__c,
                        date_of_event__c,
                        event_description__c,
                        doctors_letter_required__c,
                        sap_company_code__c,
                        asset_serial_number__c,
                        asset_lot_number__c,
                        ci_number__c,
                        mdr_number__c,
                        RP_Number__c,
                        asset_model_name__c,
                        explant_date__c,
                        asset_implant_date__c,
                        out_of_service_date__c,
                        software_version__c,
                        date_product_returned_to_manufacturer__c,
                        device_available_for_evaluation__c,
                        device_code_global__c,
                        patient_code_global__c,
                        type_of_report__c,
                        can_case_number__c,
                        Submit_to_Can__c,
                        is_locked__c,
                        death_device_related__c,
            			date_of_death__c,
                        outcome_attributed_to_adverse_event__c,
                        event_country__c,
                        ProductIdType__c,
                        udi__c,
                        RecordType.DeveloperName,
                        Asset__r.Patient__r.Status__c,
                        case__r.CreatedBy.FirstName,
                        case__r.CreatedBy.LastName
                FROM complaint__c
                WHERE Id = :complaintId
                LIMIT 1
        ];

        // Better safe than sorry...
        if (!complaint.Submit_to_Can__c) {
            return;
        }


        try {

            Asset asset = new Asset();
            Contact patient = new Contact();

            if (complaint.asset__r != null) {
                asset = complaint.asset__r;

                if (asset.patient__r != null) {
                    patient = asset.patient__r;
                }
            }


            Analysis_Report__c analysisReport = new Analysis_Report__c();
            List<Analysis_Report__c> analysisReports = [
                    SELECT
                            Id,
                            method_code__c,
                            result_code__c,
                            conclusion_code__c,
                            analysis_results__c
                    FROM
                            Analysis_Report__c
                    WHERE
                            complaint__c = :complaint.Id
                    ORDER BY CreatedDate DESC
                    LIMIT 1
            ];
            if (analysisReports != NULL && !analysisReports.isEmpty()) {
                analysisReport = analysisReports.get(0);
            }



            wsCanBiotronikComInterfacesComplain.SfdcComplaintServiceV10Port port = new wsCanBiotronikComInterfacesComplain.SfdcComplaintServiceV10Port();
            /*
             * endpoint including authentification is stored in named credentials.
             * there is one named credential per system (DEV, QA/VAL, PROD)
             * there is a custom metadata setting to configure, which named credential to use
             */
            port.endpoint_x = 'callout:' + getNamedCredentialNameCan();
            port.timeout_x = 120000; // request timeout in milliseconds


            // construct request header
            wsCanBiotronikComDataCommonMetaele.BusinessMessageHeaderType requestHeader = new wsCanBiotronikComDataCommonMetaele.BusinessMessageHeaderType();
            //requestHeader.clientReference = '';
            //requestHeader.transactionId = '';
            //requestHeader.class = '';
            //requestHeader.replyTo = '';
            requestHeader.referrer = 'SFDC_US_BINC';


            // construct complaint details
            wsCanBiotronikComInterfacesComplain.ComplaintDetailsType details = new wsCanBiotronikComInterfacesComplain.ComplaintDetailsType();

            details.externalId = complaint.Id;
            details.awarenessDate = complaint.report_date__c;
            details.eventDate = complaint.date_of_event__c;
            details.eventDescription = complaint.event_description__c;
            details.patientDeceased = getDeathOfPatientValue(patient.Status__c);
            details.analysisReportExpected = complaint.doctors_letter_required__c;
            details.deathReason = complaint.death_device_related__c;
            details.dateOfDeath = complaint.date_of_death__c;
            details.patientState = complaint.outcome_attributed_to_adverse_event__c;

            details.complainingOrganization = new wsCanBiotronikComInterfacesComplain.SalesOrganizationType();
            details.complainingOrganization.name = complaint.sap_company_code__c;

            details.complainingOrganization.contactPerson = new wsCanBiotronikComInterfacesComplain.PersonType();
            if(complaint.case__r != NULL) {
                details.complainingOrganization.contactPerson.name = complaint.case__r.CreatedBy.LastName;
                details.complainingOrganization.contactPerson.firstName = complaint.case__r.CreatedBy.FirstName;
            }
            else {
                details.complainingOrganization.contactPerson.name = UserInfo.getLastName();
                details.complainingOrganization.contactPerson.firstName = UserInfo.getFirstName();
            }

            details.eventCountry = new wsCanBiotronikComInterfacesComplain.CountryType();
            details.eventCountry.countryCode = complaint.event_country__c;


            // construct product details
            wsCanBiotronikComInterfacesComplain.ProductDetailsType product = new wsCanBiotronikComInterfacesComplain.ProductDetailsType();
            product.productIdType = complaint.ProductIdType__c;
            product.serialNumber = complaint.asset_serial_number__c;
            product.lotNumber = complaint.asset_lot_number__c;
            product.udiNumber = complaint.udi__c;
            product.ciNumber = complaint.ci_number__c;
            product.mdrNumber = complaint.mdr_number__c;
            product.rpNumber = complaint.RP_Number__c;
            // product.productName = complaint.asset_model_name__c; //@TODO removed in new WSDL version
            product.explantationDate = complaint.explant_date__c;
            product.implantationDate = complaint.asset_implant_date__c;
            product.outOfServiceDate = complaint.out_of_service_date__c;
            product.softwareVersion = complaint.software_version__c;
            //product.incomingDate = complaint.date_product_returned_to_manufacturer__c; //@TODO removed in new WSDL version
            //product.oral = getProductOralValue(complaint.device_available_for_evaluation__c); //@TODO removed in new WSDL version

            /*
            // Removed in new WSDL version
            product.classification = new wsCanBiotronikComInterfacesComplain.MdrClassificationType();
            product.classification.method = analysisReport.method_code__c;
            product.classification.result = analysisReport.result_code__c;
            product.classification.conclusion = analysisReport.conclusion_code__c;
            product.classification.deviceNumber = complaint.device_code_global__c;
            product.classification.patientNumber = complaint.patient_code_global__c;

            wsCanBiotronikComInterfacesComplain.AuthorityNotificationType authorityNotification = new wsCanBiotronikComInterfacesComplain.AuthorityNotificationType();
            authorityNotification.authorityName = '';
            */
            /*
            // Removed in new WSDL version
            wsCanBiotronikComInterfacesComplain.NotificationDocumentType notificationDocument = new wsCanBiotronikComInterfacesComplain.NotificationDocumentType();
            notificationDocument.fdaFollowUpType = complaint.type_of_report__c;
            notificationDocument.sfAnalysisResult = analysisReport.analysis_results__c;
            authorityNotification.notificationDocument = new List<wsCanBiotronikComInterfacesComplain.NotificationDocumentType>{
                    notificationDocument
            };
            product.authorityNotification = new List<wsCanBiotronikComInterfacesComplain.AuthorityNotificationType>{
                    authorityNotification
            };
            */


            wsCanBiotronikComInterfacesComplain.ProductsType products = new wsCanBiotronikComInterfacesComplain.ProductsType();
            products.product = new List<wsCanBiotronikComInterfacesComplain.ProductDetailsType>();
            products.product.add(product);


            // complaint has no case number -> not yet known by can -> create
            if (complaint.can_case_number__c == null || String.isBlank(complaint.can_case_number__c)) {

                wsCanBiotronikComInterfacesComplain.CreateComplaintResponseType response = port.createComplaint(
                        authId, //String authenticationId,
                        requestHeader, //wsCanBiotronikComDataCommonMetaele.BusinessMessageHeaderType requestHeader,
                        details, //wsCanBiotronikComInterfacesComplain.ComplaintDetailsType complaintDetails,
                        products // wsCanBiotronikComInterfacesComplain.ProductsType products
                );

                if (response.state.success) {
                    complaint.can_case_number__c = response.complaintNumber;
                } else {
                    complaint.can_error_message__c = 'SUBMISSION TO CAN FAILED: createComplaint: ' + response.state.failure.message;
                    system.debug(response);
                }

                // complaint has a case number -> already known by can -> update
            } else {

                /* 2018-09-14 Simon Becker, Lilax Solutions
                 * on update, some information should NOT be sent to CAN
                 * SAFBIO-2086 - RB: SFDC-CAN IF: OUS Complaint: SFDC triggered update of Complaints in CAN gets blocked
                 */
                if(complaint.RecordType.DeveloperName == Constants.RECORD_TYPE_NAME_COMPLAINT_OUS){
                    details.patientDeceased = null;
                    details.complainingOrganization.contactPerson = null;
                    product.udiNumber = null;
                    details.analysisReportExpected = null; // SAFBIO-2447
                    details.complainingOrganization = null;
                }

                // update complaint
                wsCanBiotronikComInterfacesComplain.UpdateComplaintResponseType response = port.updateComplaint(
                        authId, //String authenticationId,
                        requestHeader, //wsCanBiotronikComDataCommonMetaele.BusinessMessageHeaderType requestHeader,
                        complaint.can_case_number__c, // String complaintNumber,
                        details //wsCanBiotronikComInterfacesComplain.ComplaintDetailsType complaintDetails
                );

                if (response.state.success) {

                    // update product
                    wsCanBiotronikComInterfacesComplain.UpdateProductsResponseType productsResponse = port.updateProducts(
                            authId, //String authenticationId,
                            requestHeader, //wsCanBiotronikComDataCommonMetaele.BusinessMessageHeaderType requestHeader,
                            complaint.can_case_number__c, // String complaintNumber,
                            products // String complaintNumber,wsCanBiotronikComInterfacesComplain.ProductsType products
                    );

                    if(!productsResponse.state.success) {
                        complaint.can_error_message__c = 'SUBMISSION TO CAN FAILED: updateProducts: ' + response.state.failure.message;
                        system.debug(response);
                    }
                }
                else {
                    complaint.can_error_message__c = 'SUBMISSION TO CAN FAILED: updateComplaint: ' + response.state.failure.message;
                    system.debug(response);
                }
            }

            // field updates on success
            complaint.date_of_last_transmission_to_can__c = Date.Today();

        } catch (Exception e) {
            system.debug(e);

            complaint.can_error_message__c = 'SUBMISSION TO CAN FAILED: unknown: ' + e.getMessage();

        } finally {
            // field updates on both, success AND error
            complaint.is_locked__c = false;
            complaint.Submit_to_Can__c = false;
            update complaint;
        }
    }



    // helper method to map SFDC value to CAN value
    private static String getDeathOfPatientValue(String patentStatus) {

        // possible return values: Yes | No | Unknown
        if (patentStatus == PATIENT_STATUS_DEAD) {
            return 'Yes'; // patient dead
        }
        if (patentStatus == PATIENT_STATUS_ALIVE) {
            return 'No'; // patient alive
        }

        return 'Unknown'; // patient status unknown
    }

    /*
    // helper method to map SFDC value to CAN value
    private static Boolean getProductOralValue(String availableForEvaluation) {
        // @ TODO MAPPING!
        return true;
    }
    */

    // helper method to get named credential name configured in custom metadata setting
    private static String getNamedCredentialNameCan() {
        return Utility.getSettingValue(METADATA_NAME_CAN_CRED,null);
    }



}