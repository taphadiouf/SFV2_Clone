/**
* @author Fowdar Akshaye
* @created 02/06/2020
* @description Trigger actions on Order Object
*/
public with sharing class TM013_OrderTrigger extends TM000_TriggerHandler {
    private List<Order> newOrderList;
    
    public TM013_OrderTrigger() {
        this.newOrderList = (List<Order>) Trigger.new;
    }
    protected override void beforeInsert() {
        if (PAD.canTrigger('SM001_TestIfByPassed')) SM001_TestIfByPassed.executeMethod();
        SM014_OrderServices.setOrderFields(newOrderList);
    }
}