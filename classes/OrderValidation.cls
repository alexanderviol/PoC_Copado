/**
* @author:          arwe
*                   T-Systems Multimedia Solutions GmbH
*                   Riesaer Strasse 5,
*                   01129 Dresden
*                   www.t-systems-mms.com
*
* @description      This class is to set Order Validation reason
*                  
*
* @date             11.10.2018
* 
*/

public with sharing class OrderValidation {

    private static final Id ID_RECORD_TYPE_MDRF_ORDER = Utility.getRecordTypeId(Order.SObjectType, Constants.RECORD_TYPE_NAME_ORDER_MDRF);
    private static final Id ID_RECORD_TYPE_CM_ORDER = Utility.getRecordTypeId(Order.SObjectType, Constants.RECORD_TYPE_NAME_ORDER_CARDIO_MESSENGER);

    public static final Set<String> CAS_VALIDATION_VALUES = new Set<String>{Constants.PICKLIST_VALIDATION_REASON_IMPLANTING_FACILITY_IN_PUERTO_RICO
            , Constants.PICKLIST_VALIDATION_REASON_PRICE_DISCREPANCY_REASON_BULK_SWAP
            , Constants.PICKLIST_VALIDATION_REASON_PART_OF_SYSTEM_AND_PRICE_GREATER_ZERO
            , Constants.PICKLIST_VALIDATION_REASON_BULK_PRODUCT_WITH_PRICE_GREATER_ZERO
            , Constants.PICKLIST_VALIDATION_REASON_ZERO_DOLLAR_PRODUCT_OUTSIDE_SYSTEM};

    
    private static Integer implantedDeviceCount;
    private static Integer implantedAssetCount;
    private static Integer leadAttached;

    /**
     * do check for order validation
     *
     * @param newOrders list of Orders
     * @param mapOldOrder map of old Orders
     */
    public static void doCheck(List<Order> newOrders, Map<Id, Order> mapOldOrder){
        List<Order> orderInSubmitForProcessing = getOrderChangedToSubmitForProcessing(newOrders,mapOldOrder);
        System.debug('doCheck:' + newOrders );
        if(!orderInSubmitForProcessing.isEmpty()){
            validateOosAssets(orderInSubmitForProcessing, getPatientWorkOrderMap(new Map<Id,Order>(orderInSubmitForProcessing).keySet()));
            reviewOrders(orderInSubmitForProcessing);
        }
    }

    public static void reviewOrdersOnInsert(List<Order> newOrderList){

        List<Order> submittedOrders = new List<Order>();

        for (Order order : newOrderList){
            if (order.Status == Constants.PICKLIST_VALUE_ORDER_STATUS_SUBMITTED_PROCESSING) {
                submittedOrders.add(order);
            }
        }
        reviewOrders(submittedOrders);
    }

    /**
     * During the review multiple validations for the orders will be checked. Depending on the outcome of the
     *  validations and the current status of the order, the method will assign the orders to diffrent Queues
     *  and populate the validation_reason__c field on the order records.
     *
     * @param newOrderList  has to contain all order records, with status changed from not Submitted to Submitted for processing.
     * @param mapOldOrder old map of orders
     */
    private static void reviewOrders(List<Order> newOrderList) {
        OrdersReview ordersReview = new OrdersReview(newOrderList);

        for(Order objOrder : newOrderList) {
            if(ID_RECORD_TYPE_MDRF_ORDER == objOrder.RecordTypeId) {

                List <OrderItem> orderItems  = ordersReview.getOrderOrderItemMap().get(objOrder.Id);

                List <Asset> assets = ordersReview.getOrderAssetMap().get(objOrder.patient__c);

                checkOrderItemCount(objOrder, orderItems);
                checkOrderItemStatus(objOrder, orderItems);

                // Validate both hard and soft criteria
                validateCriteria(objOrder, orderItems, ordersReview.accountMap, assets);
                //validate required value before submit
                validateRequiredInfo(objOrder, ordersReview.contactMap, assets, orderItems);

                submitOrderToSap(objOrder);
            }
        }
    }

    /**
     * Check that the related order items have a status
     *
     * SAFBIO-1611
     *
     * @param   objOrder, the Order record for which the validation should run
     * @param   lstOrderItems, all Order Items related to the order records; returns if list is empty
     *
     * @author  ilu_pkas
     */
    private static void checkOrderItemStatus(Order objOrder, List<OrderItem> lstOrderItems){
        if(lstOrderItems == null || lstOrderItems.isEmpty()){
            return;
        }

        for(OrderItem item :lstOrderItems){
            if(Utility.isImplantableSerialized(item.product_type__c) && item.product_type__c != Constants.PICKLIST_VALUE_PRODUCT_TYPE_SYSTEM_DEVICE && String.isBlank(item.status__c )){
                objOrder.addError(System.Label.ERR_ORDER_ITEM_STATUS_NOT_DEFINED);
            }
        }
    }

    /**
     * Check that the order has related OrderItems
     *
     * SAFBIO-1985
     *
     * @param   objOrder, the Order record for which the validation should run
     * @param   lstOrderItems, all Order Items related to the order records; returns if list is empty
     *
     * @author  ilu_pkas
     */
    private static void checkOrderItemCount(Order objOrder, List<OrderItem> lstOrderItems){
        if(lstOrderItems == null || lstOrderItems.isEmpty()){
            objOrder.addError(Label.ERR_ORDER_HAS_NO_ORDER_ITEMS);
        }
    }

    /**
    * Flags the order ready for SAP submission, if the validation reason is None
    *  - Changes Status for SAP submission
    *
    * @param    objOrder, Order which should be enabled for SAP submission
    */
    private static void submitOrderToSap(Order objOrder) {

        Set<String> validationReasons = new Set<String>();
        if (objOrder.validation_reason__c != null) {
            validationReasons = new Set<String>(objOrder.validation_reason__c.split(';'));
        }

        validationReasons.retainAll(CAS_VALIDATION_VALUES);
        if(validationReasons.size() == 0) {
            objOrder.Status = Constants.PICKLIST_VALUE_ORDER_STATUS_PENDING_SAP;
        }else{
            objOrder.Status = Constants.PICKLIST_VALUE_ORDER_STATUS_PENDING_REVIEW;
        }
    }

    /**
     * Method checks if status changed to SUBMITTED_PROCESSING
     *
     * @param mapNewOrder list of Orders
     * @param mapOldOrder map of old Orders
     *
     * @return returns List of Orders that change to "Submitted for Processing"
     */
    private static List<Order> getOrderChangedToSubmitForProcessing(List<Order> newOrders, Map<Id, Order> mapOldOrder){

        List <Order> changedOrders = new List<Order>();

        List<Id> allowedRecordTypeIds = new List<Id>();
        allowedRecordTypeIds.add(ID_RECORD_TYPE_MDRF_ORDER);
        allowedRecordTypeIds.add(ID_RECORD_TYPE_CM_ORDER);


        for (Order order : newOrders){
            //only do something if MDRF or CM RecordType
            System.debug('set: '+allowedRecordTypeIds+' / order '+order.RecordTypeId);
            if(!allowedRecordTypeIds.contains(order.RecordTypeId) ){
                continue;
            }

            // if Status change to "Submitted for Processing"
            if (order.Status == Constants.PICKLIST_VALUE_ORDER_STATUS_SUBMITTED_PROCESSING) {
                if( mapOldOrder.get(order.Id).Status == order.Status){
                    continue;
                }
                changedOrders.add(order);
            }
        }
        return changedOrders;
    }

    /**
     * Method to update order reason
     * if order reason allrady exists in multi-picklist value then it will not change
     *
     * @param objOrder
     * @param reason reason as String
     */
    public static void updateOrderReason(Order objOrder, String reason){
        Set<String> validationReasons = new Set<String>();
        if (objOrder.validation_reason__c != null) {
            validationReasons = new Set<String>(objOrder.validation_reason__c.split(';'));
        }
        validationReasons.add(reason);
        validationReasons.remove(Constants.PICKLIST_VALIDATION_REASON_NONE);
        objOrder.validation_reason__c = String.join(new List<String>(validationReasons),';');

    }

    /**
    * Checks all required information for product, patient and physicians (following, implanting, explanting)
    *
    * SAFBIO-592
    *
    * @param    objOrder, the Order record for which the validation should run
    * @param    mapContactById, all contacts records related to the order
    * @param    lstAssets, all assets related directly to the order
    * @param    lstOrderItems, all Order Items related to the order records
    *
    * @author   ilu_pkas
    */
    private static void validateRequiredInfo(Order objOrder, Map<Id, Contact> mapContactById, List<Asset> lstAssets, List<OrderItem> lstOrderItems){
        if (lstOrderItems != null){
            checkProductRequiredValues(lstOrderItems);
        }
        if (objOrder == null || mapContactById.get(objOrder.implanting_physician__c) == null){
            return;
        }else {
            checkImplantingPhysicianInfo(objOrder, mapContactById);
            checkFollowingPhysicianInfo(objOrder, mapContactById);
        }
        checkExplantPhysicianInfo(lstAssets,  objOrder);

        checkPatientDateOfDeath (objOrder, mapContactById);
    }

    /**
    * Validates that the order items have a UDI and a batch no or a serial number
    *  - Products with the product types System Device and Service will be ignored
    *
    * @param    lstOrderItems, all Order Items related to the order records
    */
    public static void checkProductRequiredValues(List<OrderItem> lstOrderItems){
        List<String> applicableCategories = new List<String> {
                Constants.VALI_CAT_SYSTEM, Constants.VALI_CAT_NA
        };
        for (OrderItem objOrderItem: lstOrderItems) {
            if (applicableCategories.contains (Utility.getValidationCategory (objOrderItem.product_type__c))) {
                continue;
            }
            if (objOrderItem.udi__c == null || (objOrderItem.batch_no__c == null && objOrderItem.serial_number__c == null)){
                OrderHandler.addError(System.Label.ADD_PRODUCT_REQUIRED_VALUES + objOrderItem.Product2.Name);
            }
        }
    }

    /**
    *  check if the implanting physician has all required info before submit the order
    *
    *   SAFBIO-592
    *
    * @param    objOrder, the Order record for which the validation should run
    * @param    mapContactById, all contacts records related to the order
    */
    public static void checkImplantingPhysicianInfo(Order objOrder, Map<Id, Contact> mapContactById){
        if (mapContactById.get(objOrder.implanting_physician__c).Phone == null){
            OrderHandler.addError(System.Label.ADD_IMPLANTING_PHYSICIAN_PHONE_NUMBER);
        } else if (mapContactById.get(objOrder.implanting_physician__c).Name == null){
            OrderHandler.addError(System.Label.ADD_IMPLANTING_PHYSICIAN_NAME);

        } else if (mapContactById.get(objOrder.implanting_physician__c).MailingAddress == null){
            OrderHandler.addError(System.Label.ADD_IMPLANTING_PHYSICIAN_ADDRESS);
        }
    }

    /**
    * In case the Following physician is diffrent from the implanting physician, check if he has all required info before submit the order
    *
    * SAFBIO-592
    *
    * @param    objOrder, the Order record for which the validation should run
    * @param    mapContactById, all contacts records related to the order
    */
    public static void checkFollowingPhysicianInfo(Order objOrder,  Map<Id, Contact> mapContactById){
        if (mapContactById.get(objOrder.patient__c).following_physician__c !=null
                && mapContactById.get(objOrder.patient__c).following_physician__c != objOrder.implanting_physician__c){

            if (mapContactById.get(objOrder.patient__c).following_physician__r.Phone == null){
                OrderHandler.addError(System.Label.ADD_FOLLOWING_PHYSICIAN_PHONE);

            }else if (mapContactById.get(objOrder.patient__c).following_physician__r.Name == null){
                OrderHandler.addError(System.Label.ADD_FOLLOWING_PHYSICIAN_NAME);

            }else if (mapContactById.get(objOrder.patient__c).following_physician__r.MailingAddress == null){
                OrderHandler.addError(System.Label.ADD_FOLLOWING_PHYSICIAN_ADDRESS);
            }
        }
    }

    /**
    * If status of Asset = explanted or capped (Asset Object) check the required info of the explanting physician before submitting the order
    *
    * SAFBIO-592
    *
    * @param    objOrder, the Order record for which the validation should run
    * @param    lstAssets, all assets related directly to the order
    */
    public static void checkExplantPhysicianInfo(List<Asset> lstAssets, Order objOrder){
        if(objOrder == null || lstAssets == null){
            return;
        }
        for (Asset objAsset : lstAssets){
            if ((objAsset.Status == Constants.IMPLANT_STATUS_EXPLANTED || objAsset.Status == Constants.IMPLANT_STATUS_CAPPED)
                    && objAsset.explanting_physician__c != null){
                if (objAsset.explanting_physician__r.Name == null){
                    OrderHandler.addError(System.Label.ADD_EXPLANTING_PHYSICIAN_NAME);

                }else if (objAsset.explanting_physician__r.Phone == null){
                    OrderHandler.addError(System.Label.ADD_EXPLANTING_PHYSICIAN_PHONE);

                }else if (objAsset.explanting_physician__r.MailingAddress == null){
                    OrderHandler.addError(System.Label.ADD_EXPLANTING_PHYSICIAN_ADDRESS);
                }
            }
        }
    }

    /**
    * Check that if the patient is deceased, that the date of death is noted
    *
    * SAFBIO-592
    *
    * @param    objOrder, the Order record for which the validation should run
    * @param    mapContactById, all contacts records related to the order
    */
    public static void checkPatientDateOfDeath(Order objOrder, Map<Id, Contact> mapContactById){
        if(objOrder == null){
            return;
        }
        if(mapContactById.get(objOrder.patient__c).Status__c == Constants.PICKLIST_VALUE_CONTACT_STATUS_DECEASED && mapContactById.get(objOrder.patient__c).date_of_death__c == null){
            OrderHandler.addError(System.Label.ADD_DATE_OF_DEATH_OF_THE_PATIENT);
        }
    }

    /**
     * Checks if the patient of the order has related assets with missing oos information
     *
     * @param:  objOrder, Order which should be checked for oos information
     * @param:  patientWorkOrderMap, List of all WorkOrders related to the patient.
     *
     * @author  ilu_pkas
     */
    private static void validateOosAssets(List <Order> orders, Map<Id, WorkOrder> patientWorkOrderMap) {
        Map<Id,List<Order>> patientMap = new Map<Id, List<Order>>();
        for (Order order : orders) {
            if(!patientMap.containsKey(order.patient__c)){
                patientMap.put(order.patient__c,new List<Order>());
            }
            patientMap.get(order.patient__c).add(order);
        }

        Map<Id, List<Asset>> assetMap = getOosAssetsForPatient(patientMap.keySet());

        for(List<Asset> lstAssets : assetMap.values()){
            for (Asset asst : lstAssets) {

                if (asst.date_asset_status_changed__c == null ||
                        (patientWorkOrderMap != null && patientWorkOrderMap.containsKey(asst.patient__c) &&
                                asst.date_asset_status_changed__c >= patientWorkOrderMap.get(asst.patient__c).CreatedDate.date())) {
                    for (Order objOrder : patientMap.get(asst.patient__c)){
                        objOrder.addError(System.Label.ERR_OOS_VALIDATION);
                    }
                }
            }
        }
    }

    /**
     * Selects all Assets from a subset of patients, which are missing oos information
     *
     * @param   setPatientIds, the Ids of the subset of patients, for which the assets should be selected
     * @return  Map<Id, List<Asset>>, the selected oos assets mapped to the patient for which they were selected
     */
    private static Map<Id, List<Asset>> getOosAssetsForPatient(Set<Id> setPatientIds){
        Map<Id, List<Asset>> mapResults = new Map<Id, List<Asset>>();

        for(Asset asst :[SELECT id, name, status, date_asset_status_changed__c, patient__c, order__c,
                oos_date__c, oos_additional_information__c, Explant_Date__c,
                explant_date_unknown__c , explanting_facility__c, explanting_physician__c ,
                event_reason__c, has_attached_oos_complaints__c, Days_from_Implant_to_Explant__c,
                InstallDate
                FROM Asset
                WHERE Status IN :Constants.OOS_STATUS
                        AND patient__c IN :setPatientIds
                        AND imported_as_oos__c = FALSE
                        AND RecordType.DeveloperName = : Constants.RECORD_TYPE_NAME_ASSET_US_BIOTRONIK
                        AND (date_asset_status_changed__c = NULL OR date_asset_status_changed__c <= :System.today() )
        ]){

            if(checkOOSFields(asst)){
                if (mapResults.isEmpty() || !mapResults.containsKey(asst.patient__c)) {
                    mapResults.put(asst.patient__c, new List<Asset>{asst});
                } else{
                    mapResults.get(asst.patient__c).add(asst);
                }
            }
        }
        return mapResults;
    }

    /**
     * Checks if OOS Validation is to be thrown
     *
     * @param   assetObj, instance of Asset
     * @return  boolean, value if OOS validation to be thrown
     */
    private static Boolean checkOOSFields(Asset assetObj) {
        if( (assetObj.oos_date__c == null
                || assetObj.oos_additional_information__c   == null
                || (assetObj.status == Constants.IMPLANT_STATUS_EXPLANTED && assetObj.explant_Date__c == null && assetObj.explant_date_unknown__c == false)
                || assetObj.event_reason__c == null
                || (assetObj.has_attached_oos_complaints__c == false
                &&
                ((assetObj.event_reason__c == Constants.PICKLIST_VALUE_OOS_REASON_ERI && assetObj.Days_from_Implant_to_Explant__c < 1825 )
                        || (assetObj.event_reason__c == Constants.PICKLIST_VALUE_OOS_REASON_PATIENT_DEATH && assetObj.InstallDate != null && assetObj.Days_from_Implant_to_Explant__c == 0)
                        || (assetObj.event_reason__c != Constants.PICKLIST_VALUE_OOS_REASON_UPGRADE )
                )))) {

            return true;
        }
        return false;
    }

    /**
    * Retunr a map of Patient and its related Work Order
    *
    * @param    orderIdSet          the Ids of theOrder
    * @return   Map<Id, WorkOrder>  Map of Patient to its Work Order
    *
    * NOTE- This is done only for single record at the moment as discussed in 1405 ticket
    */
    private static Map<Id, WorkOrder> getPatientWorkOrderMap(Set<Id> orderIdSet) {
        Map<Id, WorkOrder> patientWorkOrderMap = new Map<Id, WorkOrder>();

        for(Order objOrder : [SELECT Id, patient__c,
        (SELECT CreatedDate FROM Implants_Procedures__r)
                FROM Order
                WHERE Id IN :orderIdSet ]) {
            if(objOrder.Implants_Procedures__r != null && objOrder.Implants_Procedures__r.size() > 0) {
                patientWorkOrderMap.put(objOrder.patient__c, objOrder.Implants_Procedures__r);
            }
        }
        return patientWorkOrderMap;
    }



    /**
     * Validation for a given order record based on its related records.
     * Checks all CAS, CS and OoS validation, for details on each take a look in the sections below
     *
     * @param objOrder the Order record for which the validation should run
     * @param OrderItemList  all Order Items related to the order records
     * @param accountMap the accounts used in this order including their shipping state
     * @param assetList all assets related directly to the order
     */
    private static void validateCriteria(Order objOrder, List<OrderItem> OrderItemList, Map<Id, Account> accountMap, List<Asset> assetList) {
        countRelatedRecords(objOrder, OrderItemList, assetList);
        checkValidationReasons(objOrder, OrderItemList, assetList, accountMap);
    }

    /**
    * Counts how many Order Items and Assets are related to an order.
    *   - Device with the status implanted
    *   - Leads with the status implanted
    *   - Assets with the status implanted
    *
    * @param    objOrder, Order which should be checked
    * @param    lstOrderItems, list with all order items related to an order
    * @param    lstAssets, lis with all assets related to an order
    */
    private static void countRelatedRecords(Order objOrder, List<OrderItem> orderItems, List<Asset> assets){
        implantedDeviceCount = 0;
        implantedAssetCount = 0;
        leadAttached = 0;

        if(orderItems != null) {
            for( OrderItem orderItem: orderItems) {
                countImplantedDevice(orderItem);
                countLead(orderItem);
            }
        }

        if (assets != null){
            for (Asset asset : assets){
                countImplantedAsset(objOrder, asset);
            }
        }
    }
	
    /**
	* If an order item is a Device, Pacemaker oder ICD and it's status is implanted,
	* 	the counter for implanted devices will be increased
	*
	* @param 	orderItem, OrderItem which should be checked and counted
	*/
    private static void countImplantedDevice (OrderItem orderItem) {
        if (Utility.getValidationCategory (orderItem.product_type__c) == Constants.VALI_CAT_DEVICE
                && orderItem.status__c == Constants.IMPLANT_STATUS_IMPLANTED)  {
            implantedDeviceCount += 1;
        }
    }

    
    /**
    * Count the number of implanted asset attached to the order with type Device, pacemaker or ICD
    *
    * SAFBIO-776
    *
    * @param    asset, Asset which should be checked and counted
    * @author   emma
    */
    private static void countImplantedAsset (Order order, Asset asset) {
        if ((Utility.getValidationCategory(asset.product_type__c) == Constants.VALI_CAT_DEVICE ||
                Utility.getValidationCategory (asset.product_type__c) == Constants.VALI_CAT_LOOP_RECORDER)
                && asset.Status == Constants.IMPLANT_STATUS_IMPLANTED
                && asset.patient__c == order.patient__c) {
            implantedAssetCount += 1;
        }
    }

    /**
    * Count the number of leads attached to the order
    *
    * @param    orderItem, OrderItem which should be checked and counted
    */
    private static void countLead (OrderItem orderItem) {
        if (Utility.getValidationCategory(orderItem.product_type__c) == Constants.VALI_CAT_LEAD) {

            if (orderItem.status__c == Constants.IMPLANT_STATUS_IMPLANTED) {
                leadAttached += 1;
            }
        }
    }

    /**
    * validates the order for the CAS use cases
    *
    * Performed Validations:
    *   - Bulk OrderItem > 0$
    *   - Lead/Device = 0$ and not System
    *   - System OrderItem > 0$
    *   - Price Discrepancy = Bulk Swap
    *   - Device > 1
    *   - Donation = true
    *   - MDRF = Puerto Rico
    *
    * @param    objOrder, the Order record for which the validation should run
    * @param    OrderItemList, all Order Items related to the order records
    * @param    accountMap, the accounts used in this order including their shipping state
    * @param    assetList all assets related directly to the order
    *
    * @author   ilu_pkas
    */
    private static void checkValidationReasons(Order objOrder, List<OrderItem> OrderItemList, List<Asset> assetList, Map<Id, Account> accountMap){

        if(OrderItemList != null) {
            for( OrderItem objOrderItem: OrderItemList) {
                // Bulk OrderItem > 0$ - (CAS)
                checkBulkOrderItemWithPrice(objOrderItem, objOrder);

                if(objOrder.donation__c == false){
                    // Lead/Device = 0$ and not System - (CAS)
                    productOutsideSystem(objOrderItem, objOrder);
                }

                // System OrderItem > 0$ -  (CAS)
                partOfSystemWithPrice(objOrderItem, objOrder);

                // Price Discrepancy = Bulk Swap - (CAS)
                bulkSwap(objOrderItem, objOrder);

            }
        }
        // Donation = true - (CAS)
        checkDonation(objOrder);

        // MDRF = Puerto Rico - (CAS)
        checkLocationFacility(objOrder, accountMap);

        // CS
        // SAFBIO-767
        checkDeviceWithOnlyOneLead(objOrder, OrderItemList, assetList);

        // Only 1 Order Item on MDRF
        checkOnlyOneOrderItem(OrderItemList, objOrder, assetList);

        // Device = 0
        checkLeadAttachedButNoDevice(objOrder);
        
        // Device > 1 - (CS) - SAFBIO-598 - Check number of 'implanted' MDRF devices
        if(implantedDeviceCount > 1 ){
            OrderValidation.updateOrderReason(objOrder, Constants.PICKLIST_VALIDATION_REASON_MORE_THAN_ONE_DEVICE_ON_MDRF);
        }
    }

    /********************************
    *           CAS Methods         *
    ********************************/

    /**
    * Checks if any of the MDRF related OrderItems doesnt belong to System
    * AND related OrderItems = Devices OR Leads AND related OrderItems Price = 0
    *
    * SAFBIO-602
    *
    * @param    objOrder, Order which should be checked for a products outside the system
    * @param    objOrderItem, the Order Item which should be checked
    *
    * @author   ilu_pkas
    */
    private static void productOutsideSystem(OrderItem objOrderItem, Order objOrder) {
        List<String> applicableCategories = new List<String> {
                Constants.VALI_CAT_LEAD, Constants.VALI_CAT_DEVICE, Constants.VALI_CAT_CARDIO_MESSENGER, Constants.VALI_CAT_LOOP_RECORDER
        };
        if (applicableCategories.contains(Utility.getValidationCategory(objOrderItem.product_type__c)) &&
                (objOrderItem.UnitPrice == 0 || objOrderItem.UnitPrice == null) &&
                objOrderItem.UnitPrice != objOrderItem.ListPrice &&
                !objOrderItem.part_of_system_price__c &&
                objOrderItem.stock_type__c != null &&
                !objOrderItem.stock_type__c.equalsIgnoreCase(Constants.PICKLIST_VALUE_ORDER_ITEM_STOCK_TYPE_BULK)) {

            OrderValidation.updateOrderReason(objOrder, Constants.PICKLIST_VALIDATION_REASON_ZERO_DOLLAR_PRODUCT_OUTSIDE_SYSTEM);
        }
    }

    /**
    * Checks if any of the MDRF related OrderItems is a bulk product and has a price
    *
    * SAFBIO-603
    *
    * @param    objOrder, Order which should be checked for bulk products
    * @param    objOrderItem, the Order Item which should be checked
    *
    * @author   ilu_pkas
    */
    private static void checkBulkOrderItemWithPrice(OrderItem objOrderItem, Order objOrder) {
        if (objOrderItem.stock_type__c != null
                && objOrderItem.stock_type__c.equalsIgnoreCase(Constants.PICKLIST_VALUE_ORDER_ITEM_STOCK_TYPE_BULK)
                && objOrderItem.UnitPrice > 0) {
            OrderValidation.updateOrderReason(objOrder, Constants.PICKLIST_VALIDATION_REASON_BULK_PRODUCT_WITH_PRICE_GREATER_ZERO);
        }
    }

    /**
    * Checks if any of the MDRF related OrderItems = is part of a system should have $0 price.
    *   If an OrderItem that is part of a system has a price greater than $0
    *
    * SAFBIO-604
    *
    * @param    objOrder, Order which should be checked
    * @param    objOrderItem, the Order Item which should be checked
    *
    * @author   ilu_pkas
    */
    private static void partOfSystemWithPrice(OrderItem objOrderItem, Order objOrder) {
        if(objOrderItem.UnitPrice > 0 && objOrderItem.part_of_system_price__c) {
            OrderValidation.updateOrderReason(objOrder, Constants.PICKLIST_VALIDATION_REASON_PART_OF_SYSTEM_AND_PRICE_GREATER_ZERO);
        }
    }

    /**
    * Check if the order is a Donation
    *
    * SAFBIO-617
    *
    * @param    objOrder, Order which should be checked
    *
    * @author   ilu_pkas
    */
    private static void checkDonation(Order objOrder) {
        if(objOrder.donation__c) {
            OrderValidation.updateOrderReason(objOrder, Constants.PICKLIST_VALIDATION_REASON_DONATION);
        }
    }

    /**
    * Check if the implanting facility is located in Puerto Rico (we bill the insurance company not the hospital)
    *
    * SAFBIO-879

    * @param    objOrder, Order which should be checked
    * @param    accountMap, the accounts used in this order including their shipping state
    *
    * @author   snpa
    */
    private static void checkLocationFacility(Order objOrder, Map<Id, Account> accountMap) {

        if(objOrder.AccountId != null &&  accountMap != null &&
                !accountMap.isEmpty() &&  accountMap.containsKey(objOrder.AccountId) &&
                accountMap.get(objOrder.AccountId).ShippingState != null &&
                accountMap.get(objOrder.AccountId).ShippingState != '' &&
                accountMap.get(objOrder.AccountId).ShippingState.equalsIgnoreCase(Constants.ACCOUNT_SHIPPING_STATE_PUERTO_RICO)
                ) {
            OrderValidation.updateOrderReason(objOrder, Constants.PICKLIST_VALIDATION_REASON_IMPLANTING_FACILITY_IN_PUERTO_RICO);
        }
    }

    /**
    * Check if "price discrepancy Reason" field is set to "Bulk"
    *
    * SAFBIO-880
    *
    * @param    objOrder, Order which should be checked
    * @param    objOrderItem, the Order Item which should be checked
    *
    * @author   snpa
    */
    private static void bulkSwap(OrderItem objOrderItem, Order objOrder) {
        if(String.isNotBlank(objOrderItem.price_discrepancy_reason__c) &&
                objOrderItem.price_discrepancy_reason__c.equalsIgnoreCase(Constants.PICKLIST_VALUE_ORDER_ITEM_DISCREPANY_REASON_BULKSWAP) ) {
            OrderValidation.updateOrderReason(objOrder, Constants.PICKLIST_VALIDATION_REASON_PRICE_DISCREPANCY_REASON_BULK_SWAP);
        }
    }

    /********************************
    *   Customer Solution Methods   *
    ********************************/

    /**
    *   If only one Order Item (product type equals 'Device' OR 'ICD' OR 'Pacemaker')
    *       was attached to the submitted Order Record
    *   AND NO OrderItem with product Type 'Lead' and Status 'Implanted' is related to the
    *       Patient (on the Order-Record)
    *
    * SAFBIO-766
    *
    * @param    objOrder, Order which should be checked
    * @param    objOrderItem, the Order Item which should be checked
    * @param    assetList, all assets related directly to the order
    *
    * @author   snpa
    */
    private static void checkOnlyOneOrderItem(List<OrderItem> OrderItemList, Order objOrder, List<Asset> assetList) {
        Integer countLead = 0;
        if(assetList != null){
            for(Asset ast :assetList){
                if (Utility.getValidationCategory(ast.product_type__c) == Constants.VALI_CAT_LEAD
                   		&& ast.Status == Constants.IMPLANT_STATUS_IMPLANTED) {
                    countLead++;
                }
            }
        }

        if(OrderItemList != null && OrderItemList.size() == 1 && countLead == 0 &&
                OrderItemList[0].Product2.sub_group_4__c != 'No Classication' &&
                Utility.getValidationCategory (OrderItemList[0].product_type__c) == Constants.VALI_CAT_DEVICE) {

            OrderValidation.updateOrderReason(objOrder, Constants.PICKLIST_VALIDATION_REASON_DEVICE_WITH_NO_LEADS);
        }
    }

    /**
    * Check if there is at least one lead and no device or icd or pacemaker attached (CS)
    *
    * If only Order Items (Product Type = 'Lead') was attached to the submitted Order Record
    * AND NO Asset with Product Type 'Device' OR 'ICD' OR 'Pacemaker' and Status 'Implanted'
    *
    * SAFBIO-776
    *
    * @param    objOrder, Order which should be checked
    *
    * @author   emma
    */
    private static void checkLeadAttachedButNoDevice(Order objOrder){
        if(leadAttached>= 1 && implantedAssetCount < 1){
            OrderValidation.updateOrderReason(objOrder, Constants.PICKLIST_VALIDATION_REASON_LEAD_WITH_NO_DEVICE);
        }
    }

    /**
    * Check if there is an Order with only one lead attached
    *
    * SAFBIO-767
    *
    * @param    objOrder, Order which should be checked
    *
    * @author   ilu_pkai
    */
    private static void checkDeviceWithOnlyOneLead(Order objOrder, List<OrderItem> lstOrderItems, List<Asset> assetList) {
        
        system.debug('*****leadAttached*'+leadAttached);
        if (leadAttached == 0 || leadAttached > 1 || lstOrderItems == null) {
            return;
        }
        Boolean isMultiLeadProd = true;
        Boolean hasDevice = false;
        OrderItem itemLead;
        String strSingleLeadProdSubGroups = Utility.getSettingValue('SINGEL_LEAD_PRODUCT_SUB_GROUP',null);
        Set<String> setSingleLeadProdSubGroup = new Set<String>(strSingleLeadProdSubGroups.split(';'));

        for (OrderItem itm : lstOrderItems) {
            if (itm.status__c == Constants.IMPLANT_STATUS_IMPLANTED) {
                if (Utility.getValidationCategory(itm.product_type__c) != Constants.VALI_CAT_LEAD
                        && setSingleLeadProdSubGroup.contains(itm.Product2.sub_group_4__c)) {
                    isMultiLeadProd = false;
                } else if (Utility.getValidationCategory(itm.product_type__c) == Constants.VALI_CAT_LEAD) {
                    itemLead = itm;
                }
                if (Utility.getValidationCategory(itm.product_type__c) == Constants.VALI_CAT_DEVICE){
                    // error should only displayed if there is a Device
                    hasDevice = true;
                }
            }
        }

        Integer implantedLeadAssets = 0;
        if (assetList != null && assetList.size() > 0) {
            for (Asset ast : assetList) {
                if (Utility.getValidationCategory(ast.product_type__c) == Constants.VALI_CAT_LEAD && ast.Status == Constants.IMPLANT_STATUS_IMPLANTED) {
                    if(itemLead != null && ast.Id == itemLead.asset__c){
                        //is the same asset then lead
                        continue;
                    }
                    implantedLeadAssets++;
                }
            }
        }

        if (hasDevice && isMultiLeadProd && (implantedLeadAssets + leadAttached <= 1)) {
            OrderValidation.updateOrderReason(objOrder, Constants.PICKLIST_VALIDATION_REASON_DEVICE_WITH_ONLY_ONE_LEAD);
        }
    }
}