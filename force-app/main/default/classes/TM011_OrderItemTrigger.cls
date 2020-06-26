/**
* @author Ayoub Ouarti
* @created 26/03/2020
* @description Trigger actions on OrderItem Object
*/
public with sharing class TM011_OrderItemTrigger extends TM000_TriggerHandler{
    private Map<Id, OrderItem> newOrderItemsMap;
    private Map<Id, OrderItem> oldOrderItemsMap;
    private List<OrderItem> newOrderItemsList;
    
    public TM011_OrderItemTrigger() {
        this.newOrderItemsMap = (Map<Id, OrderItem>) Trigger.newMap;
        this.oldOrderItemsMap = (Map<Id, OrderItem>) Trigger.oldMap;
        this.newOrderItemsList = (List<OrderItem>) Trigger.new;
    }

    protected override void beforeInsert() {
        if (PAD.canTrigger('SM001_TestIfByPassed')) SM001_TestIfByPassed.executeMethod();
        SM012_OrderItemServices.setupInvoiceDates(newOrderItemsList);
        SM012_OrderItemServices.setInvoiceGrouping(newOrderItemsList);
        SM012_OrderItemServices.setOrderItemFields(newOrderItemsList);

    }

    protected override void afterInsert() {
        if (PAD.canTrigger('SM001_TestIfByPassed')) SM001_TestIfByPassed.executeMethod();
        SM012_OrderItemServices.setInvoiceGroupingOnOrderItem(newOrderItemsMap);
        
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

    protected override void beforeUpdate() {
        if (PAD.canTrigger('SM001_TestIfByPassed')) SM001_TestIfByPassed.executeMethod();
        SM012_OrderItemServices.setupInvoiceDates(newOrderItemsList);
        SM012_OrderItemServices.setOrderItemFieldsFromContract(newOrderItemsList);
    }
    
    protected override void afterUpdate() {
        if (PAD.canTrigger('SM001_TestIfByPassed')) SM001_TestIfByPassed.executeMethod();
        SM012_OrderItemServices.legalEntityOnOrderItemConSch(newOrderItemsMap);
        SM012_OrderItemServices.updateFiledsOnBillingTransaction(oldOrderItemsMap,newOrderItemsMap);
           
    }
}