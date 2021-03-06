/**
* @author Ayoub Ouarti
* @created 23/03/2020
* @description Service class for Contract Object
* @Updated By Achraf ABOUL(aaboul@salesforce.com) 08/05/2020
*/
public class SM010_ContractServices {
    public static Id referencementRecTypeId = EM003_RecordTypeEntity.getRecTypeIdByObjectAndName('Contract',Label.LPCR_Referencement);
    public static Id reservataireRecTypeId = EM003_RecordTypeEntity.getRecTypeIdByObjectAndName('Contract', Label.LPCR_Reservataire);
    public static Id accueilRecTypeId = EM003_RecordTypeEntity.getRecTypeIdByObjectAndName('Contract',Label.LPCR_ContratA);
    public static Id entrepiseRecTypeId = EM003_RecordTypeEntity.getRecTypeIdByObjectAndName('Account','Entreprise');
    /**
* @Author Ayoub Ouarti
* @Created 23/03/2020
* @Description methode setContractFields to set Contract fields from Quote, Order before Insert
* @Inputs List<Contract> contracts
*/
    public static void setContractFields(List<Contract> contracts){
        Pad.log('SM010_ContractServices','setContractFields(List<Contract> contracts)','contracts size '+contracts.size());
        List<Id> B2BContractRecordTypeIds = new List<Id>{EM003_RecordTypeEntity.getRecTypeIdByObjectAndName(Label.LPCR_Contract, Label.LPCR_Referencement),
        EM003_RecordTypeEntity.getRecTypeIdByObjectAndName(Label.LPCR_Contract, Label.LPCR_Reservataire)};
            
            
        Set<String> quoteIds = UM003_TypeManager.getFieldsOfListObjects(contracts,'SBQQ__Quote__c');
        Set<String> orderIds = UM003_TypeManager.getFieldsOfListObjects(contracts,'SBQQ__Order__c');

        Id referencementRecTypeId = EM003_RecordTypeEntity.getRecTypeIdByObjectAndName(Label.LPCR_Contract,Label.LPCR_Referencement);
        Id reservataireRecTypeId = EM003_RecordTypeEntity.getRecTypeIdByObjectAndName(Label.LPCR_Contract,Label.LPCR_Reservataire);
        Id acceuilRecTypeId = EM003_RecordTypeEntity.getRecTypeIdByObjectAndName(Label.LPCR_Contract,'Accueil');

        Map<Id,SBQQ__Quote__c> quoteMap = new  Map<Id,SBQQ__Quote__c>([SELECT Id,LPCR_BatchCommande__c,LPCR_InitAutoAvecDateDebut__c,LPCR_DureeContratJour__c,LPCR_TypeFacturation__c,SBQQ__BillingFrequency__c,LPCR_IndexationConvenue__c,LPCR_MasterDevis__c,LPCR_DateDebut__c,LPCR_DateFin__c,LPCR_ChiffreAffaire__c, LPCR_MethodeRenouvellement__c,SBQQ__RenewalUpliftRate__c,LPCR_TypeEntreprise__c , recordtype.DeveloperName, LPCR_PlanningEnfant__c, SBQQ__SalesRep__c,LPCR_ResponsableADV__c, LPCR_ResponsableServiceFamille__c, SBQQ__Type__c, recordtype.name, LPCR_ContractEntreprise__c,LPCR_DateRevisionPrix__c  from SBQQ__Quote__c WHERE Id in :quoteIds]);
        Map<Id,Order> orderMap = new  Map<Id,Order>([SELECT id,LPCR_NouveauPlanFacture__c,LPCR_RenouvellementPlanFacture__c,SBQQ__Quote__r.SBQQ__Type__c,SBQQ__Quote__r.LPCR_NouveauPlanFacture__c ,SBQQ__Quote__r.LPCR_RenouvellementPlanFacture__c, SBQQ__Quote__c,SBQQ__Quote__r.LPCR_BatchCommande__c, LPCR_NumeroContrat__c from Order WHERE Id in :orderIds]);

        Set<String> quoteOrderIds = UM003_TypeManager.getFieldsOfListObjects(orderMap.values(),'SBQQ__Quote__c');

        Map<Id,SBQQ__Quote__c> quoteOrderMap = new  Map<Id,SBQQ__Quote__c>([SELECT Id,LPCR_NouveauPlanFacture__c,LPCR_RenouvellementPlanFacture__c, recordtype.DeveloperName, LPCR_PlanningEnfant__c, LPCR_EntiteJuridique__c , recordtype.name, LPCR_ContractEntreprise__c, LPCR_Creche__c, LPCR_TypeCreche__c, LPCR_ContactRepresentant1__c,LPCR_ContactRepresentant2__c, LPCR_CongesJours__c, LPCR_DureePreavisMois__c, LPCR_TypeAccueil__c, LPCR_Region__c, LPCR_CompteFacturation__c, LPCR_ContactEnfant__c, SBQQ__Type__c,LPCR_FraisDossier__c   from SBQQ__Quote__c WHERE Id in :quoteOrderIds]);
        String contractRTDevName;
        List<String> accountIds = new List<String>();
        List<String> accountEntrpriseIds = new List<String>();
        for (Contract eachContract : contracts){
            if(B2BContractRecordTypeIds.contains(eachContract.RecordTypeId)){
                accountIds.add( eachContract.AccountId );
            }
            if(quoteMap.containsKey(eachContract.SBQQ__Quote__c)){
                // IS-1115 fixes added by saurabh
                contractRTDevName = quoteMap.get(eachContract.SBQQ__Quote__c).recordtype.DeveloperName;

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
                    eachContract.LPCR_NumeroContrat__c = orderMap.get(eachContract.SBQQ__Order__c).LPCR_NumeroContrat__c;
            }
            
            if(eachContract.StartDate <= system.today() && eachContract.EndDate >= system.today()){
                accountEntrpriseIds.add(eachContract.AccountId);
            }
        }
        
        if(accountIds.size()>0){  
            List<Account> accounts = [SELECT Id,LPCR_ProcessRevenuCascade__c FROM Account WHERE Id IN :accountIds];
            for(Account eachAcc : accounts){
                eachAcc.LPCR_ProcessRevenuCascade__c = true;
            }
            update accounts;
        }
        
        if(accountEntrpriseIds.size()>0){
            List<Account> entrepriseAccounts = [SELECT Id,LPCR_Actif__c, RecordTypeId FROM Account WHERE Id IN :accountEntrpriseIds And RecordTypeId =: entrepiseRecTypeId ];
            for(Account eachAcc : entrepriseAccounts){
                eachAcc.LPCR_Actif__c = true;
            }
            update entrepriseAccounts;
        }
    }
    // added by saurabh IS-1449
    public static void afterInsertUpdateContractFields(List<Contract> contracts){
        Pad.log('SM010_ContractServices','afterInsertUpdateContractFields(List<Contract> contracts)','contracts size  '+ contracts.size());
        Set<Id> contractIds = UM003_TypeManager.getIdsOfListObjects(contracts);
        // call future method for populate LPCR_NumeroContrat__c field value on contract from order
        updateContractNumeroContrat(contractIds);
    }
    
