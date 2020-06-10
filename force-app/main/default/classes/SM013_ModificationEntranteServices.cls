/**
* @author Hanae MAKBOUB
* @date 15/05/2020
* @description Service class for LPCR_ModificationEntrante__c
*/
public with sharing class SM013_ModificationEntranteServices {
    public static List<SBQQ__Quote__c> updateQuotesFromModifEntrantes(List<LPCR_ModificationEntrante__c> ModifEntrantesList){
        List<LPCR_ModificationEntrante__c> evtModifEntrantesList = EM016_ModificationEntranteEntity.getModifEntranteById(ModifEntrantesList); 
        Map<Id,LPCR_ModificationEntrante__c> mapDevisModifictionEntrante = new Map<Id,LPCR_ModificationEntrante__c>();
        for(LPCR_ModificationEntrante__c eachModification : evtModifEntrantesList){
            mapDevisModifictionEntrante.put(eachModification.LPCR_Devis__c , eachModification);
        }
        List<SBQQ__Quote__c> quotesToUpdate = EM006_QuoteEntity.getQuoteModifById(mapDevisModifictionEntrante.keySet());
        for(SBQQ__Quote__c eachQuote : quotesToUpdate ){
            eachQuote.SBQQ__Status__c = System.Label.LPCR_QuoteValide ;
        }
        update quotesToUpdate;
        return quotesToUpdate;
    }
    //added by saurabh
    public static void createUsageFromModifEntrantes(List<LPCR_ModificationEntrante__c> ModifEntrantesList){
        System.debug('SM013_ModificationEntranteServices');
        List<blng__Usage__c> lstBillingUsage = new List<blng__Usage__c>();
        
        for(LPCR_ModificationEntrante__c eachModification : ModifEntrantesList){
            if('Modification Heure Supplémentaire MAC'.equals(eachModification.LPCR_Evenement__c) &&
               'Modification Heure Occasionnel MAC'.equals(eachModification.LPCR_Evenement__c) &&
               'Modification Heure Déduite MAC'.equals(eachModification.LPCR_Evenement__c) &&
               'Modification Facturation Adaptation'.equals(eachModification.LPCR_Evenement__c) &&
               'Nombre de repas'.equals(eachModification.LPCR_Evenement__c) &&
               'Abscence'.equals(eachModification.LPCR_Evenement__c)
              ){
                  blng__Usage__c newUsage = EM016_ModificationEntranteEntity.createBlngUsage(eachModification,'Hour');
                  System.debug('**** newUsage : '+ newUsage);   
                  if(newUsage != null){
                      lstBillingUsage.add(newUsage);
                  }           
              } 
        }
        if(lstBillingUsage.size() > 0){
            insert lstBillingUsage;
            System.debug('SM013_ModificationEntranteServices billing usage insertd'+lstBillingUsage.size());
        }
    }
    
}