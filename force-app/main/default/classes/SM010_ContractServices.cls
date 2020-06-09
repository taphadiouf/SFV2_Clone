/**
* @author Ayoub Ouarti
* @created 23/03/2020
* @description Service class for Contract Object
* @Updated By Achraf ABOUL(aaboul@salesforce.com) 08/05/2020
*/
public class SM010_ContractServices {
    
    /**
* @Author Ayoub Ouarti
* @Created 23/03/2020
* @Description methode setContractFields to set Contract fields from Quote before Insert
* @Inputs List<Contract> contracts
*/
    public static void setContractFields(List<Contract> contracts){
        Pad.log('SM010_ContractServices','setContractFields(List<Contract> contracts)','contracts size '+contracts.size());

        Set<String> quoteIds = UM003_TypeManager.getFieldsOfListObjects(contracts,'SBQQ__Quote__c');
        Map<Id,SBQQ__Quote__c> quoteMap = new  Map<Id,SBQQ__Quote__c>([SELECT Id,LPCR_TypeFacturation__c,SBQQ__BillingFrequency__c,LPCR_IndexationConvenue__c,LPCR_MasterDevis__c,LPCR_RenouvellementConvenu__c,LPCR_DateDebut__c,LPCR_DateFin__c,LPCR_ChiffreAffaire__c, LPCR_MethodeRenouvellement__c,SBQQ__RenewalUpliftRate__c,LPCR_TypeEntreprise__c, LPCR_ContratEntreprise__c , recordtype.name, LPCR_PlanningEnfant__c  from SBQQ__Quote__c WHERE Id in :quoteIds]);
        
        for (Contract eachContract : contracts){
            if(quoteMap.containsKey(eachContract.SBQQ__Quote__c)){                
                eachContract =setContractFieldsFromQuoteHelper(eachContract,quoteMap.get(eachContract.SBQQ__Quote__c));
                Pad.log('SM010_ContractServices','setContractFields(List<Contract> contracts)','eachContract before insert'+eachContract);

            }
        }
    }
    
    
    /**
* @Author Ayoub Ouarti
* @Created 08/06/2020
* @Description methode setContractFields to set Contract fields from new Order's quote if the Order is getting changed before Update
* @Inputs Map<Id, Contract> oldContractMap,Map<Id, Contract> newContractMap
*/
    public static void setContractFields(Map<Id, Contract> oldContractMap,Map<Id, Contract> newContractMap){
        Pad.log('SM010_ContractServices','setContractFields(Map<Id, Contract> oldContractMap,Map<Id, Contract> newContractMap)','oldContractMap size '+oldContractMap.size(),'oldContractMap size '+newContractMap.size());

        Set<String> orderIds = new Set<String>();
        for(Contract eachContract : newContractMap.values()){
            if(eachContract.SBQQ__Order__c != oldContractMap.get(eachContract.Id).SBQQ__Order__c){
                orderIds.add(eachContract.SBQQ__Order__c);
            }
        }
        
        Map<Id,Order> mapOrders = new Map<Id,Order>([SELECT Id,SBQQ__Quote__c from Order WHERE Id in :orderIds ]);
        Set<String> quoteIds = UM003_TypeManager.getFieldsOfListObjects(mapOrders.values(),'SBQQ__Quote__c');
        Map<Id,SBQQ__Quote__c> quoteMap = new  Map<Id,SBQQ__Quote__c>([SELECT Id,LPCR_TypeFacturation__c,SBQQ__BillingFrequency__c,LPCR_IndexationConvenue__c,LPCR_MasterDevis__c,LPCR_RenouvellementConvenu__c,LPCR_DateDebut__c,LPCR_DateFin__c,LPCR_ChiffreAffaire__c, LPCR_MethodeRenouvellement__c,SBQQ__RenewalUpliftRate__c,LPCR_TypeEntreprise__c, LPCR_ContratEntreprise__c , recordtype.name, LPCR_PlanningEnfant__c  from SBQQ__Quote__c WHERE Id in :quoteIds]);
        
        //  Check if the Order is getting changed, If so , updating the fields 
        for(Contract eachContract : newContractMap.values()){
            eachContract=setContractFieldsFromQuoteHelper(eachContract,quoteMap.get(mapOrders.get(eachContract.SBQQ__Order__c).SBQQ__Quote__c));
        }
    }
    /**
* @Author Ayoub Ouarti
* @Created 08/06/2020
* @Description methode setContractFieldsFromQuoteHelper to help setting Contract fields from Quote
* @Inputs Contract contract , SBQQ__Quote__c quote
* Updated by Achraf Aboul adding new fields to set
*/
    public static Contract setContractFieldsFromQuoteHelper(Contract contract,SBQQ__Quote__c quote){
        Pad.log('SM010_ContractServices','setContractFieldsFromQuoteHelper(SBQQ__Quote__c quote)','quote : '+quote);

      
        contract.LPCR_IndexationConvenue__c = quote.LPCR_IndexationConvenue__c;
        
        contract.LPCR_TypeFacturation__c = quote.LPCR_TypeFacturation__c;
        
        contract.LPCR_BillingFrequency__c = quote.SBQQ__BillingFrequency__c;
        
        contract.LPCR_MasterDevis__c = quote.LPCR_MasterDevis__c;
        
        contract.LPCR_RenouvellementConvenu__c = quote.LPCR_RenouvellementConvenu__c;
        
        contract.LPCR_DateDebut__c = quote.LPCR_DateDebut__c;
        
        contract.LPCR_DateFin__c = quote.LPCR_DateFin__c;
        
        contract.LPCR_ChiffreAffaire__c = quote.LPCR_ChiffreAffaire__c;
        
        contract.LPCR_PlanningEnfant__c = quote.LPCR_PlanningEnfant__c;
        
        contract.LPCR_MethodeRenouvellement__c = quote.LPCR_MethodeRenouvellement__c;
        
        contract.LPCR_RenouvellementAutomatique__c = quote.SBQQ__RenewalUpliftRate__c == null ? false : true;
        
        if(quote.recordtype.name == Label.LPCR_ContratA) {
            contract.LPCR_ContratEntreprise__c = quote.LPCR_ContratEntreprise__c;
        }
        return contract;
    }
    
}