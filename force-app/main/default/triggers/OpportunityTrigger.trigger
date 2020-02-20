/**
* @author Achraf ABOUL
* @created 20/02/2020
* @description Trigger actions on Opportunity Object
*/
trigger OpportunityTrigger on Opportunity (before insert) {
    
    new TM004_OpportunityTrigger().run();
}