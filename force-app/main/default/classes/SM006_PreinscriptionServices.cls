/**
* @author Ayoub Ouarti
* @created 25/02/2020
* @description Services class on Preinscription Object
* @Modified by hanae on the 12/03/2020
*/
public class SM006_PreinscriptionServices {
    
    /*
* Generate Oppty & Contract for preinscriptions 
*/
    
    public static void generateOpptyAndQuote(Map<Id, LPCR_Preinscription__c> newPreinscrisMap,Map<Id, LPCR_Preinscription__c> oldPreinscrisMap){
        
        //Map: (Preinscription Id => Opportunity)
        Map<Id, Opportunity> preiscIDToOpportunityMap = new Map<Id, Opportunity>();
        List<SBQQ__Quote__c> listQuotes = new List<SBQQ__Quote__c>();
        //Fix of the record part of Opportunity: (set to Famille)
        Id familleOpportunityRT = EM003_RecordTypeEntity.getRecTypeIdByObjectAndName(System.Label.LPCR_Opportunity,System.Label.LPCR_Famille);
        for(LPCR_Preinscription__c eachNewPreinscri : newPreinscrisMap.values()){
            if((eachNewPreinscri.LPCR_Statut__c != oldPreinscrisMap.get(eachNewPreinscri.Id).LPCR_Statut__c 
                && Label.LPCR_Confirme.equals(eachNewPreinscri.LPCR_Statut__c))
               && (
                   Label.LPCR_OCC.equals(eachNewPreinscri.LPCR_TypePreinscription__c) 
                   ||  Label.LPCR_DEF.equals(eachNewPreinscri.LPCR_TypePreinscription__c) 
                   ||  Label.LPCR_DSP.equals(eachNewPreinscri.LPCR_TypePreinscription__c) 
               )){
                   preiscIDToOpportunityMap.put(eachNewPreinscri.Id, new Opportunity( 
                       RecordTypeId = familleOpportunityRT,
                       AccountId = eachNewPreinscri.LPCR_CompteFamille__c, 
                       Name = Label.LPCR_OppFor+eachNewPreinscri.LPCR_PrenomEnfant__c + ' ' + eachNewPreinscri.NomEnfant__c,
                       StageName = Label.LPCR_Prospecting,
                       CloseDate = Date.today()));
               }
        }
        //Insert the new opportunities
        EM004_OpportunityEntity.saveOrUpdte(preiscIDToOpportunityMap.values());
        Id accueilQuoteRecordTypeId = EM003_RecordTypeEntity.getRecTypeIdByObjectAndName(System.Label.LPCR_Quote,System.Label.LPCR_ContratA);
        Opportunity currentOpportunity;
        LPCR_Preinscription__c currentPreInscr;
        for(Id eachPreinscId : preiscIDToOpportunityMap.keySet()){
            currentOpportunity = preiscIDToOpportunityMap.get(eachPreinscId);
            currentPreInscr = newPreinscrisMap.get(eachPreinscId);
            listQuotes.add(new SBQQ__Quote__c(
                RecordTypeId = accueilQuoteRecordTypeId,
                LPCR_DateDebut__c = currentPreInscr.LPCR_DateEntreeCreche__c,
                SBQQ__Account__c = currentPreInscr.LPCR_CompteFamille__c,
                LPCR_ContactEnfant__c = currentPreInscr.LPCR_ContactEnfant__c,
                LPCR_Creche__c = currentPreInscr.LPCR_Creche__c,
                LPCR_ContactRepresentant1__c = currentPreInscr.LPCR_ContactParent__c,
                SBQQ__Opportunity2__c = currentOpportunity.Id));
        }
        
        
        EM006_QuoteEntity.saveOrUpdte(listQuotes);
        
    }
    
    public static void setStatusWhenValidateFormulaireIsTrue(Map<Id,LPCR_Preinscription__c> mapNewPreinscription,Map<Id,LPCR_Preinscription__c> mapOldPreinscription){
        for(LPCR_Preinscription__c eachPreinscription : mapNewPreinscription.values()){
            if(eachPreinscription.LPCR_ValidationFormulaire__c && mapOldPreinscription.get(eachPreinscription.Id).LPCR_ValidationFormulaire__c != eachPreinscription.LPCR_ValidationFormulaire__c ){
                eachPreinscription.LPCR_Statut__c=Label.LPCR_ListeAtt;               
            }  
        }
    }
    
    public static void setStatusWhenValidateFormulaireIsTrue(List<LPCR_Preinscription__c> preinscriptions){
        for(LPCR_Preinscription__c eachPreinscription : preinscriptions){
            if(eachPreinscription.LPCR_ValidationFormulaire__c ){eachPreinscription.LPCR_Statut__c=Label.LPCR_ListeAtt;               
                                                                }
        }
    }
    
    
}