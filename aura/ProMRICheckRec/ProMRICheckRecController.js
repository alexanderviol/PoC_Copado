({
	myAction : function(component, event, helper) {
        //Added by Sumit || SAFBIO-1610
		component.set("v.showDetail", true);
        var action = component.get("c.checkProMRIFromRecord");
        var recId = component.get("v.recordId");
        var msgReturned;
        var messageType='';
        action.setParams({ 
            rec : component.get("v.recordId")});
        action.setCallback (this, function(response){
            var state = response.getState();
            if (state === "SUCCESS") {
                component.set("v.recordId", response.getReturnValue());
                msgReturned = response.getReturnValue(); 
            } else if (state === "ERROR") {
                component.set("v.showDetail", false);
            }
            messageType = msgReturned.includes("Success") ? "success" : "error";
            //Added by Sumit || SAFBIO-1610
            $A.get('e.force:closeQuickAction').fire();
            $A.get('e.force:refreshView').fire();
            var resultsToast = $A.get("e.force:showToast");
            resultsToast.setParams({
                "title": "Result of ProMRI Check",
        		"type": messageType,
        		"message": msgReturned
            });
        	resultsToast.fire();
        });
        $A.enqueueAction(action);     
	}
})