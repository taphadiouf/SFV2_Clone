/**
* @author Ayoub Ouarti
* @date 22/06/2020
* @Description identify the invoices associated with an active B2B contract. 
*/
global class APB009_GenerateLienFamilleFacture implements Database.Batchable<sObject>,Schedulable {
    final static  Id accountEntrepriseRTId  = EM003_RecordTypeEntity.getRecTypeIdByObjectAndName(Label.LPCR_Account, Label.LPCR_Entreprise);
    global APB009_GenerateLienFamilleFacture() {
        
    }
    
    global Database.QueryLocator start(Database.BatchableContext BC) {

        String query = 'SELECT Id, blng__Account__c ,blng__Account__r.RecordTypeId,LPCR_LiaisonFamilleFacture__c FROM blng__Invoice__c WHERE LPCR_LiaisonFamilleFacture__c=false AND blng__Account__r.RecordTypeId = :accountEntrepriseRTId';
        
        return Database.getQueryLocator(query);
    }
    
    global void execute(Database.BatchableContext BC, List<blng__Invoice__c> scope) {
        PAD.log('APB009_GenerateLienFamilleFacture','execute','scope to execute : '+scope);

        Id contratB2CRTId  = EM003_RecordTypeEntity.getRecTypeIdByObjectAndName(Label.LPCR_Contract, Label.LPCR_ContratA);
        
        Set<Id> invoiceIds = UM003_TypeManager.getIdsOfListObjects(scope);
        Map<Id,blng__Invoice__c> mapOfInvoice = new Map<Id,blng__Invoice__c>([SELECT Id, blng__Account__c ,LPCR_LiaisonFamilleFacture__c
                                                                              FROM blng__Invoice__c
                                                                              WHERE Id IN :invoiceIds ]);   
        
        
        Set<String> invoiceAccountIds = UM003_TypeManager.getFieldsOfListObjects(mapOfInvoice.values(),'blng__Account__c');
        String prodCode = '%Berceau%';
        List<blng__InvoiceLine__c> listOfInvoiceLine = [SELECT Id,LPCR_Creche__c,blng__StartDate__c,blng__EndDate__c ,blng__Invoice__c,blng__Invoice__r.blng__Account__c,blng__OrderProduct__r.Product2Id,blng__OrderProduct__r.SBQQ__Contract__c
                                                        FROM blng__InvoiceLine__c
                                                        WHERE blng__Invoice__c IN :invoiceIds
                                                        AND blng__OrderProduct__r.Product2.ProductCode like :prodCode];
        
        Map<String, List<blng__InvoiceLine__c>> mapOfInvoiceLine = new Map<String, List<blng__InvoiceLine__c>>();
        for(blng__InvoiceLine__c eachInvoiceLine : [SELECT Id,LPCR_Creche__c,blng__StartDate__c,blng__EndDate__c ,blng__Invoice__c,blng__Invoice__r.blng__Account__c,blng__OrderProduct__r.Product2Id,blng__OrderProduct__r.SBQQ__Contract__c
                                                    FROM blng__InvoiceLine__c
                                                    WHERE blng__Invoice__c IN :invoiceIds
                                                    AND blng__OrderProduct__r.Product2.ProductCode like :prodCode]){
                                                        if(!mapOfInvoiceLine.keyset().contains(eachInvoiceLine.blng__OrderProduct__r.SBQQ__Contract__c)){
                                                            mapOfInvoiceLine.put(eachInvoiceLine.blng__OrderProduct__r.SBQQ__Contract__c, new List<blng__InvoiceLine__c>());
                                                        }    
                                                        mapOfInvoiceLine.get(eachInvoiceLine.blng__OrderProduct__r.SBQQ__Contract__c).add(eachInvoiceLine);
                                                    }
        PAD.log('APB009_GenerateLienFamilleFacture','execute','mapOfInvoiceLine size '+ mapOfInvoiceLine.size());
        PAD.log('APB009_GenerateLienFamilleFacture','execute','mapOfInvoiceLine '+ mapOfInvoiceLine);
        Map<Id,Integer> mapNumberProdForInvoice = new Map<Id,Integer>();
        
        
        
        Date minStartDates = UM003_TypeManager.getMinMaxOfListObjectsDate(listOfInvoiceLine,'blng__StartDate__c')[0];
        Date maxEndDates = UM003_TypeManager.getMinMaxOfListObjectsDate(listOfInvoiceLine,'blng__EndDate__c')[1];
        
        PAD.log('APB009_GenerateLienFamilleFacture','execute' , 'minStartDates '+ minStartDates);
        PAD.log('APB009_GenerateLienFamilleFacture','execute', 'maxEndDates '+ maxEndDates);   
        
        List<Contract> listOfContractB2C = [SELECT Id,LPCR_Creche__c,LPCR_DateFin__c,LPCR_DateDebut__c,AccountId,LPCR_ContractEntreprise__c,LPCR_ContractEntreprise__r.AccountId
                                            FROM Contract 
                                            WHERE 
                                            LPCR_DateFin__c >= :minStartDates
                                            AND LPCR_DateDebut__c <= :maxEndDates AND
                                            RecordTypeId = :contratB2CRTId AND
                                            LPCR_ContractEntreprise__r.AccountId IN :invoiceAccountIds ];
        
        PAD.log(' APB009_GenerateLienFamilleFacture','execute','listOfContractB2C'+ listOfContractB2C);
        
        List<LPCR_LienFamilleFacture__c> listOfLienFamilleFactureFromBD = [SELECT Id,LPCR_Facture__c,LPCR_LigneFacture__c,LPCR_ContratFamille__c,LPCR_ContratEntreprise__c
                                                                           FROM LPCR_LienFamilleFacture__c 
                                                                           WHERE LPCR_Facture__c IN :invoiceIds ];
        
        List<LPCR_LienFamilleFacture__c> listOfLienFamilleFacture = new List<LPCR_LienFamilleFacture__c>();
        List<blng__Invoice__c> listOfInvoiceToUpdate = new List<blng__Invoice__c>();
        blng__Invoice__c invoiceTemp = new blng__Invoice__c();
        LPCR_LienFamilleFacture__c lienFamilleFacture = new LPCR_LienFamilleFacture__c();
        
        for(Contract eachContract : listOfContractB2C){
            PAD.log('APB009_GenerateLienFamilleFacture','execute','eachContract'+ eachContract);
            for(blng__InvoiceLine__c eachInvoiceLine : mapOfInvoiceLine.get(eachContract.LPCR_ContractEntreprise__c)){
                PAD.log('APB009_GenerateLienFamilleFacture','execute','eachInvoiceLine'+ eachInvoiceLine);
                
                if(  eachContract.LPCR_ContractEntreprise__r.AccountId != null && eachInvoiceLine.blng__Invoice__r.blng__Account__c== eachContract.LPCR_ContractEntreprise__r.AccountId 
                   && eachInvoiceLine.LPCR_Creche__c == eachContract.LPCR_Creche__c && eachContract.LPCR_Creche__c!=null){
                       
                       if(eachContract.LPCR_DateFin__c >= eachInvoiceLine.blng__StartDate__c && eachContract.LPCR_DateDebut__c <= eachInvoiceLine.blng__EndDate__c  ){
                           
                           if(mapNumberProdForInvoice.containsKey(eachInvoiceLine.blng__Invoice__c)){
                               mapNumberProdForInvoice.put(eachInvoiceLine.blng__Invoice__c,mapNumberProdForInvoice.get(eachInvoiceLine.blng__Invoice__c)+1);
                           }else{
                               mapNumberProdForInvoice.put(eachInvoiceLine.blng__Invoice__c,1);
                           }
                           lienFamilleFacture = new LPCR_LienFamilleFacture__c(LPCR_Facture__c=eachInvoiceLine.blng__Invoice__c,
                                                                               LPCR_LigneFacture__c=eachInvoiceLine.Id,
                                                                               LPCR_ContratFamille__c =eachContract.Id,
                                                                               LPCR_ContratEntreprise__c	= eachContract.LPCR_ContractEntreprise__c 
                                                                              );
                           
                           if(!listOfLienFamilleFactureFromBD.contains(lienFamilleFacture)){
                               listOfLienFamilleFacture.add(lienFamilleFacture);
                           }   
                           
                       }
                       
                   }
            }
        }
        PAD.log('APB009_GenerateLienFamilleFacture','execute ','listOfLienFamilleFacture size '+ listOfLienFamilleFacture.size());
        PAD.log('APB009_GenerateLienFamilleFacture','execute ','listOfLienFamilleFacture '+ listOfLienFamilleFacture);
        
        Map<Id,Integer> mapNumberLienFamilleFactureForInvoice = new Map<Id,Integer>();
        for(LPCR_LienFamilleFacture__c eachLienFamFac : listOfLienFamilleFacture){
            if(mapNumberLienFamilleFactureForInvoice.containsKey(eachLienFamFac.LPCR_Facture__c)){
                mapNumberLienFamilleFactureForInvoice.put(eachLienFamFac.LPCR_Facture__c,mapNumberLienFamilleFactureForInvoice.get(eachLienFamFac.LPCR_Facture__c)+1);
            }else{
                mapNumberLienFamilleFactureForInvoice.put(eachLienFamFac.LPCR_Facture__c,1);
            }
        }
        List<LPCR_LienFamilleFacture__c> listOfLienFamilleFactureToStore = new List<LPCR_LienFamilleFacture__c>();
        
        
        for(LPCR_LienFamilleFacture__c eachLienFamFac : listOfLienFamilleFacture){
            if(mapNumberProdForInvoice.get(eachLienFamFac.LPCR_Facture__c) ==mapNumberLienFamilleFactureForInvoice.get(eachLienFamFac.LPCR_Facture__c) ){
                invoiceTemp = new blng__Invoice__c(Id=eachLienFamFac.LPCR_Facture__c,LPCR_LiaisonFamilleFacture__c=true);
                
                if(!listOfInvoiceToUpdate.contains(invoiceTemp)){
                    listOfInvoiceToUpdate.add(invoiceTemp);
                }
                listOfLienFamilleFactureToStore.add(eachLienFamFac);
            }
        }
        String ErrMsg;
        try {
            insert listOfLienFamilleFacture; 
            UM001_LogManager.writeLogActivityWithoutFuture( 'identify the invoices associated with an active B2B contract',
                                                            'APB009_GenerateLienFamilleFacture', 'Batch' , null,
                                                            'Successfully insert list of \'Lien Famille et Facture\' : ' + String.valueOf(listOfLienFamilleFacture), 
                                                            UM010_Constant.SUCCESS);          
        } catch (Exception e) {
            ErrMsg = e.getMessage();
        } finally {
            if(ErrMsg != null && String.isNotBlank(ErrMsg)){
                UM001_LogManager.writeLogActivityWithoutFuture( 'identify the invoices associated with an active B2B contract','APB009_GenerateLienFamilleFacture', 'Batch' , null,'Error while inserting the \'Lien Famille et Facture\' records : ' + ErrMsg, UM010_Constant.ERROR);              
            }
        }
        ErrMsg = null;
        try {
            update listOfInvoiceToUpdate;
            UM001_LogManager.writeLogActivityWithoutFuture( 'identify the invoices associated with an active B2B contract',
                                                            'APB009_GenerateLienFamilleFacture', 'Batch' , null,
                                                            'Successfully updated list of invoices : ' + String.valueOf(listOfInvoiceToUpdate), 
                                                            UM010_Constant.SUCCESS);          
        } catch (Exception e) {
            ErrMsg = e.getMessage();
        } finally {
            if(ErrMsg != null && String.isNotBlank(ErrMsg)){
                UM001_LogManager.writeLogActivityWithoutFuture( 'identify the invoices associated with an active B2B contract', 'APB009_GenerateLienFamilleFacture', 'Batch' , null,'Error while updating the invoices : ' + ErrMsg, UM010_Constant.ERROR);              
            }
        }

        
    }
    
    global void finish(Database.BatchableContext BC) {
    }
    
    global void execute(SchedulableContext sc) {
        PAD.log('APB009_GenerateLienFamilleFacture','execute','sc');
        APB009_GenerateLienFamilleFacture sc1 = new APB009_GenerateLienFamilleFacture();
        Datetime dt = Datetime.now().addMinutes(30);  // i.e. 30 mins
        String timeForScheduler = dt.format('s m H d M \'?\' yyyy');
        // schedule the apex class only if their is not existing job running
        boolean isBatchJobRunning = UM004_BatchUtility.isBatchJobRunning('APB009_GenerateLienFamilleFacture');
        
        // check if there is any open place to schedule the class
        boolean isJobQueueFull = UM004_BatchUtility.isBatchJobQueueFull();
        
        if(isBatchJobRunning == UM004_BatchUtility.BOOLEAN_FALSE){
            if (isJobQueueFull == UM004_BatchUtility.BOOLEAN_FALSE) {
                sc1 = new APB009_GenerateLienFamilleFacture();
                Database.executeBatch(this, 1);
            } else {
                //schedule this same schedulable class again in 30 mins

                Id schedId = System.Schedule('APB009_GenerateLienFamilleFacture'+timeForScheduler,timeForScheduler,new APB009_GenerateLienFamilleFacture());
                PAD.log('APB009_GenerateLienFamilleFacture','execute','Batch scheduled in 30 minutes : '+timeForScheduler);
            }
        }  
        
    } 
}