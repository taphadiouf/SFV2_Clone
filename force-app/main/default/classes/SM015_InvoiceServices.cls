/**
* @author Saurabh
* @created 15/06/2020
* @description Service class for Invoice Object
*/
public class SM015_InvoiceServices {

/*
* 	@Author : Ayoub Ouarti
* 	@Created 10/07/2020
*	@Description : this method create Payment And Payment Allocation for Invoice with changed LPCR_StatutPaiement__c 
* 	@Inputs	List<blng__Invoice__c> newInvoiceList, Map<Id, blng__Invoice__c> oldInvoiceMap
*/
    public static void createPaymentAndPaymentAllocation(List<blng__Invoice__c> newInvoiceList, Map<Id, blng__Invoice__c> oldInvoiceMap){
        Map<Id, blng__Payment__c> paymentByInvoiceMap = new Map<Id, blng__Payment__c>();
        Map<Id,blng__Invoice__c> mapInvocieLineStatutPaiement = new Map<Id,blng__Invoice__c>();
        List<blng__PaymentAllocationInvoiceLine__c> listPaymentAlloInvoiceLine = new  List<blng__PaymentAllocationInvoiceLine__c>();
        Map<String,Decimal> mapInvoiceSumBalanceInvoicelines = new Map<String,Decimal>();
        
        for(blng__Invoice__c eachInvoice : newInvoiceList){
            // If a status of payment has been received
            if(eachInvoice.LPCR_StatutPaiement__c && eachInvoice.LPCR_StatutPaiement__c != oldInvoiceMap.get(eachInvoice.id).LPCR_StatutPaiement__c){
                mapInvocieLineStatutPaiement.put(eachInvoice.Id,eachInvoice);
            }                
        }
        
        List<blng__InvoiceLine__c > listInvoiceline = [SELECT blng__Invoice__c, blng__Balance__c FROM blng__InvoiceLine__c WHERE blng__Balance__c > 0 AND blng__Invoice__c IN :mapInvocieLineStatutPaiement.keySet() ];
        for(blng__InvoiceLine__c eachInvoiceLine : listInvoiceline){
            mapInvoiceSumBalanceInvoicelines.put(String.valueOf(eachInvoiceLine.blng__Invoice__c),
                                                 !mapInvoiceSumBalanceInvoicelines.containsKey(eachInvoiceLine.blng__Invoice__c)? eachInvoiceLine.blng__Balance__c
                                                 :eachInvoiceLine.blng__Balance__c+mapInvoiceSumBalanceInvoicelines.get(eachInvoiceLine.blng__Invoice__c));
        }
        for(blng__Invoice__c eachInvoice : mapInvocieLineStatutPaiement.values()){
          if(mapInvoiceSumBalanceInvoicelines.containsKey(eachInvoice.Id))  paymentByInvoiceMap.put(eachInvoice.Id, new blng__Payment__c(blng__Account__c = eachInvoice.blng__Account__c, blng__Amount__c = mapInvoiceSumBalanceInvoicelines.get(eachInvoice.Id), blng__Status__c = 'Posted' ));
        }
        if(paymentByInvoiceMap.size() > 0){
            //Create a blng__Payment__c record
            insert paymentByInvoiceMap.values();
        }
        
        
        for(blng__InvoiceLine__c eachInvoiceLine : listInvoiceline){
            listPaymentAlloInvoiceLine.add(new blng__PaymentAllocationInvoiceLine__c(blng__InvoiceLine__c =eachInvoiceLine.Id,
                                                                                     blng__Payment__c =paymentByInvoiceMap.get(eachInvoiceLine.blng__Invoice__c).Id,
                                                                                     blng__Amount__c=eachInvoiceLine.blng__Balance__c,
                                                                                     blng__Type__c='Allocation')); 
        }
        
        if(listPaymentAlloInvoiceLine.size() > 0){
            //Create a Payment Allocation record blng__PaymentAllocationInvoice__c
            insert listPaymentAlloInvoiceLine;
        }
    }
    
    public static void setStatutFacture(List<blng__Invoice__c> newInvoiceList, Map<Id, blng__Invoice__c> oldInvoiceMap){
        for(blng__Invoice__c eachNewInvoice : newInvoiceList){
            System.debug('eachNewInvoice => ' + eachNewInvoice);
            if(String.isNotBlank(eachNewInvoice.blng__InvoiceStatus__c) 
               && !eachNewInvoice.blng__InvoiceStatus__c.equals(oldInvoiceMap.get(eachNewInvoice.Id).blng__InvoiceStatus__c)
               &&  'Posted'.equals(eachNewInvoice.blng__InvoiceStatus__c)){
                   eachNewInvoice.LPCR_StatutFacture__c = 'Prêt à valider';
               }
        }
    }
}