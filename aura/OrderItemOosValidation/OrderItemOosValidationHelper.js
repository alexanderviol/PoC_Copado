({
	getMissingComplaints : function (component) {
        var missingComplaints = component.get("c.getMissingComplaintAssets");
        missingComplaints.setParams({
            'idOrder': component.get("v.recordId")    
        });
        missingComplaints.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var res = response.getReturnValue();
                console.log('success --', res);
                component.set("v.missingComplaints", res);   
            }
        });
        $A.enqueueAction(missingComplaints);    
    }
})