/**
* @author Ayoub Ouarti
* @date 18/03/2020
* @Description Batch for Activating the order
*/
global class APB004_ActivateOrder  implements Database.Batchable<sObject>,Schedulable {
    
    String query;
    final String ClassName = APB004_ActivateOrder.class.getName();
    global List<Order> inputOrderList;
    global String lot;

    global APB004_ActivateOrder() {
        lot = '';  
    }

    global APB004_ActivateOrder(List<Order> inputOrderListParam, String lotParam) {
        
        inputOrderList = inputOrderListParam;
        lot = ' - LOT:' + lotParam;
    }
    
    global Database.QueryLocator start(Database.BatchableContext BC) {
        
        UM001_LogManager.writeLogActivityWithoutFuture(ClassName,'start' + lot, 'Batch' , null, 'Starting Batch', UM010_Constant.SUCCESS);

        // Serial Mode for the whole scope
        if (inputOrderList == null) {

            query = 'SELECT Id,Status FROM Order WHERE Status =\'Draft\'';
            return Database.getQueryLocator(query);
        }
        // Parallel mode used to process higher volume of order at the same time
        Set<Id> tmpSet = UM003_TypeManager.getIdsOfListObjects(inputOrderList);
        return Database.getQueryLocator([SELECT Id,Status FROM Order WHERE Id in :tmpSet]);

    }
    
    global void execute(Database.BatchableContext BC, List<Order> scope) {

        UM001_LogManager.writeLogActivityWithoutFuture(ClassName,'execute' + lot, 'Batch' , null, 'Scope size : '  + scope.size(), UM010_Constant.SUCCESS); 
        
        List<Exception> errors = new List<Exception>();
        try {
            PAD.log(ClassName, 'execute','scope to execute : ' + scope );
            
            Set<Id> orderIds = UM003_TypeManager.getIdsOfListObjects(scope);
            List<Order> listOforder = [SELECT Id,Status FROM Order WHERE Id in :orderIds ];   
            List<LPCR_Log__c> listOfLog = new List<LPCR_Log__c>();
            
            for (Order eachOrder : listOforder) {
                
                eachOrder.status ='Activated';
                listOfLog.add(UM001_LogManager.getWriteLogActivityForBulkInsert('Activating Order', ClassName, 'Batch' + lot, String.valueOf(eachOrder.Id), '', 'SUCCESS'));            
            }
            
            String ErrMsg;
            try {
                update listOforder;
                UM001_LogManager.writeLogActivityWithoutFuture( 'Batch for Activating the order',
                                                                ClassName, 'Batch' + lot, null,
                                                                'Successfully updated list of orders : ' + String.valueOf(listOforder), 
                                                                UM010_Constant.SUCCESS);          
            } catch (Exception e) {
                ErrMsg = e.getMessage();
            } finally {
                if(ErrMsg != null && String.isNotBlank(ErrMsg)){
                    UM001_LogManager.writeLogActivityWithoutFuture( 'Batch for Activating the order',ClassName, 'Batch' + lot, null,'Error while updating the orders : ' + ErrMsg, UM010_Constant.ERROR);              
                }
            }
            
            ErrMsg = null ;
            try {
                insert listOfLog;
                UM001_LogManager.writeLogActivityWithoutFuture( 'Batch for Activating the order',
                                                                ClassName, 'Batch' + lot, null,
                                                                'Successfully inserted list of logs : ' + String.valueOf(listOfLog), 
                                                                UM010_Constant.SUCCESS);          
            } catch (Exception e) {
                ErrMsg = e.getMessage();
            } finally {
                if(ErrMsg != null && String.isNotBlank(ErrMsg)){
                    UM001_LogManager.writeLogActivityWithoutFuture( 'Batch for Activating the order',ClassName, 'Batch' + lot , null,'Error while inserting the logs : ' + ErrMsg, UM010_Constant.ERROR);              
                }
            }
        } catch(Exception e) {
            errors.add(e);
        }
        
        if (!errors.isEmpty()) {
            UM001_LogManager.writeLogActivityWithoutFuture(ClassName, 'execute', 'Batch' + lot , null,'Processing with errors occurred : ' + errors, UM010_Constant.ERROR);
        }
    }
    
    global void finish(Database.BatchableContext BC) {
        UM001_LogManager.writeLogActivityWithoutFuture(ClassName,'finish', 'Batch' + lot , null, 'Finished Batch Processing', UM010_Constant.SUCCESS);
    }
    
    global void execute(SchedulableContext sc) {
        
        Datetime dt = Datetime.now().addMinutes(30);  // i.e. 30 mins
        String timeForScheduler = dt.format('s m H d M \'?\' yyyy');
        
        APB004_ActivateOrder sc1 = new APB004_ActivateOrder();
        
        // schedule the apex class only if their is not existing job running
        boolean isBatchJobRunning = UM004_BatchUtility.isBatchJobRunning('APB003_CreateOrderFromorder');
        
        // check if there is any open place to schedule the class
        boolean isJobQueueFull = UM004_BatchUtility.isBatchJobQueueFull();
        
        if(isBatchJobRunning == UM004_BatchUtility.BOOLEAN_FALSE){
            if (isJobQueueFull == UM004_BatchUtility.BOOLEAN_FALSE) {
                sc1 = new APB004_ActivateOrder();
                Database.executeBatch(this, 1);
            } else {
                //schedule this same schedulable class again in 30 mins
                Id schedId = System.Schedule('APB004_ActivateOrder'+timeForScheduler,timeForScheduler,new APB004_ActivateOrder());
            }
        }  
        
    } 
}