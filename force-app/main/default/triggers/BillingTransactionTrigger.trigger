/**
 * @author Erwan Yhuellou
 * @created 26/02/2021
 * @description Trigger actions on Account Object
 */
trigger BillingTransactionTrigger on Account ( before insert, after insert,
									before update, after update) {
	//The handler will manage all the processes
	new TM023_BillingTransactionTrigger().run();
}