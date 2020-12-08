/**
* @author Ayoub Ouarti
* @date 18/03/2020
* @Description Batch for checking the box ordered on the quote which will create the order
*/
global class APB003_CreateOrderFromQuote  implements Database.Batchable<sObject>,Schedulable {
    String query;
    final String ClassName = APB003_CreateOrderFromQuote.class.getName();
    global APB003_CreateOrderFromQuote() {
        
    }
     /*
    *   @description : this method search the Quotes with SBQQ__Status__c = 'Prêt pour commande\' AND SBQQ__Ordered__c  = false', to generate order
    *   @param Database.BatchableContext BC
    *   @returns Database.QueryLocator
    */
    global Database.QueryLocator start(Database.BatchableContext BC) {
        UM001_LogManager.writeLogActivityWithoutFuture(ClassName,'start', 'Batch' , null, 'Starting Batch', UM010_Constant.SUCCESS);
        PAD.log(ClassName, 'start','Database.BatchableContext BC');        
        query = 'SELECT Id,RecordTypeId,LPCR_BonCommandeEnvoye__c,SBQQ__Status__c ,SBQQ__Ordered__c, LPCR_TypeCreche__c, SBQQ__Type__c, LPCR_RecalculationMACDone__c   FROM SBQQ__Quote__c WHERE SBQQ__Status__c =\'Prêt pour commande\' AND SBQQ__Ordered__c  = false';
        
        return Database.getQueryLocator(query);
    }
    /*
    *   @description : this method generate Orders for the Quotes with SBQQ__Status__c = 'Prêt pour commande\' AND SBQQ__Ordered__c  = false', to generate order
    *   @param Database.BatchableContext BC, List<SBQQ__Quote__c> scope
    *   @returns void
    */
    global void execute(Database.BatchableContext BC, List<SBQQ__Quote__c> scope) {
        
        UM001_LogManager.writeLogActivityWithoutFuture( ClassName, 'Scope size', 'Batch' , null, String.valueOf(scope.size()), UM010_Constant.SUCCESS); 

        List<Exception> errors = new List<Exception>();
        try {
            String ErrMsg;

            try {
                updateRelatedQuotelines(scope);
                UM001_LogManager.writeLogActivityWithoutFuture( ClassName, 'Updating the quote lines',
                                                                'Batch' , null,
                                                                'Successfully updated (BonCommande) list of quote lines for the Quotes:(' + scope.size() + ')'+ UM003_TypeManager.getIdsOfListObjects(scope), 
                                                                UM010_Constant.SUCCESS);          
            } catch (Exception e) {
                ErrMsg = e.getMessage();
            } finally {
                if(ErrMsg != null && String.isNotBlank(ErrMsg)){
                    UM001_LogManager.writeLogActivityWithoutFuture(ClassName,  'Updating the quote lines','Batch' , null,'Error while updating list of quote lines (LPCR_LigneBonCommandeEnvoye__c=true)' + ErrMsg, UM010_Constant.ERROR);              
                }
            }
            ErrMsg = null;
            PAD.log(ClassName, 'execute','scope :'+ scope.size()+'');        
            
            Set<Id> quoteIds = UM003_TypeManager.getIdsOfListObjects(scope);
            List<SBQQ__Quote__c> listOfquote = [SELECT Id,SBQQ__Status__c ,SBQQ__Ordered__c, LPCR_TypeCreche__c, SBQQ__Type__c, LPCR_RecalculationMACDone__c     FROM SBQQ__Quote__c WHERE Id in :quoteIds];   
            List<LPCR_Log__c> listOfLog = new List<LPCR_Log__c>();
            
            for (SBQQ__Quote__c eachquote : listOfquote) {
                if(!(Label.LPCR_MAC.equals(eachquote.LPCR_TypeCreche__c) && Label.LPCR_Renewal.equals(eachquote.SBQQ__Type__c) && eachquote.LPCR_RecalculationMACDone__c == false)){
                    eachquote.SBQQ__Ordered__c = true;
                }
            }

            
            try {
                
                Database.SaveResult[] srList = Database.update(listOfquote,false);
                
                for (Integer i = 0; i < listOfquote.size(); i++){

                    Database.SaveResult s = srList[i];
                    SBQQ__Quote__c tmpQuote = listOfquote[i];

                    if (s.isSuccess()){
                        
                        listOfLog.add(UM001_LogManager.getWriteLogActivityForBulkInsert(ClassName,'APB003 - Quote Updated successfully (Set Ordered)',  'Batch', 'Successfully Updated : ' + tmpQuote.Id, tmpQuote.Id, 'SUCCESS'));
                
                    } else {

                        for(Database.Error err : s.getErrors()) {
                            String tmpErr = '';
                            tmpErr += 'The following error has occurred.\n';                    
                            tmpErr += err.getStatusCode() + ': ' + err.getMessage();
                            listOfLog.add(UM001_LogManager.getWriteLogActivityForBulkInsert(ClassName,'APB003 - Error in Quote Update (Set Ordered)',  'Batch', tmpQuote.Id, tmpErr, 'ERROR'));
                        }
                     }
                }

            } catch (Exception e) {
                ErrMsg = e.getMessage();
            } finally {
                if(ErrMsg != null && String.isNotBlank(ErrMsg)){
                    UM001_LogManager.writeLogActivityWithoutFuture(ClassName, 'APB003 - Batch for checking the box ordered on the quote', 'Batch' , null,'Error while updating the quotes : ' + ErrMsg, UM010_Constant.ERROR);              
                }
            }
            
            ErrMsg = null ;
            try {
                insert listOfLog;
                         
            } catch (Exception e) {
                ErrMsg = e.getMessage();
            } finally {
                if(ErrMsg != null && String.isNotBlank(ErrMsg)){
                    UM001_LogManager.writeLogActivityWithoutFuture(ClassName, 'APB003 - Batch for checking the box ordered on the quote', 'Batch' , null,'Error while inserting the logs : ' + ErrMsg, UM010_Constant.ERROR);              
                }
            }

        } catch(Exception e) {
            errors.add(e);
        }
        
        if (!errors.isEmpty()) {
            UM001_LogManager.writeLogActivityWithoutFuture(ClassName, 'execute', 'Batch' , null,'Processing with errors occurred : ' + errors, UM010_Constant.ERROR);
        }
            
    }

    global void updateRelatedQuotelines(List<SBQQ__Quote__c> quotes){

        Id referencementRecTypeId = EM003_RecordTypeEntity.getRecTypeIdByObjectAndName(Label.LPCR_Quote,Label.LPCR_Referencement);
        Id referencementApprRecTypeId = EM003_RecordTypeEntity.getRecTypeIdByObjectAndName(Label.LPCR_Quote,Label.LPCR_Referencement_Approuve);

        //Gather refer quotes that their LPCR_BonCommandeEnvoye__c changed to true.
        List<SBQQ__Quote__c> quotesToProcess = new List<SBQQ__Quote__c>();
        for(SBQQ__Quote__c q : quotes){
            
            if( (q.LPCR_BonCommandeEnvoye__c == true) &&
                (q.RecordTypeId == referencementRecTypeId || q.RecordTypeId == referencementApprRecTypeId)                 
                ){
                    quotesToProcess.add(q); 
            }
        }
        //Retrieve their quotesLines having LPCR_LigneBonCommandeEnvoye__c = false and set it to true
        Set<Id> idsQuotes = UM003_TypeManager.getIdsOfListObjects(quotesToProcess);
        List<SBQQ__QuoteLine__c> qLines = [  SELECT id,LPCR_LigneBonCommandeEnvoye__c 
                                            FROM SBQQ__QuoteLine__c 
                                            WHERE SBQQ__Quote__c IN :idsQuotes AND LPCR_LigneBonCommandeEnvoye__c=false];
                                            
        if( !UM003_TypeManager.isNullOrEmpty(qLines)){
            
            for (SBQQ__QuoteLine__c ql : qLines) {
                ql.LPCR_LigneBonCommandeEnvoye__c = true;
            }
            // Disabling TriggerControl in order to avoid launching recalculation
            SBQQ.TriggerControl.disable();
            update qLines;
            SBQQ.TriggerControl.enable();
        }
    }
    
    global void finish(Database.BatchableContext BC) {
        UM001_LogManager.writeLogActivityWithoutFuture(ClassName,'finish', 'Batch' , null, 'Finished Batch Processing', UM010_Constant.SUCCESS);
    }
    /*
    *   @description : this method execute the batch
    *   @param SchedulableContext sc
    *   @returns void
    */
    global void execute(SchedulableContext sc) {
        PAD.log(ClassName, 'execute','sc ');     
        APB003_CreateOrderFromQuote sc1 = new APB003_CreateOrderFromQuote();
        Datetime dt = Datetime.now().addMinutes(30);  // i.e. 30 mins
        String timeForScheduler = dt.format('s m H d M \'?\' yyyy');
        // schedule the apex class only if their is not existing job running
        boolean isBatchJobRunning = UM004_BatchUtility.isBatchJobRunning(ClassName);
        
        // check if there is any open place to schedule the class
        boolean isJobQueueFull = UM004_BatchUtility.isBatchJobQueueFull();
        
        if(isBatchJobRunning == UM004_BatchUtility.BOOLEAN_FALSE){
            if (isJobQueueFull == UM004_BatchUtility.BOOLEAN_FALSE) {
                sc1 = new APB003_CreateOrderFromQuote();
                Database.executeBatch(this, 1);
            } else {
                //schedule this same schedulable class again in 30 mins
                Id schedId = System.Schedule(ClassName+timeForScheduler,timeForScheduler,new APB003_CreateOrderFromQuote());
            }
        }  
        
    } 
}
