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

        if (!FeatureManagement.checkPermission('LPCR_ByPass_Apex')){
            SM012_OrderItemServices.setupInvoiceDates(newOrderItemsList);
            SM012_OrderItemServices.setInvoiceGrouping(newOrderItemsList);
            SM012_OrderItemServices.setOrderItemFields(newOrderItemsList);
        }
    }

    protected override void afterInsert() {

        if (!FeatureManagement.checkPermission('LPCR_ByPass_Apex')) {
            SM012_OrderItemServices.setInvoiceGroupingOnOrderItem(newOrderItemsMap);
            SM012_OrderItemServices.updateContratBerceau(newOrderItemsMap);
            SM012_OrderItemServices.enqueueJob(newOrderItemsList);
        }    
    }

    protected override void beforeUpdate() {

        if (!FeatureManagement.checkPermission('LPCR_ByPass_Apex')){  
            SM012_OrderItemServices.setupInvoiceDates(newOrderItemsList);
            SM012_OrderItemServices.setOrderItemFieldsFromContract(newOrderItemsList);
            SM012_OrderItemServices.updateHoldBillingFromQuote(newOrderItemsList, oldOrderItemsMap,newOrderItemsMap);
            SM012_OrderItemServices.updateGroupId(oldOrderItemsMap, newOrderItemsList);
        }
    }
    
    protected override void afterUpdate() {

       if (!FeatureManagement.checkPermission('LPCR_ByPass_Apex')){
            SM012_OrderItemServices.updateRelatedOrderItems(oldOrderItemsMap,newOrderItemsMap);
            SM012_OrderItemServices.legalEntityOnOrderItemConSch(newOrderItemsMap);
            SM012_OrderItemServices.updateFiledsOnBillingTransaction(oldOrderItemsMap,newOrderItemsMap);
            
        } 
    }
}