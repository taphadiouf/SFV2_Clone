({
    doInit: function (component, event, helper) {
        var pageReference = component.get("v.pageReference");
        component.set("v.quoteId", pageReference.state.c__quoteId);
        console.log("quoteId : " + pageReference.state.c__quoteId);
        var quoteId = component.get("v.quoteId");

        var action = component.get("c.resetQuantity");
        action.setParams({
            quoteId: quoteId
        });
        action.setCallback(this, function (response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                console.log('success from server');
                console.log("From server: " + response.getReturnValue());
                var urlEvent = $A.get("e.force:navigateToURL");
                urlEvent.setParams({
                    "url": '/apex/SBQQ__sb?id=' + quoteId + '#quote/le?qId=' + quoteId
                });
                urlEvent.fire();
            } else if (state === "ERROR") {
                console.log("Error occured from server");
            }
        });
        $A.enqueueAction(action);
    }
})