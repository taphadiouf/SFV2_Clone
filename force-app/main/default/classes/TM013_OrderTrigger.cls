/**
* @author Fowdar Akshaye
* @created 02/06/2020
* @description Trigger actions on Order Object
*/
public with sharing class TM013_OrderTrigger extends TM000_TriggerHandler {
    private List<Order> newOrderList;
    private Map<Id, Order> oldOrdersMap;
    
    public TM013_OrderTrigger() {
        this.newOrderList = (List<Order>) Trigger.new;
        this.oldOrdersMap = (Map<Id, Order>) Trigger.oldMap;
    }
    protected override void beforeInsert() {
        if (!FeatureManagement.checkPermission('LPCR_ByPass_Apex')){
            SM014_OrderServices.setOrderFields(newOrderList, null);
        }
    }
    protected override void beforeUpdate() {
        if (!FeatureManagement.checkPermission('LPCR_ByPass_Apex')){
            SM014_OrderServices.setOrderFields(newOrderList, oldOrdersMap);
        }
    }
}