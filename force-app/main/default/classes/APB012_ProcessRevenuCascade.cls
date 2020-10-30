/**
* @author Saurabh
* @date 21/07/2020
* @Description Batch for ProcessRevenuCascade
*/
global class APB012_ProcessRevenuCascade implements Database.Batchable<sObject>,Schedulable{
    global APB012_ProcessRevenuCascade(){
        
    }
    
    global Database.QueryLocator start(Database.BatchableContext BC) {
        return Database.getQueryLocator([select id,LPCR_ProcessRevenuCascade__c from account where LPCR_ProcessRevenuCascade__c = true]);
    }
    
    global void execute(Database.BatchableContext BC, List<Account> scope) {

        // -----------------------------------------------------------------------------------------------
        // Initialisation --------------------------------------------------------------------------------
        // -----------------------------------------------------------------------------------------------

        PAD.log('APB012_ProcessRevenuCascade', 'execute', 'scope to execute : '+scope);
        
        Set<Id> accountsIdSet = UM003_TypeManager.getIdsOfListObjects(scope);
        Set<String> orderItemGroupingSet = new Set<String>();
        List<blng__RevenueTransaction__c> revenueTransList = [SELECT Id, Name, blng__Account__c, blng__RevenueFinancePeriod__c, blng__OrderProduct__c,
                                                                blng__InvoiceLine__r.blng__Invoice__c,blng__InvoiceLine__r.blng__Invoice__r.blng__InvoiceStatus__c 
                                                                FROM blng__RevenueTransaction__c 
                                                                WHERE blng__Account__c IN : accountsIdSet AND (blng__OrderProduct__c != null OR blng__InvoiceLine__c != null) 
                                                            ];
        Set<String> orderProductIds = UM003_TypeManager.getFieldsOfListObjects(revenueTransList,'blng__OrderProduct__c');
        Set<Id> orderLineIds = new Set<Id>();
        Map<String, Map<String,LPCR_RevenueCascade__c>> revenueCascadeMap = new Map<String, Map<String,LPCR_RevenueCascade__c>>();
        
        for (OrderItem eachOrderItem : [SELECT Id,blng__BillingAccount__c,SBQQ__Contract__c,LPCR_Creche__c,OrderId,Order.AccountId, Order.Status, 
                                            SBQQ__ChargeType__c,blng__GroupId__c 
                                            FROM OrderItem 
                                            WHERE Id IN: orderProductIds AND SBQQ__Contract__c != null AND Order.Status = 'Activated' AND SBQQ__ChargeType__c != 'One-Time'
                                        ]) {
            
            orderLineIds.add(eachOrderItem.Id);
            orderItemGroupingSet.add(eachOrderItem.Order.AccountId+''+eachOrderItem.SBQQ__Contract__c+''+eachOrderItem.LPCR_Creche__c);
        }
        
        for (LPCR_RevenueCascade__c eachRevCascade : [SELECT Id, Name, LPCR_Compte__c, LPCR_CreditNoteLineAggregation__c, LPCR_CreditNoteRevenue__c, LPCR_DateDebut__c, 
                                                        LPCR_MontantFacture__c, LPCR_OrderInvoiceRevenue__c, LPCR_OrderLineAggregation__c, LPCR_OrderLineGroup__c, LPCR_PCA__c 
                                                        FROM LPCR_RevenueCascade__c 
                                                        WHERE LPCR_OrderLineGroup__c IN : orderItemGroupingSet order by LPCR_DateDebut__c
                                                     ]) {
            
            if (!revenueCascadeMap.containsKey(eachRevCascade.LPCR_OrderLineGroup__c)) {

                revenueCascadeMap.put(eachRevCascade.LPCR_OrderLineGroup__c,new Map<String,LPCR_RevenueCascade__c>());
            }
            revenueCascadeMap.get(eachRevCascade.LPCR_OrderLineGroup__c).put(String.valueOf(eachRevCascade.LPCR_DateDebut__c),eachRevCascade);
        }
        
        PAD.log('APB012_ProcessRevenuCascade', 'execute', 'revenueCascadeMap size : '+revenueCascadeMap.size());
        System.debug(revenueCascadeMap.keySet());
        
        // ------------------------------------------------------------------------------------------------
        // STEP 1 : insert/update Waterfalll revenu records based on the corresponding revenue transactions 
        // (Also adjust the values corresponding to the revenue transactions updates) 
        // ------------------------------------------------------------------------------------------------

        list<AggregateResult> groupedResults = [SELECT blng__RevenueFinancePeriod__r.blng__PeriodStartDate__c rvp, SUM(blng__RevenueAmount__c) amount, 
                                                        SUM(blng__OrderProduct__r.Quantity) nbPlace, SUM(LPCR_PrixAnnuel__c) totalPrixAnnuel,
                                                        MAX(LPCR_NombreMois__c) nombreMois, blng__Account__c,blng__OrderProduct__r.SBQQ__Contract__c contract,
                                                        blng__OrderProduct__r.blng__GroupId__c groupId,blng__OrderProduct__r.Blng__LegalEntity__c legalEntity,
                                                        blng__OrderProduct__r.LPCR_Creche__c creche 
                                                    FROM blng__RevenueTransaction__c 
                                                    WHERE blng__OrderProduct__c != null AND blng__OrderProduct__c In :orderLineIds AND 
                                                    blng__OrderProduct__r.SBQQ__ChargeType__c != 'One-Time' 
                                                    GROUP BY blng__RevenueFinancePeriod__r.blng__PeriodStartDate__c,blng__Account__c,blng__OrderProduct__r.SBQQ__Contract__c ,
                                                    blng__OrderProduct__r.blng__GroupId__c,blng__OrderProduct__r.Blng__LegalEntity__c,blng__OrderProduct__r.LPCR_Creche__c 
                                                    Order By blng__RevenueFinancePeriod__r.blng__PeriodStartDate__c,blng__Account__c,blng__OrderProduct__r.SBQQ__Contract__c ,
                                                    blng__OrderProduct__r.blng__GroupId__c,blng__OrderProduct__r.Blng__LegalEntity__c,blng__OrderProduct__r.LPCR_Creche__c
                                                ];        

        PAD.log('APB012_ProcessRevenuCascade', 'execute', 'groupedResults step1 size : ' + groupedResults.size());
        List<LPCR_RevenueCascade__c> upsertRevenueCascadeList = new List<LPCR_RevenueCascade__c>();
        Map<String, double> step1AggregateAmountMap = new Map<String, double>();
        
        for (AggregateResult ar : groupedResults) {

            System.debug('>> APB012_ProcessRevenuCascade blng__RevenueFinancePeriod__c Date : ' + ar.get('rvp'));
            System.debug('>> APB012_ProcessRevenuCascade Sum amount : ' + ar.get('amount'));
            
            String groupId = String.valueOf(ar.get('groupId'));
            Double amount = Double.valueOf(ar.get('amount'));

            if(String.isNotBlank(groupId)) {
                
                if(!step1AggregateAmountMap.containsKey(groupId)) {
                    step1AggregateAmountMap.put(groupId, amount);
                }else {
                    step1AggregateAmountMap.put(groupId, step1AggregateAmountMap.get(groupId) + amount);
                }
            }
            
            String queryRvpResult = String.valueOf(ar.get('rvp'));
            String stDate = '';
           
            if(String.isNotBlank(queryRvpResult)){
                stDate = queryRvpResult.split(' ')[0];	
            }
            System.debug('>> APB012_ProcessRevenuCascade , execute(), step1 groupId :: '+ groupId);
           
            // Create the Revenue Waterfall records or update the existing ones
            if(revenueCascadeMap.keySet().Contains(groupId) && revenueCascadeMap.get(groupId).keySet().Contains(stDate)){

                LPCR_RevenueCascade__c updateRevCascade = revenueCascadeMap.get(groupId).get(stDate);
                updateRevCascade.LPCR_OrderLineAggregation__c = amount;

                if(step1AggregateAmountMap.keySet().Contains(groupId)){
                    updateRevCascade.LPCR_OrderInvoiceRevenue__c = step1AggregateAmountMap.get(groupId);
                }

                updateRevCascade.LPCR_Contrat__c = String.valueOf(ar.get('contract'));
                updateRevCascade.LPCR_NombrePlace__c = Integer.valueOf(ar.get('nbPlace'));
                updateRevCascade.LPCR_PrixAnnuel__c = Double.valueOf(ar.get('totalPrixAnnuel'));
                updateRevCascade.LPCR_NombreMois__c = UM005_DateUtility.getMonthNumberByString(String.valueOf(ar.get('nombreMois')));
                updateRevCascade.LPCR_EntiteJuridique__c = String.valueOf(ar.get('legalEntity'));
                updateRevCascade.LPCR_CompteCreche__c = String.valueOf(ar.get('creche'));
                upsertRevenueCascadeList.add(updateRevCascade);
                
            } else {

                LPCR_RevenueCascade__c newRevCascade = new LPCR_RevenueCascade__c();
                newRevCascade.LPCR_DateDebut__c = Date.valueOf(ar.get('rvp'));
                newRevCascade.LPCR_OrderLineAggregation__c = amount;
                
                if(step1AggregateAmountMap.keySet().Contains(groupId)){
                    newRevCascade.LPCR_OrderInvoiceRevenue__c = step1AggregateAmountMap.get(groupId);
                }
                
                newRevCascade.LPCR_Compte__c = String.valueOf(ar.get('blng__Account__c'));
                newRevCascade.LPCR_OrderLineGroup__c = groupId;
                newRevCascade.LPCR_Contrat__c = String.valueOf(ar.get('contract'));
                newRevCascade.LPCR_NombrePlace__c = Integer.valueOf(ar.get('nbPlace'));
                newRevCascade.LPCR_PrixAnnuel__c = Double.valueOf(ar.get('totalPrixAnnuel'));
                newRevCascade.LPCR_NombreMois__c = UM005_DateUtility.getMonthNumberByString(String.valueOf(ar.get('nombreMois')));
                newRevCascade.LPCR_EntiteJuridique__c = String.valueOf(ar.get('legalEntity'));
                newRevCascade.LPCR_CompteCreche__c = String.valueOf(ar.get('creche'));
                
                if(groupId != null){
                    if(!revenueCascadeMap.keySet().Contains(groupId)){
                        revenueCascadeMap.put(groupId, new Map<String,LPCR_RevenueCascade__c>());
                    }
                    revenueCascadeMap.get(groupId).put(String.valueOf(ar.get('rvp')),newRevCascade);
                }
                upsertRevenueCascadeList.add(newRevCascade);
            }           
        }
        
        upsert upsertRevenueCascadeList;
        upsertRevenueCascadeList = new List<LPCR_RevenueCascade__c>();
        
        System.debug('>> APB012_ProcessRevenuCascade , execute(), revenueCascadeMap : '+ revenueCascadeMap);
        System.debug('>> APB012_ProcessRevenuCascade , execute(), orderLineIds size : '+ orderLineIds.size());
        System.debug('>> APB012_ProcessRevenuCascade , execute(), orderLineIds '+orderLineIds);
        
        // ------------------------------------------------------------------------------------------------
        // STEP 2 : update Waterfall revenu records based on the corresponding credit notes
        // (Also adjust the values corresponding to the credit notes updates)
        // ------------------------------------------------------------------------------------------------

        List<blng__CreditNoteLine__c> creditNoteLineList = [SELECT Id,blng__CreditNote__c, blng__CreditNote__r.blng__Status__c, blng__InvoiceLine__r.blng__OrderProduct__c FROM blng__CreditNoteLine__c WHERE /*blng__CreditNote__r.blng__Status__c = 'Posted' AND*/ blng__InvoiceLine__r.blng__OrderProduct__c IN: orderLineIds];
        System.debug('>> APB012_ProcessRevenuCascade , execute(), creditNoteLineList size : '+ creditNoteLineList.size());
        System.debug(creditNoteLineList);
        
        if(creditNoteLineList.size() > 0){

            Set<Id> creditNoteLineIdSet = UM003_TypeManager.getIdsOfListObjects(creditNoteLineList);
            System.debug('>> APB012_ProcessRevenuCascade , execute(),creditNoteLineIdSet '+creditNoteLineIdSet);
            list<AggregateResult> step2GroupedResults = [SELECT blng__RevenueFinancePeriod__r.blng__PeriodStartDate__c rvp, SUM(blng__RevenueAmount__c) amount,blng__OrderProduct__r.blng__GroupId__c groupId FROM blng__RevenueTransaction__c WHERE blng__CreditNoteLine__c != null AND blng__CreditNoteLine__c In :creditNoteLineIdSet AND blng__CreditNoteLine__r.blng__InvoiceLine__r.blng__ChargeType__c != 'One-Time' GROUP BY blng__RevenueFinancePeriod__r.blng__PeriodStartDate__c,blng__OrderProduct__r.blng__GroupId__c Order By blng__RevenueFinancePeriod__r.blng__PeriodStartDate__c,blng__OrderProduct__r.blng__GroupId__c];
            Map<String, double> step2AggregateAmountMap = new Map<String, double>();
            system.debug('>> APB012_ProcessRevenuCascade , execute(),step2GroupedResults.size()==== ' + step2GroupedResults.size());
            
            for (AggregateResult ar : step2GroupedResults) {

                System.debug('blng__RevenueFinancePeriod__c Date : ' + ar.get('rvp'));
                System.debug('Sum amount : ' + ar.get('amount'));
                
                // Create the Revenue Waterfall records or update the existing ones
                String groupId = String.valueOf(ar.get('groupId'));
                Double amount = Double.valueOf(ar.get('amount'));
                
                if (String.isNotBlank(groupId)) {

                    if (!step2AggregateAmountMap.containsKey(groupId)) {
                        step2AggregateAmountMap.put(groupId,amount);
                    } else {
                        step2AggregateAmountMap.put(groupId,step2AggregateAmountMap.get(groupId)+amount);
                    }
                }
                
                System.debug('>> APB012_ProcessRevenuCascade , execute(), STEP 2 group id '+groupId);

                // Create the Revenue Waterfall records or update the existing ones
                if (revenueCascadeMap.keySet().Contains(groupId) && revenueCascadeMap.get(groupId).keySet().Contains(String.valueOf(ar.get('rvp')))) {

                    LPCR_RevenueCascade__c updateRevCascade = revenueCascadeMap.get(groupId).get(String.valueOf(ar.get('rvp')));
                    updateRevCascade.LPCR_CreditNoteLineAggregation__c = amount;

                    if(step2AggregateAmountMap.keySet().Contains(groupId)){
                        updateRevCascade.LPCR_CreditNoteRevenue__c = step1AggregateAmountMap.get(groupId); //aggregateAmount;
                    }
                    
                    upsertRevenueCascadeList.add(updateRevCascade);
                }
            }
        }
        if(upsertRevenueCascadeList.size() > 0){
            upsert upsertRevenueCascadeList;
        }	
        
        upsertRevenueCascadeList = new List<LPCR_RevenueCascade__c>();
        
        // ----------------------------------------------------------------------------------------------------------------
        // STEP 3 : Through 1) & 2) Step, contruct a set of related invoice. 
        // Query the invoiceLine objet in order to retrieve Sum of amount for each LPCR_OrderLineGroup__c.
        // Loop through each Waterfall Revenu record in order to update each related WaterfallRevenu.LPCR_OrderLineGroup__c
        // ----------------------------------------------------------------------------------------------------------------

        Set<Id> invoiceIdsSet = new Set<Id>();
        Map<String,Double> invoicedAmountMap = new Map<String,Double>();
        
        for(blng__RevenueTransaction__c eachRevTrans : revenueTransList){

            if (eachRevTrans.blng__InvoiceLine__c != null && 'Posted'.equals(eachRevTrans.blng__InvoiceLine__r.blng__Invoice__r.blng__InvoiceStatus__c)) {

                System.debug('>> APB012_ProcessRevenuCascade , execute(), Step 3 invoiceId = '+eachRevTrans.blng__InvoiceLine__r.blng__Invoice__c);
                invoiceIdsSet.add(eachRevTrans.blng__InvoiceLine__r.blng__Invoice__c);
            }
        }
        
        System.debug('>> APB012_ProcessRevenuCascade , execute(), Step 3 invoiceIdsSet = '+invoiceIdsSet);
        if (invoiceIdsSet.size() > 0) {

            // this will give the Aggregated sum, group by field present on the order product
            list<AggregateResult> amountGroupedResults = [SELECT blng__OrderProduct__r.blng__GroupId__c rvp, SUM(blng__Subtotal__c) amount 
                                                          FROM blng__InvoiceLine__c 
                                                          WHERE 
                                                          blng__Invoice__c IN: invoiceIdsSet
                                                          AND 
                                                          blng__ChargeType__c != 'One-Time' 
                                                          GROUP BY blng__OrderProduct__r.blng__GroupId__c 
                                                          Order By blng__OrderProduct__r.blng__GroupId__c];
            
            system.debug('>> APB012_ProcessRevenuCascade , execute(), amountGroupedResults.size()==== ' + amountGroupedResults.size());
            
            for (AggregateResult ar : amountGroupedResults){

                System.debug('>> APB012_ProcessRevenuCascade , execute(), step 3 blng__GroupId__c id is : ' + ar.get('rvp'));
                System.debug('>> APB012_ProcessRevenuCascade , execute(), step 3 Sum amount : ' + ar.get('amount'));
                invoicedAmountMap.put(String.valueOf(ar.get('rvp')), Double.valueOf(ar.get('amount')));
            }
            system.debug('>> APB012_ProcessRevenuCascade , execute(),step 3 invoicedAmountMap==== ' + invoicedAmountMap);
            
            // this will give the Aggregated Min and Max Date, group by field present on the order product
            list<AggregateResult> groupedResults2 = [SELECT blng__OrderProduct__r.blng__GroupId__c rvp, Min(blng__StartDate__c) minStartDate, Max(blng__EndDate__c) maxEndDate 
                                                     FROM blng__InvoiceLine__c 
                                                     WHERE 
                                                     blng__Invoice__c IN: invoiceIdsSet
                                                     AND 
                                                     blng__ChargeType__c != 'One-Time' 
                                                     AND
                                                     blng__Subtotal__c >= 0
                                                     GROUP BY blng__OrderProduct__r.blng__GroupId__c 
                                                     Order By blng__OrderProduct__r.blng__GroupId__c];
            
            
            system.debug('>> APB012_ProcessRevenuCascade , execute(),step 3 groupedResults2.size()==== ' + groupedResults2.size());
            system.debug('>> APB012_ProcessRevenuCascade , execute(),step 3 groupedResults2 ==== ' + groupedResults2);

            for (AggregateResult ar : groupedResults2)  {

                System.debug('>> APB012_ProcessRevenuCascade , execute(),step 3 blng__GroupId__c id is : ' + ar.get('rvp'));
                System.debug('>> APB012_ProcessRevenuCascade , execute(),step 3 minStartDate : ' + ar.get('minStartDate'));
                System.debug('>> APB012_ProcessRevenuCascade , execute(),step 3 maxEndDate : ' + ar.get('maxEndDate'));
                System.debug('>> APB012_ProcessRevenuCascade , execute(),step 3 revenueCascadeMap.keyset() : ' + revenueCascadeMap.keyset());
                String minDateKey = '';
                String minDate = String.valueOf(ar.get('minStartDate'));

                if(String.isNotBlank(minDate)){
                    minDateKey = minDate.split(' ')[0];	
                }

                if(revenueCascadeMap.keyset().contains(String.valueOf(ar.get('rvp')))){

                    System.debug('>> APB012_ProcessRevenuCascade , execute(),step 3 revenueCascadeMap.get().keyset() : ' + revenueCascadeMap.get(String.valueOf(ar.get('rvp'))).keyset());

                    for(LPCR_RevenueCascade__c updateRevCascade : revenueCascadeMap.get(String.valueOf(ar.get('rvp'))).values()) {

                        if(invoicedAmountMap.keyset().contains(String.valueOf(ar.get('rvp')))){
                            updateRevCascade.LPCR_MontantFacture__c = invoicedAmountMap.get(String.valueOf(ar.get('rvp')));
                            upsertRevenueCascadeList.add(updateRevCascade);
                        } 
                    }                    
                }
            }

            if(upsertRevenueCascadeList.size() > 0) {
                upsert upsertRevenueCascadeList;
                System.debug('>> APB012_ProcessRevenuCascade , execute(),upsertRevenueCascadeListAMOUNT '+upsertRevenueCascadeList);
            }
            
            upsertRevenueCascadeList = new List<LPCR_RevenueCascade__c>();
            Map<String,Double> creditNoteInvoicedAmountMap = new Map<String,Double>();
            Set<String> creditNoteIdsSet = UM003_TypeManager.getFieldsOfListObjects(creditNoteLineList,'blng__CreditNote__c');
            
            if(creditNoteIdsSet.size() > 0) {

                // this will give the Aggregated sum, group by field present on the order product
                list<AggregateResult> creditNoteLineGroupedResults = [SELECT blng__InvoiceLine__r.blng__OrderProduct__r.blng__GroupId__c rvp, SUM(blng__Subtotal__c) amount 
                                                        FROM blng__CreditNoteLine__c 
                                                        WHERE 
                                                        blng__CreditNote__c IN: creditNoteIdsSet
                                                        AND 
                                                        blng__InvoiceLine__r.blng__ChargeType__c != 'One-Time' 
                                                        GROUP BY blng__InvoiceLine__r.blng__OrderProduct__r.blng__GroupId__c 
                                                        Order By blng__InvoiceLine__r.blng__OrderProduct__r.blng__GroupId__c];
                
                
                system.debug('>> APB012_ProcessRevenuCascade , execute(),creditNoteLineGroupedResults.size()==== ' + creditNoteLineGroupedResults.size());
                
                for (AggregateResult ar : creditNoteLineGroupedResults) {

                    System.debug('blng__GroupId__c id is : ' + ar.get('rvp'));
                    System.debug('Sum amount : ' + ar.get('amount'));
                    creditNoteInvoicedAmountMap.put(String.valueOf(ar.get('rvp')), Double.valueOf(ar.get('amount')));
                }
                
                // this will give the Aggregated Min and Max Date, group by field present on the order product
                list<AggregateResult> creditNoteLineGroupedResults2 = [SELECT blng__InvoiceLine__r.blng__OrderProduct__r.blng__GroupId__c rvp, Min(blng__StartDate__c) minStartDate, Max(blng__EndDate__c) maxEndDate 
                                                         FROM blng__CreditNoteLine__c 
                                                         WHERE 
                                                         blng__CreditNote__c IN: creditNoteIdsSet
                                                         AND 
                                                         blng__InvoiceLine__r.blng__ChargeType__c != 'One-Time' 
                                                         AND
                                                         blng__Subtotal__c >= 0
                                                         GROUP BY blng__InvoiceLine__r.blng__OrderProduct__r.blng__GroupId__c 
                                                         Order By blng__InvoiceLine__r.blng__OrderProduct__r.blng__GroupId__c];
                
                
                system.debug('>> APB012_ProcessRevenuCascade , execute(),creditNoteLineGroupedResults2.size()==== ' + creditNoteLineGroupedResults2.size());
                
                for (AggregateResult ar : creditNoteLineGroupedResults2) {

                    System.debug('blng__GroupId__c id is : ' + ar.get('rvp'));
                    System.debug('minStartDate : ' + ar.get('minStartDate'));
                    System.debug('maxEndDate : ' + ar.get('maxEndDate'));

                    if(revenueCascadeMap.containsKey(String.valueOf(ar.get('rvp'))) && revenueCascadeMap.get(String.valueOf(ar.get('rvp'))).containsKey(String.valueOf(ar.get('minStartDate')))) {

                        LPCR_RevenueCascade__c updateRevCascade = revenueCascadeMap.get(String.valueOf(ar.get('rvp'))).get(String.valueOf(ar.get('minStartDate')));

                        if(creditNoteInvoicedAmountMap.containsKey(String.valueOf(ar.get('rvp')))) {
                            updateRevCascade.LPCR_MontantFacture__c = creditNoteInvoicedAmountMap.get(String.valueOf(ar.get('rvp')));
                        	upsertRevenueCascadeList.add(updateRevCascade);
                        }
                    }
                }
            }            
        }
        
        List<LPCR_Log__c> listOfLog = new List<LPCR_Log__c>();
        System.debug('>> APB012_ProcessRevenuCascade , execute(), upsertRevenueCascadeList size : '+ upsertRevenueCascadeList.size());
        
        // insert or update Revenue Cascade
        if(upsertRevenueCascadeList.size() > 0) {
            try {
                System.debug('>> APB012_ProcessRevenuCascade , execute(), upsertRevenueCascadeList.size = '+ upsertRevenueCascadeList.size());
                upsert upsertRevenueCascadeList;
            } catch(Exception ex) {
                System.debug('Exception: APB012_ProcessRevenuCascade | '+ ex.getMessage());
            }            
        }
        for (Account eachAcc : scope) {
            eachAcc.LPCR_ProcessRevenuCascade__c = false;
            listOfLog.add(UM001_LogManager.getWriteLogActivityForBulkInsert('Processing of Revenue Cascade', 'APB012_ProcessRevenuCascade', 'Batch', String.valueOf(eachAcc.Id), '', 'SUCCESS'));      
        }
        try {
            upsert scope;
            insert listOfLog;
        } catch(Exception ex) {
            System.debug('Exception: APB012_ProcessRevenuCascade | '+ ex.getMessage());
        }
        
    }
    
    global void finish(Database.BatchableContext BC) {
    }
    
    global void execute(SchedulableContext sc) {
        
        APB012_ProcessRevenuCascade sc1 = new APB012_ProcessRevenuCascade();
        
        // schedule the apex class only if their is not existing job running
        boolean isBatchJobRunning = UM004_BatchUtility.isBatchJobRunning('APB012_ProcessRevenuCascade');
        
        // check if there is any open place to schedule the class
        boolean isJobQueueFull = UM004_BatchUtility.isBatchJobQueueFull();
        
        if(isBatchJobRunning == UM004_BatchUtility.BOOLEAN_FALSE){
            if (isJobQueueFull == UM004_BatchUtility.BOOLEAN_FALSE) {
                sc1 = new APB012_ProcessRevenuCascade();
                Database.executeBatch(this, 1);
            } else {
                //schedule this same schedulable class again in 30 mins
                sc1 = new APB012_ProcessRevenuCascade();
                Datetime dt = Datetime.now().addMinutes(30);  // i.e. 30 mins
                String timeForScheduler = dt.format('s m H d M \'?\' yyyy');
                Id schedId = System.Schedule('APB012_ProcessRevenuCascade'+timeForScheduler,timeForScheduler,sc1);
            }
        }  
        
    }
}