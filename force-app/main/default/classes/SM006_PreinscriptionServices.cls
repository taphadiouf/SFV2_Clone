/**
* @author Ayoub Ouarti
* @created 25/02/2020
* @description Services class on Preinscription Object
*/
public class SM006_PreinscriptionServices {
    
    /*
     * Generate Oppty & Contract for preinscriptions 
     */

    public static void generateOpptyAndQuote(Map<Id, LPCR_Preinscription__c> newPreinscrisMap,Map<Id, LPCR_Preinscription__c> oldPreinscrisMap){

        List<Opportunity> listOpptys = new List<Opportunity>();
        List<SBQQ__Quote__c> listQuotes = new List<SBQQ__Quote__c>();
        Id dspOpportunityRecTypeId = EM003_RecordTypeEntity.getRecTypeIdByObjectAndDeveloperName('Opportunity','AOPublicDSP');
        for(LPCR_Preinscription__c eachNewPreinscri : newPreinscrisMap.values()){
            if((eachNewPreinscri.LPCR_Statut__c != oldPreinscrisMap.get(eachNewPreinscri.Id).LPCR_Statut__c && 
            'Confirmé'.equals(eachNewPreinscri.LPCR_Statut__c))&& ('OCC'.equals(eachNewPreinscri.LPCR_TypePreinscription__c) || 'DEF'.equals(eachNewPreinscri.LPCR_TypePreinscription__c) || 'DSP'.equals(eachNewPreinscri.LPCR_TypePreinscription__c) )){
                listOpptys.add(new Opportunity(RecordTypeId = dspOpportunityRecTypeId, AccountId=eachNewPreinscri.LPCR_CompteFamille__c , Name ='Opportunité pour : '+eachNewPreinscri.LPCR_PrenomEnfant__c+' '+eachNewPreinscri.NomEnfant__c  ,StageName='Prospecting',CloseDate=Date.today()));
            }
        }
                
        listOpptys= EM004_OpportunityEntity.saveOrUpdte(listOpptys);
        Id accueilQuoteRecordTypeId = EM003_RecordTypeEntity.getRecTypeIdByObjectAndDeveloperName('SBQQ__Quote__c','Contrat_Accueil');
        for(Opportunity eachOppty : listOpptys){
            listQuotes.add(new SBQQ__Quote__c(RecordTypeId=accueilQuoteRecordTypeId,SBQQ__Account__c=eachOppty.AccountId ,SBQQ__Opportunity2__c= eachOppty.Id));
        }


        EM006_QuoteEntity.saveOrUpdte(listQuotes);
      
    }
   
}