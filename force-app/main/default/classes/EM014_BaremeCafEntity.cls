public with sharing class EM014_BaremeCafEntity {
    public EM014_BaremeCafEntity() {

    }
    public static List<LPCR_BaremeCaf__c> getByDateByNbrEnfHigherOrEqual(Set<Integer> ressFamilleStartDateYears,Decimal minNbrEnfant){
        system.debug('Query ==== SELECT Id, LPCR_NombresEnfants__c ,LPCR_TauxEffortParEnfant__c,LPCR_DateFin__c,LPCR_DateDebut__c FROM LPCR_BaremeCaf__c  WHERE CALENDAR_YEAR(LPCR_DateDebut__c) IN '+ressFamilleStartDateYears+' AND LPCR_NombresEnfants__c>= '+minNbrEnfant+' ORDER BY LPCR_TauxEffortParEnfant__c ASC');
        return [SELECT Id, LPCR_NombresEnfants__c ,LPCR_TauxEffortParEnfant__c,LPCR_DateFin__c,LPCR_DateDebut__c FROM LPCR_BaremeCaf__c 
        WHERE CALENDAR_YEAR(LPCR_DateDebut__c) IN :ressFamilleStartDateYears 
        AND LPCR_NombresEnfants__c>= :minNbrEnfant
        ORDER BY LPCR_NombresEnfants__c ASC];
    }
}