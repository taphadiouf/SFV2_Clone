/**
* @author Achraf ABOUL
* @created 25/02/2020
* @description Trigger action handler on Contract Object
*/
public class SM005_ContractServices {
    
    public static void syncAccountsOnContracts(Map<Id, Contract> contractsMap){
        Set<Id> accountsIds = new Set<Id>();
        for(Contract eachContract : contractsMap.values()){
            if(eachContract.Status.equals('Signé')){
                accountsIds.add(eachContract.SBQQ__Opportunity__c);
            }
        }
        for(Account eachOpp : EM005_AccountEntity.getAccsByIds(accountsIds)){
            
        }
    }
    public static void syncOpportunitiesOnContracts(Map<Id, Contract> contractsMap){
        Set<Id> opportunitiesIds = new Set<Id>();
        for(Contract eachContract : contractsMap.values()){
            if(eachContract.Status.equals('Signé')){
                opportunitiesIds.add(eachContract.SBQQ__Opportunity__c);
            }
        }
        for(Opportunity eachOpp : EM004_OpportunityEntity.getOppsByIds(opportunitiesIds)){
            
        }
    }
}