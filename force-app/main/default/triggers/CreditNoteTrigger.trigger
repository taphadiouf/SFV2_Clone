/**
 * @author Ayoub Ouarti
 * @created 15/07/2020
 * @description Trigger actions on blng__CreditNote__c Object
 */
trigger CreditNoteTrigger on blng__CreditNote__c (after insert, after update) {
    //The handler will manage all the processes
	new TM016_CreditNoteTrigger().run();
}