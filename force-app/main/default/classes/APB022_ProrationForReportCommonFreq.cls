/**
* @author Erwan Yhuellou
* @date 22/02/2021
* @Description Batch Logic to populate and adjust the LPCR_Amount__c field on the Revenue Transaction accordingly to what LPCR wants
* For Common Frequency (Monthly, Quarterly, Semiannual, Annual)
*/
global class APB022_ProrationForReportCommonFreq implements Database.Batchable<sObject>,Schedulable {
    
    String query;
    final String ClassName = APB022_ProrationForReportCommonFreq.class.getName();

    global APB022_ProrationForReportCommonFreq() {
        
    }
    
    global Database.QueryLocator start(Database.BatchableContext BC) {

        UM001_LogManager.writeLogActivityWithoutFuture(ClassName,'start', 'Batch' , null, 'Starting Batch', UM010_Constant.SUCCESS);
        return Database.getQueryLocator([SELECT Id, Name FROM blng__RevenueSchedule__c where Id in (SELECT blng__RevenueSchedule__c 
                                                                                                    FROM blng__RevenueTransaction__c
                                                                                                    WHERE blng__OrderProduct__c != null AND LPCR_Amount__c = null) 
                                        ]);
    }

    global void execute(Database.BatchableContext BC, List<blng__RevenueTransaction__c> scope) {

        UM001_LogManager.writeLogActivityWithoutFuture(ClassName,'execute', 'Batch' , null, 'Scope size : '  + scope.size(), UM010_Constant.SUCCESS); 
        
        Set<Id> setRevenueSchedules = UM003_TypeManager.getIdsOfListObjects(scope, 'blng__RevenueSchedule__c');
        List<blng__RevenueTransaction__c> revenueTransactionToUpdate = new List<blng__RevenueTransaction__c>();
        List<Exception> errors = new List<Exception>();
        Map<Id, List<blng__RevenueTransaction__c>> mapScheduleRevTransaction = new Map<Id, List<blng__RevenueTransaction__c>>();

        List<blng__RevenueTransaction__c> listRevTransaction = new List<blng__RevenueTransaction__c>([SELECT Id, blng__RevenueSchedule__c, blng__OrderProduct__r.SBQQ__ChargeType__c, 
                                                                                                        blng__OrderProduct__r.SBQQ__BillingFrequency__c, blng__OrderProduct__r.LPCR_FirstInvoiceEndDate__c,
                                                                                                        blng__SystemPeriodStartDate__c, blng__RevenueSchedule__r.blng__TotalRevenueAmount__c, 
                                                                                                        blng__OrderProduct__r.blng__BillableUnitPrice__c 
                                                                                                        FROM blng__RevenueTransaction__c
                                                                                                        WHERE blng__OrderProduct__c != null AND LPCR_Amount__c = null and blng__RevenueSchedule__c in :setRevenueSchedules
                                                                                                        ORDER BY blng__RevenueSchedule__c, blng__SystemPeriodStartDate__c asc]);

        for (Id tmpId : setRevenueSchedules) {
            for (blng__RevenueTransaction__c revTran : listRevTransaction) {

                if (tmpId == revTran.blng__RevenueSchedule__c) {
                    if (mapScheduleRevTransaction.get(tmpId) == null) {
                        mapScheduleRevTransaction.put(tmpId, new List<blng__RevenueTransaction__c>());
                    }
                    mapScheduleRevTransaction.get(tmpId).add(revTran);
                }
            }
        }
        try {

            PAD.log('APB022_ProrationForReportCommonFreq','execute','scope to execute : ' + scope);
            
            for(Id eachRevSched: mapScheduleRevTransaction.keySet()){
                revenueTransactionToUpdate.addAll(processRevenueSchedule(mapScheduleRevTransaction.get(eachRevSched)));
            }

            String ErrMsg;
            
            try {
                update revenueTransactionToUpdate;
                PAD.log('APB022_ProrationForReportCommonFreq','execute','blng__RevenueTransaction__c list Update success. list : ' + revenueTransactionToUpdate);
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

    /*
        // Method used to process all the revenue transaction linked with a revenue schedule in order to set correctly the blng__RevenueTransaction__c.LPCR_Amount__c
            Calculate the number of months between OrderItem.ServiceDate & OrderItem.LPCR__FirstInvoiceEndDate__c. 
            Calculate the of days  OrderItem.ServiceDate & OrderItem.LPCR__FirstInvoiceEndDate__c. 
                Example : 
                OrderItem.ServiceDate is 16th Feb 2020 (=> 16/02/2020)
                LPCR__FirstInvoiceEndDate__c is 31st March, 2020 (=> 31/03/2020)
                frequency is monthly :
                    => 46 days => <1 month (30 days)> + <16 days> 
                    => Amount = (<16 days> / (365 / 12)) * <blng__BillableUnitPrice__c / 3>
    */
    private List<blng__RevenueTransaction__c> processRevenueSchedule(List<blng__RevenueTransaction__c> tmpListRevTransaction) {

        List<blng__RevenueTransaction__c> tmpRevenueTransactionToUpdate = new List<blng__RevenueTransaction__c>();
        Decimal totalAmount = 0;

        for (blng__RevenueTransaction__c tmpRT : tmpListRevTransaction) {

            blng__RevenueTransaction__c tmpRtToAdd = new blng__RevenueTransaction__c();
            tmpRtToAdd = tmpRT;

            if (tmpRT.blng__OrderProduct__r.SBQQ__ChargeType__c == 'One-Time') {
                tmpRtToAdd.LPCR_Amount__c = tmpRT.blng__RevenueSchedule__r.blng__TotalRevenueAmount__c;
            } 
            else {

                Decimal tmpBillableUnitPrice; 
                Decimal tmpAmount = 0;
                Integer tmpReminderDays = math.mod(tmpRT.blng__OrderProduct__r.ServiceDate.daysBetween(tmpRT.blng__OrderProduct__r.LPCR_FirstInvoiceEndDate__c), 30);

                Date[] tmpDateMinMax = UM003_TypeManager.getMinMaxOfListObjectsDate(tmpListRevTransaction, 'blng__SystemPeriodStartDate__c');
                Date tmpMaxDateRevenueTransaction = tmpDateMinMax[0];
                Date tmpMinDateRevenueTransaction = tmpDateMinMax[1];

                if (tmpRT.blng__SystemPeriodStartDate__c == tmpMinDateRevenueTransaction) { // FIRST REV TRANSACTION

                    if (tmpRT.blng__OrderProduct__r.SBQQ__BillingFrequency__c == 'Monthly') {
                        tmpBillableUnitPrice = tmpRT.blng__OrderProduct__r.blng__BillableUnitPrice__c;
                    }
                    else if (tmpRT.blng__OrderProduct__r.SBQQ__BillingFrequency__c == 'Quarterly'){
                        tmpBillableUnitPrice = tmpRT.blng__OrderProduct__r.blng__BillableUnitPrice__c / 3;
                    }
                    else if (tmpRT.blng__OrderProduct__r.SBQQ__BillingFrequency__c == 'Semiannual'){
                        tmpBillableUnitPrice = tmpRT.blng__OrderProduct__r.blng__BillableUnitPrice__c / 6;
                    }
                    else if (tmpRT.blng__OrderProduct__r.SBQQ__BillingFrequency__c == 'Annual'){
                        tmpBillableUnitPrice = tmpRT.blng__OrderProduct__r.blng__BillableUnitPrice__c / 12;
                    }
                    else if (tmpRT.blng__OrderProduct__r.SBQQ__BillingFrequency__c == 'Invoice Plan'){
                        
                    }
                    
                    tmpAmount = (tmpReminderDays / (365 / 12)) * tmpBillableUnitPrice;
                    tmpRtToAdd.LPCR_Amount__c = tmpAmount;
                    totalAmount += tmpAmount;
                    tmpRevenueTransactionToUpdate.add(tmpRtToAdd);
                }
                else if (tmpRT.blng__SystemPeriodStartDate__c != tmpMinDateRevenueTransaction && 
                            tmpRT.blng__SystemPeriodStartDate__c != tmpMaxDateRevenueTransaction) { // MID REV TRANSACTION

                    if (tmpRT.blng__OrderProduct__r.SBQQ__BillingFrequency__c == 'Monthly') {
                        tmpAmount = tmpRT.blng__OrderProduct__r.blng__BillableUnitPrice__c;
                    }
                    else if (tmpRT.blng__OrderProduct__r.SBQQ__BillingFrequency__c == 'Quarterly'){
                        tmpAmount = tmpRT.blng__OrderProduct__r.blng__BillableUnitPrice__c / 3;
                    }
                    else if (tmpRT.blng__OrderProduct__r.SBQQ__BillingFrequency__c == 'Semiannual'){
                        tmpAmount = tmpRT.blng__OrderProduct__r.blng__BillableUnitPrice__c / 6;
                    }
                    else if (tmpRT.blng__OrderProduct__r.SBQQ__BillingFrequency__c == 'Annual'){
                        tmpAmount = tmpRT.blng__OrderProduct__r.blng__BillableUnitPrice__c / 12;
                    }
                    else if (tmpRT.blng__OrderProduct__r.SBQQ__BillingFrequency__c == 'Invoice Plan'){
                        
                    }
                    tmpRtToAdd.LPCR_Amount__c = tmpAmount;
                    totalAmount += tmpAmount;
                    tmpRevenueTransactionToUpdate.add(tmpRtToAdd);
                }
            }
        }

        for (blng__RevenueTransaction__c tmpRtElem : tmpListRevTransaction) {

            blng__RevenueTransaction__c rtToAdd = new blng__RevenueTransaction__c();
            Date[] tmpDateMinMax = UM003_TypeManager.getMinMaxOfListObjectsDate(tmpListRevTransaction, 'blng__SystemPeriodStartDate__c');
            Date tmpMaxDateRevenueTransaction = tmpDateMinMax[0];
            Date tmpMinDateRevenueTransaction = tmpDateMinMax[1];

            if (tmpRtElem.blng__SystemPeriodStartDate__c == tmpMinDateRevenueTransaction) { // LAST REV TRANSACTION

                rtToAdd.LPCR_Amount__c = tmpRtElem.blng__RevenueSchedule__r.blng__TotalRevenueAmount__c - totalAmount;
            }
            tmpRevenueTransactionToUpdate.add(rtToAdd);
        }

        return tmpRevenueTransactionToUpdate;
    }
}






