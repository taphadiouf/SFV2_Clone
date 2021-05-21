public with sharing class SM030_BonAchatPartenaireService {
    public static Id entrepriseRecTypeId = EM003_RecordTypeEntity.getRecTypeIdByObjectAndName(Label.LPCR_Contract,Label.LPCR_Referencement);
    public static void populateBonAchatContrat(Map<Id, LPCR_BonAchatPartenaire__c> newBonAchatPartenaireMap){
        
    
        Map<String,ID> mapCrecheIDEnfantBonDachat=new Map<String,ID>();
        Map<String,ID> mapCrecheIDEnfantSubscription=new Map<String,ID>();
        Map<String,ID> mapCrecheIDEnfantSubscriptionContrat=new Map<String,ID>();
        Set<Id> setCreche =new Set<Id>();
        Set<Id> setContrat =new Set<Id>();
        Set<Id> setContactEnfant =new Set<Id>();
        List<SBQQ__Subscription__c> lstSubscriptionUpdate=new List<SBQQ__Subscription__c>();
        Map<Id,Id> mapBonAchatContratId =new Map<Id,Id> ();
        List<LPCR_BonAchatPartenaire__c> lstBonAchatUpdate=new List<LPCR_BonAchatPartenaire__c>();
        for (Id key : newBonAchatPartenaireMap.keySet()){
            if(newBonAchatPartenaireMap.get(key).LPCR_Creche__c != null && newBonAchatPartenaireMap.get(key).LPCR_ContactEnfant__c  != null ){
                if(!mapCrecheIDEnfantBonDachat.containsKey(newBonAchatPartenaireMap.get(key).LPCR_Creche__c+'-'+newBonAchatPartenaireMap.get(key).LPCR_ContactEnfant__c)){
                    mapCrecheIDEnfantBonDachat.put(newBonAchatPartenaireMap.get(key).LPCR_Creche__c+'-'+newBonAchatPartenaireMap.get(key).LPCR_ContactEnfant__c,key);
                    
                    setCreche.add(newBonAchatPartenaireMap.get(key).LPCR_Creche__c);
                    setContactEnfant.add(newBonAchatPartenaireMap.get(key).LPCR_ContactEnfant__c);
                }
                
            }
        }
        //get contrat where bon d'achat is null 
        for(SBQQ__Subscription__c  subs :[SELECT Id, LPCR_Creche__c, LPCR_ContactEnfant__c, SBQQ__Contract__c ,LPCR_BonDachatPartenaire__c FROM SBQQ__Subscription__c  where LPCR_BonDachatPartenaire__c =null and LPCR_Creche__c IN:setCreche  and LPCR_ContactEnfant__c IN:setContactEnfant and SBQQ__Contract__r.RecordTypeId=:entrepriseRecTypeId ]){
            if(!mapCrecheIDEnfantSubscription.containsKey(subs.LPCR_Creche__c+'-'+subs.LPCR_ContactEnfant__c)){
                mapCrecheIDEnfantSubscription.put(subs.LPCR_Creche__c+'-'+subs.LPCR_ContactEnfant__c,subs.Id);
                mapCrecheIDEnfantSubscriptionContrat.put(subs.LPCR_Creche__c+'-'+subs.LPCR_ContactEnfant__c,subs.SBQQ__Contract__c);
            }
        }
        //loop in all newly created subscription 
        for(String key : mapCrecheIDEnfantSubscription.keyset()){
            if(!mapCrecheIDEnfantBonDachat.isEmpty() && mapCrecheIDEnfantBonDachat.containsKey(key) ){
                lstSubscriptionUpdate.add(new SBQQ__Subscription__c(Id=mapCrecheIDEnfantSubscription.get(key),LPCR_BonDachatPartenaire__c=mapCrecheIDEnfantBonDachat.get(key)));
                lstBonAchatUpdate.add(new LPCR_BonAchatPartenaire__c(Id=mapCrecheIDEnfantBonDachat.get(key),LPCR_ContratReservataire__c=mapCrecheIDEnfantSubscriptionContrat.get(key)));
            }
            
        }
        if(lstSubscriptionUpdate.size() > 0 ){
            update lstSubscriptionUpdate;
            if(lstBonAchatUpdate.size() > 0){
                update lstBonAchatUpdate;
            }
        }
        
    }
}