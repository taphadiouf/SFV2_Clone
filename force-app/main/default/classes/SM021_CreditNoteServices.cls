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
        //to be replaced by the new B2B Contract RTs ( LPCR_Referencement & LPCR_Referencement_Approuve) after merging the IS-1165
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
    
}