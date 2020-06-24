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
        Set<String> orderIds = UM003_TypeManager.getFieldsOfListObjects(contracts,'SBQQ__Order__c');
        Map<Id,SBQQ__Quote__c> quoteMap = new  Map<Id,SBQQ__Quote__c>([SELECT Id,LPCR_InitAutoAvecDateDebut__c,LPCR_DureeContratJour__c,LPCR_TypeFacturation__c,SBQQ__BillingFrequency__c,LPCR_IndexationConvenue__c,LPCR_MasterDevis__c,LPCR_DateDebut__c,LPCR_DateFin__c,LPCR_ChiffreAffaire__c, LPCR_MethodeRenouvellement__c,SBQQ__RenewalUpliftRate__c,LPCR_TypeEntreprise__c, LPCR_ContratEntreprise__c , recordtype.name, LPCR_PlanningEnfant__c, SBQQ__SalesRep__c,LPCR_ResponsableADV__c, LPCR_ResponsableServiceFamille__c, SBQQ__Type__c  from SBQQ__Quote__c WHERE Id in :quoteIds]);
        Map<Id,Order> orderMap = new  Map<Id,Order>([SELECT id,SBQQ__Quote__c,SBQQ__Quote__r.LPCR_BatchCommande__c from Order WHERE Id in :orderIds]);
        
        for (Contract eachContract : contracts){

            // fix merge by ayoub to add akshayeSF code  
            if(orderMap.containsKey(eachContract.SBQQ__Order__c)){
                if(orderMap.get(eachContract.SBQQ__Order__c).SBQQ__Quote__c != null && orderMap.get(eachContract.SBQQ__Order__c).SBQQ__Quote__r.LPCR_BatchCommande__c != null ){
                    eachContract.LPCR_BatchCommande__c = orderMap.get(eachContract.SBQQ__Order__c).SBQQ__Quote__r.LPCR_BatchCommande__c;
                }
            }

            if(quoteMap.containsKey(eachContract.SBQQ__Quote__c)){
                // IS-1115 fixes added by saurabh
                if(quoteMap.get(eachContract.SBQQ__Quote__c).recordtype.name == Label.LPCR_Referencement) {
                    if(quoteMap.get(eachContract.SBQQ__Quote__c).SBQQ__Type__c != 'Renewal'){
                        eachContract.LPCR_MasterDevis__c = quoteMap.get(eachContract.SBQQ__Quote__c).Id;
                    }else{
                        eachContract.LPCR_MasterDevis__c = quoteMap.get(eachContract.SBQQ__Quote__c).LPCR_MasterDevis__c;
                    }                   
                }                
                eachContract =setContractFieldsFromQuoteMaper(eachContract,quoteMap.get(eachContract.SBQQ__Quote__c));
            }
        }
    }
    public static void setTypeEnregistrement(List<Contract> contracts){
        Set<Id> orderIdsSet = new Set<Id>();
        for(Contract eachContract : contracts){
            orderIdsSet.add(eachContract.SBQQ__Order__c);
        }
        //Map : Id=>Order (Parent records of the current contracts)
        Map<Id, Order> parentOrdersMap = new Map<Id, Order>([SELECT Id, LPCR_TypeEnregistrement__c FROM Order WHERE Id IN :orderIdsSet]);
        for(Contract eachContract : contracts){
            if(parentOrdersMap.containsKey(eachContract.SBQQ__Order__c)){
                eachContract.LPCR_TypeEnregistrement__c = parentOrdersMap.get(eachContract.SBQQ__Order__c).LPCR_TypeEnregistrement__c;
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
        Map<Id,SBQQ__Quote__c> quoteMap = new  Map<Id,SBQQ__Quote__c>([SELECT Id,LPCR_InitAutoAvecDateDebut__c,LPCR_DureeContratJour__c,LPCR_TypeFacturation__c,SBQQ__BillingFrequency__c,LPCR_IndexationConvenue__c,LPCR_MasterDevis__c,LPCR_DateDebut__c,LPCR_DateFin__c,LPCR_ChiffreAffaire__c, LPCR_MethodeRenouvellement__c,SBQQ__RenewalUpliftRate__c,LPCR_TypeEntreprise__c, LPCR_ContratEntreprise__c , recordtype.name, LPCR_PlanningEnfant__c,SBQQ__SalesRep__c,LPCR_ResponsableADV__c, LPCR_ResponsableServiceFamille__c  from SBQQ__Quote__c WHERE Id in :quoteIds]);
        
        //  Check if the Order is getting changed, If so , updating the fields 
        for(Contract eachContract : newContractMap.values()){
            if(mapOrders.containsKey(eachContract.SBQQ__Order__c) && 
               quoteMap.containsKey(mapOrders.get(eachContract.SBQQ__Order__c).SBQQ__Quote__c)){
                eachContract=setContractFieldsFromQuoteMaper(eachContract,quoteMap.get(mapOrders.get(eachContract.SBQQ__Order__c).SBQQ__Quote__c));
            }
        }
    }
/**
* @Author Ayoub Ouarti
* @Created 08/06/2020
* @Description methode setContractFieldsFromQuoteMaper to help setting Contract fields from Quote
* @Inputs Contract contract , SBQQ__Quote__c quote
* Updated by Achraf Aboul adding new fields to set
*/
    public static Contract setContractFieldsFromQuoteMaper(Contract contract,SBQQ__Quote__c quote){
        Pad.log('SM010_ContractServices','setContractFieldsFromQuoteMaper(SBQQ__Quote__c quote)','quote : '+quote);

      
        contract.LPCR_IndexationConvenue__c = quote.LPCR_IndexationConvenue__c;
        
        contract.LPCR_TypeFacturation__c = quote.LPCR_TypeFacturation__c;
        
        contract.LPCR_BillingFrequency__c = quote.SBQQ__BillingFrequency__c;
        
        contract.LPCR_DateDebut__c = quote.LPCR_DateDebut__c;
        
        contract.LPCR_DateFin__c = quote.LPCR_DateFin__c;
        
        contract.LPCR_ChiffreAffaire__c = quote.LPCR_ChiffreAffaire__c;
        
        contract.LPCR_PlanningEnfant__c = quote.LPCR_PlanningEnfant__c;
        
        contract.LPCR_MethodeRenouvellement__c = quote.LPCR_MethodeRenouvellement__c;
        
        contract.LPCR_RenouvellementAutomatique__c = quote.SBQQ__RenewalUpliftRate__c == null ? false : true;
        
        contract.LPCR_DureeContratJour__c = quote.LPCR_DureeContratJour__c;
        
         contract.LPCR_InitAutoAvecDateDebut__c = quote.LPCR_InitAutoAvecDateDebut__c;
        
        
        contract.LPCR_Sales_Rep__c = quote.SBQQ__SalesRep__c;
        
        contract.LPCR_ResponsableADV__c = quote.LPCR_ResponsableADV__c;
        
        contract.LPCR_ResponsableServiceFamille__c = quote.LPCR_ResponsableServiceFamille__c;

        if(quote.recordtype.name == Label.LPCR_ContratA) {
            contract.LPCR_ContractEntreprise__c = quote.LPCR_ContractEntreprise__c;
        }
        return contract;
    }
    
    public static void setOrderFields(Map<Id, Contract> newContractMap, Map<Id, Contract> oldContractMap){
        Map<Id,Contract> contractMap = new Map<Id,Contract>();
        Set<Id> orderIds = new Set<Id>();
        List<Order> orderList = new List<Order>();
        for(Contract eachNewContract : newContractMap.values()){ //get all contracts where LPCR_batchCommande is changed
            if(eachNewContract.LPCR_BatchCommande__c != oldContractMap.get(eachNewContract.Id).LPCR_BatchCommande__c) {
                contractMap.put(eachNewContract.Id, eachNewContract);
            }
        }
        //get order items and create a list of orders to be updated
        for(OrderItem orderItem:[Select id, orderId, SBQQ__Contract__c from orderItem where SBQQ__Contract__c in:contractMap.keyset()]){
            if(!OrderIds.contains(orderItem.OrderId)){
                Order order= new Order(Id = orderItem.OrderId);
                order.blng__InvoiceBatch__c = contractMap.get(orderItem.SBQQ__Contract__c).LPCR_BatchCommande__c;
                orderList.add(order);
                OrderIds.add(orderItem.OrderId);
            }
        }

        if(orderList.size()>0){
            update orderList;
        }

    }

    //added by saurabh
    public static void setOrderItemFields(Map<Id, Contract> newContractMap, Map<Id, Contract> oldContractMap){
        Map<Id,Contract> contractMap = new Map<Id,Contract>();
        Set<Id> orderItemIds = new Set<Id>();
        List<OrderItem> orderItemList = new List<OrderItem>();
        for(Contract eachNewContract : newContractMap.values()){ //get all contracts where Uplift is changed
            if(eachNewContract.SBQQ__RenewalUpliftRate__c != oldContractMap.get(eachNewContract.Id).SBQQ__RenewalUpliftRate__c) {
                contractMap.put(eachNewContract.Id, eachNewContract);
            }
        }
        //get order items to be updated
        for(OrderItem orderItem:[Select id, orderId, SBQQ__Contract__c from orderItem where SBQQ__Contract__c in:contractMap.keyset()]){
            orderItem.LPCR_BillingPlanProcessment__c = false;
            orderItemIds.add(orderItem.id);
            orderItemList.add(orderItem);
        }

        if(orderItemList.size() > 0){
            update orderItemList;
        }

        List<LPCR_PlanFacturation__c> delBillingPlanList = [select id, LPCR_OrderItem__c from LPCR_PlanFacturation__c where LPCR_OrderItem__c IN: orderItemIds ];

        if(delBillingPlanList.size() > 0){
            delete delBillingPlanList;
        }       

    }

}