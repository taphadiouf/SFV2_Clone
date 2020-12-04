/**
* @author Hanae MAKBOUB
* @date 15/05/2020
* @Description Queries about LPCR_ModificationEntrante__c
*/
public with sharing class EM016_ModificationEntranteEntity extends EM001_AbstractObjectEntity{
    
    public EM016_ModificationEntranteEntity(){
        super('LPCR_ModificationEntrante__c');
    }
    
    public static List<LPCR_ModificationEntrante__c> getModifEntranteById(List<LPCR_ModificationEntrante__c> modifId){
        return [SELECT Id, LPCR_Evenement__c,LPCR_Contract__c,LPCR_Contract__r.SBQQ__Quote__c  FROM LPCR_ModificationEntrante__c WHERE LPCR_Evenement__c  = 'EVT_VALIDATION_CONTRAT_DIRECTRICE' AND id =:modifId];
    }
	
}