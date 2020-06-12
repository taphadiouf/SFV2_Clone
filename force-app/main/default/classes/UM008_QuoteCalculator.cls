public with sharing class UM008_QuoteCalculator {     

  public void calculate(WRP001_QuoteModel quote, String callbackClass) {
    QuoteCalculatorContext ctx = new QuoteCalculatorContext(quote, callbackClass);
    SBQQ.ServiceRouter.load('SBQQ.QuoteAPI.QuoteCalculator', null, JSON.serialize(ctx));    
  }    

  private class QuoteCalculatorContext {        
    private WRP001_QuoteModel quote;             //The quote and callbackClass properties are called in the API code by the exact names seen here.
    private String callbackClass;         //Altering these property names will cause calculator API calls to fail.

    private QuoteCalculatorContext(WRP001_QuoteModel quote, String callbackClass) {
      this.quote = quote;            
      this.callbackClass = callbackClass;        
    }
  } 
}