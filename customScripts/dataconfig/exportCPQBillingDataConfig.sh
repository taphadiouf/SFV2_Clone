#!/bin/sh
#
# author : E.Yhuellou
# description : export data from CPQ and Billing Data Config
#                   * We removed user reference because it is not relevant information
#                   * Prefer using and storing in git data exported from same sandbox (integration for example)
#
#               (/!\ For practical reason, it is good also to have a backuo sandbox to store the data config and deploy it more easly with Prodly)
#
# Sample usage go into customScripts/ folder and execute ./exportCPQBillingDataConfig.sh <username or alias> <outputdir>
# example : ./exportCPQBillingDataConfig.sh eyhuellou@lpcr.fr.int config-cpq-billing

TARGET_ENV=$1
OUTPUT_DIR=$2

echo "Starting Exporting CPQ, Billing and Advanced Approval Data Config..."

echo ">> Processing blng__BillingRule__c..."
sfdx force:data:tree:export -q "select blng__Active__c, blng__AmendmentBillCycleDateAlignment__c, blng__GenerateInvoices__c, blng__InitialBillingTrigger__c, blng__Notes__c, blng__PartialPeriodTreatment__c, IsDeleted, LastActivityDate,  LastReferencedDate, LastViewedDate, Name, SystemModstamp from blng__BillingRule__c" -d $OUTPUT_DIR -p -u $TARGET_ENV

echo ">> Processing Product2..."
sfdx force:data:tree:export -q "select blng__BillingRule__r.Id, blng__RevenueRecognitionRule__r.Id, blng__TaxRule__r.Id, Description, DisplayUrl, ExternalId, Family, IsActive, IsArchived, IsDeleted,  LastReferencedDate, LastViewedDate, LPCR_FamilyProduct__c, LPCR_PourcentagePlancherMicro__c, LPCR_PrixPlancherParisIDF__c, LPCR_PrixPlancherProvince__c, LPCR_RefCodeProduit__c, LPCR_TypeEvenement__c, LPCR_Typemensualisation__c, Name, ProductCode, QuantityUnitOfMeasure, SBQQ__AssetAmendmentBehavior__c, SBQQ__AssetConversion__c, SBQQ__BatchQuantity__c, SBQQ__BillingFrequency__c, SBQQ__BillingType__c, SBQQ__BlockPricingField__c, SBQQ__ChargeType__c, SBQQ__Component__c, SBQQ__CompoundDiscountRate__c, SBQQ__ConfigurationEvent__c, SBQQ__ConfigurationFields__c, SBQQ__ConfigurationFieldSet__c, SBQQ__ConfigurationFormTitle__c, SBQQ__ConfigurationType__c, SBQQ__ConfigurationValidator__c, SBQQ__ConfiguredCodePattern__c, SBQQ__ConfiguredDescriptionPattern__c, SBQQ__CostEditable__c, SBQQ__CostSchedule__r.Id, SBQQ__CustomConfigurationPage__c, SBQQ__CustomConfigurationRequired__c, SBQQ__CustomerCommunityAvailability__c, SBQQ__DefaultPricingTable__c, SBQQ__DefaultQuantity__c, SBQQ__DescriptionLocked__c, SBQQ__DiscountCategory__r.Id, SBQQ__DiscountSchedule__r.Id, SBQQ__DynamicPricingConstraint__c, SBQQ__EnableLargeConfiguration__c, SBQQ__ExcludeFromMaintenance__c, SBQQ__ExcludeFromOpportunity__c, SBQQ__ExternallyConfigurable__c, SBQQ__GenerateContractedPrice__c, SBQQ__HasConfigurationAttributes__c, SBQQ__HasConsumptionSchedule__c, SBQQ__Hidden__c, SBQQ__HidePriceInSearchResults__c, SBQQ__IncludeInMaintenance__c, SBQQ__NewQuoteGroup__c, SBQQ__NonDiscountable__c, SBQQ__NonPartnerDiscountable__c, SBQQ__Optional__c, SBQQ__OptionLayout__c, SBQQ__OptionSelectionMethod__c, SBQQ__PriceEditable__c, SBQQ__PricingGuidance__r.Id, SBQQ__PricingMethod__c, SBQQ__PricingMethodEditable__c, SBQQ__ProductPictureID__c, SBQQ__QuantityEditable__c, SBQQ__QuantityScale__c, SBQQ__ReconfigurationDisabled__c, SBQQ__RenewalProduct__c, SBQQ__SortOrder__c, SBQQ__Specifications__c, SBQQ__SubscriptionBase__c, SBQQ__SubscriptionCategory__c, SBQQ__SubscriptionPercent__c, SBQQ__SubscriptionPricing__c, SBQQ__SubscriptionTarget__c, SBQQ__SubscriptionTerm__c, SBQQ__SubscriptionType__c, SBQQ__Taxable__c, SBQQ__TaxCode__c, SBQQ__TermDiscountLevel__c, SBQQ__TermDiscountSchedule__r.Id, SBQQ__UpgradeCredit__c, SBQQ__UpgradeRatio__c, SBQQ__UpgradeSource__c, SBQQ__UpgradeTarget__c, StockKeepingUnit, SystemModstamp from Product2" -d $OUTPUT_DIR -p -u $TARGET_ENV

