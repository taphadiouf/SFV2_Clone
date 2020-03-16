public with sharing class LWC003_UpdateStatusController {

    @AuraEnabled(Cacheable=true)
     public static List<String> getPicklistvalues(){
     
     List<String> lstPicklistValue = new List<String>();
     Schema.DescribeFieldResult describeFieldRslt = LPCR_Preinscription__c.LPCR_Statut__c.getDescribe();
     List<Schema.PicklistEntry> pickListEntries = describeFieldRslt.getPicklistValues();
     
     for(Schema.PicklistEntry eachEntry : pickListEntries ) {
         lstPicklistValue.add(eachEntry.getValue());
     }
    
     return lstPicklistValue;
     
 }
 @AuraEnabled
 public static List<LPCR_Preinscription__c> updateLstPreinscription(String statut, List<Id> preinscriptionIds){
    List<LPCR_Preinscription__c> lstPreinscription = EM007_PreinscriptionEntity.getListofPreinscriptionById(preinscriptionIds);
     for(LPCR_Preinscription__c eachPreinscription : lstPreinscription){
         eachPreinscription.LPCR_Statut__c = statut;
     }
     update lstPreinscription;
     return lstPreinscription;
     
 }
 


}