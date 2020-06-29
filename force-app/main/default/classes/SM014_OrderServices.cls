/**
* @author Fowdar Akshaye
* @date 02/06/2020
* @description Service class for Order
*/
public with sharing class SM014_OrderServices {
    
    /*
*	@description : this method is use to update LPCR_BatchCommande from the Quote
*	@param List<Order> order to process
*	@returns void
*/
    public static void setOrderFields (List<order> orderList) {
        Set<String> quoteIds = UM003_TypeManager.getFieldsOfListObjects(orderList,'SBQQ__Quote__c');
        
        Map<Id,SBQQ__Quote__c> quoteMap = new  Map<Id,SBQQ__Quote__c>([SELECT Id,SBQQ__BillingFrequency__c  ,LPCR_BatchCommande__c from SBQQ__Quote__c WHERE Id in :quoteIds]);
        
        for (Order eachOrder : orderList){
            if(quoteMap.containsKey(eachOrder.SBQQ__Quote__c)){
                eachOrder.blng__InvoiceBatch__c = quoteMap.get(eachOrder.SBQQ__Quote__c).LPCR_BatchCommande__c;
                eachOrder.LPCR_FrequenceFacturation__c  = quoteMap.get(eachOrder.SBQQ__Quote__c).SBQQ__BillingFrequency__c;
            }
          
        }
    }
}