/**
 * @description       :
 * @author            : Rakshak Rajjoo
 * @last modified on  : 13/10/2021
 * @last modified by  : Rakshak Rajjoo
 * Modifications Log
 * Ver   Date         Author           Modification
 * 1.0   13/10/2021   Rakshak Rajjoo   Initial Version
 **/
({
    doInit: function (component, event, helper) {
        var recId = component.get("v.recordId");

        var action = component.get("c.doUplift");
        action.setParams({ contractId: recId });

        action.setCallback(this, function (response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                console.log("From server: " + response.getReturnValue());
            } else if (state === "INCOMPLETE") {
                console.log("## Incomplete");
            } else if (state === "ERROR") {
                var errors = response.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        console.log("Error message: " + errors[0].message);
                    }
                }
            } else {
                console.log("Unknown error");
            }
        });

        action.setAbortable();
        $A.enqueueAction(action);
    }
});
