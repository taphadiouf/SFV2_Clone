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
    
    
    public static void setCongePrisPeriode(List<blng__Invoice__c> newInvoiceList, Map<Id, blng__Invoice__c> newInvoiceMap){
        
        
        Id familleRecTypeId = EM003_RecordTypeEntity.getRecTypeIdByObjectAndName(Label.LPCR_Account,Label.LPCR_Famille);
        
        List<blng__Invoice__c> invoiceList = [Select Id, LPCR_StatutFacture__c  , LPCR_CongesPrisPeriode__c, blng__Account__c,blng__Account__r.recordTypeId FROM blng__Invoice__c WHERE Id IN: newInvoiceList AND blng__Account__r.recordTypeId =: familleRecTypeId AND LPCR_StatutFacture__c = 'A Envoyer'];
        List<blng__InvoiceLine__c> invoiceLines = [Select Id, blng__OrderProduct__r.OrderId, blng__Invoice__c  From blng__InvoiceLine__c WHERE blng__Invoice__c  IN:invoiceList Limit 1];
        if(invoiceLines.size()>0){
            blng__InvoiceLine__c invoiceLine = invoiceLines.get(0);
            List<Contract> contractList =[select Id,SBQQ__Order__c from Contract where SBQQ__Order__c = :invoiceLine.blng__OrderProduct__r.OrderId];
            
            LPCR_ModificationEntrante__c modificationEntrante = [SELECT Id, LPCR_Quantite__c, LPCR_Evenement__c,LPCR_Contract__c  From LPCR_ModificationEntrante__c Where LPCR_Evenement__c='Conges_Pris_Periode' AND LPCR_Contract__c IN:contractList  order by createdDate DESC limit 1];
            
            Decimal modificationQuantity = modificationEntrante.LPCR_Quantite__c;
            
            for(blng__Invoice__c eachNewInvoice : invoiceList){
                
                newInvoiceMap.get(eachNewInvoice.Id).LPCR_CongesPrisPeriode__c = modificationQuantity;
                
            }
        }
        
    }

    // added by saurabh IS-1529
    public static void afterUpdateCreateCreditNoteAllocation(List<blng__Invoice__c> newInvoiceList){
        Pad.log('SM015_InvoiceServices','afterUpdateCreateCreditNoteAllocation(List<blng__Invoice__c> newInvoiceList)','newInvoiceList size '+newInvoiceList.size());
        
        Set<Id> invoiceIdsSet = UM003_TypeManager.getIdsOfListObjects(newInvoiceList);
        Set<Id> creditNoteIdsSet = new Set<Id>();
        List<blng__CreditNoteAllocation__c> insertCreditNoteAllocationList = new List<blng__CreditNoteAllocation__c>();
        
        for(blng__CreditNote__c creditNote : [select id from blng__CreditNote__c where blng__RelatedInvoice__c in: invoiceIdsSet and blng__Status__c = 'Posted' and blng__CreditNoteSourceAction__c = 'Manual' ]){
            creditNoteIdsSet.add(creditNote.id);
        }
        
        if(creditNoteIdsSet.size() > 0){
            for(blng__CreditNoteLine__c eachCNLine : [select id, blng__Balance__c, blng__InvoiceLine__c, blng__InvoiceLine__r.blng__Balance__c from blng__CreditNoteLine__c where blng__Status__c = 'Posted' and blng__Balance__c > 0 Order By CreatedDate]){
                blng__CreditNoteAllocation__c newCreditNoteAllocation = new blng__CreditNoteAllocation__c();
                newCreditNoteAllocation.blng__Amount__c = eachCNLine.blng__InvoiceLine__r.blng__Balance__c;
                newCreditNoteAllocation.blng__InvoiceLine__c = eachCNLine.blng__InvoiceLine__c;
                newCreditNoteAllocation.blng__Notes__c = 'Automatic Credit Note Allocation';
                newCreditNoteAllocation.blng__Type__c = 'Allocation';
                newCreditNoteAllocation.blng__CreditNoteLine__c = eachCNLine.id;
                
                if(eachCNLine.blng__InvoiceLine__r.blng__Balance__c >= eachCNLine.blng__Balance__c){
                    newCreditNoteAllocation.blng__Amount__c = eachCNLine.blng__Balance__c;
                }else{
                    newCreditNoteAllocation.blng__Amount__c = eachCNLine.blng__InvoiceLine__r.blng__Balance__c;
                }
                insertCreditNoteAllocationList.add(newCreditNoteAllocation);
            }
        }
        
        if(insertCreditNoteAllocationList.size() > 0){
            try{
				insert insertCreditNoteAllocationList;                
            }catch(Exception ex){
                PAD.log('SM015_InvoiceServices', 'afterUpdateCreateCreditNoteAllocation', 'Exception: ' + ex.getMessage());
            }
        }
    }
}