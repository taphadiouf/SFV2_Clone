/**
* @author Ayoub Ouarti
* @created 25/03/2020
* @description Trigger action handler on RessourceFamille Object
*/
public with sharing class TM010_RessourceFamilleTrigger extends TM000_TriggerHandler{
    private Map<Id, LPCR_RessourceFamille__c> newRessourceFamillesMap;
    private Map<Id, LPCR_RessourceFamille__c> oldRessourceFamillesMap;
    private List<LPCR_RessourceFamille__c> newRessourceFamillesList;
    
    public TM010_RessourceFamilleTrigger() {
        this.newRessourceFamillesMap = (Map<Id, LPCR_RessourceFamille__c>) Trigger.newMap;
        this.oldRessourceFamillesMap = (Map<Id, LPCR_RessourceFamille__c>) Trigger.oldMap;
        this.newRessourceFamillesList = (List<LPCR_RessourceFamille__c>) Trigger.new;
    }
    protected override void beforeUpdate() {
        if (PAD.canTrigger('SM001_TestIfByPassed')) SM001_TestIfByPassed.executeMethod();
        SM011_RessourceFamilleServices.createNewRessourceFamilleRecord(newRessourceFamillesMap,oldRessourceFamillesMap);
    }
}
