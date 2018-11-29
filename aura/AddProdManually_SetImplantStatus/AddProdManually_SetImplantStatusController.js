({
    onSingleSelectChange: function(cmp) {
        var selectCmp = cmp.find("InputSelectSingle");
        cmp.set("v.status", selectCmp.get("v.value"));
        console.log ('Setting status to ' + selectCmp.get("v.value"));
    },
    confirmStatus : function (component, event, helper) {
        // If the available quantity is bigger than 1, we need to ask the user for the 
        // amount that is necessary.
        var status = component.get("v.status");
        var idData = component.get("v.data");
        console.log ("Chose next, implant status: " + status);
        console.log ("status-component: " + status);
        console.log ("idData-component: " + idData);
        var eventData = idData + '_' + status;
        console.log ('Data: ' + eventData);
        var selectionEvent = $A.get("e.c:AddProdManually_Next");
        selectionEvent.setParams({data: eventData, stage: "selectedImplantStatus"});
        selectionEvent.fire();
    },
    doInit : function(component) {
        console.log('Init: SetImplantStatus');
        
    },


})