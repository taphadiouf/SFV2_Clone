@isTest
public with sharing class EM014_BaremeCafEntity_Test {
    
    @isTest
    static void EM014_BaremeCafEntity_Test() {
        EM014_BaremeCafEntity entity = new EM014_BaremeCafEntity();    
        List<Date> listStartDates = new List<Date>();
        
        List<Decimal> listTauxEffortParEnfant = new List<Decimal>();
        for(Integer i=1;i<=3;i++){
            listTauxEffortParEnfant.add(1);
        }
        for(Integer i=1;i<=3;i++){
            listTauxEffortParEnfant.add(2);
        }
        for(Integer i=1;i<=3;i++){
            listTauxEffortParEnfant.add(3);
        }
        listTauxEffortParEnfant.add(4);
        
        listStartDates = new List<Date>();
        listStartDates.add(Date.newInstance(Date.today().Year(), 1, 1));
        listStartDates.add(Date.newInstance(Date.today().addYears(1).Year(), 1, 1));
        listStartDates.add(Date.newInstance(Date.today().addYears(2).Year(), 1, 1));
        
        List<LPCR_BaremeCAF__c> listBaremeCAF = UM002_TestDataFactory.createBaremeCAF(10, listStartDates,listTauxEffortParEnfant);
        insert listBaremeCAF;

        List<LPCR_BaremeCaf__c> res = EM014_BaremeCafEntity.getByDateByNbrEnfHigherOrEqual(new Set<Integer>{2020},0);
        System.assertEquals(10, res.size());
    }
}