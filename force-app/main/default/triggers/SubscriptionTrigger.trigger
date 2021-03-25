/**
* @author  PDO
* @created 19/03/2021
* @description Trigger on SBQQ__Subscription__c Object
*/
trigger SubscriptionTrigger on SBQQ__Subscription__c (after insert, before update,before insert,after update) {
    new TM023_SubscriptionTrigger().run();
}