({
	closePopup : function(component, event, helper) {
		$A.get('e.force:closeQuickAction').fire();	
	},

    onLoadFun :  function(component, event, helper) {
        component.set("v.showDetail", false);
    },
    redirect : function(component, event, helper) {
       	component.set("v.showDetail", true);

    	var recId = component.get("v.recordId");
        var last = '';
        var tComp = component.find("mdrf");
        var mdrf = (typeof tComp == 'undefined')? null : tComp.get("v.value");
        tComp = component.find("sv");
        var sv = (typeof tComp == 'undefined')? null : tComp.get("v.value");
        tComp = component.find("pr");
        var pr = (typeof tComp == 'undefined')? null : tComp.get("v.value");
        tComp = component.find("dr");
        var dr = (typeof tComp == 'undefined')? null : tComp.get("v.value");
        tComp = component.find("pds");
        var pds = (typeof tComp == 'undefined')? null : tComp.get("v.value");
        tComp = component.find("oos");
        var oos = (typeof tComp == 'undefined')? null : tComp.get("v.value");
        tComp = component.find("tpid");
        var tpid = (typeof tComp == 'undefined')? null : tComp.get("v.value");
        tComp = component.find("dc");
        var dc = (typeof tComp == 'undefined')? null : tComp.get("v.value");
        
       /* Selecting the last document which is selected by the user, sequence is determied by the pges added on printpdf document.
        This parameter will be passed to the URL to avoid generation of addition blank pdf. */
        if(oos == true)
            last = 'oos';
        if(sv == true)
            last = 'sv';
        if(mdrf == true)
            last = 'mdrf';
        if(tpid == true)
            last = 'tpid';
        if(dr == true)
            last = 'dr';
        if(pr == true)
            last = 'pr';
        if(pds == true)
            last = 'pds';
        if(dc == true)
            last = 'dc';

        var urlString = '/apex/PrintPdfDocuments?id=' + recId + '&mdrf='+ mdrf + '&sv=' + sv + '&pr=' + pr + '&dr=' + dr + '&pds=' + pds + '&oos=' + oos + '&tpid=' + tpid + '&dc=' + dc + '&last=' + last;
        var action = component.get('c.insertFile');
        action.setParams({
            'url': urlString
        });

        action.setCallback(this, function(response) {
        var state = response.getState();
            if (state === "SUCCESS") {
                $A.get('e.force:closeQuickAction').fire();
            	$A.get('e.lightning:openFiles').fire({
        			recordIds: [response.getReturnValue()]
    			});
            } else if (state === "ERROR") {
                component.set("v.showDetail", false);
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