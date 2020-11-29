#!/bin/sh
#
# author : E.Yhuellou
# description : Split test class execution
# Usage : execFullSoTest.sh <username or alias>

YourAlias=$1
TmpFilename01=Test_Result_$1_$(date +"%Y-%m-%d_%H:%M")_PART_01.txt
TmpFilename02=Test_Result_$1_$(date +"%Y-%m-%d_%H:%M")_PART_02.txt
TmpFilename03=Test_Result_$1_$(date +"%Y-%m-%d_%H:%M")_PART_03.txt
TmpFilename04=Test_Result_$1_$(date +"%Y-%m-%d_%H:%M")_PART_04.txt

echo "------> Starting Test..." 

echo "------> Processing : $TmpFilename01" 
sfdx force:apex:test:run --classnames "APB001_ProcessLPCR_Log_Test,APB002_RenewalContract_Test,APB003_CreateOrderFromQuote_Test,APB004_ActivateOrder_Test,APB005_GenerateContractFromOrder_Test,APB006_PrepaRenewalContract_Test,APB007_AllPriceBookClasses_Tests,APB008_ResetStartEndDatesOnContract_Test,APB009_GenerateLienFamilleFacture_Test,APB010_ProcessDailyOrderProduct_Test" --resultformat human -u $YourAlias --verbose --wait 1000 >> $TmpFilename01

echo "------> Processing : $TmpFilename02"
sfdx force:apex:test:run --classnames "APB011_SetInvoiceCommentaire_Test,APB012_ProcessRevenuCascade_Test,APB013_ProcessYearlyOrderProduct_Test,APB015_ProcessBillingPlanLines_Test,APC001_LeadFaConverController_Test,APC002_AttachmentController_Test,APC004_SendMailController_Test,APC005_PreinscriptionsEnCoursCtrl_Test,APC006_CloneQuoteLines_Test,APC007_ShowCrechesLpcrController_Test" --resultformat human -u $YourAlias --verbose --wait 1000 >> $TmpFilename02

echo "------> Processing : $TmpFilename03"
sfdx force:apex:test:run --classnames "APC008_ResetQuoteLines_Test,LWC003_UpdateStatusController_Test,MCK001_LPCRHttpCalloutMockImpl_Test,PAD_Test,SM001_TestIfByPassed_Test,SM002_EventServices_TEST,SM003_TaskServices_TEST,SM004_OpportunityServices_Test,SM006_PreinscriptionServices_Test,SM007_LeadServices_Test,SM008_QuoteServices_Test,SM009_ParametrageScoreServices_Test" --resultformat human -u $YourAlias --verbose --wait 1000 >> $TmpFilename03

echo "------> Processing : $TmpFilename04"
sfdx force:apex:test:run --classnames "SM010_ContractServices_Test,SM011_RessourceFamilleServices_Test,SM012_OrderItemServices_Test,SM014_OrderServices_Test,SM015_InvoiceServices_Test,SM016_SendMail_Callout_Test,SM018_AttachmentService_Test,SM019_DocumentList_Callout_Test,SM020_GetDocument_Callout_Test,SM020_PresinscriptionInvockeService_Test,SM021_CreditNoteServices_Test,SM022_ModificationEntranteServices_Test,SM023_GetDocument_Callout_Test,SM024_ContactServices_Test,SM025_SendContact_Callout_Test,UM001_LogManager_Test,VFC001_GenererDocAnn2_Test" --resultformat human -u $YourAlias --verbose --wait 1000 >> $TmpFilename04

echo "------> All Test Finished."