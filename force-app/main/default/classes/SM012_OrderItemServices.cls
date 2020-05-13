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
        Boolean updateOrderItem = false;
        for(OrderItem eachOrderItem : listOrderItem){
            if(eachOrderItem.blng__LegalEntity__c ==null){
                updateOrderItem = true;
                eachOrderItem.blng__LegalEntity__c = eachOrderItem.SBQQ__QuoteLine__r.LPCR_EntiteJuridique__c;
                system.debug('setting legal entity on Order item '+eachOrderItem.blng__LegalEntity__c);
            }
        }
        if (updateOrderItem) {
            update listOrderItem;
        }
    }
    
    public static void legalEntityOnOrderItemConSch( Map<Id,OrderItem> mapOrderItem){
        List<SBQQ__OrderItemConsumptionSchedule__c> listOrderItemConSch = [SELECT SBQQ__OrderItem__c,SBQQ__OrderItem__r.blng__LegalEntity__c,blng__LegalEntity__c  FROM SBQQ__OrderItemConsumptionSchedule__c WHERE SBQQ__OrderItem__c in :mapOrderItem.keySet() ];
        List<SBQQ__OrderItemConsumptionSchedule__c> listOrderItemConSchtoSave = new List<SBQQ__OrderItemConsumptionSchedule__c>();
        for(SBQQ__OrderItemConsumptionSchedule__c eachOrderItemConSch : listOrderItemConSch){
            if(eachOrderItemConSch.SBQQ__OrderItem__r.blng__LegalEntity__c != null ){
                eachOrderItemConSch.blng__LegalEntity__c  = eachOrderItemConSch.SBQQ__OrderItem__r.blng__LegalEntity__c;
                system.debug('setting legal entity on Order item ConSch '+eachOrderItemConSch.blng__LegalEntity__c);

                listOrderItemConSchtoSave.add(eachOrderItemConSch);
            }
        }
        if(listOrderItemConSchtoSave.size()>0){
            update listOrderItemConSchtoSave;
        }
        
    }

    public static void setupInvoiceDates(Map<Id, OrderItem> newOrderItems) {
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
            
            // reload orderItems with relations
            List<OrderItem> orderItems = [SELECT Id, SBQQ__BillingType__c, ServiceDate, blng__NextChargeDate__c, blng__OverrideNextBillingDate__c, 
                blng__BillThroughDateOverride__c, OrderId, Order.LPCR_TypeCreche__c, Order.blng__BillingAccount__c, Order.blng__BillingAccount__r.RecordTypeId 
                FROM OrderItem WHERE Id IN :newOrderItems.keySet()];

            for (OrderItem item : orderItems) {
                if(item.Order.blng__BillingAccount__c != null && item.Order.blng__BillingAccount__r.RecordTypeId == accountFamilleRTId && item.ServiceDate != null) {

                    Integer orderItemStartDay = item.ServiceDate.day();
                    Integer invoiceDay = (item.Order.LPCR_TypeCreche__c == 'MAC')
                        ? macInvoicingDay
                        : microInvoicingDay;
                    
                    PAD.log('SM012_OrderItemServices', 'setupInvoiceDates', 'item (BEFORE): ' + item);
                    PAD.log('SM012_OrderItemServices', 'setupInvoiceDates', 'invoiceDay: ' + invoiceDay);
                    
                    if (item.blng__NextChargeDate__c != null) {
                        if(item.SBQQ__BillingType__c == 'Advance') {
                            if(item.ServiceDate == item.blng__NextChargeDate__c) { 
                                //update original record to make because of beforeUpdate event
                                newOrderItems.get(item.Id).blng__OverrideNextBillingDate__c = (orderItemStartDay > invoiceDay)
                                    ? UM005_DateUtility.setDayOnDate (invoiceDay, item.blng__NextChargeDate__c.addMonths(1))
                                    : UM005_DateUtility.setDayOnDate (invoiceDay, item.blng__NextChargeDate__c);

                                if(item.Order.LPCR_TypeCreche__c == 'MICRO') {
                                    newOrderItems.get(item.Id).blng__BillThroughDateOverride__c = UM005_DateUtility.lastDateOfMonth (newOrderItems.get(item.Id).blng__OverrideNextBillingDate__c.addMonths(1));
                                } 
                            } else if(item.ServiceDate != item.blng__NextChargeDate__c) {
                                newOrderItems.get(item.Id).blng__OverrideNextBillingDate__c = (item.Order.LPCR_TypeCreche__c =='MAC')
                                    ? UM005_DateUtility.setDayOnDate (invoiceDay, item.blng__NextChargeDate__c)
                                    : UM005_DateUtility.setDayOnDate (invoiceDay, item.blng__NextChargeDate__c.addMonths(-1));
                            }
                        } else if(item.SBQQ__BillingType__c == 'Arrears') {
                            newOrderItems.get(item.Id).blng__OverrideNextBillingDate__c = item.Order.LPCR_TypeCreche__c =='MAC' 
                                || (item.Order.LPCR_TypeCreche__c =='MICRO' && item.ServiceDate == item.blng__NextChargeDate__c && orderItemStartDay > invoiceDay)
                                    ? UM005_DateUtility.setDayOnDate (invoiceDay, item.blng__NextChargeDate__c.addMonths(1))
                                    : UM005_DateUtility.setDayOnDate (invoiceDay, item.blng__NextChargeDate__c);

                            if (item.Order.LPCR_TypeCreche__c =='MICRO' && item.ServiceDate == item.blng__NextChargeDate__c) {
                                newOrderItems.get(item.Id).blng__BillThroughDateOverride__c = UM005_DateUtility.lastDateOfMonth (newOrderItems.get(item.Id).blng__OverrideNextBillingDate__c);
                            }
                        }
                    }
                }
                PAD.log('SM012_OrderItemServices', 'setupInvoiceDates', 'item (AFTER): ' + newOrderItems.get(item.Id));
            }
        }  
    }
}