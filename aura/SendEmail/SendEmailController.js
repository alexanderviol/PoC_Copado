({
	sendEmail : function(component, event, helper) {
        var recId = component.get("v.recordId");
         //calling apex class method
        var action = component.get('c.getRecords');
        action.setParams({
            'recId': recId
        });
        action.setCallback(this, function(response) {
        var state = response.getState();
        if (state === "SUCCESS") {
            //Parsing JSON response
            var stringifyJSON = JSON.stringify(response.getReturnValue());
            var parsedJSON = JSON.parse(stringifyJSON);
            var conEmail = (parsedJSON.c.Email) ? parsedJSON.c.Email : '';
            window.location.href = 'mailto:'+conEmail+'?bcc='+parsedJSON.u.Email;
            //Closing the popup
        	$A.get('e.force:closeQuickAction').fire();
        } else if (state === "ERROR") {
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