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
}