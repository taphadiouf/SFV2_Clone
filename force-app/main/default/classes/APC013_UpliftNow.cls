/**
 * @description       : Controller class for LWC015_UpliftNow
 * @author            : Rakshak Rajjoo
 * @last modified on  : 21/10/2021
 * @last modified by  : Rakshak Rajjoo
 * Modifications Log
 * Ver   Date         Author           Modification
 * 1.0   12/10/2021   Rakshak Rajjoo   Initial Version
 **/
public with sharing class APC013_UpliftNow {
    final private static String TYPEAVENANT_INDEXATION = 'Amendement d\'indexation';

    @AuraEnabled
    public static void doUplift(String contractId) {
        try {
            Contract con = [SELECT Id, LPCR_IndexationConvenue__c, SBQQ__RenewalUpliftRate__c, LPCR_DateRevisionPrix__c FROM Contract WHERE Id = :contractId];

            List<SBQQ__Quote__c> lstQuoteUpdate = new List<SBQQ__Quote__c>();

            String a_Object_API_Name = 'Contract';
            Map<String, Schema.SObjectField> contractFields = Schema.getGlobalDescribe().get(a_Object_API_Name).getDescribe().fields.getMap();
            if (con.LPCR_DateRevisionPrix__c == null) {
                throw new CustomException(System.Label.LPCR_ErrorMessageUplift+' \''+contractFields.get('LPCR_DateRevisionPrix__c').getDescribe().getLabel()+'\'');
            }
            if (con.SBQQ__RenewalUpliftRate__c == null) {
                throw new CustomException(System.Label.LPCR_ErrorMessageUplift+' \''+contractFields.get('SBQQ__RenewalUpliftRate__c').getDescribe().getLabel()+'\'');
            }

            UM006_ContractAmender amender = new UM006_ContractAmender();

            WRP001_QuoteModel quote = amender.load(con.Id);
            UM007_QuoteReader reader = new UM007_QuoteReader();
            WRP001_QuoteModel quoteModel = reader.read(quote.record.id);
            APC006_CloneQuoteLinesIndexation.cloneAndResetQL(quoteModel.record.id, con.SBQQ__RenewalUpliftRate__c, con.LPCR_DateRevisionPrix__c);
            lstQuoteUpdate.add(
                new SBQQ__Quote__c(
                    Id = quoteModel.record.id,
                    SBQQ__RenewalUpliftRate__c = con.SBQQ__RenewalUpliftRate__c,
                    LPCR_DateRevisionPrix__c = con.LPCR_DateRevisionPrix__c.addYears(1),
                    LPCR_TypeAvenant__c = TYPEAVENANT_INDEXATION
                )
            );

            if (lstQuoteUpdate.size() > 0) {
                update lstQuoteUpdate;
            }
        } catch (Exception e) {
            PAD.log('APC013_UpliftNow', 'doUplift', '', e.getMessage() + ' ' + e.getStackTraceString());
            throw new AuraHandledException(e.getMessage());
        }
    }

    public class CustomException extends Exception {
    }
}
