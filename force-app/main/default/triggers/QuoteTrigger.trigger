/**
* @author Achraf ABOUL
* @created 28/02/2020
* @description Trigger action handler on SBQQ__Quote__c Object
*/
trigger QuoteTrigger on SBQQ__Quote__c (before update,before insert,after insert) {
	new TM008_QuoteTrigger().run();
}