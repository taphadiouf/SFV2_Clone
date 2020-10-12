public with sharing class UM006_ContractAmender {
    public WRP001_QuoteModel load(String contractId) {
        String quoteJSON = SBQQ.ServiceRouter.load('SBQQ.ContractManipulationAPI.ContractAmender', contractId, null);
        return (WRP001_QuoteModel) JSON.deserialize(quoteJSON, WRP001_QuoteModel.class);
    }
}