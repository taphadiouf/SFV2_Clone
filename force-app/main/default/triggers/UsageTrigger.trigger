/**
 * @author Ayoub Ouarti
 * @created 09/06/2020
 * @description Trigger actions on Usage Object
 */
trigger UsageTrigger on blng__Usage__c (before insert) {
    //The handler will manage all the processes
	new TM013_UsageTrigger().run();
}