    // added by saurabh IS-1449
    @future(Callout=true)
    public static void updateContractNumeroContrat(Set<Id> contractIds){
        Pad.log('SM010_ContractServices','updateContractNumeroContrat(Set<Id> contractIds)','contractIds  '+ contractIds);
        Set<Id> orderIds = new Set<Id>();
        for(Contract eachContract : [select Id, SBQQ__Order__c from Contract where Id in : contractIds]){
            if(eachContract.SBQQ__Order__c != null){
                orderIds.add(eachContract.SBQQ__Order__c);
            }            
        }  
        Pad.log('SM010_ContractServices','updateContractNumeroContrat(Set<Id> contractIds)','orderIds  '+ orderIds);
        
        Map<Id,Order> orderMap = new  Map<Id,Order>([SELECT id, LPCR_NumeroContrat__c from Order WHERE Id in: orderIds]);	
        List<Contract> updateContractList = new List<Contract>();
        for (Contract eachContract : [select Id, SBQQ__Order__c,LPCR_NumeroContrat__c from Contract where Id in : contractIds]){
            if(orderMap.containsKey(eachContract.SBQQ__Order__c)){
                eachContract.LPCR_NumeroContrat__c = orderMap.get(eachContract.SBQQ__Order__c).LPCR_NumeroContrat__c;
            	updateContractList.add(eachContract);
            }
        }
        if(updateContractList.size() > 0){
            update updateContractList; 
        }       
    }
    
