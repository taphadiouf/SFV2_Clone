/**
 * @author Ayoub Ouarti
 * @created 27/02/2020
 * @description Trigger actions on LPCR_Preinscription__c Object
 */
trigger PreinscriptionTrigger on LPCR_Preinscription__c (after update,before update,before insert) {
    //The handler will manage all the processes
	new TM006_PreinscriptionTrigger().run();
}