/**
* @author Hanae Makboub
* @created 15/05/2020
* @description Trigger action handler on LPCR_ModificationEntrante__c Object
*/
trigger ModificationEntranteTrigger on LPCR_ModificationEntrante__c (after insert) {
	new TM012_ModificationEntranteTrigger().run();
}