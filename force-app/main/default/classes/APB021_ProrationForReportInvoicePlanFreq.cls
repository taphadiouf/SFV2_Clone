/**
* @author Erwan Yhuellou
* @date 22/02/2021
* @Description Batch Logic to populate and adjust the LPCR_Amount__c field on the Revenue Transaction accordingly to what LPCR wants
*/
global class APB021_ProrationForReportInvoicePlanFreq implements Database.Batchable<sObject>,Schedulable {
    
    String query;
    final String ClassName = APB021_ProrationForReportInvoicePlanFreq.class.getName();

    global APB021_ProrationForReportInvoicePlanFreq() {
        
    }
    
    global Database.QueryLocator start(Database.BatchableContext BC) {

        UM001_LogManager.writeLogActivityWithoutFuture(ClassName,'start', 'Batch' , null, 'Starting Batch', UM010_Constant.SUCCESS);
        return Database.getQueryLocator([SELECT Id, Name, blng__Amount__c, blng__OverrideAmount__c, blng__BillingSchedule__c,
                                                blng__BillingTargetDate__c, blng__OverrideBillingTargetDate__c, blng__BillingSchedule__r.blng__OrderProduct__c 
                                                FROM blng__BillingTransaction__c 
                                                WHERE blng__BillingSchedule__r.blng__OrderProduct__c != null AND LPCR_ProcessProrate__c = false]);
    }

    global void execute(Database.BatchableContext BC, List<blng__BillingTransaction__c> scope) {

        UM001_LogManager.writeLogActivityWithoutFuture(ClassName,'execute', 'Batch' , null, 'Scope size : '  + scope.size(), UM010_Constant.SUCCESS); 
        List<blng__RevenueTransaction__c> revenueTransactionToUpdate = new List<blng__RevenueTransaction__c>();
        List<Exception> errors = new List<Exception>();
        String ErrMsg = '';

        try {

            PAD.log('APB021_ProrationForReportInvoicePlanFreq','execute','scope to execute : ' + scope);
            revenueTransactionToUpdate.addAll(processRevenueTransactionForInvoicePlan(scope));

            try {
                update revenueTransactionToUpdate;
                PAD.log('APB021_ProrationForReportInvoicePlanFreq','execute','blng__RevenueTransaction__c list Update success. list : ' + revenueTransactionToUpdate);
                UM001_LogManager.writeLogActivityWithoutFuture(ClassName, 'execute', 'Batch' , null, 'Successfully updated : ' + String.valueOf(revenueTransactionToUpdate),  UM010_Constant.SUCCESS);     
            } 
            catch (Exception e) {
                ErrMsg = e.getMessage();
            } 
            finally {
                if(ErrMsg != null && String.isNotBlank(ErrMsg)){
                    UM001_LogManager.writeLogActivityWithoutFuture(ClassName, 'execute', 'Batch' , null,'Error updating. Error : ' + ErrMsg, UM010_Constant.ERROR);              
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
        
    } 

    /* Method : processRevenueTransactionForInvoicePlan

        Loop through each BT (+ billing schedule (+ orderitem.Id))

        For each Orderitem loop through each RT

            // Eembed this part in logic which can be also called from Apex trigger
            Depending on date of BT 
                
                if (BT.blng__OverrideBillingTargetDate__c != null)

                    1) if RT exists with RT.blng__RevenueFinancePeriod__c.startDate.<Yearmonth> = BT.blng__OverrideBillingTargetDate__c.<Yearmonth>
                        get RT reference Id
                    2) else create a new RT (based on a clone with different period and amount)

                    3) if BT.blng__OverrideAmount__c != null
                            Set RT.LPCR__Amount with  BT.blng__OverrideAmount__c                       
                        else 
                            Set RT.LPCR__Amount with  BT.blng__Amount__c  
                else 

                    do 1) 2) 3) replacing at step 1) BT.blng__OverrideBillingTargetDate__c with BT.blng__BillingTargetDate__c

        return Database.getQueryLocator([SELECT Id, Name, blng__Amount__c, blng__OverrideAmount__c, blng__BillingSchedule__c,
                                                blng__BillingTargetDate__c, blng__OverrideBillingTargetDate__c, blng__BillingSchedule__r.blng__OrderProduct__c 
                                                FROM blng__BillingTransaction__c 
                                                WHERE blng__BillingSchedule__r.blng__OrderProduct__c != null]);
    */
    private List<blng__RevenueTransaction__c> processRevenueTransactionForInvoicePlan(List<blng__BillingTransaction__c> tmpBillingTransactionList) {

        //Create Respective Revenue Transaction List by getting scope of order id
        Set<Id> setOrderIds = UM003_TypeManager.getIdsOfListObjects(tmpBillingTransactionList, 'blng__BillingSchedule__r.blng__OrderProduct__c');
        List<blng__RevenueTransaction__c> tmpListRevTransaction = new List<blng__RevenueTransaction__c>([SELECT Id, blng__RevenueFinancePeriod__r.blng__PeriodStartDate__c, blng__OrderProduct__c 
                                                                                                            FROM blng__RevenueTransaction__c WHERE blng__OrderProduct__c in :setOrderIds ]);

        // Map of List<blng__RevenueTransaction__c> grouped by orderItem.Id
        Map<Id, List<blng__RevenueTransaction__c>> mapOrderItemRevTransactions = new Map<Id, List<blng__RevenueTransaction__c>>();
        for (blng__RevenueTransaction__c tmpRt : tmpListRevTransaction) {
            if (!mapOrderItemRevTransactions.containsKey(tmpRt.blng__OrderProduct__c)) {
                mapOrderItemRevTransactions.put(tmpRt.blng__OrderProduct__c, new List<blng__RevenueTransaction__c>());
            }
            mapOrderItemRevTransactions.get(tmpRt.blng__OrderProduct__c).add(tmpRt);
        }

        List<blng__RevenueTransaction__c> tmpListRevTransactionToUpdate = new List<blng__RevenueTransaction__c>();

        for (blng__BillingTransaction__c bt : tmpBillingTransactionList) {

            for (blng__RevenueTransaction__c rt : tmpListRevTransaction) {

                if (bt.blng__BillingSchedule__r.blng__OrderProduct__c == rt.blng__OrderProduct__c) {

                    String BtMonthYear = bt.blng__OverrideBillingTargetDate__c.year() + '-' + bt.blng__OverrideBillingTargetDate__c.month();
                    String RtMonthYear = rt.blng__RevenueFinancePeriod__r.blng__PeriodStartDate__c.year() + '-' + rt.blng__RevenueFinancePeriod__r.blng__PeriodStartDate__c.month();
                    Decimal tmpAmount = (bt.blng__OverrideAmount__c != null) ? bt.blng__OverrideAmount__c : bt.blng__Amount__c;
                    List<blng__RevenueTransaction__c> tmpElements = new List<blng__RevenueTransaction__c>();

                    tmpElements = detectUpdateOrCreateRevenueTransaction(mapOrderItemRevTransactions.get(rt.blng__OrderProduct__c), rt.blng__OrderProduct__c, BtMonthYear, tmpAmount);
                    tmpListRevTransactionToUpdate.addAll(tmpElements);
                }
            }

        }

        return tmpListRevTransactionToUpdate;
    }

    private List<blng__RevenueTransaction__c> detectUpdateOrCreateRevenueTransaction(List<blng__RevenueTransaction__c> tmpListRevTransaction, Id tmpOrderItemId, String tmpBtMonthYear, Decimal tmpAmount) {

        List<blng__RevenueTransaction__c> tmpResult = new List<blng__RevenueTransaction__c>();
        Boolean revenueTransactionDetected = false;
        blng__RevenueTransaction__c lastRt;

        for (blng__RevenueTransaction__c tmpRt : tmpListRevTransaction) {

            String RtMonthYear = tmpRt.blng__RevenueFinancePeriod__r.blng__PeriodStartDate__c.year() + '-' + tmpRt.blng__RevenueFinancePeriod__r.blng__PeriodStartDate__c.month();

            if (tmpBtMonthYear == RtMonthYear) {
                tmpResult.add(new blng__RevenueTransaction__c(Id = tmpRt.Id, LPCR_Amount__c = tmpAmount));
                revenueTransactionDetected = true;
            }
            lastRt = tmpRt;
        }

        if (!revenueTransactionDetected) {
            blng__RevenueTransaction__c newRt = lastRt.clone(false, false, false, false);
            newRt.LPCR_Amount__c = tmpAmount;  
            tmpResult.add(newRt);         
        }

        return tmpResult;
    }
}
