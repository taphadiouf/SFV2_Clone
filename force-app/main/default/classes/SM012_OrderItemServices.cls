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
    
    public static void setLegalEntityOnOrderItem(List<OrderItem> newOrderItem){
        Set<Id> orderItemId = UM003_TypeManager.getIdsOfListObjects(newOrderItem);
        List<OrderItem> listOrderItem = [SELECT Id,blng__LegalEntity__c, SBQQ__QuoteLine__r.LPCR_EntiteJuridique__c	 FROM OrderItem WHERE ID in :orderItemId];
        for(OrderItem eachOrderItem : listOrderItem){
            if(eachOrderItem.blng__LegalEntity__c ==null){
                eachOrderItem.blng__LegalEntity__c =eachOrderItem.SBQQ__QuoteLine__r.LPCR_EntiteJuridique__c;
                system.debug('setting legal entity on Order item '+eachOrderItem.blng__LegalEntity__c);
            }
        }
        update listOrderItem;
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

    public static void setInvoiceGroupingOnOrderItem(Map<Id,OrderItem> mapOrderItem){
        Id recordTypeId = UM003_TypeManager.getQuoteRecordTypeIdByDeveloperName('Referencement');
        List<OrderItem> listOrderItem = [SELECT Id, LPCR_NumeroPurchaseOrder__c, Order.SBQQ__Quote__r.RecordTypeId, blng__InvoiceGrouping__c, blng__InvoiceGroupId__c FROM OrderItem WHERE ID in :mapOrderItem.keySet() AND Order.SBQQ__Quote__r.RecordTypeId =: recordTypeId];
        List<OrderItem> listOrderItemtoSave = new List<OrderItem>();
        for(OrderItem eachOrderItem : listOrderItem){
            eachOrderItem.blng__InvoiceGrouping__c = 'Invoice Group ID';
            if(String.isNotBlank(eachOrderItem.LPCR_NumeroPurchaseOrder__c)){
                eachOrderItem.blng__InvoiceGroupId__c = eachOrderItem.LPCR_NumeroPurchaseOrder__c;
                system.debug('invoice group id update on OrderItem '+eachOrderItem.blng__InvoiceGroupId__c);
            }
            listOrderItemtoSave.add(eachOrderItem);
        }
        if(listOrderItemtoSave.size()>0){
            update listOrderItemtoSave;
        }
    }
}