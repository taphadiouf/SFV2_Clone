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
    public static void setOrderFields (List<order> orderList, Map<Id, Order> oldOrdersMap) {
        Map<String,Schema.RecordTypeInfo> mapOrderRT = Schema.getGlobalDescribe().get('Order').getDescribe().getRecordTypeInfosByDeveloperName();
        Set<String> quoteIds = UM003_TypeManager.getFieldsOfListObjects(orderList,'SBQQ__Quote__c');
        
        Map<Id,SBQQ__Quote__c> quoteMap = new  Map<Id,SBQQ__Quote__c>([SELECT Id,LPCR_TypeEnregistrement__c,RecordType.DeveloperName,LPCR_CompteFacturation__c,SBQQ__BillingFrequency__c  ,LPCR_BatchCommande__c, SBQQ__MasterContract__r.LPCR_BatchCommande__c from SBQQ__Quote__c WHERE Id in :quoteIds]);
  
        for (Order eachOrder : orderList){
           eachOrder.blng__BillingDayOfMonth__c  =  eachOrder.LPCR_InitAutoAvecDateDebut__c ?  eachOrder.EffectiveDate.day()+'' : eachOrder.blng__BillingDayOfMonth__c;
            
           if(
               Trigger.isUpdate  
                && Label.LPCR_Amendment.equals(eachOrder.Type)  
                && eachOrder.SBQQ__Contracted__c == true 
                && oldOrdersMap.get(eachOrder.Id).SBQQ__Contracted__c == false
                ){
                eachOrder.blng__InvoiceBatch__c = quoteMap.get(eachOrder.SBQQ__Quote__c).SBQQ__MasterContract__r.LPCR_BatchCommande__c;
            }
            if(Trigger.isInsert && quoteMap.containsKey(eachOrder.SBQQ__Quote__c)){
                eachOrder.blng__InvoiceBatch__c = quoteMap.get(eachOrder.SBQQ__Quote__c).LPCR_BatchCommande__c;
                eachOrder.LPCR_FrequenceFacturation__c  = quoteMap.get(eachOrder.SBQQ__Quote__c).SBQQ__BillingFrequency__c;
                eachOrder.blng__BillingAccount__c = quoteMap.get(eachOrder.SBQQ__Quote__c).LPCR_CompteFacturation__c;
               
             /*eachOrder.RecordTypeId = mapOrderRT.containsKey(quoteMap.get(eachOrder.SBQQ__Quote__c).RecordType.DeveloperName)? 
                    mapOrderRT.get(quoteMap.get(eachOrder.SBQQ__Quote__c).RecordType.DeveloperName).getRecordTypeId():  eachOrder.RecordTypeId;*/
            if(quoteMap.get(eachOrder.SBQQ__Quote__c).RecordType.DeveloperName != null){
                if( mapOrderRT.containsKey(quoteMap.get(eachOrder.SBQQ__Quote__c).RecordType.DeveloperName)){
                    eachOrder.RecordTypeId = mapOrderRT.get(quoteMap.get(eachOrder.SBQQ__Quote__c).RecordType.DeveloperName).getRecordTypeId();
                }else if(mapOrderRT.containsKey(quoteMap.get(eachOrder.SBQQ__Quote__c).RecordType.DeveloperName.split('_')[0])){
                    eachOrder.RecordTypeId = mapOrderRT.get(quoteMap.get(eachOrder.SBQQ__Quote__c).RecordType.DeveloperName.split('_')[0]).getRecordTypeId();
                }
            }
               
            }
          
        }
    }
}