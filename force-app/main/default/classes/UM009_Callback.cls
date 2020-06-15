global with sharing class UM009_Callback implements SBQQ.CalculateCallback {
  global void callback(String quoteJSON){
    SBQQ.ServiceRouter.save('SBQQ.QuoteAPI.QuoteSaver', quoteJSON);       
  }
}