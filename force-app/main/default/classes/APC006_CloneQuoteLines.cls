/**
* @Author Achraf ABOUL (aaboul@salesforce.com)
* @Created 20/05/2020
* @Description controller to clone quote line items for the LC : LC003_CloneQuoteLines
*/
public with sharing class APC006_CloneQuoteLines {
    
 //The purpose of this is to elevate the test class code coverage.
 public static Boolean testRunningFlag1 = false;
 public static Boolean testRunningFlag2 = false;
 @AuraEnabled
    public static Boolean cloneAndResetQL(Id quoteId){
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

            query += String.join(fieldsList, ',') + ' FROM SBQQ__QuoteLine__c WHERE SBQQ__Quote__c = :quoteId AND LPCR_CloneCancel__c = True ORDER BY Name';
            List<SBQQ__QuoteLine__c> targetQLList = Database.query(query);
            if(targetQLList != null && targetQLList.size()>0){
                for (SBQQ__QuoteLine__c ql:targetQLList) {
                    idToQuoteLineMap.put(ql.Id, ql);
            }
            }
            
        }
        if(idToQuoteLineMap.size() == 0){
            return false;
        }

        SBQQ.TriggerControl.disable();
        if (hasError) return false;
        Savepoint sp = Database.setSavepoint();
        // Map : origin Id => cloner Quote Line record
        Map<Id,SBQQ__QuoteLine__c> originIdsToclonedQLMap = new Map<Id, SBQQ__QuoteLine__c>();
       
        SBQQ__QuoteLine__c currentQL;
        // Clone every quote line
        for (SBQQ__QuoteLine__c ql: idToQuoteLineMap.values()) {
                currentQL = ql.clone(false, true, false, false);
                currentQL.SBQQ__PriorQuantity__c = 0;
                //To insure the order
                if(currentQL.SBQQ__Number__c != null){
                    currentQL.SBQQ__Number__c = ql.SBQQ__Number__c + 1000;
                }
                originIdsToclonedQLMap.put(ql.Id, currentQL);
                ql.SBQQ__Quantity__c = 0;
                ql.LPCR_TotalBerceauGratuitRegion__c = 0;

        }
        // Insert the new cloned QL records, we will update their requiredby fields later in this code
        try {
            insert originIdsToclonedQLMap.values();
            if (Test.isRunningTest() && testRunningFlag1) {
                throw new CustomException('Error message in Test Class.');
            }
        } catch (Exception ex) {
            ApexPages.addMessage(new ApexPages.Message(
                ApexPages.Severity.ERROR,
                'DML operation has failed. More info: ' + ex.getMessage() + '\nStack Trace:' + ex.getStackTraceString()));
            Database.rollback(sp);
            return false;
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
            if (Test.isRunningTest() && testRunningFlag2) {
                throw new CustomException('Error message in Test Class.');
            }
        } catch (Exception ex) {
            ApexPages.addMessage(new ApexPages.Message(
                ApexPages.Severity.ERROR,
                'DML operation has failed. More info: ' + ex.getMessage() + '\nStack Trace:' + ex.getStackTraceString()));
            Database.rollback(sp);
            return false;
        }
        return true;
    }
    public class CustomException extends Exception {

    }
}