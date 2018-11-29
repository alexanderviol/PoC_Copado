({
	updateWorkOrderRecord : function(component, event, helper) {
        var workOrderObj = component.get("v.objworkorder");
         workOrderObj.rep_at_implant__c = null ; 
         workOrderObj.rep_for_credit__c = null ; 

        if(component.get("v.selectedLookUpRecord1").Id != undefined){
          workOrderObj.rep_for_credit__c = component.get("v.selectedLookUpRecord1").Id;
        }
        
        if(component.get("v.selectedLookUpRecord2").Id != undefined){
          workOrderObj.rep_at_implant__c = component.get("v.selectedLookUpRecord2").Id;
        }
        var recId = component.get("v.recordId");
        
        //call apex class method
       var action = component.get('c.updateWorkOrderredords');
        action.setParams({
            'wo': workOrderObj,
            'woRecId': recId
        });
      action.setCallback(this, function(response) {
        //store state of response
        var state = response.getState();
        if (state === "SUCCESS") {
         alert('Representatives were added to MDRF successfully');
         $A.get('e.force:refreshView').fire();
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