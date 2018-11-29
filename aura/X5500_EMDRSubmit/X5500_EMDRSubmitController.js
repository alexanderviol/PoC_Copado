({
	doInit : function(cmp, evt, hlp) {
		var action = cmp.get("c.submitFromButton");
		action.setCallback(this,
			function(response) {
				var state = response.getState();
				if (state == "SUCCESS") {
					var ret = response.getReturnValue();
					if (ret == 'success') {
						alert('Success. Operation executed and was successful. Check back later for FDA response.');
						$A.get('e.force:refreshView').fire();
					} else {
						alert('Fail. Operation executed but was not successful because: ' + ret);
					}
				} else if (state === "INCOMPLETE") {
					alert('Fail. The operation did not complete due to an unknown problem.');
				} else if (state === "ERROR") {
					var errors = response.getError();
					if (errors) {
						if (errors[0] && errors[0].message) {
							console.log("Error message: " + errors[0].message);
							alert('Errors indicated in response: ' +  errors[0].message);
						}
					} else {
						console.log("Unknown error");
					}
				}
				$A.get("e.force:closeQuickAction").fire();
			}
		);
		$A.enqueueAction(action);
	},
	submitSingle : function(cmp, evt, hlp) {
		var action = cmp.get("c.submitSingleFromButton");

        action.setParams({"complaintId": cmp.get("v.recordId")});

		action.setCallback(this,
			function(response) {
				var state = response.getState();
				if (state == "SUCCESS") {
					var ret = response.getReturnValue();
					if (ret == 'success') {
						alert('Success. Operation executed and was successful. Check back later for FDA response.');
						$A.get('e.force:refreshView').fire();
					} else {
						alert('Fail. Operation executed but was not successful because: ' + ret);
					}
				} else if (state === "INCOMPLETE") {
					alert('Fail. The operation did not complete due to an unknown problem.');
				} else if (state === "ERROR") {
					var errors = response.getError();
					if (errors) {
						if (errors[0] && errors[0].message) {
							console.log("Error message: " + errors[0].message);
							alert('Errors indicated in response: ' +  errors[0].message);
						}
					} else {
						console.log("Unknown error");
					}
				}
				$A.get("e.force:closeQuickAction").fire();
			}
		);
		$A.enqueueAction(action);
	}
})