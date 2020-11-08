/**
* @author Saurabh
* @date 06/08/2020
* @Description Batch for Process Amended Billing Plan Lines
*/
 
global class APB015_ProcessBillingPlanLines implements Database.Batchable<sObject>,Schedulable{
    String query;
    
    global APB015_ProcessBillingPlanLines() {
        
    }
    
    global Database.QueryLocator start(Database.BatchableContext BC) {
        return Database.getQueryLocator(
            [SELECT Id, OrderId, TotalPrice,SBQQ__DefaultSubscriptionTerm__c,LPCR_Uplift__c,LPCR_ContractStartDate__c,LPCR_ContractEndDate__c,ServiceDate,EndDate, 
                    blng__BillableUnitPrice__c, SBQQ__BillingFrequency__c,SBQQ__RevisedOrderProduct__r.SBQQ__BillingFrequency__c, blng__NextChargeDate__c,
                    SBQQ__Contract__c,SBQQ__Contract__r.LPCR_DateFin__c,SBQQ__QuoteLine__r.SBQQ__ProrateMultiplier__c,Order.LPCR_RenouvellementPlanFacture__c,
                    LPCR_BillingPlanProcessment__c,SBQQ__RevisedOrderProduct__c,SBQQ__RevisedOrderProduct__r.blng__LastChargeToDate__c,SBQQ__RevisedOrderProduct__r.Quantity,
                    SBQQ__TerminatedDate__c,SBQQ__RevisedOrderProduct__r.SBQQ__TerminatedDate__c,blng__PendingBillings__c,Quantity,SBQQ__RevisedOrderProduct__r.blng__PendingBillings__c 
                FROM OrderItem 
                    WHERE 
                        SBQQ__BillingFrequency__c != null AND 
                        SBQQ__RevisedOrderProduct__c != null AND 
                        LPCR_BillingPlanProcessment__c = false AND 
                        (
                            (SBQQ__BillingFrequency__c != 'Invoice Plan' AND SBQQ__TerminatedDate__c != null AND blng__PendingBillings__c < 0) OR 
                            (SBQQ__TerminatedDate__c != null AND SBQQ__BillingFrequency__c = 'Invoice Plan' AND Quantity < 0)
                        )
            ]);
    }
    
    global void execute(Database.BatchableContext BC, List<OrderItem> scope) {
        String ErrMsg;
        UM001_LogManager.writeLogActivityWithoutFuture( 'Batch for Process Amended Billing Plan Lines',
                                                        'APB015_ProcessBillingPlanLines', 'Batch' , null,
                                                        'Execute method started with scope : ' + String.valueOf(scope), 
                                                        UM010_Constant.SUCCESS); 
        PAD.log('APB015_ProcessBillingPlanLines', 'execute', 'scope to execute : ' + scope);
        // Managing proration in case of amendment (Monthly / Quarterly / Semi Annual)
        Map<Id, LPCR_PlanFacturation__c> billingPlanMap = new Map<Id, LPCR_PlanFacturation__c>();
        Map<Id, LPCR_PlanFacturation__c> rpBillingPlanMap = new Map<Id, LPCR_PlanFacturation__c>();
        List<LPCR_LignePlanFacturation__c> billingPlanLineList = new List<LPCR_LignePlanFacturation__c>();
        List<LPCR_LignePlanFacturation__c> tmpBillingPlanLineList = new List<LPCR_LignePlanFacturation__c>();
        Set<Id> selectedOrderItemId = new Set<Id>();
        Set<Id> revisedOrderProductId = new Set<Id>();
        Set<String> orderInvPlanIdsSet = new Set<String>();
        Map<Id, List<blng__BillingTransaction__c>> billingTransactionMap = new Map<Id, List<blng__BillingTransaction__c>>();
        Map<Id, List<blng__BillingTransaction__c>> rpBillingTransactionMap = new Map<Id, List<blng__BillingTransaction__c>>();

        for(OrderItem eachOrderItem : scope){

            // create billing plan record
            LPCR_PlanFacturation__c billingPlan = new LPCR_PlanFacturation__c();
            billingPlan.LPCR_OrderItem__c = eachOrderItem.Id;
            billingPlan.LPCR_BillingFrequency__c = eachOrderItem.SBQQ__BillingFrequency__c;
            //billingPlan.LPCR_TotalContractValue__c = totalFullYearPrice;
            billingPlan.LPCR_StartDate__c = eachOrderItem.ServiceDate;
            billingPlan.LPCR_EndDate__c = eachOrderItem.EndDate;
            billingPlanMap.put(eachOrderItem.Id, billingPlan);
            
            if(eachOrderItem.SBQQ__BillingFrequency__c != 'Invoice Plan' && eachOrderItem.SBQQ__TerminatedDate__c != null && eachOrderItem.blng__PendingBillings__c < 0){
                                               
                // create billing plan line record
                LPCR_LignePlanFacturation__c newBPLine = new LPCR_LignePlanFacturation__c();
                newBPLine.LPCR_Amount__c = eachOrderItem.blng__PendingBillings__c;
                newBPLine.LPCR_StartDate__c = eachOrderItem.ServiceDate;
                newBPLine.LPCR_EndDate__c = eachOrderItem.EndDate;
                newBPLine.LPCR_OrderItem__c = eachOrderItem.id;
                newBPLine.LPCR_BillingFrequency__c = eachOrderItem.SBQQ__BillingFrequency__c;
                newBPLine.LPCR_Quantity__c = eachOrderItem.Quantity;
                
                if(eachOrderItem.SBQQ__RevisedOrderProduct__c != null && newBPLine.LPCR_StartDate__c > eachOrderItem.SBQQ__RevisedOrderProduct__r.blng__LastChargeToDate__c){
                    eachOrderItem.LPCR_ExclureDuPlanFacturation__c = true; 
                }
                
                if(eachOrderItem.SBQQ__RevisedOrderProduct__c != null && eachOrderItem.SBQQ__RevisedOrderProduct__r.blng__LastChargeToDate__c < eachOrderItem.SBQQ__RevisedOrderProduct__r.SBQQ__TerminatedDate__c && eachOrderItem.SBQQ__RevisedOrderProduct__r.blng__PendingBillings__c > 0){
                    newBPLine.LPCR_EndDate__c = eachOrderItem.SBQQ__RevisedOrderProduct__r.SBQQ__TerminatedDate__c;
                    billingPlan.LPCR_EndDate__c = eachOrderItem.SBQQ__RevisedOrderProduct__r.SBQQ__TerminatedDate__c;
                }
                eachOrderItem.LPCR_TraitementLigneFacturationAvenant__c = true;
                billingPlanMap.put(eachOrderItem.Id, billingPlan);
                billingPlanLineList.add(newBPLine);
                
            }else if(eachOrderItem.SBQQ__TerminatedDate__c != null && eachOrderItem.SBQQ__BillingFrequency__c == 'Invoice Plan' && eachOrderItem.Quantity < 0){

                selectedOrderItemId.add(eachOrderItem.Id);
                if(eachOrderItem.SBQQ__RevisedOrderProduct__c != null){
                    revisedOrderProductId.add(eachOrderItem.SBQQ__RevisedOrderProduct__r.id);
                }                 
            }            
        }
        
        if(billingPlanMap.size() > 0){
            try {
                insert billingPlanMap.values();
                UM001_LogManager.writeLogActivityWithoutFuture( 'Batch for Process Amended Billing Plan Lines',
                                                        'APB015_ProcessBillingPlanLines', 'Batch' , null,
                                                        'Successfully inserted list of billing plan list : ' + String.valueOf(billingPlanMap.values()), 
                                                        UM010_Constant.SUCCESS); 
                PAD.log('APB015_ProcessBillingPlanLines', 'execute', 'Insert success of Billing Plan lines : ' + billingPlanMap.values());
            } catch (Exception e) {
                ErrMsg = e.getMessage();
                PAD.log('APB015_ProcessBillingPlanLines', 'execute', 'Insert Error of Billing Plan lines : ' + e.getMessage()+ '|Line :' + e.getLineNumber());
            }finally {
                if(ErrMsg != null && String.isNotBlank(ErrMsg)){
                    UM001_LogManager.writeLogActivityWithoutFuture( 'Batch for Process Amended Billing Plan Lines','APB015_ProcessBillingPlanLines', 'Batch' , null,'Error while inserting billing plan list. Error : ' + ErrMsg, UM010_Constant.ERROR);              
                }
            } 
        }
        
        // construct a map of Billing Transaction
        for(blng__BillingTransaction__c eachTransaction : [SELECT Id, Name,blng__Amount__c, blng__BillingSchedule__r.blng__OrderProduct__c, blng__BillingTargetDate__c,blng__OverrideBillingTargetDate__c 
                                                                FROM blng__BillingTransaction__c 
                                                                WHERE blng__BillingSchedule__r.blng__OrderProduct__c IN: selectedOrderItemId ]){
            
            if(!billingTransactionMap.containsKey(eachTransaction.blng__BillingSchedule__r.blng__OrderProduct__c)){
                billingTransactionMap.put(eachTransaction.blng__BillingSchedule__r.blng__OrderProduct__c, new List<blng__BillingTransaction__c>());
            }
            billingTransactionMap.get(eachTransaction.blng__BillingSchedule__r.blng__OrderProduct__c).add(eachTransaction);
        }
        
        for(blng__BillingTransaction__c eachTransaction : [SELECT Id, Name,blng__Amount__c, blng__BillingSchedule__r.blng__OrderProduct__c, blng__BillingTargetDate__c,blng__OverrideBillingTargetDate__c 
                                                                FROM blng__BillingTransaction__c 
                                                                WHERE blng__BillingSchedule__r.blng__OrderProduct__c IN: revisedOrderProductId AND blng__Status__c = 'Pending' ]){
            
            if(!rpBillingTransactionMap.containsKey(eachTransaction.blng__BillingSchedule__r.blng__OrderProduct__c)){
                rpBillingTransactionMap.put(eachTransaction.blng__BillingSchedule__r.blng__OrderProduct__c, new List<blng__BillingTransaction__c>());
            }
            rpBillingTransactionMap.get(eachTransaction.blng__BillingSchedule__r.blng__OrderProduct__c).add(eachTransaction);
        }
        
        
        for(OrderItem eachOrderItem : scope) {

            if(eachOrderItem.SBQQ__TerminatedDate__c != null && eachOrderItem.SBQQ__BillingFrequency__c == 'Invoice Plan' && eachOrderItem.Quantity < 0) {

                if(billingTransactionMap.containsKey(eachOrderItem.Id)){

                    for(blng__BillingTransaction__c eachTransaction : billingTransactionMap.get(eachOrderItem.Id)){

                        // create billing plan line record
                        LPCR_LignePlanFacturation__c newBPLine = new LPCR_LignePlanFacturation__c();
                        newBPLine.LPCR_Amount__c = eachTransaction.blng__Amount__c;
                        newBPLine.LPCR_StartDate__c = (eachTransaction.blng__OverrideBillingTargetDate__c != null)?eachTransaction.blng__OverrideBillingTargetDate__c:eachTransaction.blng__BillingTargetDate__c;
                        newBPLine.LPCR_EndDate__c = (eachTransaction.blng__OverrideBillingTargetDate__c != null)?eachTransaction.blng__OverrideBillingTargetDate__c:eachTransaction.blng__BillingTargetDate__c;
                        newBPLine.LPCR_OrderItem__c = eachOrderItem.id;
                        newBPLine.LPCR_BillingFrequency__c = eachOrderItem.SBQQ__BillingFrequency__c;
                        newBPLine.LPCR_Quantity__c = eachOrderItem.Quantity;
                        newBPLine.LPCR_PlanFacturation__c = billingPlanMap.get(eachOrderItem.id).id;
                        billingPlanLineList.add(newBPLine);
                        
                        if (eachOrderItem.SBQQ__RevisedOrderProduct__c != null && newBPLine.LPCR_StartDate__c > eachOrderItem.SBQQ__RevisedOrderProduct__r.SBQQ__TerminatedDate__c){
                            eachOrderItem.LPCR_ExclureDuPlanFacturation__c = true; 
                        }
                    }
                    eachOrderItem.LPCR_TraitementLigneFacturationAvenant__c = true;
                }
                
                if (rpBillingTransactionMap.containsKey(eachOrderItem.SBQQ__RevisedOrderProduct__c)){

                    Double sumAmount = 0;
                    Date overrideBillingTargetDate = null;
                    
                    // create billing plan record
                    LPCR_PlanFacturation__c billingPlan = new LPCR_PlanFacturation__c();
                    billingPlan.LPCR_OrderItem__c = eachOrderItem.SBQQ__RevisedOrderProduct__c;
                    billingPlan.LPCR_BillingFrequency__c = eachOrderItem.SBQQ__RevisedOrderProduct__r.SBQQ__BillingFrequency__c;
                    //billingPlan.LPCR_TotalContractValue__c = totalFullYearPrice;
                    
                    for (blng__BillingTransaction__c eachTransaction : rpBillingTransactionMap.get(eachOrderItem.SBQQ__RevisedOrderProduct__c)) {
                        sumAmount += eachTransaction.blng__Amount__c;
                        overrideBillingTargetDate = eachTransaction.blng__OverrideBillingTargetDate__c;
                    }
                    
                    billingPlan.LPCR_StartDate__c = eachOrderItem.ServiceDate;
                    billingPlan.LPCR_EndDate__c = eachOrderItem.EndDate;
                    rpBillingPlanMap.put(eachOrderItem.SBQQ__RevisedOrderProduct__c,billingPlan);
                    
                    // create billing plan line record
                    LPCR_LignePlanFacturation__c newBPLine = new LPCR_LignePlanFacturation__c();
                    newBPLine.LPCR_Amount__c = sumAmount;
                    newBPLine.LPCR_StartDate__c = overrideBillingTargetDate;
                    newBPLine.LPCR_EndDate__c = overrideBillingTargetDate;
                    newBPLine.LPCR_OrderItem__c = eachOrderItem.SBQQ__RevisedOrderProduct__c;
                    newBPLine.LPCR_BillingFrequency__c = eachOrderItem.SBQQ__BillingFrequency__c;
                    newBPLine.LPCR_Quantity__c = eachOrderItem.SBQQ__RevisedOrderProduct__r.Quantity;
                    //newBPLine.LPCR_PlanFacturation__c = billingPlanMap.get(eachOrderItem.id).id;
                    tmpBillingPlanLineList.add(newBPLine);
                }                
            }
        }
        
        // insert new billing plan record
        ErrMsg = null;
        if (rpBillingPlanMap.size() > 0) {
            try {
                insert rpBillingPlanMap.values();
                PAD.log('APB015_ProcessBillingPlanLines', 'execute', 'Insert success of Billing Plan lines : ' + rpBillingPlanMap.values());
                UM001_LogManager.writeLogActivityWithoutFuture( 'Batch for Process Amended Billing Plan Lines',
                                                                'APB015_ProcessBillingPlanLines', 'Batch' , null,
                                                                'Successfully inserted list of billing plan list : ' + String.valueOf(rpBillingPlanMap.values()), 
                                                                UM010_Constant.SUCCESS); 
                                                                
                for (LPCR_LignePlanFacturation__c eachBPLine : tmpBillingPlanLineList){

                    if (rpBillingPlanMap.containsKey(eachBPLine.LPCR_OrderItem__c)){

                        eachBPLine.LPCR_PlanFacturation__c = rpBillingPlanMap.get(eachBPLine.LPCR_OrderItem__c).Id;
                        billingPlanLineList.add(eachBPLine);
                    }
                }
            }catch(Exception ex){
                ErrMsg = ex.getMessage();
                PAD.log('APB015_ProcessBillingPlanLines', 'execute', 'Insert Error of Billing Plan lines : ' + ex.getMessage()+ '|Line :' + ex.getLineNumber());
            }finally {
                if(ErrMsg != null && String.isNotBlank(ErrMsg)){
                    UM001_LogManager.writeLogActivityWithoutFuture( 'Batch for Process Amended Billing Plan Lines','APB015_ProcessBillingPlanLines', 'Batch' , null,'Error while inserting billing plan list. Error : ' + ErrMsg, UM010_Constant.ERROR);              
                }
            } 
        }

        ErrMsg = null;
        // insert billing plan line list
        try {
            insert billingPlanLineList;
            UM001_LogManager.writeLogActivityWithoutFuture( 'Batch for Process Amended Billing Plan Lines',
                                                            'APB015_ProcessBillingPlanLines', 'Batch' , null,
                                                            'Successfully inserted list of billing plan lines : ' + String.valueOf(billingPlanLineList), 
                                                            UM010_Constant.SUCCESS); 
            PAD.log('APB015_ProcessBillingPlanLines', 'execute', 'Insert success of Billing Plan lines : ' + billingPlanLineList);
        } catch (Exception e) {
            ErrMsg = e.getMessage();
        } finally {
            if(ErrMsg != null && String.isNotBlank(ErrMsg)){
                UM001_LogManager.writeLogActivityWithoutFuture( 'Batch for Process Amended Billing Plan Lines','APB015_ProcessBillingPlanLines', 'Batch' , null,'Error while updating billing plan lines. Error : ' + ErrMsg, UM010_Constant.ERROR);              
            }
        }  
        
        // update order item
        ErrMsg = null;
        if(scope.size() > 0){
            try{
                update scope;
                UM001_LogManager.writeLogActivityWithoutFuture( 'Batch for Process Amended Billing Plan Lines',
                                                                'APB015_ProcessBillingPlanLines', 'Batch' , null,
                                                                'Successfully updated list of order items : ' + String.valueOf(scope), 
                                                                UM010_Constant.SUCCESS); 
                PAD.log('APB015_ProcessBillingPlanLines', 'execute', 'Update Success of Order items : ' + scope);
            }catch(Exception ex){
                ErrMsg = ex.getMessage();
                PAD.log('APB015_ProcessBillingPlanLines', 'execute', 'Update Error of Order items : ' + ex.getMessage() + '|Line :' + ex.getLineNumber());
            }finally {
                if(ErrMsg != null && String.isNotBlank(ErrMsg)){
                    UM001_LogManager.writeLogActivityWithoutFuture( 'Batch for Process Amended Billing Plan Lines','APB015_ProcessBillingPlanLines', 'Batch' , null,'Error while updating order items. Error : ' + ErrMsg, UM010_Constant.ERROR);              
                }
            }  
        }
   
    }
    
    global void finish(Database.BatchableContext BC) {
    }
    
    global void execute(SchedulableContext sc) {
        
        APB015_ProcessBillingPlanLines sc1 = new APB015_ProcessBillingPlanLines();
        Datetime dt = Datetime.now().addMinutes(30);  // i.e. 30 mins
        String timeForScheduler = dt.format('s m H d M \'?\' yyyy');
        // schedule the apex class only if their is not existing job running
        boolean isBatchJobRunning = UM004_BatchUtility.isBatchJobRunning('APB015_ProcessBillingPlanLines');
        
        // check if there is any open place to schedule the class
        boolean isJobQueueFull = UM004_BatchUtility.isBatchJobQueueFull();
        
        if(isBatchJobRunning == UM004_BatchUtility.BOOLEAN_FALSE){
            if (isJobQueueFull == UM004_BatchUtility.BOOLEAN_FALSE) {
                sc1 = new APB015_ProcessBillingPlanLines();
                Database.executeBatch(this, 1);
            } else {
                //schedule this same schedulable class again in 30 mins
                Id schedId = System.Schedule('APB015_ProcessBillingPlanLines'+timeForScheduler,timeForScheduler,new APB015_ProcessBillingPlanLines());
            }
        }  
        
    }
}