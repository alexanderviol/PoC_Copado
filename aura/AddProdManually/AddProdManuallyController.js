({
    doInit : function (component) {
        
        var hasPermission = component.get ("c.checkUserPermission");
        var showError = false;
        
        hasPermission.setCallback(this, function(response) {
            var state = response.getState();
            
            if (state === 'SUCCESS'){
                if (response.getReturnValue()){ 
                    console.log('you are  allowed');
                    showError = false;
                    console.log('----- Init -----');
                    console.log('OrderId : ' + component.get("v.recordId"));
                    var myOrderId = component.get("v.recordId");
                    $A.createComponent(
                        "c:AddProdManually_SearchProductItem",
                        {label : "Product search",
                         orderId : myOrderId},
                        function(newComponent) {
                            component.set("v.body", newComponent);
                        }
                    );
                } else {
                    console.log('you are not allowed');
                    showError = true;
                }
            }
            component.set("v.showError", showError);   
        });
        $A.enqueueAction(hasPermission);
        
//                    $A.createComponent("c:AddProdManually_CollectOIInformation", 
//                                       {
//                                           Id : '12345',
//                                           maxAmount : 5
//                                           
//                                       },
//                                       function(newComponent) {
//                                           component.set("v.body", newComponent);
//                                       });
        
    },
    
    handleNextEvent : function (component, event, helper) {
        console.log('handleNextEvent, Stage: ' + event.getParam("stage"));
        var idData = event.getParam("data");
        var data = idData.split('_');
        var idx = data[0];
        var amount = data[1];
        var isUBD = data[2];
        var implantable = data[3];
        var implantStatus = '';
        if(data.length == 5) {
            implantStatus = data[4];
        }
        var ubdIsAcknowledged = 'false';
        if(data.length == 6) {
        	ubdIsAcknowledged = data[5];
        }
        
        console.log('isUBD: ' + isUBD + ' ubdIsAcknowledged: ' + ubdIsAcknowledged);
        
        if(isUBD == 'true' && ubdIsAcknowledged != 'true' ) {
            component.set("v.preubddata", idData);
            document.getElementById("ubdmodal").style.display = "block";
        }
        else {
            document.getElementById("ubdmodal").style.display = "none";
            switch(event.getParam("stage")) {
                case "selectedProduct" :
                case "selectedImplantStatus" :
                    component.set("v.productItem", idx);
                    console.log('selected ' + idx);
                    console.log('Marker 1');

                    if(implantable == 'implantable' && implantStatus == '') {
                        console.log('Is implantable (' + data[3] + ')');
                        $A.createComponent("c:AddProdManually_SetImplantStatus", 
                                           { label : "Set Implant Status",
                                             data: idData,  
                                           },
                                           function(newComponent) {
                                               component.set("v.body", newComponent);
                                           });
                        break;
                        
                    }
                    if (implantable != 'implantable') {
                        implantStatus = 'Not Implantable';
                    }
                    
                    component.set("v.selectedAmount", 1);
                    var action = component.get('c.consumeProduct');
                    
                    
                    var waitEvent = $A.get("e.force:showToast");
                    waitEvent.setParams({
                        title: "Wait, please",
                        message: "We're getting things ready for you...",
                        type: "information"
                    });
                    waitEvent.fire();
                    
                    console.log ('Implant status: ' + implantStatus);
                    
                    action.setParams({piId : idx,
                                      amount : '1',
                                      orderId : component.get("v.recordId"),
                                      implantStatus : implantStatus
                                     });
                    
                    var sObjectEvent = $A.get("e.force:editRecord");
                    var closeEvent = $A.get("e.force:closeQuickAction");
                    var toastEvent = $A.get("e.force:showToast");
                    
                    
                    action.setCallback(this, function(response) {
                        var state = response.getState();
                        console.log('Response-state: ' + state);
                        
                        if (state === 'SUCCESS') {
                            closeEvent.fire();
                            var asset = response.getReturnValue();
                            // component.set("v.products", prods);
                            console.log(asset);
                            console.log("Order Id: " + component.get("v.recordId"));
                            console.log('1!');
                            /*                            var sObjectEvent = $A.get("e.force:navigateToSObject");
                            sObjectEvent.setParams({
                                "recordId": asset.Id,
                                "slideDevName": 'related'
                            })
                            */
                                if(sObjectEvent != null && typeof sObjectEvent != 'undefined') {
                                    sObjectEvent.setParams({
                                        "recordId": asset.Id,
                                        "slideDevName": 'related'
                                    });
                                    console.log('Firing editRecord, recordId : ' + asset.Id);
                                    sObjectEvent.fire();
                                }
                                else { 
                                    console.log('NOT firing editRecord, recordId : ' + asset.Id);
                                    toastEvent.setParams({
                                        title: "Error!",
                                        message: "Cannot open Asset-Editor. sObjectEvent missing.",
                                        type: "error"
                                    });
                                    toastEvent.fire();
                                }
                                
                            }
                            else {
                                toastEvent.setParams({
                                    title: "Error!",
                                    message: response.getReturnValue(),
                                    type: "error"
                                });
                                toastEvent.fire();
                                
                            }
                        });
                    $A.enqueueAction(action);
                    // }
                    break;
                case "selectedQuantity" : 
                    console.log('selectedQuantity....');
                    var waitEvent = $A.get("e.force:showToast");
                    waitEvent.setParams({
                        title: "Wait, please",
                        message: "We're getting things ready for you...",
                        type: "information"
                    });
                    waitEvent.fire();
                    
                    var sObjectEvent = $A.get("e.force:editRecord");
                    var closeEvent = $A.get("e.force:closeQuickAction");
                    var toastEvent = $A.get("e.force:showToast");
                    
                    
                    component.set("v.selectedAmount", event.getParam("data"));
                    var action = component.get('c.consumeProduct');
                    action.setParams({piId : component.get("v.productItem"),
                                      amount : component.get("v.selectedAmount"),
                                      orderId : component.get("v.recordId")
                                     });
                    console.log('Setting callback');
                    action.setCallback(this, function(response) {
                        var state = response.getState();
                        console.log('Response-state: ' + state);
                        if (state === 'SUCCESS') {
                            var asset = response.getReturnValue();
                            // component.set("v.asset", asset);
                            console.log(asset);
                            console.log("Order Id: " + component.get("v.recordId"));
                            console.log('2!');
                            
                            if(sObjectEvent != null && typeof sObjectEvent != 'undefined') {
                                sObjectEvent.setParams({
                                    "recordId": asset.Id,
                                    "slideDevName": 'related'
                                });
                                console.log('Firing editRecord, recordId : ' + asset.Id);
                                sObjectEvent.fire();
                            }
                            else { 
                                console.log('NOT firing editRecord, recordId : ' + asset.Id);
                                toastEvent.setParams({
                                    title: "Error!",
                                    message: "Cannot open Asset-Editor. sObjectEvent missing.",
                                    type: "error"
                                });
                                toastEvent.fire();
                            }
                            
                        }
                        else {
                            toastEvent.setParams({
                                title: "Error!",
                                message: response.getReturnValue(),
                                type: "error"
                            });
                            toastEvent.fire();
                        }
                    });
                    console.log('enqueuing action...');
                    $A.enqueueAction(action);
                    $A.get("e.force:closeQuickAction").fire();
                    break;
            }
        }
        $A.get('e.force:refreshView').fire();
    },
    acknowlegdeUBD : function (component, event, helper) {
        console.log("acknowlegdeUBD");
        var idData = component.get("v.preubddata") + '_true';
        var selectionEvent = $A.get("e.c:AddProdManually_Next");
        selectionEvent.setParams({data: idData, stage: "selectedProduct"});
        selectionEvent.fire();
    },
    cancelUBD : function (component, event, helper) {
        console.log("cancelUBD");
        $A.get("e.force:closeQuickAction").fire()
    }
    
})