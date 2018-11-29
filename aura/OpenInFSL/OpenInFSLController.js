({
    openWorkOrder : function(component, event, helper) {
        var sObjectEvent = $A.get("e.force:navigateToSObject");
        var woId = component.get("v.Id");
        if(sObjectEvent != null && typeof sObjectEvent != 'undefined') {
            sObjectEvent.setParams({
                "recordId": woId,
                "slideDevName": 'detail'
            });
            console.log('Firing viewRecord, recordId : ' + woId);
            sObjectEvent.fire();
        }
        else { 
            console.log('NOT firing viewRecord, recordId : ' + woId);
        }
        
    }
})