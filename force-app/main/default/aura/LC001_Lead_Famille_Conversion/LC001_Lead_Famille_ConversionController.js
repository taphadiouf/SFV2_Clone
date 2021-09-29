({
	getValueCreateCTFromLwc: function(component, event, helper) {
		component.set("v.createContratAccueil",event.getParam('value'));
	},
	cancelAction: function(component, event, helper) {
		console.log('PRA ICI ');
		$A.get("e.force:closeQuickAction").fire();
	}
})