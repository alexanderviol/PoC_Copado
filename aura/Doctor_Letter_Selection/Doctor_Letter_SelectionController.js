({
	closePopup : function(component, event, helper) {
		$A.get('e.force:closeQuickAction').fire();	
	},
    redirect : function(component, event, helper) {

        var action = component.get("c.getErrorMsg");
    	var recId = component.get("v.recordId");
        var docL = component.find("docL").get("v.value");
        var docLw = component.find("docLw").get("v.value");
        
        var msgLabel = $A.get("$Label.c.DOCTOR_LETTER_CREATED");
		component.set("v.msgLabel", msgLabel);
        
        var toastTitle = $A.get("$Label.c.DOCTOR_LETTER_CREATION_PROCCES");
		component.set("v.titleLabel", toastTitle);
        var toastMsg;
        
        action.setParams({ 
            complaintId : component.get("v.recordId")});
        action.setCallback (this, function(response){
            var state = response.getState();
            
            if (state === "SUCCESS"){
                component.set("v.recordId", response.getReturnValue());
                toastMsg = response.getReturnValue();
                
                if (response.getReturnValue() === msgLabel){
					urlEvent();
                }               
            }  
            $A.get('e.force:closeQuickAction').fire();
            var resultsToast = $A.get("e.force:showToast");
            resultsToast.setParams({
                "title": toastTitle ,
                "message": toastMsg
            });
        	resultsToast.fire();
        });
         $A.enqueueAction(action);
        function urlEvent() {
        	location.href = '/apex/PrintDocDoctorLetters?id=' + recId + '&docL='+ docL + '&docLw=' + docLw;
        }  
	}
})