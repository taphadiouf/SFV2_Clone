
/* @author Nerea Leguinazabal
* @created 08/10/2021
* @description Trigger actions on  BillingTreatmentTrigger Object
*/
trigger BillingTreatmentTrigger on blng__BillingTreatement__c ( before insert, after insert,
									before update, after update) {
	//The handler will manage all the processes
	new TM023_BillingTransactionTrigger().run();
}