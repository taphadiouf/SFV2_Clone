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
* @Description methode setContractFields to set Contract fields from Quote, Order before Insert
* @Inputs List<Contract> contracts
*/
    public static void setContractFields(List<Contract> contracts){
        Pad.log('SM010_ContractServices','setContractFields(List<Contract> contracts)','contracts size '+contracts.size());
        
        Set<String> quoteIds = UM003_TypeManager.getFieldsOfListObjects(contracts,'SBQQ__Quote__c');
        Set<String> orderIds = UM003_TypeManager.getFieldsOfListObjects(contracts,'SBQQ__Order__c');

        Id referencementRecTypeId = EM003_RecordTypeEntity.getRecTypeIdByObjectAndName(Label.LPCR_Contract,Label.LPCR_Referencement);
        Id reservataireRecTypeId = EM003_RecordTypeEntity.getRecTypeIdByObjectAndName(Label.LPCR_Contract,Label.LPCR_Reservataire);
        Id acceuilRecTypeId = EM003_RecordTypeEntity.getRecTypeIdByObjectAndName(Label.LPCR_Contract,'Accueil');

        Map<Id,SBQQ__Quote__c> quoteMap = new  Map<Id,SBQQ__Quote__c>([SELECT Id,LPCR_BatchCommande__c,LPCR_InitAutoAvecDateDebut__c,LPCR_DureeContratJour__c,LPCR_TypeFacturation__c,SBQQ__BillingFrequency__c,LPCR_IndexationConvenue__c,LPCR_MasterDevis__c,LPCR_DateDebut__c,LPCR_DateFin__c,LPCR_ChiffreAffaire__c, LPCR_MethodeRenouvellement__c,SBQQ__RenewalUpliftRate__c,LPCR_TypeEntreprise__c , recordtype.DeveloperName, LPCR_PlanningEnfant__c, SBQQ__SalesRep__c,LPCR_ResponsableADV__c, LPCR_ResponsableServiceFamille__c, SBQQ__Type__c, recordtype.name, LPCR_ContractEntreprise__c  from SBQQ__Quote__c WHERE Id in :quoteIds]);
        Map<Id,Order> orderMap = new  Map<Id,Order>([SELECT id,LPCR_NouveauPlanFacture__c,LPCR_RenouvellementPlanFacture__c,SBQQ__Quote__r.SBQQ__Type__c,SBQQ__Quote__r.LPCR_NouveauPlanFacture__c ,SBQQ__Quote__r.LPCR_RenouvellementPlanFacture__c, SBQQ__Quote__c,SBQQ__Quote__r.LPCR_BatchCommande__c, LPCR_NumeroContrat__c from Order WHERE Id in :orderIds]);

        Set<String> quoteOrderIds = UM003_TypeManager.getFieldsOfListObjects(orderMap.values(),'SBQQ__Quote__c');
        Map<Id,SBQQ__Quote__c> quoteOrderMap = new  Map<Id,SBQQ__Quote__c>([SELECT Id,LPCR_NouveauPlanFacture__c,LPCR_RenouvellementPlanFacture__c, recordtype.DeveloperName, LPCR_PlanningEnfant__c, LPCR_EntiteJuridique__c , recordtype.name, LPCR_ContractEntreprise__c, LPCR_Creche__c, LPCR_TypeCreche__c, LPCR_ContactRepresentant1__c,LPCR_ContactRepresentant2__c, LPCR_CongesJours__c, LPCR_DureePreavisMois__c, LPCR_TypeAccueil__c, LPCR_Region__c, LPCR_CompteFacturation__c, LPCR_ContactEnfant__c, SBQQ__Type__c,LPCR_FraisDossier__c   from SBQQ__Quote__c WHERE Id in :quoteOrderIds]);
                String contractRTDevName;

        for (Contract eachContract : contracts){
            
            if(quoteMap.containsKey(eachContract.SBQQ__Quote__c)){
                // IS-1115 fixes added by saurabh
                contractRTDevName = quoteMap.get(eachContract.SBQQ__Quote__c).recordtype.DeveloperName;
                if(contractRTDevName == Label.LPCR_Referencement) {
                    if(quoteMap.get(eachContract.SBQQ__Quote__c).recordtype.name == Label.LPCR_Referencement || quoteMap.get(eachContract.SBQQ__Quote__c).recordtype.name == Label.LPCR_Referencement_Approuve ) {
                        if(quoteMap.get(eachContract.SBQQ__Quote__c).SBQQ__Type__c != 'Renewal'){
                            eachContract.LPCR_MasterDevis__c = quoteMap.get(eachContract.SBQQ__Quote__c).Id;
                        }else{
                            eachContract.LPCR_MasterDevis__c = quoteMap.get(eachContract.SBQQ__Quote__c).LPCR_MasterDevis__c;
                        }
                    }
                }


                if(orderMap.containsKey(eachContract.SBQQ__Order__c) &&
                   quoteOrderMap.containsKey(orderMap.get(eachContract.SBQQ__Order__c).SBQQ__Quote__c)){
                    if(quoteMap.containsKey(eachContract.SBQQ__Quote__c) && (quoteMap.get(eachContract.SBQQ__Quote__c).recordtype.DeveloperName == Label.LPCR_Referencement || quoteMap.get(eachContract.SBQQ__Quote__c).recordtype.DeveloperName == Label.LPCR_Referencement_Approuve)){
                        eachContract.LPCR_FraisDossier__c = quoteOrderMap.get(orderMap.get(eachContract.SBQQ__Order__c).SBQQ__Quote__c).LPCR_FraisDossier__c;                	
                       }
                       eachContract=setContractFieldsFromOrderQuoteMaper(eachContract,quoteOrderMap.get(orderMap.get(eachContract.SBQQ__Order__c).SBQQ__Quote__c));
                   }
                eachContract =setContractFieldsFromQuoteMaper(eachContract,quoteMap.get(eachContract.SBQQ__Quote__c));
                

                if(orderMap.containsKey(eachContract.SBQQ__Order__c)){
                    if(orderMap.get(eachContract.SBQQ__Order__c).SBQQ__Quote__c != null && orderMap.get(eachContract.SBQQ__Order__c).SBQQ__Quote__r.LPCR_BatchCommande__c != null ){
                        eachContract.LPCR_BatchCommande__c = orderMap.get(eachContract.SBQQ__Order__c).SBQQ__Quote__r.LPCR_BatchCommande__c;
                    }
                    eachContract.LPCR_NouveauPlanFacturation__c = orderMap.get(eachContract.SBQQ__Order__c).LPCR_NouveauPlanFacture__c;
                    eachContract.LPCR_RenouvellementPlanFacturation__c = orderMap.get(eachContract.SBQQ__Order__c).LPCR_RenouvellementPlanFacture__c;
                }
            }

            if(orderMap.containsKey(eachContract.SBQQ__Order__c)){
                if(eachContract.RecordTypeId == referencementRecTypeId|| eachContract.RecordTypeId == reservataireRecTypeId || eachContract.RecordTypeId == acceuilRecTypeId){
                    eachContract.LPCR_NumeroContrat__c = orderMap.get(eachContract.SBQQ__Order__c).LPCR_NumeroContrat__c;
                }
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
        Set<String> orderIds = UM003_TypeManager.getFieldsOfListObjects(newContractMap.values(),'SBQQ__Order__c');
        Map<Id,Order> mapOrders = new Map<Id,Order>([SELECT Id,RecordType.DeveloperName,LPCR_NouveauPlanFacture__c,LPCR_RenouvellementPlanFacture__c,SBQQ__Quote__c from Order WHERE Id in :orderIds ]);
        Set<String> quoteIds = UM003_TypeManager.getFieldsOfListObjects(mapOrders.values(),'SBQQ__Quote__c');
        Map<Id,SBQQ__Quote__c> quoteMap = new  Map<Id,SBQQ__Quote__c>([SELECT Id,LPCR_NouveauPlanFacture__c,LPCR_RenouvellementPlanFacture__c,LPCR_InitAutoAvecDateDebut__c,LPCR_DureeContratJour__c,LPCR_TypeFacturation__c,SBQQ__BillingFrequency__c,LPCR_IndexationConvenue__c,LPCR_MasterDevis__c,LPCR_DateDebut__c,LPCR_DateFin__c,LPCR_ChiffreAffaire__c, LPCR_MethodeRenouvellement__c,SBQQ__RenewalUpliftRate__c,LPCR_TypeEntreprise__c, recordtype.name, LPCR_PlanningEnfant__c,SBQQ__SalesRep__c,LPCR_ResponsableADV__c, LPCR_ResponsableServiceFamille__c, LPCR_EntiteJuridique__c, recordtype.DeveloperName, LPCR_ContractEntreprise__c, LPCR_Creche__c, LPCR_TypeCreche__c, LPCR_ContactRepresentant1__c, LPCR_ContactRepresentant2__c, LPCR_CongesJours__c, LPCR_DureePreavisMois__c, LPCR_TypeAccueil__c, LPCR_Region__c, LPCR_CompteFacturation__c, LPCR_ContactEnfant__c, SBQQ__Type__c ,LPCR_FraisDossier__c  from SBQQ__Quote__c WHERE Id in :quoteIds]);
        Map<String,Schema.RecordTypeInfo> mapContractRT = Schema.getGlobalDescribe().get('Contract').getDescribe().getRecordTypeInfosByDeveloperName();

        //  Check if the Order is getting changed, If so , updating the fields 
        for(Contract eachContract : newContractMap.values()){
            if(mapOrders.containsKey(eachContract.SBQQ__Order__c) && 
               quoteMap.containsKey(mapOrders.get(eachContract.SBQQ__Order__c).SBQQ__Quote__c)){
                 if(eachContract.SBQQ__Order__c != oldContractMap.get(eachContract.Id).SBQQ__Order__c){
                    if(quoteMap.get(mapOrders.get(eachContract.SBQQ__Order__c).SBQQ__Quote__c).recordtype.DeveloperName == Label.LPCR_Referencement || quoteMap.get(mapOrders.get(eachContract.SBQQ__Order__c).SBQQ__Quote__c).recordtype.DeveloperName == Label.LPCR_Referencement_Approuve) {
                        eachContract.LPCR_FraisDossier__c = quoteMap.get(mapOrders.get(eachContract.SBQQ__Order__c).SBQQ__Quote__c).LPCR_FraisDossier__c;
                       }
                     eachContract=setContractFieldsFromOrderQuoteMaper(eachContract,quoteMap.get(mapOrders.get(eachContract.SBQQ__Order__c).SBQQ__Quote__c));
                     eachContract=setContractFieldsFromQuoteMaper(eachContract,quoteMap.get(mapOrders.get(eachContract.SBQQ__Order__c).SBQQ__Quote__c));
                 }
               }
            if(mapOrders.containsKey(eachContract.SBQQ__Order__c) ){
                eachContract.LPCR_NouveauPlanFacturation__c = mapOrders.get(eachContract.SBQQ__Order__c).LPCR_NouveauPlanFacture__c;
                eachContract.LPCR_RenouvellementPlanFacturation__c = mapOrders.get(eachContract.SBQQ__Order__c).LPCR_RenouvellementPlanFacture__c;
                eachContract.RecordTypeId = mapContractRT.containsKey(mapOrders.get(eachContract.SBQQ__Order__c).RecordType.DeveloperName)? 
                    mapContractRT.get(mapOrders.get(eachContract.SBQQ__Order__c).RecordType.DeveloperName).getRecordTypeId(): eachContract.RecordTypeId;
            }
            
        }
}

    /**
* @Author Ayoub Ouarti
* @Created 08/06/2020
* @Description methode setContractFieldsFromQuoteMaper to help setting Contract fields from Quote
* @Inputs Contract contract , SBQQ__Quote__c quote
* Updated by Achraf Aboul adding new fields to set
* Updated by Hanae Makboub deleting some fields 
*/
    public static Contract setContractFieldsFromQuoteMaper(Contract contract,SBQQ__Quote__c quote){
        
        Pad.log('SM010_ContractServices','setContractFieldsFromQuoteMaper(SBQQ__Quote__c quote)','quote : '+quote);
        
        contract.LPCR_IndexationConvenue__c = quote.LPCR_IndexationConvenue__c;
        
        contract.LPCR_TypeFacturation__c = quote.LPCR_TypeFacturation__c;
        
        contract.LPCR_BillingFrequency__c = quote.SBQQ__BillingFrequency__c;
        
        contract.LPCR_DateDebut__c = quote.LPCR_DateDebut__c;
        
        contract.LPCR_DateFin__c = quote.LPCR_DateFin__c;
        
        contract.LPCR_ChiffreAffaire__c = quote.LPCR_ChiffreAffaire__c;
        
        if(quote.recordtype.DeveloperName == Label.LPCR_Referencement || quote.recordtype.DeveloperName == Label.LPCR_Referencement_Approuve || quote.recordtype.DeveloperName == Label.LPCR_Reservataire || quote.recordtype.DeveloperName == Label.LPCR_Reservataire_Approuve ) {
            contract.LPCR_MethodeRenouvellement__c = quote.LPCR_MethodeRenouvellement__c;
        }
        
        if(contract.LPCR_TypeCreche__c == 'MAC' && contract.EndDate != contract.LPCR_DateFin__c){
            contract.LPCR_RenouvellementAutomatique__c =true;
        }
        else if(contract.SBQQ__RenewalUpliftRate__c != null && 
                (contract.LPCR_MethodeRenouvellement__c == 'Tacite' ||
                 (contract.LPCR_MethodeRenouvellement__c != 'Tacite' && contract.EndDate != contract.LPCR_DateFin__c))){
                     contract.LPCR_RenouvellementAutomatique__c =true;
                 }
        
        contract.LPCR_DureeContratJour__c = quote.LPCR_DureeContratJour__c;
        
        contract.LPCR_InitAutoAvecDateDebut__c = quote.LPCR_InitAutoAvecDateDebut__c;

        contract.LPCR_Sales_Rep__c = quote.SBQQ__SalesRep__c;
        
        contract.LPCR_ResponsableADV__c = quote.LPCR_ResponsableADV__c;
        
        contract.LPCR_ResponsableServiceFamille__c = quote.LPCR_ResponsableServiceFamille__c;
        if(Trigger.IsInsert && Trigger.IsBefore){
            contract.LPCR_BatchCommande__c=quote.LPCR_BatchCommande__c;
        }
        return contract;
    }
    
    /**
* @Author Hanae Makboub
* @Created 30/06/2020
* @Description methode setContractFieldsFromOrderQuoteMaper to help setting Contract fields from Quote trough Order
* @Inputs Contract contract , SBQQ__Quote__c quote
*/    
    
    
    public static Contract setContractFieldsFromOrderQuoteMaper(Contract contract,SBQQ__Quote__c quote){
        contract.LPCR_CompteFacturation__c = quote.LPCR_CompteFacturation__c ;
        if(quote.recordtype.DeveloperName == Label.LPCR_ContratA || quote.recordtype.DeveloperName == Label.LPCR_Accueil_Approuve) {
            
            contract.LPCR_EntiteJuridique__c  = quote.LPCR_EntiteJuridique__c ;
            
            contract.LPCR_Creche__c = quote.LPCR_Creche__c ;
            
            contract.LPCR_Region__c  = quote.LPCR_Region__c ;
            
            contract.LPCR_ContactEnfant__c = quote.LPCR_ContactEnfant__c ;
            
            System.debug('##!:' + quote.LPCR_TypeCreche__c);
            
            contract.LPCR_TypeCreche__c = quote.LPCR_TypeCreche__c ;
            
            contract.LPCR_PlanningEnfant__c = quote.LPCR_PlanningEnfant__c;
            
            contract.LPCR_ContractEntreprise__c = quote.LPCR_ContractEntreprise__c;
            
            contract.LPCR_ContactRepresentant1__c   = quote.LPCR_ContactRepresentant1__c  ;
            
            contract.LPCR_ContactRepresentant2__c  = quote.LPCR_ContactRepresentant2__c  ;
            
            contract.LPCR_CongesJours__c = quote.LPCR_CongesJours__c ;
            
            contract.LPCR_DureePreavisMois__c = quote.LPCR_DureePreavisMois__c ;
            
            contract.LPCR_TypeAccueil__c  = quote.LPCR_TypeAccueil__c  ;                
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