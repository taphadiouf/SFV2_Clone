/**
* @author Ayoub Ouarti
* @date 19/05/2020
* @description Service class for blng__Usage__c
*/
public with sharing class SM014_UsageServices {
    
    /*
*	@description : this method check if any registration fee had been alredy applied for a given customer / nursery.
*	@param List<blng__Usage__c> usageList to process
*	@returns void
*/
    
    public static void setUsageFields(List<blng__Usage__c> usageList){
        
        Pad.log('SM014_UsageServices', 'setUsageFields(List<blng__Usage__c> usageList)', 'usageList.size '+usageList.size());
        
        Id accountEntrepriseRTId = EM003_RecordTypeEntity.getRecTypeIdByObjectAndName(Label.LPCR_Account, Label.LPCR_Entreprise);
        Id accountCrecheTId = EM003_RecordTypeEntity.getRecTypeIdByObjectAndName(Label.LPCR_Account, Label.LPCR_Creche);
        Set<String> accountIds = UM003_TypeManager.getFieldsOfListObjects(usageList,'blng__Account__c');
        Map<Id,Account> mapAccounts = new Map<Id,Account>([SELECT Id,Name,LPCR_TypeCreche__c, RecordTypeId FROM Account WHERE ID in :accountIds]);
        
        Set<String> productIds = UM003_TypeManager.getFieldsOfListObjects(usageList,'LPCR_Product__c');
        Map<Id,Product2> mapProducts = new Map<Id,Product2>([SELECT Id,Name FROM Product2 WHERE ID in :productIds]);

        
        for(blng__Usage__c eachUsage : usageList){
            //B2B case
            Pad.log('SM014_UsageServices', 'setUsageFields(List<blng__Usage__c> usageList)', 'eachUsage.blng__Account__r.RecordTypeId '+eachUsage.blng__Account__r.RecordTypeId);
			Pad.log('SM014_UsageServices', 'setUsageFields(List<blng__Usage__c> usageList)', 'accountEntrepriseRTId '+accountEntrepriseRTId);
            if(mapAccounts.get(eachUsage.blng__Account__c).RecordTypeId ==accountEntrepriseRTId ){
                eachUsage.blng__MatchingId__c = mapProducts.get(eachUsage.LPCR_Product__c).Name + mapAccounts.get(eachUsage.blng__Account__c).Name;
            }
            //B2C & MIRCO case
            else if(mapAccounts.get(eachUsage.blng__Account__c).RecordTypeId ==accountCrecheTId && 'MICRO'.equals(mapAccounts.get(eachUsage.blng__Account__c).LPCR_TypeCreche__c)){
                
            }
            
            
        }
        
    }
}