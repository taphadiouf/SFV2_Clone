/**
* @author Erwan Yhuellou
* @date 22/02/2021
* @Description :
* Only For Common Frequency (Monthly, Quarterly, Semiannual, Annual)
* Input : blng__RevenueTransaction__c with LPCR_Amount__c empty
* Output : Populate and adjust the LPCR_Amount__c field on the Revenue Transaction accordingly to what LPCR wants
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
                                                                                                    WHERE blng__OrderProduct__c != null AND LPCR_Amount__c = null AND 
																										((blng__OrderProduct__r.SBQQ__ChargeType__c != 'One-Time' AND blng__OrderProduct__r.LPCR_FirstInvoiceEndDate__c != null) 
																											OR 
																										(blng__OrderProduct__r.SBQQ__ChargeType__c = 'One-Time' AND blng__OrderProduct__r.LPCR_FirstInvoiceEndDate__c = null)))
                                        ]);
    }

    global void execute(Database.BatchableContext BC, List<blng__RevenueSchedule__c> scope) {

        UM001_LogManager.writeLogActivityWithoutFuture(ClassName,'execute', 'Batch' , null, 'Scope size : '  + scope.size(), UM010_Constant.SUCCESS); 
        
        Set<Id> setRevenueSchedules = UM003_TypeManager.getIdsOfListObjects(scope);
        List<blng__RevenueTransaction__c> revenueTransactionToUpdate = new List<blng__RevenueTransaction__c>();
        List<Exception> errors = new List<Exception>();
        Map<Id, List<blng__RevenueTransaction__c>> mapScheduleRevTransaction = new Map<Id, List<blng__RevenueTransaction__c>>();

        List<blng__RevenueTransaction__c> listRevTransaction = new List<blng__RevenueTransaction__c>([SELECT Id, blng__OrderProduct__r.ServiceDate, blng__RevenueSchedule__c, blng__OrderProduct__r.SBQQ__ChargeType__c, 
                                                                                                        blng__OrderProduct__r.SBQQ__BillingFrequency__c, blng__OrderProduct__r.LPCR_FirstInvoiceEndDate__c,
                                                                                                        blng__SystemPeriodStartDate__c, blng__RevenueSchedule__r.blng__TotalRevenueAmount__c, 
                                                                                                        blng__OrderProduct__r.blng__BillableUnitPrice__c 
                                                                                                        FROM blng__RevenueTransaction__c
                                                                                                        WHERE blng__OrderProduct__c != null AND LPCR_Amount__c = null and blng__RevenueSchedule__c in :setRevenueSchedules
                                                                                                        ORDER BY blng__RevenueSchedule__c, blng__SystemPeriodStartDate__c asc]);

        PAD.logAllList(ClassName,'execute','listRevTransaction', listRevTransaction);

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

            PAD.log(ClassName,'execute','scope to execute : ' + scope);
            
            for(Id eachRevSched: mapScheduleRevTransaction.keySet()){
                revenueTransactionToUpdate.addAll(processRevenueSchedule(mapScheduleRevTransaction.get(eachRevSched)));
            }

            PAD.logAllList(ClassName,'execute','revenueTransactionToUpdate', revenueTransactionToUpdate);

            String ErrMsg;
            
            try {
                update revenueTransactionToUpdate;
                PAD.log(ClassName,'execute','blng__RevenueTransaction__c list Update success. list : ' + revenueTransactionToUpdate);
                UM001_LogManager.writeLogActivityWithoutFuture(ClassName, 'execute', 'Batch' , null, 'Successfully updated : ' + String.valueOf(revenueTransactionToUpdate),  UM010_Constant.SUCCESS);     
            } 
            catch (Exception e) {
                ErrMsg = e.getMessage() + '- line:' + e.getLineNumber() + '-';
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

        PAD.logAllList(ClassName,'processRevenueSchedule','tmpListRevTransaction', tmpListRevTransaction);

        for (blng__RevenueTransaction__c tmpRT : tmpListRevTransaction) {

            PAD.log(ClassName,'processRevenueSchedule','tmpListRevTransaction - ***************************************************');
            PAD.log(ClassName,'processRevenueSchedule','tmpListRevTransaction - tmpRT:' + tmpRT);

            blng__RevenueTransaction__c tmpRtToAdd = new blng__RevenueTransaction__c();
            tmpRtToAdd = tmpRT;



            if (tmpRT.blng__OrderProduct__r.SBQQ__ChargeType__c == 'One-Time') { // ONE TIME Charge Type
            
                Integer tmpMonthSD = tmpRT.blng__OrderProduct__r.ServiceDate.Month();
                Integer tmpMonthPSD = tmpRT.blng__SystemPeriodStartDate__c.Month();
                
                if (tmpMonthSD == tmpMonthPSD) {
                    PAD.log(ClassName,'processRevenueSchedule','tmpListRevTransaction - One-Time - tmpRT.blng__RevenueSchedule__r.blng__TotalRevenueAmount__c:' + tmpRT.blng__RevenueSchedule__r.blng__TotalRevenueAmount__c);
                    tmpRtToAdd.LPCR_Amount__c = tmpRT.blng__RevenueSchedule__r.blng__TotalRevenueAmount__c;
                    tmpRevenueTransactionToUpdate.add(tmpRtToAdd);
                }                
            } 
            else { // RECURRING Charge Type

                Decimal tmpBillableUnitPrice; 
                Decimal tmpAmount = 0;
                PAD.log(ClassName,'processRevenueSchedule','tmpListRevTransaction - tmpRT.blng__OrderProduct__r.ServiceDate:' + tmpRT.blng__OrderProduct__r.ServiceDate);
                PAD.log(ClassName,'processRevenueSchedule','tmpListRevTransaction - tmpRT.blng__OrderProduct__r.LPCR_FirstInvoiceEndDate__c:' + tmpRT.blng__OrderProduct__r.LPCR_FirstInvoiceEndDate__c);

                Integer tmpMonthSD = tmpRT.blng__OrderProduct__r.ServiceDate.Month();
                Integer tmpMonthFEED = tmpRT.blng__OrderProduct__r.LPCR_FirstInvoiceEndDate__c.Month();
                Integer count = Date.daysInMonth(tmpRT.blng__OrderProduct__r.ServiceDate.year(), tmpRT.blng__OrderProduct__r.ServiceDate.month());
                Date tmpDate = tmpRT.blng__OrderProduct__r.ServiceDate;

                PAD.log(ClassName,'processRevenueSchedule','tmpListRevTransaction - tmpMonthSD:' + tmpMonthSD);
                PAD.log(ClassName,'processRevenueSchedule','tmpListRevTransaction - tmpMonthFEED:' + tmpMonthFEED);
                PAD.log(ClassName,'processRevenueSchedule','tmpListRevTransaction - count:' + count);
                PAD.log(ClassName,'processRevenueSchedule','tmpListRevTransaction - tmpDate:' + tmpDate);

                if (tmpMonthSD >= tmpMonthFEED) {
                    tmpDate = tmpDate.addDays(- 1);
                }
                else {

                    for (Integer tmpMmonth = tmpMonthSD; tmpMmonth < tmpMonthFEED; tmpMmonth++) {

                        count = Date.daysInMonth(tmpDate.year(), tmpDate.month());
                        tmpDate = tmpDate.addDays(count);
                        PAD.log(ClassName,'processRevenueSchedule','tmpListRevTransaction - count:' + count);
                        PAD.log(ClassName,'processRevenueSchedule','tmpListRevTransaction - tmpDate after adding count:' + tmpDate);
                    }
                    tmpDate = tmpDate.addDays(- 1);
                }

                Decimal tmpReminderDays = tmpDate.daysBetween(tmpRT.blng__OrderProduct__r.LPCR_FirstInvoiceEndDate__c);

                Date[] tmpDateMinMax = UM003_TypeManager.getMinMaxOfListObjectsDate(tmpListRevTransaction, 'blng__SystemPeriodStartDate__c');
                Date tmpMaxDateRevenueTransaction = tmpDateMinMax[1];
                Date tmpMinDateRevenueTransaction = tmpDateMinMax[0];

                PAD.log(ClassName,'processRevenueSchedule','tmpListRevTransaction - tmpReminderDays:' + tmpReminderDays);
                PAD.log(ClassName,'processRevenueSchedule','tmpListRevTransaction - tmpMaxDateRevenueTransaction:' + tmpMaxDateRevenueTransaction);
                PAD.log(ClassName,'processRevenueSchedule','tmpListRevTransaction - tmpMinDateRevenueTransaction:' + tmpMinDateRevenueTransaction);


                PAD.log(ClassName,'processRevenueSchedule','tmpListRevTransaction - Critical conditions value:');
                PAD.log(ClassName,'processRevenueSchedule','tmpListRevTransaction - tmpRT.blng__SystemPeriodStartDate__c:' + tmpRT.blng__SystemPeriodStartDate__c);
                PAD.log(ClassName,'processRevenueSchedule','tmpListRevTransaction - tmpMinDateRevenueTransaction:' + tmpMinDateRevenueTransaction);

                if (tmpRT.blng__SystemPeriodStartDate__c == tmpMinDateRevenueTransaction) { // FIRST REV TRANSACTION

                    PAD.log(ClassName,'processRevenueSchedule','tmpListRevTransaction - FIRST REV TRANSACTION - tmpRT:' + tmpRT);

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
                    
                    PAD.log(ClassName,'processRevenueSchedule','tmpListRevTransaction - tmpBillableUnitPrice arrondis :' + tmpBillableUnitPrice.setScale(4));

                    Decimal a = tmpBillableUnitPrice.setScale(4);
                    Decimal abis = 30.4166666667; // (365 / 12) value because SF dont manage well two decimal divison at same time
                    Decimal b = tmpReminderDays / abis;
                    tmpAmount = UM003_TypeManager.getDecimalValueWithScale(a * b, 4);

                    PAD.log(ClassName,'processRevenueSchedule','tmpListRevTransaction - a:' + a);
                    PAD.log(ClassName,'processRevenueSchedule','tmpListRevTransaction - abis:' + abis);
                    PAD.log(ClassName,'processRevenueSchedule','tmpListRevTransaction - b:' + b);
                    PAD.log(ClassName,'processRevenueSchedule','tmpListRevTransaction - tmpAmount:' + tmpAmount);
                    PAD.log(ClassName,'processRevenueSchedule','tmpListRevTransaction - tmpReminderDays:' + tmpReminderDays);
                    PAD.log(ClassName,'processRevenueSchedule','tmpListRevTransaction - tmpBillableUnitPrice:' + tmpBillableUnitPrice);
                    

                    tmpRtToAdd.LPCR_Amount__c = tmpAmount;
                    totalAmount += tmpAmount;
                    tmpRevenueTransactionToUpdate.add(tmpRtToAdd);
                }
                else if (tmpRT.blng__SystemPeriodStartDate__c != tmpMinDateRevenueTransaction && 
                            tmpRT.blng__SystemPeriodStartDate__c != tmpMaxDateRevenueTransaction) { // MID REV TRANSACTION

                    PAD.log(ClassName,'processRevenueSchedule','tmpListRevTransaction - MID REV TRANSACTION - tmpRT:' + tmpRT);
                    
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
                    tmpAmount = tmpAmount.setScale(4);
                    tmpRtToAdd.LPCR_Amount__c = tmpAmount;

                    PAD.log(ClassName,'processRevenueSchedule','tmpListRevTransaction - tmpReminderDays:' + tmpReminderDays);
                    PAD.log(ClassName,'processRevenueSchedule','tmpListRevTransaction - tmpBillableUnitPrice:' + tmpBillableUnitPrice);
                    PAD.log(ClassName,'processRevenueSchedule','tmpListRevTransaction - tmpAmount:' + tmpAmount);

                    totalAmount += tmpAmount;
                    tmpRevenueTransactionToUpdate.add(tmpRtToAdd);
                }
            }
        }

        for (blng__RevenueTransaction__c tmpRtElem : tmpListRevTransaction) {

            if (tmpRtElem.blng__OrderProduct__r.SBQQ__ChargeType__c != 'One-Time') {

                blng__RevenueTransaction__c rtToAdd = new blng__RevenueTransaction__c();
                Date[] tmpDateMinMax = UM003_TypeManager.getMinMaxOfListObjectsDate(tmpListRevTransaction, 'blng__SystemPeriodStartDate__c');
                Date tmpMaxDateRevenueTransaction = tmpDateMinMax[1];
                Date tmpMinDateRevenueTransaction = tmpDateMinMax[0];

                if (tmpRtElem.blng__SystemPeriodStartDate__c == tmpMaxDateRevenueTransaction) { // LAST REV TRANSACTION

                    PAD.log(ClassName,'processRevenueSchedule','tmpListRevTransaction - ***************************************************');
                    PAD.log(ClassName,'processRevenueSchedule','tmpListRevTransaction - LAST REV TRANSACTION - tmpRtElem:' + tmpRtElem);
                    PAD.log(ClassName,'processRevenueSchedule','tmpListRevTransaction - tmpRtElem.blng__RevenueSchedule__r.blng__TotalRevenueAmount__c:' + tmpRtElem.blng__RevenueSchedule__r.blng__TotalRevenueAmount__c);
                    PAD.log(ClassName,'processRevenueSchedule','tmpListRevTransaction - totalAmount:' + totalAmount);
                    
                    rtToAdd = tmpRtElem;
                    rtToAdd.LPCR_Amount__c = UM003_TypeManager.getDecimalValueWithScale(tmpRtElem.blng__RevenueSchedule__r.blng__TotalRevenueAmount__c.setScale(2) - totalAmount, 4);
                    
                    tmpRevenueTransactionToUpdate.add(rtToAdd);

                    PAD.log(ClassName,'processRevenueSchedule','tmpListRevTransaction - rtToAdd.LPCR_Amount__c:' + rtToAdd.LPCR_Amount__c);
                }

            }
            
        }

        PAD.logAllList(ClassName,'processRevenueSchedule','tmpRevenueTransactionToUpdate', tmpRevenueTransactionToUpdate);

        return tmpRevenueTransactionToUpdate;
    }
}






