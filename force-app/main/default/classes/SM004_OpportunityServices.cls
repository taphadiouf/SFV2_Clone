/**
* @author Achraf ABOUL
* @created 20/02/2020
* @description Services class on Opportunity Object
*/
public class SM004_OpportunityServices {

    public static void setOpportunityFields(List<Opportunity> newOpportunitiesList) {

    PAD.log('SM004_OpportunityServices', 'setOpportunityFields', 'newOpportunitiesList');

    Set<String> accountIds= UM003_TypeManager.getFieldsOfListObjects(newOpportunitiesList, 'AccountId');
    Map<ID, Account> mapAccount = new Map<ID, Account>([SELECT Id, Name, blng__BillToContact__c, LPCR_ContactInscriptions__c, 
                                                        LPCR_ResponsableADV__c, LPCR_ResponsableServiceFamille__c 
                                                        FROM Account where id in :accountIds]);

        for (Opportunity opp : newOpportunitiesList) {

            if (mapAccount.get(opp.AccountId) != null) {

                if (mapAccount.get(opp.AccountId).blng__BillToContact__c != null)
                    opp.LPCR_Ref_ContactFacturation__c = mapAccount.get(opp.AccountId).blng__BillToContact__c;
                if (mapAccount.get(opp.AccountId).LPCR_ContactInscriptions__c != null)
                    opp.LPCR_Ref_ContactInscription__c = mapAccount.get(opp.AccountId).LPCR_ContactInscriptions__c;
                if (mapAccount.get(opp.AccountId).Id != null)
                    opp.LPCR_Ref_IdCompte__c = mapAccount.get(opp.AccountId).Id;
                if (mapAccount.get(opp.AccountId).LPCR_ResponsableADV__c != null)
                    opp.LPCR_Ref_RespADV__c = mapAccount.get(opp.AccountId).LPCR_ResponsableADV__c;
                if (mapAccount.get(opp.AccountId).LPCR_ResponsableServiceFamille__c != null)
                    opp.LPCR_Ref_RespServiceFam__c = mapAccount.get(opp.AccountId).LPCR_ResponsableServiceFamille__c;

                PAD.log('SM004_OpportunityServices', 'setOpportunityFields', 'opp.Account:' + opp.Account);
                PAD.log('SM004_OpportunityServices', 'setOpportunityFields', 'opp.Account:' + opp.AccountId);
            }
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