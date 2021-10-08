/**
 * @author Nerea Leguinazabal
 * @created 08/10/2021
* @description Service class for Billing Treatement Object
*/

public with sharing class SM031_BillingTreatementServices {
    
    public static void setFinanceBook(List<blng__BillingTreatement__c> newBillingTreatementList){

        blng__FinanceBook__c accountingBook = [SELECT Id FROM blng__FinanceBook__c WHERE Name='Accounting'];
        
        for(blng__BillingTreatement__c newBillingTreatment : newBillingTreatementList){
            newBillingTreatment.blng__BillingFinanceBook__c = accountingBook.Id;
        }
    }
}