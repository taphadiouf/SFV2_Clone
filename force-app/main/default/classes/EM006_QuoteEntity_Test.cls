@isTest
public class EM006_QuoteEntity_Test {
    @isTest
    static void EM006_QuoteEntity_Test() {

        EM006_QuoteEntity ent = new EM006_QuoteEntity();    
        
        List<Account> accounts1 = UM002_TestDataFactory.createAccounts(1, 'testAccount_1');
        List<Opportunity> opps1 = UM002_TestDataFactory.createOpportunities(1, 'testOpp_1', 'Prospecting');
        insert accounts1;
        insert opps1;
        SBQQ__Quote__c q = UM002_TestDataFactory.createQuotes(1, accounts1, opps1).get(0);
        insert q;  
        q.SBQQ__StartDate__c = Date.today().addDays(1);
        q = EM006_QuoteEntity.saveOrUpdte(q);
        SBQQ__Quote__c quoteRes = [SELECT id,SBQQ__StartDate__c FROM SBQQ__Quote__c WHERE id=:q.Id ];
        System.assertEquals(Date.today().addDays(1),quoteRes.SBQQ__StartDate__c);

        List<Account> accounts = UM002_TestDataFactory.createAccounts(2, 'testAccount');
        List<Opportunity> opps = UM002_TestDataFactory.createOpportunities(2, 'testOpp', 'Prospecting');
        insert accounts;
        insert opps;
        List<SBQQ__Quote__c> quotes = UM002_TestDataFactory.createQuotes(2, accounts, opps);
        insert quotes;
        quotes.get(0).SBQQ__StartDate__c = Date.today().addDays(2);
        quotes.get(1).SBQQ__StartDate__c = Date.today().addDays(2);
        quotes = EM006_QuoteEntity.saveOrUpdte(quotes);
        System.assertEquals(Date.today().addDays(2),quotes.get(0).SBQQ__StartDate__c);
        System.assertEquals(Date.today().addDays(2),quotes.get(1).SBQQ__StartDate__c);

        SBQQ__Quote__c res = EM006_QuoteEntity.getQuoteById(q.id);
        System.assertNotEquals(null, res);

        //static List<SBQQ__Quote__c> getQuoteModifById (Set<Id> quoteId)
        Set<Id> quoteIds = (new Map<Id,SBQQ__Quote__c>(quotes)).keySet();
        List<SBQQ__Quote__c> res2 = EM006_QuoteEntity.getQuoteModifById(quoteIds);
        System.assertEquals(2, res2.size());
    }
}