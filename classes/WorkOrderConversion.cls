/* Created 2018-05-18, Florian Heer <f.heer@conciscon.de>
* 
* This class provides functionality to convert WorkOrders to Orders. 
* Includes conversion from Product Item - Product Consumed to Order Item - Asset
*/ 

public without sharing class WorkOrderConversion {

    public static String DEFAULT_ORDER_STATUS = Constants.PICKLIST_VALUE_STATUS_NOT_SUBMITTED;

    public static final String ASSET_RELATIONSHIP_FOR_CHANGEOUT = 'replaces';
    public static final String STOCK_TYPE_BULK = 'B';
    
    //RecordTypIds
    private static Id assetRTId = Utility.getRecordTypeId(Asset.SObjectType, Constants.RECORD_TYPE_NAME_ASSET_US_BIOTRONIK);
      
    /* Returns the fields of an Order just as necessary for this class
     * @param orderId the id of the order to be retrieved.
     */
    private static Order getAnOrderAsILikeIt(String orderId) {
        return [SELECT donation__c, patient__c, AccountId, implant_date__c,
                             Account.crm_pricebook__c, CurrencyIsoCode FROM Order WHERE Id = :orderId];
    }
    
    /* Just a facade to take less arguments.
     * @param orderId the Order with which the resulting OrderItem will be associated
     * @param productConsumedId Id of the ProductConsumed record that should be converted to an OrderItem and an asset
     * @return the created asset
     */
    public static Asset convertProduct(String orderId, String productConsumedId) {
        return convertProduct(orderId, productConsumedId, false);
    }
    /* Converts a given ProductConsumed record into an OrderItem and an Asset. This method will retrieve the Pricebook from the
     * Order.
     * @param orderId the Order with which the resulting OrderItem will be associated
     * @param productConsumedId Id of the ProductConsumed record that should be converted to an OrderItem and an asset
     * @param replenish Sets the flag to replenish a product on the OrderItem
     * @return the created Asset
     */
    public static Asset convertProduct(String orderId, String productConsumedId, Boolean replenish) {

        
        List<ProductConsumed> pcs = [SELECT 
                                     Product2.Name, status__c, 
                                     av_delay_pace__c, brady_channel__c, 
                                     charge_time__c, cm_active__c,
                                     // comment_oos__c,  // 2018-06-28 FH SAFBIO-1314
                                     sap_account_no__c, dft__c, 
                                     // OOS_reason__c ? event_reason__c ?
                                     ProductItem.expiration_date_ubd__c, expired_ubd_acknowledged__c, CurrencyIsoCode, Product2Id, QuantityConsumed, 
                                     UnitPrice, PricebookEntryId, 
                                     ProductItem.batch_no__c, 
                                     implant_date__c, 
                                     Product2.ProductCode, 
                                     Id, 
                                     ProductItem.SerialNumber, ProductItem.barcode__c,  // barcode needs to go in OrderItem.barcode__c - is being added at the moment.
                                     ProductItem.date_of_manufacture__c, // Needs to go in OrderItem.date_of_manufacture__c - is being added at the moment.
                                     ProductItem.stocktype__c, 
                                     udi__c, ProductItem.LocationId, 
                                     Product2.sap_model_no__c, WorkOrder.implanting_physician__c, 
                                     shock_impedance__c, slew_rate__c, Product2.study_product__c, sensitivity_mv_rv__c, 
                                     sensitivity_a__c, sensitivity_v__c, sensitivity_mv_atrium__c, 
                                     sensitivity_mv_lv__c, pulse_width_ms_atrium__c, pulse_width_ms_lv__c, Pulse_width_ms_rv__c, 
                                     r_amp__c, pulse_amplitude_v_lv__c, pulse_amplitude_v_rv__c, pulse_width__c, 
                                     polarity_sensing_rv__c, pulse_amplitude_v__c, polarity_pacing_rv__c, 
                                     polarity_sensing_atrium__c, polarity_sensing_lv__c, pid_ui__c, polarity__c, polarity_pacing_atrium__c,
                                     polarity_pacing_lv__c, mode_switch__c,
                                     // oos_additional_information__c, oos_date__c, // SAFBIO-1355
                                     p_amp__c,
                                     patient__c, lower_rate__c, 
                                     ProductItem.manufacturer__c, 
                                     mode__c, serial_number__c,
                                     // explanting_facility__c, explanting_physician__c, // SAFBIO-1355
                                     impedance__c,
                                     last_movement_date__c, Lead_Tip_Location__c, Tachy_Channel__c, Threshold__c, upper_rate__c,
                                     Product2.manufacturer__c, Product2.product_type__c,
                                     asset__c,
                                     // batch_no__c, // SAFBIO-1355
                                     ProductItem.udi__c, ProductItem.product_type__c,
                                     ProductItem.product_code__c,
                                     replenish__c
                                     FROM ProductConsumed WHERE Id = :productConsumedId];
        if(pcs.size() > 0) {
        	System.debug('AAA woc orderId: ' + orderId);
            Order myOrder = getAnOrderAsILikeIt(orderId);            
            System.debug('AAA woc currency (order): ' + myOrder.CurrencyIsoCode);
            Map<Id, PricebookEntry> pbeMap = new Map<Id, PricebookEntry>();
            for (PricebookEntry pbe : [SELECT Id, UnitPrice, Product2Id FROM PricebookEntry WHERE Pricebook2Id = :myOrder.Account.crm_pricebook__c
                                         AND Product2Id = :pcs[0].Product2Id AND CurrencyIsoCode = :myOrder.CurrencyIsoCode]) {
                pbeMap.put(pbe.Product2Id, pbe);
            }
            
            ConvertedProductConsumedHolder cpcHolder = convertProduct(myOrder, pcs[0], pbeMap, replenish);
            
            insert cpcHolder.oi;
            cpcHolder.ass.order_product__c = cpcHolder.oi.Id;
            System.debug('BBB woc prodtype: ' + cpcHolder.ass.product_type__c + ' manu: ' + cpcHolder.ass.manufacturer__c + ' prod: ' + cpcHolder.ass.Product2Id + ' SerialNumber: ' + cpcHolder.ass.SerialNumber);
            insert cpcHolder.ass;
            upsert new OrderItem(Id=cpcHolder.oi.Id, asset__c = cpcHolder.ass.Id);
            If(cpcHolder.relatedAsset != null) {
                insert new AssetRelationship(AssetId = cpcHolder.ass.Id, RelatedAssetId = cpcHolder.relatedAsset, RelationshipType = ASSET_RELATIONSHIP_FOR_CHANGEOUT);
            }            
            return cpcHolder.ass;
            
        }
        return null;
        
    }
    
    /* Converts a ProductConsumed to an OrderItem (linked to the supplied Order) and an Asset linked to that OrderItem. This method
     * takes a map of Pricebook-Entries from the caller.
     * 
     * @param myOrder the Order to connect the new OrderItem to. Make sure that myOrder.Account.crm_pricebook__c exists
     * @param pc the ProductConsumed that needs to be converted
     * @param pbes Map of Product2-Id and PricebookEntry
     */    
    public static ConvertedProductConsumedHolder convertProduct (Order myOrder, ProductConsumed pc, Map<Id, PricebookEntry> pbeMap) {
        return convertProduct (myOrder, pc, pbeMap, false);
    }

    public static ConvertedProductConsumedHolder convertProduct (Order myOrder, ProductConsumed pc, Map<Id, PricebookEntry> pbeMap, Boolean replenish) {
		return convertProduct (myOrder, pc, pbeMap, replenish, null);
    }
    
    public static ConvertedProductConsumedHolder convertProduct (Order myOrder, ProductConsumed pc, Map<Id, PricebookEntry> pbeMap, Boolean replenish, String sapCompanyCode) {
        ConvertedProductConsumedHolder cpcHolder = new ConvertedProductConsumedHolder();
        cpcHolder.pc = pc;
        
        String errAssetRelationshipCreate = Schema.SObjectType.AssetRelationship.isCreateable() ? '' : 'Create AssetRelationship';
        String errAssetCreate = Schema.SObjectType.Asset.isCreateable() ? '' : 'Create Asset';
        String errOrderItemCreate = Schema.SObjectType.OrderItem.isCreateable() ? '' : 'Create OrderItem';
        String errOrderItemUpdate = Schema.SObjectType.OrderItem.isUpdateable() ? '' : 'Update OrderItem';
        
        if(errAssetRelationshipCreate == '' 
           && errAssetCreate == ''
           && errOrderItemCreate == ''
           && errOrderItemUpdate == ''
          ) {
              if(assetRTId == null) { 
                  throw new WorkOrderConversionException (String.format(Label.cannot_find_recordtype, new List<String> {Constants.RECORD_TYPE_NAME_ASSET_US_BIOTRONIK}));
              }
              
              System.debug('ConvertProduct: Pricebook: ' + myOrder.Account.crm_pricebook__c + ' ProductId: ' + pc.Product2Id);
              
              PricebookEntry pbe = pbeMap.get(pc.Product2Id);
              if (pbe == null) {
                  throw new WorkOrderConversionException(String.format(Label.product_not_in_pricebook, new List<String> {pc.Product2.Name, pc.Product2Id, myOrder.CurrencyIsoCode}));
              }
              
              
              Id orderId = myOrder.Id;
              //SAFBIO-1540 set replenish flag 
              if(Schema.sObjectType.OrderItem.isCreateable() && Schema.sObjectType.OrderItem.isUpdateable()) {

                  OrderItem oi = new OrderItem(OrderId = orderId
                                               , Product2Id = pc.Product2Id
                                               , Quantity = pc.QuantityConsumed
                                               , UnitPrice = (myOrder.donation__c || pc.ProductItem.stocktype__c == STOCK_TYPE_BULK) ? 0 : pbe.UnitPrice
                                               , PricebookEntryId = pbe.Id
                                               , status__c = pc.status__c
                                               , batch_no__c = pc.ProductItem.batch_no__c
                                               , date_of_manufacture__c = pc.ProductItem.date_of_manufacture__c
                                               , expiration_date_ubd__c = pc.ProductItem.expiration_date_ubd__c
                                               , implant_date__c = myOrder.implant_date__c
                                               , location__c = pc.ProductItem.LocationId
                                               , model_no__c = pc.Product2.sap_model_no__c //product_code__c
                                               , part_of_donation__c = myOrder.donation__c
                                               , product_consumed__c = pc.Id
                                               , product_type__c = pc.Product2.product_type__c
                                               , expired_ubd_acknowledged__c = pc.expired_ubd_acknowledged__c
                                               // ??                                             // , replace_existing_cm__c = pc.replace_existing_cm__c
                                               , replenish__c = (pc.ProductItem.stocktype__c == STOCK_TYPE_BULK ? false : pc.replenish__c)
                                               , sap_account_no__c = pc.sap_account_no__c
                                               , sap_stock_location__c = pc.ProductItem.LocationId
                                               , serial_number__c = pc.ProductItem.SerialNumber
                                               , barcode__c = pc.ProductItem.barcode__c
                                               , stock_type__c = pc.ProductItem.stocktype__c
                                               , udi__c = pc.ProductItem.udi__c
                                               , product_code__c = pc.ProductItem.product_code__c
                                              );
                  cpcHolder.oi = oi;
                  
                  if(Schema.sObjectType.Asset.isCreateable()) {
                      // Conversion from ProductConsumed should never have to deal with Competitor or System - these cannot come from inventory.
                      Id assetRecordTypeId = assetRTId;
                      
                      Asset ass = new Asset (CurrencyIsoCode = pc.CurrencyIsoCode,
                                             Name = pc.Product2.Name,
                                             RecordTypeId = assetRecordTypeId,
                                             IsCompetitorProduct = false,
                                             ContactId = myOrder.patient__c,
                                             // It is absolutely necessary to have an account either directly or through the patient
                                             AccountId = myOrder.AccountId,
                                             InstallDate = myOrder.implant_date__c,
                                             LocationId = pc.ProductItem.LocationId,
                                             Price = pc.UnitPrice,
                                             Product2Id = pc.Product2Id,
                                             // Order ?                                           PurchaseDate = pc.PurchaseDate,
                                             Quantity = pc.QuantityConsumed,
                                             SerialNumber = pc.serial_number__c,
                                             Status = pc.status__c,
                                             av_delay_pace__c = pc.av_delay_pace__c,
                                             batch_no__c = pc.ProductItem.batch_no__c,
                                             brady_channel__c = pc.brady_channel__c,
                                             charge_time__c = pc.charge_time__c,
                                             cm_active__c = pc.cm_active__c,
                                             // comment_oos__c = pc.comment_oos__c, // 2018-06-28 FH SAFBIO-1314
                                             sap_company_code__c = (sapCompanyCode == null ? pc.sap_account_no__c : sapCompanyCode),
                                             date_of_manufacture__c = pc.ProductItem.date_of_manufacture__c,
                                             dft__c = pc.dft__c,
                                             
                                             expiration_date_ubd__c = pc.ProductItem.expiration_date_ubd__c,
                                             expired_ubd_acknowledged__c = pc.expired_ubd_acknowledged__c,
                                             // explanting_facility__c = pc.explanting_facility__c, // SAFBIO-1355
                                             // explanting_physician__c = pc.explanting_physician__c,
                                             impedance__c = pc.impedance__c,
                                             implanting_physician__c = pc.WorkOrder.implanting_physician__c,
                                             last_movement_date__c = pc.last_movement_date__c,
                                             Lead_Tip_Location__c = pc.Lead_Tip_Location__c,
                                             lower_rate__c = pc.lower_rate__c,
                                             manufacturer__c = pc.Product2.manufacturer__c,
                                             mode__c = pc.mode__c,
                                             //model_name__c = pc.Product2.Name,
                                             model_no__c = pc.Product2.sap_model_no__c,
                                             mode_switch__c = pc.mode_switch__c,
                                             // oos_additional_information__c = pc.oos_additional_information__c, // SAFBIO-1355
                                             // oos_date__c = pc.oos_date__c,
                                             order__c = orderId,
                                             // TODO: update later
                                             // order_product__c = oi.Id,
                                             p_amp__c = pc.p_amp__c,
                                             // part_of_donation__c = myOrder.donation__c,
                                             patient__c = myOrder.patient__c,
                                             pid__c = pc.pid_ui__c,
                                             polarity__c = pc.polarity__c,
                                             polarity_pacing_atrium__c = pc.polarity_pacing_atrium__c,
                                             polarity_pacing_lv__c = pc.polarity_pacing_lv__c,
                                             polarity_pacing_rv__c = pc.polarity_pacing_rv__c,
                                             polarity_sensing_atrium__c = pc.polarity_sensing_atrium__c,
                                             polarity_sensing_lv__c = pc.polarity_sensing_lv__c,
                                             polarity_sensing_rv__c = pc.polarity_sensing_rv__c,
                                             product_type__c = pc.ProductItem.product_type__c,
                                             pulse_amplitude_v_atrium__c = pc.pulse_amplitude_v__c,
                                             pulse_amplitude_v_lv__c = pc.pulse_amplitude_v_lv__c,
                                             pulse_amplitude_v_rv__c = pc.pulse_amplitude_v_rv__c,
                                             pulse_width__c = pc.pulse_width__c,
                                             pulse_width_ms_atrium__c = pc.pulse_width_ms_atrium__c,
                                             pulse_width_ms_lv__c = pc.pulse_width_ms_lv__c,
                                             Pulse_width_ms_rv__c = pc.Pulse_width_ms_rv__c,
                                             r_amp__c = pc.r_amp__c,
                                             sap_stock_location__c = pc.ProductItem.LocationId,
                                             sensitivity_mv_atrium__c = pc.sensitivity_mv_atrium__c,
                                             sensitivity_mv_lv__c = pc.sensitivity_mv_lv__c,
                                             sensitivity_mv_rv__c = pc.sensitivity_mv_rv__c,
                                             sensitivity_a__c = pc.sensitivity_a__c,
                                             sensitivity_v__c = pc.sensitivity_v__c,
                                             shock_impedance__c = pc.shock_impedance__c,
                                             slew_rate__c = pc.slew_rate__c,
                                             stock_type__c = pc.ProductItem.stocktype__c,
                                             study_product__c = pc.Product2.study_product__c,
                                             Tachy_Channel__c = pc.Tachy_Channel__c,
                                             Threshold__c = pc.Threshold__c,
                                             UDI__c = pc.UDI__c,
                                             upper_rate__c = pc.upper_rate__c
                                             
                                            );
                      // TODO: insert later
                      // insert ass;
                      cpcHolder.ass = ass;
                      
                      // TODO: update later
                      // oi.asset__c = ass.Id;
                      // update oi;
                      
                      if(pc.asset__c != null) {
                          // It seems we have a Changeout-item here
                          // TODO: create later
                          // AssetRelationship arel = new AssetRelationship(AssetId = ass.Id, RelatedAssetId = pc.asset__c, RelationshipType = ASSET_RELATIONSHIP_FOR_CHANGEOUT);
                          cpcHolder.relatedAsset = pc.asset__c;
                          
                          // TODO: insert later
                          // insert arel;
                      }
                      
                      
                      return cpcHolder;
                  }
              }
          }
        else {
            // SAFBIO-2092 - gives better info on what rights are missing
            throw new WorkOrderConversionException(Label.access_rights_missing 
                                                   + '(' + errAssetRelationshipCreate
                                                   + errAssetCreate
                                                   + errOrderItemCreate
                                                   + errOrderItemUpdate 
                                                   + ')');
        }
        return null;
    }
    
    public static void convertProducts (Order myOrder, List<ProductConsumed> conProducts, Map<Id, PricebookEntry> pbeMap) {
        List<ConvertedProductConsumedHolder> conHolders = new List<ConvertedProductConsumedHolder>();
        
        for(ProductConsumed conProd : conProducts) {
            conHolders.add(convertProduct(myOrder, conProd, pbeMap));
        }
         
        List<OrderItem> ois = new List<OrderItem>();
        for(ConvertedProductConsumedHolder cpcHolder : conHolders) {
            ois.add(cpcHolder.oi);
        }
        insert ois;
        
        List<Asset> assets = new List<Asset>();
        for(ConvertedProductConsumedHolder cpcHolder : conHolders) {
			cpcHolder.ass.order_product__c = cpcHolder.oi.Id;
            assets.add(cpcHolder.ass);
        }
        insert assets;

        assets = new List<Asset> ();
        
        ois = new List<OrderItem>();
        List<AssetRelationship> arels = new List<AssetRelationship>();
        for(ConvertedProductConsumedHolder cpcHolder : conHolders) {
            ois.add(new OrderItem(Id = cpcHolder.oi.Id, asset__c = cpcHolder.ass.Id));
            if(cpcHolder.relatedAsset != null) {
                arels.add(new AssetRelationship(AssetId = cpcHolder.ass.Id, RelatedAssetId = cpcHolder.relatedAsset, RelationshipType = ASSET_RELATIONSHIP_FOR_CHANGEOUT));
                // f.heer: SAFBIO-2281 explant date of replaced Asset to be set automatically
                assets.add (new Asset (Id = cpcHolder.relatedAsset, explant_date__c = cpcHolder.ass.InstallDate) );
            }
        }
        upsert assets;
        update ois;
        if(arels.size()>0) {
        	insert arels;
        }
        
    }
    

    /* Converts a WorkOrder to an Order, including ProductItems. The result will always be the RecordType of implant Order.
     * @param workOrderId the Id of the WorkOrder record to be converted.
     * @return the resulting Order object (already inserted);
     */
    public static Order convertToOrder (String workOrderId) {
        Id orderRtId;
        List<RecordTypeInfo> orderRTs = Schema.SObjectType.Order.getRecordTypeInfos();
        for(RecordTypeInfo rti : orderRTs) {
            if(rti.getDeveloperName() == Constants.RECORD_TYPE_NAME_ORDER_MDRF) {
                orderRtId = rti.getRecordTypeId();
                break;
            }
        }

        return convertToOrder(workOrderId, orderRtId);
    }

    /* Converts a WorkOrder to an Order, including ProductItems.
     * @param workOrderId Id of the WorkOrder to convert
     * @param orderRtId Id of the RecordType to use for the target Order.
     * @return the new created (and insert) Order - or an Exception
     * SAFBIO-1890 remove Donation
     */
    public static Order convertToOrder (String workOrderId, Id orderRtId) {
        return convertToOrder (workOrderId, orderRtId, null);
    }
    
    public static Order convertToOrder (Id workOrderId, Id orderRtId, String sapCompanyCode) {
        Order orderNew;
        String errOrderCreate = Schema.SObjectType.Order.isCreateable() ? '' : 'Create Order';
        String errWorkOrderUpdate = Schema.SObjectType.WorkOrder.isUpdateable() ? '' : 'Update WorkOrder';
        String errWorkOrderLineItemUpdate = Schema.SObjectType.WorkOrderLineItem.isUpdateable() ? '' : 'Update WorkOrderLineItem';
        
        if(errOrderCreate == ''
           && errWorkOrderUpdate == ''
           && errWorkOrderLineItemUpdate == ''
          ) {
               
               
               WorkOrder objWorkOrder = [SELECT Id, AccountId, City, Country, PostalCode, State, Street, brady_tachy_syndrome__c, chf__c, 
                                         EndDate, mi__c, one_hb__c, referring_physician__c, implanting_physician__c,
                                         following_physician__c, rep_at_implant__c, rep_for_credit__c, 
                                         Pricebook2Id, description, two_hb__c, three_hb_chb__c, afib__c, atrial_tachycadria__c, 
                                         patient__c, scd__c, sick_sinus_syndrome__c, sinus_arrest__c, sinus_bradycardia__c, vf__c, vt__c,
                                         Subject, sap_company_code__c, CurrencyIsoCode, order__c,
                                         Account.crm_pricebook__c, no_rep_present_at_implant__c, medical_record_no__c
                                         FROM WorkOrder WHERE Id = :workOrderId LIMIT 1];
               if(objWorkOrder == null) {
                   throw new WorkOrderConversionException (String.format(Label.cannot_find_workorder, new List<String> {workOrderId}));
               }
               if(objWorkOrder.order__c != null) {
                   throw new WorkOrderConversionException (String.format(Label.workorder_already_converted, new List<String> {workOrderId, objWorkOrder.order__c}));
               }
               
               //SAFBIO-1890 Boolean isDonation = objWorkOrder.donation__c;
               
               // Override information from LineItems
               List<WorkOrderLineItem> wolis = [SELECT Id, OrderId FROM WorkOrderLineItem WHERE WorkOrderId = :workOrderId];
               /*SAFBIO-1890 for(WorkOrderLineItem woli : wolis) {
                   isDonation |= woli.donation__c;
               }*/
                              
               Date implantDate;
               for(ServiceAppointment sApp : [SELECT Id, SchedEndTime, ActualEndTime FROM ServiceAppointment WHERE ParentRecordId = :wolis[0].Id]) {
                   if(sApp.ActualEndTime != null) {
                       implantDate = sApp.ActualEndTime.dateGMT();
                       break;
                   }
                   else {
                       implantDate = sApp.SchedEndTime.dateGMT();
                   }
               }
               if(implantDate == null) {
                   implantDate = Date.today();
               }
               
               orderNew = new Order(RecordTypeId = orderRtId);
               
               System.debug('WorkOrder Id: ' + objWorkOrder.Id + ' Subject: ' + objWorkOrder.Subject + ' AccountId: ' + objWorkOrder.AccountId);
               
               orderNew.AccountId                   = objWorkOrder.AccountId;
               orderNew.BillingCity             = objWorkOrder.City;
               orderNew.BillingCountry              = objWorkOrder.Country;
               orderNew.BillingPostalCode           = objWorkOrder.PostalCode;
               orderNew.BillingState                = objWorkOrder.State;
               orderNew.BillingStreet               = objWorkOrder.Street;
               orderNew.CurrencyIsoCode         = objWorkOrder.CurrencyIsoCode;
              System.debug('AAA woc WorkOrder Currency: ' + objWorkOrder.CurrencyIsoCode);
               
               
               orderNew.chf__c          = objWorkOrder.chf__c;
               //SAFBIO-1890 orderNew.donation__c         = isDonation;
               
               Datetime dtEndDate = objWorkOrder.EndDate;
               if(dtEndDate != null) {
                   orderNew.EndDate         = dtEndDate.dateGmt();
               }
               orderNew.Status              = DEFAULT_ORDER_STATUS;
               orderNew.mi__c               = objWorkOrder.mi__c;
               orderNew.one_hb__c           = objWorkOrder.one_hb__c;
               
               orderNew.referring_physician__c  = objWorkOrder.referring_physician__c;
               orderNew.implanting_physician__c = objWorkOrder.implanting_physician__c;
               orderNew.following_physican__c   = objWorkOrder.following_physician__c;
               orderNew.rep_at_implant__c   = objWorkOrder.rep_at_implant__c;
               orderNew.rep_for_credit__c   = objWorkOrder.rep_for_credit__c;
               orderNew.sap_company_code__c = (sapCompanyCode == null ? objWorkOrder.sap_company_code__c : sapCompanyCode);
               
               orderNew.patient__c          = objWorkOrder.patient__c;
               orderNew.Pricebook2Id        = objWorkOrder.Account.crm_pricebook__c;    
               
               
               orderNew.Description     = objWorkOrder.description;
               
               // PoDate
               // PoNumber
               orderNew.two_hb__c           = objWorkOrder.two_hb__c;
               orderNew.three_hc_chb__c = objWorkOrder.three_hb_chb__c;
               orderNew.afib__c = objWorkOrder.afib__c;
               orderNew.atrial_tachycadria__c   = objWorkOrder.atrial_tachycadria__c;
               orderNew.brady_tachy_syndrome__c = objWorkOrder.brady_tachy_syndrome__c;
               //orderNew.cash_on_delivery__c   = objWorkOrder.cash_on_delivery__c;
               orderNew.chf__c  = objWorkOrder.chf__c;
               //orderNew.comments_ship_to__c   = objWorkOrder.comments_ship_to__;
               //orderNew.company_code__c   = objWorkOrder.company_code__c;
               //orderNew.date_cm_shipped__c    = objWorkOrder.date_cm_shipped__c;
               //orderNew.date_cm_submitted__c  = objWorkOrder.date_cm_submitted__c;
               //orderNew.date_patient_verified__c  = objWorkOrder.date_patient_verified__c;
               //orderNew.date_po_entered__c    = objWorkOrder.date_po_entered__c;
               //orderNew.days_since_procedure__c   = objWorkOrder.days_since_procedure__c;
               orderNew.implant_date__c = implantDate;
               // orderNew.order_status__c  = DEFAULT_ORDER_CUSTOM_STATUS;
               // Formula
               //orderNew.ous_patient__c    = objWorkOrder.ous_patient__c;
               orderNew.scd__c  = objWorkOrder.scd__c;
               orderNew.sick_sinus_syndrome__c  = objWorkOrder.sick_sinus_syndrome__c;
               orderNew.sinus_arrest__c = objWorkOrder.sinus_arrest__c;
               orderNew.sinus_bradycardia__c    = objWorkOrder.sinus_bradycardia__c;
               orderNew.vf__c   = objWorkOrder.vf__c;
               orderNew.vt__c   = objWorkOrder.vt__c;
               orderNew.no_rep_present_at_implant__c = objWorkOrder.no_rep_present_at_implant__c;
               
               orderNew.EffectiveDate = implantDate;
              orderNew.medical_record_no__c = objWorkOrder.medical_record_no__c;
               
               
               insert orderNew;
               
               objWorkOrder.order__c = orderNew.Id;
               update objWorkOrder;
               
               // Additionally, set the Order-Id on the WorkOrderLineItems. This only makes for easier access - just click on the link in the UI
               for(WorkOrderLineItem woli : wolis) {
                   woli.OrderId = orderNew.Id;
               }
               update wolis;
               
               List<ProductConsumed> conProducts = [SELECT 
                                           Product2.Name, status__c, 
                                           av_delay_pace__c, brady_channel__c, 
                                           charge_time__c, cm_active__c,
                                           // comment_oos__c,  // 2018-06-28 FH SAFBIO-1314
                                           sap_account_no__c, dft__c, 
                                           // OOS_Reason__c ? event_reason__c ?
                                           ProductItem.expiration_date_ubd__c, expired_ubd_acknowledged__c, CurrencyIsoCode, Product2Id, QuantityConsumed, 
                                           UnitPrice, PricebookEntryId, 
                                           ProductItem.batch_no__c, 
                                           implant_date__c, 
                                           Product2.ProductCode, 
                                           Id, 
                                                                                     
                                           ProductItem.SerialNumber, ProductItem.barcode__c,  // barcode needs to go in OrderItem.barcode__c - is being added at the moment.
                                           ProductItem.date_of_manufacture__c, // Needs to go in OrderItem.date_of_manufacture__c - is being added at the moment.
                                           ProductItem.stocktype__c, 
                                           udi__c, ProductItem.LocationId, 
                                           Product2.sap_model_no__c, WorkOrder.implanting_physician__c, 
                                           shock_impedance__c, slew_rate__c, Product2.study_product__c, sensitivity_mv_rv__c, 
                                           sensitivity_a__c, sensitivity_v__c, sensitivity_mv_atrium__c, 
                                           sensitivity_mv_lv__c, pulse_width_ms_atrium__c, pulse_width_ms_lv__c, Pulse_width_ms_rv__c, 
                                           r_amp__c, pulse_amplitude_v_lv__c, pulse_amplitude_v_rv__c, pulse_width__c, 
                                           polarity_sensing_rv__c, pulse_amplitude_v__c, polarity_pacing_rv__c, 
                                           polarity_sensing_atrium__c, polarity_sensing_lv__c, pid_ui__c, polarity__c, polarity_pacing_atrium__c,
                                           polarity_pacing_lv__c, mode_switch__c,
                                           // oos_additional_information__c, oos_date__c, // SAFBIO-1355
                                           p_amp__c,
                                           patient__c, lower_rate__c, 
                                           ProductItem.manufacturer__c, 
                                           mode__c, serial_number__c,
                                           // explanting_facility__c, explanting_physician__c, // SAFBIO-1355
                                           impedance__c,
                                           last_movement_date__c, Lead_Tip_Location__c, Tachy_Channel__c, Threshold__c, upper_rate__c,
                                           Product2.manufacturer__c, Product2.product_type__c,
                                           asset__c,
                                           // batch_no__c, // SAFBIO-1355
                                           ProductItem.udi__c, ProductItem.product_type__c,
                                           ProductItem.product_code__c,
                                           replenish__c
                                           FROM ProductConsumed WHERE WorkOrderId = :objWorkOrder.Id];   
               List<Id> prod2Ids = new List<Id>();
               for(ProductConsumed conProd: conProducts) {
                    prod2Ids.add(conProd.Product2Id);
               }
               
               System.debug('orderNew.CurrencyISOCode: ' + orderNew.CurrencyIsoCode);

               Order myOrder = getAnOrderAsILikeIt(orderNew.Id);
               
               Map<Id, PricebookEntry> pbeMap = new Map<Id, PricebookEntry>();
               for (PricebookEntry pbe : [SELECT Id, UnitPrice, Product2Id FROM PricebookEntry WHERE Pricebook2Id = :myOrder.Account.crm_pricebook__c
                                            AND Product2Id IN :prod2Ids AND CurrencyIsoCode = :orderNew.CurrencyIsoCode]) {
                   pbeMap.put(pbe.Product2Id, pbe);
               }


              convertProducts(myOrder, conProducts, pbeMap);
              
               for(ProductConsumed conProd: conProducts) {
                   convertProduct(myOrder, conProd, pbeMap);
               }
               
           }
        else {
            // SAFBIO-2092: More information in case of an error
            throw new WorkOrderConversionException(Label.access_rights_missing
                                                   + '('
                                                   + errOrderCreate
                                                   + errWorkOrderUpdate
                                                   + errWorkOrderLineItemUpdate
                                                   + ')');
            
        }
        return orderNew;
        
    }
    
    public static List<Order> convertToOrder(List<WorkOrder> lstWorkOrder){
        List<Order> lstNewOrder = new List<Order>();
        
        for(WorkOrder wo :lstWorkOrder){
            lstNewOrder.add(convertToOrder(wo.Id));
        }
        
        return lstNewOrder;
    }
    
    public class WorkOrderConversionException extends Exception {}
    
    public class ConvertedProductConsumedHolder {
        public ProductConsumed pc;
        public OrderItem oi;
        public Asset ass;
        public Id relatedAsset;
    }
    
}