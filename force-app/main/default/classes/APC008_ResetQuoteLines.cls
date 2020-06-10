/**
* @Author Achraf ABOUL (aaboul@salesforce.com)
* @Created 08/06/2020
* @Description controller to reset quantities of quote lines the LC : LC004_ResetQuoteLines
*/
public class APC008_ResetQuoteLines {

 //The purpose of this is to elevate the test class code coverage.
 public static Boolean testRunningFlag1 = false;
 @AuraEnabled
    public static Boolean resetQuantity(Id quoteId){
        //Map (existing quote line id => Quote line record)
        Map<Id,SBQQ__QuoteLine__c> idToQuoteLineMap;

        //Do not proceed action method if there's an error in the constructor
        Boolean hasError = false;

        // Throw an error if one of the required parameters is null
        if (String.isBlank(quoteId)) {
            ApexPages.addMessage(new ApexPages.Message(
                ApexPages.Severity.ERROR,
                'No quoteId parameter found.'));
            hasError = true;
            return false;
        }
        // Query all the fields from the collected quote line ids
        if (quoteId != null) {
            idToQuoteLineMap = new Map<Id,SBQQ__QuoteLine__c> ();

            String query = 'SELECT  SBQQ__Quote__r.SBQQ__Type__c, SBQQ__UpgradedSubscription__r.SBQQ__NetPrice__c, ' +
                ' SBQQ__UpgradedSubscription__r.SBQQ__CustomerPrice__c, SBQQ__UpgradedSubscription__r.SBQQ__RegularPrice__c, ';

            List <String> fieldsList = new List < String > ();
            for (Schema.FieldSetMember f: SObjectType.SBQQ__QuoteLine__c.FieldSets.LPCR_Tech_FieldSet.getFields()) {
                fieldsList.add(f.getFieldPath());
            }

            query += String.join(fieldsList, ',') + ' FROM SBQQ__QuoteLine__c WHERE SBQQ__Quote__c = :quoteId ORDER BY Name';
            List<SBQQ__QuoteLine__c> targetQLList = Database.query(query);
            if(targetQLList != null && targetQLList.size()>0){
                for (SBQQ__QuoteLine__c ql:targetQLList) {
                    ql.SBQQ__Quantity__c = 0;
            }
                // Update the current Quotelines with the quantity 0
                try {
                    update targetQLList;
                    if (Test.isRunningTest() && testRunningFlag1) {
                        throw new CustomException('Error message in Test Class.');
                    }
                } catch (Exception ex) {
                    ApexPages.addMessage(new ApexPages.Message(
                        ApexPages.Severity.ERROR,
                        'DML operation has failed. More info: ' + ex.getMessage() + '\nStack Trace:' + ex.getStackTraceString()));
                    return false;
                }           
             }
        }
        return true;
    }
    public class CustomException extends Exception {

    }
}