({
	helperMethod : function() {
		
	},
    noImplantFacility : function (cmp, evt){
      var accounts = cmp.get("c.getImplantinFacility");
      var noImplant = false;
      accounts.setCallback(this, function(response){
            var state = response.getState();
            console.log('state no Implant'+state);
            if (state === "SUCCESS") {            
            } else if (state === "ERROR"){
             noImplant = true;
             cmp.set("v.showError", noImplant);
                
             cmp.set("v.goBack", false);
             cmp.set("v.errorText", $A.get("$Label.c.ERR_CREATE_CM_ORDER_ACCOUNT_MISSING"));
           }  
      });
     $A.enqueueAction(accounts);
    },
    nodeviceImplant : function (cmp, evt){
      var assets = cmp.get("c.getLastDeviceFromPatient");
      var noAssets = false;
      var contacts = cmp.get("v.contact");
      assets.setParams({ 
            con : contacts
      });
      assets.setCallback(this, function(response){
            var state = response.getState();
            console.log('state nodevice'+state);
            if (state === "SUCCESS") {
                console.log('assets');            
            } else if (state === "ERROR"){
                
             noAssets = true;
             cmp.set("v.showError", noAssets);
             cmp.set("v.goBack", false);
             cmp.set("v.errorText", $A.get("$Label.c.ERR_CREATE_CM_ORDER_EXCEPTION_MESSAGE"));
           }  
      });
     $A.enqueueAction(assets);
    },
    myAvailableProducts : function (cmp, evt){
    var products_n = [];
    var product_list;
    var noServiceRessource = false;
    var odrType   = cmp.get("v.comboselectedValue");
    var serialNum = cmp.get("v.serial_number");
    var inventory = cmp.get("v.inventory_name");
    var action    = cmp.get("c.getAvailableProduct");
    
        action.setParams({ 
            orderType : odrType,
            serialNumber    : serialNum,
            inventoryName   : inventory
        });
        action.setCallback(this, function(response) {
        	var state = response.getState();
            var defaultvalue;
            if (state === "SUCCESS"){
                product_list = response.getReturnValue();
                for ( var i in product_list) {
                defaultvalue = product_list[0].Id;
                    var item;
                   	 if (odrType === "Direct Hand-out"){
                       item = {
              		 		   "label": product_list[i].Product2.Name +' (' + product_list[i].SerialNumber + ')',
               		 		   "value": product_list[i].Id
           				    }; 
                     }
            		products_n.push(item);  
        		}
                cmp.set("v.product_value", defaultvalue);
                cmp.set("v.products", products_n);
            } else if (state === "ERROR"){
                if(response.getReturnValue() == $A.get("$Label.c.ccmo_No_Service_Resource_for_current_User")){
                    noServiceRessource = true;
                	cmp.set("v.showError", noServiceRessource);
                    cmp.set("v.goBack", false);
                	cmp.set("v.errorText", $A.get("$Label.c.ccmo_No_Service_Resource_for_current_User"));
                } 
            }
        });
        $A.enqueueAction(action);
    },
    myproductsCMDS : function (cmp, evt){
        var products_n = [];
    	var product_list;
   	 	
    	var odrType   = cmp.get("v.comboselectedValue");
    	var action = cmp.get("c.getavailableProd");
        action.setParams({ 
            orderType : odrType
        });
        action.setCallback(this, function(response){
            var state = response.getState();
            var defaultvalue;
            if (state === "SUCCESS") {
            product_list = response.getReturnValue();
                for ( var i in product_list) {
                defaultvalue = product_list[0].Id;
                    var item;
                   	 if (odrType ==="Direct Ship" || odrType ==="Direct Ship Replacement"){
                       item = {
                               "label"  : product_list[i].Name,
                               "value"  : product_list[i].Id
           				    };
            		 products_n.push(item);  
        		}
                cmp.set("v.product_value", defaultvalue);
                cmp.set("v.products", products_n);
            }
            }
      });
        $A.enqueueAction(action);  
    },
    resetMyAvailableProduct : function (cmp, evt){
    	var products_n = [];
        cmp.set("v.products", products_n);
    },
    
    myCountries : function (cmp, evt) {
    	var countryOptions = cmp.get("c.getPicklistValues");
        var countryOp =[];
        
        countryOptions.setCallback(this, function(response){
        var state = response.getState();
        if(state === "SUCCESS") {
            var result = response.getReturnValue();
            
            for (var i in result){
             	var item = {
              		 		 "label": result[i].strLabel,
               		 		 "value": result[i].strValue
           				   }; 
                countryOp.push(item);
            }
            console.log('=====countryOp====');
            cmp.set("v.countryOps", countryOp);
        }
    })
    $A.enqueueAction(countryOptions);
    },
    myStates : function (cmp, evt) {
    	var stateOptions = cmp.get("c.getRegonPiklistValues");
        var states = [];
        
        var selectedCountry = cmp.get("v.country");
        stateOptions.setParams({ 
            country : selectedCountry
        });
        stateOptions.setCallback(this, function(response){
        var state = response.getState();
        if(state === "SUCCESS") {
            var result = response.getReturnValue();
            for (var i in result){
             	var item = {
               		 		 "label": result[i].strLabel,
               		 		 "value": result[i].strValue
           				   }; 
                states.push(item);
            }
            console.log('=====states====');
            cmp.set("v.statesOp", states);
        }
    })
    $A.enqueueAction(stateOptions);
    },
 
    listAddressUpdate: function(cmp, event){
     var address_update = [
            {'label': '--None--' , 'value': 'none'},
            {'label': 'Shipping Address', 'value': 'Shipping_Address'},
            {'label': 'Mailing Address' , 'value': 'Mailing_Address'},
            {'label': 'Other Address'   , 'value': 'Other_Address'}                                                        
            ];
        cmp.set("v.addessToUpdate", address_update);       
    },
    myAddressMap : function (cmp, evt){
        var showAddressInput = cmp.get("v.showAddressInput");
        console.log('showAddressInput is '+showAddressInput);
        if (showAddressInput){
        	var inputAddress   = cmp.find("myaddress");
        
            var newMailingStreet  = inputAddress.get("v.street");
            var newMailingcity    = inputAddress.get("v.city");
            var newMailingcode    = inputAddress.get("v.postalCode");
            var newMailingState   = inputAddress.get("v.province"); 
            var newMailingCountry = inputAddress.get("v.country");
            
            var newAddress = [
                { street :  newMailingStreet, city : newMailingcity, PostalCode : newMailingcode, statecode : newMailingState, Country : newMailingCountry}
            ];
            cmp.set("v.addressList", newAddress);    
        }
    },
    havePatientAddress : function (cmp, evt){
    var addresses = cmp.get("c.getPatientAddress");
    var list_address = [];
    var statee = ' ';
    addresses.setParams({ 
            recordId    : cmp.get("v.recordId"),
            sObjectName : cmp.get ("v.sobjecttype")
        });
        addresses.setCallback(this, function(response){
        	var state = response.getState();
            if(state === "SUCCESS") {
                var result = response.getReturnValue();
                console.log(result);
                for (var i in result){
                  statee = result[i]["StateProvince"];
                    var address_label = result[i]["lbl_address"];

             	var item = {
                    'label': result[i]["Name"]+' : '+address_label,
                    'value': result[i]["Name"]
                           };
                list_address.push(item);
            }
            console.log('=====add===='+list_address);
            cmp.set("v.optionsRadio", list_address);
            }  
        })
        $A.enqueueAction(addresses);
	}, 
    availableRep : function (cmp, evt){
        console.log("my Rep");
        var salesRep = [];
        var salesRep_list;
        var action = cmp.get("c.getAvailableRepForCredit");
        action.setCallback(this, function(response){
            var state = response.getState();
            var defaultvalue;
            if (state === "SUCCESS") {
                salesRep_list = response.getReturnValue();
                for ( var i in salesRep_list) {
                    defaultvalue = salesRep_list[0].Id;
                    var item;
                    item = {
                        "label"  : salesRep_list[i].Name,
                        "value"  : salesRep_list[i].Id
                    };
                    salesRep.push(item);  
                    cmp.set("v.repSelected", defaultvalue);
                    cmp.set("v.rep_for_credit", salesRep);
                }
            }
        });
        $A.enqueueAction(action);  
    },
    collectSalesRep : function (cmp, evt){
        console.log("need a rep start")
       var action = cmp.get("c.repSelectionNeeded");
       action.setParams({ 
            recordId    : cmp.get("v.recordId"),
            sObjectName : cmp.get ("v.sobjecttype")
        });
        action.setCallback(this, function(response){
            var state = response.getState();
            console.log("what is the status "+state);
            console.log("response is "+response.getReturnValue());
            if (state === "SUCCESS") {
                console.log("here is SUCCESS")
                if (response.getReturnValue()){
                   var collecting = true;
                   this.availableRep(cmp, evt);
                   cmp.set("v.showCollectRep", collecting);
                   console.log("collecting is "+collecting)
                }
                
            } 
        });
       $A.enqueueAction(action);
    }, 
    validateSalesRep : function (cmp){
        var neededSales = cmp.get("v.showCollectRep");
        var selectedRep = cmp.get("v.repSelected");
        console.log('mysale '+selectedRep);
        if (neededSales == true && selectedRep == null){
            cmp.set("v.showError", true);
            cmp.set("v.errorText", $A.get("$Label.c.LBL_NO_REP_SELECTED"));
        }
        
    }
})