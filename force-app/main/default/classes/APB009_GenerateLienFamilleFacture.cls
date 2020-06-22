/**
* @author Ayoub Ouarti
* @date 22/06/2020
* @Description identify the invoices associated with an active B2B contract. 
*/
global class APB009_GenerateLienFamilleFacture implements Database.Batchable<sObject>,Schedulable {
    
    global APB009_GenerateLienFamilleFacture() {
        
    }
    
    global Database.QueryLocator start(Database.BatchableContext BC) {
        //Id accountEntrepriseRTId  = EM003_RecordTypeEntity.getRecTypeIdByObjectAndName(Label.LPCR_Account, Label.LPCR_Entreprise);

        String query = 'SELECT Id, blng__Account__c ,LPCR_LiaisonFamilleFacture__c FROM blng__Invoice__c WHERE LPCR_LiaisonFamilleFacture__c=false ';//AND blng__Acoount__r.RecordTypeeId = :accountEntrepriseRTId';
        
        return Database.getQueryLocator(query);
    }
    
    global void execute(Database.BatchableContext BC, List<blng__Invoice__c> scope) {
        PAD.log('APB009_GenerateLienFamilleFacture','execute','scope to execute : '+scope);
        Id contratB2CRTId  = EM003_RecordTypeEntity.getRecTypeIdByObjectAndName(Label.LPCR_Contract, Label.LPCR_Contrat_B2B);

        Set<Id> invoiceIds = UM003_TypeManager.getIdsOfListObjects(scope);
        Map<Id,blng__Invoice__c> mapOfInvoice = new Map<Id,blng__Invoice__c>([SELECT Id, blng__Account__c ,LPCR_LiaisonFamilleFacture__c
                                                         FROM blng__Invoice__c
                                                         WHERE Id IN :invoiceIds ]);   
        
        Set<String> invoiceAccountIds = UM003_TypeManager.getFieldsOfListObjects(mapOfInvoice.values(),'blng__Account__c');

        List<blng__InvoiceLine__c> listOfInvoiceLine = [SELECT Id,LPCR_Creche__c,blng__StartDate__c,blng__EndDate__c ,blng__Invoice__c,blng__Invoice__r.blng__Account__c,blng__OrderProduct__r.SBQQ__Contract__c
                                                        FROM blng__InvoiceLine__c
                                                        WHERE blng__Invoice__c IN :invoiceIds];

        //Date minStartDates = UM003_TypeManager.getMinMaxOfListObjectsDate(listOfInvoiceLine,'startDate')[0];
        //Date maxEndDates = UM003_TypeManager.getMinMaxOfListObjectsDate(listOfInvoiceLine,'endDate')[1];

        List<Contract> listOfContractB2C = [SELECT Id,endDate,startDate,AccountId,LPCR_ContractEntreprise__c,LPCR_ContractEntreprise__r.AccountId
                                            FROM Contract 
                                            WHERE AccountId IN :invoiceAccountIds 
                                            //AND endDate >= :minStartDates
                                            //AND startDate <= :maxEndDates
                                            AND RecordTypeId = :contratB2CRTId];


        List<LPCR_LienFamilleFacture__c> listOfLienFamilleFacture = new List<LPCR_LienFamilleFacture__c>();
        List<blng__Invoice__c> listOfInvocieToUpdate = new List<blng__Invoice__c>();
        blng__Invoice__c invoiceTemp = new blng__Invoice__c();
        for(Contract eachContract : listOfContractB2C){
            for(blng__InvoiceLine__c eachInvoiceLine : listOfInvoiceLine){
                    if( eachInvoiceLine.blng__Invoice__r.blng__Account__c== eachContract.LPCR_ContractEntreprise__r.AccountId &&  eachContract.LPCR_ContractEntreprise__r.AccountId != null
                    && eachInvoiceLine.LPCR_Creche__c == eachContract.LPCR_Creche__c && eachContract.LPCR_Creche__c!=null){

                    if(eachContract.endDate >= eachInvoiceLine.blng__StartDate__c && eachContract.startDate <= eachInvoiceLine.blng__EndDate__c  ){
                        invoiceTemp = new blng__Invoice__c(Id=mapOfInvoice.get(eachInvoiceLine.blng__Invoice__c).Id,LPCR_LiaisonFamilleFacture__c=true);
                        if(!UM003_TypeManager.listContainsValue(listOfInvocieToUpdate,invoiceTemp,'Id')){
                            listOfInvocieToUpdate.add(invoiceTemp);
                        }

                        listOfLienFamilleFacture.add(new LPCR_LienFamilleFacture__c(LPCR_Facture__c=eachInvoiceLine.blng__Invoice__c,
                                                                                    LPCR_LigneFacture__c=eachInvoiceLine.Id,
                                                                                    LPCR_ContratFamille__c =eachContract.Id,
                                                                                    LPCR_ContratEntreprise__c	= eachInvoiceLine.blng__OrderProduct__r.SBQQ__Contract__c
                                                                                    ));
                        }   
                    }
                }
        }
    insert listOfLienFamilleFacture;
    update listOfInvocieToUpdate;

    }
    
    global void finish(Database.BatchableContext BC) {
    }
    
    global void execute(SchedulableContext sc) {
        PAD.log('APB009_GenerateLienFamilleFacture','execute','sc');
        APB009_GenerateLienFamilleFacture sc1 = new APB009_GenerateLienFamilleFacture();
        
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
                sc1 = new APB009_GenerateLienFamilleFacture();
                Datetime dt = Datetime.now().addMinutes(30);  // i.e. 30 mins
                String timeForScheduler = dt.format('s m H d M \'?\' yyyy');
                Id schedId = System.Schedule('APB009_GenerateLienFamilleFacture'+timeForScheduler,timeForScheduler,sc1);
            }
        }  
        
    } 
}