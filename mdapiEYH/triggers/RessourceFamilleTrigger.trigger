trigger RessourceFamilleTrigger on LPCR_RessourceFamille__c (after insert, before update,before insert,after update) {
new TM010_RessourceFamilleTrigger().run();
}