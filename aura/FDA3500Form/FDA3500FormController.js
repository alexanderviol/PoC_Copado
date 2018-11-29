({
	closePopup : function(component, event, helper) {
		$A.get('e.force:closeQuickAction').fire();	
	},
    open : function(component, event, helper) {       
    	var recId = component.get("v.recordId");              
        location.href = '/apex/FDA3500Form?id=' + recId ;       
	},
    saveDoc : function(component, event, helper) {
    	
        var action = component.get("c.attachAsPdf");
    	var recId = component.get("v.recordId");
        
        action.setParams({ 
            parentId : component.get("v.recordId")});
        action.setCallback (this, function(response){
            var state = response.getState();
            if (state === "SUCCESS") {
                var eUrl= $A.get("e.force:navigateToURL");
                eUrl.setParams({
                  "url": ' /apex/FDA3500Form?id=' + recId 
                });
                eUrl.fire();
            }             
        });
         $A.enqueueAction(action);            
	}
})