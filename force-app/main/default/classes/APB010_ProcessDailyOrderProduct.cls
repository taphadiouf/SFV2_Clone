/**
* @author Saurabh
* @date 19/06/2020
* @Description IS-981 Batch for Order Product
*/ 
global class APB010_ProcessDailyOrderProduct implements Database.Batchable<sObject>,Schedulable  {
    String query;
    final String ClassName = APB010_ProcessDailyOrderProduct.class.getName();
    global APB010_ProcessDailyOrderProduct() {
        
    }
    
    global Database.QueryLocator start(Database.BatchableContext BC) {

        UM001_LogManager.writeLogActivityWithoutFuture(ClassName,'start', 'Batch' , null, 'Starting Batch', UM010_Constant.SUCCESS);
        return Database.getQueryLocator([SELECT Id,Quantity, OrderId, TotalPrice,SBQQ__DefaultSubscriptionTerm__c,LPCR_Uplift__c,LPCR_ContractStartDate__c,
                                                LPCR_ContractEndDate__c, blng__BillableUnitPrice__c, SBQQ__BillingFrequency__c, blng__NextChargeDate__c,
                                                SBQQ__Contract__c,SBQQ__Contract__r.LPCR_DateFin__c, Order.LPCR_BDOM_OrderStartdate__c,SBQQ__QuoteLine__r.SBQQ__ProrateMultiplier__c,
                                                SBQQ__QuoteLine__r.SBQQ__ListPrice__c,Order.LPCR_RenouvellementPlanFacture__c 
                                            FROM OrderItem 
                                            WHERE Order.Status = 'Activated'  AND LPCR_BillingPlanProcessment__c = false AND LastModifiedDate = TODAY]);
    }
    
    global void execute(Database.BatchableContext BC, List<OrderItem> scope) {
               
        UM001_LogManager.writeLogActivityWithoutFuture(ClassName,'execute', 'Batch' , null, 'Scope size : '  + scope.size(), UM010_Constant.SUCCESS); 
        List<Exception> errors = new List<Exception>();

        try {    
            
            String ErrMsg;
            PAD.log(ClassName, 'execute', 'scope to execute : '+scope);
            

            Set<Id> orderItemIds = UM003_TypeManager.getIdsOfListObjects(scope);
            Set<String> contractIds = UM003_TypeManager.getFieldsOfListObjects(scope, 'SBQQ__Contract__c');
            Set<Id> selectedOrderItemId = new Set<Id>();
            Set<String> orderInvPlanIdsSet = new Set<String>();
            
            Map<Id, List<blng__BillingTransaction__c>> billingTransactionMap = new Map<Id, List<blng__BillingTransaction__c>>();
            Map<Id, List<LPCR_PlanFacturation__c>> billingPlanMap = new Map<Id, List<LPCR_PlanFacturation__c>>();
            Map<Id, List<blng__InvoicePlanLine__c>> invoicePlanLineMap = new Map<Id, List<blng__InvoicePlanLine__c>>();
            
            List<LPCR_LignePlanFacturation__c> billingPlanLineList = new List<LPCR_LignePlanFacturation__c>();
            Map<Id,Contract> updateContractmap = new Map<Id,Contract>([SELECT Id, LPCR_TotaleGlobalePlanFacture__c, LPCR_ValeurTotale__c 
                                                                        FROM Contract 
                                                                        WHERE Id =: contractIds]);
            
            // ------------------------------------------------------------------------------------------------------------
            //
            // STEP 1 : Create PlanFacturation records for each year of the order item with proper values
            //
            // ------------------------------------------------------------------------------------------------------------

            for(OrderItem eachOrderItem : scope){ 
                //Set Multiplier value
                Integer multiplier;
                if(eachOrderItem.SBQQ__DefaultSubscriptionTerm__c == 1){
                    multiplier = 12; // Set Multiplier value to 12 (B2C use case)
                }else{
                    multiplier = 1; // Set Multiplier value to 1 (B2B use case)
                }
                
                // Calculate no. of total years
                
                Date tmpDate = eachOrderItem.LPCR_ContractStartDate__c;
                Date endDate = eachOrderItem.LPCR_ContractEndDate__c;            
                Integer totalNoOfYears = (endDate.year() - tmpDate.year()) + 1;
                
                Decimal totalPrice = eachOrderItem.TotalPrice;
                Decimal totalFullYearPrice = eachOrderItem.SBQQ__QuoteLine__r.LPCR_PrixUnitaire__c;
                Decimal finalLastYearPrice = 0;
                Decimal totaleGlobalePlanFacture = 0;
                Decimal sumOfTotalContractValue = 0;
                
                // Store Billing plan map for order product
                if(!billingPlanMap.containsKey(eachOrderItem.Id)){
                    billingPlanMap.put(eachOrderItem.Id, new List<LPCR_PlanFacturation__c>());
                }
                
                if(totalNoOfYears > 0){
                    Date lastDayOfCurrentMonthDateSetEndDate = null;
                    
                    for(integer eachYear = 1 ; eachYear <= totalNoOfYears ; eachYear++){

                        if(eachYear == 1){ // First Year
                            
                            PAD.log(ClassName, 'execute','First Year - totalPrice = ' + totalPrice);
                            PAD.log(ClassName, 'execute','First Year - multiplier = ' + multiplier);
                            PAD.log(ClassName, 'execute','First Year - ProrateMultiplier = ' + eachOrderItem.SBQQ__QuoteLine__r.SBQQ__ProrateMultiplier__c);
                            
                            //totalFullYearPrice = (totalPrice * multiplier)/eachOrderItem.SBQQ__QuoteLine__r.SBQQ__ProrateMultiplier__c;
                            //totalFullYearPrice = totalPrice * eachOrderItem.SBQQ__QuoteLine__r.SBQQ__ProrateMultiplier__c;
                            totaleGlobalePlanFacture += totalPrice;
                            
                            PAD.log(ClassName, 'execute','First Year - totalFullYearPrice = ' + totalFullYearPrice);
                            PAD.log(ClassName, 'execute','First Year - totaleGlobalePlanFacture = ' + totaleGlobalePlanFacture);
                            
                            // Create new Billing Plan record
                            LPCR_PlanFacturation__c billingPlan = new LPCR_PlanFacturation__c();
                            billingPlan.LPCR_OrderItem__c = eachOrderItem.Id;
                            billingPlan.LPCR_BillingFrequency__c = eachOrderItem.SBQQ__BillingFrequency__c;
                            billingPlan.LPCR_TotalContractValue__c = totalPrice;
                            billingPlan.LPCR_StartDate__c = tmpDate;
                            Date lastDayOfCurrentYear=Date.newInstance(tmpDate.year(), 12 , 31) ;
                            lastDayOfCurrentMonthDateSetEndDate = lastDayOfCurrentYear;
                            if(eachOrderItem.LPCR_ContractEndDate__c > lastDayOfCurrentMonthDateSetEndDate)
                                billingPlan.LPCR_EndDate__c = lastDayOfCurrentYear;
                            else
                                billingPlan.LPCR_EndDate__c =  eachOrderItem.LPCR_ContractEndDate__c;   
                            lastDayOfCurrentMonthDateSetEndDate = billingPlan.LPCR_EndDate__c;

                            sumOfTotalContractValue = billingPlan.LPCR_TotalContractValue__c;
                            billingPlanMap.get(eachOrderItem.Id).add(billingPlan);

                            PAD.log(ClassName, 'execute','First Year - billing Plan = '+ billingPlan);
                            
                        }else if(eachYear != totalNoOfYears) { // Middle Year price

                            totalFullYearPrice =  totalFullYearPrice + ((totalFullYearPrice * eachOrderItem.LPCR_Uplift__c)/100);
                            totaleGlobalePlanFacture += totalFullYearPrice;
                            
                            // Create Billing plan record
                            LPCR_PlanFacturation__c billingPlan = new LPCR_PlanFacturation__c();
                            billingPlan.LPCR_OrderItem__c = eachOrderItem.Id;
                            billingPlan.LPCR_BillingFrequency__c = eachOrderItem.SBQQ__BillingFrequency__c;
                            billingPlan.LPCR_TotalContractValue__c  = totalFullYearPrice;
                            billingPlan.LPCR_StartDate__c = lastDayOfCurrentMonthDateSetEndDate.addDays(1);
                            Date stDate = billingPlan.LPCR_StartDate__c;
                            Date lastDayOfCurrentMonthDate=Date.newInstance(stDate.year(), 12 , 31);

                            if(eachOrderItem.LPCR_ContractEndDate__c > lastDayOfCurrentMonthDate) { 
                                billingPlan.LPCR_EndDate__c = lastDayOfCurrentMonthDate;
                            }
                            else {
                                billingPlan.LPCR_EndDate__c = eachOrderItem.LPCR_ContractEndDate__c;    
                            }

                            lastDayOfCurrentMonthDateSetEndDate = billingPlan.LPCR_EndDate__c;
                            sumOfTotalContractValue += billingPlan.LPCR_TotalContractValue__c;
                            billingPlanMap.get(eachOrderItem.Id).add(billingPlan);

                            PAD.log(ClassName, 'execute','Middle Year - billing Plan : '+ billingPlan);

                        } else { // Last Partial Year

                            totalFullYearPrice =  totalFullYearPrice + ((totalFullYearPrice * eachOrderItem.LPCR_Uplift__c)/100);
                            Double perDayPrice = ((totalFullYearPrice)/365).setScale(4);
                            Integer diffBetweenMonths = lastDayOfCurrentMonthDateSetEndDate.addDays(1).monthsBetween(eachOrderItem.LPCR_ContractEndDate__c);
                            Integer reminderDays = Date.newInstance(eachOrderItem.LPCR_ContractEndDate__c.year(), eachOrderItem.LPCR_ContractEndDate__c.month() , 1).daysBetween(eachOrderItem.LPCR_ContractEndDate__c) + 1;
                            PAD.log(ClassName, 'execute','Last Partial Year - perDayPrice : '+ perDayPrice);
                                                        
                            totaleGlobalePlanFacture += totalFullYearPrice;
                            
                            // Create Billing plan record
                            LPCR_PlanFacturation__c billingPlan = new LPCR_PlanFacturation__c();
                            billingPlan.LPCR_OrderItem__c = eachOrderItem.Id;
                            billingPlan.LPCR_BillingFrequency__c = eachOrderItem.SBQQ__BillingFrequency__c;
                            
                            billingPlan.LPCR_StartDate__c = lastDayOfCurrentMonthDateSetEndDate.addDays(1);
                            Date stDate = billingPlan.LPCR_StartDate__c;
                            Date lastDayOfCurrentMonthDate=Date.newInstance(stDate.year(), 12 , 31);

                            if(eachOrderItem.LPCR_ContractEndDate__c > lastDayOfCurrentMonthDate)
                                billingPlan.LPCR_EndDate__c =   lastDayOfCurrentMonthDate;
                            else
                                billingPlan.LPCR_EndDate__c =   eachOrderItem.LPCR_ContractEndDate__c; 
                            
                            PAD.log(ClassName, 'execute','Last Partial Year - lastDayOfCurrentMonthDateSetEndDate.addDays(1) :' + lastDayOfCurrentMonthDateSetEndDate.addDays(1));
                            PAD.log(ClassName, 'execute','Last Partial Year - eachOrderItem.LPCR_ContractEndDate__c.toStartOfMonth().addDays(-1) :' + eachOrderItem.LPCR_ContractEndDate__c.toStartOfMonth().addDays(-1));

                            //Decimal monthlyPrice = (totalPrice / 12);
                            //new monthlyPrice => ( ((LPCR_PrixUnitaire__c *eachOrderItem.LPCR_Uplift__c)/100) * eachOrderItem.LPCR_Uplift__c/100 ) /12
                            Decimal monthlyPrice = (((eachOrderItem.SBQQ__QuoteLine__r.LPCR_PrixUnitaire__c * eachOrderItem.LPCR_Uplift__c)/100) * eachOrderItem.LPCR_Uplift__c/100) / 12;
                            Decimal nbMonths = lastDayOfCurrentMonthDateSetEndDate.addDays(1).monthsBetween(eachOrderItem.LPCR_ContractEndDate__c.toStartOfMonth());
                            Decimal Subtotal_Part1 = monthlyPrice * nbMonths;
                            PAD.log(ClassName, 'execute','Last Partial Year - monthlyPrice :' + monthlyPrice);
                            PAD.log(ClassName, 'execute','Last Partial Year - nbMonths :' + nbMonths);
                            PAD.log(ClassName, 'execute','Last Partial Year - Subtotal_Part1 :' + Subtotal_Part1);

                            Decimal d1 = reminderDays;
                            Decimal d2 = totalPrice;
                            PAD.log(ClassName, 'execute','Last Partial Year - d1 :' + d1);
                            PAD.log(ClassName, 'execute','Last Partial Year - d2 :' + d2);
                            Decimal Subtotal_Part2 = ((d1 / 30) * monthlyPrice);

                            PAD.log(ClassName, 'execute','Last Partial Year - Subtotal_Part2 :' + Subtotal_Part2);

                            // <Monthly price> : (totalPrice / 12)
                            // <remaining number of days> : reminderDays
                            // <number of days in the current month> : always 30
                            // Definition of total (IS-1255) : (Number of months * <Monthly price>) + ((<remaining number of days> / <number of days in the month>) * <Monthly price>)

                            PAD.log(ClassName, 'execute','Last Partial Year - (totalPrice / 12) :'+ (totalPrice / 12));
                            PAD.log(ClassName, 'execute','Last Partial Year - reminderDays :'+ reminderDays);
                            
                            billingPlan.LPCR_TotalContractValue__c = Subtotal_Part1 + Subtotal_Part2;
                            lastDayOfCurrentMonthDateSetEndDate = billingPlan.LPCR_EndDate__c;                            
                            sumOfTotalContractValue += billingPlan.LPCR_TotalContractValue__c;
                            billingPlanMap.get(eachOrderItem.Id).add(billingPlan);

                            PAD.log(ClassName, 'execute','Last Partial Year billing Plan = '+ billingPlan);
                        }
                        
                    }           
                    
                    // Calculate and store the whole global price
                    if(updateContractMap.containsKey(eachOrderItem.SBQQ__Contract__c)) {

                        updateContractMap.get(eachOrderItem.SBQQ__Contract__c).LPCR_TotaleGlobalePlanFacture__c = sumOfTotalContractValue;

                        if((updateContractMap.get(eachOrderItem.SBQQ__Contract__c).LPCR_ValeurTotale__c == null || 
                                updateContractMap.get(eachOrderItem.SBQQ__Contract__c).LPCR_ValeurTotale__c == 0) && 
                                updateContractMap.get(eachOrderItem.SBQQ__Contract__c).LPCR_TotaleGlobalePlanFacture__c != null ) {

                            updateContractMap.get(eachOrderItem.SBQQ__Contract__c).LPCR_ValeurTotale__c = sumOfTotalContractValue;
                        }
                    }
                }
                if(eachOrderItem.SBQQ__BillingFrequency__c == 'Invoice Plan') {
                    selectedOrderItemId.add(eachOrderItem.Id);
                    orderInvPlanIdsSet.add(eachOrderItem.OrderId);
                }
            }
            
            if(billingPlanMap.size() > 0){
                // insert billing plan for order product
                List<LPCR_PlanFacturation__c> insertBillingPlanList = new List<LPCR_PlanFacturation__c>();
                for(List<LPCR_PlanFacturation__c> eachList : billingPlanMap.values()){
                    insertBillingPlanList.addAll(eachList);
                }
                try {
                    insert insertBillingPlanList;
                    UM001_LogManager.writeLogActivityWithoutFuture( 'Batch for Order Product',
                                                                    ClassName, 'Batch' , null,
                                                                    'Successfully insert Billing Plan List : ' + String.valueOf(insertBillingPlanList), 
                                                                    UM010_Constant.SUCCESS);     
                } catch (Exception e) {
                    ErrMsg = e.getMessage();
                } finally {
                    if(ErrMsg != null && String.isNotBlank(ErrMsg)){
                        UM001_LogManager.writeLogActivityWithoutFuture( 'Batch for Order Product',ClassName, 'Batch' , null,'Error while inserting Billing Plan List. Error : ' + ErrMsg, UM010_Constant.ERROR);              
                    }
                }
            }
            
            if (updateContractMap.size() > 0){
                ErrMsg = null;
                try {
                    update updateContractMap.values();
                    UM001_LogManager.writeLogActivityWithoutFuture( 'Batch for Order Product',
                                                                    ClassName, 'Batch' , null,
                                                                    'Successfully updated Contract records : ' + String.valueOf(updateContractMap.values()), 
                                                                    UM010_Constant.SUCCESS);     
                } catch (Exception e) {
                    ErrMsg = e.getMessage();
                } finally {
                    if(ErrMsg != null && String.isNotBlank(ErrMsg)){
                        UM001_LogManager.writeLogActivityWithoutFuture( 'Batch for Order Product',ClassName, 'Batch' , null,'Error while updating the Contracts. Error : ' + ErrMsg, UM010_Constant.ERROR);              
                    }
                }
            }
            
            for (blng__BillingTransaction__c eachTransaction : [SELECT Id, Name,blng__Amount__c, blng__BillingSchedule__r.blng__OrderProduct__c, blng__BillingTargetDate__c,blng__OverrideBillingTargetDate__c 
                                                                FROM blng__BillingTransaction__c 
                                                                WHERE blng__BillingSchedule__r.blng__OrderProduct__c IN: selectedOrderItemId ]) {
                                                                    
                if (!billingTransactionMap.containsKey(eachTransaction.blng__BillingSchedule__r.blng__OrderProduct__c)){
                    billingTransactionMap.put(eachTransaction.blng__BillingSchedule__r.blng__OrderProduct__c, new List<blng__BillingTransaction__c>());
                }
                billingTransactionMap.get(eachTransaction.blng__BillingSchedule__r.blng__OrderProduct__c).add(eachTransaction);
            }
            
            Set<String> invoicePlanIdSet = new Set<String>();

            for(Order order : [SELECT LPCR_RenouvellementPlanFacture__c FROM Order WHERE id IN: orderInvPlanIdsSet]) {

                if(order.LPCR_RenouvellementPlanFacture__c != null){
                    invoicePlanIdSet.add(order.LPCR_RenouvellementPlanFacture__c);
                }            
            }
            
            for(blng__InvoicePlanLine__c eachInvoicePlanLine : [SELECT Id, blng__CommencementDateOffset__c,blng__CommencementDateOffsetUnits__c, blng__InvoicePlan__c, blng__Percentage__c 
                                                                    FROM blng__InvoicePlanLine__c 
                                                                    WHERE blng__InvoicePlan__c IN: invoicePlanIdSet]) {

                if(!invoicePlanLineMap.containsKey(eachInvoicePlanLine.blng__InvoicePlan__c)){
                    invoicePlanLineMap.put(eachInvoicePlanLine.blng__InvoicePlan__c, new List<blng__InvoicePlanLine__c>());
                }
                invoicePlanLineMap.get(eachInvoicePlanLine.blng__InvoicePlan__c).add(eachInvoicePlanLine);
            }
            
            // ------------------------------------------------------------------------------------------------------------
            //
            // STEP 2 : Managing Billing Plan Line for billing plan
            //
            // ------------------------------------------------------------------------------------------------------------

            for(OrderItem eachOrderItem : scope) {

                eachOrderItem.LPCR_BillingPlanProcessment__c = true;
                
                // ------------------------------------------------------------------------------------------------------------
                // Manage != Invoice Plan LPCR_LignePlanFacturation__c
                // ------------------------------------------------------------------------------------------------------------
                if(eachOrderItem.SBQQ__BillingFrequency__c != 'Invoice Plan') {

                    if(billingPlanMap.containsKey(eachOrderItem.Id)) {

                        Integer itemIndex = 1;
                        Integer maxItemIndex = billingPlanMap.get(eachOrderItem.Id).size();
                        Double billableUnitPrice = 0;
                        
                        for(LPCR_PlanFacturation__c eachPlan : billingPlanMap.get(eachOrderItem.Id)) { // Looping through each LPCR_PlanFacturation__c of the OrderItem

                            Date tmpDate = eachPlan.LPCR_StartDate__c;
                            Integer totalDaysInBP = tmpDate.daysBetween(eachPlan.LPCR_EndDate__c)+1;
                            Double oneDayPriceBP = (eachPlan.LPCR_TotalContractValue__c/totalDaysInBP).setScale(4);
                            Integer intervel = 1;
                            Integer billingFrequency = 12;
                            
                            if (itemIndex == 1) { 
                                billableUnitPrice =  eachOrderItem.blng__BillableUnitPrice__c;
                            } 
                            else {
                                if(eachOrderItem.LPCR_Uplift__c > 0){
                                    billableUnitPrice += ((billableUnitPrice * eachOrderItem.LPCR_Uplift__c)/100);
                                }
                            }
                            
                            if ('Quarterly'.equals(eachOrderItem.SBQQ__BillingFrequency__c)) {
                                intervel = 3;
                                billingFrequency = 4;
                            }
                            else if ('Semiannual'.equals(eachOrderItem.SBQQ__BillingFrequency__c)) {
                                intervel = 6; 
                                billingFrequency = 2;
                            }
                            else if ('Annual'.equals(eachOrderItem.SBQQ__BillingFrequency__c)) {
                                intervel = 12; 
                                billingFrequency = 1;
                            }
                            
                            for (integer i = 1; i <= billingFrequency ; i++) { // Looping through each frequency iteration  

                                boolean isBreak = false;
                                boolean isFullDate = false;

                                LPCR_LignePlanFacturation__c newPlanLine = new LPCR_LignePlanFacturation__c();
                                newPlanLine.LPCR_OrderItem__c = eachOrderItem.Id;
                                newPlanLine.LPCR_BillingFrequency__c = eachOrderItem.SBQQ__BillingFrequency__c;
                                newPlanLine.LPCR_StartDate__c = tmpDate;
                                newPlanLine.LPCR_Quantity__c = eachOrderItem.Quantity;
                                newPlanLine.LPCR_PlanFacturation__c = eachPlan.Id;

                                Integer IntervalByMonth = 1;

                                if(intervel == 3){

                                    Integer months = tmpDate.month();
                                    
                                    if(months == 1 || months == 4 || months == 7 || months == 10) {

                                        IntervalByMonth = 3;
                                        if(newPlanLine.LPCR_StartDate__c.day() == 1){
                                            isFullDate = true;
                                            PAD.log(ClassName, 'execute','Is Full date'+ newPlanLine.LPCR_StartDate__c + '|LPCR_LignePlanFacturation__c:' + newPlanLine);
                                        }                                    
                                    }else if(months == 2 || months == 5 || months == 8 || months == 11){
                                        IntervalByMonth = 2;
                                    }else if(months == 3 || months == 6 || months == 9 || months == 12){
                                        IntervalByMonth = 1;
                                    }
                                }
                                if(intervel == 6){
                                    Integer months = tmpDate.month();
                                    if(months == 1 || months == 7){
                                        IntervalByMonth = 6;
                                        if(newPlanLine.LPCR_StartDate__c.day() == 1){
                                            isFullDate = true;
                                        }
                                    }
                                    if(months == 2 || months == 8){
                                        IntervalByMonth = 5;
                                    }
                                    if(months == 3 || months == 9){
                                        IntervalByMonth = 4;
                                    }
                                    if(months == 4 || months == 10){
                                        IntervalByMonth = 3;
                                    }
                                    if(months == 5 || months == 11){
                                        IntervalByMonth = 2;
                                    }
                                    if(months == 6 || months == 12){
                                        IntervalByMonth = 1;
                                    }
                                }
                                if(intervel == 12){
                                    Integer months = tmpDate.month();
                                    if(months == 1 ){
                                        IntervalByMonth = 12;
                                        if(newPlanLine.LPCR_StartDate__c.day() == 1){
                                            isFullDate = true;
                                        }
                                    }else{
                                        IntervalByMonth = (13 - months);
                                    }
                                    
                                }
                                
                                Date lastDayOfCurrentMonthDate=tmpDate.addMonths(IntervalByMonth-1); 
                                Integer numberOfDays = Date.daysInMonth(lastDayOfCurrentMonthDate.year(), lastDayOfCurrentMonthDate.month());
                                Date lastDayOfMonth = Date.newInstance(lastDayOfCurrentMonthDate.year(), lastDayOfCurrentMonthDate.month(), numberOfDays);
                                
                                if(eachPlan.LPCR_EndDate__c > lastDayOfMonth){ 
                                    newPlanLine.LPCR_EndDate__c = lastDayOfMonth;
                        
                                }
                                else{
                                    newPlanLine.LPCR_EndDate__c = eachPlan.LPCR_EndDate__c;
                                    if(newPlanLine.LPCR_EndDate__c != lastDayOfMonth){
                                        isFullDate = false;
                                    }
                                    isBreak = true;
                                }
                                
                                Integer noOfDaysInBPL = newPlanLine.LPCR_StartDate__c.daysBetween(newPlanLine.LPCR_EndDate__c) + 1;

                                if (itemIndex == 1) {

                                    if (isFullDate) {
                                        newPlanLine.LPCR_Amount__c = eachOrderItem.blng__BillableUnitPrice__c;
                                    }
                                    else {
                                        newPlanLine.LPCR_Amount__c = noOfDaysInBPL *  oneDayPriceBP;
                                    }
                                }
                                else if (itemIndex < maxItemIndex ) {
                                    newPlanLine.LPCR_Amount__c = eachPlan.LPCR_TotalContractValue__c/billingFrequency;
                                }
                                else {
                                    if (isFullDate) {
                                        newPlanLine.LPCR_Amount__c = billableUnitPrice;
                                        PAD.log(ClassName, 'execute','Partial Year Full Amount '+newPlanLine.LPCR_Amount__c + '|LPCR_LignePlanFacturation__c:' + newPlanLine);
                                    }else{
                                        newPlanLine.LPCR_Amount__c = noOfDaysInBPL *  oneDayPriceBP;
                                        PAD.log(ClassName, 'execute','Partial Year reminder Amount '+newPlanLine.LPCR_Amount__c + '|LPCR_LignePlanFacturation__c:' + newPlanLine);
                                    }
                                }   
                                
                                tmpDate = lastDayOfMonth.addDays(1);
                                billingPlanLineList.add(newPlanLine);

                                if(isBreak){
                                    break;
                                }
                            }
                            itemIndex++;
                        }
                    }
                    
                } else {
                // ------------------------------------------------------------------------------------------------------------
                // Manage Invoice Plan LPCR_LignePlanFacturation__c
                // ------------------------------------------------------------------------------------------------------------
                    if(billingPlanMap.containsKey(eachOrderItem.Id)) {

                        Integer itemIndex = 1;
                        Integer maxItemIndex = billingPlanMap.get(eachOrderItem.Id).size();

                        for(LPCR_PlanFacturation__c eachPlan : billingPlanMap.get(eachOrderItem.Id)) {

                            if(itemIndex == 1){
                                if(billingTransactionMap.containsKey(eachOrderItem.Id)){

                                    for(blng__BillingTransaction__c eachTransaction : billingTransactionMap.get(eachOrderItem.Id)){
                                        LPCR_LignePlanFacturation__c newPlanLine = new LPCR_LignePlanFacturation__c();
                                        newPlanLine.LPCR_OrderItem__c = eachOrderItem.Id;
                                        newPlanLine.LPCR_BillingFrequency__c = eachOrderItem.SBQQ__BillingFrequency__c;
                                        newPlanLine.LPCR_StartDate__c = (eachTransaction.blng__OverrideBillingTargetDate__c != null)?eachTransaction.blng__OverrideBillingTargetDate__c:eachTransaction.blng__BillingTargetDate__c;
                                        newPlanLine.LPCR_EndDate__c = (eachTransaction.blng__OverrideBillingTargetDate__c != null)?eachTransaction.blng__OverrideBillingTargetDate__c:eachTransaction.blng__BillingTargetDate__c;
                                        newPlanLine.LPCR_PlanFacturation__c = eachPlan.Id; 
                                        newPlanLine.LPCR_Amount__c = eachTransaction.blng__Amount__c;
                                        billingPlanLineList.add(newPlanLine);
                                    }
                                }
                            }
                            else {
                                if(invoicePlanLineMap.containsKey(eachOrderItem.Order.LPCR_RenouvellementPlanFacture__c)) {

                                    for(blng__InvoicePlanLine__c eachInvoicePlanLine : invoicePlanLineMap.get(eachOrderItem.Order.LPCR_RenouvellementPlanFacture__c)) {

                                        LPCR_LignePlanFacturation__c newPlanLine = new LPCR_LignePlanFacturation__c();
                                        newPlanLine.LPCR_OrderItem__c = eachOrderItem.Id;
                                        newPlanLine.LPCR_BillingFrequency__c = eachOrderItem.SBQQ__BillingFrequency__c;
                                        Date tmpDate = eachOrderItem.LPCR_ContractStartDate__c;
                                        if ('Days'.equals(eachInvoicePlanLine.blng__CommencementDateOffsetUnits__c)) {
                                            tmpDate = tmpDate.addDays((Integer)eachInvoicePlanLine.blng__CommencementDateOffset__c);
                                        }
                                        else if('Months'.equals(eachInvoicePlanLine.blng__CommencementDateOffsetUnits__c)) {
                                            tmpDate = tmpDate.addMonths((Integer)eachInvoicePlanLine.blng__CommencementDateOffset__c);
                                        }
                                        else {
                                            tmpDate = tmpDate.addYears((Integer)eachInvoicePlanLine.blng__CommencementDateOffset__c);
                                        }
                                        newPlanLine.LPCR_StartDate__c = tmpDate;
                                        newPlanLine.LPCR_EndDate__c = tmpDate;
                                        newPlanLine.LPCR_PlanFacturation__c = eachPlan.Id; 
                                        newPlanLine.LPCR_Amount__c =  eachPlan.LPCR_TotalContractValue__c ;
                                        billingPlanLineList.add(newPlanLine);
                                    }
                                }
                            }
                            itemIndex++;
                        }
                    }
                    
                }
                
            }  
            ErrMsg = null;
            if (billingPlanLineList.size() > 0) {

                PAD.log(ClassName, 'execute','billingPlanLineList size = '+ billingPlanLineList.size());
                PAD.log(ClassName, 'execute','billingPlanLineList data = '+ billingPlanLineList);

                try {
                    insert billingPlanLineList;
                    PAD.log(ClassName, 'execute','Insert success of :'+ billingPlanLineList);
                    UM001_LogManager.writeLogActivityWithoutFuture( 'Batch for Order Product',
                                                                    ClassName, 'Batch' , null,
                                                                    'Successfully inserted billingPlan Lines List : ' + String.valueOf(billingPlanLineList), 
                                                                    UM010_Constant.SUCCESS);     
                } catch (Exception e) {
                    PAD.log(ClassName, 'execute', '**** Exception : '+ e.getMessage());
                    ErrMsg = e.getMessage();
                } finally {
                    if(ErrMsg != null && String.isNotBlank(ErrMsg)){
                        UM001_LogManager.writeLogActivityWithoutFuture( 'Batch for Order Product',ClassName, 'Batch' , null,'Error while updating billingPlan Lines List. Error : ' + ErrMsg, UM010_Constant.ERROR);              
                    }
                }

            }
            ErrMsg = null;
            try {
                update scope;
                UM001_LogManager.writeLogActivityWithoutFuture( 'Batch for Order Product',
                                                                ClassName, 'Batch' , null,
                                                                'Successfully updated order Items : ' + String.valueOf(scope), 
                                                                UM010_Constant.SUCCESS);     
            } catch (Exception e) {
                ErrMsg = e.getMessage();
            } finally {
                if(ErrMsg != null && String.isNotBlank(ErrMsg)){
                    UM001_LogManager.writeLogActivityWithoutFuture( 'Batch for Order Product',ClassName, 'Batch' , null,'Error while updating the order items. Error : ' + ErrMsg, UM010_Constant.ERROR);              
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
        
        APB010_ProcessDailyOrderProduct sc1 = new APB010_ProcessDailyOrderProduct();
        Datetime dt = Datetime.now().addMinutes(30);  // i.e. 30 mins
        String timeForScheduler = dt.format('s m H d M \'?\' yyyy');
        // schedule the apex class only if their is not existing job running
        boolean isBatchJobRunning = UM004_BatchUtility.isBatchJobRunning(ClassName);
        
        // check if there is any open place to schedule the class
        boolean isJobQueueFull = UM004_BatchUtility.isBatchJobQueueFull();
        
        if(isBatchJobRunning == UM004_BatchUtility.BOOLEAN_FALSE){
            if (isJobQueueFull == UM004_BatchUtility.BOOLEAN_FALSE) {
                sc1 = new APB010_ProcessDailyOrderProduct();
                Database.executeBatch(this, 1);	
            } else {
                //schedule this same schedulable class again in 30 mins
                Id schedId = System.Schedule(ClassName+timeForScheduler,timeForScheduler,new APB010_ProcessDailyOrderProduct());
            }
        }  
        
    }
    
}