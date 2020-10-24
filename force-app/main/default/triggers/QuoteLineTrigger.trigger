/**
* @author Dario Correnti
* @created 19/05/2020
* @description Trigger actions on QuoteLin Object
*/
trigger QuoteLineTrigger on SBQQ__QuoteLine__c (before insert, before update) {
    new TM012_QuoteLineItemTrigger().run();
}