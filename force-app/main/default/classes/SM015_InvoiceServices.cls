/**
* @author Saurabh
* @created 15/06/2020
* @description Service class for Invoice Object
*/
public class SM015_InvoiceServices {
    
    public static void createPaymentAndPaymentAllocation(List<blng__Invoice__c> newInvoiceList, Map<Id, blng__Invoice__c> oldInvoiceMap){
        Map<Id, blng__Payment__c> paymentByInvoiceMap = new Map<Id, blng__Payment__c>();
        List<blng__PaymentAllocationInvoice__c> paymentAllocationInvoiceList = new List<blng__PaymentAllocationInvoice__c>();
        
        for(blng__Invoice__c eachInvoice : newInvoiceList){
            // If a status of payment has been received
            if(eachInvoice.LPCR_StatutPaiement__c && eachInvoice.LPCR_StatutPaiement__c != oldInvoiceMap.get(eachInvoice.id).LPCR_StatutPaiement__c){
                blng__Payment__c newPayment = createPayment(eachInvoice.blng__Account__c, eachInvoice.blng__TotalAmount__c);
                paymentByInvoiceMap.put(eachInvoice.Id, newPayment);
            }                
        }
        
        if(paymentByInvoiceMap.size() > 0){
            //Create a blng__Payment__c record
            insert paymentByInvoiceMap.values();
        }
        
        for(blng__Invoice__c eachInvoice : newInvoiceList){
            // If a status of payment has been received
            if(eachInvoice.LPCR_StatutPaiement__c && eachInvoice.LPCR_StatutPaiement__c != oldInvoiceMap.get(eachInvoice.id).LPCR_StatutPaiement__c){
                blng__PaymentAllocationInvoice__c newPaymentAllocationInvoice = createPaymentAllocationInvoice(eachInvoice.id, paymentByInvoiceMap.get(eachInvoice.Id).Id, eachInvoice.blng__TotalAmount__c);
                paymentAllocationInvoiceList.add(newPaymentAllocationInvoice);
            }                
        }
        
        if(paymentAllocationInvoiceList.size() > 0){
            //Create a Payment Allocation record blng__PaymentAllocationInvoice__c
            insert paymentAllocationInvoiceList;
        }
    }
    
    public static blng__Payment__c createPayment(Id accountId, Decimal amount){
        return new blng__Payment__c(blng__Account__c = accountId, blng__Amount__c = amount, blng__Status__c = 'Posted');
    }
    
    public static blng__PaymentAllocationInvoice__c createPaymentAllocationInvoice(Id invoiceId, Id paymentId, Decimal amount){
        return new blng__PaymentAllocationInvoice__c(blng__Invoice__c = invoiceId,blng__Payment__c = paymentId, blng__Amount__c = amount, blng__Type__c = 'Allocation');
    }
    
    public static void setStatutFacture(List<blng__Invoice__c> newInvoiceList, Map<Id, blng__Invoice__c> oldInvoiceMap){
        for(blng__Invoice__c eachNewInvoice : newInvoiceList){
            if(String.isNotBlank(eachNewInvoice.blng__InvoiceStatus__c) 
            && !eachNewInvoice.blng__InvoiceStatus__c.equals(oldInvoiceMap.get(eachNewInvoice.Id).blng__InvoiceStatus__c)
            &&  'Posted'.equals(eachNewInvoice.blng__InvoiceStatus__c)){
                eachNewInvoice.LPCR_StatutFacture__c = 'Prêt à valider';
            }
        }
    }
}