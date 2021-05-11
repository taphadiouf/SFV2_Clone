/**
* @author Erwan Yhuellou
* @date 22/02/2021
* @Description :
* Only For Invoice Plan
* Input : blng__BillingTransaction__c with blng__BillingSchedule__r.blng__OrderProduct__c != null AND LPCR_ProcessProrate__c = false
* Output : Populate and adjust the LPCR_Amount__c field on the Revenue Transaction accordingly to what LPCR wants
*/
global class APB021_ProrationForReportInvoicePlanFreq implements Database.Batchable<sObject>,Schedulable {
    
    String query;
    final String ClassName = APB021_ProrationForReportInvoicePlanFreq.class.getName();

    global APB021_ProrationForReportInvoicePlanFreq() {
        
    }
    
    global Database.QueryLocator start(Database.BatchableContext BC) {

        UM001_LogManager.writeLogActivityWithoutFuture(ClassName,'start', 'Batch' , null, 'Starting Batch', UM010_Constant.SUCCESS);
        return Database.getQueryLocator([SELECT Id, Name, blng__Amount__c, blng__OverrideAmount__c, blng__BillingSchedule__c,
                                                blng__BillingTargetDate__c, blng__OverrideBillingTargetDate__c, blng__BillingSchedule__r.blng__OrderProduct__c,
                                                blng__BillingSchedule__r.blng__OrderProduct__r.blng__LegalEntity__c 
                                                FROM blng__BillingTransaction__c 
                                                WHERE blng__BillingSchedule__r.blng__OrderProduct__c != null AND LPCR_ProcessProrate__c = false
                                                        ]);
    }

    global void execute(Database.BatchableContext BC, List<blng__BillingTransaction__c> scope) {

        UM001_LogManager.writeLogActivityWithoutFuture(ClassName,'execute', 'Batch' , null, 'Scope size : '  + scope.size(), UM010_Constant.SUCCESS); 
        List<blng__RevenueTransaction__c> revenueTransactionToUpdate = new List<blng__RevenueTransaction__c>();
        List<blng__BillingTransaction__c> btProcessed = new List<blng__BillingTransaction__c>();
        
        List<Exception> errors = new List<Exception>();
        String ErrMsg = '';

        try {

            PAD.log('APB021_ProrationForReportInvoicePlanFreq','execute','scope to execute : ' + scope);
            revenueTransactionToUpdate.addAll(processRevenueTransactionForInvoicePlan(scope));
            for (blng__BillingTransaction__c bt : scope) {
                btProcessed.add(new blng__BillingTransaction__c(Id = bt.Id, LPCR_ProcessProrate__c = true));
            }

            try {
                PAD.logAllList(ClassName,'execute','revenueTransactionToUpdate', revenueTransactionToUpdate);

                upsert revenueTransactionToUpdate;
                PAD.log(ClassName,'execute','blng__RevenueTransaction__c list Update success. list : ' + revenueTransactionToUpdate);
                UM001_LogManager.writeLogActivityWithoutFuture(ClassName, 'execute', 'Batch' , null, 'Successfully updated : ' + String.valueOf(revenueTransactionToUpdate),  UM010_Constant.SUCCESS);     

                update btProcessed;
                PAD.log(ClassName,'execute','btProcessed list Update success. list : ' + btProcessed);
                UM001_LogManager.writeLogActivityWithoutFuture(ClassName, 'execute', 'Batch' , null, 'Successfully updated : ' + String.valueOf(btProcessed),  UM010_Constant.SUCCESS);     

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
            UM001_LogManager.writeLogActivityWithoutFuture(ClassName, 'execute', 'Batch' , null,'Processing with errors occurred : ' + errors + showLineError(errors), UM010_Constant.ERROR);
        }
    }

    global String showLineError(List<Exception> errList) {
        String result = '';
        for (Exception tmpE : errList) {
            result += 'line:' + tmpE.getLineNumber();
        }
        return result;
    }

    global void finish(Database.BatchableContext BC) {
        UM001_LogManager.writeLogActivityWithoutFuture(ClassName,'finish', 'Batch' , null, 'Finished Batch Processing', UM010_Constant.SUCCESS);
    }
    
    global void execute(SchedulableContext sc) {
        
    } 

    /* Method : processRevenueTransactionForInvoicePlan

        Loop through each BT (+ billing schedule (+ orderitem.Id)) and For each Orderitem loop through each RT

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
    */
    private List<blng__RevenueTransaction__c> processRevenueTransactionForInvoicePlan(List<blng__BillingTransaction__c> tmpBillingTransactionList) {

        //Create Respective Revenue Transaction List by getting scope of order id
        Set<Id> setOrderIds = new Set<Id>();
        for (blng__BillingTransaction__c tmpBT : tmpBillingTransactionList) {
            setOrderIds.add(tmpBT.blng__BillingSchedule__r.blng__OrderProduct__c);
        }

        //Set<Id> setOrderIds = UM003_TypeManager.getIdsOfListObjects(tmpBillingTransactionList, 'blng__BillingSchedule__r.blng__OrderProduct__c');
        List<blng__RevenueTransaction__c> tmpListRevTransaction = new List<blng__RevenueTransaction__c>([SELECT Id, blng__LegalEntity__c, blng__RevenueFinancePeriod__r.blng__PeriodStartDate__c, blng__OrderProduct__c, blng__RevenueSchedule__c 
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

                    Integer tmpMonth = 0;
                    Integer tmpYear = 0;

                    PAD.log(ClassName,'processRevenueTransactionForInvoicePlan','Match  ***************************************************');
                    PAD.log(ClassName,'processRevenueTransactionForInvoicePlan','bt.blng__BillingSchedule__r.blng__OrderProduct__c == rt.blng__OrderProduct__c');

                    String BtMonthYear = (bt.blng__OverrideBillingTargetDate__c != null) ? bt.blng__OverrideBillingTargetDate__c.year() + '-' + bt.blng__OverrideBillingTargetDate__c.month() : '';
                    
                    if (bt.blng__OverrideBillingTargetDate__c != null) {
                        tmpMonth = bt.blng__OverrideBillingTargetDate__c.month(); 
                        tmpYear = bt.blng__OverrideBillingTargetDate__c.year(); 
                    }
                    else {
                        BtMonthYear = bt.blng__BillingTargetDate__c.year() + '-' + bt.blng__BillingTargetDate__c.month(); 
                        tmpMonth = bt.blng__BillingTargetDate__c.month(); 
                        tmpYear = bt.blng__BillingTargetDate__c.year();
                    }

                    Decimal tmpAmount = (bt.blng__OverrideAmount__c != null) ? bt.blng__OverrideAmount__c : bt.blng__Amount__c;
                    List<blng__RevenueTransaction__c> tmpElements = new List<blng__RevenueTransaction__c>();

                    PAD.log(ClassName,'processRevenueTransactionForInvoicePlan','mapOrderItemRevTransactions.get(bt.blng__BillingSchedule__r.blng__OrderProduct__c):' + mapOrderItemRevTransactions.get(bt.blng__BillingSchedule__r.blng__OrderProduct__c));
                    PAD.log(ClassName,'processRevenueTransactionForInvoicePlan','bt.blng__BillingSchedule__r.blng__OrderProduct__c:' + bt.blng__BillingSchedule__r.blng__OrderProduct__c);
                    PAD.log(ClassName,'processRevenueTransactionForInvoicePlan','BtMonthYear:' + BtMonthYear);
                    PAD.log(ClassName,'processRevenueTransactionForInvoicePlan','tmpAmount:' + tmpAmount);

                    tmpElements = detectUpdateOrCreateRevenueTransaction(mapOrderItemRevTransactions.get(bt.blng__BillingSchedule__r.blng__OrderProduct__c), bt.blng__BillingSchedule__r.blng__OrderProduct__c, BtMonthYear, tmpAmount, tmpMonth, tmpYear, bt.blng__BillingSchedule__r.blng__OrderProduct__r.blng__LegalEntity__c);
                    tmpListRevTransactionToUpdate.addAll(tmpElements);
        }
        
        return tmpListRevTransactionToUpdate;
    }

    private List<blng__RevenueTransaction__c> detectUpdateOrCreateRevenueTransaction(List<blng__RevenueTransaction__c> tmpListRevTransaction, Id tmpOrderItemId, String tmpBtMonthYear, Decimal tmpAmount, Integer tmpBtMonth, Integer tmpBtYear, Id legalEntityId) {

        List<blng__RevenueTransaction__c> tmpResult = new List<blng__RevenueTransaction__c>();
        Boolean revenueTransactionDetected = false;
        blng__RevenueTransaction__c lastRt;

        PAD.log(ClassName,'detectUpdateOrCreateRevenueTransaction','****************************** Starting');

        if (tmpListRevTransaction != null) {

            for (blng__RevenueTransaction__c tmpRt : tmpListRevTransaction) {

                String RtMonthYear = (tmpRt.blng__RevenueFinancePeriod__c != null) ? tmpRt.blng__RevenueFinancePeriod__r.blng__PeriodStartDate__c.year() + '-' + tmpRt.blng__RevenueFinancePeriod__r.blng__PeriodStartDate__c.month() : '';
                Integer rtYear = (tmpRt.blng__RevenueFinancePeriod__c != null) ? tmpRt.blng__RevenueFinancePeriod__r.blng__PeriodStartDate__c.year() : 0;
                Integer rtMonth = (tmpRt.blng__RevenueFinancePeriod__c != null) ? tmpRt.blng__RevenueFinancePeriod__r.blng__PeriodStartDate__c.month() : 0;

                if (tmpBtMonth == rtMonth && tmpBtYear == rtYear && tmpBtYear != 0 && tmpBtMonth != 0 ) {    

                    PAD.log(ClassName,'detectUpdateOrCreateRevenueTransaction','****************************** Match ');
                    PAD.log(ClassName,'detectUpdateOrCreateRevenueTransaction','****************************** tmpBtMonthYear == RtMonthYear ');

                    
                    tmpResult.add(new blng__RevenueTransaction__c(Id = tmpRt.Id, LPCR_Amount__c = tmpAmount, blng__RevenueFinancePeriod__c = tmpRt.blng__RevenueFinancePeriod__c));
                    revenueTransactionDetected = true;
                }
                lastRt = tmpRt;
            }
        

            if (!revenueTransactionDetected) {

                Date tmpStartDate = Date.newInstance(tmpBtYear, tmpBtMonth, 1);
                blng__FinancePeriod__c tmpFp = [SELECT Id, Name FROM blng__FinancePeriod__c 
                                                                            WHERE blng__LegalEntity__c = :legalEntityId AND blng__PeriodType__c  = 'Revenue' AND 
                                                                                    blng__PeriodStartDate__c = :tmpStartDate];
                
                PAD.log(ClassName,'detectUpdateOrCreateRevenueTransaction','****************************** !revenueTransactionDetected');
                PAD.log(ClassName,'detectUpdateOrCreateRevenueTransaction','tmpFp:' + tmpFp);

                blng__RevenueTransaction__c newRt = lastRt.clone(false, false, false, false);
                newRt.LPCR_Amount__c = tmpAmount;  
                newRt.blng__RevenueSchedule__c = lastRt.blng__RevenueSchedule__c;
                newRt.blng__RevenueFinancePeriod__c = tmpFp.Id;
                tmpResult.add(newRt);   
            }
        }

        PAD.logAllList(ClassName,'detectUpdateOrCreateRevenueTransaction','tmpResult', tmpResult);

        return tmpResult;
    }
}