public with sharing class EM012_RessourceFamilleEntity {
      public static List<LPCR_RessourceFamille__c> saveOrUpdte(List<LPCR_RessourceFamille__c> ressourceFamilles){
        if(UM003_TypeManager.isNotNullAndNotEmpty(ressourceFamilles) ){
            upsert ressourceFamilles;
        }
     return  ressourceFamilles; 
    }

    public static LPCR_RessourceFamille__c saveOrUpdte(LPCR_RessourceFamille__c ressourceFamille){
        if(UM003_TypeManager.isNotNull(ressourceFamille)){
            upsert ressourceFamille;
        }
     return  ressourceFamille; 
    }
}