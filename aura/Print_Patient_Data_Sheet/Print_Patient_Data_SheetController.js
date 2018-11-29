({
	generatePatientDataSheet : function(component, event, helper) {
		component.set("v.showDetail", true);
        var recId = component.get("v.recordId");
        var urlString = '/apex/PatientDataSheet_Patient?id=' + recId ;
        var action = component.get('c.insertFile');
        action.setParams({
            'url': urlString
        });
       
        action.setCallback(this, function(response) {
        var state = response.getState();
            if (state === "SUCCESS") {
                $A.get('e.force:closeQuickAction').fire();
            	$A.get('e.lightning:openFiles').fire({
        			recordIds: [response.getReturnValue()]
    			});
            } else if (state === "ERROR") {
                component.set("v.showDetail", false);
            	var errors = response.getError();
                var dynDiv = document.createElement("div");
                if (errors[0] && errors[0].message) {
                    dynDiv.innerHTML = response.getError()[0].message;
                } else {
                    dynDiv.innerHTML = "Request Failed!";
                }          
                dynDiv.innerHTML = response.getError()[0].message;
                alert(dynDiv.innerHTML); 
                }
        });
      	$A.enqueueAction(action);
	}
})