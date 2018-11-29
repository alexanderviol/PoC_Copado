({
	throwExceptionMeaage : function(response) {
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
})