({
    handleKey : function(component, event, helper) {
        var searchText = component.get('v.searchText');
        var action = component.get('c.searchForProductItems');
        console.log('SearchText: ' +  searchText);
        if(searchText.length > 0) {
            document.getElementById("spinner").style.display = "block";
            document.getElementById("prodtable").style.display = "none";

            action.setParams({searchText : searchText,
                              orderID : component.get("v.orderId")});
            action.setCallback(this, function(response) {
                var state = response.getState();
                if (state === 'SUCCESS') {
                    var prods = response.getReturnValue();
                    component.set("v.products", prods);
                    console.log(prods);
                    console.log("Order Id (v.orderId): " + component.get("v.orderId"));
                    console.log('0!');
                }
                document.getElementById("spinner").style.display = "none";
                document.getElementById("prodtable").style.display = "table";
            });
            
            $A.enqueueAction(action);
        }
    },
    doInit : function(component) {
        console.log('Init: SearchProductItem');
        
    },
    selectProduct : function (component, event, helper) {
        // If the available quantity is bigger than 1, we need to ask the user for the 
        // amount that is necessary.
        var idData = event.target.id;
        var selectionEvent = $A.get("e.c:AddProdManually_Next");
        selectionEvent.setParams({data: idData, stage: "selectedProduct"});
        selectionEvent.fire();
    }
    
})