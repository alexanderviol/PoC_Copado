({
	 doInit: function(component, event, helper) {
		var action = component.get("c.assignCiNumber");
		action.setParams({
            "recordId": component.get("v.recordId")
        });
		action.setCallback(this, function(response) {
			var state = response.getState();
			if (state === "SUCCESS") {
				response.getReturnValue();
                $A.get("e.force:closeQuickAction").fire();
                $A.get('e.force:refreshView').fire();
			} else {
                var errors = response.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        alert("Error message: " +
                                 errors[0].message);
                    }
                }
                $A.get("e.force:closeQuickAction").fire();
				console.log("Failed with state: " + state);
			}
		});
		$A.enqueueAction(action);
	},
})