({
	doInit : function(component, event, helper) {
        console.log("input "+component.get("v.recordId"));
        component.set('v.columns', [
            {label: 'View', type: 'button', initialWidth: 135, typeAttributes: { label: 'View Details', name: 'view_details', title: 'Click to View Details'}},
            {label: 'Asset name', fieldName: 'Name', type: 'text'},
            {label: 'Status', fieldName: 'Status', type: 'text'}
        ]);
        
		helper.getMissingComplaints(component);
        
    },
     handleRowAction : function(component, event, helper) {
    	var action =event.getParam('action');
        var row =event.getParam('row');
            
            console.log('row id --', row.Id);
         switch (action.name) {
            case 'view_details':
                 var urlEvent = $A.get("e.force:navigateToURL");
                urlEvent.setParams({
                  "url": "/" + row.Id
                });
                urlEvent.fire();
                break;
           default:
                break;
        }
     }
})