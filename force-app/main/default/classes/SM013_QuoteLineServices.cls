/**
* @author Dario Correnti
* @date 19/05/2020
* @description Service class for QuoteLine
*/
public with sharing class SM013_QuoteLineServices {
    
    private static Map<String, Integer> billingPeriodMultiplier {
        get {
            if(billingPeriodMultiplier == null) {
                billingPeriodMultiplier = new Map<String, Integer>();
                billingPeriodMultiplier.put('Monthly', 1);
                billingPeriodMultiplier.put('Quarterly', 3);
                billingPeriodMultiplier.put('Semiannual', 6);
                billingPeriodMultiplier.put('Annual', 12);
            }
            return billingPeriodMultiplier;
        }
        
        set;
        
    }

    /*
    *    @description : this method check if any registration fee had been alredy applied for a given customer / nursery.
    *    @param List<SBQQ__QuoteLine__c> quoteLineList to process
    *    @returns void
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
    *    @description : this method check if any registration fee had been alredy applied for a given customer / nursery.
    *    @param List<SBQQ__QuoteLine__c> quoteLineList to process
    *    @returns void
    */
    public static void setBillThroughDateOverride (List<SBQQ__QuoteLine__c> quoteLineList) {

        PAD.logAllList('SM013_QuoteLineServices', 'setBillThroughDateOverride', 'quoteLineList', quoteLineList);

        Set<String> quoteIdSet = new Set<String>();

        for(SBQQ__QuoteLine__c quoteLine : quoteLineList) { 

                quoteIdSet.add(quoteLine.SBQQ__Quote__c);
        }
        
        Map<Id, SBQQ__Quote__c> quoteMap = new Map<Id, SBQQ__Quote__c>([Select SBQQ__StartDate__c, SBQQ__EndDate__c from SBQQ__Quote__c Where Id IN :quoteIdSet]);
        
        for(SBQQ__QuoteLine__c quoteLine : quoteLineList) {

            if (quoteLine.SBQQ__Quote__r.LPCR_InitAutoAvecDateDebut__c == false && 
                quoteLine.SBQQ__BillingFrequency__c != null && 
                quoteLine.SBQQ__BillingFrequency__c != 'Invoice Plan' && 
                quoteLine.SBQQ__HasConsumptionSchedule__c == false) {
            
                SBQQ__Quote__c quote = quoteMap.get(quoteLine.SBQQ__Quote__c);

                // Get right start date depending if Quote Line is empty
                Date rightStartDate = quoteLine.SBQQ__StartDate__c == null ? quote.SBQQ__StartDate__c : quoteLine.SBQQ__StartDate__c;
                Date rightEndDate = quoteLine.SBQQ__EndDate__c == null ? quote.SBQQ__EndDate__c : quoteLine.SBQQ__EndDate__c;         

                if (quoteLine.SBQQ__BillingFrequency__c == 'Monthly') {
                    quoteLine.LPCR_BillThroughDateOverride__c = UM005_DateUtility.lastDateOfMonth(rightStartDate);
                }
                else if (quoteLine.SBQQ__BillingFrequency__c == 'Quarterly') {
                    quoteLine.LPCR_BillThroughDateOverride__c = UM005_DateUtility.lastDayOfDatePeriod (rightStartDate, UM005_DateUtility.quarterlyMonths);
                }
                else if (quoteLine.SBQQ__BillingFrequency__c == 'Semiannual') {
                    quoteLine.LPCR_BillThroughDateOverride__c = UM005_DateUtility.lastDayOfDatePeriod (rightStartDate, UM005_DateUtility.semiannualMonths);
                }
                else if (quoteLine.SBQQ__BillingFrequency__c == 'Annual') {
                    quoteLine.LPCR_BillThroughDateOverride__c = UM005_DateUtility.lastDayOfYear(rightStartDate);
                }

                if (quoteLine.LPCR_BillThroughDateOverride__c > rightEndDate) {
                    quoteLine.LPCR_BillThroughDateOverride__c = rightEndDate;
                }

            }
        }

        PAD.logAllList('SM013_QuoteLineServices', 'setBillThroughDateOverride', 'quoteLineList', quoteLineList);

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
            if (quoteLine.LPCR_BillThroughDateOverride__c == null || 
                quoteLine.SBQQ__DefaultSubscriptionTerm__c == null || 
                quoteLine.SBQQ__ProrateMultiplier__c == null || 
                quoteLine.SBQQ__NetTotal__c == null || 
                quoteLine.SBQQ__NetTotal__c == 0) {
               // return;
               Continue;
            }
            
            // Billing Frequency Multiplier
            Integer bpMultiplier = billingPeriodMultiplier.get(quoteLine.SBQQ__BillingFrequency__c); // 6
            
            // Billable Unit Price Formula 
            // CPQ Formula has been used
            // Since we use NetTotal, Quantity is included in the Billable Unit Price 
            System.debug('quoteLine.SBQQ__ProrateMultiplier__c CPQ Calculation: '+ quoteLine.SBQQ__ProrateMultiplier__c);
            System.debug('quoteLine.SBQQ__NetTotal__c CPQ Calculation: '+ quoteLine.SBQQ__NetTotal__c);
            System.debug('quoteLine.SBQQ__DefaultSubscriptionTerm__c CPQ Calculation: '+ quoteLine.SBQQ__DefaultSubscriptionTerm__c);
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
            Decimal Discountvar = 0;
            
            // Assign the values to the quote line
            
            quoteLine.SBQQ__ProrateMultiplier__c = prorateMultiplier;
            quoteLine.LPCR_BillingMultiplier__c = billingMultiplier;
            quoteline.SBQQ__ProratedListPrice__c = quoteline.SBQQ__ListPrice__c * prorateMultiplier;
            quoteline.SBQQ__ProratedPrice__c = quoteline.SBQQ__ListPrice__c * prorateMultiplier;
            quoteline.SBQQ__RegularPrice__c = quoteline.SBQQ__SpecialPrice__c * prorateMultiplier;
    
            if (quoteline.SBQQ__Discount__c != null){
            Discountvar = quoteline.SBQQ__RegularPrice__c *(quoteline.SBQQ__Discount__c / 100);
            } 
            else if (quoteline.SBQQ__AdditionalDiscountAmount__c != null){
            Discountvar = quoteline.SBQQ__AdditionalDiscountAmount__c * prorateMultiplier;
            }
    
            quoteline.SBQQ__CustomerPrice__c = quoteline.SBQQ__RegularPrice__c - Discountvar;
            quoteLine.SBQQ__NetPrice__c = netUnitPrice;
    
           
            
                       
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
    public static void updateIndexationRemiseQuote(List<SBQQ__QuoteLine__c> quoteLineList,Map<Id,SBQQ__QuoteLine__c> newQuoteLineMap){
        //List<SBQQ__Quote__c> lstQuoteUpdate=new List<SBQQ__Quote__c>();
    
        List<SBQQ__QuoteLine__c> lstQuoteLineUpdate=new List<SBQQ__QuoteLine__c>();
        Map<Id,Decimal> mapQuoteIndexationMontant =new Map<Id,Decimal>();
        Map<Id,Id> mapQuoteInitialQuoteRenewal = new Map<Id,Id>();
        Map<Id,Decimal> mapAbonnementPrix = new Map<Id,Decimal>();
        Map<Id,Decimal> mapAbonnementMultiplier = new Map<Id,Decimal>();
        Set <Id> setQuoteOriginal=new Set <Id>();
        Map<id,id> quoteOriginalQLIAmendement = new Map<id,id> ();
        Map<String,Id> mapUniqueKeyQLIamendement=new Map<String,Id>();
        Map<String,Decimal> mapUniqueKeyQLIoriginal=new Map<String,Decimal>();
        Map<Id,String> mapUniqueKeyQLIamendementReverse = new Map<Id,String>();
        Map<id,Decimal> mapQuoteRemiseMontant =new Map<id,Decimal>();
        List<SBQQ__Quote__c> quoteListToUpdate=new List<SBQQ__Quote__c>();
        for(SBQQ__QuoteLine__c qli : quoteLineList){
            System.debug('#pdo this is type '+qli.LPCR_TypeDeDevis__c);
            System.debug('#pdo this is contrat devis '+qli.LPCR_MasterContrat__c);
            System.debug('##pdo this is quote '+qli.LPCR_QuoteOriginal__c);
            if(qli.SBQQ__RenewedSubscription__c != null){
                mapQuoteInitialQuoteRenewal.put(qli.Id,qli.SBQQ__RenewedSubscription__c);
            }
            if(qli.LPCR_TypeDeDevis__c=='Amendment'){
                setQuoteOriginal.add(qli.LPCR_QuoteOriginal__c);
                quoteOriginalQLIAmendement.put(qli.LPCR_QuoteOriginal__c,qli.Id);
                mapUniqueKeyQLIamendement.put(qli.LPCR_QuoteOriginal__c+qli.SBQQ__ProductCode__c+qli.SBQQ__Quantity__c ,qli.Id);
                mapUniqueKeyQLIamendementReverse.put(qli.Id,qli.LPCR_QuoteOriginal__c+qli.SBQQ__ProductCode__c+qli.SBQQ__Quantity__c );
            }
            if(qli.LPCR_TypeDeDevis__c == 'Quote' && qli.LPCR_Remise__c != 0 ){
                if(!mapQuoteRemiseMontant.containsKey(qli.SBQQ__Quote__c)){
                    mapQuoteRemiseMontant.put(qli.SBQQ__Quote__c,qli.LPCR_Remise__c);
                }else{
                    mapQuoteRemiseMontant.put(qli.SBQQ__Quote__c,mapQuoteRemiseMontant.get(qli.SBQQ__Quote__c)+qli.LPCR_Remise__c);
                    
                }
            }
            
        }
        //select QLI in orginal quotes 
        for(SBQQ__QuoteLine__c qli:[SELECT Id ,SBQQ__Quote__c  ,SBQQ__PriorQuantity__c,LPCR_IndexationCustom__c ,SBQQ__ProductCode__c,SBQQ__StartDate__c, SBQQ__EndDate__c,SBQQ__Quantity__c FROM SBQQ__QuoteLine__c where SBQQ__Quote__c IN :setQuoteOriginal]){
            System.debug('qli amendemnet id'+quoteOriginalQLIAmendement.get(qli.SBQQ__Quote__c));
            mapUniqueKeyQLIoriginal.put(qli.SBQQ__Quote__c+qli.SBQQ__ProductCode__c+qli.SBQQ__Quantity__c ,qli.LPCR_IndexationCustom__c);
        }
        System.debug('##Pdo this is map '+mapUniqueKeyQLIoriginal);
        System.debug('##Pdo this is map '+mapUniqueKeyQLIamendement);
        System.debug('##Pdo this is map '+setQuoteOriginal);
        for(SBQQ__QuoteLine__c qli : quoteLineList){
            if(qli.LPCR_TypeDeDevis__c=='Amendment'){
                lstQuoteLineUpdate.add(new SBQQ__QuoteLine__c (Id=qli.Id,LPCR_IndexationCustom__c=mapUniqueKeyQLIoriginal.get(mapUniqueKeyQLIamendementReverse.get(qli.ID))));
                //lstQuoteLineUpdate.add(new SBQQ__QuoteLine__c (Id=qli.Id,LPCR_IndexationCustom__c=100));
                //if cloned 
                if(qli.LPCR_Clone__c){
                    
                }
            }
            
        }
        System.debug('pdo this is remise montant '+mapQuoteRemiseMontant);
        System.debug('pdo this is list to update'+lstQuoteLineUpdate);
        //query data in abonnement 
        for(SBQQ__Subscription__c subs :[SELECT Id,SBQQ__CustomerPrice__c,SBQQ__ProrateMultiplier__c FROM SBQQ__Subscription__c where id IN : mapQuoteInitialQuoteRenewal.values()]){
            System.debug('pdo '+subs.SBQQ__CustomerPrice__c);
            if(subs.SBQQ__CustomerPrice__c != null){
                mapAbonnementPrix.put(subs.Id,subs.SBQQ__CustomerPrice__c);
            }
            if(subs.SBQQ__ProrateMultiplier__c != null){
                mapAbonnementMultiplier.put(subs.Id,subs.SBQQ__ProrateMultiplier__c);
            }
        }
        //loop in map quote line items 
        for(Id key :newQuoteLineMap.keySet() ){
            if(mapQuoteInitialQuoteRenewal.containsKey(key)){
                //(SBQQ__Uplift__c * ( SBQQ__RenewedSubscription__r.SBQQ__CustomerPrice__c / SBQQ__RenewedSubscription__r.SBQQ__ProrateMultiplier__c )) * SBQQ__ProrateMultiplier__c
            Decimal quotelineUplift=newQuoteLineMap.get(key).SBQQ__Uplift__c != null ? newQuoteLineMap.get(key).SBQQ__Uplift__c/100 : 0;
            Decimal renewalSubscriptionCustomerprice =mapAbonnementPrix.containsKey(mapQuoteInitialQuoteRenewal.get(key))? mapAbonnementPrix.get(mapQuoteInitialQuoteRenewal.get(key)) :0;
            Decimal renewalSubscriptionmultiplier=mapAbonnementMultiplier.containsKey(mapQuoteInitialQuoteRenewal.get(key))? mapAbonnementMultiplier.get(mapQuoteInitialQuoteRenewal.get(key)) :0;
            Decimal quotelineProrate=newQuoteLineMap.get(key).SBQQ__ProrateMultiplier__c != null ? newQuoteLineMap.get(key).SBQQ__ProrateMultiplier__c : 0;
            lstQuoteLineUpdate.add(new  SBQQ__QuoteLine__c(id=key,LPCR_IndexationCustom__c=(quotelineUplift *renewalSubscriptionCustomerprice/ renewalSubscriptionmultiplier) *quotelineProrate));
            }
            
        }
        //update quote 
        for(Id key : mapQuoteRemiseMontant.keySet()){
            quoteListToUpdate.add(new SBQQ__Quote__c(id=key,LPCR_RemiseCustom__c=mapQuoteRemiseMontant.get(key)));
        }
        if(quoteListToUpdate.size() > 0){
            update quoteListToUpdate;
        }
        if(lstQuoteLineUpdate.size() > 0 ){
            update lstQuoteLineUpdate;
        }
        
        
        
    }
    public static void updateRemiseQuote(Map<Id,SBQQ__QuoteLine__c> oldQuoteLineMap, Map<Id,SBQQ__QuoteLine__c> newQuoteLineMap){
        Map<id,Decimal> mapQuoteRemiseMontant =new Map<id,Decimal>();
        List<SBQQ__Quote__c> quoteListToUpdate=new List<SBQQ__Quote__c>();
        List<SBQQ__Quote__c> quoteListUnmatch=new List<SBQQ__Quote__c>();
        Map<id,Decimal> mapQuoteRemiseMontantDevis =new Map<id,Decimal>();
        for(Id key :newQuoteLineMap.keySet() ){
            System.debug('##Pdo this is qli type '+newQuoteLineMap.get(key).LPCR_TypeDeDevis__c);
            System.debug('##Pdo this is qli type '+newQuoteLineMap.get(key).id);
            if(newQuoteLineMap.get(key).LPCR_Remise__c != oldQuoteLineMap.get(key).LPCR_Remise__c && newQuoteLineMap.get(key).LPCR_Clone__c &&newQuoteLineMap.get(key).LPCR_TypeDeDevis__c=='Amendment' ){
                if(!mapQuoteRemiseMontant.containsKey(newQuoteLineMap.get(key).SBQQ__Quote__c)){
                    mapQuoteRemiseMontant.put(newQuoteLineMap.get(key).SBQQ__Quote__c,newQuoteLineMap.get(key).LPCR_Remise__c);
                }else{
                    mapQuoteRemiseMontant.put(newQuoteLineMap.get(key).SBQQ__Quote__c,mapQuoteRemiseMontant.get(newQuoteLineMap.get(key).SBQQ__Quote__c)+newQuoteLineMap.get(key).LPCR_Remise__c);
                    
                }
            }
            //for quote devis 
            if(newQuoteLineMap.get(key).LPCR_Remise__c != oldQuoteLineMap.get(key).LPCR_Remise__c && newQuoteLineMap.get(key).LPCR_TypeDeDevis__c=='Quote' ){
                if(!mapQuoteRemiseMontantDevis.containsKey(newQuoteLineMap.get(key).SBQQ__Quote__c)){
                    mapQuoteRemiseMontantDevis.put(newQuoteLineMap.get(key).SBQQ__Quote__c,newQuoteLineMap.get(key).LPCR_Remise__c -oldQuoteLineMap.get(key).LPCR_Remise__c );
                }else{
                    mapQuoteRemiseMontantDevis.put(newQuoteLineMap.get(key).SBQQ__Quote__c,mapQuoteRemiseMontantDevis.get(newQuoteLineMap.get(key).SBQQ__Quote__c)+(newQuoteLineMap.get(key).LPCR_Remise__c-oldQuoteLineMap.get(key).LPCR_Remise__c));
                    
                }
            }
        }
        //get existing quote
        for(SBQQ__Quote__c quot :[Select id, LPCR_RemiseCustom__c from SBQQ__Quote__c where id IN:mapQuoteRemiseMontantDevis.keyset() ]){
            //to add verif map 
        	quoteListToUpdate.add(new SBQQ__Quote__c(id=quot.Id, LPCR_RemiseCustom__c=quot.LPCR_RemiseCustom__c+mapQuoteRemiseMontantDevis.get(quot.Id)));
    	}
        System.debug('##pdot quore to update '+quoteListToUpdate);
        //update quote 
        for(Id key : mapQuoteRemiseMontant.keySet()){
            quoteListToUpdate.add(new SBQQ__Quote__c(id=key,LPCR_RemiseCustom__c=mapQuoteRemiseMontant.get(key)));
        }
        if(quoteListToUpdate.size() > 0){
            update quoteListToUpdate;
        }
        
        
    }
     //method to update contacts on QLI
     public static void updateContactQLI(Map<Id,SBQQ__QuoteLine__c> newQuoteLineMap){
        List<id> lstQuote=new List<id> () ;  
        Map<String,Id> mapContactTypeQuote =new Map<String,Id>();
        List<SBQQ__QuoteLine__c> lstQLIUpdate=new List<SBQQ__QuoteLine__c>();
        for(SBQQ__QuoteLine__c qli:newQuoteLineMap.values()){
            lstQuote.add(qli.SBQQ__Quote__c );
        }
        for(SBQQ__Quote__c eachNewQuote :[Select id,LPCR_ContactFacturation__c,LPCR_ContactPrincipal__c ,LPCR_ContactInscriptions__c from SBQQ__Quote__c  where Id IN:lstQuote]){
            if(eachNewQuote.LPCR_ContactFacturation__c != null){
                mapContactTypeQuote.put(eachNewQuote.Id+'-'+'Fac',eachNewQuote.LPCR_ContactFacturation__c );
            }
            if(eachNewQuote.LPCR_ContactInscriptions__c != null){
                mapContactTypeQuote.put(eachNewQuote.Id+'-'+'Insc',eachNewQuote.LPCR_ContactInscriptions__c );
            }
            if(eachNewQuote.LPCR_ContactPrincipal__c != null){
                mapContactTypeQuote.put(eachNewQuote.Id+'-'+'Primary',eachNewQuote.LPCR_ContactPrincipal__c );
            }
        }
        
        for(SBQQ__QuoteLine__c qli:newQuoteLineMap.values()){
            SBQQ__QuoteLine__c qli2=new SBQQ__QuoteLine__c(Id=qli.ID);
            if(mapContactTypeQuote.containsKey(qli.SBQQ__Quote__c+'-'+'Fac')){
            qli2.LPCR_ContactFacturation__c=mapContactTypeQuote.get(qli.SBQQ__Quote__c+'-'+'Fac');
            }
            //
            if(mapContactTypeQuote.containsKey(qli.SBQQ__Quote__c+'-'+'Insc')){
            qli2.LPCR_ContactInscriptions__c=mapContactTypeQuote.get(qli.SBQQ__Quote__c+'-'+'Insc');
         
            }
            //
            if(mapContactTypeQuote.containsKey(qli.SBQQ__Quote__c+'-'+'Primary')){
            qli2.LPCR_PrimaryContact__c=mapContactTypeQuote.get(qli.SBQQ__Quote__c+'-'+'Primary');
            }
            lstQLIUpdate.add(qli2);
        }
       if(lstQLIUpdate.size() > 0){
        update lstQLIUpdate;
        }
        
    }

    // PRA 29/07/2021  IS-2518
    public static void setContactOnDevis(List<SBQQ__QuoteLine__c> newQuoteLineList){
        List<SBQQ__Quote__c> quoteToUpdate = new List<SBQQ__Quote__c>();
        for(Integer i = 0 ; i<newQuoteLineList.size();i++){
            if(Label.LPCR_Amendment.equals(newQuoteLineList[i].LPCR_TypeDeDevis__c) && (newQuoteLineList[i].LPCR_ContactPrincipal__c <> null || newQuoteLineList[i].LPCR_ContactInscriptions__c <> null ||newQuoteLineList[i].LPCR_ContactFacturation__c <> null)){
                quoteToUpdate.add(new SBQQ__Quote__c(
                    id=newQuoteLineList[i].SBQQ__Quote__c,
                    LPCR_ContactFacturation__c=newQuoteLineList[i].LPCR_ContactFacturation__c,
                    LPCR_ContactInscriptions__c=newQuoteLineList[i].LPCR_ContactInscriptions__c,
                    SBQQ__PrimaryContact__c=newQuoteLineList[i].LPCR_ContactPrincipal__c
                	)
				);
            }
            
        }
        if(quoteToUpdate.size()>0)
            update quoteToUpdate;
    }
}