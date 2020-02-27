/**
* @author Hanae Makboub
* @date 11/02/2020
* @SOQL Queries about Lead
* @Last update : 20/02/2020 by Achraf ABOUL
*/
public with sharing class EM002_LeadEntity {
    public static List<Lead> getLeadsByOppsAndRecordType(Id leadEntrepriseTypeId, Set<Id> opportunitiesIds) {
        return [SELECT Id FROM Lead WHERE 
                convertedOpportunityId IN :opportunitiesIds
                AND RecordTypeId = :leadEntrepriseTypeId];
    }
    public static List<Lead> getLeadsBy(set<Id> setLeadIds,String recordTypeName) {
        return [SELECT Id, Status,RecordType.Name ,LPCR_DatePriseEnChargeCommercial__c
                FROM Lead 
                WHERE Id In :setLeadIds 
                AND RecordType.Name= :recordTypeName];
    }
   
    public static List<Lead> getLeadsBy(set<Id> setLeadIds,String recordTypeName,String status) {
        return [SELECT Id, Status,RecordType.Name ,LPCR_DatePriseEnChargeCommercial__c
                FROM Lead 
                WHERE Id In :setLeadIds 
                AND RecordType.Name= :recordTypeName 
                AND Status = :status];
    }
    public static Lead getAllLeadfielsById(Id leadId){
        return [SELECT  Id,
                        LastName,
                        Name, 
                        OwnerId, 
                        Phone, 
                        Email, 
                        LPCR_CiviliteCoDemandeur__c, 
                        LPCR_PrenomCoDemandeur__c, 
                        LPCR_NomCoDemandeur__c, 
                        LPCR_DateNaissance1__c, LPCR_DateNaissance2__c, LPCR_DateNaissance3__c, 
                        //LPCR_ProfessionCoDemandeur__c,
                        LPCR_SocieteCoDemandeur__c, 
                        LPCR_EmailCoDemandeur__c,
                        LPCR_TypePrestation__c, 
                        LPCR_SituationFamiliale__c, 
                        LPCR_AgeEnfants__c,
                        Address,
                        LPCR_DateEntreeCreche1__c,LPCR_DateEntreeCreche2__c, LPCR_DateEntreeCreche3__c,
                        LPCR_Lundi1__c, LPCR_Mardi1__c, LPCR_Mercredi1__c, LPCR_Jeudi1__c, LPCR_Vendredi1__c, LPCR_AmplitudeHoraireLundi1__c, LPCR_AmplitudeHoraireMardi1__c, LPCR_AmplitudeHoraireMercredi1__c, LPCR_AmplitudeHoraireJeudi1__c, LPCR_AmplitudeHoraireVendredi1__c,
                        LPCR_Lundi2__c, LPCR_Mardi2__c, LPCR_Mercredi2__c, LPCR_Jeudi2__c, LPCR_Vendredi2__c, LPCR_AmplitudeHoraireLundi2__c, LPCR_AmplitudeHoraireMardi2__c, LPCR_AmplitudeHoraireMercredi2__c, LPCR_AmplitudeHoraireJeudi2__c, LPCR_AmplitudeHoraireVendredi2__c, 
                        LPCR_Lundi3__c, LPCR_Mardi3__c, LPCR_Mercredi3__c, LPCR_Jeudi3__c, LPCR_Vendredi3__c, LPCR_AmplitudeHoraireLundi3__c, LPCR_AmplitudeHoraireMardi3__c, LPCR_AmplitudeHoraireMercredi3__c, LPCR_AmplitudeHoraireJeudi3__c, LPCR_AmplitudeHoraireVendredi3__c, 
                        LPCR_NomEnfant1__c, LPCR_NomEnfant2__c, LPCR_NomEnfant3__c
                FROM Lead 
                WHERE Id = :leadId LIMIT 1];
    }
     
}