echo ">> Processing SBQQ__PriceRule__c..."
sfdx force:data:tree:export -q "select IsDeleted,  LastReferencedDate, LastViewedDate, Name, SBQQ__Active__c, SBQQ__AdvancedCondition__c, SBQQ__ConditionsMet__c, SBQQ__ConfiguratorEvaluationEvent__c, SBQQ__EvaluationEvent__c, SBQQ__EvaluationOrder__c, SBQQ__LookupObject__c,  SBQQ__TargetObject__c, SystemModstamp, SBQQ__Product__r.Id  from SBQQ__PriceRule__c" -d $OUTPUT_DIR -p -u $TARGET_ENV

echo ">> Processing SBQQ__ConfigurationRule__c..."
sfdx force:data:tree:export -q "select IsDeleted,  Name, SBQQ__Active__c, SBQQ__AscendingNestedLevel__c, SBQQ__DescendingActionNesting__c, SBQQ__DescendingNestedLevel__c , SBQQ__ProductFeature__c, SBQQ__ProductRule__c, SBQQ__RuleEvaluationEvent__c, SBQQ__RuleType__c, SystemModstamp, SBQQ__Product__r.Id from SBQQ__ConfigurationRule__c" -d $OUTPUT_DIR -p -u $TARGET_ENV

echo ">> Processing SBQQ__ErrorCondition__c..."
sfdx force:data:tree:export -q "select IsDeleted,  Name, SBQQ__FilterType__c, SBQQ__FilterValue__c, SBQQ__Index__c, SBQQ__Operator__c, SBQQ__ParentRuleIsActive__c, SBQQ__Rule__r.Id, SBQQ__RuleTargetsQuote__c, SBQQ__TestedAttribute__r.Id, SBQQ__TestedField__c, SBQQ__TestedObject__c, SBQQ__TestedVariable__r.Id, SystemModstamp from SBQQ__ErrorCondition__c" -d $OUTPUT_DIR -p -u $TARGET_ENV

echo ">> Processing SBQQ__LookupQuery__c..."
sfdx force:data:tree:export -q "select IsDeleted,  Name, SBQQ__LookupField__c, SBQQ__MatchType__c, SBQQ__Operator__c, SBQQ__ParentRuleIsActive__c, SBQQ__PriceRule2__r.Id, SBQQ__ProductRule__r.Id, SBQQ__RuleLookupObject__c, SBQQ__RuleTargetsCalculator__c, SBQQ__TestedConfigurationAttribute__r.Id, SBQQ__TestedField__c, SBQQ__TestedObject__c, SBQQ__TestedValue__c, SystemModstamp from SBQQ__LookupQuery__c" -d $OUTPUT_DIR -p -u $TARGET_ENV

