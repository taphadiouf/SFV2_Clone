/**
 * @author Saurabh
 * @created 15/06/2020
 * @description Trigger actions on Invoice Object
 */
trigger InvoiceTrigger on blng__Invoice__c (after insert, before update, after update) {
	//The handler will manage all the processes
	new TM014_InvoiceTrigger().run();
}