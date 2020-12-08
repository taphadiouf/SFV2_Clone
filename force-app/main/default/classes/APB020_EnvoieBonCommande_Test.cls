/**
* @author Ayoub Ouarti
* @date 18/03/2020
* @Description Test class for APB020_EnvoieBonCommande_Test 
*/
@isTest
public class APB020_EnvoieBonCommande_Test {
    @testsetup
    static void setup() {
        
        List<Account> accs = UM002_TestDataFactory.createAccounts(1,'test');
        insert accs;
        List<Opportunity> oppties = UM002_TestDataFactory.createOpportunities(1, 'test', 'Prospecting');
        insert oppties;
        SBQQ__Quote__c quote =UM002_TestDataFactory.createQuotes(1, accs, oppties).get(0);
        insert quote;
        
    }
    @isTest
    private static void test(){
        System.runAs(UM002_TestDataFactory.createUser()){     

            Test.startTest();
            Opportunity oppty=[SELECT Id,SBQQ__PrimaryQuote__c, Name from Opportunity where Name ='test'];
            
            SBQQ__Quote__c quote = [SELECT Id ,SBQQ__Primary__c,SBQQ__Status__c,SBQQ__Opportunity2__c from SBQQ__Quote__c where Id = :oppty.SBQQ__PrimaryQuote__c ];
            quote.SBQQ__Primary__c=true;
            quote.SBQQ__Status__c='Prêt pour commande';
            update quote;

            APB020_EnvoieBonCommande_Test updateQLBonCommande = new APB020_EnvoieBonCommande_Test();
            updateQLBonCommande.execute(null);
            Test.stopTest();
            
            
        }
    }
}