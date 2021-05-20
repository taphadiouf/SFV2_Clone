/**
* @author  PDO
* @created 13/05/2021
* @description Trigger on LPCR_BonAchatPartenaire__c Object
*/
trigger BonAchatPartenaire on LPCR_BonAchatPartenaire__c (after insert) {
    new TM025_BonAchatPartenaireTrigger().run();
}