echo ">> Processing SBQQ__PriceAction__c..."
sfdx force:data:tree:export -q "select IsDeleted,  LPCR_Notes__c, Name, SBQQ__Field__c, SBQQ__Formula__c, SBQQ__Order__c, SBQQ__ParentRuleIsActive__c, SBQQ__Rule__r.Id, SBQQ__RuleLookupObject__c, SBQQ__RuleTargetsCalculator__c, SBQQ__SourceLookupField__c, SBQQ__SourceVariable__r.Id, SBQQ__TargetObject__c, SBQQ__Value__c, SBQQ__ValueField__c, SystemModstamp from SBQQ__PriceAction__c" -d $OUTPUT_DIR -p -u $TARGET_ENV

echo ">> Processing SBQQ__PriceCondition__c..."
sfdx force:data:tree:export -q "select IsDeleted,  Name, SBQQ__Field__c, SBQQ__FilterFormula__c, SBQQ__FilterType__c, SBQQ__Index__c, SBQQ__Object__c, SBQQ__Operator__c, SBQQ__ParentRuleIsActive__c, SBQQ__Rule__r.Id, SBQQ__RuleTargetsCalculator__c, SBQQ__TestedFormula__c, SBQQ__TestedVariable__r.Id, SBQQ__Value__c, SystemModstamp from SBQQ__PriceCondition__c" -d $OUTPUT_DIR -p -u $TARGET_ENV

echo ">> Processing SBQQ__ProductAction__c..."
sfdx force:data:tree:export -q "select IsDeleted,  Name, SBQQ__FilterField__c, SBQQ__FilterValue__c, SBQQ__Operator__c, SBQQ__ParentRuleIsActive__c, SBQQ__Product__r.Id, SBQQ__Required__c, SBQQ__Rule__r.Id, SBQQ__Type__c, SBQQ__ValueAttribute__r.Id, SBQQ__ValueField__c, SBQQ__ValueObject__c, SystemModstamp from SBQQ__ProductAction__c" -d $OUTPUT_DIR -p -u $TARGET_ENV

echo ">> Processing SBQQ__ProductRule__c..."
sfdx force:data:tree:export -q "select IsDeleted,  LastReferencedDate, LastViewedDate, Name, SBQQ__Active__c, SBQQ__AdvancedCondition__c, SBQQ__ConditionsMet__c, SBQQ__ErrorMessage__c, SBQQ__EvaluationEvent__c, SBQQ__EvaluationOrder__c, SBQQ__LookupMessageField__c, SBQQ__LookupObject__c, SBQQ__LookupProductField__c, SBQQ__LookupRequiredField__c, SBQQ__LookupTypeField__c, SBQQ__Scope__c, SBQQ__Type__c, SystemModstamp from SBQQ__ProductRule__c" -d $OUTPUT_DIR -p -u $TARGET_ENV

echo ">> Processing blng__GLRule__c..."
sfdx force:data:tree:export -q "select blng__Active__c, blng__Notes__c, IsDeleted,  LastReferencedDate, LastViewedDate, Name, SystemModstamp from blng__GLRule__c" -d $OUTPUT_DIR -p -u $TARGET_ENV

echo ">> Processing blng__RevenueRecognitionRule__c..."
sfdx force:data:tree:export -q "select blng__Active__c, blng__CreateRevenueSchedule__c, blng__Notes__c, IsDeleted,  LastReferencedDate, LastViewedDate, Name, SystemModstamp from blng__RevenueRecognitionRule__c" -d $OUTPUT_DIR -p -u $TARGET_ENV

echo ">> Processing blng__TaxRule__c..."
sfdx force:data:tree:export -q "select blng__Active__c, blng__Notes__c, blng__TaxableYesNo__c, IsDeleted,  LastReferencedDate, LastViewedDate, Name, SystemModstamp from blng__TaxRule__c" -d $OUTPUT_DIR -p -u $TARGET_ENV

