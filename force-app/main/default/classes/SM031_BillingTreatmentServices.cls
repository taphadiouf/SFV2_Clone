/**
 * @author Nerea Leguinazabal
 * @created 08/10/2021
* @description Service class for Billing Treatement Object
*/

public with sharing class SM031_BillingTreatmentServices {
    
    public static void setFinanceBook(List<blng__BillingTreatment__c> newBillingTreatmentList){    
        for(blng__BillingTreatment__c newBillingTreatment : newBillingTreatmentList){
            newBillingTreatment.blng__BillingFinanceBook__c = [SELECT Id FROM blng__FinanceBook__c WHERE Name='Accounting' LIMIT 1]?.Id;
        }
    }
}