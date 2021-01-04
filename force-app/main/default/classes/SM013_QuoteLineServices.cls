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

    public static void calculateQuoteLine (List<SBQQ__QuoteLine__c> quoteLineList) {
        
            
        // Query Quote Info
        Set<String> quoteIdSet = new Set<String>();
        for(SBQQ__QuoteLine__c quoteLine : quoteLineList) {
            quoteIdSet.add(quoteLine.SBQQ__Quote__c);
        }
        
        Map<Id, SBQQ__Quote__c> quoteMap = new Map<Id, SBQQ__Quote__c>([Select SBQQ__StartDate__c, SBQQ__EndDate__c from SBQQ__Quote__c Where Id IN :quoteIdSet]);
        
        for(SBQQ__QuoteLine__c quoteLine : quoteLineList) {
            
            //BillingCPQFormulaTriggerHandler.calculateQuoteLine(quoteMap.get(quoteLine.SBQQ__Quote__c), quoteLine);
            SBQQ__Quote__c quote = quoteMap.get(quoteLine.SBQQ__Quote__c);
            
            // If BillThroughDate__c is not set on the quote line
            // Do not proceed further
            if (quoteLine.LPCR_BillThroughDateOverride__c == null || quoteLine.SBQQ__NetTotal__c == 0) {
                return;
            }
            
            // Billing Frequency Multiplier
            Integer bpMultiplier = billingPeriodMultiplier.get(quoteLine.SBQQ__BillingFrequency__c); // 6
            
            // Billable Unit Price Formula 
            // CPQ Formula has been used
            // Since we use NetTotal, Quantity is included in the Billable Unit Price 
            Decimal billableUnitPriceWithQuantity = (quoteLine.SBQQ__NetTotal__c * bpMultiplier) / (quoteLine.SBQQ__ProrateMultiplier__c * quoteLine.SBQQ__DefaultSubscriptionTerm__c);
            System.debug('billableUnitPriceWithQuantity: '+ billableUnitPriceWithQuantity);
            
    
            // NetPrice to NetTotal Ratio
            // This Ratio will be used to determine billable unit price without the quantity
            Decimal netPriceTotalRatio = quoteLine.SBQQ__NetTotal__c / quoteLine.SBQQ__NetPrice__c;
            System.debug('netPriceTotalRatio: '+ netPriceTotalRatio);
            
    
            // Billable Unit Price without the quantity
            Decimal billableUnitPrice = billableUnitPriceWithQuantity / netPriceTotalRatio;
            billableUnitPrice = billableUnitPrice.setScale(2);
            System.debug('billableUnitPrice: '+ billableUnitPrice);
            
    
            // Get right start date depending if Quote Line is empty
            Date rightStartDate = quoteLine.SBQQ__StartDate__c == null ? quote.SBQQ__StartDate__c : quoteLine.SBQQ__StartDate__c;
            Date rightEndDate = quoteLine.SBQQ__EndDate__c == null ? quote.SBQQ__EndDate__c : quoteLine.SBQQ__EndDate__c;

            // Get the billing multiplier so that final NetUnitPrice can be calculated
            Decimal billingMultiplier = getBillingMultiplier(rightStartDate, quoteLine.LPCR_BillThroughDateOverride__c, rightEndDate, bpMultiplier);
            Decimal netUnitPrice = billableUnitPrice * billingMultiplier;
            System.debug('NetUnitPrice -> (billableUnitPrice * billingMultiplier): '+ netUnitPrice);
            
            
            // Calculate Prorate Multiplier by reversing the Billable Unit Price formula
            billableUnitPriceWithQuantity = billableUnitPrice * netPriceTotalRatio;
            Decimal prorateMultiplier = ((netUnitPrice * netPriceTotalRatio) * bpMultiplier) / (billableUnitPriceWithQuantity * quoteLine.SBQQ__DefaultSubscriptionTerm__c);
            System.debug('Updated SBQQ__ProrateMultiplier__c: '+ prorateMultiplier);
            
    
            // Assign the values to the quote line
            quoteLine.SBQQ__NetPrice__c = netUnitPrice;
            quoteLine.SBQQ__ProrateMultiplier__c = prorateMultiplier;
            quoteLine.LPCR_BillingMultiplier__c = billingMultiplier;
    	}
        
    }    
    
    public static Decimal getBillingMultiplier(Date quoteStartDate, Date billThroughDate, Date quoteEndDate, Integer bpMultiplier) {
        
        // Initialize the start date to quote start date
        Date startDate = quoteStartDate;

        // Initialize the end date to quote end date
        Date endDate = billThroughDate;

        // End product of this function
        Decimal billingMultiplier = 0;


        // While startDate is less than quote end date
        // Split the days into service periods (Similar to Invoice Line Start and End Date)
        // And find the multiplier for each service period
        while(startDate < quoteEndDate) {
            System.debug('startDate: '+ startDate + ' | endDate:' + endDate);


            // Get the billingMultiplier for the service period based on the start date, end date
            // and bpMultiplier
            billingMultiplier += getPerPeriodMultiplier(startDate, endDate, bpMultiplier);
            System.debug('billingMultiplier: '+ billingMultiplier);

            // Set the start date to end date + 1 day
            startDate = endDate + 1;

            // Determine the end date by adding bpMultiplier months to the start date
            // addDays(-1) used because if start date is 03/15/2020
            // end date should be 14th of the month not 15th
            endDate = startDate.addMonths(bpMultiplier).addDays(-1);


            // If the end date we calculated is greater than the quote end date
            // Then set the end date to quote end date
            if(endDate > quoteEndDate) {
                endDate = quoteEndDate;
            }
        }

        return billingMultiplier;

    }

    public static Decimal getPerPeriodMultiplier(Date startDate, Date endDate, Integer bpMultiplier) {

        // CPQ Formula assumes 365/12 days in every month
        Decimal denominator = 365 / 12.0;


        // If start date and end date gives full service period without proration
        // Then return multiplier 1
        if((startDate.addMonths(bpMultiplier).addDays(-1)).isSameDay(endDate)) {
            System.debug('perPeriodMultiplier: '+ 1);
            return 1;
        } else { // Else calculate the prorated multiplier
            Integer times = bpMultiplier - 1;
            System.debug('times: '+ times);


            // Calculate number of full months that can be fit between start and end date
            Date indexDate = startDate.addMonths(times).addDays(-1);
            while(times > 0 && startDate.addMonths(times).addDays(-1) > endDate) {
               System.debug('indexDate: '+ indexDate);
               times -= 1;
               indexDate = startDate.addMonths(times).addDays(-1);
            }

            // If there are any days left after the fit then calculate the prorated multiplier 
            Decimal perPeriodMultiplier = 0; 
            if(!(indexDate).isSameDay(endDate)) {
                Decimal daysBetween = indexDate.daysBetween(endDate);
                System.debug('daysBetween: '+ daysBetween);
                perPeriodMultiplier += daysBetween / denominator;
            }
            

            // times: Number of full months that is fit
            perPeriodMultiplier = (perPeriodMultiplier + times) / bpMultiplier;
            System.debug('perPeriodMultiplier: '+ perPeriodMultiplier);

            return perPeriodMultiplier;
        }
    }
}