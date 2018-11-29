({
	openModel: function(component, event, helper) {
       window.location ='/one/one.app#/sObject/complaint__c/list?filterName=Recent';
   },
 
   closeModel: function(component, event, helper) {
       window.location ='/one/one.app#/sObject/complaint__c/list?filterName=Recent';
   },
 
    redirect : function(component, event, helper) {
        var usr = component.find("a").get("v.value");
        var pdw = component.find("b").get("v.value");
        if (usr == null || pdw == null ){
            alert('Please complete required values');
        }else{
        var action = component.get("c.auth");
        action.setParams({ 
            usernam : component.find("a").get("v.value") ,
            passwrd : component.find("b").get("v.value")  });

        // Create a callback that is executed after 
        // the server-side action returns
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
				var result = response.getReturnValue();
                if (result == 'Authentication succeeded!'){
                    alert('Authentication succeeded!');
                    //*********Submission to CAN shoud be called from here in case a auth to can session is required****/
                    //for the moment the home page is reloded
                    window.location ='/one/one.app#/sObject/complaint__c/list?filterName=Recent';
                }
                else if (result == 'Please try again.'){
                   alert('Login faild! Please try again.');
                   
                 }
                else{ alert('Exception occured! Could not perform required operation.');
                      window.location ='/one/one.app#/sObject/complaint__c/list?filterName=Recent';
                     }
                
            }
            else if (state === "INCOMPLETE") {
                alert('Exception occured! Could not perform required operation.');
                window.location ='/one/one.app#/sObject/complaint__c/list?filterName=Recent';
            }
            else if (state === "ERROR") {
                var errors = response.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        console.log("Error message: " + 
                                 errors[0].message);
                    }
                } else {
                    console.log("Unknown error");
                }
            }
        });

        
        $A.enqueueAction(action);
    
    }
        }
})