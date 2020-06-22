/**
* @author Saurabh
* @date 19/06/2020
* @Description IS-981 Batch for Order Product
*/
global class APB010_ProcessDailyOrderProduct implements Database.Batchable<sObject>,Schedulable  {
    String query;
    
    global APB010_ProcessDailyOrderProduct() {
        
    }
    
    global Database.QueryLocator start(Database.BatchableContext BC) {
        return Database.getQueryLocator([SELECT Id, OrderId, TotalPrice, blng__BillableUnitPrice__c, SBQQ__BillingFrequency__c, blng__NextChargeDate__c,SBQQ__Contract__r.LPCR_DateFin__c, Order.LPCR_BDOM_OrderStartdate__c FROM OrderItem WHERE Order.Status = 'Activated' AND  CreatedDate = TODAY]);
    }
    
    global void execute(Database.BatchableContext BC, List<OrderItem> scope) {
        System.debug('scope to execute : '+scope);
        
        Set<Id> orderItemIds = UM003_TypeManager.getIdsOfListObjects(scope);
        Set<Id> selectedOrderItemId = new Set<Id>();
        
        Map<Id, List<blng__BillingTransaction__c>> billingTransactionMap = new Map<Id, List<blng__BillingTransaction__c>>();
        Map<Id, LPCR_PlanFacturation__c> billingPlanMap = new Map<Id, LPCR_PlanFacturation__c>();
        
        List<LPCR_LignePlanFacturation__c> billingPlanLineList = new List<LPCR_LignePlanFacturation__c>();
        
        for(OrderItem eachOrderItem : scope){
            LPCR_PlanFacturation__c billingPlan = new LPCR_PlanFacturation__c();
            billingPlan.LPCR_OrderItem__c = eachOrderItem.Id;
            billingPlan.LPCR_BillingFrequency__c = eachOrderItem.SBQQ__BillingFrequency__c;
            billingPlanMap.put(eachOrderItem.Id,billingPlan);
            
            if(eachOrderItem.SBQQ__BillingFrequency__c == 'Invoice Plan') {
                selectedOrderItemId.add(eachOrderItem.Id);
            }
        }
        
        if(billingPlanMap.size() > 0){
            // insert billing plan for order product
            insert billingPlanMap.values();
        }
        
        for(blng__BillingTransaction__c eachTransaction : [SELECT Id, Name, blng__BillingSchedule__r.blng__OrderProduct__c, blng__BillingTargetDate__c FROM blng__BillingTransaction__c WHERE blng__BillingSchedule__r.blng__OrderProduct__c IN: selectedOrderItemId ]){
            if(billingTransactionMap.containsKey(eachTransaction.blng__BillingSchedule__r.blng__OrderProduct__c)){
                billingTransactionMap.put(eachTransaction.blng__BillingSchedule__r.blng__OrderProduct__c, new List<blng__BillingTransaction__c>());
            }
            billingTransactionMap.get(eachTransaction.blng__BillingSchedule__r.blng__OrderProduct__c).add(eachTransaction);
        }
        
        for(OrderItem eachOrderItem : scope) {
            if(eachOrderItem.SBQQ__BillingFrequency__c != 'Invoice Plan') {
                Date tmpDate = eachOrderItem.blng__NextChargeDate__c;
                Integer diffBetweenMonths = System.today().monthsBetween(eachOrderItem.SBQQ__Contract__r.LPCR_DateFin__c) + 1;
                Integer intervel = 1;
                
                if('Quarterly'.equals(eachOrderItem.SBQQ__BillingFrequency__c)){
                    intervel = 3;
                }else if('Semiannual'.equals(eachOrderItem.SBQQ__BillingFrequency__c)){
                    intervel = 6; 
                }
                
                for(integer i = 1 ; i <= diffBetweenMonths ; i+=intervel){
                    LPCR_LignePlanFacturation__c newPlanLine = new LPCR_LignePlanFacturation__c();
                    newPlanLine.LPCR_OrderItem__c = eachOrderItem.Id;
                    newPlanLine.LPCR_BillingFrequency__c = eachOrderItem.SBQQ__BillingFrequency__c;
                    newPlanLine.LPCR_StartDate__c = tmpDate;
                    
                    if(billingPlanMap.containsKey(eachOrderItem.Id)){
                        newPlanLine.LPCR_PlanFacturation__c = billingPlanMap.get(eachOrderItem.Id).Id; 
                    }
                    if(eachOrderItem.Order.LPCR_BDOM_OrderStartdate__c){
                        newPlanLine.LPCR_EndDate__c = tmpDate.addMonths(intervel);
                    }else{
                        newPlanLine.LPCR_EndDate__c = Date.newInstance(tmpDate.Year(), tmpDate.month() + intervel , Date.daysInMonth(tmpDate.year(), tmpDate.month() + intervel));
                    } 
                    billingPlanLineList.add(newPlanLine);
                }
            }else{
                // If Billing Frequency is Invoice Plan
                if(billingTransactionMap.containsKey(eachOrderItem.Id)){
                    for(blng__BillingTransaction__c eachTransaction : billingTransactionMap.get(eachOrderItem.Id)){
                        LPCR_LignePlanFacturation__c newPlanLine = new LPCR_LignePlanFacturation__c();
                        newPlanLine.LPCR_OrderItem__c = eachOrderItem.Id;
                        newPlanLine.LPCR_BillingFrequency__c = eachOrderItem.SBQQ__BillingFrequency__c;
                        newPlanLine.LPCR_StartDate__c = eachTransaction.blng__BillingTargetDate__c;
                        newPlanLine.LPCR_EndDate__c = eachTransaction.blng__BillingTargetDate__c;
                        if(billingPlanMap.containsKey(eachOrderItem.Id)){
                            newPlanLine.LPCR_PlanFacturation__c = billingPlanMap.get(eachOrderItem.Id).Id; 
                        }
                    }
                }                
            }
        }        
    }
    
    global void finish(Database.BatchableContext BC) {
    }
    
    global void execute(SchedulableContext sc) {
        
        APB010_ProcessDailyOrderProduct sc1 = new APB010_ProcessDailyOrderProduct();
        
        // schedule the apex class only if their is not existing job running
        boolean isBatchJobRunning = UM004_BatchUtility.isBatchJobRunning('APB010_ProcessDailyOrderProduct');
        
        // check if there is any open place to schedule the class
        boolean isJobQueueFull = UM004_BatchUtility.isBatchJobQueueFull();
        
        if(isBatchJobRunning == UM004_BatchUtility.BOOLEAN_FALSE){
            if (isJobQueueFull == UM004_BatchUtility.BOOLEAN_FALSE) {
                sc1 = new APB010_ProcessDailyOrderProduct();
                Database.executeBatch(this, 1);
            } else {
                //schedule this same schedulable class again in 30 mins
                sc1 = new APB010_ProcessDailyOrderProduct();
                Datetime dt = Datetime.now().addMinutes(30);  // i.e. 30 mins
                String timeForScheduler = dt.format('s m H d M \'?\' yyyy');
                Id schedId = System.Schedule('APB010_ProcessDailyOrderProduct'+timeForScheduler,timeForScheduler,sc1);
            }
        }  
        
    }
    
}