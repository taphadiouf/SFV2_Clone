/**
* @author Ayoub Ouarti
* @created 25/03/2020
* @description  class for BaremeCafEntity 
*/
public with sharing class EM014_BaremeCafEntity {
    public EM014_BaremeCafEntity() {

    }
    /*
	*	@description : this method get a list of BaremeCaf for specifics Date Debut Dates and for Higher Or Equal Number Enfants 
	*	@param Set<Integer> ressFamilleStartDateYears,Decimal minNbrEnfant
    *	@returns List<LPCR_BaremeCaf__c>
    */
    public static List<LPCR_BaremeCaf__c> getByDateByNbrEnfHigherOrEqual(Set<Integer> ressFamilleStartDateYears,Decimal minNbrEnfant){
        PAD.log('EM014_BaremeCafEntity', 'getByDateByNbrEnfHigherOrEqual','ressFamilleStartDateYears'+ ressFamilleStartDateYears.size()+'','minNbrEnfant'+ minNbrEnfant);
        return [SELECT Id, LPCR_NombresEnfants__c ,LPCR_TauxEffortParEnfant__c,LPCR_DateFin__c,LPCR_DateDebut__c FROM LPCR_BaremeCaf__c 
        WHERE CALENDAR_YEAR(LPCR_DateDebut__c) IN :ressFamilleStartDateYears 
        AND LPCR_NombresEnfants__c>= :minNbrEnfant
        ORDER BY LPCR_NombresEnfants__c ASC];
    }
}