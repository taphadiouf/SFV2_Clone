/**
* @author Achraf ABOUL
* @created 20/02/2020
* @description Services class on Opportunity Object
*/
public class SM004_OpportunityServices {

    
    public static void setOpportunityFields(List<Opportunity> newOpportunitiesList) {

        for (Opportunity opp : newOpportunitiesList) {

            opp.LPCR_Ref_ContactFacturation__c = opp.Account.blng__BillToContact__c;
            opp.LPCR_Ref_ContactInscription__c = opp.Account.LPCR_ContactInscriptions__c;
            opp.LPCR_Ref_IdCompte__c = opp.Account.Id;
            opp.LPCR_Ref_RespADV__c = opp.Account.LPCR_ResponsableADV__c;
            opp.LPCR_Ref_RespServiceFam__c = opp.Account.LPCR_ResponsableServiceFamille__c;
        }
    }
    

    public static void setAccountStatus(Map<Id, Opportunity> newOpportunitiesMap, Map<Id, Opportunity> oldOpportunitiesMap ){
        List<Account> accountListNew = new List<Account>();
        
        Set<String> accountIds= UM003_TypeManager.getFieldsOfListObjects(newOpportunitiesMap.values(), 'AccountId');
        
        Map<String, String> accountStatutMap = new Map<String, String>(); 
        
        for(Opportunity opp : [SELECT AccountId, account.lpcr_statut__c
                               FROM Opportunity
                               WHERE AccountId IN: accountIds]){
                                   accountStatutMap.put(opp.AccountId, opp.Account.lpcr_statut__c);
                               }
        
        
        for(Opportunity opp: newOpportunitiesMap.values()){
            if(oldOpportunitiesMap.get(opp.Id).isWon != opp.isWon){
                if(opp.AccountId != null && accountStatutMap.containsKey(opp.AccountId) && accountStatutMap.get(opp.AccountId) != Label.LPCR_Client){
                    if(opp.isWon == true) accountListNew.add(new Account(id=opp.AccountId, lpcr_statut__c = Label.LPCR_Client));                         
                    else  accountListNew.add(new Account(id=opp.AccountId, lpcr_statut__c = Label.LPCR_Prospect));                    
                }}
        }
        EM004_OpportunityEntity cl = new EM004_OpportunityEntity();
        String methodName = 'setAccountStatus';
        cl.dmlExecuteRequest('update',  accountListNew, true, methodName, DM000_SObject.ProcessType.TRIGGER_SRC);
               
    }

    public static void setAccountStatus(Map<Id, Opportunity> newOpportunitiesMap)
    {
        List<Account> accountListNew = new List<Account>();
        
        Set<String> accountIds= UM003_TypeManager.getFieldsOfListObjects(newOpportunitiesMap.values(), 'AccountId');
        
        Map<String, String> accountStatutMap = new Map<String, String>(); 
        
        for(Opportunity opp : [SELECT AccountId, account.lpcr_statut__c
                               FROM Opportunity
                               WHERE AccountId IN: accountIds]){
                                   accountStatutMap.put(opp.AccountId, opp.Account.lpcr_statut__c);
                               }
        
        
        for(Opportunity opp: newOpportunitiesMap.values()){
            if(opp.AccountId != null && accountStatutMap.containsKey(opp.AccountId) && accountStatutMap.get(opp.AccountId) != Label.LPCR_Client){
                if(opp.isWon == true) accountListNew.add(new Account(id=opp.AccountId, lpcr_statut__c = Label.LPCR_Client));                         
                else  accountListNew.add(new Account(id=opp.AccountId, lpcr_statut__c = Label.LPCR_Prospect));                    
            }
        }
        EM004_OpportunityEntity cl = new EM004_OpportunityEntity();
        String methodName = 'setAccountStatus';
        cl.dmlExecuteRequest('update',  accountListNew, true, methodName, DM000_SObject.ProcessType.TRIGGER_SRC);
               
    }
}