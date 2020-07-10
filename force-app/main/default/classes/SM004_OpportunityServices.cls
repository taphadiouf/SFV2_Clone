/**
* @author Achraf ABOUL
* @created 20/02/2020
* @description Services class on Opportunity Object
*/
public class SM004_OpportunityServices {
    public static void setAccountStatus(Map<Id, Opportunity> newOpportunitiesMap, Map<Id, Opportunity> oldOpportunitiesMap ){
        List<Account> accountList = new List<Account>();
        Set<Id> setAccountIds = new Set<Id>();
        for(Opportunity opp: newOpportunitiesMap.values()){
            if(opp.IsWon == true && oldOpportunitiesMap.get(opp.id).IsWon == false){
                if(!setAccountIds.contains(opp.AccountId) && opp.AccountId != null){
                    accountList.add(new Account(id=opp.AccountId, lpcr_statut__c = 'Client'));
                    setAccountIds.add(opp.AccountId);
                }
                
            }
        }
        update accountList;
        
    }
}