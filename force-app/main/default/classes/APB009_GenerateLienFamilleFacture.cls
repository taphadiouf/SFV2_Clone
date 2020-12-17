/**
* @author Ayoub Ouarti
* @date 22/06/2020
* @Description identify the invoices associated with an active B2B contract. 
*/

global class APB009_GenerateLienFamilleFacture implements Database.Batchable<sObject>,Schedulable {

    final static  Id accountEntrepriseRTId  = EM003_RecordTypeEntity.getRecTypeIdByObjectAndName(Label.LPCR_Account, Label.LPCR_Entreprise);
    final static  Id orderReferencRT = EM003_RecordTypeEntity.getRecTypeIdByObjectAndName('Order','Referencement');
    final String ClassName = APB009_GenerateLienFamilleFacture.class.getName();
    
    global APB009_GenerateLienFamilleFacture() {
        
    }
    
    global Database.QueryLocator start(Database.BatchableContext BC) {

        UM001_LogManager.writeLogActivityWithoutFuture(ClassName,'start', 'Batch' , null, 'Starting Batch', UM010_Constant.SUCCESS);

        return Database.getQueryLocator([SELECT Id, blng__Account__c ,blng__Account__r.RecordTypeId,LPCR_LiaisonFamilleFacture__c 
                                            FROM blng__Invoice__c 
                                            WHERE LPCR_LiaisonFamilleFacture__c=false AND blng__Account__r.RecordTypeId = :accountEntrepriseRTId]);
    }
    
    global void execute(Database.BatchableContext BC, List<blng__Invoice__c> scope) {

        UM001_LogManager.writeLogActivityWithoutFuture(ClassName,'execute', 'Batch' , null, 'Scope size : '  + scope.size(), UM010_Constant.SUCCESS); 
        
        List<Exception> errors = new List<Exception>();
        try {
       
            PAD.log(ClassName,'execute','scope to execute : '+scope);

            Id contratB2CRTId  = EM003_RecordTypeEntity.getRecTypeIdByObjectAndName(Label.LPCR_Contract, Label.LPCR_ContratA);
            
            Set<Id> invoiceIds = UM003_TypeManager.getIdsOfListObjects(scope);
            Map<Id,blng__Invoice__c> mapOfInvoice = new Map<Id,blng__Invoice__c>([SELECT Id, blng__Account__c ,LPCR_LiaisonFamilleFacture__c
                                                                                FROM blng__Invoice__c
                                                                                WHERE Id IN :invoiceIds ]);   

            PAD.log(ClassName, 'execute', 'mapOfInvoice : ' + mapOfInvoice);

            Set<String> invoiceAccountIds = UM003_TypeManager.getFieldsOfListObjects(mapOfInvoice.values(),'blng__Account__c');
            String prodCode = '%Berceau%';

            PAD.log(ClassName, 'execute', 'invoiceAccountIds : ' + invoiceAccountIds);

            List<blng__InvoiceLine__c> listOfInvoiceLine = [SELECT Id,LPCR_Creche__c,blng__StartDate__c,blng__EndDate__c ,blng__Invoice__c,
                                                                    blng__Invoice__r.blng__Account__c,blng__OrderProduct__r.Product2Id,
                                                                    blng__OrderProduct__r.SBQQ__Contract__c,blng__OrderProduct__r.OrderId,LPCR_ContactEnfant__c
                                                            FROM blng__InvoiceLine__c
                                                            WHERE blng__Invoice__c IN :invoiceIds
                                                            AND blng__OrderProduct__r.Product2.ProductCode like :prodCode];

            PAD.log(ClassName, 'execute', 'listOfInvoiceLine : ' + listOfInvoiceLine);
            
            Map<String, List<blng__InvoiceLine__c>> mapOfInvoiceLine = new Map<String, List<blng__InvoiceLine__c>>();
            
            Map<Id, Id> invoiceLineOrderIdMap = new Map<Id, Id>();

            for (blng__InvoiceLine__c eachInvoiceLine : listOfInvoiceLine) {

                // We populate a map with all the corresponding B2B Contract Id coming from scope of invoice line assciated to invoice scope
                if (!mapOfInvoiceLine.keyset().contains(eachInvoiceLine.blng__OrderProduct__r.SBQQ__Contract__c)) {

                    PAD.log(ClassName, 'execute', 'mapOfInvoiceLine.keyset() not containing Contract Id');

                    mapOfInvoiceLine.put(eachInvoiceLine.blng__OrderProduct__r.SBQQ__Contract__c, new List<blng__InvoiceLine__c>());
                }    
                mapOfInvoiceLine.get(eachInvoiceLine.blng__OrderProduct__r.SBQQ__Contract__c).add(eachInvoiceLine);

                invoiceLineOrderIdMap.put(eachInvoiceLine.id,eachInvoiceLine.blng__OrderProduct__r.OrderId);
            }

            // Create a map of (Id invoice line, Order Object)
            Map<Id,Order> orderMap = new Map<ID, Order>([SELECT id,RecordTypeId FROM Order where Id IN :invoiceLineOrderIdMap.values()]);
            Map<Id,Order> invoiceLineOrderMap = new Map<ID, Order>();
            for(Id i : invoiceLineOrderIdMap.keySet()){
                invoiceLineOrderMap.put(i,orderMap.get(invoiceLineOrderIdMap.get(i)));
            }
            PAD.log(ClassName,'execute','mapOfInvoiceLine size '+ mapOfInvoiceLine.size());
            PAD.log(ClassName,'execute','mapOfInvoiceLine '+ mapOfInvoiceLine);

            Map<Id,Integer> mapNumberProdForInvoice = new Map<Id,Integer>();
            
            Date minStartDates = UM003_TypeManager.getMinMaxOfListObjectsDate(listOfInvoiceLine,'blng__StartDate__c')[0]; // Min Start Date of all the Invoice Line
            Date maxEndDates = UM003_TypeManager.getMinMaxOfListObjectsDate(listOfInvoiceLine,'blng__EndDate__c')[1]; // Max End Date of all the Invoice Line
            
            PAD.log(ClassName,'execute' , 'minStartDates '+ minStartDates);
            PAD.log(ClassName,'execute', 'maxEndDates '+ maxEndDates);   
            
            List<Contract> listOfContractB2C = [SELECT Id,LPCR_Creche__c,LPCR_DateFin__c,LPCR_DateDebut__c,AccountId,LPCR_ContactEnfant__c,
                                                        LPCR_ContractEntreprise__c,LPCR_ContractEntreprise__r.AccountId
                                                FROM Contract 
                                                WHERE 
                                                Status = 'Activated'
                                                AND
                                                LPCR_DateFin__c >= :minStartDates
                                                AND LPCR_DateDebut__c <= :maxEndDates AND
                                                RecordTypeId = :contratB2CRTId AND
                                                LPCR_Creche__c != null AND
                                                LPCR_ContractEntreprise__r.AccountId IN :invoiceAccountIds ];
            
            PAD.log(ClassName,'execute','listOfContractB2C'+ listOfContractB2C);
            
            List<LPCR_LienFamilleFacture__c> listOfLienFamilleFactureFromBD = [SELECT Id,LPCR_Facture__c,LPCR_LigneFacture__c,LPCR_ContratFamille__c,LPCR_ContratEntreprise__c
                                                                            FROM LPCR_LienFamilleFacture__c 
                                                                            WHERE LPCR_Facture__c IN :invoiceIds ];
            

            PAD.logAllList(ClassName, 'execute', 'listOfLienFamilleFactureFromBD', listOfLienFamilleFactureFromBD);

            List<LPCR_LienFamilleFacture__c> listOfLienFamilleFacture   = new List<LPCR_LienFamilleFacture__c>();
            List<blng__Invoice__c>  listOfInvoiceToUpdate               = new List<blng__Invoice__c>();
            blng__Invoice__c invoiceTemp                                = new blng__Invoice__c();

            generateLinksForContracts(mapOfInvoiceLine,listOfContractB2C,listOfLienFamilleFacture,listOfLienFamilleFactureFromBD,mapNumberProdForInvoice,invoiceLineOrderMap);

            List<LPCR_BonAchatPartenaire__c> listBonAchats = [SELECT Id,LPCR_Creche__c,LPCR_DateFinPrestation__c,LPCR_DateDebutPrestation__c,LPCR_Client__c,LPCR_ContactEnfant__c,
                                                                    LPCR_ContratReservataire__c
                                                                FROM LPCR_BonAchatPartenaire__c
                                                                WHERE 
                                                                LPCR_DateFinPrestation__c >= :minStartDates AND
                                                                LPCR_DateDebutPrestation__c <= :maxEndDates AND 
                                                                LPCR_Creche__c != Null AND 
                                                                LPCR_Client__c IN :invoiceAccountIds];

            generateLinksForBonAchat(mapOfInvoiceLine,listBonAchats,listOfLienFamilleFacture,listOfLienFamilleFactureFromBD,mapNumberProdForInvoice,invoiceLineOrderMap);

            PAD.log(ClassName,'execute ','listOfLienFamilleFacture size '+ listOfLienFamilleFacture.size());
            PAD.log(ClassName,'execute ','listOfLienFamilleFacture '+ listOfLienFamilleFacture);
            
            Map<Id,Integer> mapNumberLienFamilleFactureForInvoice = new Map<Id,Integer>();

            for (LPCR_LienFamilleFacture__c eachLienFamFac : listOfLienFamilleFacture) {

                if (mapNumberLienFamilleFactureForInvoice.containsKey(eachLienFamFac.LPCR_Facture__c)) {

                    PAD.log(ClassName, 'execute', 'mapNumberLienFamilleFactureForInvoice.containsKey(eachLienFamFac.LPCR_Facture__c)');
                    mapNumberLienFamilleFactureForInvoice.put(eachLienFamFac.LPCR_Facture__c, mapNumberLienFamilleFactureForInvoice.get(eachLienFamFac.LPCR_Facture__c) + 1);
                } else {

                    mapNumberLienFamilleFactureForInvoice.put(eachLienFamFac.LPCR_Facture__c, 1);
                }
            }
            List<LPCR_LienFamilleFacture__c> listOfLienFamilleFactureToStore = new List<LPCR_LienFamilleFacture__c>();
            
            for (LPCR_LienFamilleFacture__c eachLienFamFac : listOfLienFamilleFacture) {

                PAD.log(ClassName, 'execute', 'eachLienFamFac:' + eachLienFamFac);
                PAD.log(ClassName, 'execute', 'mapNumberProdForInvoice.get(eachLienFamFac.LPCR_Facture__c):' + mapNumberProdForInvoice.get(eachLienFamFac.LPCR_Facture__c));
                PAD.log(ClassName, 'execute', 'mapNumberLienFamilleFactureForInvoice.get(eachLienFamFac.LPCR_Facture__c):' + mapNumberLienFamilleFactureForInvoice.get(eachLienFamFac.LPCR_Facture__c));

                if (mapNumberProdForInvoice.get(eachLienFamFac.LPCR_Facture__c) == mapNumberLienFamilleFactureForInvoice.get(eachLienFamFac.LPCR_Facture__c) ) {

                    PAD.log(ClassName, 'execute', 'mapNumberProdForInvoice condition matches');

                    invoiceTemp = new blng__Invoice__c(Id=eachLienFamFac.LPCR_Facture__c,LPCR_LiaisonFamilleFacture__c=true);
                    
                    if(!listOfInvoiceToUpdate.contains(invoiceTemp)){
                        listOfInvoiceToUpdate.add(invoiceTemp);
                    }
                    listOfLienFamilleFactureToStore.add(eachLienFamFac);
                }
            }

            PAD.logAllList(ClassName, 'execute', 'listOfLienFamilleFacture', listOfLienFamilleFacture); 
            PAD.logAllList(ClassName, 'execute', 'listOfInvoiceToUpdate', listOfInvoiceToUpdate); 

            String ErrMsg;
            try {
                if (listOfLienFamilleFacture.size() > 0) {

                    insert listOfLienFamilleFacture; 
                    UM001_LogManager.writeLogActivityWithoutFuture(ClassName, 'execute', 'Batch' , null, 'Inserted list of \'Lien Famille et Facture\' : ' + String.valueOf(listOfLienFamilleFacture), UM010_Constant.SUCCESS);  
                }        
            } catch (Exception e) {
                ErrMsg = e.getMessage();
            } finally {
                if(ErrMsg != null && String.isNotBlank(ErrMsg)){
                    UM001_LogManager.writeLogActivityWithoutFuture(ClassName, 'execute', 'Batch' , null,'Error while inserting the \'Lien Famille et Facture\' records : ' + ErrMsg, UM010_Constant.ERROR);              
                }
            }

            ErrMsg = null;
            try {
                if (listOfInvoiceToUpdate.size() > 0) {

                    update listOfInvoiceToUpdate;
                    UM001_LogManager.writeLogActivityWithoutFuture(ClassName, 'execute', 'Batch' , null, 'Updated list of invoices : ' + String.valueOf(listOfInvoiceToUpdate), UM010_Constant.SUCCESS);   
                }       
            } catch (Exception e) {
                ErrMsg = e.getMessage();
            } finally {
                if(ErrMsg != null && String.isNotBlank(ErrMsg)){
                    UM001_LogManager.writeLogActivityWithoutFuture(ClassName, 'execute', 'Batch' , null,'Error while updating the invoices : ' + ErrMsg, UM010_Constant.ERROR);              
                }
            }

        } catch(Exception e) {
            errors.add(e);
        }
        
        if (!errors.isEmpty()) {
            UM001_LogManager.writeLogActivityWithoutFuture(ClassName, 'execute', 'Batch' , null,'Processing with errors occurred : ' + errors, UM010_Constant.ERROR);
        }
        
    }
    
    global void generateLinksForContracts(Map<String, List<blng__InvoiceLine__c>> mapOfInvoiceLine,List<Contract> listOfContractB2C,List<LPCR_LienFamilleFacture__c> listOfLienFamilleFacture,List<LPCR_LienFamilleFacture__c> listOfLienFamilleFactureFromBD,Map<Id,Integer> mapNumberProdForInvoice,Map<Id,Order> invoiceLineOrderMap){
        
        for (Contract eachContract : listOfContractB2C) { // loop through all the B2C Contract

            PAD.log(ClassName,'execute','eachContract'+ eachContract);

            if (!mapOfInvoiceLine.containsKey(eachContract.LPCR_ContractEntreprise__c)) {
                
                PAD.log(ClassName, 'execute', 'skip the occurence' + eachContract);
                continue; // If our scope of Invoice Line is not link to our scope of B2C Contract we skip the occurence
            }

            for (blng__InvoiceLine__c eachInvoiceLine : mapOfInvoiceLine.get(eachContract.LPCR_ContractEntreprise__c)) {

                PAD.log(ClassName,'execute','eachInvoiceLine'+ eachInvoiceLine);
                
                PAD.log(ClassName,'execute','eachInvoiceLine.blng__Invoice__r.blng__Account__c == eachContract.LPCR_ContractEntreprise__r.AccountId :' + (eachInvoiceLine.blng__Invoice__r.blng__Account__c == eachContract.LPCR_ContractEntreprise__r.AccountId));
                PAD.log(ClassName,'execute','eachInvoiceLine.LPCR_Creche__c == eachContract.LPCR_Creche__c :' + (eachInvoiceLine.LPCR_Creche__c == eachContract.LPCR_Creche__c));
                
                if (eachInvoiceLine.blng__Invoice__r.blng__Account__c == eachContract.LPCR_ContractEntreprise__r.AccountId  // B2B Invoice Line Account = B2C Contract Account
                        && eachInvoiceLine.LPCR_Creche__c == eachContract.LPCR_Creche__c) {                                 // B2B Invoice Line Creche = B2C Contract Creche

                    PAD.log(ClassName,'execute','eachContract.LPCR_DateFin__c >= eachInvoiceLine.blng__StartDate__c :' + (eachContract.LPCR_DateFin__c >= eachInvoiceLine.blng__StartDate__c));
                    PAD.log(ClassName,'execute','eachContract.LPCR_DateDebut__c <= eachInvoiceLine.blng__EndDate__c :' + (eachContract.LPCR_DateDebut__c <= eachInvoiceLine.blng__EndDate__c));

                    if (eachContract.LPCR_DateFin__c >= eachInvoiceLine.blng__StartDate__c && eachContract.LPCR_DateDebut__c <= eachInvoiceLine.blng__EndDate__c) {
                        
                        if (mapNumberProdForInvoice.containsKey(eachInvoiceLine.blng__Invoice__c)) {
                            mapNumberProdForInvoice.put(eachInvoiceLine.blng__Invoice__c,mapNumberProdForInvoice.get(eachInvoiceLine.blng__Invoice__c) +1 );
                        }
                        else {
                            mapNumberProdForInvoice.put(eachInvoiceLine.blng__Invoice__c,1);
                        }

                        Order invoiceLineOrder = invoiceLineOrderMap.get(eachInvoiceLine.id);
                        if(invoiceLineOrder.RecordTypeId == orderReferencRT){

                            if(eachContract.LPCR_ContactEnfant__c == eachInvoiceLine.LPCR_ContactEnfant__c){

                                LPCR_LienFamilleFacture__c lienFamilleFacture = new LPCR_LienFamilleFacture__c(
                                                                            LPCR_Facture__c = eachInvoiceLine.blng__Invoice__c,
                                                                            LPCR_LigneFacture__c = eachInvoiceLine.Id,
                                                                            LPCR_ContratFamille__c = eachContract.Id,
                                                                            LPCR_ContratEntreprise__c = eachContract.LPCR_ContractEntreprise__c,
                                                                            LPCR_Enfant__c = eachContract.LPCR_ContactEnfant__c
                                                                            );
                                if(!listOfLienFamilleFactureFromBD.contains(lienFamilleFacture)){
                                    listOfLienFamilleFacture.add(lienFamilleFacture);
                                } 
                            }
                        }else{
                            LPCR_LienFamilleFacture__c lienFamilleFacture = new LPCR_LienFamilleFacture__c(
                                                                            LPCR_Facture__c = eachInvoiceLine.blng__Invoice__c,
                                                                            LPCR_LigneFacture__c = eachInvoiceLine.Id,
                                                                            LPCR_ContratFamille__c = eachContract.Id,
                                                                            LPCR_ContratEntreprise__c = eachContract.LPCR_ContractEntreprise__c 
                                                                            );
                            if(!listOfLienFamilleFactureFromBD.contains(lienFamilleFacture)){
                                listOfLienFamilleFacture.add(lienFamilleFacture);
                            } 
                             
                        }
                    }
                }
            }
        }
    }

    global void generateLinksForBonAchat(Map<String, List<blng__InvoiceLine__c>> mapOfInvoiceLine,List<LPCR_BonAchatPartenaire__c> listBonAchats,List<LPCR_LienFamilleFacture__c> listOfLienFamilleFacture,List<LPCR_LienFamilleFacture__c> listOfLienFamilleFactureFromBD,Map<Id,Integer> mapNumberProdForInvoice,Map<Id,Order> invoiceLineOrderMap){

        for(LPCR_BonAchatPartenaire__c bonAchat : listBonAchats){
                
            if (!mapOfInvoiceLine.containsKey(bonAchat.LPCR_ContratReservataire__c)) {
                
                PAD.log(ClassName, 'execute', 'skip the occurence' + bonAchat);
                continue; // If our scope of Invoice Line is not link to our scope of B2C Contract we skip the occurence
            }

            for (blng__InvoiceLine__c eachInvoiceLine : mapOfInvoiceLine.get(bonAchat.LPCR_ContratReservataire__c)) {

                if (eachInvoiceLine.blng__Invoice__r.blng__Account__c   == bonAchat.LPCR_Client__c 
                    && 
                    eachInvoiceLine.LPCR_Creche__c                      == bonAchat.LPCR_Creche__c) {


                    if (bonAchat.LPCR_DateFinPrestation__c >= eachInvoiceLine.blng__StartDate__c && bonAchat.LPCR_DateDebutPrestation__c <= eachInvoiceLine.blng__EndDate__c) {

                        if (mapNumberProdForInvoice.containsKey(eachInvoiceLine.blng__Invoice__c)) {
                            mapNumberProdForInvoice.put(eachInvoiceLine.blng__Invoice__c,mapNumberProdForInvoice.get(eachInvoiceLine.blng__Invoice__c) +1 );
                        }
                        else {
                            mapNumberProdForInvoice.put(eachInvoiceLine.blng__Invoice__c,1);
                        }

                        Order invoiceLineOrder = invoiceLineOrderMap.get(eachInvoiceLine.id);
                        if(invoiceLineOrder.RecordTypeId == orderReferencRT){

                            if(bonAchat.LPCR_ContactEnfant__c == eachInvoiceLine.LPCR_ContactEnfant__c){

                                LPCR_LienFamilleFacture__c lienFamilleFacture = new LPCR_LienFamilleFacture__c(
                                                                            LPCR_Facture__c = eachInvoiceLine.blng__Invoice__c,
                                                                            LPCR_LigneFacture__c = eachInvoiceLine.Id,
                                                                            LPCR_BonAchat__c = bonAchat.Id,
                                                                            LPCR_ContratEntreprise__c = bonAchat.LPCR_ContratReservataire__c,
                                                                            LPCR_Enfant__c = bonAchat.LPCR_ContactEnfant__c
                                                                            );
                                if(!listOfLienFamilleFactureFromBD.contains(lienFamilleFacture)){
                                    listOfLienFamilleFacture.add(lienFamilleFacture);
                                } 
                            }
                        }else{
                            LPCR_LienFamilleFacture__c lienFamilleFacture = new LPCR_LienFamilleFacture__c(
                                                                            LPCR_Facture__c = eachInvoiceLine.blng__Invoice__c,
                                                                            LPCR_LigneFacture__c = eachInvoiceLine.Id,
                                                                            LPCR_BonAchat__c = bonAchat.Id,
                                                                            LPCR_ContratEntreprise__c = bonAchat.LPCR_ContratReservataire__c 
                                                                            );
                            if(!listOfLienFamilleFactureFromBD.contains(lienFamilleFacture)){
                                listOfLienFamilleFacture.add(lienFamilleFacture);
                            } 
                        }
                    }
                }    
            }
        }
    }


    global void finish(Database.BatchableContext BC) {
        UM001_LogManager.writeLogActivityWithoutFuture(ClassName,'finish', 'Batch' , null, 'Finished Batch Processing', UM010_Constant.SUCCESS);
    }
    
    global void execute(SchedulableContext sc) {
        PAD.log(ClassName,'execute','sc');
        APB009_GenerateLienFamilleFacture sc1 = new APB009_GenerateLienFamilleFacture();
        Datetime dt = Datetime.now().addMinutes(30);  // i.e. 30 mins
        String timeForScheduler = dt.format('s m H d M \'?\' yyyy');
        // schedule the apex class only if their is not existing job running
        boolean isBatchJobRunning = UM004_BatchUtility.isBatchJobRunning(ClassName);
        
        // check if there is any open place to schedule the class
        boolean isJobQueueFull = UM004_BatchUtility.isBatchJobQueueFull();
        
        if(isBatchJobRunning == UM004_BatchUtility.BOOLEAN_FALSE){
            if (isJobQueueFull == UM004_BatchUtility.BOOLEAN_FALSE) {
                sc1 = new APB009_GenerateLienFamilleFacture();
                Database.executeBatch(this, 1);
            } else {
                //schedule this same schedulable class again in 30 mins

                Id schedId = System.Schedule(ClassName+timeForScheduler,timeForScheduler,new APB009_GenerateLienFamilleFacture());
                PAD.log(ClassName,'execute','Batch scheduled in 30 minutes : '+timeForScheduler);
            }
        }  
        
    } 
}