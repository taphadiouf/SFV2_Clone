public with sharing class UM006_ContractAmender {
    public static boolean allowInsert = false;
    public WRP001_QuoteModel load(String contractId) {
        // allowInsert set to true in order to bypass custom validation rule on 'LPCR_Creation_conforme__c' field
        allowInsert = true;
        String quoteJSON = SBQQ.ServiceRouter.load('SBQQ.ContractManipulationAPI.ContractAmender', contractId, null);
        allowInsert = false;
        return (WRP001_QuoteModel) JSON.deserialize(quoteJSON, WRP001_QuoteModel.class);
    }
}