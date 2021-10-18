/**
 * @description       :
 * @author            : Rakshak Rajjoo
 * @last modified on  : 14/10/2021
 * @last modified by  : Rakshak Rajjoo
 * Modifications Log
 * Ver   Date         Author           Modification
 * 1.0   14/10/2021   Rakshak Rajjoo   Initial Version
 **/
({
    showToast: function (type, title, message) {
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            type: type,
            title: title,
            message: message
        });
        toastEvent.fire();
    }
});
