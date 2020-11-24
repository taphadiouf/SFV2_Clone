/**
* @author Ayoub Ouarti
* @date 19/03/2020
* @Description Batch for Generate the Contract from the order
*/
global class APB005_GenerateContractFromOrder  implements Database.Batchable<sObject>,Schedulable {
    String query;
    final String ClassName = APB005_GenerateContractFromOrder.class.getName();
    global APB005_GenerateContractFromOrder() {
        
    }
    
    global Database.QueryLocator start(Database.BatchableContext BC) {
        UM001_LogManager.writeLogActivityWithoutFuture(ClassName,'start', 'Batch' , null, 'Starting Batch', UM010_Constant.SUCCESS);
        query = 'SELECT Id,Status,SBQQ__Contracted__c FROM Order WHERE Status =\'Activated\' AND SBQQ__Contracted__c =false';
        
        return Database.getQueryLocator(query);
    }
    
    global void execute(Database.BatchableContext BC, List<Order> scope) {
        
        List<Exception> errors = new List<Exception>();
        try {
            
            PAD.log(ClassName, 'execute', 'scope to execute : '+scope);
            
            Set<Id> orderIds = UM003_TypeManager.getIdsOfListObjects(scope);
            List<OrderItem> orderItemList = [Select Id, orderId, blng__BillThroughDateOverride__c  from OrderItem where orderId in:orderIds];
            List<LPCR_Log__c> listOfLog = new List<LPCR_Log__c>();
            Map<id,Order> OrderOrderItemMap = new Map<id,Order> ([select id,Status,SBQQ__Contracted__c,SBQQ__Quote__r.LPCR_RepriseDateProchaineFacturation__c ,(Select Id, orderId, blng__BillThroughDateOverride__c  from OrderItems) from order where id in: orderIds]);
            
            for ( OrderItem eachOrderItem :orderItemList)
            {
                order eachOrder = OrderOrderItemMap.get(eachOrderItem.orderId);
                eachOrder.SBQQ__Contracted__c = true;
                if(eachOrder.SBQQ__Quote__r.LPCR_RepriseDateProchaineFacturation__c != null){
                    eachOrderItem.blng__BillThroughDateOverride__c =  eachOrder.SBQQ__Quote__r.LPCR_RepriseDateProchaineFacturation__c;
                }
                listOfLog.add(UM001_LogManager.getWriteLogActivityForBulkInsert('Generating Contract From Order', ClassName, 'Batch', String.valueOf(eachOrder.Id), '', 'SUCCESS'));            
            }

            String ErrMsg;
            try {
                update (OrderOrderItemMap.values());  
                UM001_LogManager.writeLogActivityWithoutFuture( 'Batch for Generate the Contract from the order',
                                                                ClassName, 'Batch' , null,
                                                                'Successfully updated list of order items : ' + String.valueOf(OrderOrderItemMap.values()), 
                                                                UM010_Constant.SUCCESS);          
            } catch (Exception e) {
                ErrMsg = e.getMessage();
            } finally {
                if(ErrMsg != null && String.isNotBlank(ErrMsg)){
                    UM001_LogManager.writeLogActivityWithoutFuture( 'Batch for Generate the Contract from the order',ClassName, 'Batch' , null,'Error while updating the order items : ' + ErrMsg, UM010_Constant.ERROR);              
                }
            }


            ErrMsg = null ;
            try {
                insert listOfLog;
                UM001_LogManager.writeLogActivityWithoutFuture( 'Batch for Generate the Contract from the order',
                                                                ClassName, 'Batch' , null,
                                                                'Successfully inserted list of logs : ' + String.valueOf(listOfLog), 
                                                                UM010_Constant.SUCCESS);          
            } catch (Exception e) {
                ErrMsg = e.getMessage();
            } finally {
                if(ErrMsg != null && String.isNotBlank(ErrMsg)){
                    UM001_LogManager.writeLogActivityWithoutFuture( 'Batch for Generate the Contract from the order',ClassName, 'Batch' , null,'Error while inserting the logs : ' + ErrMsg, UM010_Constant.ERROR);              
                }
            }

        } catch(Exception e) {
            errors.add(e);
        }
        
        if (!errors.isEmpty()) {
            UM001_LogManager.writeLogActivityWithoutFuture(ClassName, 'execute', 'Batch' , null,'Processing with errors occurred : ' + errors, UM010_Constant.ERROR);
        }
    }
    
    global void finish(Database.BatchableContext BC) {
        UM001_LogManager.writeLogActivityWithoutFuture(ClassName,'finish', 'Batch' , null, 'Finished Batch Processing', UM010_Constant.SUCCESS);
    }
    
    global void execute(SchedulableContext sc) {
        Datetime dt = Datetime.now().addMinutes(30);  // i.e. 30 mins
        String timeForScheduler = dt.format('s m H d M \'?\' yyyy');

        APB005_GenerateContractFromOrder sc1 = new APB005_GenerateContractFromOrder();
        
        // schedule the apex class only if their is not existing job running
        boolean isBatchJobRunning = UM004_BatchUtility.isBatchJobRunning('APB003_CreateOrderFromorder');
        
        // check if there is any open place to schedule the class
        boolean isJobQueueFull = UM004_BatchUtility.isBatchJobQueueFull();
        
        if(isBatchJobRunning == UM004_BatchUtility.BOOLEAN_FALSE){
            if (isJobQueueFull == UM004_BatchUtility.BOOLEAN_FALSE) {
                sc1 = new APB005_GenerateContractFromOrder();
                Database.executeBatch(this, 1);
            } else {
                //schedule this same schedulable class again in 30 mins
                Id schedId = System.Schedule(ClassName+timeForScheduler,timeForScheduler,new APB005_GenerateContractFromOrder());
            }
        }  
        
    } 
}