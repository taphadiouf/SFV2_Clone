({

    goToAmendPage : function(component, event, helper){
    		var contractId = component.get("v.recordId");
        	var errorMessage = null;
        	
        
            // in the server-side controller
            var action = component.get("c.getContractDetails");
            action.setParams({ "contractId" : contractId});
    
            // Create a callback that is executed after 
            // the server-side action returns
            action.setCallback(this, function(response) {
                var state = response.getState();
                if (state === "SUCCESS") {
                    errorMessage = response.getReturnValue();
                    
                    // set the error message to display to user
                    component.set('v.errorMessage', errorMessage);
                    
                    //alert("From server: " + errorMessage);
                    // redirect to standard CPQ amend page
                    if(errorMessage == '' || errorMessage == null ) {
                        // redirect the user to amend page
                        if(contractId != null){
                            window.open('/apex/sbqq__AmendContract?id=' + contractId,'_blank');
                        }
                        var closeAction = $A.get("e.force:closeQuickAction");
                        setTimeout(function(){
                                   closeAction.fire();
                        }, 1000);
                    }
                }
                else if (state === "INCOMPLETE") {
                    // do something
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
    
            // A client-side action could cause multiple events, 
            // which could trigger other events and 
            // other server-side action calls.
            // $A.enqueueAction adds the server-side action to the queue.
            $A.enqueueAction(action);
        	
        	
        
    	},
});