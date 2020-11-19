({      
    closeQuickAction : function(component, event, helper) {
        console.log("we are closing the quick Action from aura");
        $A.get("e.force:closeQuickAction").fire();
    }
});