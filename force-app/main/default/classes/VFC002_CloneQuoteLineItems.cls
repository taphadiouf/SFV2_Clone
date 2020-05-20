/**
* @Author Achraf ABOUL (aaboul@salesforce.com)
* @Created 08/05/2020
* @Description controller to clone quote line items for the vf page VFP002_CloneQuoteLineItems
*/
public with sharing class VFC002_CloneQuoteLineItems {
    private Id quoteId;
    //Map (existing quote line id => Quote line record)
    private Map<Id,SBQQ__QuoteLine__c> idToQuoteLineMap;


    //The purpose of this is to elevate the test class code coverage.
    public Boolean testRunningFlag = false;

    //Do not proceed action method if there's an error in the constructor
    Boolean hasError = false;

    // Class constructor. This method queries all of the records needed for the clone action.
    public VFC002_CloneQuoteLineItems() {
        hasError = false;

        //Get the parameters
        quoteId = ApexPages.currentPage().getParameters().get('quoteId');

        // Throw an error if one of the required parameters is null
        if (String.isBlank(quoteId)) {
            ApexPages.addMessage(new ApexPages.Message(
                ApexPages.Severity.ERROR,
                'No quoteId parameter found.'));
            hasError = true;
            return;
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

            for (SBQQ__QuoteLine__c ql: Database.query(query)) {
                    idToQuoteLineMap.put(ql.Id, ql);
            }
        }

    }

    // Method that executes the cloning action.
    public PageReference cloneAndResetQLI() {
        SBQQ.TriggerControl.disable();
        if (hasError) return null;
        Savepoint sp = Database.setSavepoint();
        // Map : origin Id => cloner Quote Line record
        Map<Id,SBQQ__QuoteLine__c> originIdsToclonedQLMap = new Map<Id, SBQQ__QuoteLine__c>();
       
        SBQQ__QuoteLine__c currentQL;
        // Clone every quote line
        for (SBQQ__QuoteLine__c ql: idToQuoteLineMap.values()) {
                currentQL = ql.clone(false, true, false, false);
                //To insure the order
                currentQL.SBQQ__Number__c = ql.SBQQ__Number__c + 1000;
                originIdsToclonedQLMap.put(ql.Id, currentQL);
                ql.SBQQ__Quantity__c = 0;
        }
        // Insert the new cloned QL records, we will update their requiredby fields later in this code
        try {
            insert originIdsToclonedQLMap.values();
            if (Test.isRunningTest() && testRunningFlag) {
                throw new CustomException('Error message in Test Class.');
            }
        } catch (Exception ex) {
            ApexPages.addMessage(new ApexPages.Message(
                ApexPages.Severity.ERROR,
                'DML operation has failed. More info: ' + ex.getMessage() + '\nStack Trace:' + ex.getStackTraceString()));
            Database.rollback(sp);
            return null;
        }
        //The current Cloned Quote line in the next loop
        SBQQ__QuoteLine__c currentClonedQL;
        //The current Original Quote line in the next loop
        SBQQ__QuoteLine__c currentOriginQL;
        //The Id of the current Parent of the original Quote line in the next loop
        Id currentOriginParentQLId;
        //update the bundles for the cloned Quote lines 
        // eachId is for the current original quote line
        for(Id eachId : originIdsToclonedQLMap.keySet()){
            currentClonedQL = originIdsToclonedQLMap.get(eachId);
            if(currentClonedQL.SBQQ__RequiredBy__c != null){
                //Origin quote line of the current cloned quote line
                currentOriginQL = idToQuoteLineMap.get(eachId);
                currentOriginParentQLId = currentOriginQL.SBQQ__RequiredBy__c;
                //set the parent of the cloned QL to be => the cloned QL from the parent of the original QL
                currentClonedQL.SBQQ__RequiredBy__c = originIdsToclonedQLMap.get(currentOriginParentQLId).Id;
            }
        }
        // Update the RequiredBy fields of cloned QL 
        // And update the quantity field of the original QL
        try {
            update originIdsToclonedQLMap.values();
            update idToQuoteLineMap.values();
            if (Test.isRunningTest() && testRunningFlag) {
                throw new CustomException('Error message in Test Class.');
            }
        } catch (Exception ex) {
            ApexPages.addMessage(new ApexPages.Message(
                ApexPages.Severity.ERROR,
                'DML operation has failed. More info: ' + ex.getMessage() + '\nStack Trace:' + ex.getStackTraceString()));
            Database.rollback(sp);
            return null;
        }
        return new PageReference('/apex/SBQQ__sb?id=' + quoteId + '#quote/le?qId=' + quoteId);
    }
    public class CustomException extends Exception {

    }
}
