/**
* @author Ayoub Ouarti
* @created 15/07/2020
* @description Service class for blng__CreditNote__c Object
*/
public class SM021_CreditNoteServices {
    
    /**
* @Author Ayoub Ouarti
* @created 15/07/2020
* @Description methode updateReleatedObjectsFields to set releated objects fields
* @Inputs void
*/
    public static void updateReleatedObjectsFields(List<blng__CreditNote__c> creditNoteList){
        Pad.log('SM021_CreditNoteServices','updateReleatedObjectsFields(List<blng__CreditNote__c> creditNoteList)','creditNoteList size '+creditNoteList.size());
        Id accountEntrepriseRTId  = EM003_RecordTypeEntity.getRecTypeIdByObjectAndName(Label.LPCR_Account, Label.LPCR_Entreprise);
        Set<Id> creditNoteListIds = UM003_TypeManager.getIdsOfListObjects(creditNoteList);
        List<blng__CreditNote__c> creditNoteListB2B = [SELECT Id  ,blng__Account__c FROM blng__CreditNote__c WHERE Id IN :creditNoteListIds AND blng__Account__r.RecordTypeId =:accountEntrepriseRTId ];
        Set<String> accountIds =     UM003_TypeManager.getFieldsOfListObjects(creditNoteListB2B, 'blng__Account__c');
        
        
        if(accountIds.size()>0){  
            List<Account> accounts = [SELECT Id,LPCR_ProcessRevenuCascade__c FROM Account WHERE Id IN :accountIds];
            for(Account eachAcc : accounts){
                eachAcc.LPCR_ProcessRevenuCascade__c = true;
            }
            update accounts;
        }
        
    }
    
