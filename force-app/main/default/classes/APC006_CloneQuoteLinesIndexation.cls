public class APC006_CloneQuoteLinesIndexation {
    //a copy of class APC006_CloneQuoteLines
    //added creche to VR
    public static Boolean cloneAndResetQL(Id quoteId, Decimal tmpRate, Date tmpDate){
        //Map (existing quote line id => Quote line record)
        Map<Id,SBQQ__QuoteLine__c> idToQuoteLineMap;

        //Do not proceed action method if there's an error in the constructor
        Boolean hasError = false;

        // Throw an error if one of the required parameters is null
        if (String.isBlank(quoteId)) {
           
            return false;
        }
        if (quoteId != null) {
            idToQuoteLineMap = new Map<Id,SBQQ__QuoteLine__c> ();

            String query = 'SELECT LPCR_Region__c,LPCR_Creche__c,  SBQQ__Quote__r.SBQQ__Type__c, SBQQ__UpgradedSubscription__r.SBQQ__NetPrice__c,SBQQ__UpgradedSubscription__r.SBQQ__CustomerPrice__c, SBQQ__UpgradedSubscription__r.SBQQ__RegularPrice__c,         SBQQ__AdditionalDiscount__c,        SBQQ__VolumeDiscount__c,        SBQQ__UpliftAmount__c,        SBQQ__Uplift__c,        SBQQ__UpgradedSubscription__c,        SBQQ__UpgradedQuantity__c,        SBQQ__UpgradedAsset__c,        SBQQ__UnproratedNetPrice__c,        SBQQ__UnitCost__c,        SBQQ__TotalDiscountAmount__c,        SBQQ__TotalDiscountRate__c,        SBQQ__TermDiscountTier__c,        SBQQ__TermDiscountSchedule__c,        SBQQ__TermDiscount__c,        SBQQ__TaxCode__c,        SBQQ__Taxable__c,        SBQQ__SubscriptionType__c,        SBQQ__SubscriptionTerm__c,        SBQQ__SubscriptionPricing__c,        SBQQ__SubscribedAssetIds__c,        SBQQ__StartDate__c,        SBQQ__SpecialPriceType__c,        SBQQ__SpecialPriceDescription__c,        SBQQ__SpecialPrice__c,        SBQQ__Source__c,        SBQQ__SegmentLabel__c,        SBQQ__SegmentKey__c,        SBQQ__SegmentIndex__c,        SBQQ__RequiredBy__c,        SBQQ__RenewedSubscription__c,        SBQQ__RenewedAsset__c,        SBQQ__Renewal__c,        SBQQ__RegularPrice__c,        SBQQ__RegularTotal__c,        Id,        SBQQ__Quote__c,        SBQQ__Quantity__c,        SBQQ__ProrateMultiplier__c,        SBQQ__ProratedPrice__c,        SBQQ__ProratedListPrice__c,        SBQQ__ProductSubscriptionType__c,        SBQQ__ProductOption__c,        SBQQ__ProductName__c,        SBQQ__ProductFamily__c,        SBQQ__ListTotal__c,        SBQQ__PartnerTotal__c,        SBQQ__PartnerDiscount__c,        SBQQ__PackageTotal__c,        SBQQ__ProductCode__c,        SBQQ__Product__c,        SBQQ__PriorQuantity__c,        SBQQ__PricingMethodEditable__c,        SBQQ__PricingMethod__c,        SBQQ__PriceEditable__c,        SBQQ__Dimension__c,        SBQQ__PricebookEntryId__c,        SBQQ__PreviousSegmentUplift__c,        SBQQ__PreviousSegmentPrice__c,        SBQQ__SubscriptionTargetPrice__c,        SBQQ__SubscriptionScope__c,        SBQQ__SubscriptionCategory__c,        SBQQ__SubscriptionBase__c,        SBQQ__SubscriptionPercent__c,        SBQQ__PartnerPrice__c,        SBQQ__PackageProductDescription__c,        SBQQ__PackageProductCode__c,        SBQQ__PackageListTotal__c,        SBQQ__PackageCost__c,        SBQQ__Bundle__c,        SBQQ__OriginalUnitCost__c,        SBQQ__OriginalQuoteLineId__c,        SBQQ__BundledQuantity__c,        SBQQ__OriginalPrice__c,        SBQQ__OptionType__c,        SBQQ__OptionLevel__c,        SBQQ__OptionDiscountAmount__c,        SBQQ__OptionDiscount__c,        SBQQ__Optional__c,        SBQQ__Number__c,        SBQQ__NonPartnerDiscountable__c,        SBQQ__NonDiscountable__c,        SBQQ__NetPrice__c,        SBQQ__NetTotal__c,        SBQQ__MinimumPrice__c,        SBQQ__MaximumPrice__c,        SBQQ__MarkupAmount__c,        SBQQ__MarkupRate__c,        SBQQ__Markup__c,        SBQQ__ListPrice__c,        Name,        SBQQ__Incomplete__c,        SBQQ__Hidden__c,        SBQQ__HasConsumptionSchedule__c,        SBQQ__Guidance__c,        SBQQ__Group__c,        SBQQ__GrossProfit__c,        SBQQ__GenerateContractedPrice__c,        SBQQ__Favorite__c,        SBQQ__Existing__c,        SBQQ__EndDate__c,        SBQQ__EffectiveSubscriptionTerm__c,        SBQQ__EffectiveStartDate__c,        SBQQ__EffectiveQuantity__c,        SBQQ__EarliestValidAmendmentStartDate__c,        SBQQ__EffectiveEndDate__c,        SBQQ__DynamicOptionId__c,        SBQQ__DistributorDiscount__c,        SBQQ__DiscountTier__c,        SBQQ__DiscountScheduleType__c,        SBQQ__DiscountSchedule__c,        SBQQ__Description__c,        IsDeleted,        SBQQ__DefaultSubscriptionTerm__c,        SBQQ__Discount__c,        SBQQ__AdditionalDiscountAmount__c,        SBQQ__AdditionalQuantity__c,        SBQQ__AllowAssetRefund__c,        SBQQ__BatchQuantity__c,        blng__BillableUnitPrice__c,        SBQQ__Bundled__c,        SBQQ__BlockPrice__c,        SBQQ__BillingType__c,        SBQQ__BillingFrequency__c,        SBQQ__CarryoverLine__c,        SBQQ__ChargeType__c,        SBQQ__ComponentCost__c,        SBQQ__ComponentDiscountedByPackage__c,        SBQQ__ComponentUpliftedByPackage__c,        SBQQ__ComponentSubscriptionScope__c,        SBQQ__ComponentTotal__c,        SBQQ__ComponentListTotal__c,        SBQQ__ComponentVisibility__c,        SBQQ__CompoundDiscountRate__c,        SBQQ__ConfigurationRequired__c,        SBQQ__ContractedPrice__c,        SBQQ__Cost__c,        CreatedById,        SBQQ__CostEditable__c,        CreatedDate,        SBQQ__CustomerTotal__c,        SBQQ__CustomerPrice__c ,LPCR_RemiseSum__c ';

            query +=  ' FROM SBQQ__QuoteLine__c WHERE SBQQ__Quote__c = :quoteId  ORDER BY Name';
            List<SBQQ__QuoteLine__c> targetQLList = Database.query(query);
            if(targetQLList != null && targetQLList.size()>0){
                for (SBQQ__QuoteLine__c ql:targetQLList) {
                    idToQuoteLineMap.put(ql.Id, ql);
            }
            }    
        }
        if(idToQuoteLineMap.size() == 0){
            return false;
        }

        SBQQ.TriggerControl.disable();
        if (hasError) return false;
        Savepoint sp = Database.setSavepoint();
        // Map : origin Id => cloner Quote Line record
        Map<Id,SBQQ__QuoteLine__c> originIdsToclonedQLMap = new Map<Id, SBQQ__QuoteLine__c>();
       
        SBQQ__QuoteLine__c currentQL;
        // Clone every quote line
        for (SBQQ__QuoteLine__c ql: idToQuoteLineMap.values()) {
                currentQL = ql.clone(false, true, false, false);
                currentQL.SBQQ__PriorQuantity__c = null;
                currentQL.SBQQ__UpgradedSubscription__c = null;
                currentQL.SBQQ__UpgradedAsset__c = null;
                currentQL.SBQQ__UpgradedQuantity__c = null;
                currentQL.SBQQ__Existing__c = false;
                currentQL.LPCR_Creche__c=ql.LPCR_Creche__c;
                currentQL.LPCR_Region__c=ql.LPCR_Region__c; 
                //customer price unprorated
                Decimal customerpriceunprorated=ql.SBQQ__CustomerPrice__c /ql.SBQQ__ProrateMultiplier__c;
                currentQL.SBQQ__ListPrice__c = customerpriceunprorated+(customerpriceunprorated*( tmpRate/100));
                if(ql.SBQQ__AdditionalDiscountAmount__c != null )currentQL.SBQQ__AdditionalDiscountAmount__c=0;
                if(ql.SBQQ__Discount__c != null )currentQL.SBQQ__Discount__c=0;
            	currentQL.LPCR_IndexationQuote__c  = true;
                currentQL.SBQQ__Uplift__c = tmpRate;
                currentQL.LPCR_IndexationCustom__c =customerpriceunprorated*( tmpRate/100);
                if(currentQL.SBQQ__Number__c != null){
                    currentQL.SBQQ__Number__c = ql.SBQQ__Number__c + 1000;
                }
                originIdsToclonedQLMap.put(ql.Id, currentQL);
                ql.SBQQ__Quantity__c = 0;
              

        }
        // Insert the new cloned QL records, we will update their requiredby fields later in this code
        try {
            insert originIdsToclonedQLMap.values();
            
           
        } catch (Exception ex) {
            System.debug('## ex '+ex.getMessage());
            Database.rollback(sp);
            return false;
        }

        // get consumption schedule
        Map<String,SBQQ__QuoteLineConsumptionSchedule__c> clonedQLConsumptionScheduleMap = new Map<String,SBQQ__QuoteLineConsumptionSchedule__c>();
        for(SBQQ__QuoteLineConsumptionSchedule__c qlCS : [SELECT Id, Name, SBQQ__QuoteLine__c, SBQQ__BillingTermUnit__c, SBQQ__BillingTerm__c, SBQQ__Category__c, SBQQ__ConsumptionSchedule__c, SBQQ__Description__c, SBQQ__MatchingAttribute__c, SBQQ__RatingMethod__c, SBQQ__Type__c, SBQQ__UnitOfMeasure__c  
                                                        FROM SBQQ__QuoteLineConsumptionSchedule__c 
                                                        WHERE SBQQ__QuoteLine__c IN: originIdsToclonedQLMap.keySet()]){
            if(originIdsToclonedQLMap.containsKey(qlCS.SBQQ__QuoteLine__c)){
                //ENTER HERE
                SBQQ__QuoteLineConsumptionSchedule__c newQLCS = qlCS.clone(false, true, false, false);
                newQLCS.SBQQ__QuoteLine__c = originIdsToclonedQLMap.get(qlCS.SBQQ__QuoteLine__c).Id;
                clonedQLConsumptionScheduleMap.put(qlCS.id,newQLCS);
            }            
        }
        
        try {
            insert clonedQLConsumptionScheduleMap.values();
           
        } catch (Exception ex) {
            //ENTER HERE
             Database.rollback(sp);
            return false;
        }
        
        List<SBQQ__QuoteLineConsumptionRate__c> clonedQLConsumptionRateList = new List<SBQQ__QuoteLineConsumptionRate__c>();
        for(SBQQ__QuoteLineConsumptionRate__c eachQLCRate : [SELECT Id, Name, SBQQ__QuoteLineConsumptionSchedule__c, SBQQ__Description__c, SBQQ__LowerBound__c, SBQQ__OriginalPrice__c, SBQQ__Price__c, SBQQ__PricingMethod__c, SBQQ__ProcessingOrder__c, SBQQ__UpperBound__c 
                                                            FROM SBQQ__QuoteLineConsumptionRate__c 
                                                            WHERE SBQQ__QuoteLineConsumptionSchedule__c IN: clonedQLConsumptionScheduleMap.keySet()]){
            if(clonedQLConsumptionScheduleMap.containsKey(eachQLCRate.SBQQ__QuoteLineConsumptionSchedule__c)){
                //ENTER HERE
                SBQQ__QuoteLineConsumptionRate__c newQLCRate = eachQLCRate.clone(false, true, false, false);
                newQLCRate.SBQQ__QuoteLineConsumptionSchedule__c = clonedQLConsumptionScheduleMap.get(eachQLCRate.SBQQ__QuoteLineConsumptionSchedule__c).id;
                clonedQLConsumptionRateList.add(newQLCRate);
            }
        }      
        
        try {
            insert clonedQLConsumptionRateList;
           
        } catch (Exception ex) {
            //ENTER HERE
            System.debug('**** clonedQLConsumptionRateList Exception : '+ ex.getMessage());
           Database.rollback(sp);
            return false;
        }
            
        //The current Cloned Quote line in the next loop
        SBQQ__QuoteLine__c currentClonedQL;
        //The current Original Quote line in the next loop
        SBQQ__QuoteLine__c currentOriginQL;
        //The Id of the current Parent of the original Quote line in the next loop
        Id currentOriginParentQLId;
        //update the bundles for the cloned Quote lines 
        // eachId is for the current original quote line
        for(Id eachId : originIdsToclonedQLMap.keySet()){
            currentClonedQL = originIdsToclonedQLMap.get(eachId);
            if(currentClonedQL.SBQQ__RequiredBy__c != null){
                //Origin quote line of the current cloned quote line
                currentOriginQL = idToQuoteLineMap.get(eachId);
                currentOriginParentQLId = currentOriginQL.SBQQ__RequiredBy__c;
                //set the parent of the cloned QL to be => the cloned QL from the parent of the original QL
                currentClonedQL.SBQQ__RequiredBy__c = originIdsToclonedQLMap.get(currentOriginParentQLId).Id;
            }
        }
        // Update the RequiredBy fields of cloned QL 
        // And update the quantity field of the original QL
        try {
            System.debug('error ');
            update originIdsToclonedQLMap.values();
            update idToQuoteLineMap.values();
            
        } catch (Exception ex) {
            System.debug('Error'+ ex.getMessage());
            Database.rollback(sp);
            return false;
        }
        SBQQ.TriggerControl.Enable();
        return true;
    }
    


}