echo ">> Processing sbaa__ApprovalCondition__c..."
sfdx force:data:tree:export -q "select IsDeleted,  Name, sbaa__ApprovalRule__r.Id, sbaa__EnableSmartApproval__c, sbaa__FilterField__c, sbaa__FilterType__c, sbaa__FilterValue__c, sbaa__FilterVariable__r.Id, sbaa__Index__c, sbaa__Operator__c, sbaa__TestedField__c, sbaa__TestedVariable__r.Id, SystemModstamp from sbaa__ApprovalCondition__c" -d $OUTPUT_DIR -p -u $TARGET_ENV

echo ">> Processing sbaa__ApprovalRule__c..."
sfdx force:data:tree:export -q "select IsDeleted,  LastReferencedDate, LastViewedDate, Name, sbaa__Active__c, sbaa__AdvancedCondition__c, sbaa__ApprovalChain__r.Id, sbaa__ApprovalRecipients__c, sbaa__ApprovalStep__c, sbaa__ApprovalTemplate__r.Id, sbaa__Approver__r.Id, sbaa__ApproverField__c, sbaa__ConditionsMet__c, sbaa__EffectiveDateField__c, sbaa__EffectiveEndDate__c, sbaa__EffectiveStartDate__c, sbaa__ExcludedStatuses__c, sbaa__OverrideField__c, sbaa__Parallel__c, sbaa__RecallTemplate__r.Id, sbaa__RejectionRecipients__c, sbaa__RejectionTemplate__r.Id, sbaa__RequestTemplate__r.Id, sbaa__RequireExplicitApproval__c, sbaa__SmartApprovalIgnoresConditionsMet__c, sbaa__TargetObject__c, SystemModstamp from sbaa__ApprovalRule__c" -d $OUTPUT_DIR -p -u $TARGET_ENV

echo ">> Processing sbaa__Approval__c..."
sfdx force:data:tree:export -q "select IsDeleted,  LastReferencedDate, LastViewedDate, Name, Quote__r.Id, sbaa__Actions__c, sbaa__ApprovalChain__r.Id, sbaa__ApprovalStep__c, sbaa__ApprovalTemplateId__c, sbaa__ApprovedBy__r.Id, sbaa__Approver__r.Id, sbaa__ApproverField__c, sbaa__Archived__c, sbaa__AssignedGroupId__c, sbaa__AssignedTo__r.Id, sbaa__AssignedToMe__c, sbaa__CommentsLong__c, sbaa__DelegatedApprover__r.Id, sbaa__Opportunity__r.Id, sbaa__RecallTemplateId__c, sbaa__RecordField__c, sbaa__RejectedBy__r.Id, sbaa__RejectionTemplateId__c, sbaa__RequestTemplateId__c, sbaa__RequireExplicitApproval__c, sbaa__Rule__r.Id, sbaa__Status__c, sbaa__Unanimous__c, SystemModstamp from sbaa__Approval__c" -d $OUTPUT_DIR -p -u $TARGET_ENV

echo ">> Processing sbaa__TrackedField__c..."
sfdx force:data:tree:export -q "select IsDeleted,  Name, sbaa__ApprovalRule__r.Id, sbaa__RecordField__c, sbaa__TrackedField__c, sbaa__TrackedObject__c, sbaa__TrackingType__c, SystemModstamp from sbaa__TrackedField__c" -d $OUTPUT_DIR -p -u $TARGET_ENV

echo ">> Processing SBQQ__CustomScript__c..."
sfdx force:data:tree:export -q "select IsDeleted,  LastReferencedDate, LastViewedDate, Name, SBQQ__Code__c, SBQQ__ConsumptionRateFields__c, SBQQ__ConsumptionScheduleFields__c, SBQQ__GroupFields__c, SBQQ__QuoteFields__c, SBQQ__QuoteLineFields__c, SBQQ__TranspiledCode__c from SBQQ__CustomScript__c" -d $OUTPUT_DIR -p -u $TARGET_ENV

echo ">> Processing CONGA CIT..."
sfdx force:data:tree:export -q "select csfb__Name__c, csfb__Template_Type__c, csfb__Template_Group__c, csfb__Master_Field_to_Set_3__c, csfb__Master_Field_to_Set_2__c, csfb__Master_Field_to_Set_1__c, csfb__Label_Template_Use_Detail_Data__c, csfb__Description__c from csfb__Conga_Template__c"  -d $OUTPUT_DIR -p -u $TARGET_ENV

