/**
* @author Saurabh
* @date 19/06/2020
* @Description IS-981 Batch for Set Fields on Order Product and Delete the Billing Plan + Billing Plan Line records associated to the Order Product
*/ 
global class APB013_ProcessYearlyOrderProduct implements Database.Batchable<sObject>,Schedulable {
    String query;
    
    global APB013_ProcessYearlyOrderProduct() {
        
    }
    
    global Database.QueryLocator start(Database.BatchableContext BC) {

        return Database.getQueryLocator([SELECT Id, OrderId, EndDate, SBQQ__Activated__c, LPCR_BillingPlanProcessment__c 
                                            FROM OrderItem 
                                            WHERE SBQQ__Activated__c = true AND EndDate > TODAY]);
    }
    
    global void execute(Database.BatchableContext BC, List<OrderItem> scope) {

        PAD.log('APB013_ProcessYearlyOrderProduct', 'execute', 'scope to execute : '+scope);
        Set<Id> orderItemIds = UM003_TypeManager.getIdsOfListObjects(scope);
        
        for (OrderItem eachOrderItem : scope) {
            eachOrderItem.LPCR_BillingPlanProcessment__c = false;
        }       
        String ErrMsg;
        try {
            update scope;
            UM001_LogManager.writeLogActivityWithoutFuture( 'Batch for Set Fields on Order Product and Delete the Billing Plan',
                                                            'APB013_ProcessYearlyOrderProduct', 'Batch' , null,
                                                            'Successfully updated list of Order items : ' + String.valueOf(scope), 
                                                            UM010_Constant.SUCCESS);  
            PAD.log('APB013_ProcessYearlyOrderProduct', 'execute', 'OrderItems Update Success. List : ' + scope);

        } catch (Exception e) {
            ErrMsg = e.getMessage();
        } finally {
            if(ErrMsg != null && String.isNotBlank(ErrMsg)){
                UM001_LogManager.writeLogActivityWithoutFuture( 'Batch for Set Fields on Order Product and Delete the Billing Plan','APB013_ProcessYearlyOrderProduct', 'Batch' , null,'Error while updating the order items. Error : ' + ErrMsg, UM010_Constant.ERROR);              
            }
        }
        
        List<LPCR_PlanFacturation__c> delBillingPlanList = [SELECT id, LPCR_OrderItem__c FROM LPCR_PlanFacturation__c WHERE LPCR_OrderItem__c IN: orderItemIds ];

        if(delBillingPlanList.size() > 0){
            ErrMsg = null;
            try {
                delete delBillingPlanList;
                PAD.log('APB013_ProcessYearlyOrderProduct', 'execute', 'Deleted Billing plan list : ' + delBillingPlanList);
                UM001_LogManager.writeLogActivityWithoutFuture( 'Batch for Set Fields on Order Product and Delete the Billing Plan',
                                                                'APB013_ProcessYearlyOrderProduct', 'Batch' , null,
                                                                'Successfully deleted billing plan list : ' + String.valueOf(delBillingPlanList), 
                                                                UM010_Constant.SUCCESS);  
            } catch (Exception e) {
                ErrMsg = e.getMessage();
            } finally {
                if(ErrMsg != null && String.isNotBlank(ErrMsg)){
                    UM001_LogManager.writeLogActivityWithoutFuture( 'Batch for Set Fields on Order Product and Delete the Billing Plan','APB013_ProcessYearlyOrderProduct', 'Batch' , null,'Error while deleting billing plan list. Error : ' + ErrMsg, UM010_Constant.ERROR);              
                }
            }
        }   
    }
    
    global void finish(Database.BatchableContext BC) {
    }
    
    global void execute(SchedulableContext sc) {
        Datetime dt = Datetime.now().addMinutes(30);  // i.e. 30 mins
        String timeForScheduler = dt.format('s m H d M \'?\' yyyy');
        APB013_ProcessYearlyOrderProduct sc1 = new APB013_ProcessYearlyOrderProduct();
        
        // schedule the apex class only if their is not existing job running
        boolean isBatchJobRunning = UM004_BatchUtility.isBatchJobRunning('APB013_ProcessYearlyOrderProduct');
        
        // check if there is any open place to schedule the class
        boolean isJobQueueFull = UM004_BatchUtility.isBatchJobQueueFull();
        
        if(isBatchJobRunning == UM004_BatchUtility.BOOLEAN_FALSE){
            if (isJobQueueFull == UM004_BatchUtility.BOOLEAN_FALSE) {
                sc1 = new APB013_ProcessYearlyOrderProduct();
                Database.executeBatch(this, 1);
            } else {
                //schedule this same schedulable class again in 30 mins
                Id schedId = System.Schedule('APB013_ProcessYearlyOrderProduct'+timeForScheduler,timeForScheduler,new APB013_ProcessYearlyOrderProduct());
            }
        }  
        
    } 
    
}
