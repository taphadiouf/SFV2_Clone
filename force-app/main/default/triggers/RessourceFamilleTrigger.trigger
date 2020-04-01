trigger RessourceFamilleTrigger on LPCR_RessourceFamille__c (before update) {
new TM010_RessourceFamilleTrigger().run();
}