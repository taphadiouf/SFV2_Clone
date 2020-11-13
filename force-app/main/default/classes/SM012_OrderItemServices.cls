/**
* @author Ayoub Ouarti
* @date 26/03/2020
* @description Service class for SM012_OrderItemServices
*/
public with sharing class SM012_OrderItemServices implements Queueable{
    List<OrderItem> listOrderItem ;
    public SM012_OrderItemServices(List<OrderItem> listOrderItem) {
        this.listOrderItem = listOrderItem;
    }

    public static void enqueueJob(List<OrderItem> newOrderItemsList){
        List<OrderItem> orderItemToProcess = new List<OrderItem> ();
        for(OrderItem oi : newOrderItemsList){
            if(oi.blng__LegalEntity__c == null){
                orderItemToProcess.add(oi);
            }
        }
        if (orderItemToProcess.size() > 0) {
            SM012_OrderItemServices job = new SM012_OrderItemServices(newOrderItemsList);
            ID jobID = System.enqueueJob(job);
        }
    }

    public void execute(QueueableContext context) {
        SM012_OrderItemServices.setLegalEntityOnOrderItem(this.listOrderItem);
    }
    
    // DCO Is there any specific reasons to run this aynch on AfterUpdate?
    public static void setLegalEntityOnOrderItem(List<OrderItem> newOrderItem){

        Set<Id> orderItemId = UM003_TypeManager.getIdsOfListObjects(newOrderItem);
        List<OrderItem> listOrderItem = [SELECT Id,blng__LegalEntity__c, SBQQ__QuoteLine__r.LPCR_EntiteJuridique__c  FROM OrderItem WHERE ID in :orderItemId];
        //Boolean updateOrderItem = false;
        for(OrderItem eachOrderItem : listOrderItem){
            if(eachOrderItem.blng__LegalEntity__c ==null){

                eachOrderItem.blng__LegalEntity__c = eachOrderItem.SBQQ__QuoteLine__r.LPCR_EntiteJuridique__c;
                PAD.log('SM012_OrderItemServices', 'setLegalEntityOnOrderItem' , 'setting legal entity on Order item ' +eachOrderItem.blng__LegalEntity__c);
            }
        }

        update listOrderItem;
    }

    public static void updateGroupId(Map<Id, OrderItem> oldOrderItemsMap, List<OrderItem> newOrderItemsList){

        Set<Id> objOrderItemIds = new Set<Id>();

        for(OrderItem orderItem : newOrderItemsList){
            if((orderItem.LPCR_Creche__c != null) && (orderItem.SBQQ__Contract__c != null && (orderItem.SBQQ__Contract__c != oldOrderItemsMap.get(orderItem.Id).SBQQ__Contract__c))){
                    objOrderItemIds.add(orderItem.Id);
            }
        }

        if(objOrderItemIds.size() > 0){
              
            List<OrderItem> objOrderItemList = [Select Id,Order.AccountId,SBQQ__Contract__c,LPCR_Creche__c,blng__GroupId__c,
                                                blng__InvoiceGroupId__c from OrderItem where Id IN : objOrderItemIds];
            for(OrderItem objOrderItem : objOrderItemList){
                objOrderItem.blng__GroupId__c = objOrderItem.Order.AccountId+''+objOrderItem.SBQQ__Contract__c+''+objOrderItem.LPCR_Creche__c;
            }
            if(objOrderItemList.size() > 0){
                update objOrderItemList;
            }

        }
    }
    public static void legalEntityOnOrderItemConSch( Map<Id,OrderItem> mapOrderItem){

        List<SBQQ__OrderItemConsumptionSchedule__c> listOrderItemConSch = [SELECT SBQQ__OrderItem__c,SBQQ__OrderItem__r.blng__LegalEntity__c,blng__LegalEntity__c  FROM SBQQ__OrderItemConsumptionSchedule__c WHERE SBQQ__OrderItem__c in :mapOrderItem.keySet() ];
        List<SBQQ__OrderItemConsumptionSchedule__c> listOrderItemConSchtoSave = new List<SBQQ__OrderItemConsumptionSchedule__c>();

        for(SBQQ__OrderItemConsumptionSchedule__c eachOrderItemConSch : listOrderItemConSch) {

            if(eachOrderItemConSch.SBQQ__OrderItem__r.blng__LegalEntity__c != null ){

                eachOrderItemConSch.blng__LegalEntity__c  = eachOrderItemConSch.SBQQ__OrderItem__r.blng__LegalEntity__c;
                PAD.log('SM012_OrderItemServices', 'legalEntityOnOrderItemConSch', 'setting legal entity on Order item ConSch '+eachOrderItemConSch.blng__LegalEntity__c);
                
                listOrderItemConSchtoSave.add(eachOrderItemConSch);
            }
        }
        if(listOrderItemConSchtoSave.size()>0){
            update listOrderItemConSchtoSave;
        }
    }
    
/*
*   @description : this method set the right invoces dates on orde items.
*   @param List<OrderItem> newOrderItems to process
*   @returns void
*/
    public static void setupInvoiceDates(List<OrderItem> newOrderItems) {
        PAD.log('SM012_OrderItemServices', 'setupInvoiceDates', 'newOrderItems: ' + newOrderItems.size());
        if (newOrderItems != null) {

            Id accountEntrepriseRTId = EM003_RecordTypeEntity.getRecTypeIdByObjectAndName(Label.LPCR_Account, Label.LPCR_Entreprise);
            Id accountFamilleRTId = EM003_RecordTypeEntity.getRecTypeIdByObjectAndName(Label.LPCR_Account, Label.LPCR_Famille);
            
            // Load Contract Type Conf
            Map<String, LPCR_TypeContrat__mdt> mapTypeContractConf = new Map<String, LPCR_TypeContrat__mdt> ();

            for (LPCR_TypeContrat__mdt typeContractConf : [SELECT Id, DeveloperName, LPCR_JourFacturation__c FROM LPCR_TypeContrat__mdt]) {
                mapTypeContractConf.put(typeContractConf.DeveloperName, typeContractConf);
            }
            
            Integer macInvoicingDay = Integer.valueOf(mapTypeContractConf.get('B2C_MAC').LPCR_JourFacturation__c);
            Integer microInvoicingDay = Integer.valueOf(mapTypeContractConf.get('B2C_MICRO').LPCR_JourFacturation__c);
            Integer invoiceDelta = -1 * Integer.valueOf(mapTypeContractConf.get('B2B').LPCR_JourFacturation__c);
            
            Set<Id> orderIds = new Set<Id>();

            //Load their orders
            for (OrderItem item : newOrderItems) {
                orderIds.add(item.OrderId);
            }
            
            Map<Id, Order> orderMap = new Map<Id, Order> ([SELECT Id,RecordTypeId,LPCR_TypeFacturation__c ,LPCR_FrequenceFacturation__c ,LPCR_InitAutoAvecDateDebut__c , 
                                                            LPCR_TypeCreche__c, blng__BillingAccount__c, blng__BillingAccount__r.RecordTypeId 
                                                           FROM Order WHERE Id IN :orderIds]);
            
            Set<Id> orderItemIds = new Set<Id>();

            for (OrderItem item : newOrderItems) {
                orderItemIds.add(item.SBQQ__RequiredBy__c);
            }

            Map<Id, OrderItem> orderItemMap = new Map<Id, OrderItem> ([SELECT Id,SBQQ__RequiredBy__c,blng__NextBillingDate__c FROM OrderItem WHERE Id IN :orderItemIds ]);
            Id rtReferencementId = EM003_RecordTypeEntity.getRecTypeIdByObjectAndName(Label.LPCR_Order, Label.LPCR_Referencement);
            Integer currentYr;
            for (OrderItem item : newOrderItems) {
                
                if (item.blng__NextChargeDate__c != null) {
                    
                    if(orderMap.get(item.OrderId).blng__BillingAccount__c != null && orderMap.get(item.OrderId).blng__BillingAccount__r.RecordTypeId == accountFamilleRTId && item.ServiceDate != null) {
                        
                        Integer orderItemStartDay = item.ServiceDate.day();
                        Integer invoiceDay = (orderMap.get(item.OrderId).LPCR_TypeCreche__c == 'MAC')
                            ? macInvoicingDay
                            : microInvoicingDay;
                        Date lastDayOfMonth = UM005_DateUtility.lastDateOfMonth(item.blng__NextChargeDate__c);
                        PAD.log('SM012_OrderItemServices', 'setupInvoiceDates', 'item (BEFORE): ' + item);
                        PAD.log('SM012_OrderItemServices', 'setupInvoiceDates', 'invoiceDay: ' + invoiceDay);
                        
                        if(item.SBQQ__ChargeType__c == Label.LPCR_OneTime ){
                            if(orderMap.get(item.OrderId).LPCR_TypeFacturation__c  == Label.LPCR_Advance){
                                item.blng__OverrideNextBillingDate__c = item.blng__NextChargeDate__c.toStartOfMonth();
                            }
                            else if(orderMap.get(item.OrderId).LPCR_TypeFacturation__c  == Label.LPCR_Arrears){
                                item.blng__OverrideNextBillingDate__c = lastdayofmonth.addDays(1);
                            }
                        }
                        else if(item.Quantity > 0 && (item.SBQQ__TerminatedDate__c == null || (item.SBQQ__TerminatedDate__c != null && lastdayofmonth < item.SBQQ__TerminatedDate__c))){
                            item.blng__BillThroughDateOverride__c = lastdayofmonth;
                        }
                        
                    } 
                    // All Frequency but Invoice Plan
                    else if(   (
                                    orderMap.get(item.OrderId).blng__BillingAccount__c              != null
                                    && 
                                    orderMap.get(item.OrderId).blng__BillingAccount__r.RecordTypeId == accountEntrepriseRTId
                                )
                                && orderMap.get(item.OrderId).LPCR_FrequenceFacturation__c  != Label.LPCR_InvoicePlan 
                                && item.blng__NextChargeDate__c != null
                            ){

                            Date lastDayofQuarter = UM005_DateUtility.lastDayOfDatePeriod (item.blng__NextChargeDate__c, UM005_DateUtility.quarterlyMonths);
                            Date lastDayOfMonth = UM005_DateUtility.lastDateOfMonth(item.blng__NextChargeDate__c);
                            Date semiannualLastDay = UM005_DateUtility.lastDayOfDatePeriod (item.blng__NextChargeDate__c, UM005_DateUtility.semiannualMonths);
                            Date annualLastDay = UM005_DateUtility.lastDayOfYear(item.blng__NextChargeDate__c);
                            
                        //Advance
                        if( orderMap.get(item.OrderId).LPCR_TypeFacturation__c == Label.LPCR_Advance){
                            currentYr = item.ServiceDate.year();
                            Date nextBillingDate = item.blng__NextChargeDate__c.addDays(invoiceDelta);
                            item.blng__OverrideNextBillingDate__c = nextBillingDate;
                            
                            if (item.SBQQ__BillingFrequency__c == Label.LPCR_Quarterly ){
                                // lastDayOfQuarterPeriod return the last date of the given quarter (1,4,7,10)
                                if(item.Quantity > 0 && (item.SBQQ__TerminatedDate__c == null || (item.SBQQ__TerminatedDate__c != null && lastDayofQuarter < item.SBQQ__TerminatedDate__c))){
                                    item.blng__BillThroughDateOverride__c = lastDayofQuarter;
                                }
                            
                                //Populate Order Item > LPCR_DateArrondie__c
                                if(orderMap.get(item.OrderId).RecordTypeId == rtReferencementId){// only for orders rt=referencement

                                    if(item.ServiceDate >= Date.newInstance(currentYr, 01, 01) && item.ServiceDate <= Date.newInstance(currentYr, 03, 31)){         // (01/01 to 31/03)
                                        item.LPCR_DateArrondie__c = Date.newInstance(currentYr, 01, 01); //Give the 1st day of this period
                                    }
                                    else if(item.ServiceDate >= Date.newInstance(currentYr, 04, 01) && item.ServiceDate <= Date.newInstance(currentYr, 06, 30)){   // (01/04 to 30/06)
                                        item.LPCR_DateArrondie__c = Date.newInstance(currentYr, 04, 01); //Give the 1st day of this period
                                    }
                                    else if(item.ServiceDate >= Date.newInstance(currentYr, 07, 01) && item.ServiceDate <= Date.newInstance(currentYr, 09, 30)){   // (01/07 to 30/09)
                                        item.LPCR_DateArrondie__c = Date.newInstance(currentYr, 07, 01); //Give the 1st day of this period
                                    }
                                    else if(item.ServiceDate >= Date.newInstance(currentYr, 10, 01) && item.ServiceDate <= Date.newInstance(currentYr, 12, 31)){   // (01/10 to 31/12)
                                        item.LPCR_DateArrondie__c = Date.newInstance(currentYr, 10, 01); //Give the 1st day of this period
                                    }
                                }
                            }else if (item.SBQQ__BillingFrequency__c == Label.LPCR_Monthly){
                                
                                // lastDateOfMonth
                                if(item.Quantity > 0 && (item.SBQQ__TerminatedDate__c == null || (item.SBQQ__TerminatedDate__c != null && lastDayOfMonth < item.SBQQ__TerminatedDate__c))){
                                    item.blng__BillThroughDateOverride__c = lastDayOfMonth;
                                }
                                //Populate Order Item > LPCR_DateArrondie__c
                                if(orderMap.get(item.OrderId).RecordTypeId == rtReferencementId){// only for orders rt=referencement
                                    item.LPCR_DateArrondie__c = item.blng__NextBillingDate__c;
                                }

                            }else if (item.SBQQ__BillingFrequency__c == Label.LPCR_Semiannual ) {
                                // lastDayOfHalfYearPeriod return the last date of the given Half Year period (1,7)
                                if(item.Quantity > 0 && (item.SBQQ__TerminatedDate__c == null || (item.SBQQ__TerminatedDate__c != null && semiannualLastDay < item.SBQQ__TerminatedDate__c))){
                                    item.blng__BillThroughDateOverride__c = semiannualLastDay;
                                }
                                //Populate Order Item > LPCR_DateArrondie__c
                                if(orderMap.get(item.OrderId).RecordTypeId == rtReferencementId){// only for orders rt=referencement

                                    if(item.ServiceDate >= Date.newInstance(currentYr, 01, 01) && item.ServiceDate <= Date.newInstance(currentYr, 06, 30)){         // (01/01 to 31/03)
                                        item.LPCR_DateArrondie__c = Date.newInstance(currentYr, 01, 01); //Give the 1st day of this period
                                    }else if(item.ServiceDate >= Date.newInstance(currentYr, 07, 01) && item.ServiceDate <= Date.newInstance(currentYr, 12, 31)){   // (01/04 to 30/06)
                                        item.LPCR_DateArrondie__c = Date.newInstance(currentYr, 07, 01); //Give the 1st day of this period
                                    }
                                }

                            }else if(item.SBQQ__BillingFrequency__c == Label.LPCR_Annual  ) {
                                
                                if( item.Quantity > 0 
                                    && 
                                    (
                                        item.SBQQ__TerminatedDate__c == null 
                                        || 
                                        (item.SBQQ__TerminatedDate__c != null   &&      annualLastDay < item.SBQQ__TerminatedDate__c)
                                    ))
                                    {
                                        item.blng__BillThroughDateOverride__c = annualLastDay;
                                    }
                                 
                                //Populate Order Item > LPCR_DateArrondie__c
                                if(orderMap.get(item.OrderId).RecordTypeId == rtReferencementId){// only for orders rt=referencement
                                    if(item.ServiceDate >= Date.newInstance(currentYr, 01, 01) && item.ServiceDate <= Date.newInstance(currentYr, 12, 31)){// (01/Jan to 31/Dec)
                                        item.LPCR_DateArrondie__c = Date.newInstance(currentYr, 01, 01); //Give the 1st day of this period
                                    }
                                }
                            }
                        }
                        //Arrears
                        else if( orderMap.get(item.OrderId).LPCR_TypeFacturation__c == Label.LPCR_Arrears && !orderMap.get(item.OrderId).LPCR_InitAutoAvecDateDebut__c) {

                            if ((( item.SBQQ__BillingFrequency__c == Label.LPCR_Quarterly)
                                    || (item.SBQQ__ChargeType__c ==Label.LPCR_OneTime && orderMap.get(item.OrderId).LPCR_FrequenceFacturation__c == Label.LPCR_Quarterly))) {

                                item.blng__OverrideNextBillingDate__c = UM005_DateUtility.lastDayOfDatePeriod (item.blng__NextChargeDate__c, UM005_DateUtility.quarterlyMonths); // Workaround: Override Next Billing Date = Bill Through Date Override because of Billing package validation error
                                // lastDayOfQuarterPeriod return the last date of the given quarter (1,4,7,10)
                                
                                if(item.SBQQ__ChargeType__c !=Label.LPCR_OneTime){
                                    if(item.Quantity > 0 && (item.SBQQ__TerminatedDate__c == null || (item.SBQQ__TerminatedDate__c != null && lastDayofQuarter < item.SBQQ__TerminatedDate__c))){
                                        item.blng__BillThroughDateOverride__c = lastDayofQuarter;
                                    }
                                }
                            }
                            else if ( (item.SBQQ__BillingFrequency__c == Label.LPCR_Monthly )
                                    || (item.SBQQ__ChargeType__c ==Label.LPCR_OneTime && orderMap.get(item.OrderId).LPCR_FrequenceFacturation__c == Label.LPCR_Monthly)) {

                                // lastDateOfMonth
                                if(item.SBQQ__ChargeType__c !=Label.LPCR_OneTime){
                                    if(item.Quantity > 0 && (item.SBQQ__TerminatedDate__c == null || (item.SBQQ__TerminatedDate__c != null && lastDayOfMonth < item.SBQQ__TerminatedDate__c))){
                                        item.blng__BillThroughDateOverride__c = lastDayOfMonth;
                                    }
                                }

                                item.blng__OverrideNextBillingDate__c = item.SBQQ__ChargeType__c ==Label.LPCR_OneTime ? UM005_DateUtility.lastDateOfMonth(item.blng__NextChargeDate__c).addDays(1):null;
                            }
                            else if ((item.SBQQ__BillingFrequency__c == Label.LPCR_Semiannual)||
                                    (item.SBQQ__ChargeType__c ==Label.LPCR_OneTime
                                        && orderMap.get(item.OrderId).LPCR_FrequenceFacturation__c == Label.LPCR_Semiannual) ) {

                                item.blng__OverrideNextBillingDate__c =UM005_DateUtility.lastDayOfDatePeriod (item.blng__NextChargeDate__c, UM005_DateUtility.semiannualMonths); // Workaround: Override Next Billing Date = Bill Through Date Override because of Billing package validation error
                                // lastDayOfHalfYearPeriod return the last date of the given Half Year period (1,7)
                                
                                if(item.SBQQ__ChargeType__c !=Label.LPCR_OneTime){
                                    if(item.Quantity > 0 && (item.SBQQ__TerminatedDate__c == null || (item.SBQQ__TerminatedDate__c != null && semiannualLastDay < item.SBQQ__TerminatedDate__c))){
                                        item.blng__BillThroughDateOverride__c = semiannualLastDay;
                                    }
                                }
                            }
                            else if ((item.SBQQ__BillingFrequency__c == Label.LPCR_Annual )
                                    || (item.SBQQ__ChargeType__c ==Label.LPCR_OneTime && orderMap.get(item.OrderId).LPCR_FrequenceFacturation__c == Label.LPCR_Annual)) {

                                item.blng__OverrideNextBillingDate__c = UM005_DateUtility.lastDayOfYear(item.blng__NextChargeDate__c); // Workaround: Override Next Billing Date = Bill Through Date Override because of Billing package validation error
                                if(item.SBQQ__ChargeType__c !=Label.LPCR_OneTime){
                                    if(item.Quantity > 0 && (item.SBQQ__TerminatedDate__c == null || (item.SBQQ__TerminatedDate__c != null && annualLastDay < item.SBQQ__TerminatedDate__c))){
                                        item.blng__BillThroughDateOverride__c = annualLastDay;
                                    }
                                }
                            }
                        }
                    }
                       
                    if((item.blng__BillThroughDateOverride__c != null) && item.EndDate < item.blng__BillThroughDateOverride__c){
                        item.blng__BillThroughDateOverride__c = item.EndDate;
                    }
                    PAD.log('SM012_OrderItemServices', 'setupInvoiceDates', 'item (AFTER): ' + item);
                }
            }
        }
    }
    
    public static void setInvoiceGrouping(List<OrderItem> newOrderItem){

        Set<string> productIdSet = new Set<string>();
        for(OrderItem orderitem: newOrderItem){
            productIdSet.add(orderitem.product2Id);
        }
        Map<Id, product2> ProductMap = new Map<Id,product2>([select id, productcode from product2 where id in : productIdSet]);
        for(OrderItem eachOrderItem : newOrderItem){ 
            
            if(ProductMap.get(eachOrderItem.Product2Id).productCode == Label.Product_Code_Depot_Garantie ){
                eachOrderItem.blng__InvoiceGrouping__c = Label.InvoiceGrouping_SeperateInvoice;
            }
        }
    }
    
    
    public static void setInvoiceGroupingOnOrderItem(Map<Id,OrderItem> mapOrderItem){

        Id recordTypeId = EM003_RecordTypeEntity.getRecTypeIdByObjectAndName(Label.LPCR_Quote, 'Referencement');
        List<OrderItem> listOrderItem = [SELECT Id, LPCR_NumeroPurchaseOrder__c, Order.SBQQ__Quote__r.RecordTypeId, blng__InvoiceGrouping__c, blng__InvoiceGroupId__c FROM OrderItem WHERE ID in :mapOrderItem.keySet() AND Order.SBQQ__Quote__r.RecordTypeId =: recordTypeId];
        List<OrderItem> listOrderItemtoSave = new List<OrderItem>();
        for(OrderItem eachOrderItem : listOrderItem){
            eachOrderItem.blng__InvoiceGrouping__c = 'Invoice Group ID';
            if(String.isNotBlank(eachOrderItem.LPCR_NumeroPurchaseOrder__c)){
                eachOrderItem.blng__InvoiceGroupId__c = eachOrderItem.LPCR_NumeroPurchaseOrder__c;
                PAD.log('SM012_OrderItemServices' , 'setInvoiceGroupingOnOrderItem', 'invoice group id update on OrderItem '+eachOrderItem.blng__InvoiceGroupId__c);
            }
            listOrderItemtoSave.add(eachOrderItem);
        }
        if(listOrderItemtoSave.size()>0){
            update listOrderItemtoSave;
        }
    }
    
    //added by saurabh
    public static void setOrderItemFieldsFromContract(List<OrderItem> newOrderItemsList){

        Set<String> contractId = UM003_TypeManager.getFieldsOfListObjects(newOrderItemsList,'SBQQ__Contract__c');
        Map<Id, Contract> contractMap = new Map<Id, Contract>([SELECT Id, LPCR_DateDebut__c, LPCR_DateFin__c, SBQQ__RenewalUpliftRate__c FROM Contract WHERE Id IN: contractId]);
        
        for(OrderItem eachOrderItem : newOrderItemsList){
            if(eachOrderItem.SBQQ__Contract__c != null){
                eachOrderItem.LPCR_ContractStartDate__c = contractMap.get(eachOrderItem.SBQQ__Contract__c).LPCR_DateDebut__c;
                eachOrderItem.LPCR_ContractEndDate__c = contractMap.get(eachOrderItem.SBQQ__Contract__c).LPCR_DateFin__c;
                eachOrderItem.LPCR_Uplift__c = contractMap.get(eachOrderItem.SBQQ__Contract__c).SBQQ__RenewalUpliftRate__c;
            }
        }
    }
    
    
/*
* @author : Ayoub Ouarti
*   @description : this method set orderItem's blng__BillingRule__c 
*   @param List<OrderItem> newOrderItemsList
*   @returns void
*/
    public static void setOrderItemFields(List<OrderItem> newOrderItemsList){

        Set<String> orderIds = UM003_TypeManager.getFieldsOfListObjects(newOrderItemsList,'OrderId');        
        Map<Id, Order> ordersMap = new Map<Id, Order>([SELECT Id, LPCR_NouveauPlanFacture__c,LPCR_RenouvellementPlanFacture__c,  SBQQ__Quote__r.SBQQ__Type__c, accountId FROM Order WHERE Id IN :orderIds]);
        Map<String,SObject> mapSobject = null;
        Set<String> nouveauPlanFactureIds = UM003_TypeManager.getFieldsOfListObjects(ordersMap.values(),'LPCR_NouveauPlanFacture__c');
        Set<String> renouvellementPlanFactureIds = UM003_TypeManager.getFieldsOfListObjects(ordersMap.values(),'LPCR_RenouvellementPlanFacture__c');
        
        List<blng__BillingTreatment__c> billingTreatmentsForQuote =  [select blng__BillingRule__c ,blng__InvoicePlan__c from blng__BillingTreatment__c where blng__InvoicePlan__c IN :nouveauPlanFactureIds];
        List<blng__BillingTreatment__c> billingTreatmentsForRenewal =  [select blng__BillingRule__c ,blng__InvoicePlan__c from blng__BillingTreatment__c where blng__InvoicePlan__c IN :renouvellementPlanFactureIds];
        
        Map<String,blng__BillingTreatment__c> mapBillingTreatmentWithInvoicePlanQuote = new Map<String,blng__BillingTreatment__c>() ;
        mapSobject = UM003_TypeManager.generateMapOfObjectsByKeyField(billingTreatmentsForQuote,'blng__InvoicePlan__c');
        for(String eachkey : mapSobject.keyset()){
            mapBillingTreatmentWithInvoicePlanQuote.put(eachkey,(blng__BillingTreatment__c)mapSobject.get(eachkey));
        }
        
        Map<String,blng__BillingTreatment__c> mapBillingTreatmentWithInvoicePlanRenewal = new  Map<String,blng__BillingTreatment__c>();
        mapSobject = UM003_TypeManager.generateMapOfObjectsByKeyField(billingTreatmentsForRenewal,'blng__InvoicePlan__c');
        for(String eachkey : mapSobject.keyset()){
            mapBillingTreatmentWithInvoicePlanRenewal.put(eachkey,(blng__BillingTreatment__c)mapSobject.get(eachkey));
        }
        

        //Lets jump from a map of (orderId,AccID) to a map of (orderId,AccountObj). This is in order to limit the queries into the database into just one
            //STEP 1 : MAP ( Order ID , AccID )
        Map<Id,Id> orderIdAccountId= new Map<Id, Id>();
        for(Order o : ordersMap.values()){
            orderIdAccountId.put(o.Id,o.accountId);
        }
            //STEP 2 : MAP (AccID , Account )
        Map<Id, Account> IdAccounts = new Map<Id, Account>([SELECT Id, LPCR_PurchaseOrder__c from account where id in :orderIdAccountId.values()]);
            //STEP 3 : Map of ( orderID , Account)
        Map<Id,Account> orderIdAccounts= new Map<Id, Account>();
        for(Id OrderId : orderIdAccountId.keyset()){
            orderIdAccounts.put(OrderId,     IdAccounts.get(OrderId)       );
        }
        //

        for(OrderItem eachOrderItem : newOrderItemsList){
            //Let's use my last map to give an itemOrderId and return me my LPCR_PurchaseOrder__c on the account :
            if(orderIdAccountId.get(eachOrderItem.OrderId) != null){// check ID account exist for this product's order
                if(IdAccounts.get(orderIdAccountId.get(eachOrderItem.OrderId)) != null){// check account is not null
                    eachOrderItem.LPCR_CompteAvecPO__c = IdAccounts.get(orderIdAccountId.get(eachOrderItem.OrderId)).LPCR_PurchaseOrder__c;
                }
            }
            //
            if('Quote'.equals(ordersMap.get(eachOrderItem.OrderId).SBQQ__Quote__r.SBQQ__Type__c )){
                if(mapBillingTreatmentWithInvoicePlanQuote.containsKey(ordersMap.get(eachOrderItem.OrderId).LPCR_NouveauPlanFacture__c)){
                    eachOrderItem.blng__BillingRule__c  = mapBillingTreatmentWithInvoicePlanQuote.get(ordersMap.get(eachOrderItem.OrderId).LPCR_NouveauPlanFacture__c).blng__BillingRule__c;
                }
            }else if('Renewal'.equals(ordersMap.get(eachOrderItem.OrderId).SBQQ__Quote__r.SBQQ__Type__c )){
                if(mapBillingTreatmentWithInvoicePlanRenewal.containsKey(ordersMap.get(eachOrderItem.OrderId).LPCR_RenouvellementPlanFacture__c)){
                    eachOrderItem.blng__BillingRule__c  = mapBillingTreatmentWithInvoicePlanRenewal.get(ordersMap.get(eachOrderItem.OrderId).LPCR_RenouvellementPlanFacture__c).blng__BillingRule__c;
                }  
            }
            
        }
    }
    
    public static void updateHoldBillingFromQuote(List<OrderItem> newOrderItemsList, Map<Id,OrderItem> oldMapOrderItem,Map<Id,OrderItem> newMapOrderItem){

        Set<String> quoteLineIds = UM003_TypeManager.getFieldsOfListObjects(newOrderItemsList,'SBQQ__QuoteLine__c');
        map<id,string> mapQuoteLine = new map<Id,String>();
        List<OrderItem> listOrderItem = [SELECT Id,SBQQ__Status__c,SBQQ__QuoteLine__c, SBQQ__QuoteLine__r.LPCR_HoldBilling__c FROM OrderItem WHERE ID in :newMapOrderItem.keyset()];
        for(SBQQ__QuoteLine__c quoteLine: [Select id,LPCR_HoldBilling__c from SBQQ__QuoteLine__c where id in: quoteLineIds]){
            mapQuoteLine.put(quoteLine.id, quoteLine.LPCR_HoldBilling__c);
        }
        
        for(OrderItem eachNewOrderItem : newMapOrderItem.values()){
            
            if('Activated'.equals(eachNewOrderItem.SBQQ__Status__c) && oldMapOrderItem.get(eachNewOrderItem.Id).SBQQ__Status__c != eachNewOrderItem.SBQQ__Status__c 
               && mapQuoteLine.containsKey(eachNewOrderItem.SBQQ__QuoteLine__c) && mapQuoteLine.get(eachNewOrderItem.SBQQ__QuoteLine__c) == 'Yes'){
                   eachNewOrderItem.blng__HoldBilling__c = mapQuoteLine.get(eachNewOrderItem.SBQQ__QuoteLine__c);
               }
        }
    }
    
    
    
/*
* @author : Ayoub Ouarti
*   @description : this method update Billing transaction for RevisedOrderProduct on orderItem
*   @param List<OrderItem> newOrderItemsList
*   @returns void
*/
    public static void updateFiledsOnBillingTransaction(Map<Id,OrderItem> oldMapOrderItem,Map<Id,OrderItem> newMapOrderItem){

        Set<Id> orderItemIds=new Set<Id>();
        Id accountEntrepriseRTId = EM003_RecordTypeEntity.getRecTypeIdByObjectAndName(Label.LPCR_Account, Label.LPCR_Entreprise);

        for(OrderItem eachNewOrderItem : newMapOrderItem.values()){
            if('Activated'.equals(eachNewOrderItem.SBQQ__Status__c) && oldMapOrderItem.get(eachNewOrderItem.Id).SBQQ__Status__c != eachNewOrderItem.SBQQ__Status__c){
                orderItemIds.add(eachNewOrderItem.Id);                
            }
        }

        if(orderItemIds.size()>0){
            Map<Id,OrderItem> mapOrderItems = new Map<Id,OrderItem>([SELECT Id,SBQQ__BillingFrequency__c,SBQQ__RevisedOrderProduct__c,ServiceDate
                                                                     FROM OrderItem 
                                                                     WHERE Order.blng__BillingAccount__r.RecordTypeId = :accountEntrepriseRTId
                                                                     AND SBQQ__BillingFrequency__c = 'Invoice Plan' 
                                                                     AND orderItem.Quantity < 0
                                                                     AND Id IN :orderItemIds]);
            
            Map<String,OrderItem> mapOrderItemsWithSBQQRevisedOP = new Map<String,OrderItem>();
            
            Map<String,SObject> mapSobject = UM003_TypeManager.generateMapOfObjectsByKeyField(mapOrderItems.values(),'SBQQ__RevisedOrderProduct__c');
            for(String eachkey : mapSobject.keyset()){
                mapOrderItemsWithSBQQRevisedOP.put(eachkey,(OrderItem)mapSobject.get(eachkey));
            }
            
            Set<String> revisedOrderItemIds = UM003_TypeManager.getFieldsOfListObjects(mapOrderItems.values(),'SBQQ__RevisedOrderProduct__c');
            Map<Id,blng__BillingSchedule__c> mapBillingSchedule = new Map<Id,blng__BillingSchedule__c> ([ SELECT id ,blng__OrderProduct__c FROM blng__BillingSchedule__c WHERE blng__OrderProduct__c IN :revisedOrderItemIds]);   

            if(UM003_TypeManager.isNotNullAndNotEmpty(mapBillingSchedule.values())){

                List<blng__BillingTransaction__c> listBT = [SELECT id,blng__OverrideBillingTargetDate__c,blng__BillingSchedule__c, blng__ServicePeriodEnd__c, blng__ServicePeriodStart__c FROM blng__BillingTransaction__c
                                                            WHERE blng__BillingSchedule__c IN :mapBillingSchedule.keySet()]; 

                if(UM003_TypeManager.isNotNullAndNotEmpty(listBT)){

                    for(blng__BillingTransaction__c eachBT : listBT){

                        if(mapBillingSchedule.containsKey(eachBT.blng__BillingSchedule__c) &&
                           mapOrderItemsWithSBQQRevisedOP.containsKey(mapBillingSchedule.get(eachBT.blng__BillingSchedule__c).blng__OrderProduct__c)){
                               
                               eachBT.blng__OverrideBillingTargetDate__c = mapOrderItemsWithSBQQRevisedOP.get(mapBillingSchedule.get(eachBT.blng__BillingSchedule__c).blng__OrderProduct__c).ServiceDate ;   
                               eachBT.blng__ServicePeriodStart__c = mapOrderItemsWithSBQQRevisedOP.get(mapBillingSchedule.get(eachBT.blng__BillingSchedule__c).blng__OrderProduct__c).ServiceDate;   
                               eachBT.blng__ServicePeriodEnd__c = mapOrderItemsWithSBQQRevisedOP.get(mapBillingSchedule.get(eachBT.blng__BillingSchedule__c).blng__OrderProduct__c).ServiceDate;  
                           }
                    }  
                    update listBT;
                }
                
            }   
        }
    }
    /*
    *   @author : Achraf ABOUL
    *   @description : this method updates blng__OverrideNextBillingDate__c of children orderitems
    *   @param List<OrderItem> newOrderItemsList
    *   @returns void
    */
    public static void updateRelatedOrderItems(Map<Id,OrderItem> oldMapOrderItem,Map<Id,OrderItem> newMapOrderItem){
        //Ids of order which repect the later conditions
        Set<Id> orderItemsIds = new Set<Id>();
        //Parnet orders Ids set
        Set<String> orderIds = UM003_TypeManager.getFieldsOfListObjects(newMapOrderItem.values(),'OrderId');

        //Entreprise account record type
        Id accountEntrepriseRTId = EM003_RecordTypeEntity.getRecTypeIdByObjectAndName(Label.LPCR_Account, Label.LPCR_Entreprise);
        //Map containing parent orders: (Order Id => Order)
        Map<Id, Order> ordersMap = new Map<Id, Order>([SELECT Id, blng__BillingAccount__c,blng__BillingAccount__r.RecordTypeId, LPCR_FrequenceFacturation__c
                                                        FROM Order 
                                                        WHERE Id IN :orderIds]);

        OrderItem currentOldOrderItem;
        Order currentOrder;
        //For every new order item check for conditions
        for(OrderItem eachNewOrderItem : newMapOrderItem.values()){
            currentOldOrderItem = oldMapOrderItem.get(eachNewOrderItem.Id);
            currentOrder = ordersMap.get(currentOldOrderItem.OrderId);
            if( eachNewOrderItem.blng__NextBillingDate__c != currentOldOrderItem.blng__NextBillingDate__c
                && currentOrder.blng__BillingAccount__c != null
                && currentOrder.blng__BillingAccount__r.RecordTypeId == accountEntrepriseRTId
                && currentOrder.LPCR_FrequenceFacturation__c == Label.LPCR_InvoicePlan){
                    //Add OrderItems ids respecting conditions
                    orderItemsIds.add(eachNewOrderItem.Id);
                }
        }
        //Query for the children related Order Items
        List<OrderItem> relatedOrderItems = [ SELECT Id, blng__OverrideNextBillingDate__c, SBQQ__RequiredBy__r.blng__NextBillingDate__c,
                                                        SBQQ__ChargeType__c, blng__NextChargeDate__c   
                                                FROM OrderItem WHERE SBQQ__RequiredBy__c IN :orderItemsIds ];

        List<OrderItem> relatedOneTimeOrderItems = new List<OrderItem>();   

        for(Orderitem eachOrderItem : relatedOrderItems){

            // populate only for one time products where blng_NextChargeDate_c not blank
            if(eachOrderItem.SBQQ__ChargeType__c == Label.LPCR_OneTime && eachOrderItem.blng__NextChargeDate__c != null) {           

                //For every related order item : Update its next billing date                 
                eachOrderItem.blng__OverrideNextBillingDate__c = eachOrderItem.SBQQ__RequiredBy__r.blng__NextBillingDate__c;                 
                relatedOneTimeOrderItems.add(eachOrderItem);             
            }
        }

        if(relatedOneTimeOrderItems.size() > 0){
            update relatedOneTimeOrderItems;
        }
    }
}