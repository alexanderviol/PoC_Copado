({
    confirmQuantity : function (component, event, helper) {
        // If the available quantity is bigger than 1, we need to ask the user for the 
        // amount that is necessary.
        var amount = component.get("v.quantity");
        console.log ("Chose next, quantity: " + amount);
        var selectionEvent = $A.get("e.c:AddProdManually_Next");
        selectionEvent.setParams({data: amount, stage: "selectedQuantity"});
        selectionEvent.fire();
    },
    handleKey : function(component, event, helper) {
        var amount = component.get("v.quantity");
        console.log ("Change, quantity: " + amount);
    },
    doInit : function (component) {
        console.log('AddProdManually_CollectOIInformation - Init');
    }


})