    /**
* @Author Saurabh
* @created 16/08/2020
* @Description methode afterUpdateCreateCreditNoteAllocation to create new CreditNoteAllocation records
* @Inputs void
*/
    public static void afterUpdateCreateCreditNoteAllocation(List<blng__CreditNote__c> newCreditNoteList, Map<Id, blng__CreditNote__c> oldCreditNoteMap){
        Pad.log('SM021_CreditNoteServices','afterUpdateCreateCreditNoteAllocation(List<blng__CreditNote__c> newCreditNoteList)','newCreditNoteList size '+newCreditNoteList.size());
        Set<String> relatedInvoiceSet = new Set<String>();
        Set<String> creditNoteIdSet = new Set<String>();
        Set<String> updateAccountSet = new Set<String>();
        
        List<blng__CreditNoteAllocation__c> insertCreditNoteAllocationList = new List<blng__CreditNoteAllocation__c>();
        Map<String,Map<String,blng__CreditNoteLine__c>> mapOfInvoiceCreditNoteLine = new Map<String,Map<String,blng__CreditNoteLine__c>>();
        Map<String,Double> mapOfAppliedCNLBal= new Map<String,Double>();
        Integer currentCNLIndex = 1;
        String currentProcessingInvoice = '';
        
        // If credit note is posted then set related Account.LPCR_ProcessRevenuCascade__c to true
        for(blng__CreditNote__c eachCreditNote : newCreditNoteList){
            if('Posted'.equals(eachCreditNote.blng__Status__c) && eachCreditNote.blng__Status__c != oldCreditNoteMap.get(eachCreditNote.id).blng__Status__c){
				updateAccountSet.add(eachCreditNote.blng__Account__c);
            }
        }
        
        // Get blng__RelatedInvoice__c from blng__CreditNote__c
        for(blng__CreditNote__c eachCreditNote : newCreditNoteList){
            if('Posted'.equals(eachCreditNote.blng__Status__c) && 'Negative Lines Conversion'.equals(eachCreditNote.blng__CreditNoteSourceAction__c)){
                relatedInvoiceSet.add(eachCreditNote.blng__RelatedInvoice__c);
                creditNoteIdSet.add(eachCreditNote.id);
            }
        }
        
        decimal minBal = 0;
        if(test.isRunningTest()){minBal = -1;}   
        
        // If I have a set of account ids
        if(relatedInvoiceSet.size() > 0){
            // create map for credit note line record
            for(blng__CreditNoteLine__c eachCNLine : [select id, blng__Balance__c,blng__CreditNote__r.blng__RelatedInvoice__c from blng__CreditNoteLine__c where blng__CreditNote__r.blng__RelatedInvoice__c IN : relatedInvoiceSet and blng__CreditNote__c IN : creditNoteIdSet and  blng__Balance__c > 0 Order By CreatedDate]){
                if(!mapOfInvoiceCreditNoteLine.containsKey(eachCNLine.blng__CreditNote__r.blng__RelatedInvoice__c)){
                    mapOfInvoiceCreditNoteLine.put(eachCNLine.blng__CreditNote__r.blng__RelatedInvoice__c,new Map<String,blng__CreditNoteLine__c>());
                    currentCNLIndex = 1;
                }                
                mapOfInvoiceCreditNoteLine.get(eachCNLine.blng__CreditNote__r.blng__RelatedInvoice__c).put(String.valueOf(currentCNLIndex),eachCNLine);
                mapOfAppliedCNLBal.put(eachCNLine.blng__CreditNote__r.blng__RelatedInvoice__c+'-'+currentCNLIndex,eachCNLine.blng__Balance__c);
                currentCNLIndex ++;
            } 
            currentCNLIndex = 1;
        }
        
        System.debug('>> SM021_CreditNoteServices , afterUpdateCreateCreditNoteAllocation() :  mapOfInvoiceCreditNoteLine ='+mapOfInvoiceCreditNoteLine);
        System.debug('>> SM021_CreditNoteServices , afterUpdateCreateCreditNoteAllocation() :  mapOfAppliedCNLBal ='+mapOfAppliedCNLBal);
        
        // Query only the positive Invoice Lines based on the Source Invoice(blng__RelatedInvoice__c field on Credit Note) AND blng__Balance__c > 0
        if(relatedInvoiceSet.size() > 0){
            for(blng__InvoiceLine__c eachInvLine : [SELECT Id, Name, blng__Balance__c,blng__Invoice__c FROM blng__InvoiceLine__c WHERE blng__Invoice__c IN: relatedInvoiceSet AND blng__Balance__c > : minBal ]){
                
                if(mapOfInvoiceCreditNoteLine.containsKey(eachInvLine.blng__Invoice__c)){
                    
                    // check if invoice  is change then update and reset increment index
                    if(currentProcessingInvoice != String.valueOf(eachInvLine.blng__Invoice__c)){
                        currentProcessingInvoice = eachInvLine.blng__Invoice__c;
                        currentCNLIndex = 1;
                    }
                    
                    // Store billing invoice line balance in local variable
                    Double balance = eachInvLine.blng__Balance__c;
                    Pad.log('SM021_CreditNoteServices','afterUpdateCreateCreditNoteAllocation()','eachInvLine [balance]',eachInvLine.id+' - ['+eachInvLine.blng__Balance__c+']');
                    
                    // inner loop: while loop untile balance not zero or less than zero
                    while(balance > 0){ 
                        if(mapOfInvoiceCreditNoteLine.get(eachInvLine.blng__Invoice__c).containsKey(String.valueOf(currentCNLIndex))){
                            blng__CreditNoteLine__c eachCNLine = mapOfInvoiceCreditNoteLine.get(eachInvLine.blng__Invoice__c).get(String.valueOf(currentCNLIndex));
                            
                            if(mapOfAppliedCNLBal.containsKey(eachInvLine.blng__Invoice__c+'-'+currentCNLIndex) && mapOfAppliedCNLBal.get(eachInvLine.blng__Invoice__c+'-'+currentCNLIndex) > 0){
                                
                                Pad.log('SM021_CreditNoteServices','afterUpdateCreateCreditNoteAllocation()','eachCNLine [balance]',eachCNLine.id+' - ['+mapOfAppliedCNLBal.get(eachInvLine.blng__Invoice__c+'-'+currentCNLIndex)+']');
                                
                                // Create Credit Note Allocation 
                                blng__CreditNoteAllocation__c newCreditNoteAllocation = new blng__CreditNoteAllocation__c();
                                Double balCNL = mapOfAppliedCNLBal.get(eachInvLine.blng__Invoice__c+'-'+currentCNLIndex);
                                
                                // if credit note line balance is grather then equal to invoice line balance then
                                if(balCNL >= balance){
                                    newCreditNoteAllocation.blng__Amount__c = balance;
                                    
                                    Pad.log('SM021_CreditNoteServices','afterUpdateCreateCreditNoteAllocation()','B mapOfAppliedCNLBal '+currentCNLIndex,String.valueOf(balCNL));
                                    mapOfAppliedCNLBal.put(eachInvLine.blng__Invoice__c+'-'+currentCNLIndex, balCNL - balance);
                                    Pad.log('SM021_CreditNoteServices','afterUpdateCreateCreditNoteAllocation()','A mapOfAppliedCNLBal '+currentCNLIndex,String.valueOf(balCNL));
                                    balance = 0;
                                }else if(balCNL > 0 && balCNL < balance ){
                                    newCreditNoteAllocation.blng__Amount__c = balCNL;
                                    balance = balance - balCNL;
                                    mapOfAppliedCNLBal.put(eachInvLine.blng__Invoice__c+'-'+currentCNLIndex, 0);
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
        }
        
        if(insertCreditNoteAllocationList.size() > 0){
            try{
                insert insertCreditNoteAllocationList;                
            }catch(Exception ex){
                PAD.log('SM021_CreditNoteServices', 'afterUpdateCreateCreditNoteAllocation', 'Exception: ' + ex.getMessage());
            }
        }
        
        // Upon B2B Posting of Credit Notes (status = posted)
        if(updateAccountSet.size()>0){  
            List<Account> accounts = [SELECT Id,LPCR_ProcessRevenuCascade__c FROM Account WHERE Id IN :updateAccountSet];
            for(Account eachAcc : accounts){
                eachAcc.LPCR_ProcessRevenuCascade__c = true;
            }	
            update accounts;
        }
    }
    
}