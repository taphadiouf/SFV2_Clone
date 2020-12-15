@isTest
public class EM001_AbstractObjectEntity_Test {
 
    @isTest
    static void EM001_AbstractObjectEntity_Test() {

        EM006_QuoteEntity ent = new EM006_QuoteEntity();    
        
        List<Account> accounts1 = UM002_TestDataFactory.createAccounts(1, 'testAccount_1');
        List<Opportunity> opps1 = UM002_TestDataFactory.createOpportunities(1, 'testOpp_1', 'Prospecting');
        insert accounts1;
        insert opps1;
        SBQQ__Quote__c q = UM002_TestDataFactory.createQuotes(1, accounts1, opps1).get(0);

        ent.doInsert( new List<SObject>{q} );

        ent.getAllWithAllFields();

        ent.getAll(new Set<String>{'name'});

        ent.getByIds(new Set<Id>{q.id},new Set<String>{'name'});

        ent.getById(q.id,new Set<String>{'name'});

        Map<String, Set<String>> filtersMap = new Map<String, Set<String>>();
        filtersMap.put('id', new Set<String>{q.id});
        ent.getBy(new Set<String>{'name'},filtersMap);

        ent.getBy('id',new Set<String>{q.id},new Set<String>{'name'});

        ent.getBy('id',new Set<Id>{q.id},new Set<String>{'name'});

    }
}
