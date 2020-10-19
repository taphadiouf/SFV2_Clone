/**
* @author Dario Correnti
* @date 19/05/2020
* @description Service class for QuoteLine
*/
public with sharing class SM013_QuoteLineServices {
    
    /*
	*	@description : this method check if any registration fee had been alredy applied for a given customer / nursery.
	*	@param List<SBQQ__QuoteLine__c> quoteLineList to process
    *	@returns void
    */
    public static void checkExistingRegistrationFee (List<SBQQ__QuoteLine__c> quoteLineList) {
        PAD.log('SM013_QuoteLineServices', 'checkExistingRegistrationFee', 'start method with quoteLineList: ' + quoteLineList.size());
        Set<Id> quoteIds = new Set<Id>();
        Set<Id> productIds = new Set<Id>();
        Set<Id> customerAccountIds = new Set<Id>();
        Map<String, Asset> assetsByCustomerNurseryYear = new Map<String, Asset> ();

        for (SBQQ__QuoteLine__c ql : quoteLineList) {
            quoteIds.add(ql.SBQQ__Quote__c);
        }

        // Load QL related data
        Map<Id, SBQQ__Quote__c> quotesById = new Map<Id, SBQQ__Quote__c> ([SELECT Id, LPCR_TypeCreche__c, SBQQ__Account__c, LPCR_Creche__c, SBQQ__Status__c FROM SBQQ__Quote__c WHERE Id IN :quoteIds]);
        for (SBQQ__QuoteLine__c ql : quoteLineList) {
            if (quotesById.get(ql.SBQQ__Quote__c).LPCR_TypeCreche__c != 'MAC' 
                || quotesById.get(ql.SBQQ__Quote__c).SBQQ__Status__c != 'Draft' 
                || ql.SBQQ__ProductCode__c != Label.LPCR_RegistrationFeeMac) {
                    continue;
            }
            customerAccountIds.add(quotesById.get(ql.SBQQ__Quote__c).SBQQ__Account__c);
        }
        PAD.log('SM013_QuoteLineServices', 'checkExistingRegistrationFee', 'customerAccountIds: ' + customerAccountIds);

        // Load all Registration Fees for current customers
        List<Asset> assets = [SELECT Id, AccountId, ProductCode, SBQQ__QuoteLine__c, SBQQ__QuoteLine__r.SBQQ__Quote__c,
            SBQQ__QuoteLine__r.SBQQ__Quote__r.LPCR_Creche__c, SBQQ__QuoteLine__r.SBQQ__EffectiveStartDate__c FROM Asset WHERE AccountId IN :customerAccountIds AND ProductCode = :Label.LPCR_RegistrationFeeMac];

        PAD.log('SM013_QuoteLineServices', 'checkExistingRegistrationFee', 'assets: ' + assets);
        for (Asset a : assets) {
            String assetKey = a.AccountId + '-' 
                + a.SBQQ__QuoteLine__r.SBQQ__Quote__r.LPCR_Creche__c + '-' 
                + a.SBQQ__QuoteLine__r.SBQQ__EffectiveStartDate__c.year();

            assetsByCustomerNurseryYear.put (assetKey, a);
        }
        PAD.log('SM013_QuoteLineServices', 'checkExistingRegistrationFee', 'assetsByCustomerNurseryYear: ' + assetsByCustomerNurseryYear.keySet());

        // Check if any QL
        for (SBQQ__QuoteLine__c ql : quoteLineList) {
            if (quotesById.get(ql.SBQQ__Quote__c).LPCR_TypeCreche__c != 'MAC' 
                || quotesById.get(ql.SBQQ__Quote__c).SBQQ__Status__c != 'Draft' 
                || ql.SBQQ__ProductCode__c != Label.LPCR_RegistrationFeeMac) {
                    continue;
            }

            String relatedAssetKey = quotesById.get(ql.SBQQ__Quote__c).SBQQ__Account__c + '-' 
                + quotesById.get(ql.SBQQ__Quote__c).LPCR_Creche__c + '-' 
                + ql.SBQQ__EffectiveStartDate__c.year();
                
            PAD.log('SM013_QuoteLineServices', 'checkExistingRegistrationFee', 'relatedAssetKey: ' + relatedAssetKey);

            if (assetsByCustomerNurseryYear.containsKey(relatedAssetKey)) {
                ql.addError(Label.LPCR_RegistrationFeeErrorMessage);
            }
        }
    }
    /*
	*	@description : 
	*	@param List<SBQQ__QuoteLine__c> quoteLineList to process
    *	@returns void
    */
    public static void setStartAndEndDates(List<SBQQ__QuoteLine__c> quoteLineList){
    
        Id quoteReferencementRT = EM003_RecordTypeEntity.getRecTypeIdByObjectAndName(Label.LPCR_Quote, Label.LPCR_Referencement);
        for(SBQQ__QuoteLine__c eachQuoteLine : quoteLineList){
            if(eachQuoteLine.SBQQ__Quote__r.RecordTypeId == quoteReferencementRT && eachQuoteLine.SBQQ__Quote__r.SBQQ__Type__c != Label.LPCR_Amendment){
                //Is the QL supposed to start this year? already started?
                if(eachQuoteLine.LPCR_DateDebut__c != null && (eachQuoteLine.LPCR_DateDebut__c.year() <= eachQuoteLine.SBQQ__Quote__r.SBQQ__StartDate__c.year())){
                    //Is the QL still alive this year?
                    if(eachQuoteLine.LPCR_DateFin__c != null && (eachQuoteLine.LPCR_DateFin__c.year() >= eachQuoteLine.SBQQ__Quote__r.SBQQ__StartDate__c.year())){
                        //SBQQEndDate logic
                        if(eachQuoteLine.LPCR_DateFin__c.year() < eachQuoteLine.SBQQ__StartDate__c.year()){
                            eachQuoteLine.SBQQ__EndDate__c = eachQuoteLine.LPCR_DateFin__c;
                        }
                        else{
                            eachQuoteLine.SBQQ__EndDate__c = Date.valueOf(''+ eachQuoteLine.SBQQ__StartDate__c.year() + '-12-31');
                        }
                        //SBQQStartDate logic
                        if(eachQuoteLine.LPCR_DateDebut__c.year() == eachQuoteLine.SBQQ__Quote__r.SBQQ__StartDate__c.year()){
                            eachQuoteLine.SBQQ__StartDate__c = eachQuoteLine.LPCR_DateDebut__c;
                        }
                    }               
                    else{
                        //If the QL won't still alive this year set quantity to 0
                        eachQuoteLine.SBQQ__Quantity__c = 0;
                    }
                }       
                else{
                    //If the QL won't start this year or it is not already started, set HoldBilling to true
                    eachQuoteLine.LPCR_HoldBilling__c = 'true'; //Picklist value
                }
            }
        }
    }
}