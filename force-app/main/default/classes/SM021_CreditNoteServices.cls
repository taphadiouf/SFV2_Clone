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
        
		List<blng__CreditNoteAllocation__c> insertCreditNoteAllocationList = new List<blng__CreditNoteAllocation__c>();
        
        // Get blng__RelatedInvoice__c from blng__CreditNote__c
        for(blng__CreditNote__c eachCreditNote : newCreditNoteList){
            if('Posted'.equals(eachCreditNote.blng__Status__c) && 'Negative Lines Conversion'.equals(eachCreditNote.blng__CreditNoteSourceAction__c)){
                relatedInvoiceSet.add(eachCreditNote.blng__RelatedInvoice__c);
            }
        }
        
        decimal minBal = 0;
        if(test.isRunningTest()){minBal = -1;}   

		// Query only the positive Invoice Lines based on the Source Invoice(blng__RelatedInvoice__c field on Credit Note) AND blng__Balance__c > 0
        if(relatedInvoiceSet.size() > 0){
            for(blng__InvoiceLine__c eachInvoiceLine : [SELECT Id, Name, blng__Balance__c, blng__ConvertedCreditNoteLine__c,blng__ConvertedCreditNoteLine__r.blng__TotalAmount__c FROM blng__InvoiceLine__c WHERE blng__Invoice__c IN: relatedInvoiceSet AND blng__Balance__c > : minBal ]){
                blng__CreditNoteAllocation__c newCreditNoteAllocation = new blng__CreditNoteAllocation__c();
                newCreditNoteAllocation.blng__Amount__c = eachInvoiceLine.blng__Balance__c;
                newCreditNoteAllocation.blng__InvoiceLine__c = eachInvoiceLine.id;
                newCreditNoteAllocation.blng__Notes__c = 'Automatic Credit Note Allocation';
                newCreditNoteAllocation.blng__Type__c = 'Allocation';
                newCreditNoteAllocation.blng__CreditNoteLine__c = eachInvoiceLine.blng__ConvertedCreditNoteLine__c;
                
                if(eachInvoiceLine.blng__Balance__c >= eachInvoiceLine.blng__ConvertedCreditNoteLine__r.blng__TotalAmount__c){
                    newCreditNoteAllocation.blng__Amount__c = eachInvoiceLine.blng__ConvertedCreditNoteLine__r.blng__TotalAmount__c;
                }else{
                    newCreditNoteAllocation.blng__Amount__c = eachInvoiceLine.blng__Balance__c;
                }
                insertCreditNoteAllocationList.add(newCreditNoteAllocation);
            }
        }
		
        if(insertCreditNoteAllocationList.size() > 0){
            try{
				insert insertCreditNoteAllocationList;                
            }catch(Exception ex){
                PAD.log('SM021_CreditNoteServices', 'afterUpdateCreateCreditNoteAllocation', 'Exception: ' + ex.getMessage());
            }
        }
    }
    
}