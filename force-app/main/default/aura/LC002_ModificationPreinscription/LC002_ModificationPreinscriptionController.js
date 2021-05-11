({
    doInit: function(component, event, helper) {
        var pageReference = component.get("v.pageReference");
        console.log("pageRefer : " + pageReference);
        component.set("v.accId", pageReference.state.c__accId);
        
    }
})