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
    public void execute(QueueableContext context) {
        SM012_OrderItemServices.setLegalEntityOnOrderItem(this.listOrderItem);
    }
    
    // DCO Is there any specific reasons to run this aynch on AfterUpdate?
    public static void setLegalEntityOnOrderItem(List<OrderItem> newOrderItem){
        Set<Id> orderItemId = UM003_TypeManager.getIdsOfListObjects(newOrderItem);
        List<OrderItem> listOrderItem = [SELECT Id,blng__LegalEntity__c, SBQQ__QuoteLine__r.LPCR_EntiteJuridique__c	 FROM OrderItem WHERE ID in :orderItemId];
        //Boolean updateOrderItem = false;
        for(OrderItem eachOrderItem : listOrderItem){
            if(eachOrderItem.blng__LegalEntity__c ==null){
                //        updateOrderItem = true;
                eachOrderItem.blng__LegalEntity__c = eachOrderItem.SBQQ__QuoteLine__r.LPCR_EntiteJuridique__c;
                PAD.log('SM012_OrderItemServices', 'setLegalEntityOnOrderItem' , 'setting legal entity on Order item ' +eachOrderItem.blng__LegalEntity__c);
            }
        }
        //if (updateOrderItem) {
        update listOrderItem;
        //}
    }
    
    public static void legalEntityOnOrderItemConSch( Map<Id,OrderItem> mapOrderItem){
        List<SBQQ__OrderItemConsumptionSchedule__c> listOrderItemConSch = [SELECT SBQQ__OrderItem__c,SBQQ__OrderItem__r.blng__LegalEntity__c,blng__LegalEntity__c  FROM SBQQ__OrderItemConsumptionSchedule__c WHERE SBQQ__OrderItem__c in :mapOrderItem.keySet() ];
        List<SBQQ__OrderItemConsumptionSchedule__c> listOrderItemConSchtoSave = new List<SBQQ__OrderItemConsumptionSchedule__c>();
        for(SBQQ__OrderItemConsumptionSchedule__c eachOrderItemConSch : listOrderItemConSch){
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
*	@description : this method set the right invoces dates on orde items.
*	@param List<OrderItem> newOrderItems to process
*	@returns void
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
            
            Integer macInvoicingDay = mapTypeContractConf.containsKey('B2C_MAC')
                ? Integer.valueOf(mapTypeContractConf.get('B2C_MAC').LPCR_JourFacturation__c)
                : 5;
            
            Integer microInvoicingDay = mapTypeContractConf.containsKey('B2C_MICRO')
                ? Integer.valueOf(mapTypeContractConf.get('B2C_MICRO').LPCR_JourFacturation__c)
                : 27;
            
            Integer invoiceDelta = mapTypeContractConf.containsKey('B2B')
                ? -1 * Integer.valueOf(mapTypeContractConf.get('B2B').LPCR_JourFacturation__c)
                : -35;
            
            Set<Id> orderIds = new Set<Id>();
            for (OrderItem item : newOrderItems) {
                orderIds.add(item.OrderId);
            }
            
            Map<Id, Order> orderMap = new Map<Id, Order> ([SELECT Id,LPCR_TypeFacturation__c ,LPCR_FrequenceFacturation__c ,LPCR_InitAutoAvecDateDebut__c , LPCR_TypeCreche__c, blng__BillingAccount__c, blng__BillingAccount__r.RecordTypeId 
                                                           FROM Order WHERE Id IN :orderIds]);
            
            for (OrderItem item : newOrderItems) {
                if (item.blng__NextChargeDate__c != null) {
                    if(orderMap.get(item.OrderId).blng__BillingAccount__c != null && orderMap.get(item.OrderId).blng__BillingAccount__r.RecordTypeId == accountFamilleRTId && item.ServiceDate != null) {
                        Integer orderItemStartDay = item.ServiceDate.day();
                        Integer invoiceDay = (orderMap.get(item.OrderId).LPCR_TypeCreche__c == 'MAC')
                            ? macInvoicingDay
                            : microInvoicingDay;
                        
                        PAD.log('SM012_OrderItemServices', 'setupInvoiceDates', 'item (BEFORE): ' + item);
                        PAD.log('SM012_OrderItemServices', 'setupInvoiceDates', 'invoiceDay: ' + invoiceDay);
                        
                        if(item.SBQQ__BillingType__c == 'Advance') {
                            if(item.ServiceDate == item.blng__NextChargeDate__c) { 
                                //update original record to make because of beforeUpdate event
                                if(orderMap.get(item.OrderId).LPCR_TypeCreche__c == 'MICRO' ) {
                                    
                                    if(orderItemStartDay > invoiceDay){
                                        
                                        item.blng__OverrideNextBillingDate__c =  UM005_DateUtility.setDayOnDate(invoiceDay, item.blng__NextChargeDate__c.addMonths(1));
                                    }else{
                                        // added code from IS-1064 
                                        if( item.Order.Type==null || item.Order.Type =='New'){
                                            item.blng__OverrideNextBillingDate__c = UM005_DateUtility.setDayOnDate(invoiceDay, item.blng__NextChargeDate__c);
                                            item.blng__BillThroughDateOverride__c = UM005_DateUtility.setDayOnDate(invoiceDay, item.blng__OverrideNextBillingDate__c.addMonths(1));
                                        } 
                                        else if( item.Order.Type =='Renewal'){
                                            item.blng__OverrideNextBillingDate__c =  UM005_DateUtility.setDayOnDate(invoiceDay ,item.blng__NextChargeDate__c.addMonths(-1));
                                        }
                                    }
                                }
                                //Macro
                                else{
                                    item.blng__OverrideNextBillingDate__c = (orderItemStartDay > invoiceDay)
                                        ? UM005_DateUtility.setDayOnDate (invoiceDay, item.blng__NextChargeDate__c.addMonths(1))
                                        : UM005_DateUtility.setDayOnDate (invoiceDay, item.blng__NextChargeDate__c);
                                    
                                }
                            } else if(item.ServiceDate != item.blng__NextChargeDate__c) {
                                item.blng__OverrideNextBillingDate__c = (orderMap.get(item.OrderId).LPCR_TypeCreche__c == 'MAC')
                                    ? UM005_DateUtility.setDayOnDate (invoiceDay, item.blng__NextChargeDate__c)
                                    : UM005_DateUtility.setDayOnDate (invoiceDay, item.blng__NextChargeDate__c.addMonths(-1));
                            }
                        } else if(item.SBQQ__BillingType__c == 'Arrears') {
                            item.blng__OverrideNextBillingDate__c = orderMap.get(item.OrderId).LPCR_TypeCreche__c == 'MAC' 
                                || (orderMap.get(item.OrderId).LPCR_TypeCreche__c == 'MICRO' && item.ServiceDate == item.blng__NextChargeDate__c && orderItemStartDay > invoiceDay)
                                ? UM005_DateUtility.setDayOnDate (invoiceDay, item.blng__NextChargeDate__c.addMonths(1))
                                : UM005_DateUtility.setDayOnDate (invoiceDay, item.blng__NextChargeDate__c);
                            
                            if (orderMap.get(item.OrderId).LPCR_TypeCreche__c == 'MICRO' && item.ServiceDate == item.blng__NextChargeDate__c) {
                                // added code from IS-1074, change blng__NextChargeDate__c by blng__OverrideNextBillingDate__c
                                item.blng__BillThroughDateOverride__c = UM005_DateUtility.lastDateOfMonth (item.blng__OverrideNextBillingDate__c);
                            }
                        }
                    } else if ((orderMap.get(item.OrderId).blng__BillingAccount__c != null 
                                && orderMap.get(item.OrderId).blng__BillingAccount__r.RecordTypeId == accountEntrepriseRTId)
                               && item.SBQQ__BillingFrequency__c  != 'Invoice Plan' 
                               && !orderMap.get(item.OrderId).LPCR_InitAutoAvecDateDebut__c  
                               && item.blng__NextChargeDate__c != null) {
                                   //Advance
                                   if( orderMap.get(item.OrderId).LPCR_TypeFacturation__c  == 'Advance'){
                                       Date nextBillingDate = item.blng__NextChargeDate__c.addDays(invoiceDelta);
                                       item.blng__OverrideNextBillingDate__c = nextBillingDate;
                                       
                                       if (item.SBQQ__BillingFrequency__c == 'Quarterly' 
                                           && ((UM005_DateUtility.quarterlyMonths.contains(item.blng__NextChargeDate__c.month()) 
                                                && item.blng__NextChargeDate__c.day() != 1) 
                                               || !UM005_DateUtility.quarterlyMonths.contains(item.blng__NextChargeDate__c.month()) )){ 
                                                   // lastDayOfQuarterPeriod return the last date of the given quarter (1,4,7,10) 
                                                   item.blng__BillThroughDateOverride__c = UM005_DateUtility.lastDayOfDatePeriod (item.blng__NextChargeDate__c, UM005_DateUtility.quarterlyMonths); 
                                               }else if (item.SBQQ__BillingFrequency__c == 'Monthly' 
                                                         && item.blng__NextChargeDate__c.day() != 1 ){
                                                             // lastDateOfMonth
                                                             item.blng__BillThroughDateOverride__c =  UM005_DateUtility.lastDateOfMonth(item.blng__NextChargeDate__c);
                                                         }else  if (item.SBQQ__BillingFrequency__c == 'Semiannual' 
                                                                    && ((UM005_DateUtility.semiannualMonths.contains(item.blng__NextChargeDate__c.month()) 
                                                                         && item.blng__NextChargeDate__c.day() != 1) 
                                                                        || !UM005_DateUtility.semiannualMonths.contains(item.blng__NextChargeDate__c.month()))) {
                                                                            // lastDayOfHalfYearPeriod return the last date of the given Half Year period (1,7) 
                                                                            item.blng__BillThroughDateOverride__c = UM005_DateUtility.lastDayOfDatePeriod(item.blng__NextChargeDate__c,UM005_DateUtility.semiannualMonths); 
                                                                        }
                                   }
                                   //Arrears 
                                   else if(  orderMap.get(item.OrderId).LPCR_TypeFacturation__c  == 'Arrears'){
                                       PAD.log('SM012_OrderItemServices','setupInvoiceDates','$$$$$$$ item.SBQQ__BillingFrequency__c '+item.SBQQ__BillingFrequency__c);
                                       if ( (item.SBQQ__BillingFrequency__c == 'Quarterly' || (item.SBQQ__ChargeType__c =='One-Time' && orderMap.get(item.OrderId).LPCR_FrequenceFacturation__c == 'Quarterly') )
                                           && ((UM005_DateUtility.quarterlyMonths.contains(item.blng__NextChargeDate__c.month()) 
                                                && item.blng__NextChargeDate__c.day() != 1) 
                                               || !UM005_DateUtility.quarterlyMonths.contains(item.blng__NextChargeDate__c.month()) )) {
                                                   item.blng__OverrideNextBillingDate__c = UM005_DateUtility.lastDayOfDatePeriod (item.blng__NextChargeDate__c, UM005_DateUtility.quarterlyMonths).addDays(1);
                                                   // lastDayOfQuarterPeriod return the last date of the given quarter (1,4,7,10) 
                                                   item.blng__BillThroughDateOverride__c =item.SBQQ__ChargeType__c !='One-Time' ? UM005_DateUtility.lastDayOfDatePeriod (item.blng__NextChargeDate__c, UM005_DateUtility.quarterlyMonths):null; 
                                               }
                                       else if (item.SBQQ__BillingFrequency__c == 'Monthly' && item.blng__NextChargeDate__c.day() != 1 ){
                                           // lastDateOfMonth
                                           item.blng__BillThroughDateOverride__c = item.SBQQ__ChargeType__c !='One-Time' ? UM005_DateUtility.lastDateOfMonth(item.blng__NextChargeDate__c):null;
                                           item.blng__OverrideNextBillingDate__c = item.SBQQ__ChargeType__c =='One-Time'? UM005_DateUtility.lastDateOfMonth(item.blng__NextChargeDate__c).addDays(1):null;
                                       }
                                       
                                       else  if ((item.SBQQ__BillingFrequency__c == 'Semiannual' || (item.SBQQ__ChargeType__c =='One-Time' && orderMap.get(item.OrderId).LPCR_FrequenceFacturation__c == 'Semiannual') ) 
                                                 && (!UM005_DateUtility.semiannualMonths.contains(item.blng__NextChargeDate__c.month()) 
                                                     || item.blng__NextChargeDate__c.day() != 1)){ 
                                                         item.blng__OverrideNextBillingDate__c =UM005_DateUtility.lastDayOfDatePeriod (item.blng__NextChargeDate__c, UM005_DateUtility.semiannualMonths).addDays(1); 
                                                         // lastDayOfHalfYearPeriod return the last date of the given Half Year period (1,7) 
                                                         item.blng__BillThroughDateOverride__c =item.SBQQ__ChargeType__c !='One-Time' ? UM005_DateUtility.lastDayOfDatePeriod (item.blng__NextChargeDate__c, UM005_DateUtility.semiannualMonths):null; 
                                                     }
                                   }
                               }
                }
                PAD.log('SM012_OrderItemServices', 'setupInvoiceDates', 'item (AFTER): ' + item);
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
        //Id recordTypeId = UM003_TypeManager.getQuoteRecordTypeIdByDeveloperName('Referencement');
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
                //eachOrderItem.LPCR_TotalContractValue = <TO BE DEFINED>
            }
        }
    }
    
    
    /*
* @author : Ayoub Ouarti
*	@description : this method set orderItem's blng__BillingRule__c 
*	@param List<OrderItem> newOrderItemsList
*	@returns void
*/
    public static void setOrderItemFields(List<OrderItem> newOrderItemsList){
        Set<String> orderIds = UM003_TypeManager.getFieldsOfListObjects(newOrderItemsList,'OrderId');
        Map<Id, Order> ordersMap = new Map<Id, Order>([SELECT Id, LPCR_NouveauPlanFacture__c,LPCR_RenouvellementPlanFacture__c,  SBQQ__Quote__r.SBQQ__Type__c FROM Order WHERE Id IN :orderIds]);
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
        
        for(OrderItem eachOrderItem : newOrderItemsList){
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
    
    /*
* @author : Ayoub Ouarti
*	@description : this method update Billing transaction for RevisedOrderProduct on orderItem
*	@param List<OrderItem> newOrderItemsList
*	@returns void
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
}