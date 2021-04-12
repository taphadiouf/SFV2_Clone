/**
* @author Saurabh
* @date 21/07/2020
* @Description Batch for ProcessRevenuCascade
*/
global class APB012_ProcessRevenuCascade implements Database.Batchable<sObject>,Schedulable{
    
    final String ClassName = APB012_ProcessRevenuCascade.class.getName();
    global APB012_ProcessRevenuCascade(){
        
    }
    
    global Database.QueryLocator start(Database.BatchableContext BC) {

        UM001_LogManager.writeLogActivityWithoutFuture(ClassName,'start', 'Batch' , null, 'Starting Batch', UM010_Constant.SUCCESS);

        return Database.getQueryLocator([select id,LPCR_ProcessRevenuCascade__c from account where LPCR_ProcessRevenuCascade__c = true]);
    }
    
    global void execute(Database.BatchableContext BC, List<Account> scope) {

        // -----------------------------------------------------------------------------------------------
        // Initialisation --------------------------------------------------------------------------------
        // -----------------------------------------------------------------------------------------------
        
        List<Exception> errors = new List<Exception>();
        UM001_LogManager.writeLogActivityWithoutFuture(ClassName,'execute', 'Batch' , null, 'Scope size : '  + scope.size(), UM010_Constant.SUCCESS); 
    
        try {

            PAD.log(ClassName, 'execute', 'INIT - scope to execute : ' + scope);
            
            Set<Id> accountsIdSet = UM003_TypeManager.getIdsOfListObjects(scope);
            Set<String> orderItemGroupingSet = new Set<String>();

            PAD.logAllSetId(ClassName, 'execute', 'INIT - accountsIdSet : ', accountsIdSet);

            List<blng__RevenueTransaction__c> revenueTransList = [SELECT Id, Name, blng__Account__c, blng__RevenueFinancePeriod__c, blng__OrderProduct__c,
                                                                    blng__InvoiceLine__r.blng__Invoice__c,blng__InvoiceLine__r.blng__Invoice__r.blng__InvoiceStatus__c 
                                                                    FROM blng__RevenueTransaction__c 
                                                                    WHERE blng__Account__c IN : accountsIdSet AND (blng__OrderProduct__c != null OR blng__InvoiceLine__c != null) 
                                                                ];
            Set<String> orderProductIds = UM003_TypeManager.getFieldsOfListObjects(revenueTransList,'blng__OrderProduct__c');

            PAD.logAllSetString(ClassName, 'execute', 'INIT - orderProductIds : ', orderProductIds);

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

            PAD.logAllSetId(ClassName, 'execute', 'INIT - orderLineIds : ', orderLineIds);
            PAD.logAllSetString(ClassName, 'execute', 'INIT - orderItemGroupingSet : ', orderItemGroupingSet);
            
            for (LPCR_RevenueCascade__c eachRevCascade : [SELECT Id, Name, LPCR_Compte__c, LPCR_NombrePlace__c, LPCR_CreditNoteLineAggregation__c, LPCR_CreditNoteRevenue__c, LPCR_DateDebut__c, 
                                                            LPCR_MontantFacture__c, LPCR_OrderInvoiceRevenue__c, LPCR_OrderLineAggregation__c, LPCR_OrderLineGroup__c, LPCR_PCA__c 
                                                            FROM LPCR_RevenueCascade__c 
                                                            WHERE LPCR_OrderLineGroup__c IN : orderItemGroupingSet order by LPCR_DateDebut__c
                                                        ]) {
                
                if (!revenueCascadeMap.containsKey(eachRevCascade.LPCR_OrderLineGroup__c)) {

                    revenueCascadeMap.put(eachRevCascade.LPCR_OrderLineGroup__c,new Map<String,LPCR_RevenueCascade__c>());
                }
                revenueCascadeMap.get(eachRevCascade.LPCR_OrderLineGroup__c).put(String.valueOf(eachRevCascade.LPCR_DateDebut__c),eachRevCascade);
            }
            
            PAD.log(ClassName, 'execute', 'INIT - revenueCascadeMap size : '+revenueCascadeMap.size());
            PAD.log(ClassName, 'execute', 'INIT - revenueCascadeMap.keySet():' + revenueCascadeMap.keySet());
            PAD.log(ClassName, 'execute', 'INIT - Displaying revenueCascadeMap...');
            for (String grpId : revenueCascadeMap.keyset()) {
                for (String mapRcKey : revenueCascadeMap.get(grpId).keySet()) {                    
                    PAD.log(ClassName, 'execute', 'INIT - revenueCascadeMap Key (grpId):' + grpId + ' - revenueCascadeMap Sub Key-Value mapRc Key:' + mapRcKey + ' - mapRc Value:' + revenueCascadeMap.get(grpId).get(mapRcKey));
                }
            }

            // ------------------------------------------------------------------------------------------------
            // STEP 1 : insert/update Waterfalll revenu records based on the corresponding revenue transactions 
            // (Also adjust the values corresponding to the revenue transactions updates) 
            // ------------------------------------------------------------------------------------------------
            PAD.log(ClassName, 'execute', '---------------------------------- ');
            PAD.log(ClassName, 'execute', '--------------- STEP 1 ----------- ');
            PAD.log(ClassName, 'execute', '---------------------------------- ');

            PAD.log(ClassName, 'execute', 'STEP 1 - orderLineIds : ' + orderLineIds);
            PAD.logAllSetId(ClassName, 'execute', 'STEP 1 - orderLineIds',orderLineIds);

            list<AggregateResult> groupedResults = [SELECT blng__RevenueFinancePeriod__r.blng__PeriodStartDate__c rvp, SUM(LPCR_MontantBascule__c) amount, 
                                                            SUM(blng__OrderProduct__r.Quantity) nbPlace, SUM(LPCR_PrixAnnuel__c) totalPrixAnnuel,
                                                            MAX(LPCR_NombreMois__c) nombreMois, blng__Account__c,blng__OrderProduct__r.SBQQ__Contract__c contract,
                                                            blng__OrderProduct__r.blng__GroupId__c groupId,blng__OrderProduct__r.Blng__LegalEntity__c legalEntity,
                                                            blng__OrderProduct__r.LPCR_Creche__c creche 
                                                        FROM blng__RevenueTransaction__c 
                                                        WHERE blng__OrderProduct__c != null AND blng__OrderProduct__c In :orderLineIds AND LPCR_MontantBascule__c != null AND
                                                        blng__OrderProduct__r.SBQQ__ChargeType__c != 'One-Time' 
                                                        GROUP BY blng__RevenueFinancePeriod__r.blng__PeriodStartDate__c,blng__Account__c,blng__OrderProduct__r.SBQQ__Contract__c ,
                                                        blng__OrderProduct__r.blng__GroupId__c,blng__OrderProduct__r.Blng__LegalEntity__c,blng__OrderProduct__r.LPCR_Creche__c 
                                                        Order By blng__RevenueFinancePeriod__r.blng__PeriodStartDate__c,blng__Account__c,blng__OrderProduct__r.SBQQ__Contract__c ,
                                                        blng__OrderProduct__r.blng__GroupId__c,blng__OrderProduct__r.Blng__LegalEntity__c,blng__OrderProduct__r.LPCR_Creche__c
                                                    ];        

            PAD.log(ClassName, 'execute', 'STEP 1 - groupedResults step1 size : ' + groupedResults.size());
            PAD.logAllList(ClassName, 'execute', 'STEP 2 - groupedResults',groupedResults);

            List<LPCR_RevenueCascade__c> upsertRevenueCascadeList = new List<LPCR_RevenueCascade__c>();
            Map<String, double> step1AggregateAmountMap = new Map<String, double>();
            
            for (AggregateResult ar : groupedResults) {

                PAD.log(ClassName, 'execute', 'STEP 1 - blng__RevenueFinancePeriod__c Date : ' + ar.get('rvp'));
                PAD.log(ClassName, 'execute', 'STEP 1 - Sum amount : ' + ar.get('amount'));
                PAD.log(ClassName, 'execute', 'STEP 1 - test1:' + ar.get('nbPlace'));
                PAD.log(ClassName, 'execute', 'STEP 1 - test1:' + ((Decimal)ar.get('nbPlace')));
                //PAD.log(ClassName, 'execute', 'STEP 1 - test1:' + ((Double)ar.get('nbPlace')));
                //PAD.log(ClassName, 'execute', 'STEP 1 - test1:' + ((Integer)ar.get('nbPlace')));

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

                PAD.log(ClassName, 'execute', 'STEP 1 - groupId :: '+ groupId);
            
                // Update existing Revenue Waterfall records
                if(revenueCascadeMap.keySet().Contains(groupId) && revenueCascadeMap.get(groupId).keySet().Contains(stDate)){

                    LPCR_RevenueCascade__c updateRevCascade = revenueCascadeMap.get(groupId).get(stDate);
                    updateRevCascade.LPCR_OrderLineAggregation__c = amount;

                    if(step1AggregateAmountMap.keySet().Contains(groupId)){
                        updateRevCascade.LPCR_OrderInvoiceRevenue__c = step1AggregateAmountMap.get(groupId);
                    }

                    updateRevCascade.LPCR_Contrat__c = String.valueOf(ar.get('contract'));

                    Decimal majNbPlace = Integer.valueOf(String.valueOf(ar.get('nbPlace')));

                    updateRevCascade.LPCR_NombrePlace__c = majNbPlace >= 0 ? majNbPlace : 0;
                    updateRevCascade.LPCR_PrixAnnuel__c = Double.valueOf(ar.get('totalPrixAnnuel'));
                    updateRevCascade.LPCR_NombreMois__c = UM005_DateUtility.getMonthNumberByString(String.valueOf(ar.get('nombreMois')));
                    updateRevCascade.LPCR_EntiteJuridique__c = String.valueOf(ar.get('legalEntity'));
                    updateRevCascade.LPCR_CompteCreche__c = String.valueOf(ar.get('creche'));
                    
                    PAD.log(ClassName, 'execute', 'STEP 1 - Add existing LPCR_RevenueCascade__c record:' + updateRevCascade);
                    upsertRevenueCascadeList.add(updateRevCascade);
                    
                } else { // Create the Revenue Waterfall

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
                    PAD.log(ClassName, 'execute', 'STEP 1 - Add new LPCR_RevenueCascade__c:' + newRevCascade);
                    upsertRevenueCascadeList.add(newRevCascade);
                }           
            }
            
            upsert upsertRevenueCascadeList;
            upsertRevenueCascadeList = new List<LPCR_RevenueCascade__c>();
            
            //Map<String, Map<String,LPCR_RevenueCascade__c>> revenueCascadeMap = new Map<String, Map<String,LPCR_RevenueCascade__c>>();
            for (String grpId : revenueCascadeMap.keyset()) {

                //for (Map<String,LPCR_RevenueCascade__c> mapRc : revenueCascadeMap.get(grpId).keySet()) {

                    for (String mapRcKey : revenueCascadeMap.get(grpId).keySet()) {
                        
                        PAD.log(ClassName, 'execute', 'STEP 1 - revenueCascadeMap Key (grpId):' + grpId + ' - revenueCascadeMap Sub Key-Value mapRc Key:' + mapRcKey + ' - mapRc Value:' + revenueCascadeMap.get(grpId).get(mapRcKey));
                    }
            }

            PAD.log(ClassName, 'execute', 'STEP 1 - revenueCascadeMap :' + revenueCascadeMap);
            PAD.log(ClassName, 'execute', 'STEP 1 - orderLineIds size :' + orderLineIds.size());
            PAD.log(ClassName, 'execute', 'STEP 1 - orderLineIds :' + orderLineIds);
            
            // ------------------------------------------------------------------------------------------------
            // STEP 2 : update Waterfall revenu records based on the corresponding credit notes
            // (Also adjust the values corresponding to the credit notes updates)
            // ------------------------------------------------------------------------------------------------
            PAD.log(ClassName, 'execute', '---------------------------------- ');
            PAD.log(ClassName, 'execute', '--------------- STEP 2 ----------- ');
            PAD.log(ClassName, 'execute', '---------------------------------- ');

            List<blng__CreditNoteLine__c> creditNoteLineList = [SELECT Id,blng__CreditNote__c, blng__CreditNote__r.blng__Status__c, blng__InvoiceLine__r.blng__OrderProduct__c 
                                                                FROM blng__CreditNoteLine__c 
                                                                WHERE /*blng__CreditNote__r.blng__Status__c = 'Posted' AND*/ blng__InvoiceLine__r.blng__OrderProduct__c IN: orderLineIds];

            PAD.log(ClassName, 'execute', 'STEP 2 - creditNoteLineList size : '+ creditNoteLineList.size());
            PAD.log(ClassName, 'execute', 'STEP 2 - creditNoteLineList:' + creditNoteLineList);
            
            if(creditNoteLineList.size() > 0){

                Set<Id> creditNoteLineIdSet = UM003_TypeManager.getIdsOfListObjects(creditNoteLineList);

                PAD.log(ClassName, 'execute', 'STEP 2 - creditNoteLineIdSet :'+creditNoteLineIdSet);

                list<AggregateResult> step2GroupedResults = [SELECT blng__RevenueFinancePeriod__r.blng__PeriodStartDate__c rvp, SUM(blng__RevenueAmount__c) amount,blng__CreditNoteLine__r.blng__InvoiceLine__r.blng__OrderProduct__r.blng__GroupId__c groupId 
                                                                FROM blng__RevenueTransaction__c 
                                                                WHERE blng__CreditNoteLine__c != null AND blng__CreditNoteLine__c In :creditNoteLineIdSet AND blng__CreditNoteLine__r.blng__InvoiceLine__r.blng__ChargeType__c != 'One-Time' 
                                                                GROUP BY blng__RevenueFinancePeriod__r.blng__PeriodStartDate__c,blng__CreditNoteLine__r.blng__InvoiceLine__r.blng__OrderProduct__r.blng__GroupId__c
                                                                ORDER By blng__RevenueFinancePeriod__r.blng__PeriodStartDate__c,blng__CreditNoteLine__r.blng__InvoiceLine__r.blng__OrderProduct__r.blng__GroupId__c
                                                            ];
                
                Map<String, double> step2AggregateAmountMap = new Map<String, double>();
                PAD.log(ClassName, 'execute', 'STEP 2 - step2GroupedResults.size()==== ' + step2GroupedResults.size());
                PAD.logAllList(ClassName, 'execute', 'STEP 2 - step2GroupedResults',step2GroupedResults);
                
                for (AggregateResult ar : step2GroupedResults) {

                    PAD.log(ClassName, 'execute', 'STEP 2 - Credit Note Line Management - PART 0');
                    
                    // Create the Revenue Waterfall records or update the existing ones
                    String groupId = String.valueOf(ar.get('groupId'));
                    Double amount = Double.valueOf(ar.get('amount'));
                    
                    PAD.log(ClassName, 'execute', 'STEP 2 - Credit Note Line Management - PART I - groupId:' + groupId);
                    PAD.log(ClassName, 'execute', 'STEP 2 - Credit Note Line Management - PART I - amount:' + amount);

                    if (String.isNotBlank(groupId)) {

                        if (!step2AggregateAmountMap.containsKey(groupId)) {
                            step2AggregateAmountMap.put(groupId,amount);
                        } else {
                            step2AggregateAmountMap.put(groupId,step2AggregateAmountMap.get(groupId)+amount);
                        }
                    }
                    
                    
                    Boolean containsGroupId = revenueCascadeMap.keySet().Contains(groupId);
                    PAD.log(ClassName, 'execute', 'STEP 2 - Credit Note Line Management - PART I - revenueCascadeMap.keySet().Contains(groupId):' + containsGroupId);

                    PAD.log(ClassName, 'execute', 'STEP 2 - Credit Note Line Management - PART I - String.valueOf(ar.get(rvp):' + String.valueOf(ar.get('rvp')));
                    PAD.log(ClassName, 'execute', 'STEP 2 - Credit Note Line Management - PART I - String.valueOf(ar.get(rvp):' + ar.get('rvp'));
                                        
                    if (containsGroupId) {
                        PAD.log(ClassName, 'execute', 'STEP 2 - Credit Note Line Management - PART I - revenueCascadeMap.get(groupId).keySet():' + revenueCascadeMap.get(groupId).keySet());
                    }
                    
                    PAD.log(ClassName, 'execute', 'STEP 2 - group id ' + groupId);

                    String queryRvpResult = String.valueOf(ar.get('rvp'));
                    String stDate = '';
                
                    if(String.isNotBlank(queryRvpResult)){
                        stDate = queryRvpResult.split(' ')[0];	
                    }	

                    // Create the Revenue Waterfall records or update the existing ones
                    if (revenueCascadeMap.keySet().Contains(groupId) && revenueCascadeMap.get(groupId).keySet().Contains(stDate)) {

                        PAD.log(ClassName, 'execute', 'STEP 2 - Credit Note Line Management - PART II');
                        LPCR_RevenueCascade__c updateRevCascade = revenueCascadeMap.get(groupId).get(stDate);
                        updateRevCascade.LPCR_CreditNoteLineAggregation__c = amount;

                        if(step2AggregateAmountMap.keySet().Contains(groupId)){

                            PAD.log(ClassName, 'execute', 'STEP 2 - Credit Note Line Management - PART III :' + step1AggregateAmountMap.get(groupId));
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
            PAD.log(ClassName, 'execute', '---------------------------------- ');
            PAD.log(ClassName, 'execute', '--------------- STEP 3 ----------- ');
            PAD.log(ClassName, 'execute', '---------------------------------- ');

            Set<Id> invoiceIdsSet = new Set<Id>();
            Map<String,Double> invoicedAmountMap = new Map<String,Double>();
            
            for(blng__RevenueTransaction__c eachRevTrans : revenueTransList){

                if (eachRevTrans.blng__InvoiceLine__c != null && 'Posted'.equals(eachRevTrans.blng__InvoiceLine__r.blng__Invoice__r.blng__InvoiceStatus__c)) {

                    PAD.log(ClassName, 'execute', 'STEP 3 - invoiceId = '+eachRevTrans.blng__InvoiceLine__r.blng__Invoice__c);
                    invoiceIdsSet.add(eachRevTrans.blng__InvoiceLine__r.blng__Invoice__c);
                }
            }
            
            PAD.log(ClassName, 'execute', 'STEP 3 - invoiceIdsSet = '+invoiceIdsSet);

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
                
                PAD.log(ClassName, 'execute', 'STEP 3 - amountGroupedResults.size()==== ' + amountGroupedResults.size());
                
                for (AggregateResult ar : amountGroupedResults){

                    PAD.log(ClassName, 'execute', 'STEP 3 - blng__GroupId__c id is : ' + ar.get('rvp'));
                    PAD.log(ClassName, 'execute', 'STEP 3 - Sum amount : ' + ar.get('amount'));

                    invoicedAmountMap.put(String.valueOf(ar.get('rvp')), Double.valueOf(ar.get('amount')));
                }
                PAD.log(ClassName, 'execute', 'STEP 3 - invoicedAmountMap==== ' + invoicedAmountMap);
                
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
                
                PAD.log(ClassName, 'execute', 'STEP 3 - groupedResults2.size()==== ' + groupedResults2.size());
                PAD.log(ClassName, 'execute', 'STEP 3 - groupedResults2 ==== ' + groupedResults2);

                for (AggregateResult ar : groupedResults2)  {

                    PAD.log(ClassName, 'execute', 'STEP 3 - blng__GroupId__c id is : ' + ar.get('rvp'));
                    PAD.log(ClassName, 'execute', 'STEP 3 - minStartDate : ' + ar.get('minStartDate'));
                    PAD.log(ClassName, 'execute', 'STEP 3 - maxEndDate : ' + ar.get('maxEndDate'));
                    PAD.log(ClassName, 'execute', 'STEP 3 - revenueCascadeMap.keyset() : ' + revenueCascadeMap.keyset());

                    String minDateKey = '';
                    String minDate = String.valueOf(ar.get('minStartDate'));

                    if(String.isNotBlank(minDate)){
                        minDateKey = minDate.split(' ')[0];	
                    }

                    if(revenueCascadeMap.keyset().contains(String.valueOf(ar.get('rvp')))){

                        PAD.log(ClassName, 'execute', 'STEP 3 - revenueCascadeMap.get().keyset() : ' + revenueCascadeMap.get(String.valueOf(ar.get('rvp'))).keyset());

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
                    PAD.log(ClassName, 'execute', 'STEP 3 - upsertRevenueCascadeListAMOUNT :'+upsertRevenueCascadeList);
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
                    
                    PAD.log(ClassName, 'execute', 'STEP 3 - creditNoteLineGroupedResults.size()==== ' + creditNoteLineGroupedResults.size());
                    
                    for (AggregateResult ar : creditNoteLineGroupedResults) {

                        PAD.log(ClassName, 'execute', 'STEP 3 - blng__GroupId__c id is : ' + ar.get('rvp'));
                        PAD.log(ClassName, 'execute', 'STEP 3 - Sum amount : ' + ar.get('amount'));

                        creditNoteInvoicedAmountMap.put(String.valueOf(ar.get('rvp')), Double.valueOf(ar.get('amount')));
                    }
                    
                    // this will give the Aggregated Min and Max Date, group by field present on the order product
                    list<AggregateResult> creditNoteLineGroupedResults2 = [SELECT blng__InvoiceLine__r.blng__OrderProduct__r.blng__GroupId__c rvp, 
                                                                                Min(blng__StartDate__c) minStartDate, Max(blng__EndDate__c) maxEndDate 
                                                                            FROM blng__CreditNoteLine__c 
                                                                            WHERE 
                                                                            blng__CreditNote__c IN: creditNoteIdsSet
                                                                            AND 
                                                                            blng__InvoiceLine__r.blng__ChargeType__c != 'One-Time' 
                                                                            AND
                                                                            blng__Subtotal__c >= 0
                                                                            GROUP BY blng__InvoiceLine__r.blng__OrderProduct__r.blng__GroupId__c 
                                                                            Order By blng__InvoiceLine__r.blng__OrderProduct__r.blng__GroupId__c];
                    
                    PAD.log(ClassName, 'execute', 'STEP 3 - creditNoteLineGroupedResults2.size()==== ' + creditNoteLineGroupedResults2.size());
                    
                    for (AggregateResult ar : creditNoteLineGroupedResults2) {

                        PAD.log(ClassName, 'execute', 'STEP 3 - blng__GroupId__c id is : ' + ar.get('rvp'));
                        PAD.log(ClassName, 'execute', 'STEP 3 - minStartDate : ' + ar.get('minStartDate'));
                        PAD.log(ClassName, 'execute', 'STEP 3 - maxEndDate : ' + ar.get('maxEndDate'));

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
            
            // ----------------------------------------------------------------------------------------------------------------
            // FINAL EXECUTE PART :  upsert upsertRevenueCascadeList and set Account LPCR_ProcessRevenuCascade__c to false
            // ----------------------------------------------------------------------------------------------------------------
            PAD.log(ClassName, 'execute', '----------------------------------------- ');
            PAD.log(ClassName, 'execute', '--------------- FINAL EXECUTE PART ------ ');
            PAD.log(ClassName, 'execute', '----------------------------------------- ');

            List<LPCR_Log__c> listOfLog = new List<LPCR_Log__c>();
            PAD.log(ClassName, 'execute', 'FINAL EXECUTE PART - upsertRevenueCascadeList size : '+ upsertRevenueCascadeList.size());

            // insert or update Revenue Cascade
            if(upsertRevenueCascadeList.size() > 0) {

                try {
                    PAD.log(ClassName, 'execute', 'FINAL EXECUTE PART - upsertRevenueCascadeList.size = '+ upsertRevenueCascadeList.size());
                    upsert upsertRevenueCascadeList;
                } catch(Exception ex) {
                    PAD.log(ClassName, 'execute', 'FINAL EXECUTE PART - Exception: APB012_ProcessRevenuCascade | '+ ex.getMessage());
                }  
            }

            for (Account eachAcc : scope) {
                
                eachAcc.LPCR_ProcessRevenuCascade__c = false;

                PAD.log(ClassName, 'execute', 'FINAL EXECUTE PART - Adding to listOfLog:' + eachAcc);
                UM001_LogManager.writeLogActivityWithoutFuture(ClassName,'execute', 'Batch' , null, 'eachAcc : '  + eachAcc, UM010_Constant.SUCCESS);  
                  
            }
            String conclusionError;
            try {

                upsert scope;
                insert listOfLog;

            } catch(Exception ex) {

                PAD.log(ClassName, 'execute', 'FINAL EXECUTE PART - Exception: APB012_ProcessRevenuCascade | '+ ex.getMessage());
                conclusionError = ex.getMessage();
            }
            finally {
                if (conclusionError != null) {
                    PAD.log(ClassName, 'execute', 'FINAL EXECUTE PART - Error:' + conclusionError);
                    UM001_LogManager.writeLogActivityWithoutFuture(ClassName, 'execute', 'Batch' , null,'Error : ' + conclusionError + showLineError(errors), UM010_Constant.ERROR);
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
            result += 'line:' + tmpE.getLineNumber() + '-';
        }
        return result;
        
    }
    
    global void finish(Database.BatchableContext BC) {
        UM001_LogManager.writeLogActivityWithoutFuture(ClassName,'finish', 'Batch' , null, 'Finished Batch Processing', UM010_Constant.SUCCESS);
    }
    
    global void execute(SchedulableContext sc) {
        
        APB012_ProcessRevenuCascade sc1 = new APB012_ProcessRevenuCascade();
        
        // schedule the apex class only if their is not existing job running
        boolean isBatchJobRunning = UM004_BatchUtility.isBatchJobRunning(ClassName);
        
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
                Id schedId = System.Schedule(ClassName+timeForScheduler,timeForScheduler,sc1);
            }
        }  
        
    }
}