    /* deleted in IS-1165
    public static void setTypeEnregistrement(List<Contract> contracts){
        Set<Id> orderIdsSet = new Set<Id>();
        for(Contract eachContract : contracts){
            orderIdsSet.add(eachContract.SBQQ__Order__c);
        }
         Set<String> orderIds = UM003_TypeManager.getFieldsOfListObjects(contracts,'SBQQ__Order__c');

            if(orderMap.containsKey(eachContract.SBQQ__Order__c)){
                    eachContract.LPCR_NumeroContrat__c = orderMap.get(eachContract.SBQQ__Order__c).LPCR_NumeroContrat__c;
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
        
        List<Id> B2BContractRecordTypeIds = new List<Id>{EM003_RecordTypeEntity.getRecTypeIdByObjectAndName(Label.LPCR_Contract, Label.LPCR_Referencement),
        EM003_RecordTypeEntity.getRecTypeIdByObjectAndName(Label.LPCR_Contract, Label.LPCR_Reservataire)};
        List<String> accountIds = new List<String>();
        List<String> accountEntrpriseIds = new List<String>();
               Set<String> orderIds = UM003_TypeManager.getFieldsOfListObjects(newContractMap.values(),'SBQQ__Order__c');
        Map<Id,Order> mapOrders = new Map<Id,Order>([SELECT Id,Type,RecordType.DeveloperName,LPCR_NouveauPlanFacture__c,LPCR_RenouvellementPlanFacture__c,SBQQ__Quote__c from Order WHERE Id in :orderIds ]);

        for(Contract eachContract : newContractMap.values()){
            if(eachContract.SBQQ__Order__c != oldContractMap.get(eachContract.Id).SBQQ__Order__c || eachContract.CreatedDate > System.now().addMinutes(-1) ){
                
                if(B2BContractRecordTypeIds.contains(eachContract.RecordTypeId)){
                    accountIds.add( eachContract.AccountId );
                }
            }
            
            if(eachContract.StartDate <= system.today() && eachContract.EndDate >= system.today()){
                accountEntrpriseIds.add(eachContract.AccountId);
            }
        }
        if(accountIds.size()>0){  
            List<Account> accounts = [SELECT Id,LPCR_ProcessRevenuCascade__c FROM Account WHERE Id IN :accountIds];
            for(Account eachAcc : accounts){
                eachAcc.LPCR_ProcessRevenuCascade__c = true;
            }
            update accounts;
        }
        
        if(accountEntrpriseIds.size()>0){
            List<Account> entrepriseAccounts = [SELECT Id,LPCR_Actif__c, RecordTypeId FROM Account WHERE Id IN :accountEntrpriseIds And RecordTypeId =: entrepiseRecTypeId ];
            for(Account eachAcc : entrepriseAccounts){
                eachAcc.LPCR_Actif__c = true;
            }
            update entrepriseAccounts;
        }
     
      
        Set<String> quoteIds = UM003_TypeManager.getFieldsOfListObjects(mapOrders.values(),'SBQQ__Quote__c');
        Map<Id,SBQQ__Quote__c> quoteMap = new  Map<Id,SBQQ__Quote__c>([SELECT Id,LPCR_DateFinMaxQuoteLine__c,LPCR_NouveauPlanFacture__c,LPCR_RenouvellementPlanFacture__c,LPCR_InitAutoAvecDateDebut__c,LPCR_DureeContratJour__c,LPCR_TypeFacturation__c,SBQQ__BillingFrequency__c,LPCR_IndexationConvenue__c,LPCR_MasterDevis__c,LPCR_DateDebut__c,LPCR_DateFin__c,LPCR_ChiffreAffaire__c, LPCR_MethodeRenouvellement__c,SBQQ__RenewalUpliftRate__c,LPCR_TypeEntreprise__c, recordtype.name, LPCR_PlanningEnfant__c,SBQQ__SalesRep__c,LPCR_ResponsableADV__c, LPCR_ResponsableServiceFamille__c, LPCR_EntiteJuridique__c, recordtype.DeveloperName, LPCR_ContractEntreprise__c, LPCR_Creche__c, LPCR_TypeCreche__c, LPCR_ContactRepresentant1__c, LPCR_ContactRepresentant2__c, LPCR_CongesJours__c, LPCR_DureePreavisMois__c, LPCR_TypeAccueil__c, LPCR_Region__c, LPCR_CompteFacturation__c, LPCR_ContactEnfant__c, SBQQ__Type__c ,LPCR_FraisDossier__c,LPCR_DateRevisionPrix__c,LPCR_Indexation__c  from SBQQ__Quote__c WHERE Id in :quoteIds]);
        Map<String,Schema.RecordTypeInfo> mapContractRT = Schema.getGlobalDescribe().get('Contract').getDescribe().getRecordTypeInfosByDeveloperName();

        //  Check if the Order is getting changed, If so , updating the fields 
        for(Contract eachContract : newContractMap.values()){
            
            if( mapOrders.containsKey(eachContract.SBQQ__Order__c) && quoteMap.containsKey(mapOrders.get(eachContract.SBQQ__Order__c).SBQQ__Quote__c)){        
                 
                if(eachContract.SBQQ__Order__c != oldContractMap.get(eachContract.Id).SBQQ__Order__c){
                    
                    if (mapOrders.get(eachContract.SBQQ__Order__c).RecordType.DeveloperName == Label.LPCR_Referencement) {

                        eachContract.LPCR_DateFinMaxQuoteLine__c = quoteMap.get(mapOrders.get(eachContract.SBQQ__Order__c).SBQQ__Quote__c).LPCR_DateFinMaxQuoteLine__c;

                        Integer yearDateFinMaxQuoteLine = date.valueOf(eachContract.LPCR_DateFinMaxQuoteLine__c).year();
                        Integer yearContractEndDate = date.valueOf(eachContract.Enddate).year();

                        if (yearDateFinMaxQuoteLine > yearContractEndDate) {

                            eachContract.Enddate = Date.newInstance(yearContractEndDate, 12, 31);
                        }
                        else if (yearDateFinMaxQuoteLine == yearContractEndDate) {

                            if (eachContract.LPCR_DateFinMaxQuoteLine__c > eachContract.Enddate) {

                                eachContract.Enddate =  eachContract.LPCR_DateFinMaxQuoteLine__c;
                            }
                        }
                    }
                    
                    
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
                
                	if(eachContract.recordtypeId == accueilRecTypeId && eachContract.EndDate != eachContract.LPCR_DateFin__c){
                        eachContract.LPCR_RenouvellementAutomatique__c =true;
                    }
                    else if(    eachContract.SBQQ__RenewalUpliftRate__c != null 
                                && 
                                (   eachContract.LPCR_MethodeRenouvellement__c == 'Tacite' 
                                    ||
                                    (eachContract.RecordTypeId == reservataireRecTypeId && eachContract.LPCR_MethodeRenouvellement__c != 'Tacite' && eachContract.EndDate != eachContract.LPCR_DateFin__c)
                                    ||
                                    (eachContract.RecordTypeId == referencementRecTypeId && eachContract.LPCR_MethodeRenouvellement__c != 'Tacite' && eachContract.EndDate != eachContract.LPCR_DateFinMaxQuoteLine__c)
                                )
                            ){
                                 eachContract.LPCR_RenouvellementAutomatique__c =true;
                             }
            }
            if(quoteMap.containsKey(eachContract.SBQQ__Quote__c)){
                if(eachContract.RecordTypeId == referencementRecTypeId) {

                        if(quoteMap.get(eachContract.SBQQ__Quote__c).SBQQ__Type__c != 'Renewal'){
                            eachContract.LPCR_MasterDevis__c = quoteMap.get(eachContract.SBQQ__Quote__c).Id;
                        }else{
                            eachContract.LPCR_MasterDevis__c = quoteMap.get(eachContract.SBQQ__Quote__c).LPCR_MasterDevis__c;
                        }

                }       
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
        
        contract.LPCR_DateRevisionPrix__c = quote.LPCR_DateRevisionPrix__c;

        contract.SBQQ__RenewalUpliftRate__c = quote.SBQQ__RenewalUpliftRate__c;

        
        if(quote.recordtype.DeveloperName == Label.LPCR_Referencement || quote.recordtype.DeveloperName == Label.LPCR_Referencement_Approuve || quote.recordtype.DeveloperName == Label.LPCR_Reservataire || quote.recordtype.DeveloperName == Label.LPCR_Reservataire_Approuve ) {
            contract.LPCR_MethodeRenouvellement__c = quote.LPCR_MethodeRenouvellement__c;
        }
        
        contract.LPCR_DureeContratJour__c = quote.LPCR_DureeContratJour__c;
        
        contract.LPCR_InitAutoAvecDateDebut__c = quote.LPCR_InitAutoAvecDateDebut__c;

        contract.LPCR_Sales_Rep__c = quote.SBQQ__SalesRep__c;
        
        contract.LPCR_ResponsableADV__c = quote.LPCR_ResponsableADV__c;
        
        contract.LPCR_ResponsableServiceFamille__c = quote.LPCR_ResponsableServiceFamille__c;
        if(Trigger.IsInsert && Trigger.IsBefore){
            contract.LPCR_BatchCommande__c=quote.LPCR_BatchCommande__c;
            
            
            if(contract.recordtype.DeveloperName == 'Accueil'){
                contract.LPCR_Section__c  = quote.LPCR_Section__c  ;
            }
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
        contract.LPCR_Indexation__c=quote.LPCR_Indexation__c;      
        return contract;
    }
    
    //added by saurabh IS-1848
    public static void setRenewalContractFields(Map<Id, Contract> newContractMap, Map<Id, Contract> oldContractMap){
        PAD.log('SM010_ContractServices','setRenewalContractFields(Map<Id, Contract> newContractMap, Map<Id, Contract> oldContractMap)','newContractMap size '+ newContractMap.size());
        Map<Id,Contract> contractOrderMap = new Map<Id,Contract>();
        
        for(Contract eachNewContract : newContractMap.values()){ 
            System.debug('>> SM010_ContractServices , setRenewalContractFields : eachNewContract : '+ eachNewContract.id);
            if(eachNewContract.SBQQ__Order__c != null && (eachNewContract.RecordTypeId == reservataireRecTypeId || eachNewContract.recordtypeId == referencementRecTypeId) && eachNewContract.Status == 'Activated' && eachNewContract.LPCR_ProcessIdRenouvellementContrat__c == false && eachNewContract.LPCR_ProcessIdRenouvellementContrat__c == oldContractMap.get(eachNewContract.id).LPCR_ProcessIdRenouvellementContrat__c){
                contractOrderMap.put(eachNewContract.SBQQ__Order__c, eachNewContract);
            }
        }
        System.debug('>> SM010_ContractServices , setRenewalContractFields : contractOrderMap :'+ contractOrderMap);
        //get order items and create a list of orders to be updated
        for(Order eachOrder:[SELECT Id, Type,recordtype.DeveloperName FROM Order where Id in:contractOrderMap.keyset()]){
            if(eachOrder.Type == 'Renewal' && (eachOrder.recordtype.DeveloperName == Label.LPCR_Reservataire ||eachOrder.recordtype.DeveloperName == Label.LPCR_Reservataire )){
                contractOrderMap.get(eachOrder.id).LPCR_ProcessIdRenouvellementContrat__c = true;
            }
        }
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
    //create amendment d'indexation si convenue  SC-9
    @future(callout=true)
    public static void createCAAmendement(String strnewContractMap, String stroldContractMap){
        //deserialize maps 
        Map<Id,Contract> newContractMap=(Map<Id,Contract>) JSON.deserialize(strnewContractMap,Map<Id,Contract>.class);
        Map<Id,Contract> oldContractMap=(Map<Id,Contract>) JSON.deserialize(stroldContractMap,Map<Id,Contract>.class);
        Map<Id,Contract> contractMap = new Map<Id,Contract>();
        List<SBQQ__Quote__c> lstQuoteUpdate=new List<SBQQ__Quote__c>();
        List<SBQQ__QuoteLine__c> listCloneQuoteLine = new List<SBQQ__QuoteLine__c>();
                
        Map<Id,SBQQ__Quote__c > mapQuoteToIndex =new Map<Id,SBQQ__Quote__c >();
        List<Id> lstIdQuoteAmended =new List<Id>();
        List<WRP001_QuoteModel> lstQuoteModelBulk=new List<WRP001_QuoteModel>();
        for(Contract eachNewContract : newContractMap.values()){ //get all contracts where Uplift is changed
             System.debug('pdo 1 '+eachNewContract.SBQQ__RenewalUpliftRate__c );
             System.debug('pdo 2 '+oldContractMap.get(eachNewContract.Id).SBQQ__RenewalUpliftRate__c);   
             System.debug('pdo 3 '+eachNewContract.LPCR_UpliftNow__c);       
             System.debug('pdo 4 '+oldContractMap.get(eachNewContract.Id).LPCR_UpliftNow__c); 
             System.debug('pdo 5 '+oldContractMap.get(eachNewContract.Id).LPCR_IndexationConvenue__c);                                                    
            if(eachNewContract.SBQQ__RenewalUpliftRate__c != oldContractMap.get(eachNewContract.Id).SBQQ__RenewalUpliftRate__c && eachNewContract.LPCR_UpliftNow__c != oldContractMap.get(eachNewContract.Id).LPCR_UpliftNow__c && eachNewContract.LPCR_UpliftNow__c && (oldContractMap.get(eachNewContract.Id).LPCR_IndexationConvenue__c =='Oui' && eachNewContract.LPCR_IndexationConvenue__c !='Non') ) {
                System.debug('##pdo hiiii');
                UM006_ContractAmender amender = new UM006_ContractAmender();
                
                WRP001_QuoteModel quote = amender.load(eachNewContract.Id);
                UM007_QuoteReader reader = new UM007_QuoteReader();
                WRP001_QuoteModel quoteModel = reader.read(quote.record.id);
                APC006_CloneQuoteLinesIndexation.cloneAndResetQL(quoteModel.record.id, eachNewContract.SBQQ__RenewalUpliftRate__c, eachNewContract.LPCR_DateRevisionPrix__c);
                lstQuoteUpdate.add(new SBQQ__Quote__c(Id=quoteModel.record.id,SBQQ__RenewalUpliftRate__c= eachNewContract.SBQQ__RenewalUpliftRate__c,LPCR_DateRevisionPrix__c=eachNewContract.LPCR_DateRevisionPrix__c.addYears(1)));
            }
        }
        if(lstQuoteUpdate.size() > 0){
            update lstQuoteUpdate;
        }
       
            
        
        
        
        
    }
    
}