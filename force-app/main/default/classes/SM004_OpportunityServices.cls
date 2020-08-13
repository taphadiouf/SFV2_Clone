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
            if(
                opp.AccountId != null 
                && !setAccountIds.contains(opp.AccountId)
                && opp.IsWon != oldOpportunitiesMap.get(opp.id).IsWon
                ){
                setAccountIds.add(opp.AccountId);
                if( opp.IsWon == true){
                    accountList.add(new Account(id=opp.AccountId, lpcr_statut__c = Label.LPCR_Client));
                }
                else{
                    accountList.add(new Account(id=opp.AccountId, lpcr_statut__c = Label.LPCR_Prospect));
                }
            }
        }
        update accountList;
    }
    public static void setAccountStatus(Map<Id, Opportunity> newOpportunitiesMap){
        List<Account> accountList = new List<Account>();
        Set<Id> setAccountIds = new Set<Id>();
        for(Opportunity opp: newOpportunitiesMap.values()){
            if(opp.AccountId != null && !setAccountIds.contains(opp.AccountId) ){
                setAccountIds.add(opp.AccountId);
                if(opp.IsWon == true){
                    accountList.add(new Account(id=opp.AccountId, lpcr_statut__c = Label.LPCR_Client));   
                }
                else{
                    accountList.add(new Account(id=opp.AccountId, lpcr_statut__c = Label.LPCR_Prospect));
                }
            }
        }
        update accountList;
    }
}