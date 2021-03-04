/**
 * @author Erwan Yhuellou
 * @created 26/02/2021
* @description Service class for Billing Transaction Object
*/

public with sharing class SM026_BillingTransactionServices {
    
    public static void setCorrespondingRevenueTransactions(Map<Id, blng__BillingTransaction__c> oldBtMap, Map<Id, blng__BillingTransaction__c> newBtMap){
        
        for(blng__BillingTransaction__c bt : newBtMap.values()){

            if((oldBtMap.get(bt.Id).blng__OverrideAmount__c != bt.blng__OverrideAmount__c) || 
            oldBtMap.get(bt.Id).blng__OverrideBillingTargetDate__c != bt.blng__OverrideBillingTargetDate__c){
                
                PAD.log('SM026_BillingTransactionServices', 'setCorrespondingRevenueTransactions', 'critical value changed - bt' + bt);
                bt.LPCR_ProcessProrate__c = true;
            }
        }
    }
}
