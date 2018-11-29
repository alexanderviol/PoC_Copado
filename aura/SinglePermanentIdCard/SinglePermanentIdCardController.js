({
	generateIDCard : function(component, event, helper) {
		var recId = component.get("v.recordId");
        setTimeout(function() {
            $A.get('e.force:closeQuickAction').fire();	
        }, 1000);
        var openedWindow = window.open('/apex/SinglePermanentIdCard?id='+recId);
	}
})