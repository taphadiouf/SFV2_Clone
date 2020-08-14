/**
* @author Achraf ABOUL
* @created 20/02/2020
* @description Services class on Opportunity Object
*/
public class SM004_OpportunityServices {
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
        update accountListNew;
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
        update accountListNew;
    }
}