({
    closePopup : function(component, event, helper) {
		$A.get('e.force:closeQuickAction').fire();	
	},
    
	populateLookupValues : function(component, event, helper) {
		var recId = component.get("v.recordId");
        //calling apex class method
        var action = component.get('c.getlookupFieldValues');
        action.setParams({
            'recId': recId
        });	
        action.setCallback(this, function(response) {
        var state = response.getState();
        if (state === "SUCCESS") {
            //Parsing JSON response
            var selOptions = [];
            var options = new Object();
            var stringifyJSON = JSON.stringify(response.getReturnValue());
            var parsedJSON = JSON.parse(stringifyJSON);
            //Iterating on parsed JSON object
            for(var i in parsedJSON) {
                var options = new Object();
				options.value = parsedJSON[i].Id;
                options.label = parsedJSON[i].label + ' : ' + parsedJSON[i].val;
                selOptions[i] = options;
            }
            component.set("v.statusOptions", selOptions);
        } else if (state === "ERROR") {
            helper.throwExceptionMeaage(response);              
        }
      });
      $A.enqueueAction(action);  
	},
    
    handleOnChange : function(component, event, helper) {
        var selVal = component.find('selectItem').get('v.value');
        var action = component.get('c.getRecords');
        if(selVal == 'new') {
            alert('Send email to : Please choose a value');
        } else {
            action.setParams({
                'recId': selVal
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
                helper.throwExceptionMeaage(response);         
            }
          });
          $A.enqueueAction(action);  
        }   
	}
})