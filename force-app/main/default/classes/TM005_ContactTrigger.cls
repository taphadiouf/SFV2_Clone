
/**
* @author Achraf ABOUL
* @created 26/03/2020
* @description Trigger action handler on Contact Object
*/
public with sharing class TM005_ContactTrigger extends TM000_TriggerHandler{
    
    private Map<Id, Contact> newContactsMap;
    private Map<Id, Contact> oldContactsMap;
    private List<Contact> newContactsList;
    
    public TM005_ContactTrigger() {
        this.newContactsMap = (Map<Id, Contact>) Trigger.newMap;
        this.oldContactsMap = (Map<Id, Contact>) Trigger.oldMap;
        this.newContactsList = (List<Contact>) Trigger.new;
    }

    protected override void beforeInsert() {

        if (!FeatureManagement.checkPermission('LPCR_ByPass_Apex')) {
            SM024_ContactServices.prepareContactsToBeSent(newContactsList);
        }
    }

    protected override void afterInsert() {
        
        if (!FeatureManagement.checkPermission('LPCR_ByPass_Apex')) {
            SM024_ContactServices.initialiseVariableLeadConversion(newContactsMap);
            SM024_ContactServices.sendContacts(newContactsList);
        }
    }
}
