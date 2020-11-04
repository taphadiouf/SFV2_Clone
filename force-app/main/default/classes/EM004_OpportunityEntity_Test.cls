@isTest
public  class EM004_OpportunityEntity_Test {

    @isTest
    static void EM004_OpportunityEntity_Test() {
        Account acc = UM002_TestDataFactory.createAccount('test');
        insert acc;
        Opportunity opp = new Opportunity(AccountId = acc.Id,
                                              CloseDate = Date.today().addDays(15),
                                              StageName = 'CreationProgress',
                                              Name = 'Test opp1');
        List<Opportunity> opps = new List<Opportunity>{opp};
        opps = EM004_OpportunityEntity.saveOrUpdte(opps);
        
        Test.startTest();
        EM004_OpportunityEntity e = new EM004_OpportunityEntity();
        System.assertEquals('Opportunity', e.getObjectName());
        System.assertEquals('EM004_OpportunityEntity', e.getDataManagerClassName());
        System.assertNotEquals(null, opps.get(0).id);
        List<Opportunity> getOpps = EM004_OpportunityEntity.getOppsByIds(new Set<Id>{opp.id});
        opp.stageName = 'Signée';
        opp = EM004_OpportunityEntity.saveOrUpdte(opp);
        Test.stopTest();

        Opportunity afterOpp = [SELECT id,stagename from Opportunity where Name = 'Test opp1'];
        System.assertEquals('Signée', afterOpp.stageName);
        System.assertEquals(1, getOpps.size());

    }
}
