public with sharing class UM007_QuoteReader {   
    public WRP001_QuoteModel read(String quoteId) {
        String quoteJSON = SBQQ.ServiceRouter.read('SBQQ.QuoteAPI.QuoteReader', quoteId);
        return (WRP001_QuoteModel) JSON.deserialize(quoteJSON, WRP001_QuoteModel.class);
    }
}