echo ">> Processing CONGA CIQ..."
sfdx force:data:tree:export -q "select csfb__Name__c, csfb__Description__c, csfb__Query__c from csfb__Conga_Merge_Query__c  "  -d $OUTPUT_DIR -p -u $TARGET_ENV

echo ">> Processing CONGA CQT..."
sfdx force:data:tree:export -q "select APXTCFQ__Name__c, APXTCFQ__Description__c, APXTCFQ__Label_Template_Use_Detail_Data__c, APXTCFQ__Master_Field_to_Set_1__c, APXTCFQ__Master_Field_to_Set_2__c, APXTCFQ__Master_Field_to_Set_3__c, APXTCFQ__Template_Extension__c, APXTCFQ__Template_Group__c, APXTCFQ__Template_Type__c  from APXTCFQ__Conga_Template__c"  -d $OUTPUT_DIR -p -u $TARGET_ENV

echo ">> Processing CONGA CQQ..."
sfdx force:data:tree:export -q "select APXTCFQ__Name__c, APXTCFQ__Description__c, APXTCFQ__Query__c from APXTCFQ__Conga_Merge_Query__c"  -d $OUTPUT_DIR -p -u $TARGET_ENV

echo ">> Processing CONGA CS..."
sfdx force:data:tree:export -q "select Name,  csfb__Button_body_field__c, csfb__Button_Link_API_Name__c, csfb__Composer_Parameters__c, csfb__CongaEmailTemplateCount__c, csfb__Custom_Object_Id__c, csfb__Formula_body_field__c, csfb__Formula_Field_API_Name__c, csfb__Is_Quick_Start__c, csfb__Launch_C8_Formula_Button__c, csfb__Master_Object_Type__c, csfb__Master_Object_Type_Validator__c, csfb__Sample_Record_Id__c, csfb__Sample_Record_Name__c, csfb__Solution_Description__c, csfb__Solution_Weblink_Syntax__c, csfb__Weblink_Id__c from csfb__Conga_Solution__c"  -d $OUTPUT_DIR -p -u $TARGET_ENV

echo ">> Processing ADOBE AAT..."
sfdx force:data:tree:export -q "select echosign_dev1__Name__c, echosign_dev1__Account__c, echosign_dev1__Active__c, echosign_dev1__Agreement_Type__c, echosign_dev1__Auto_Send__c, echosign_dev1__Automatic_Reminders__c, echosign_dev1__Available_Publisher_Actions__c, echosign_dev1__Confirm_Password__c, echosign_dev1__Contract__c, echosign_dev1__Data_Mapping__c, echosign_dev1__Days_Until_Expiration2__c, echosign_dev1__Default__c, echosign_dev1__Email_Copy_To__c, echosign_dev1__External_Signers_Verification_Method__c, echosign_dev1__Fill_Sign__c, echosign_dev1__Hosted_Signing__c, echosign_dev1__Internal_Signers_Verification_Method__c, echosign_dev1__Language__c, echosign_dev1__Master_Object_Type__c, echosign_dev1__Merge_Mapping__c, echosign_dev1__Message__c, echosign_dev1__Opportunity__c, echosign_dev1__Password__c, echosign_dev1__Post_Sign_Redirect_Delay__c, echosign_dev1__Post_Sign_Redirect_URL__c, echosign_dev1__Preview_Position__c, echosign_dev1__Sender_Signs_Only__c, echosign_dev1__Sender_User__c, echosign_dev1__Sign_External_Password__c, echosign_dev1__Sign_Internal_Password__c, echosign_dev1__Sign_Password__c, echosign_dev1__Sign_Workflow_Id__c, echosign_dev1__Signature_Flow__c, echosign_dev1__Signature_Order__c, echosign_dev1__Signature_Type__c, echosign_dev1__View_Password__c  from echosign_dev1__Agreement_Template__c "  -d $OUTPUT_DIR -p -u $TARGET_ENV




echo "Export Finished !"




















