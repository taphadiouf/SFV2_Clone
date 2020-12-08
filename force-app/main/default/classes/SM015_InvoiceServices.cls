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
        Set<String> accountIds = new Set<String>();
        
        for(blng__Invoice__c eachInvoice : newInvoiceList){
            // If invoice is Posted and LPCR_StatutFacture__c = 'Envoyée'
            if('Posted'.equals(eachInvoice.blng__InvoiceStatus__c) && eachInvoice.blng__InvoiceStatus__c != oldInvoiceMap.get(eachInvoice.id).blng__InvoiceStatus__c && 'Envoyée'.equals(eachInvoice.LPCR_StatutFacture__c)){
                accountIds.add(eachInvoice.blng__Account__c);
            }
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
        
        // On modification of B2B invoices where Status = 'Posted' and LPCR_StatutFacture__c = 'Envoyée'
        if(accountIds.size()>0){  
            List<Account> accounts = [SELECT Id,LPCR_ProcessRevenuCascade__c FROM Account WHERE Id IN :accountIds];
            for(Account eachAcc : accounts){
                eachAcc.LPCR_ProcessRevenuCascade__c = true;
            }	
            update accounts;
        }
    }
    


    public static void resetAccountProcessRevenuCascade(List<blng__Invoice__c> newInvoiceList, Map<Id, blng__Invoice__c> oldInvoiceMap) {

        Set<Id> setAccount = new Set<Id>();

        for(blng__Invoice__c eachNewInvoice : newInvoiceList){

            if(String.isNotBlank(eachNewInvoice.blng__InvoiceStatus__c) 
               && !eachNewInvoice.blng__InvoiceStatus__c.equals(oldInvoiceMap.get(eachNewInvoice.Id).blng__InvoiceStatus__c)
               &&  'Posted'.equals(eachNewInvoice.blng__InvoiceStatus__c)) {

                setAccount.add(eachNewInvoice.blng__Account__c);
            }
        }

        List<Account> listAcc = [Select Id, LPCR_ProcessRevenuCascade__c From Account WHERE Id  IN:setAccount];

        if(listAcc.size() > 0) {

            for(Account acc : listAcc){
                acc.LPCR_ProcessRevenuCascade__c = true;
            }
        }

        update listAcc;
    }

    
	    
    public static void setCongePrisPeriode(List<blng__Invoice__c> newInvoiceList, Map<Id, blng__Invoice__c> newInvoiceMap){
        
        
        Id familleRecTypeId = EM003_RecordTypeEntity.getRecTypeIdByObjectAndName(Label.LPCR_Account,Label.LPCR_Famille);
        
        List<blng__Invoice__c> invoiceList = [Select Id, LPCR_StatutFacture__c  , LPCR_CongesPrisPeriode__c, blng__Account__c,blng__Account__r.recordTypeId FROM blng__Invoice__c WHERE Id IN: newInvoiceList AND blng__Account__r.recordTypeId =: familleRecTypeId AND LPCR_StatutFacture__c = 'A Envoyer'];
        List<blng__InvoiceLine__c> invoiceLines = [Select Id, blng__OrderProduct__r.OrderId, blng__Invoice__c  From blng__InvoiceLine__c WHERE blng__Invoice__c  IN:invoiceList Limit 1];
        if(invoiceLines.size()>0){
            blng__InvoiceLine__c invoiceLine = invoiceLines.get(0);
            List<Contract> contractList =[select Id,SBQQ__Order__c from Contract where SBQQ__Order__c = :invoiceLine.blng__OrderProduct__r.OrderId];
            try{
            LPCR_ModificationEntrante__c modificationEntrante = [SELECT Id, LPCR_Quantite__c, LPCR_Evenement__c,LPCR_Contract__c  From LPCR_ModificationEntrante__c Where LPCR_Evenement__c='EVT_NOMBRE_JOUR_CONGE' AND LPCR_Contract__c IN:contractList  order by createdDate DESC limit 1];

                Decimal modificationQuantity = modificationEntrante.LPCR_Quantite__c;
            
                for(blng__Invoice__c eachNewInvoice : invoiceList){
                
                    newInvoiceMap.get(eachNewInvoice.Id).LPCR_CongesPrisPeriode__c = modificationQuantity;
                
                }
            }
            catch(Exception e) {
    			System.debug('An exception occurred: ' + e.getMessage());
            }
            
        }
        
    }
    
    // added by saurabh singh IS-1651
    public static void setFieldsOnInvoice(List<blng__Invoice__c> newInvoiceList, Map<Id, blng__Invoice__c> newInvoiceMap, Boolean isInsert){
        Pad.log('SM015_InvoiceServices','setFieldsOnInvoice(List<blng__Invoice__c> newInvoiceList)','newInvoiceList size '+newInvoiceList.size());


        List<blng__Invoice__c> invoicesToProcess = new List<blng__Invoice__c>();
        if(isInsert){
            invoicesToProcess = newInvoiceList;
        }else{
            invoicesToProcess = newInvoiceMap.values();
        }

        Id familleRecTypeId = EM003_RecordTypeEntity.getRecTypeIdByObjectAndName(Label.LPCR_Account,Label.LPCR_Famille);
        
        List<blng__Invoice__c> invoiceList = [SELECT Id, blng__Account__c,blng__Account__r.recordTypeId FROM blng__Invoice__c WHERE Id IN: invoicesToProcess AND blng__Account__r.recordTypeId =: familleRecTypeId];

        Set<Id> invoicesIds = UM003_TypeManager.getIdsOfListObjects(invoiceList);

        //Get the first invoice line of each invoice
        List<blng__InvoiceLine__c> invoiceLines = new List<blng__InvoiceLine__c>();
        for(blng__Invoice__c queriedInvoice : [ SELECT Id,
                                                    ( SELECT blng__Invoice__c,blng__OrderProduct__r.OrderId FROM blng__InvoiceInvoiceLines__r LIMIT 1) // take the first one
                                                FROM blng__Invoice__c WHERE Id in: invoicesIds]){

            if(queriedInvoice.blng__InvoiceInvoiceLines__r.size() > 0) {
                invoiceLines.add(queriedInvoice.blng__InvoiceInvoiceLines__r[0]);
            }
        }

        Map<String,blng__Invoice__c> updateInvoiceMap = new Map<String,blng__Invoice__c>();
        
        Set<String> orderIds = new Set<String>(); 
        for(blng__InvoiceLine__c eachInvoiceLine : invoiceLines){
            if(eachInvoiceLine.blng__OrderProduct__c != null){
                orderIds.add(eachInvoiceLine.blng__OrderProduct__r.OrderId);	
            }
        }
        
        Map<ID, Order> invoiceOrderMap = new Map<ID, Order>([Select Id,LPCR_ContactEnfant__c,LPCR_Creche__c From Order Where Id in: orderIds ]);
        
        if(invoiceLines.size()>0){
            for(blng__InvoiceLine__c eachNewInvoiceLine : invoiceLines){
                newInvoiceMap.get(eachNewInvoiceLine.blng__Invoice__c).LPCR_Creche__c = invoiceOrderMap.get(eachNewInvoiceLine.blng__OrderProduct__r.OrderId).LPCR_Creche__c;
                newInvoiceMap.get(eachNewInvoiceLine.blng__Invoice__c).LPCR_ContactEnfant__c = invoiceOrderMap.get(eachNewInvoiceLine.blng__OrderProduct__r.OrderId).LPCR_ContactEnfant__c;            	
                if(!updateInvoiceMap.containsKey(eachNewInvoiceLine.blng__Invoice__c)){
                    updateInvoiceMap.put(eachNewInvoiceLine.blng__Invoice__c,newInvoiceMap.get(eachNewInvoiceLine.blng__Invoice__c));
                }
            }
        }
        
        if(isInsert){
            if(updateInvoiceMap.size() > 0){
                update (updateInvoiceMap.values());
            }            
        }

    }
    
    // added by saurabh IS-1529
    public static void afterUpdateCreateCreditNoteAllocation(List<blng__Invoice__c> newInvoiceList,Map<Id, blng__Invoice__c> oldInvoiceMap){
        if(!System.isFuture() &&  !System.isBatch()){
            if(Limits.getFutureCalls() < Limits.getLimitFutureCalls()){
                Pad.log('SM015_InvoiceServices','afterUpdateCreateCreditNoteAllocation(List<blng__Invoice__c> newInvoiceList)','newInvoiceList size '+newInvoiceList.size());
                
                Set<String> invoiceAccountIdsSet = new Set<String>(); 
                Set<String> invoiceIdsSet = new Set<String>(); 
                
                // Get only posted invoice account ids and invoice ids into set
                for(blng__Invoice__c eachInvoice : newInvoiceList){
                    if('Posted'.equals(eachInvoice.blng__InvoiceStatus__c) && eachInvoice.blng__InvoiceStatus__c != oldInvoiceMap.get(eachInvoice.id).blng__InvoiceStatus__c && eachInvoice.blng__Account__c != null ){
                        invoiceAccountIdsSet.add(eachInvoice.blng__Account__c);
                        invoiceIdsSet.add(eachInvoice.id);
                    }
                }
                System.debug('SM015_InvoiceServices : afterUpdateCreateCreditNoteAllocation() - invoiceAccountIdsSet'+ invoiceAccountIdsSet );
                System.debug('SM015_InvoiceServices : afterUpdateCreateCreditNoteAllocation() - invoiceIdsSet'+ invoiceIdsSet);
                futureUpdateCreateCreditNoteAllocation(invoiceAccountIdsSet,invoiceIdsSet);
            }
        }
    }
    
    @future(callout=true)
    public static void futureUpdateCreateCreditNoteAllocation(Set<String> invoiceAccountIdsSet, Set<String> invoiceIdsSet){
        Pad.log('SM015_InvoiceServices','futureUpdateCreateCreditNoteAllocation(Set<String> invoiceAccountIdsSet, Set<String> invoiceIdsSet)','invoiceAccountIdsSet size '+invoiceAccountIdsSet.size());      
        
        System.debug('SM015_InvoiceServices : futureUpdateCreateCreditNoteAllocation() - invoiceAccountIdsSet'+ invoiceAccountIdsSet );
        System.debug('SM015_InvoiceServices : futureUpdateCreateCreditNoteAllocation() - invoiceIdsSet'+ invoiceIdsSet);       
        
        List<blng__CreditNoteAllocation__c> insertCreditNoteAllocationList = new List<blng__CreditNoteAllocation__c>();        
        
        Map<String,Map<String,blng__CreditNoteLine__c>> mapOfAccountCreditNoteLine = new Map<String,Map<String,blng__CreditNoteLine__c>>();
        Map<String,Double> mapOfAppliedCNLBal= new Map<String,Double>();
        
        String currentProcessingAccount = '';
        Integer currentCNLIndex = 1;
        
        // If I have a set of account ids
        if(invoiceAccountIdsSet.size() > 0){
            // create map for credit note line record
            for(blng__CreditNoteLine__c eachCNLine : [select id, blng__Balance__c,blng__CreditNote__r.blng__Account__c from blng__CreditNoteLine__c where blng__CreditNote__r.blng__Account__c IN : invoiceAccountIdsSet and  blng__CreditNote__r.blng__Status__c = 'Posted' and blng__CreditNote__r.blng__CreditNoteSourceAction__c = 'Manual' and blng__Status__c = 'Posted' and blng__Balance__c > 0 Order By CreatedDate]){
                if(!mapOfAccountCreditNoteLine.containsKey(eachCNLine.blng__CreditNote__r.blng__Account__c)){
                    mapOfAccountCreditNoteLine.put(eachCNLine.blng__CreditNote__r.blng__Account__c,new Map<String,blng__CreditNoteLine__c>());
                    currentCNLIndex = 1;
                }                
                mapOfAccountCreditNoteLine.get(eachCNLine.blng__CreditNote__r.blng__Account__c).put(String.valueOf(currentCNLIndex),eachCNLine);
                mapOfAppliedCNLBal.put(eachCNLine.blng__CreditNote__r.blng__Account__c+'-'+currentCNLIndex,eachCNLine.blng__Balance__c);
                currentCNLIndex ++;
            } 
            currentCNLIndex = 1;
        }
        
        // outer loop: loop over Invoice Line based on some conditions
        for(blng__InvoiceLine__c eachInvLine : [select Id, Name, blng__Invoice__c,blng__Invoice__r.blng__Account__c, blng__Balance__c from blng__InvoiceLine__c where blng__Invoice__c in: invoiceIdsSet and blng__Invoice__r.blng__InvoiceStatus__c = 'Posted' Order By blng__Invoice__r.blng__Account__c , CreatedDate]){
            Pad.log('SM015_InvoiceServices','futureUpdateCreateCreditNoteAllocation()','eachInvLine',eachInvLine.id+' - ['+eachInvLine.Name+']');
            if(mapOfAccountCreditNoteLine.containsKey(eachInvLine.blng__Invoice__r.blng__Account__c)){
                
                // check if invoice account is change then update and reset increment index
                if(currentProcessingAccount != String.valueOf(eachInvLine.blng__Invoice__r.blng__Account__c)){
                    currentProcessingAccount = eachInvLine.blng__Invoice__r.blng__Account__c;
                    currentCNLIndex = 1;
                }
                
                // Store billing invoice line balance in local variable
                Double balance = eachInvLine.blng__Balance__c;
                Pad.log('SM015_InvoiceServices','futureUpdateCreateCreditNoteAllocation()','eachInvLine [balance]',eachInvLine.id+' - ['+eachInvLine.blng__Balance__c+']');
                
                // inner loop: while loop untile balance not zero or less than zero
                while(balance > 0){ 
                    if(mapOfAccountCreditNoteLine.get(eachInvLine.blng__Invoice__r.blng__Account__c).containsKey(String.valueOf(currentCNLIndex))){
                        blng__CreditNoteLine__c eachCNLine = mapOfAccountCreditNoteLine.get(eachInvLine.blng__Invoice__r.blng__Account__c).get(String.valueOf(currentCNLIndex));
                        
                        if(mapOfAppliedCNLBal.containsKey(eachInvLine.blng__Invoice__r.blng__Account__c+'-'+currentCNLIndex) && mapOfAppliedCNLBal.get(eachInvLine.blng__Invoice__r.blng__Account__c+'-'+currentCNLIndex) > 0){
                            
                            Pad.log('SM015_InvoiceServices','futureUpdateCreateCreditNoteAllocation()','eachCNLine [balance]',eachCNLine.id+' - ['+mapOfAppliedCNLBal.get(eachInvLine.blng__Invoice__r.blng__Account__c+'-'+currentCNLIndex)+']');
                            
                            // Create Credit Note Allocation 
                            blng__CreditNoteAllocation__c newCreditNoteAllocation = new blng__CreditNoteAllocation__c();
                            Double balCNL = mapOfAppliedCNLBal.get(eachInvLine.blng__Invoice__r.blng__Account__c+'-'+currentCNLIndex);
                            // if credit note line balance is grather then equal to invoice line balance then
                            if(balCNL >= balance){
                                newCreditNoteAllocation.blng__Amount__c = balance;
                                
                                Pad.log('SM015_InvoiceServices','futureUpdateCreateCreditNoteAllocation()','B mapOfAppliedCNLBal '+currentCNLIndex,String.valueOf(balCNL));
                                mapOfAppliedCNLBal.put(eachInvLine.blng__Invoice__r.blng__Account__c+'-'+currentCNLIndex, balCNL - balance);
                            	Pad.log('SM015_InvoiceServices','futureUpdateCreateCreditNoteAllocation()','A mapOfAppliedCNLBal '+currentCNLIndex,String.valueOf(balCNL));
                                balance = 0;
                            }else if(balCNL > 0 && balCNL < balance ){
                                newCreditNoteAllocation.blng__Amount__c = balCNL;
                                balance = balance - balCNL;
                                mapOfAppliedCNLBal.put(eachInvLine.blng__Invoice__r.blng__Account__c+'-'+currentCNLIndex, 0);
                                currentCNLIndex++;
                            }else{
                                balance = 0;
                            }
                            
                            newCreditNoteAllocation.blng__InvoiceLine__c = eachInvLine.Id;
                            newCreditNoteAllocation.blng__Notes__c = 'Automatic Credit Note Allocation';
                            newCreditNoteAllocation.blng__Type__c = 'Allocation';
                            newCreditNoteAllocation.blng__CreditNoteLine__c = eachCNLine.id;
                            
                            // add newCreditNoteAllocation into list 
                            insertCreditNoteAllocationList.add(newCreditNoteAllocation);
                            
                        }
                    }else{
                        balance = 0;
                    }
                }
                
            }
        }
        
        if(insertCreditNoteAllocationList.size() > 0){
            try{
                Pad.log('SM015_InvoiceServices','afterUpdateCreateCreditNoteAllocation1()','insertCreditNoteAllocationList size',String.valueOf(insertCreditNoteAllocationList.size()));
                
                insert insertCreditNoteAllocationList;                
            }catch(Exception ex){
                PAD.log('SM015_InvoiceServices', 'afterUpdateCreateCreditNoteAllocation1()', 'Exception: ' + ex.getMessage());
            }
        }
    }
}