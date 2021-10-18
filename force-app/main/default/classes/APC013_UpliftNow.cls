/**
 * @description       : Controller class for LWC015_UpliftNow
 * @author            : Rakshak Rajjoo
 * @last modified on  : 14/10/2021
 * @last modified by  : Rakshak Rajjoo
 * Modifications Log
 * Ver   Date         Author           Modification
 * 1.0   12/10/2021   Rakshak Rajjoo   Initial Version
 **/
public with sharing class APC013_UpliftNow {
    @AuraEnabled
    public static void doUplift(String contractId) {
        try {
            Contract con = [SELECT Id, LPCR_IndexationConvenue__c, SBQQ__RenewalUpliftRate__c, LPCR_DateRevisionPrix__c FROM Contract WHERE Id = :contractId];

            List<SBQQ__Quote__c> lstQuoteUpdate = new List<SBQQ__Quote__c>();

            // if (con.SBQQ__RenewalUpliftRate__c != null || con.LPCR_DateRevisionPrix__c == null){
            //     throw new CustomException('Ce devis n\'est éligible pour l\'uplift');
            // }
            // ' WHERE LPCR_IndexationConvenue__c = \'Non\' ';
            // ' AND SBQQ__RenewalUpliftRate__c = NULL ';
            // ' AND LPCR_DateRevisionPrix__c != NULL ';
            // ' AND LPCR_UpliftNow__c = False ';

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
                    LPCR_TypeAvenant__c = 'Amendement d\'indexation'
                )
            );

            if (lstQuoteUpdate.size() > 0) {
                update lstQuoteUpdate;
            }
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage() + ' ' + e.getStackTraceString());
        }
    }

    public class CustomException extends Exception {
    }
}
