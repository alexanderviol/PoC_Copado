({
	myAction : function(component, event, helper) {
		
	},
    
    init : function (cmp, evt, helper){
    
    var shipment_type = [
           { value: 'Direct Hand-out', label: 'Direct Hand-out'},
           { value: 'Direct Ship', label: 'Direct Ship' },
           { value: 'Direct Ship Replacement', label: 'Direct Ship Replacement' }
         ];
         cmp.set("v.options", shipment_type);
        
    var ordertypeD = cmp.get("c.getOrderType");
    var mydefault;
    var handout = false;
        ordertypeD.setParams({ 
            sObjectName : cmp.get ("v.sobjecttype")
        });
        console.log ('myrecordSobject '+cmp.get ("v.sobjecttype"));
        
        ordertypeD.setCallback(this, function(response) {
        	var state = response.getState();
            
            if (state === "SUCCESS"){
               mydefault = response.getReturnValue();
               cmp.set("v.comboselectedValue", mydefault );
                if (mydefault == "Direct Hand-out"){
                	handout= true;    
                }
               cmp.set("v.HandOut", handout);
               //helper.myAvailableProducts (cmp, evt);
                helper.myproductsCMDS (cmp, evt);
            }
        });
        
    /*var address_all = [
            {'label': 'Mailing Address' , 'value': 'Mailing Address'},
            {'label': 'Shipping Address', 'value': 'Shipping Address'},
            {'label': 'Other Address'   , 'value': 'Other Address'}                                                        
            ];*/
        helper.havePatientAddress(cmp, evt);
       // cmp.set("v.optionsRadio", address_all);
        
    var action_02 = cmp.get("c.isPatientDceased");
    var isDead = false;
        action_02.setParams({ 
            recordId    : cmp.get("v.recordId"),
            sObjectName : cmp.get ("v.sobjecttype")
        });
        action_02.setCallback(this, function(response){
            var state = response.getState();
            if (state === "SUCCESS") {
                if (response.getReturnValue()){
					isDead = true;
                    cmp.set("v.showError", isDead);
                    cmp.set("v.goBack", false);
                    cmp.set("v.errorText", $A.get("$Label.c.LBL_CM_ORDER_PATIENT_DEAD"));
                }               
            } 
    });    
    var action = cmp.get("c.getContact");
        action.setParams({ 
            recordId    : cmp.get("v.recordId"),
            sObjectName : cmp.get ("v.sobjecttype")
        });
        action.setCallback(this, function(response){
            var state = response.getState();
            if (state === "SUCCESS") {
                cmp.set("v.contact", response.getReturnValue());
                if (isDead === false){
                    helper.nodeviceImplant(cmp, evt);
                }
            }
        });
         helper.noImplantFacility(cmp, evt);
         helper.collectSalesRep(cmp, evt);
         
         $A.enqueueAction(action_02);
         $A.enqueueAction(action);
         $A.enqueueAction(ordertypeD);
         
    }, 
    
    handleChange : function(cmp, evt, helper){
    var selected = cmp.get("v.comboselectedValue");
    var handout = false;
        if (selected == 'Direct Hand-out'){
           handout= true;
           helper.resetMyAvailableProduct(cmp, evt);
           cmp.set("v.showAddressInput", false); 
        } else {
           //helper.myAvailableProducts (cmp, evt);
           helper.myproductsCMDS (cmp, evt);
        }
        cmp.set("v.HandOut", handout);
    }, 
    
    searchProduct : function (cmp, evt, helper){
    	helper.myAvailableProducts (cmp, evt);
    },
    selectOneProduct : function (cmp, evt, helper){
		var myselection = cmp.get("v.product_value");
        cmp.set("v.product_value", myselection);
        console.log("mySelectedProduct"+myselection);
    },
    
    navigate : function (cmp, evt, helper){
        var myselectedAddress = cmp.get("v.selectedValue");
        var contacts          = cmp.get("v.contact");
        var orderType         = cmp.get("v.comboselectedValue");
        var selectedProduct   = cmp.get("v.product_value");
        console.log("what did I select "+selectedProduct);
    	var action         = cmp.get("c.get_ourProductItem");
        var actionProd     = cmp.get("c.get_ourProduct");
        var action_address = cmp.get("c.prepareOrder");

        action.setParams({ 
            orderType         : orderType,
            selectedCMProduct : selectedProduct
        });
        actionProd.setParams({ 
            orderType         : orderType,
            selectedCMProduct : selectedProduct
        });
        helper.myAddressMap(cmp, evt);
        var adr = cmp.get("v.addressList");
        action_address.setParams({ 
            selectedAddress    : myselectedAddress,
            patientAdd         : contacts,
            address            : JSON.stringify(adr)
        });
        action.setCallback(this, function(response) {
        	var state = response.getState();
            if (state === "SUCCESS"){
                if (orderType === "Direct Hand-out") {
               		cmp.set("v.ourProductItem", response.getReturnValue());    
                } 
            }  else if (state === "ERROR"){
                console.log('Iam heree'+response.getReturnValue());
                if (response.getReturnValue() == null){
                    
                 	cmp.set("v.showError", true);
                 	cmp.set("v.errorText", $A.get("$Label.c.LBL_NO_PRODUCT_SELECTED"));   
                }else {
                var errors = response.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        console.log("Error message: " + 
                                 errors[0].message);
                         cmp.set("v.showError", true);
                 	     cmp.set("v.errorText","Error message: " + errors[0].message);
                   		 }
                	}
                } 
            }
        });
        $A.enqueueAction(action);
        
		actionProd.setCallback(this, function(response) {
        	var state = response.getState();
            if (state === "SUCCESS"){
                cmp.set("v.ourProduct", response.getReturnValue());
            } 
        });
        $A.enqueueAction(actionProd);
        var showAddressInput = cmp.get("v.showAddressInput");

        action_address.setCallback(this, function(response) {
        	var state = response.getState();

            if (state === "SUCCESS"){
                if (orderType === "Direct Ship" ||orderType === "Direct Ship Replacement" ) {
                    cmp.set("v.tempContact", response.getReturnValue());
                    if (showAddressInput){
                        cmp.set("v.selectedValue", null);
                    }
                    console.log( response.getReturnValue());
                    var result = response.getReturnValue();
                    if(myselectedAddress == undefined  && adr.length == 0 || (Object.getOwnPropertyNames(result).length == 0 && myselectedAddress) ){
                 		cmp.set("v.showError", true);
                 		cmp.set("v.errorText", $A.get("$Label.c.VALIDATE_ADDRESS_ENTRIES"));
                    }
                    var productCMDS = cmp.get("v.product_value");
                    if (productCMDS == null){
                        cmp.set("v.showError", true);
                 	    cmp.set("v.errorText", $A.get("$Label.c.LBL_NO_PRODUCT_SELECTED"));   
                    }
                }
            } 
        });
        $A.enqueueAction(action_address);
        helper.validateSalesRep(cmp);
        var stillCollect = false;
        var showSummary = true;
        cmp.set("v.summary", showSummary);
        cmp.set("v.collect", stillCollect);
    }, 

    handleparamChange : function (cmp, event) {
        var changeValue = event.getParam("value");
        cmp.set("v.selectedValue",changeValue);
    },
    
    updateAddresspatient : function (cmp, event){
    	var changeAddress = event.getParam("value");
        cmp.set("v.selectedAddressToUpdate", changeAddress );
    },
    
    createmyOrder : function (cmp, event, helper){
        console.log('start create order');
        var myselectedAddress = cmp.get("v.selectedValue");
        var contacts          = cmp.get("v.contact");
        var orderType         = cmp.get("v.comboselectedValue");
        var selectedProduct   = cmp.get("v.product_value");
        var sObjectName       = cmp.get ("v.sobjecttype");
        var recordIds         = cmp.get("v.recordId");
        var addressToUpdate   = cmp.get("v.selectedAddressToUpdate");
        var repSelected       = cmp.get("v.repSelected");
        var adr = cmp.get("v.addressList");
        
        var stillCollect = false;
        var showSummary = false;
        var doRecap = false;
        
        var action = cmp.get("c.createOrderReally");
      
        var abc = true;
        cmp.set("v.spinner", abc);
        
         action.setParams({ 
            orderType         : orderType,
            recordId          : recordIds,
            sObjectName       : sObjectName,
            selectedCMProduct : selectedProduct,
            selectedAddress   : myselectedAddress,
            patientAdd        : contacts,
            selectedAddressToUpdate : addressToUpdate,
            addrss            : JSON.stringify(adr),
            selectedRep       : repSelected
        });
        action.setCallback(this, function(response) {
        	var state = response.getState();
            
            if (state === "SUCCESS"){
                abc = false;
                cmp.set("v.spinner", abc);
                console.log('an order has been created');
                doRecap = true;
                cmp.set("v.recap", doRecap);
                
            } 
            else if (state === "ERROR"){
               var errors = response.getError();
               var message = '';
               
                if (errors) {
                    
                    for(var i=0; i < errors.length; i++) {
                        for(var j=0; errors[i].pageErrors && j < errors[i].pageErrors.length; j++) {
                            message += (message.length > 0 ? '\n' : '') + errors[i].pageErrors[j].message;
                        }
                        if(errors[i].fieldErrors) {
                            for(var fieldError in errors[i].fieldErrors) {
                                var thisFieldError = errors[i].fieldErrors[fieldError];
                                for(var j=0; j < thisFieldError.length; j++) {
                                    message += (message.length > 0 ? '\n' : '') + thisFieldError[j].message;
                                }
                            }
                        }
                        if(errors[i].message) {
                            message += (message.length > 0 ? '\n' : '') + errors[i].message;
                        }
                    }
                } else {
                    message += (message.length > 0 ? '\n' : '') + 'Unknown error';
                }
               abc = false;
               cmp.set("v.spinner", abc);
               doRecap = false;
               cmp.set("v.recap", doRecap);
               cmp.set("v.showError", true);
               cmp.set("v.errorText", message);
            }
        });
        $A.enqueueAction(action); 

        cmp.set("v.summary", showSummary);
        cmp.set("v.collect", stillCollect);
    }, 
    createNewAddress : function (cmp, event, helper){
        
    	var showAddressInput = true;
        helper.listAddressUpdate(cmp, event);
        cmp.set("v.showAddressInput", showAddressInput);
        cmp.set("v.selectedValue", null);
        helper.myCountries(cmp, event);
    },
    updateProvinces : function(cmp, event, helper) {
        helper.myStates(cmp, event);
    },
    selectRepCredit : function (cmp, evt, helper){
		var myselection = cmp.get("v.repSelected");
        cmp.set("v.repSelected", myselection);
        console.log("mySelectedRep"+myselection);
    },
    previous : function(component, event, helper) {
        component.set("v.showError", false);
        component.set("v.collect", true);
        component.set("v.summary", false);
	},
    
    close : function(component, event, helper) {
		$A.get('e.force:closeQuickAction').fire();
	}
    
})