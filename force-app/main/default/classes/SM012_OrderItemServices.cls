/**
* @author Ayoub Ouarti
* @date 26/03/2020
* @description Service class for SM012_OrderItemServices
*/
public with sharing class SM012_OrderItemServices implements Queueable{
    Map<Id,OrderItem> newOrderItemMap ;
    public SM012_OrderItemServices(Map<Id,OrderItem> newOrderItemMap) {
        this.newOrderItemMap = newOrderItemMap;
    }
     public void execute(QueueableContext context) {
        SM012_OrderItemServices.setLegalEntityOnOrderItem(this.newOrderItemMap);
    }

    public static void setLegalEntityOnOrderItem(Map<Id,OrderItem> newOrderItemMap){
        
        List<OrderItem> listOrderItem = [SELECT Id,blng__LegalEntity__c, SBQQ__QuoteLine__r.LPCR_EntiteJuridique__c	 FROM OrderItem WHERE ID in :newOrderItemMap.keySet()];
        for(OrderItem eachOrderItem : listOrderItem){
            if(eachOrderItem.blng__LegalEntity__c ==null){
                eachOrderItem.blng__LegalEntity__c =eachOrderItem.SBQQ__QuoteLine__r.LPCR_EntiteJuridique__c;
            }
        }
        update listOrderItem;
    }
}
