<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE html
  PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns:pmd="http://pmd.sourceforge.net/report/2.0.0">
   <head>
      <title>PMD 6.25.0 Report</title>
      <style type="text/css">
    .bannercell {
      border: 0px;
      padding: 0px;
    }
    body {
      margin-left: 10px;
      margin-right: 10px;
      font:normal 80% arial,helvetica,sanserif;
      background-color:#FFFFFF;
      color:#000000;
    }
    .a td {
      background: #efefef;
    }
    .b td {
      background: #fff;
    }
    th, td {
      text-align: left;
      vertical-align: top;
    }
    th {
      font-weight:bold;
      background: #ccc;
      color: black;
    }
    table, th, td {
      font-size:100%;
      border: none
    }
    table.log tr td, tr th {

    }
    h2 {
      font-weight:bold;
      font-size:140%;
      margin-bottom: 5;
    }
    h3 {
      font-size:100%;
      font-weight:bold;
      background: #525D76;
      color: white;
      text-decoration: none;
      padding: 5px;
      margin-right: 2px;
      margin-left: 2px;
      margin-bottom: 0px;
    }
	.p1 { background:#FF9999; }
	.p2 { background:#FFCC66; }
	.p3 { background:#FFFF99; }
	.p4 { background:#99FF99; }
	.p5 { background:#a6caf0; }

		</style>
   </head>
   <body>
      <a name="top"/>
      <table border="0" cellpadding="0" cellspacing="0" width="100%">
         <tr>
            <td class="bannercell" rowspan="2"/>
            <td class="text-align:right">
               <h2>PMD 6.25.0 Report. Generated on 2020-07-02 - 20:06:07</h2>
            </td>
         </tr>
      </table>
      <hr size="1"/>
      <h3>Summary</h3>
      <table class="log" border="0" cellpadding="5" cellspacing="2" width="100%">
         <tr>
            <th style="width:25%">Files</th>
            <th>Total</th>
            <th>
               <div class="p1">Priority 1</div>
            </th>
            <th>
               <div class="p2">Priority 2</div>
            </th>
            <th>
               <div class="p3">Priority 3</div>
            </th>
            <th>
               <div class="p4">Priority 4</div>
            </th>
            <th>
               <div class="p5">Priority 5</div>
            </th>
         </tr>
         <tr class="a">
            <td>52</td>
            <td>194</td>
            <td>0</td>
            <td>53</td>
            <td>141</td>
            <td>0</td>
            <td>0</td>
         </tr>
      </table>
      <hr size="1" width="100%" align="left"/>
      <h3>Rules</h3>
      <table class="log" border="0" cellpadding="5" cellspacing="2" width="100%">
         <tr>
            <th style="width:84%">Rule</th>
            <th style="width:8%">Violations</th>
            <th style="width:8%">Severity</th>
         </tr>
         <tr class="a">
            <td>
					[Best Practices] ApexAssertionsShouldIncludeMessage</td>
            <td>103</td>
            <td>
               <div class="p3"> 3</div>
            </td>
         </tr>
         <tr class="b">
            <td>
					[Best Practices] ApexUnitTestClassShouldHaveAsserts</td>
            <td>52</td>
            <td>
               <div class="p2"> 2</div>
            </td>
         </tr>
         <tr class="a">
            <td>
					[Best Practices] DebugsShouldUseLoggingLevel</td>
            <td>23</td>
            <td>
               <div class="p3"> 3</div>
            </td>
         </tr>
         <tr class="b">
            <td>
					[Best Practices] AvoidGlobalModifier</td>
            <td>15</td>
            <td>
               <div class="p3"> 3</div>
            </td>
         </tr>
         <tr class="a">
            <td>
					[Best Practices] ApexUnitTestMethodShouldHaveIsTestAnnotation</td>
            <td>1</td>
            <td>
               <div class="p2"> 2</div>
            </td>
         </tr>
      </table>
      <hr size="1" width="100%" align="left"/>
      <h3>Files</h3>
      <table class="log" border="0" cellpadding="5" cellspacing="2" width="100%">
         <tr>
            <th>File</th>
            <th style="width:40px">
               <div class="p5">5</div>
            </th>
            <th style="width:40px">
               <div class="p4">4</div>
            </th>
            <th style="width:40px">
               <div class="p3">3</div>
            </th>
            <th style="width:40px">
               <div class="p2">2</div>
            </th>
            <th style="width:40px">
               <div class="p1">1</div>
            </th>
         </tr>
         <tr class="a">
            <td>
               <a href="#f-_Users_ataib_workspace_SFV2_force-app_main_default_classes_SM012_OrderItemServices_Test.cls">/Users/ataib/workspace/SFV2/force-app/main/default/classes/SM012_OrderItemServices_Test.cls</a>
            </td>
            <td>0</td>
            <td>0</td>
            <td>55</td>
            <td>2</td>
            <td>0</td>
         </tr>
         <tr class="b">
            <td>
               <a href="#f-_Users_ataib_workspace_SFV2_force-app_main_default_classes_SM013_ModificationEntranteServices_Test.cls">/Users/ataib/workspace/SFV2/force-app/main/default/classes/SM013_ModificationEntranteServices_Test.cls</a>
            </td>
            <td>0</td>
            <td>0</td>
            <td>0</td>
            <td>25</td>
            <td>0</td>
         </tr>
         <tr class="a">
            <td>
               <a href="#f-_Users_ataib_workspace_SFV2_force-app_main_default_classes_SM007_LeadServices_Test.cls">/Users/ataib/workspace/SFV2/force-app/main/default/classes/SM007_LeadServices_Test.cls</a>
            </td>
            <td>0</td>
            <td>0</td>
            <td>9</td>
            <td>5</td>
            <td>0</td>
         </tr>
         <tr class="b">
            <td>
               <a href="#f-_Users_ataib_workspace_SFV2_force-app_main_default_classes_UM002_TestDataFactory_Test.cls">/Users/ataib/workspace/SFV2/force-app/main/default/classes/UM002_TestDataFactory_Test.cls</a>
            </td>
            <td>0</td>
            <td>0</td>
            <td>11</td>
            <td>1</td>
            <td>0</td>
         </tr>
         <tr class="a">
            <td>
               <a href="#f-_Users_ataib_workspace_SFV2_force-app_main_default_classes_APC001_LeadFaConverController_Test.cls">/Users/ataib/workspace/SFV2/force-app/main/default/classes/APC001_LeadFaConverController_Test.cls</a>
            </td>
            <td>0</td>
            <td>0</td>
            <td>10</td>
            <td>0</td>
            <td>0</td>
         </tr>
         <tr class="b">
            <td>
               <a href="#f-_Users_ataib_workspace_SFV2_force-app_main_default_classes_MCK001_LPCRHttpCalloutMockImpl.cls">/Users/ataib/workspace/SFV2/force-app/main/default/classes/MCK001_LPCRHttpCalloutMockImpl.cls</a>
            </td>
            <td>0</td>
            <td>0</td>
            <td>8</td>
            <td>0</td>
            <td>0</td>
         </tr>
         <tr class="a">
            <td>
               <a href="#f-_Users_ataib_workspace_SFV2_force-app_main_default_classes_PAD.cls">/Users/ataib/workspace/SFV2/force-app/main/default/classes/PAD.cls</a>
            </td>
            <td>0</td>
            <td>0</td>
            <td>4</td>
            <td>0</td>
            <td>0</td>
         </tr>
         <tr class="b">
            <td>
               <a href="#f-_Users_ataib_workspace_SFV2_force-app_main_default_classes_SM008_QuoteServices_Test.cls">/Users/ataib/workspace/SFV2/force-app/main/default/classes/SM008_QuoteServices_Test.cls</a>
            </td>
            <td>0</td>
            <td>0</td>
            <td>2</td>
            <td>2</td>
            <td>0</td>
         </tr>
         <tr class="a">
            <td>
               <a href="#f-_Users_ataib_workspace_SFV2_force-app_main_default_classes_APC006_CloneQuoteLines_Test.cls">/Users/ataib/workspace/SFV2/force-app/main/default/classes/APC006_CloneQuoteLines_Test.cls</a>
            </td>
            <td>0</td>
            <td>0</td>
            <td>0</td>
            <td>3</td>
            <td>0</td>
         </tr>
         <tr class="b">
            <td>
               <a href="#f-_Users_ataib_workspace_SFV2_force-app_main_default_classes_SM003_TaskServices_TEST.cls">/Users/ataib/workspace/SFV2/force-app/main/default/classes/SM003_TaskServices_TEST.cls</a>
            </td>
            <td>0</td>
            <td>0</td>
            <td>3</td>
            <td>0</td>
            <td>0</td>
         </tr>
         <tr class="a">
            <td>
               <a href="#f-_Users_ataib_workspace_SFV2_force-app_main_default_classes_SM013_QuoteLineServices_Test.cls">/Users/ataib/workspace/SFV2/force-app/main/default/classes/SM013_QuoteLineServices_Test.cls</a>
            </td>
            <td>0</td>
            <td>0</td>
            <td>3</td>
            <td>0</td>
            <td>0</td>
         </tr>
         <tr class="b">
            <td>
               <a href="#f-_Users_ataib_workspace_SFV2_force-app_main_default_classes_APB007_AllPriceBookClasses_Tests.cls">/Users/ataib/workspace/SFV2/force-app/main/default/classes/APB007_AllPriceBookClasses_Tests.cls</a>
            </td>
            <td>0</td>
            <td>0</td>
            <td>2</td>
            <td>0</td>
            <td>0</td>
         </tr>
         <tr class="a">
            <td>
               <a href="#f-_Users_ataib_workspace_SFV2_force-app_main_default_classes_APB009_GenerateLienFamilleFacture_Test.cls">/Users/ataib/workspace/SFV2/force-app/main/default/classes/APB009_GenerateLienFamilleFacture_Test.cls</a>
            </td>
            <td>0</td>
            <td>0</td>
            <td>2</td>
            <td>0</td>
            <td>0</td>
         </tr>
         <tr class="b">
            <td>
               <a href="#f-_Users_ataib_workspace_SFV2_force-app_main_default_classes_APC004_SendMailController_Test.cls">/Users/ataib/workspace/SFV2/force-app/main/default/classes/APC004_SendMailController_Test.cls</a>
            </td>
            <td>0</td>
            <td>0</td>
            <td>0</td>
            <td>2</td>
            <td>0</td>
         </tr>
         <tr class="a">
            <td>
               <a href="#f-_Users_ataib_workspace_SFV2_force-app_main_default_classes_APC008_ResetQuoteLines_Test.cls">/Users/ataib/workspace/SFV2/force-app/main/default/classes/APC008_ResetQuoteLines_Test.cls</a>
            </td>
            <td>0</td>
            <td>0</td>
            <td>1</td>
            <td>1</td>
            <td>0</td>
         </tr>
         <tr class="b">
            <td>
               <a href="#f-_Users_ataib_workspace_SFV2_force-app_main_default_classes_LWC003_UpdateStatusController_Test.cls">/Users/ataib/workspace/SFV2/force-app/main/default/classes/LWC003_UpdateStatusController_Test.cls</a>
            </td>
            <td>0</td>
            <td>0</td>
            <td>0</td>
            <td>2</td>
            <td>0</td>
         </tr>
         <tr class="a">
            <td>
               <a href="#f-_Users_ataib_workspace_SFV2_force-app_main_default_classes_QuoteExtControllerTests.cls">/Users/ataib/workspace/SFV2/force-app/main/default/classes/QuoteExtControllerTests.cls</a>
            </td>
            <td>0</td>
            <td>0</td>
            <td>2</td>
            <td>0</td>
            <td>0</td>
         </tr>
         <tr class="b">
            <td>
               <a href="#f-_Users_ataib_workspace_SFV2_force-app_main_default_classes_SM013_ModificationEntranteServices.cls">/Users/ataib/workspace/SFV2/force-app/main/default/classes/SM013_ModificationEntranteServices.cls</a>
            </td>
            <td>0</td>
            <td>0</td>
            <td>2</td>
            <td>0</td>
            <td>0</td>
         </tr>
         <tr class="a">
            <td>
               <a href="#f-_Users_ataib_workspace_SFV2_force-app_main_default_classes_SM015_InvoiceServices_Test.cls">/Users/ataib/workspace/SFV2/force-app/main/default/classes/SM015_InvoiceServices_Test.cls</a>
            </td>
            <td>0</td>
            <td>0</td>
            <td>2</td>
            <td>0</td>
            <td>0</td>
         </tr>
         <tr class="b">
            <td>
               <a href="#f-_Users_ataib_workspace_SFV2_force-app_main_default_classes_SM016_SendMail_Callout.cls">/Users/ataib/workspace/SFV2/force-app/main/default/classes/SM016_SendMail_Callout.cls</a>
            </td>
            <td>0</td>
            <td>0</td>
            <td>2</td>
            <td>0</td>
            <td>0</td>
         </tr>
         <tr class="a">
            <td>
               <a href="#f-_Users_ataib_workspace_SFV2_force-app_main_default_classes_SM019_DocumentList_Callout.cls">/Users/ataib/workspace/SFV2/force-app/main/default/classes/SM019_DocumentList_Callout.cls</a>
            </td>
            <td>0</td>
            <td>0</td>
            <td>2</td>
            <td>0</td>
            <td>0</td>
         </tr>
         <tr class="b">
            <td>
               <a href="#f-_Users_ataib_workspace_SFV2_force-app_main_default_classes_APB001_ProcessLPCR_Log.cls">/Users/ataib/workspace/SFV2/force-app/main/default/classes/APB001_ProcessLPCR_Log.cls</a>
            </td>
            <td>0</td>
            <td>0</td>
            <td>1</td>
            <td>0</td>
            <td>0</td>
         </tr>
         <tr class="a">
            <td>
               <a href="#f-_Users_ataib_workspace_SFV2_force-app_main_default_classes_APB001_ProcessLPCR_Log_Test.cls">/Users/ataib/workspace/SFV2/force-app/main/default/classes/APB001_ProcessLPCR_Log_Test.cls</a>
            </td>
            <td>0</td>
            <td>0</td>
            <td>1</td>
            <td>0</td>
            <td>0</td>
         </tr>
         <tr class="b">
            <td>
               <a href="#f-_Users_ataib_workspace_SFV2_force-app_main_default_classes_APB002_RenewalContract.cls">/Users/ataib/workspace/SFV2/force-app/main/default/classes/APB002_RenewalContract.cls</a>
            </td>
            <td>0</td>
            <td>0</td>
            <td>1</td>
            <td>0</td>
            <td>0</td>
         </tr>
         <tr class="a">
            <td>
               <a href="#f-_Users_ataib_workspace_SFV2_force-app_main_default_classes_APB002_RenewalContract_Test.cls">/Users/ataib/workspace/SFV2/force-app/main/default/classes/APB002_RenewalContract_Test.cls</a>
            </td>
            <td>0</td>
            <td>0</td>
            <td>0</td>
            <td>1</td>
            <td>0</td>
         </tr>
         <tr class="b">
            <td>
               <a href="#f-_Users_ataib_workspace_SFV2_force-app_main_default_classes_APB003_CreateOrderFromQuote.cls">/Users/ataib/workspace/SFV2/force-app/main/default/classes/APB003_CreateOrderFromQuote.cls</a>
            </td>
            <td>0</td>
            <td>0</td>
            <td>1</td>
            <td>0</td>
            <td>0</td>
         </tr>
         <tr class="a">
            <td>
               <a href="#f-_Users_ataib_workspace_SFV2_force-app_main_default_classes_APB004_ActivateOrder.cls">/Users/ataib/workspace/SFV2/force-app/main/default/classes/APB004_ActivateOrder.cls</a>
            </td>
            <td>0</td>
            <td>0</td>
            <td>1</td>
            <td>0</td>
            <td>0</td>
         </tr>
         <tr class="b">
            <td>
               <a href="#f-_Users_ataib_workspace_SFV2_force-app_main_default_classes_APB004_ActivateOrder_Test.cls">/Users/ataib/workspace/SFV2/force-app/main/default/classes/APB004_ActivateOrder_Test.cls</a>
            </td>
            <td>0</td>
            <td>0</td>
            <td>0</td>
            <td>1</td>
            <td>0</td>
         </tr>
         <tr class="a">
            <td>
               <a href="#f-_Users_ataib_workspace_SFV2_force-app_main_default_classes_APB005_GenerateContractFromOrder.cls">/Users/ataib/workspace/SFV2/force-app/main/default/classes/APB005_GenerateContractFromOrder.cls</a>
            </td>
            <td>0</td>
            <td>0</td>
            <td>1</td>
            <td>0</td>
            <td>0</td>
         </tr>
         <tr class="b">
            <td>
               <a href="#f-_Users_ataib_workspace_SFV2_force-app_main_default_classes_APB005_GenerateContractFromOrder_Test.cls">/Users/ataib/workspace/SFV2/force-app/main/default/classes/APB005_GenerateContractFromOrder_Test.cls</a>
            </td>
            <td>0</td>
            <td>0</td>
            <td>0</td>
            <td>1</td>
            <td>0</td>
         </tr>
         <tr class="a">
            <td>
               <a href="#f-_Users_ataib_workspace_SFV2_force-app_main_default_classes_APB006_PrepaRenewalContract.cls">/Users/ataib/workspace/SFV2/force-app/main/default/classes/APB006_PrepaRenewalContract.cls</a>
            </td>
            <td>0</td>
            <td>0</td>
            <td>1</td>
            <td>0</td>
            <td>0</td>
         </tr>
         <tr class="b">
            <td>
               <a href="#f-_Users_ataib_workspace_SFV2_force-app_main_default_classes_APB006_PrepaRenewalContract_Test.cls">/Users/ataib/workspace/SFV2/force-app/main/default/classes/APB006_PrepaRenewalContract_Test.cls</a>
            </td>
            <td>0</td>
            <td>0</td>
            <td>0</td>
            <td>1</td>
            <td>0</td>
         </tr>
         <tr class="a">
            <td>
               <a href="#f-_Users_ataib_workspace_SFV2_force-app_main_default_classes_APB007_TraitementModificationEntrante.cls">/Users/ataib/workspace/SFV2/force-app/main/default/classes/APB007_TraitementModificationEntrante.cls</a>
            </td>
            <td>0</td>
            <td>0</td>
            <td>1</td>
            <td>0</td>
            <td>0</td>
         </tr>
         <tr class="b">
            <td>
               <a href="#f-_Users_ataib_workspace_SFV2_force-app_main_default_classes_APB008_ResetStartEndDatesOnContract.cls">/Users/ataib/workspace/SFV2/force-app/main/default/classes/APB008_ResetStartEndDatesOnContract.cls</a>
            </td>
            <td>0</td>
            <td>0</td>
            <td>1</td>
            <td>0</td>
            <td>0</td>
         </tr>
         <tr class="a">
            <td>
               <a href="#f-_Users_ataib_workspace_SFV2_force-app_main_default_classes_APB009_GenerateLienFamilleFacture.cls">/Users/ataib/workspace/SFV2/force-app/main/default/classes/APB009_GenerateLienFamilleFacture.cls</a>
            </td>
            <td>0</td>
            <td>0</td>
            <td>1</td>
            <td>0</td>
            <td>0</td>
         </tr>
         <tr class="b">
            <td>
               <a href="#f-_Users_ataib_workspace_SFV2_force-app_main_default_classes_APB009_ProcessYearlyOrderProduct.cls">/Users/ataib/workspace/SFV2/force-app/main/default/classes/APB009_ProcessYearlyOrderProduct.cls</a>
            </td>
            <td>0</td>
            <td>0</td>
            <td>1</td>
            <td>0</td>
            <td>0</td>
         </tr>
         <tr class="a">
            <td>
               <a href="#f-_Users_ataib_workspace_SFV2_force-app_main_default_classes_APB010_ProcessDailyOrderProduct.cls">/Users/ataib/workspace/SFV2/force-app/main/default/classes/APB010_ProcessDailyOrderProduct.cls</a>
            </td>
            <td>0</td>
            <td>0</td>
            <td>1</td>
            <td>0</td>
            <td>0</td>
         </tr>
         <tr class="b">
            <td>
               <a href="#f-_Users_ataib_workspace_SFV2_force-app_main_default_classes_APB011_SetInvoiceCommentaire.cls">/Users/ataib/workspace/SFV2/force-app/main/default/classes/APB011_SetInvoiceCommentaire.cls</a>
            </td>
            <td>0</td>
            <td>0</td>
            <td>1</td>
            <td>0</td>
            <td>0</td>
         </tr>
         <tr class="a">
            <td>
               <a href="#f-_Users_ataib_workspace_SFV2_force-app_main_default_classes_APC005_PreinscriptionsEnCoursCtrl_Test.cls">/Users/ataib/workspace/SFV2/force-app/main/default/classes/APC005_PreinscriptionsEnCoursCtrl_Test.cls</a>
            </td>
            <td>0</td>
            <td>0</td>
            <td>0</td>
            <td>1</td>
            <td>0</td>
         </tr>
         <tr class="b">
            <td>
               <a href="#f-_Users_ataib_workspace_SFV2_force-app_main_default_classes_APC007_ShowCrechesLpcrController.cls">/Users/ataib/workspace/SFV2/force-app/main/default/classes/APC007_ShowCrechesLpcrController.cls</a>
            </td>
            <td>0</td>
            <td>0</td>
            <td>1</td>
            <td>0</td>
            <td>0</td>
         </tr>
         <tr class="a">
            <td>
               <a href="#f-_Users_ataib_workspace_SFV2_force-app_main_default_classes_APC007_ShowCrechesLpcrController_Test.cls">/Users/ataib/workspace/SFV2/force-app/main/default/classes/APC007_ShowCrechesLpcrController_Test.cls</a>
            </td>
            <td>0</td>
            <td>0</td>
            <td>0</td>
            <td>1</td>
            <td>0</td>
         </tr>
         <tr class="b">
            <td>
               <a href="#f-_Users_ataib_workspace_SFV2_force-app_main_default_classes_MCK001_SendMailMock.cls">/Users/ataib/workspace/SFV2/force-app/main/default/classes/MCK001_SendMailMock.cls</a>
            </td>
            <td>0</td>
            <td>0</td>
            <td>1</td>
            <td>0</td>
            <td>0</td>
         </tr>
         <tr class="a">
            <td>
               <a href="#f-_Users_ataib_workspace_SFV2_force-app_main_default_classes_SM002_EventServices_TEST.cls">/Users/ataib/workspace/SFV2/force-app/main/default/classes/SM002_EventServices_TEST.cls</a>
            </td>
            <td>0</td>
            <td>0</td>
            <td>1</td>
            <td>0</td>
            <td>0</td>
         </tr>
         <tr class="b">
            <td>
               <a href="#f-_Users_ataib_workspace_SFV2_force-app_main_default_classes_SM004_OpportunityServices_Test.cls">/Users/ataib/workspace/SFV2/force-app/main/default/classes/SM004_OpportunityServices_Test.cls</a>
            </td>
            <td>0</td>
            <td>0</td>
            <td>1</td>
            <td>0</td>
            <td>0</td>
         </tr>
         <tr class="a">
            <td>
               <a href="#f-_Users_ataib_workspace_SFV2_force-app_main_default_classes_SM010_ContractServices_Test.cls">/Users/ataib/workspace/SFV2/force-app/main/default/classes/SM010_ContractServices_Test.cls</a>
            </td>
            <td>0</td>
            <td>0</td>
            <td>1</td>
            <td>0</td>
            <td>0</td>
         </tr>
         <tr class="b">
            <td>
               <a href="#f-_Users_ataib_workspace_SFV2_force-app_main_default_classes_SM015_InvoiceServices.cls">/Users/ataib/workspace/SFV2/force-app/main/default/classes/SM015_InvoiceServices.cls</a>
            </td>
            <td>0</td>
            <td>0</td>
            <td>1</td>
            <td>0</td>
            <td>0</td>
         </tr>
         <tr class="a">
            <td>
               <a href="#f-_Users_ataib_workspace_SFV2_force-app_main_default_classes_SM017_SendDocument_Callout.cls">/Users/ataib/workspace/SFV2/force-app/main/default/classes/SM017_SendDocument_Callout.cls</a>
            </td>
            <td>0</td>
            <td>0</td>
            <td>1</td>
            <td>0</td>
            <td>0</td>
         </tr>
         <tr class="b">
            <td>
               <a href="#f-_Users_ataib_workspace_SFV2_force-app_main_default_classes_SM018_AttachmentService_Test.cls">/Users/ataib/workspace/SFV2/force-app/main/default/classes/SM018_AttachmentService_Test.cls</a>
            </td>
            <td>0</td>
            <td>0</td>
            <td>0</td>
            <td>1</td>
            <td>0</td>
         </tr>
         <tr class="a">
            <td>
               <a href="#f-_Users_ataib_workspace_SFV2_force-app_main_default_classes_SM020_PresinscriptionInvockeService_Test.cls">/Users/ataib/workspace/SFV2/force-app/main/default/classes/SM020_PresinscriptionInvockeService_Test.cls</a>
            </td>
            <td>0</td>
            <td>0</td>
            <td>0</td>
            <td>1</td>
            <td>0</td>
         </tr>
         <tr class="b">
            <td>
               <a href="#f-_Users_ataib_workspace_SFV2_force-app_main_default_classes_UM001_LogManager_Test.cls">/Users/ataib/workspace/SFV2/force-app/main/default/classes/UM001_LogManager_Test.cls</a>
            </td>
            <td>0</td>
            <td>0</td>
            <td>0</td>
            <td>1</td>
            <td>0</td>
         </tr>
         <tr class="a">
            <td>
               <a href="#f-_Users_ataib_workspace_SFV2_force-app_main_default_classes_UM009_Callback.cls">/Users/ataib/workspace/SFV2/force-app/main/default/classes/UM009_Callback.cls</a>
            </td>
            <td>0</td>
            <td>0</td>
            <td>1</td>
            <td>0</td>
            <td>0</td>
         </tr>
         <tr class="b">
            <td>
               <a href="#f-_Users_ataib_workspace_SFV2_force-app_main_default_classes_VFC001_GenererDocAnn2_Test.cls">/Users/ataib/workspace/SFV2/force-app/main/default/classes/VFC001_GenererDocAnn2_Test.cls</a>
            </td>
            <td>0</td>
            <td>0</td>
            <td>0</td>
            <td>1</td>
            <td>0</td>
         </tr>
      </table>
      <hr size="1" width="100%" align="left"/>
      <a name="f-_Users_ataib_workspace_SFV2_force-app_main_default_classes_APB001_ProcessLPCR_Log.cls"/>
      <h3>File /Users/ataib/workspace/SFV2/force-app/main/default/classes/APB001_ProcessLPCR_Log.cls</h3>
      <table class="log" border="0" cellpadding="5" cellspacing="2" width="100%">
         <tr>
            <th style="width:60px;">Violation</th>
            <th>Error Description</th>
            <th style="width:40px;">Line</th>
         </tr>
         <tr class="a">
            <td>
               <div class="p3">3</div>
            </td>
            <td>
						[Best Practices.AvoidGlobalModifier]
						 -
						 <a href="https://pmd.github.io/pmd-6.25.0/pmd_rules_apex_bestpractices.html#avoidglobalmodifier">
Avoid using global modifier
</a>
            </td>
            <td>6 - 37</td>
         </tr>
      </table>
      <a href="#top">Back to top</a>
      <a name="f-_Users_ataib_workspace_SFV2_force-app_main_default_classes_APB001_ProcessLPCR_Log_Test.cls"/>
      <h3>File /Users/ataib/workspace/SFV2/force-app/main/default/classes/APB001_ProcessLPCR_Log_Test.cls</h3>
      <table class="log" border="0" cellpadding="5" cellspacing="2" width="100%">
         <tr>
            <th style="width:60px;">Violation</th>
            <th>Error Description</th>
            <th style="width:40px;">Line</th>
         </tr>
         <tr class="a">
            <td>
               <div class="p3">3</div>
            </td>
            <td>
						[Best Practices.ApexAssertionsShouldIncludeMessage]
						 -
						 <a href="https://pmd.github.io/pmd-6.25.0/pmd_rules_apex_bestpractices.html#apexassertionsshouldincludemessage">
'System.assertEquals' should have 3 parameters.
</a>
            </td>
            <td>20 - 20</td>
         </tr>
      </table>
      <a href="#top">Back to top</a>
      <a name="f-_Users_ataib_workspace_SFV2_force-app_main_default_classes_APB002_RenewalContract.cls"/>
      <h3>File /Users/ataib/workspace/SFV2/force-app/main/default/classes/APB002_RenewalContract.cls</h3>
      <table class="log" border="0" cellpadding="5" cellspacing="2" width="100%">
         <tr>
            <th style="width:60px;">Violation</th>
            <th>Error Description</th>
            <th style="width:40px;">Line</th>
         </tr>
         <tr class="a">
            <td>
               <div class="p3">3</div>
            </td>
            <td>
						[Best Practices.AvoidGlobalModifier]
						 -
						 <a href="https://pmd.github.io/pmd-6.25.0/pmd_rules_apex_bestpractices.html#avoidglobalmodifier">
Avoid using global modifier
</a>
            </td>
            <td>6 - 62</td>
         </tr>
      </table>
      <a href="#top">Back to top</a>
      <a name="f-_Users_ataib_workspace_SFV2_force-app_main_default_classes_APB002_RenewalContract_Test.cls"/>
      <h3>File /Users/ataib/workspace/SFV2/force-app/main/default/classes/APB002_RenewalContract_Test.cls</h3>
      <table class="log" border="0" cellpadding="5" cellspacing="2" width="100%">
         <tr>
            <th style="width:60px;">Violation</th>
            <th>Error Description</th>
            <th style="width:40px;">Line</th>
         </tr>
         <tr class="a">
            <td>
               <div class="p2">2</div>
            </td>
            <td>
						[Best Practices.ApexUnitTestClassShouldHaveAsserts]
						 -
						 <a href="https://pmd.github.io/pmd-6.25.0/pmd_rules_apex_bestpractices.html#apexunittestclassshouldhaveasserts">
Apex unit test classes should have at least one System.assert() or assertEquals() or AssertNotEquals() call
</a>
            </td>
            <td>35 - 55</td>
         </tr>
      </table>
      <a href="#top">Back to top</a>
      <a name="f-_Users_ataib_workspace_SFV2_force-app_main_default_classes_APB003_CreateOrderFromQuote.cls"/>
      <h3>File /Users/ataib/workspace/SFV2/force-app/main/default/classes/APB003_CreateOrderFromQuote.cls</h3>
      <table class="log" border="0" cellpadding="5" cellspacing="2" width="100%">
         <tr>
            <th style="width:60px;">Violation</th>
            <th>Error Description</th>
            <th style="width:40px;">Line</th>
         </tr>
         <tr class="a">
            <td>
               <div class="p3">3</div>
            </td>
            <td>
						[Best Practices.AvoidGlobalModifier]
						 -
						 <a href="https://pmd.github.io/pmd-6.25.0/pmd_rules_apex_bestpractices.html#avoidglobalmodifier">
Avoid using global modifier
</a>
            </td>
            <td>6 - 72</td>
         </tr>
      </table>
      <a href="#top">Back to top</a>
      <a name="f-_Users_ataib_workspace_SFV2_force-app_main_default_classes_APB004_ActivateOrder.cls"/>
      <h3>File /Users/ataib/workspace/SFV2/force-app/main/default/classes/APB004_ActivateOrder.cls</h3>
      <table class="log" border="0" cellpadding="5" cellspacing="2" width="100%">
         <tr>
            <th style="width:60px;">Violation</th>
            <th>Error Description</th>
            <th style="width:40px;">Line</th>
         </tr>
         <tr class="a">
            <td>
               <div class="p3">3</div>
            </td>
            <td>
						[Best Practices.AvoidGlobalModifier]
						 -
						 <a href="https://pmd.github.io/pmd-6.25.0/pmd_rules_apex_bestpractices.html#avoidglobalmodifier">
Avoid using global modifier
</a>
            </td>
            <td>6 - 60</td>
         </tr>
      </table>
      <a href="#top">Back to top</a>
      <a name="f-_Users_ataib_workspace_SFV2_force-app_main_default_classes_APB004_ActivateOrder_Test.cls"/>
      <h3>File /Users/ataib/workspace/SFV2/force-app/main/default/classes/APB004_ActivateOrder_Test.cls</h3>
      <table class="log" border="0" cellpadding="5" cellspacing="2" width="100%">
         <tr>
            <th style="width:60px;">Violation</th>
            <th>Error Description</th>
            <th style="width:40px;">Line</th>
         </tr>
         <tr class="a">
            <td>
               <div class="p2">2</div>
            </td>
            <td>
						[Best Practices.ApexUnitTestClassShouldHaveAsserts]
						 -
						 <a href="https://pmd.github.io/pmd-6.25.0/pmd_rules_apex_bestpractices.html#apexunittestclassshouldhaveasserts">
Apex unit test classes should have at least one System.assert() or assertEquals() or AssertNotEquals() call
</a>
            </td>
            <td>54 - 71</td>
         </tr>
      </table>
      <a href="#top">Back to top</a>
      <a name="f-_Users_ataib_workspace_SFV2_force-app_main_default_classes_APB005_GenerateContractFromOrder.cls"/>
      <h3>File /Users/ataib/workspace/SFV2/force-app/main/default/classes/APB005_GenerateContractFromOrder.cls</h3>
      <table class="log" border="0" cellpadding="5" cellspacing="2" width="100%">
         <tr>
            <th style="width:60px;">Violation</th>
            <th>Error Description</th>
            <th style="width:40px;">Line</th>
         </tr>
         <tr class="a">
            <td>
               <div class="p3">3</div>
            </td>
            <td>
						[Best Practices.AvoidGlobalModifier]
						 -
						 <a href="https://pmd.github.io/pmd-6.25.0/pmd_rules_apex_bestpractices.html#avoidglobalmodifier">
Avoid using global modifier
</a>
            </td>
            <td>6 - 60</td>
         </tr>
      </table>
      <a href="#top">Back to top</a>
      <a name="f-_Users_ataib_workspace_SFV2_force-app_main_default_classes_APB005_GenerateContractFromOrder_Test.cls"/>
      <h3>File /Users/ataib/workspace/SFV2/force-app/main/default/classes/APB005_GenerateContractFromOrder_Test.cls</h3>
      <table class="log" border="0" cellpadding="5" cellspacing="2" width="100%">
         <tr>
            <th style="width:60px;">Violation</th>
            <th>Error Description</th>
            <th style="width:40px;">Line</th>
         </tr>
         <tr class="a">
            <td>
               <div class="p2">2</div>
            </td>
            <td>
						[Best Practices.ApexUnitTestClassShouldHaveAsserts]
						 -
						 <a href="https://pmd.github.io/pmd-6.25.0/pmd_rules_apex_bestpractices.html#apexunittestclassshouldhaveasserts">
Apex unit test classes should have at least one System.assert() or assertEquals() or AssertNotEquals() call
</a>
            </td>
            <td>56 - 74</td>
         </tr>
      </table>
      <a href="#top">Back to top</a>
      <a name="f-_Users_ataib_workspace_SFV2_force-app_main_default_classes_APB006_PrepaRenewalContract.cls"/>
      <h3>File /Users/ataib/workspace/SFV2/force-app/main/default/classes/APB006_PrepaRenewalContract.cls</h3>
      <table class="log" border="0" cellpadding="5" cellspacing="2" width="100%">
         <tr>
            <th style="width:60px;">Violation</th>
            <th>Error Description</th>
            <th style="width:40px;">Line</th>
         </tr>
         <tr class="a">
            <td>
               <div class="p3">3</div>
            </td>
            <td>
						[Best Practices.AvoidGlobalModifier]
						 -
						 <a href="https://pmd.github.io/pmd-6.25.0/pmd_rules_apex_bestpractices.html#avoidglobalmodifier">
Avoid using global modifier
</a>
            </td>
            <td>6 - 89</td>
         </tr>
      </table>
      <a href="#top">Back to top</a>
      <a name="f-_Users_ataib_workspace_SFV2_force-app_main_default_classes_APB006_PrepaRenewalContract_Test.cls"/>
      <h3>File /Users/ataib/workspace/SFV2/force-app/main/default/classes/APB006_PrepaRenewalContract_Test.cls</h3>
      <table class="log" border="0" cellpadding="5" cellspacing="2" width="100%">
         <tr>
            <th style="width:60px;">Violation</th>
            <th>Error Description</th>
            <th style="width:40px;">Line</th>
         </tr>
         <tr class="a">
            <td>
               <div class="p2">2</div>
            </td>
            <td>
						[Best Practices.ApexUnitTestClassShouldHaveAsserts]
						 -
						 <a href="https://pmd.github.io/pmd-6.25.0/pmd_rules_apex_bestpractices.html#apexunittestclassshouldhaveasserts">
Apex unit test classes should have at least one System.assert() or assertEquals() or AssertNotEquals() call
</a>
            </td>
            <td>143 - 160</td>
         </tr>
      </table>
      <a href="#top">Back to top</a>
      <a name="f-_Users_ataib_workspace_SFV2_force-app_main_default_classes_APB007_AllPriceBookClasses_Tests.cls"/>
      <h3>File /Users/ataib/workspace/SFV2/force-app/main/default/classes/APB007_AllPriceBookClasses_Tests.cls</h3>
      <table class="log" border="0" cellpadding="5" cellspacing="2" width="100%">
         <tr>
            <th style="width:60px;">Violation</th>
            <th>Error Description</th>
            <th style="width:40px;">Line</th>
         </tr>
         <tr class="a">
            <td>
               <div class="p3">3</div>
            </td>
            <td>
						[Best Practices.ApexAssertionsShouldIncludeMessage]
						 -
						 <a href="https://pmd.github.io/pmd-6.25.0/pmd_rules_apex_bestpractices.html#apexassertionsshouldincludemessage">
'System.assertEquals' should have 3 parameters.
</a>
            </td>
            <td>224 - 224</td>
         </tr>
         <tr class="b">
            <td>
               <div class="p3">3</div>
            </td>
            <td>
						[Best Practices.ApexAssertionsShouldIncludeMessage]
						 -
						 <a href="https://pmd.github.io/pmd-6.25.0/pmd_rules_apex_bestpractices.html#apexassertionsshouldincludemessage">
'System.assertEquals' should have 3 parameters.
</a>
            </td>
            <td>225 - 225</td>
         </tr>
      </table>
      <a href="#top">Back to top</a>
      <a name="f-_Users_ataib_workspace_SFV2_force-app_main_default_classes_APB007_TraitementModificationEntrante.cls"/>
      <h3>File /Users/ataib/workspace/SFV2/force-app/main/default/classes/APB007_TraitementModificationEntrante.cls</h3>
      <table class="log" border="0" cellpadding="5" cellspacing="2" width="100%">
         <tr>
            <th style="width:60px;">Violation</th>
            <th>Error Description</th>
            <th style="width:40px;">Line</th>
         </tr>
         <tr class="a">
            <td>
               <div class="p3">3</div>
            </td>
            <td>
						[Best Practices.AvoidGlobalModifier]
						 -
						 <a href="https://pmd.github.io/pmd-6.25.0/pmd_rules_apex_bestpractices.html#avoidglobalmodifier">
Avoid using global modifier
</a>
            </td>
            <td>7 - 56</td>
         </tr>
      </table>
      <a href="#top">Back to top</a>
      <a name="f-_Users_ataib_workspace_SFV2_force-app_main_default_classes_APB008_ResetStartEndDatesOnContract.cls"/>
      <h3>File /Users/ataib/workspace/SFV2/force-app/main/default/classes/APB008_ResetStartEndDatesOnContract.cls</h3>
      <table class="log" border="0" cellpadding="5" cellspacing="2" width="100%">
         <tr>
            <th style="width:60px;">Violation</th>
            <th>Error Description</th>
            <th style="width:40px;">Line</th>
         </tr>
         <tr class="a">
            <td>
               <div class="p3">3</div>
            </td>
            <td>
						[Best Practices.AvoidGlobalModifier]
						 -
						 <a href="https://pmd.github.io/pmd-6.25.0/pmd_rules_apex_bestpractices.html#avoidglobalmodifier">
Avoid using global modifier
</a>
            </td>
            <td>6 - 62</td>
         </tr>
      </table>
      <a href="#top">Back to top</a>
      <a name="f-_Users_ataib_workspace_SFV2_force-app_main_default_classes_APB009_GenerateLienFamilleFacture.cls"/>
      <h3>File /Users/ataib/workspace/SFV2/force-app/main/default/classes/APB009_GenerateLienFamilleFacture.cls</h3>
      <table class="log" border="0" cellpadding="5" cellspacing="2" width="100%">
         <tr>
            <th style="width:60px;">Violation</th>
            <th>Error Description</th>
            <th style="width:40px;">Line</th>
         </tr>
         <tr class="a">
            <td>
               <div class="p3">3</div>
            </td>
            <td>
						[Best Practices.AvoidGlobalModifier]
						 -
						 <a href="https://pmd.github.io/pmd-6.25.0/pmd_rules_apex_bestpractices.html#avoidglobalmodifier">
Avoid using global modifier
</a>
            </td>
            <td>6 - 147</td>
         </tr>
      </table>
      <a href="#top">Back to top</a>
      <a name="f-_Users_ataib_workspace_SFV2_force-app_main_default_classes_APB009_GenerateLienFamilleFacture_Test.cls"/>
      <h3>File /Users/ataib/workspace/SFV2/force-app/main/default/classes/APB009_GenerateLienFamilleFacture_Test.cls</h3>
      <table class="log" border="0" cellpadding="5" cellspacing="2" width="100%">
         <tr>
            <th style="width:60px;">Violation</th>
            <th>Error Description</th>
            <th style="width:40px;">Line</th>
         </tr>
         <tr class="a">
            <td>
               <div class="p3">3</div>
            </td>
            <td>
						[Best Practices.ApexAssertionsShouldIncludeMessage]
						 -
						 <a href="https://pmd.github.io/pmd-6.25.0/pmd_rules_apex_bestpractices.html#apexassertionsshouldincludemessage">
'System.assertEquals' should have 3 parameters.
</a>
            </td>
            <td>280 - 280</td>
         </tr>
         <tr class="b">
            <td>
               <div class="p3">3</div>
            </td>
            <td>
						[Best Practices.ApexAssertionsShouldIncludeMessage]
						 -
						 <a href="https://pmd.github.io/pmd-6.25.0/pmd_rules_apex_bestpractices.html#apexassertionsshouldincludemessage">
'System.assertEquals' should have 3 parameters.
</a>
            </td>
            <td>281 - 281</td>
         </tr>
      </table>
      <a href="#top">Back to top</a>
      <a name="f-_Users_ataib_workspace_SFV2_force-app_main_default_classes_APB009_ProcessYearlyOrderProduct.cls"/>
      <h3>File /Users/ataib/workspace/SFV2/force-app/main/default/classes/APB009_ProcessYearlyOrderProduct.cls</h3>
      <table class="log" border="0" cellpadding="5" cellspacing="2" width="100%">
         <tr>
            <th style="width:60px;">Violation</th>
            <th>Error Description</th>
            <th style="width:40px;">Line</th>
         </tr>
         <tr class="a">
            <td>
               <div class="p3">3</div>
            </td>
            <td>
						[Best Practices.AvoidGlobalModifier]
						 -
						 <a href="https://pmd.github.io/pmd-6.25.0/pmd_rules_apex_bestpractices.html#avoidglobalmodifier">
Avoid using global modifier
</a>
            </td>
            <td>6 - 65</td>
         </tr>
      </table>
      <a href="#top">Back to top</a>
      <a name="f-_Users_ataib_workspace_SFV2_force-app_main_default_classes_APB010_ProcessDailyOrderProduct.cls"/>
      <h3>File /Users/ataib/workspace/SFV2/force-app/main/default/classes/APB010_ProcessDailyOrderProduct.cls</h3>
      <table class="log" border="0" cellpadding="5" cellspacing="2" width="100%">
         <tr>
            <th style="width:60px;">Violation</th>
            <th>Error Description</th>
            <th style="width:40px;">Line</th>
         </tr>
         <tr class="a">
            <td>
               <div class="p3">3</div>
            </td>
            <td>
						[Best Practices.AvoidGlobalModifier]
						 -
						 <a href="https://pmd.github.io/pmd-6.25.0/pmd_rules_apex_bestpractices.html#avoidglobalmodifier">
Avoid using global modifier
</a>
            </td>
            <td>6 - 125</td>
         </tr>
      </table>
      <a href="#top">Back to top</a>
      <a name="f-_Users_ataib_workspace_SFV2_force-app_main_default_classes_APB011_SetInvoiceCommentaire.cls"/>
      <h3>File /Users/ataib/workspace/SFV2/force-app/main/default/classes/APB011_SetInvoiceCommentaire.cls</h3>
      <table class="log" border="0" cellpadding="5" cellspacing="2" width="100%">
         <tr>
            <th style="width:60px;">Violation</th>
            <th>Error Description</th>
            <th style="width:40px;">Line</th>
         </tr>
         <tr class="a">
            <td>
               <div class="p3">3</div>
            </td>
            <td>
						[Best Practices.AvoidGlobalModifier]
						 -
						 <a href="https://pmd.github.io/pmd-6.25.0/pmd_rules_apex_bestpractices.html#avoidglobalmodifier">
Avoid using global modifier
</a>
            </td>
            <td>6 - 59</td>
         </tr>
      </table>
      <a href="#top">Back to top</a>
      <a name="f-_Users_ataib_workspace_SFV2_force-app_main_default_classes_APC001_LeadFaConverController_Test.cls"/>
      <h3>File /Users/ataib/workspace/SFV2/force-app/main/default/classes/APC001_LeadFaConverController_Test.cls</h3>
      <table class="log" border="0" cellpadding="5" cellspacing="2" width="100%">
         <tr>
            <th style="width:60px;">Violation</th>
            <th>Error Description</th>
            <th style="width:40px;">Line</th>
         </tr>
         <tr class="a">
            <td>
               <div class="p3">3</div>
            </td>
            <td>
						[Best Practices.ApexAssertionsShouldIncludeMessage]
						 -
						 <a href="https://pmd.github.io/pmd-6.25.0/pmd_rules_apex_bestpractices.html#apexassertionsshouldincludemessage">
'System.assertEquals' should have 3 parameters.
</a>
            </td>
            <td>55 - 55</td>
         </tr>
         <tr class="b">
            <td>
               <div class="p3">3</div>
            </td>
            <td>
						[Best Practices.ApexAssertionsShouldIncludeMessage]
						 -
						 <a href="https://pmd.github.io/pmd-6.25.0/pmd_rules_apex_bestpractices.html#apexassertionsshouldincludemessage">
'System.assertEquals' should have 3 parameters.
</a>
            </td>
            <td>63 - 63</td>
         </tr>
         <tr class="a">
            <td>
               <div class="p3">3</div>
            </td>
            <td>
						[Best Practices.ApexAssertionsShouldIncludeMessage]
						 -
						 <a href="https://pmd.github.io/pmd-6.25.0/pmd_rules_apex_bestpractices.html#apexassertionsshouldincludemessage">
'System.assertEquals' should have 3 parameters.
</a>
            </td>
            <td>71 - 71</td>
         </tr>
         <tr class="b">
            <td>
               <div class="p3">3</div>
            </td>
            <td>
						[Best Practices.ApexAssertionsShouldIncludeMessage]
						 -
						 <a href="https://pmd.github.io/pmd-6.25.0/pmd_rules_apex_bestpractices.html#apexassertionsshouldincludemessage">
'System.assertEquals' should have 3 parameters.
</a>
            </td>
            <td>111 - 111</td>
         </tr>
         <tr class="a">
            <td>
               <div class="p3">3</div>
            </td>
            <td>
						[Best Practices.ApexAssertionsShouldIncludeMessage]
						 -
						 <a href="https://pmd.github.io/pmd-6.25.0/pmd_rules_apex_bestpractices.html#apexassertionsshouldincludemessage">
'System.assertNotEquals' should have 3 parameters.
</a>
            </td>
            <td>112 - 112</td>
         </tr>
         <tr class="b">
            <td>
               <div class="p3">3</div>
            </td>
            <td>
						[Best Practices.ApexAssertionsShouldIncludeMessage]
						 -
						 <a href="https://pmd.github.io/pmd-6.25.0/pmd_rules_apex_bestpractices.html#apexassertionsshouldincludemessage">
'System.assertNotEquals' should have 3 parameters.
</a>
            </td>
            <td>113 - 113</td>
         </tr>
         <tr class="a">
            <td>
               <div class="p3">3</div>
            </td>
            <td>
						[Best Practices.ApexAssertionsShouldIncludeMessage]
						 -
						 <a href="https://pmd.github.io/pmd-6.25.0/pmd_rules_apex_bestpractices.html#apexassertionsshouldincludemessage">
'System.assertEquals' should have 3 parameters.
</a>
            </td>
            <td>120 - 120</td>
         </tr>
         <tr class="b">
            <td>
               <div class="p3">3</div>
            </td>
            <td>
						[Best Practices.ApexAssertionsShouldIncludeMessage]
						 -
						 <a href="https://pmd.github.io/pmd-6.25.0/pmd_rules_apex_bestpractices.html#apexassertionsshouldincludemessage">
'System.assertEquals' should have 3 parameters.
</a>
            </td>
            <td>127 - 127</td>
         </tr>
         <tr class="a">
            <td>
               <div class="p3">3</div>
            </td>
            <td>
						[Best Practices.ApexAssertionsShouldIncludeMessage]
						 -
						 <a href="https://pmd.github.io/pmd-6.25.0/pmd_rules_apex_bestpractices.html#apexassertionsshouldincludemessage">
'System.assertEquals' should have 3 parameters.
</a>
            </td>
            <td>135 - 135</td>
         </tr>
         <tr class="b">
            <td>
               <div class="p3">3</div>
            </td>
            <td>
						[Best Practices.ApexAssertionsShouldIncludeMessage]
						 -
						 <a href="https://pmd.github.io/pmd-6.25.0/pmd_rules_apex_bestpractices.html#apexassertionsshouldincludemessage">
'System.assertEquals' should have 3 parameters.
</a>
            </td>
            <td>139 - 139</td>
         </tr>
      </table>
      <a href="#top">Back to top</a>
      <a name="f-_Users_ataib_workspace_SFV2_force-app_main_default_classes_APC004_SendMailController_Test.cls"/>
      <h3>File /Users/ataib/workspace/SFV2/force-app/main/default/classes/APC004_SendMailController_Test.cls</h3>
      <table class="log" border="0" cellpadding="5" cellspacing="2" width="100%">
         <tr>
            <th style="width:60px;">Violation</th>
            <th>Error Description</th>
            <th style="width:40px;">Line</th>
         </tr>
         <tr class="a">
            <td>
               <div class="p2">2</div>
            </td>
            <td>
						[Best Practices.ApexUnitTestClassShouldHaveAsserts]
						 -
						 <a href="https://pmd.github.io/pmd-6.25.0/pmd_rules_apex_bestpractices.html#apexunittestclassshouldhaveasserts">
Apex unit test classes should have at least one System.assert() or assertEquals() or AssertNotEquals() call
</a>
            </td>
            <td>35 - 39</td>
         </tr>
         <tr class="b">
            <td>
               <div class="p2">2</div>
            </td>
            <td>
						[Best Practices.ApexUnitTestClassShouldHaveAsserts]
						 -
						 <a href="https://pmd.github.io/pmd-6.25.0/pmd_rules_apex_bestpractices.html#apexunittestclassshouldhaveasserts">
Apex unit test classes should have at least one System.assert() or assertEquals() or AssertNotEquals() call
</a>
            </td>
            <td>41 - 48</td>
         </tr>
      </table>
      <a href="#top">Back to top</a>
      <a name="f-_Users_ataib_workspace_SFV2_force-app_main_default_classes_APC005_PreinscriptionsEnCoursCtrl_Test.cls"/>
      <h3>File /Users/ataib/workspace/SFV2/force-app/main/default/classes/APC005_PreinscriptionsEnCoursCtrl_Test.cls</h3>
      <table class="log" border="0" cellpadding="5" cellspacing="2" width="100%">
         <tr>
            <th style="width:60px;">Violation</th>
            <th>Error Description</th>
            <th style="width:40px;">Line</th>
         </tr>
         <tr class="a">
            <td>
               <div class="p2">2</div>
            </td>
            <td>
						[Best Practices.ApexUnitTestClassShouldHaveAsserts]
						 -
						 <a href="https://pmd.github.io/pmd-6.25.0/pmd_rules_apex_bestpractices.html#apexunittestclassshouldhaveasserts">
Apex unit test classes should have at least one System.assert() or assertEquals() or AssertNotEquals() call
</a>
            </td>
            <td>27 - 32</td>
         </tr>
      </table>
      <a href="#top">Back to top</a>
      <a name="f-_Users_ataib_workspace_SFV2_force-app_main_default_classes_APC006_CloneQuoteLines_Test.cls"/>
      <h3>File /Users/ataib/workspace/SFV2/force-app/main/default/classes/APC006_CloneQuoteLines_Test.cls</h3>
      <table class="log" border="0" cellpadding="5" cellspacing="2" width="100%">
         <tr>
            <th style="width:60px;">Violation</th>
            <th>Error Description</th>
            <th style="width:40px;">Line</th>
         </tr>
         <tr class="a">
            <td>
               <div class="p2">2</div>
            </td>
            <td>
						[Best Practices.ApexUnitTestClassShouldHaveAsserts]
						 -
						 <a href="https://pmd.github.io/pmd-6.25.0/pmd_rules_apex_bestpractices.html#apexunittestclassshouldhaveasserts">
Apex unit test classes should have at least one System.assert() or assertEquals() or AssertNotEquals() call
</a>
            </td>
            <td>35 - 40</td>
         </tr>
         <tr class="b">
            <td>
               <div class="p2">2</div>
            </td>
            <td>
						[Best Practices.ApexUnitTestClassShouldHaveAsserts]
						 -
						 <a href="https://pmd.github.io/pmd-6.25.0/pmd_rules_apex_bestpractices.html#apexunittestclassshouldhaveasserts">
Apex unit test classes should have at least one System.assert() or assertEquals() or AssertNotEquals() call
</a>
            </td>
            <td>43 - 49</td>
         </tr>
         <tr class="a">
            <td>
               <div class="p2">2</div>
            </td>
            <td>
						[Best Practices.ApexUnitTestClassShouldHaveAsserts]
						 -
						 <a href="https://pmd.github.io/pmd-6.25.0/pmd_rules_apex_bestpractices.html#apexunittestclassshouldhaveasserts">
Apex unit test classes should have at least one System.assert() or assertEquals() or AssertNotEquals() call
</a>
            </td>
            <td>51 - 57</td>
         </tr>
      </table>
      <a href="#top">Back to top</a>
      <a name="f-_Users_ataib_workspace_SFV2_force-app_main_default_classes_APC007_ShowCrechesLpcrController.cls"/>
      <h3>File /Users/ataib/workspace/SFV2/force-app/main/default/classes/APC007_ShowCrechesLpcrController.cls</h3>
      <table class="log" border="0" cellpadding="5" cellspacing="2" width="100%">
         <tr>
            <th style="width:60px;">Violation</th>
            <th>Error Description</th>
            <th style="width:40px;">Line</th>
         </tr>
         <tr class="a">
            <td>
               <div class="p3">3</div>
            </td>
            <td>
						[Best Practices.DebugsShouldUseLoggingLevel]
						 -
						 <a href="https://pmd.github.io/pmd-6.25.0/pmd_rules_apex_bestpractices.html#debugsshoulduselogginglevel">
Debug statements should include a LoggingLevel
</a>
            </td>
            <td>50 - 50</td>
         </tr>
      </table>
      <a href="#top">Back to top</a>
      <a name="f-_Users_ataib_workspace_SFV2_force-app_main_default_classes_APC007_ShowCrechesLpcrController_Test.cls"/>
      <h3>File /Users/ataib/workspace/SFV2/force-app/main/default/classes/APC007_ShowCrechesLpcrController_Test.cls</h3>
      <table class="log" border="0" cellpadding="5" cellspacing="2" width="100%">
         <tr>
            <th style="width:60px;">Violation</th>
            <th>Error Description</th>
            <th style="width:40px;">Line</th>
         </tr>
         <tr class="a">
            <td>
               <div class="p2">2</div>
            </td>
            <td>
						[Best Practices.ApexUnitTestClassShouldHaveAsserts]
						 -
						 <a href="https://pmd.github.io/pmd-6.25.0/pmd_rules_apex_bestpractices.html#apexunittestclassshouldhaveasserts">
Apex unit test classes should have at least one System.assert() or assertEquals() or AssertNotEquals() call
</a>
            </td>
            <td>31 - 42</td>
         </tr>
      </table>
      <a href="#top">Back to top</a>
      <a name="f-_Users_ataib_workspace_SFV2_force-app_main_default_classes_APC008_ResetQuoteLines_Test.cls"/>
      <h3>File /Users/ataib/workspace/SFV2/force-app/main/default/classes/APC008_ResetQuoteLines_Test.cls</h3>
      <table class="log" border="0" cellpadding="5" cellspacing="2" width="100%">
         <tr>
            <th style="width:60px;">Violation</th>
            <th>Error Description</th>
            <th style="width:40px;">Line</th>
         </tr>
         <tr class="a">
            <td>
               <div class="p3">3</div>
            </td>
            <td>
						[Best Practices.ApexAssertionsShouldIncludeMessage]
						 -
						 <a href="https://pmd.github.io/pmd-6.25.0/pmd_rules_apex_bestpractices.html#apexassertionsshouldincludemessage">
'System.assertEquals' should have 3 parameters.
</a>
            </td>
            <td>39 - 39</td>
         </tr>
         <tr class="b">
            <td>
               <div class="p2">2</div>
            </td>
            <td>
						[Best Practices.ApexUnitTestClassShouldHaveAsserts]
						 -
						 <a href="https://pmd.github.io/pmd-6.25.0/pmd_rules_apex_bestpractices.html#apexunittestclassshouldhaveasserts">
Apex unit test classes should have at least one System.assert() or assertEquals() or AssertNotEquals() call
</a>
            </td>
            <td>43 - 49</td>
         </tr>
      </table>
      <a href="#top">Back to top</a>
      <a name="f-_Users_ataib_workspace_SFV2_force-app_main_default_classes_LWC003_UpdateStatusController_Test.cls"/>
      <h3>File /Users/ataib/workspace/SFV2/force-app/main/default/classes/LWC003_UpdateStatusController_Test.cls</h3>
      <table class="log" border="0" cellpadding="5" cellspacing="2" width="100%">
         <tr>
            <th style="width:60px;">Violation</th>
            <th>Error Description</th>
            <th style="width:40px;">Line</th>
         </tr>
         <tr class="a">
            <td>
               <div class="p2">2</div>
            </td>
            <td>
						[Best Practices.ApexUnitTestClassShouldHaveAsserts]
						 -
						 <a href="https://pmd.github.io/pmd-6.25.0/pmd_rules_apex_bestpractices.html#apexunittestclassshouldhaveasserts">
Apex unit test classes should have at least one System.assert() or assertEquals() or AssertNotEquals() call
</a>
            </td>
            <td>18 - 24</td>
         </tr>
         <tr class="b">
            <td>
               <div class="p2">2</div>
            </td>
            <td>
						[Best Practices.ApexUnitTestClassShouldHaveAsserts]
						 -
						 <a href="https://pmd.github.io/pmd-6.25.0/pmd_rules_apex_bestpractices.html#apexunittestclassshouldhaveasserts">
Apex unit test classes should have at least one System.assert() or assertEquals() or AssertNotEquals() call
</a>
            </td>
            <td>27 - 36</td>
         </tr>
      </table>
      <a href="#top">Back to top</a>
      <a name="f-_Users_ataib_workspace_SFV2_force-app_main_default_classes_MCK001_LPCRHttpCalloutMockImpl.cls"/>
      <h3>File /Users/ataib/workspace/SFV2/force-app/main/default/classes/MCK001_LPCRHttpCalloutMockImpl.cls</h3>
      <table class="log" border="0" cellpadding="5" cellspacing="2" width="100%">
         <tr>
            <th style="width:60px;">Violation</th>
            <th>Error Description</th>
            <th style="width:40px;">Line</th>
         </tr>
         <tr class="a">
            <td>
               <div class="p3">3</div>
            </td>
            <td>
						[Best Practices.AvoidGlobalModifier]
						 -
						 <a href="https://pmd.github.io/pmd-6.25.0/pmd_rules_apex_bestpractices.html#avoidglobalmodifier">
Avoid using global modifier
</a>
            </td>
            <td>7 - 51</td>
         </tr>
         <tr class="b">
            <td>
               <div class="p3">3</div>
            </td>
            <td>
						[Best Practices.DebugsShouldUseLoggingLevel]
						 -
						 <a href="https://pmd.github.io/pmd-6.25.0/pmd_rules_apex_bestpractices.html#debugsshoulduselogginglevel">
Debug statements should include a LoggingLevel
</a>
            </td>
            <td>12 - 12</td>
         </tr>
         <tr class="a">
            <td>
               <div class="p3">3</div>
            </td>
            <td>
						[Best Practices.DebugsShouldUseLoggingLevel]
						 -
						 <a href="https://pmd.github.io/pmd-6.25.0/pmd_rules_apex_bestpractices.html#debugsshoulduselogginglevel">
Debug statements should include a LoggingLevel
</a>
            </td>
            <td>22 - 22</td>
         </tr>
         <tr class="b">
            <td>
               <div class="p3">3</div>
            </td>
            <td>
						[Best Practices.DebugsShouldUseLoggingLevel]
						 -
						 <a href="https://pmd.github.io/pmd-6.25.0/pmd_rules_apex_bestpractices.html#debugsshoulduselogginglevel">
Debug statements should include a LoggingLevel
</a>
            </td>
            <td>23 - 23</td>
         </tr>
         <tr class="a">
            <td>
               <div class="p3">3</div>
            </td>
            <td>
						[Best Practices.DebugsShouldUseLoggingLevel]
						 -
						 <a href="https://pmd.github.io/pmd-6.25.0/pmd_rules_apex_bestpractices.html#debugsshoulduselogginglevel">
Debug statements should include a LoggingLevel
</a>
            </td>
            <td>33 - 33</td>
         </tr>
         <tr class="b">
            <td>
               <div class="p3">3</div>
            </td>
            <td>
						[Best Practices.DebugsShouldUseLoggingLevel]
						 -
						 <a href="https://pmd.github.io/pmd-6.25.0/pmd_rules_apex_bestpractices.html#debugsshoulduselogginglevel">
Debug statements should include a LoggingLevel
</a>
            </td>
            <td>34 - 34</td>
         </tr>
         <tr class="a">
            <td>
               <div class="p3">3</div>
            </td>
            <td>
						[Best Practices.DebugsShouldUseLoggingLevel]
						 -
						 <a href="https://pmd.github.io/pmd-6.25.0/pmd_rules_apex_bestpractices.html#debugsshoulduselogginglevel">
Debug statements should include a LoggingLevel
</a>
            </td>
            <td>44 - 44</td>
         </tr>
         <tr class="b">
            <td>
               <div class="p3">3</div>
            </td>
            <td>
						[Best Practices.DebugsShouldUseLoggingLevel]
						 -
						 <a href="https://pmd.github.io/pmd-6.25.0/pmd_rules_apex_bestpractices.html#debugsshoulduselogginglevel">
Debug statements should include a LoggingLevel
</a>
            </td>
            <td>45 - 45</td>
         </tr>
      </table>
      <a href="#top">Back to top</a>
      <a name="f-_Users_ataib_workspace_SFV2_force-app_main_default_classes_MCK001_SendMailMock.cls"/>
      <h3>File /Users/ataib/workspace/SFV2/force-app/main/default/classes/MCK001_SendMailMock.cls</h3>
      <table class="log" border="0" cellpadding="5" cellspacing="2" width="100%">
         <tr>
            <th style="width:60px;">Violation</th>
            <th>Error Description</th>
            <th style="width:40px;">Line</th>
         </tr>
         <tr class="a">
            <td>
               <div class="p3">3</div>
            </td>
            <td>
						[Best Practices.AvoidGlobalModifier]
						 -
						 <a href="https://pmd.github.io/pmd-6.25.0/pmd_rules_apex_bestpractices.html#avoidglobalmodifier">
Avoid using global modifier
</a>
            </td>
            <td>7 - 21</td>
         </tr>
      </table>
      <a href="#top">Back to top</a>
      <a name="f-_Users_ataib_workspace_SFV2_force-app_main_default_classes_PAD.cls"/>
      <h3>File /Users/ataib/workspace/SFV2/force-app/main/default/classes/PAD.cls</h3>
      <table class="log" border="0" cellpadding="5" cellspacing="2" width="100%">
         <tr>
            <th style="width:60px;">Violation</th>
            <th>Error Description</th>
            <th style="width:40px;">Line</th>
         </tr>
         <tr class="a">
            <td>
               <div class="p3">3</div>
            </td>
            <td>
						[Best Practices.DebugsShouldUseLoggingLevel]
						 -
						 <a href="https://pmd.github.io/pmd-6.25.0/pmd_rules_apex_bestpractices.html#debugsshoulduselogginglevel">
Debug statements should include a LoggingLevel
</a>
            </td>
            <td>29 - 29</td>
         </tr>
         <tr class="b">
            <td>
               <div class="p3">3</div>
            </td>
            <td>
						[Best Practices.DebugsShouldUseLoggingLevel]
						 -
						 <a href="https://pmd.github.io/pmd-6.25.0/pmd_rules_apex_bestpractices.html#debugsshoulduselogginglevel">
Debug statements should include a LoggingLevel
</a>
            </td>
            <td>34 - 34</td>
         </tr>
         <tr class="a">
            <td>
               <div class="p3">3</div>
            </td>
            <td>
						[Best Practices.DebugsShouldUseLoggingLevel]
						 -
						 <a href="https://pmd.github.io/pmd-6.25.0/pmd_rules_apex_bestpractices.html#debugsshoulduselogginglevel">
Debug statements should include a LoggingLevel
</a>
            </td>
            <td>38 - 38</td>
         </tr>
         <tr class="b">
            <td>
               <div class="p3">3</div>
            </td>
            <td>
						[Best Practices.DebugsShouldUseLoggingLevel]
						 -
						 <a href="https://pmd.github.io/pmd-6.25.0/pmd_rules_apex_bestpractices.html#debugsshoulduselogginglevel">
Debug statements should include a LoggingLevel
</a>
            </td>
            <td>42 - 42</td>
         </tr>
      </table>
      <a href="#top">Back to top</a>
      <a name="f-_Users_ataib_workspace_SFV2_force-app_main_default_classes_QuoteExtControllerTests.cls"/>
      <h3>File /Users/ataib/workspace/SFV2/force-app/main/default/classes/QuoteExtControllerTests.cls</h3>
      <table class="log" border="0" cellpadding="5" cellspacing="2" width="100%">
         <tr>
            <th style="width:60px;">Violation</th>
            <th>Error Description</th>
            <th style="width:40px;">Line</th>
         </tr>
         <tr class="a">
            <td>
               <div class="p3">3</div>
            </td>
            <td>
						[Best Practices.ApexAssertionsShouldIncludeMessage]
						 -
						 <a href="https://pmd.github.io/pmd-6.25.0/pmd_rules_apex_bestpractices.html#apexassertionsshouldincludemessage">
'System.assertEquals' should have 3 parameters.
</a>
            </td>
            <td>14 - 14</td>
         </tr>
         <tr class="b">
            <td>
               <div class="p3">3</div>
            </td>
            <td>
						[Best Practices.ApexAssertionsShouldIncludeMessage]
						 -
						 <a href="https://pmd.github.io/pmd-6.25.0/pmd_rules_apex_bestpractices.html#apexassertionsshouldincludemessage">
'System.assertEquals' should have 3 parameters.
</a>
            </td>
            <td>28 - 28</td>
         </tr>
      </table>
      <a href="#top">Back to top</a>
      <a name="f-_Users_ataib_workspace_SFV2_force-app_main_default_classes_SM002_EventServices_TEST.cls"/>
      <h3>File /Users/ataib/workspace/SFV2/force-app/main/default/classes/SM002_EventServices_TEST.cls</h3>
      <table class="log" border="0" cellpadding="5" cellspacing="2" width="100%">
         <tr>
            <th style="width:60px;">Violation</th>
            <th>Error Description</th>
            <th style="width:40px;">Line</th>
         </tr>
         <tr class="a">
            <td>
               <div class="p3">3</div>
            </td>
            <td>
						[Best Practices.ApexAssertionsShouldIncludeMessage]
						 -
						 <a href="https://pmd.github.io/pmd-6.25.0/pmd_rules_apex_bestpractices.html#apexassertionsshouldincludemessage">
'system.assertEquals' should have 3 parameters.
</a>
            </td>
            <td>25 - 25</td>
         </tr>
      </table>
      <a href="#top">Back to top</a>
      <a name="f-_Users_ataib_workspace_SFV2_force-app_main_default_classes_SM003_TaskServices_TEST.cls"/>
      <h3>File /Users/ataib/workspace/SFV2/force-app/main/default/classes/SM003_TaskServices_TEST.cls</h3>
      <table class="log" border="0" cellpadding="5" cellspacing="2" width="100%">
         <tr>
            <th style="width:60px;">Violation</th>
            <th>Error Description</th>
            <th style="width:40px;">Line</th>
         </tr>
         <tr class="a">
            <td>
               <div class="p3">3</div>
            </td>
            <td>
						[Best Practices.ApexAssertionsShouldIncludeMessage]
						 -
						 <a href="https://pmd.github.io/pmd-6.25.0/pmd_rules_apex_bestpractices.html#apexassertionsshouldincludemessage">
'system.assertEquals' should have 3 parameters.
</a>
            </td>
            <td>29 - 29</td>
         </tr>
         <tr class="b">
            <td>
               <div class="p3">3</div>
            </td>
            <td>
						[Best Practices.ApexAssertionsShouldIncludeMessage]
						 -
						 <a href="https://pmd.github.io/pmd-6.25.0/pmd_rules_apex_bestpractices.html#apexassertionsshouldincludemessage">
'system.assertEquals' should have 3 parameters.
</a>
            </td>
            <td>30 - 30</td>
         </tr>
         <tr class="a">
            <td>
               <div class="p3">3</div>
            </td>
            <td>
						[Best Practices.ApexAssertionsShouldIncludeMessage]
						 -
						 <a href="https://pmd.github.io/pmd-6.25.0/pmd_rules_apex_bestpractices.html#apexassertionsshouldincludemessage">
'system.assertEquals' should have 3 parameters.
</a>
            </td>
            <td>31 - 31</td>
         </tr>
      </table>
      <a href="#top">Back to top</a>
      <a name="f-_Users_ataib_workspace_SFV2_force-app_main_default_classes_SM004_OpportunityServices_Test.cls"/>
      <h3>File /Users/ataib/workspace/SFV2/force-app/main/default/classes/SM004_OpportunityServices_Test.cls</h3>
      <table class="log" border="0" cellpadding="5" cellspacing="2" width="100%">
         <tr>
            <th style="width:60px;">Violation</th>
            <th>Error Description</th>
            <th style="width:40px;">Line</th>
         </tr>
         <tr class="a">
            <td>
               <div class="p3">3</div>
            </td>
            <td>
						[Best Practices.ApexAssertionsShouldIncludeMessage]
						 -
						 <a href="https://pmd.github.io/pmd-6.25.0/pmd_rules_apex_bestpractices.html#apexassertionsshouldincludemessage">
'System.assert' should have 2 parameters.
</a>
            </td>
            <td>38 - 38</td>
         </tr>
      </table>
      <a href="#top">Back to top</a>
      <a name="f-_Users_ataib_workspace_SFV2_force-app_main_default_classes_SM007_LeadServices_Test.cls"/>
      <h3>File /Users/ataib/workspace/SFV2/force-app/main/default/classes/SM007_LeadServices_Test.cls</h3>
      <table class="log" border="0" cellpadding="5" cellspacing="2" width="100%">
         <tr>
            <th style="width:60px;">Violation</th>
            <th>Error Description</th>
            <th style="width:40px;">Line</th>
         </tr>
         <tr class="a">
            <td>
               <div class="p2">2</div>
            </td>
            <td>
						[Best Practices.ApexUnitTestClassShouldHaveAsserts]
						 -
						 <a href="https://pmd.github.io/pmd-6.25.0/pmd_rules_apex_bestpractices.html#apexunittestclassshouldhaveasserts">
Apex unit test classes should have at least one System.assert() or assertEquals() or AssertNotEquals() call
</a>
            </td>
            <td>38 - 40</td>
         </tr>
         <tr class="b">
            <td>
               <div class="p2">2</div>
            </td>
            <td>
						[Best Practices.ApexUnitTestClassShouldHaveAsserts]
						 -
						 <a href="https://pmd.github.io/pmd-6.25.0/pmd_rules_apex_bestpractices.html#apexunittestclassshouldhaveasserts">
Apex unit test classes should have at least one System.assert() or assertEquals() or AssertNotEquals() call
</a>
            </td>
            <td>42 - 44</td>
         </tr>
         <tr class="a">
            <td>
               <div class="p2">2</div>
            </td>
            <td>
						[Best Practices.ApexUnitTestClassShouldHaveAsserts]
						 -
						 <a href="https://pmd.github.io/pmd-6.25.0/pmd_rules_apex_bestpractices.html#apexunittestclassshouldhaveasserts">
Apex unit test classes should have at least one System.assert() or assertEquals() or AssertNotEquals() call
</a>
            </td>
            <td>46 - 48</td>
         </tr>
         <tr class="b">
            <td>
               <div class="p2">2</div>
            </td>
            <td>
						[Best Practices.ApexUnitTestClassShouldHaveAsserts]
						 -
						 <a href="https://pmd.github.io/pmd-6.25.0/pmd_rules_apex_bestpractices.html#apexunittestclassshouldhaveasserts">
Apex unit test classes should have at least one System.assert() or assertEquals() or AssertNotEquals() call
</a>
            </td>
            <td>50 - 52</td>
         </tr>
         <tr class="a">
            <td>
               <div class="p2">2</div>
            </td>
            <td>
						[Best Practices.ApexUnitTestMethodShouldHaveIsTestAnnotation]
						 -
						 <a href="https://pmd.github.io/pmd-6.25.0/pmd_rules_apex_bestpractices.html#apexunittestmethodshouldhaveistestannotation">
'syncLeadRT' method should have @IsTest annotation.
</a>
            </td>
            <td>53 - 90</td>
         </tr>
         <tr class="b">
            <td>
               <div class="p3">3</div>
            </td>
            <td>
						[Best Practices.ApexAssertionsShouldIncludeMessage]
						 -
						 <a href="https://pmd.github.io/pmd-6.25.0/pmd_rules_apex_bestpractices.html#apexassertionsshouldincludemessage">
'System.assert' should have 2 parameters.
</a>
            </td>
            <td>73 - 73</td>
         </tr>
         <tr class="a">
            <td>
               <div class="p3">3</div>
            </td>
            <td>
						[Best Practices.ApexAssertionsShouldIncludeMessage]
						 -
						 <a href="https://pmd.github.io/pmd-6.25.0/pmd_rules_apex_bestpractices.html#apexassertionsshouldincludemessage">
'System.assertEquals' should have 3 parameters.
</a>
            </td>
            <td>84 - 84</td>
         </tr>
         <tr class="b">
            <td>
               <div class="p3">3</div>
            </td>
            <td>
						[Best Practices.ApexAssertionsShouldIncludeMessage]
						 -
						 <a href="https://pmd.github.io/pmd-6.25.0/pmd_rules_apex_bestpractices.html#apexassertionsshouldincludemessage">
'System.assertEquals' should have 3 parameters.
</a>
            </td>
            <td>85 - 85</td>
         </tr>
         <tr class="a">
            <td>
               <div class="p3">3</div>
            </td>
            <td>
						[Best Practices.ApexAssertionsShouldIncludeMessage]
						 -
						 <a href="https://pmd.github.io/pmd-6.25.0/pmd_rules_apex_bestpractices.html#apexassertionsshouldincludemessage">
'System.assertEquals' should have 3 parameters.
</a>
            </td>
            <td>86 - 86</td>
         </tr>
         <tr class="b">
            <td>
               <div class="p3">3</div>
            </td>
            <td>
						[Best Practices.ApexAssertionsShouldIncludeMessage]
						 -
						 <a href="https://pmd.github.io/pmd-6.25.0/pmd_rules_apex_bestpractices.html#apexassertionsshouldincludemessage">
'System.assertEquals' should have 3 parameters.
</a>
            </td>
            <td>109 - 109</td>
         </tr>
         <tr class="a">
            <td>
               <div class="p3">3</div>
            </td>
            <td>
						[Best Practices.ApexAssertionsShouldIncludeMessage]
						 -
						 <a href="https://pmd.github.io/pmd-6.25.0/pmd_rules_apex_bestpractices.html#apexassertionsshouldincludemessage">
'System.assertEquals' should have 3 parameters.
</a>
            </td>
            <td>110 - 110</td>
         </tr>
         <tr class="b">
            <td>
               <div class="p3">3</div>
            </td>
            <td>
						[Best Practices.ApexAssertionsShouldIncludeMessage]
						 -
						 <a href="https://pmd.github.io/pmd-6.25.0/pmd_rules_apex_bestpractices.html#apexassertionsshouldincludemessage">
'System.assertEquals' should have 3 parameters.
</a>
            </td>
            <td>111 - 111</td>
         </tr>
         <tr class="a">
            <td>
               <div class="p3">3</div>
            </td>
            <td>
						[Best Practices.ApexAssertionsShouldIncludeMessage]
						 -
						 <a href="https://pmd.github.io/pmd-6.25.0/pmd_rules_apex_bestpractices.html#apexassertionsshouldincludemessage">
'System.assert' should have 2 parameters.
</a>
            </td>
            <td>150 - 150</td>
         </tr>
         <tr class="b">
            <td>
               <div class="p3">3</div>
            </td>
            <td>
						[Best Practices.ApexAssertionsShouldIncludeMessage]
						 -
						 <a href="https://pmd.github.io/pmd-6.25.0/pmd_rules_apex_bestpractices.html#apexassertionsshouldincludemessage">
'System.assertEquals' should have 3 parameters.
</a>
            </td>
            <td>153 - 153</td>
         </tr>
      </table>
      <a href="#top">Back to top</a>
      <a name="f-_Users_ataib_workspace_SFV2_force-app_main_default_classes_SM008_QuoteServices_Test.cls"/>
      <h3>File /Users/ataib/workspace/SFV2/force-app/main/default/classes/SM008_QuoteServices_Test.cls</h3>
      <table class="log" border="0" cellpadding="5" cellspacing="2" width="100%">
         <tr>
            <th style="width:60px;">Violation</th>
            <th>Error Description</th>
            <th style="width:40px;">Line</th>
         </tr>
         <tr class="a">
            <td>
               <div class="p2">2</div>
            </td>
            <td>
						[Best Practices.ApexUnitTestClassShouldHaveAsserts]
						 -
						 <a href="https://pmd.github.io/pmd-6.25.0/pmd_rules_apex_bestpractices.html#apexunittestclassshouldhaveasserts">
Apex unit test classes should have at least one System.assert() or assertEquals() or AssertNotEquals() call
</a>
            </td>
            <td>116 - 117</td>
         </tr>
         <tr class="b">
            <td>
               <div class="p2">2</div>
            </td>
            <td>
						[Best Practices.ApexUnitTestClassShouldHaveAsserts]
						 -
						 <a href="https://pmd.github.io/pmd-6.25.0/pmd_rules_apex_bestpractices.html#apexunittestclassshouldhaveasserts">
Apex unit test classes should have at least one System.assert() or assertEquals() or AssertNotEquals() call
</a>
            </td>
            <td>204 - 220</td>
         </tr>
         <tr class="a">
            <td>
               <div class="p3">3</div>
            </td>
            <td>
						[Best Practices.ApexAssertionsShouldIncludeMessage]
						 -
						 <a href="https://pmd.github.io/pmd-6.25.0/pmd_rules_apex_bestpractices.html#apexassertionsshouldincludemessage">
'System.assertEquals' should have 3 parameters.
</a>
            </td>
            <td>242 - 242</td>
         </tr>
         <tr class="b">
            <td>
               <div class="p3">3</div>
            </td>
            <td>
						[Best Practices.ApexAssertionsShouldIncludeMessage]
						 -
						 <a href="https://pmd.github.io/pmd-6.25.0/pmd_rules_apex_bestpractices.html#apexassertionsshouldincludemessage">
'System.assertEquals' should have 3 parameters.
</a>
            </td>
            <td>315 - 315</td>
         </tr>
      </table>
      <a href="#top">Back to top</a>
      <a name="f-_Users_ataib_workspace_SFV2_force-app_main_default_classes_SM010_ContractServices_Test.cls"/>
      <h3>File /Users/ataib/workspace/SFV2/force-app/main/default/classes/SM010_ContractServices_Test.cls</h3>
      <table class="log" border="0" cellpadding="5" cellspacing="2" width="100%">
         <tr>
            <th style="width:60px;">Violation</th>
            <th>Error Description</th>
            <th style="width:40px;">Line</th>
         </tr>
         <tr class="a">
            <td>
               <div class="p3">3</div>
            </td>
            <td>
						[Best Practices.ApexAssertionsShouldIncludeMessage]
						 -
						 <a href="https://pmd.github.io/pmd-6.25.0/pmd_rules_apex_bestpractices.html#apexassertionsshouldincludemessage">
'System.assertEquals' should have 3 parameters.
</a>
            </td>
            <td>296 - 296</td>
         </tr>
      </table>
      <a href="#top">Back to top</a>
      <a name="f-_Users_ataib_workspace_SFV2_force-app_main_default_classes_SM012_OrderItemServices_Test.cls"/>
      <h3>File /Users/ataib/workspace/SFV2/force-app/main/default/classes/SM012_OrderItemServices_Test.cls</h3>
      <table class="log" border="0" cellpadding="5" cellspacing="2" width="100%">
         <tr>
            <th style="width:60px;">Violation</th>
            <th>Error Description</th>
            <th style="width:40px;">Line</th>
         </tr>
         <tr class="a">
            <td>
               <div class="p3">3</div>
            </td>
            <td>
						[Best Practices.ApexAssertionsShouldIncludeMessage]
						 -
						 <a href="https://pmd.github.io/pmd-6.25.0/pmd_rules_apex_bestpractices.html#apexassertionsshouldincludemessage">
'System.assertEquals' should have 3 parameters.
</a>
            </td>
            <td>164 - 164</td>
         </tr>
         <tr class="b">
            <td>
               <div class="p3">3</div>
            </td>
            <td>
						[Best Practices.ApexAssertionsShouldIncludeMessage]
						 -
						 <a href="https://pmd.github.io/pmd-6.25.0/pmd_rules_apex_bestpractices.html#apexassertionsshouldincludemessage">
'System.assertEquals' should have 3 parameters.
</a>
            </td>
            <td>166 - 166</td>
         </tr>
         <tr class="a">
            <td>
               <div class="p3">3</div>
            </td>
            <td>
						[Best Practices.ApexAssertionsShouldIncludeMessage]
						 -
						 <a href="https://pmd.github.io/pmd-6.25.0/pmd_rules_apex_bestpractices.html#apexassertionsshouldincludemessage">
'System.assertEquals' should have 3 parameters.
</a>
            </td>
            <td>168 - 168</td>
         </tr>
         <tr class="b">
            <td>
               <div class="p3">3</div>
            </td>
            <td>
						[Best Practices.ApexAssertionsShouldIncludeMessage]
						 -
						 <a href="https://pmd.github.io/pmd-6.25.0/pmd_rules_apex_bestpractices.html#apexassertionsshouldincludemessage">
'System.assertEquals' should have 3 parameters.
</a>
            </td>
            <td>170 - 170</td>
         </tr>
         <tr class="a">
            <td>
               <div class="p3">3</div>
            </td>
            <td>
						[Best Practices.ApexAssertionsShouldIncludeMessage]
						 -
						 <a href="https://pmd.github.io/pmd-6.25.0/pmd_rules_apex_bestpractices.html#apexassertionsshouldincludemessage">
'System.assertEquals' should have 3 parameters.
</a>
            </td>
            <td>178 - 178</td>
         </tr>
         <tr class="b">
            <td>
               <div class="p3">3</div>
            </td>
            <td>
						[Best Practices.ApexAssertionsShouldIncludeMessage]
						 -
						 <a href="https://pmd.github.io/pmd-6.25.0/pmd_rules_apex_bestpractices.html#apexassertionsshouldincludemessage">
'System.assertEquals' should have 3 parameters.
</a>
            </td>
            <td>180 - 180</td>
         </tr>
         <tr class="a">
            <td>
               <div class="p2">2</div>
            </td>
            <td>
						[Best Practices.ApexUnitTestClassShouldHaveAsserts]
						 -
						 <a href="https://pmd.github.io/pmd-6.25.0/pmd_rules_apex_bestpractices.html#apexunittestclassshouldhaveasserts">
Apex unit test classes should have at least one System.assert() or assertEquals() or AssertNotEquals() call
</a>
            </td>
            <td>350 - 395</td>
         </tr>
         <tr class="b">
            <td>
               <div class="p3">3</div>
            </td>
            <td>
						[Best Practices.ApexAssertionsShouldIncludeMessage]
						 -
						 <a href="https://pmd.github.io/pmd-6.25.0/pmd_rules_apex_bestpractices.html#apexassertionsshouldincludemessage">
'System.assertEquals' should have 3 parameters.
</a>
            </td>
            <td>510 - 510</td>
         </tr>
         <tr class="a">
            <td>
               <div class="p3">3</div>
            </td>
            <td>
						[Best Practices.ApexAssertionsShouldIncludeMessage]
						 -
						 <a href="https://pmd.github.io/pmd-6.25.0/pmd_rules_apex_bestpractices.html#apexassertionsshouldincludemessage">
'System.assertEquals' should have 3 parameters.
</a>
            </td>
            <td>511 - 511</td>
         </tr>
         <tr class="b">
            <td>
               <div class="p3">3</div>
            </td>
            <td>
						[Best Practices.ApexAssertionsShouldIncludeMessage]
						 -
						 <a href="https://pmd.github.io/pmd-6.25.0/pmd_rules_apex_bestpractices.html#apexassertionsshouldincludemessage">
'System.assertEquals' should have 3 parameters.
</a>
            </td>
            <td>512 - 512</td>
         </tr>
         <tr class="a">
            <td>
               <div class="p3">3</div>
            </td>
            <td>
						[Best Practices.ApexAssertionsShouldIncludeMessage]
						 -
						 <a href="https://pmd.github.io/pmd-6.25.0/pmd_rules_apex_bestpractices.html#apexassertionsshouldincludemessage">
'System.assertEquals' should have 3 parameters.
</a>
            </td>
            <td>513 - 513</td>
         </tr>
         <tr class="b">
            <td>
               <div class="p3">3</div>
            </td>
            <td>
						[Best Practices.ApexAssertionsShouldIncludeMessage]
						 -
						 <a href="https://pmd.github.io/pmd-6.25.0/pmd_rules_apex_bestpractices.html#apexassertionsshouldincludemessage">
'System.assertEquals' should have 3 parameters.
</a>
            </td>
            <td>633 - 633</td>
         </tr>
         <tr class="a">
            <td>
               <div class="p3">3</div>
            </td>
            <td>
						[Best Practices.ApexAssertionsShouldIncludeMessage]
						 -
						 <a href="https://pmd.github.io/pmd-6.25.0/pmd_rules_apex_bestpractices.html#apexassertionsshouldincludemessage">
'System.assertEquals' should have 3 parameters.
</a>
            </td>
            <td>634 - 634</td>
         </tr>
         <tr class="b">
            <td>
               <div class="p3">3</div>
            </td>
            <td>
						[Best Practices.ApexAssertionsShouldIncludeMessage]
						 -
						 <a href="https://pmd.github.io/pmd-6.25.0/pmd_rules_apex_bestpractices.html#apexassertionsshouldincludemessage">
'System.assertEquals' should have 3 parameters.
</a>
            </td>
            <td>635 - 635</td>
         </tr>
         <tr class="a">
            <td>
               <div class="p3">3</div>
            </td>
            <td>
						[Best Practices.ApexAssertionsShouldIncludeMessage]
						 -
						 <a href="https://pmd.github.io/pmd-6.25.0/pmd_rules_apex_bestpractices.html#apexassertionsshouldincludemessage">
'System.assertEquals' should have 3 parameters.
</a>
            </td>
            <td>753 - 753</td>
         </tr>
         <tr class="b">
            <td>
               <div class="p3">3</div>
            </td>
            <td>
						[Best Practices.ApexAssertionsShouldIncludeMessage]
						 -
						 <a href="https://pmd.github.io/pmd-6.25.0/pmd_rules_apex_bestpractices.html#apexassertionsshouldincludemessage">
'System.assertEquals' should have 3 parameters.
</a>
            </td>
            <td>754 - 754</td>
         </tr>
         <tr class="a">
            <td>
               <div class="p3">3</div>
            </td>
            <td>
						[Best Practices.ApexAssertionsShouldIncludeMessage]
						 -
						 <a href="https://pmd.github.io/pmd-6.25.0/pmd_rules_apex_bestpractices.html#apexassertionsshouldincludemessage">
'System.assertEquals' should have 3 parameters.
</a>
            </td>
            <td>755 - 755</td>
         </tr>
         <tr class="b">
            <td>
               <div class="p3">3</div>
            </td>
            <td>
						[Best Practices.ApexAssertionsShouldIncludeMessage]
						 -
						 <a href="https://pmd.github.io/pmd-6.25.0/pmd_rules_apex_bestpractices.html#apexassertionsshouldincludemessage">
'System.assertEquals' should have 3 parameters.
</a>
            </td>
            <td>756 - 756</td>
         </tr>
         <tr class="a">
            <td>
               <div class="p3">3</div>
            </td>
            <td>
						[Best Practices.ApexAssertionsShouldIncludeMessage]
						 -
						 <a href="https://pmd.github.io/pmd-6.25.0/pmd_rules_apex_bestpractices.html#apexassertionsshouldincludemessage">
'System.assertEquals' should have 3 parameters.
</a>
            </td>
            <td>875 - 875</td>
         </tr>
         <tr class="b">
            <td>
               <div class="p3">3</div>
            </td>
            <td>
						[Best Practices.ApexAssertionsShouldIncludeMessage]
						 -
						 <a href="https://pmd.github.io/pmd-6.25.0/pmd_rules_apex_bestpractices.html#apexassertionsshouldincludemessage">
'System.assertEquals' should have 3 parameters.
</a>
            </td>
            <td>876 - 876</td>
         </tr>
         <tr class="a">
            <td>
               <div class="p3">3</div>
            </td>
            <td>
						[Best Practices.ApexAssertionsShouldIncludeMessage]
						 -
						 <a href="https://pmd.github.io/pmd-6.25.0/pmd_rules_apex_bestpractices.html#apexassertionsshouldincludemessage">
'System.assertEquals' should have 3 parameters.
</a>
            </td>
            <td>877 - 877</td>
         </tr>
         <tr class="b">
            <td>
               <div class="p3">3</div>
            </td>
            <td>
						[Best Practices.ApexAssertionsShouldIncludeMessage]
						 -
						 <a href="https://pmd.github.io/pmd-6.25.0/pmd_rules_apex_bestpractices.html#apexassertionsshouldincludemessage">
'System.assertEquals' should have 3 parameters.
</a>
            </td>
            <td>878 - 878</td>
         </tr>
         <tr class="a">
            <td>
               <div class="p3">3</div>
            </td>
            <td>
						[Best Practices.ApexAssertionsShouldIncludeMessage]
						 -
						 <a href="https://pmd.github.io/pmd-6.25.0/pmd_rules_apex_bestpractices.html#apexassertionsshouldincludemessage">
'System.assertEquals' should have 3 parameters.
</a>
            </td>
            <td>992 - 992</td>
         </tr>
         <tr class="b">
            <td>
               <div class="p3">3</div>
            </td>
            <td>
						[Best Practices.ApexAssertionsShouldIncludeMessage]
						 -
						 <a href="https://pmd.github.io/pmd-6.25.0/pmd_rules_apex_bestpractices.html#apexassertionsshouldincludemessage">
'System.assertEquals' should have 3 parameters.
</a>
            </td>
            <td>993 - 993</td>
         </tr>
         <tr class="a">
            <td>
               <div class="p3">3</div>
            </td>
            <td>
						[Best Practices.ApexAssertionsShouldIncludeMessage]
						 -
						 <a href="https://pmd.github.io/pmd-6.25.0/pmd_rules_apex_bestpractices.html#apexassertionsshouldincludemessage">
'System.assertEquals' should have 3 parameters.
</a>
            </td>
            <td>994 - 994</td>
         </tr>
         <tr class="b">
            <td>
               <div class="p3">3</div>
            </td>
            <td>
						[Best Practices.ApexAssertionsShouldIncludeMessage]
						 -
						 <a href="https://pmd.github.io/pmd-6.25.0/pmd_rules_apex_bestpractices.html#apexassertionsshouldincludemessage">
'System.assertEquals' should have 3 parameters.
</a>
            </td>
            <td>995 - 995</td>
         </tr>
         <tr class="a">
            <td>
               <div class="p3">3</div>
            </td>
            <td>
						[Best Practices.ApexAssertionsShouldIncludeMessage]
						 -
						 <a href="https://pmd.github.io/pmd-6.25.0/pmd_rules_apex_bestpractices.html#apexassertionsshouldincludemessage">
'System.assertEquals' should have 3 parameters.
</a>
            </td>
            <td>1111 - 1111</td>
         </tr>
         <tr class="b">
            <td>
               <div class="p3">3</div>
            </td>
            <td>
						[Best Practices.ApexAssertionsShouldIncludeMessage]
						 -
						 <a href="https://pmd.github.io/pmd-6.25.0/pmd_rules_apex_bestpractices.html#apexassertionsshouldincludemessage">
'System.assertEquals' should have 3 parameters.
</a>
            </td>
            <td>1112 - 1112</td>
         </tr>
         <tr class="a">
            <td>
               <div class="p3">3</div>
            </td>
            <td>
						[Best Practices.ApexAssertionsShouldIncludeMessage]
						 -
						 <a href="https://pmd.github.io/pmd-6.25.0/pmd_rules_apex_bestpractices.html#apexassertionsshouldincludemessage">
'System.assertEquals' should have 3 parameters.
</a>
            </td>
            <td>1114 - 1114</td>
         </tr>
         <tr class="b">
            <td>
               <div class="p3">3</div>
            </td>
            <td>
						[Best Practices.ApexAssertionsShouldIncludeMessage]
						 -
						 <a href="https://pmd.github.io/pmd-6.25.0/pmd_rules_apex_bestpractices.html#apexassertionsshouldincludemessage">
'System.assertEquals' should have 3 parameters.
</a>
            </td>
            <td>1230 - 1230</td>
         </tr>
         <tr class="a">
            <td>
               <div class="p3">3</div>
            </td>
            <td>
						[Best Practices.ApexAssertionsShouldIncludeMessage]
						 -
						 <a href="https://pmd.github.io/pmd-6.25.0/pmd_rules_apex_bestpractices.html#apexassertionsshouldincludemessage">
'System.assertEquals' should have 3 parameters.
</a>
            </td>
            <td>1231 - 1231</td>
         </tr>
         <tr class="b">
            <td>
               <div class="p3">3</div>
            </td>
            <td>
						[Best Practices.ApexAssertionsShouldIncludeMessage]
						 -
						 <a href="https://pmd.github.io/pmd-6.25.0/pmd_rules_apex_bestpractices.html#apexassertionsshouldincludemessage">
'System.assertEquals' should have 3 parameters.
</a>
            </td>
            <td>1232 - 1232</td>
         </tr>
         <tr class="a">
            <td>
               <div class="p3">3</div>
            </td>
            <td>
						[Best Practices.ApexAssertionsShouldIncludeMessage]
						 -
						 <a href="https://pmd.github.io/pmd-6.25.0/pmd_rules_apex_bestpractices.html#apexassertionsshouldincludemessage">
'System.assertEquals' should have 3 parameters.
</a>
            </td>
            <td>1237 - 1237</td>
         </tr>
         <tr class="b">
            <td>
               <div class="p3">3</div>
            </td>
            <td>
						[Best Practices.DebugsShouldUseLoggingLevel]
						 -
						 <a href="https://pmd.github.io/pmd-6.25.0/pmd_rules_apex_bestpractices.html#debugsshoulduselogginglevel">
Debug statements should include a LoggingLevel
</a>
            </td>
            <td>1306 - 1306</td>
         </tr>
         <tr class="a">
            <td>
               <div class="p3">3</div>
            </td>
            <td>
						[Best Practices.DebugsShouldUseLoggingLevel]
						 -
						 <a href="https://pmd.github.io/pmd-6.25.0/pmd_rules_apex_bestpractices.html#debugsshoulduselogginglevel">
Debug statements should include a LoggingLevel
</a>
            </td>
            <td>1307 - 1307</td>
         </tr>
         <tr class="b">
            <td>
               <div class="p3">3</div>
            </td>
            <td>
						[Best Practices.ApexAssertionsShouldIncludeMessage]
						 -
						 <a href="https://pmd.github.io/pmd-6.25.0/pmd_rules_apex_bestpractices.html#apexassertionsshouldincludemessage">
'System.assertEquals' should have 3 parameters.
</a>
            </td>
            <td>1362 - 1362</td>
         </tr>
         <tr class="a">
            <td>
               <div class="p3">3</div>
            </td>
            <td>
						[Best Practices.ApexAssertionsShouldIncludeMessage]
						 -
						 <a href="https://pmd.github.io/pmd-6.25.0/pmd_rules_apex_bestpractices.html#apexassertionsshouldincludemessage">
'System.assertEquals' should have 3 parameters.
</a>
            </td>
            <td>1363 - 1363</td>
         </tr>
         <tr class="b">
            <td>
               <div class="p3">3</div>
            </td>
            <td>
						[Best Practices.ApexAssertionsShouldIncludeMessage]
						 -
						 <a href="https://pmd.github.io/pmd-6.25.0/pmd_rules_apex_bestpractices.html#apexassertionsshouldincludemessage">
'System.assertEquals' should have 3 parameters.
</a>
            </td>
            <td>1364 - 1364</td>
         </tr>
         <tr class="a">
            <td>
               <div class="p3">3</div>
            </td>
            <td>
						[Best Practices.ApexAssertionsShouldIncludeMessage]
						 -
						 <a href="https://pmd.github.io/pmd-6.25.0/pmd_rules_apex_bestpractices.html#apexassertionsshouldincludemessage">
'System.assertEquals' should have 3 parameters.
</a>
            </td>
            <td>1368 - 1368</td>
         </tr>
         <tr class="b">
            <td>
               <div class="p3">3</div>
            </td>
            <td>
						[Best Practices.ApexAssertionsShouldIncludeMessage]
						 -
						 <a href="https://pmd.github.io/pmd-6.25.0/pmd_rules_apex_bestpractices.html#apexassertionsshouldincludemessage">
'System.assertEquals' should have 3 parameters.
</a>
            </td>
            <td>1486 - 1486</td>
         </tr>
         <tr class="a">
            <td>
               <div class="p3">3</div>
            </td>
            <td>
						[Best Practices.ApexAssertionsShouldIncludeMessage]
						 -
						 <a href="https://pmd.github.io/pmd-6.25.0/pmd_rules_apex_bestpractices.html#apexassertionsshouldincludemessage">
'System.assertEquals' should have 3 parameters.
</a>
            </td>
            <td>1487 - 1487</td>
         </tr>
         <tr class="b">
            <td>
               <div class="p3">3</div>
            </td>
            <td>
						[Best Practices.ApexAssertionsShouldIncludeMessage]
						 -
						 <a href="https://pmd.github.io/pmd-6.25.0/pmd_rules_apex_bestpractices.html#apexassertionsshouldincludemessage">
'System.assertEquals' should have 3 parameters.
</a>
            </td>
            <td>1488 - 1488</td>
         </tr>
         <tr class="a">
            <td>
               <div class="p3">3</div>
            </td>
            <td>
						[Best Practices.ApexAssertionsShouldIncludeMessage]
						 -
						 <a href="https://pmd.github.io/pmd-6.25.0/pmd_rules_apex_bestpractices.html#apexassertionsshouldincludemessage">
'System.assertEquals' should have 3 parameters.
</a>
            </td>
            <td>1493 - 1493</td>
         </tr>
         <tr class="b">
            <td>
               <div class="p3">3</div>
            </td>
            <td>
						[Best Practices.ApexAssertionsShouldIncludeMessage]
						 -
						 <a href="https://pmd.github.io/pmd-6.25.0/pmd_rules_apex_bestpractices.html#apexassertionsshouldincludemessage">
'System.assertEquals' should have 3 parameters.
</a>
            </td>
            <td>1609 - 1609</td>
         </tr>
         <tr class="a">
            <td>
               <div class="p3">3</div>
            </td>
            <td>
						[Best Practices.ApexAssertionsShouldIncludeMessage]
						 -
						 <a href="https://pmd.github.io/pmd-6.25.0/pmd_rules_apex_bestpractices.html#apexassertionsshouldincludemessage">
'System.assertEquals' should have 3 parameters.
</a>
            </td>
            <td>1610 - 1610</td>
         </tr>
         <tr class="b">
            <td>
               <div class="p3">3</div>
            </td>
            <td>
						[Best Practices.ApexAssertionsShouldIncludeMessage]
						 -
						 <a href="https://pmd.github.io/pmd-6.25.0/pmd_rules_apex_bestpractices.html#apexassertionsshouldincludemessage">
'System.assertEquals' should have 3 parameters.
</a>
            </td>
            <td>1615 - 1615</td>
         </tr>
         <tr class="a">
            <td>
               <div class="p3">3</div>
            </td>
            <td>
						[Best Practices.ApexAssertionsShouldIncludeMessage]
						 -
						 <a href="https://pmd.github.io/pmd-6.25.0/pmd_rules_apex_bestpractices.html#apexassertionsshouldincludemessage">
'System.assertEquals' should have 3 parameters.
</a>
            </td>
            <td>1620 - 1620</td>
         </tr>
         <tr class="b">
            <td>
               <div class="p3">3</div>
            </td>
            <td>
						[Best Practices.ApexAssertionsShouldIncludeMessage]
						 -
						 <a href="https://pmd.github.io/pmd-6.25.0/pmd_rules_apex_bestpractices.html#apexassertionsshouldincludemessage">
'System.assertEquals' should have 3 parameters.
</a>
            </td>
            <td>1736 - 1736</td>
         </tr>
         <tr class="a">
            <td>
               <div class="p3">3</div>
            </td>
            <td>
						[Best Practices.ApexAssertionsShouldIncludeMessage]
						 -
						 <a href="https://pmd.github.io/pmd-6.25.0/pmd_rules_apex_bestpractices.html#apexassertionsshouldincludemessage">
'System.assertEquals' should have 3 parameters.
</a>
            </td>
            <td>1737 - 1737</td>
         </tr>
         <tr class="b">
            <td>
               <div class="p3">3</div>
            </td>
            <td>
						[Best Practices.ApexAssertionsShouldIncludeMessage]
						 -
						 <a href="https://pmd.github.io/pmd-6.25.0/pmd_rules_apex_bestpractices.html#apexassertionsshouldincludemessage">
'System.assertEquals' should have 3 parameters.
</a>
            </td>
            <td>1740 - 1740</td>
         </tr>
         <tr class="a">
            <td>
               <div class="p3">3</div>
            </td>
            <td>
						[Best Practices.ApexAssertionsShouldIncludeMessage]
						 -
						 <a href="https://pmd.github.io/pmd-6.25.0/pmd_rules_apex_bestpractices.html#apexassertionsshouldincludemessage">
'System.assertEquals' should have 3 parameters.
</a>
            </td>
            <td>1745 - 1745</td>
         </tr>
         <tr class="b">
            <td>
               <div class="p3">3</div>
            </td>
            <td>
						[Best Practices.ApexAssertionsShouldIncludeMessage]
						 -
						 <a href="https://pmd.github.io/pmd-6.25.0/pmd_rules_apex_bestpractices.html#apexassertionsshouldincludemessage">
'System.assertEquals' should have 3 parameters.
</a>
            </td>
            <td>1861 - 1861</td>
         </tr>
         <tr class="a">
            <td>
               <div class="p3">3</div>
            </td>
            <td>
						[Best Practices.ApexAssertionsShouldIncludeMessage]
						 -
						 <a href="https://pmd.github.io/pmd-6.25.0/pmd_rules_apex_bestpractices.html#apexassertionsshouldincludemessage">
'System.assertEquals' should have 3 parameters.
</a>
            </td>
            <td>1862 - 1862</td>
         </tr>
         <tr class="b">
            <td>
               <div class="p3">3</div>
            </td>
            <td>
						[Best Practices.ApexAssertionsShouldIncludeMessage]
						 -
						 <a href="https://pmd.github.io/pmd-6.25.0/pmd_rules_apex_bestpractices.html#apexassertionsshouldincludemessage">
'System.assertEquals' should have 3 parameters.
</a>
            </td>
            <td>1865 - 1865</td>
         </tr>
         <tr class="a">
            <td>
               <div class="p3">3</div>
            </td>
            <td>
						[Best Practices.ApexAssertionsShouldIncludeMessage]
						 -
						 <a href="https://pmd.github.io/pmd-6.25.0/pmd_rules_apex_bestpractices.html#apexassertionsshouldincludemessage">
'System.assertEquals' should have 3 parameters.
</a>
            </td>
            <td>1870 - 1870</td>
         </tr>
         <tr class="b">
            <td>
               <div class="p2">2</div>
            </td>
            <td>
						[Best Practices.ApexUnitTestClassShouldHaveAsserts]
						 -
						 <a href="https://pmd.github.io/pmd-6.25.0/pmd_rules_apex_bestpractices.html#apexunittestclassshouldhaveasserts">
Apex unit test classes should have at least one System.assert() or assertEquals() or AssertNotEquals() call
</a>
            </td>
            <td>1879 - 1905</td>
         </tr>
         <tr class="a">
            <td>
               <div class="p3">3</div>
            </td>
            <td>
						[Best Practices.ApexAssertionsShouldIncludeMessage]
						 -
						 <a href="https://pmd.github.io/pmd-6.25.0/pmd_rules_apex_bestpractices.html#apexassertionsshouldincludemessage">
'System.assertEquals' should have 3 parameters.
</a>
            </td>
            <td>2021 - 2021</td>
         </tr>
      </table>
      <a href="#top">Back to top</a>
      <a name="f-_Users_ataib_workspace_SFV2_force-app_main_default_classes_SM013_ModificationEntranteServices.cls"/>
      <h3>File /Users/ataib/workspace/SFV2/force-app/main/default/classes/SM013_ModificationEntranteServices.cls</h3>
      <table class="log" border="0" cellpadding="5" cellspacing="2" width="100%">
         <tr>
            <th style="width:60px;">Violation</th>
            <th>Error Description</th>
            <th style="width:40px;">Line</th>
         </tr>
         <tr class="a">
            <td>
               <div class="p3">3</div>
            </td>
            <td>
						[Best Practices.DebugsShouldUseLoggingLevel]
						 -
						 <a href="https://pmd.github.io/pmd-6.25.0/pmd_rules_apex_bestpractices.html#debugsshoulduselogginglevel">
Debug statements should include a LoggingLevel
</a>
            </td>
            <td>168 - 168</td>
         </tr>
         <tr class="b">
            <td>
               <div class="p3">3</div>
            </td>
            <td>
						[Best Practices.DebugsShouldUseLoggingLevel]
						 -
						 <a href="https://pmd.github.io/pmd-6.25.0/pmd_rules_apex_bestpractices.html#debugsshoulduselogginglevel">
Debug statements should include a LoggingLevel
</a>
            </td>
            <td>194 - 194</td>
         </tr>
      </table>
      <a href="#top">Back to top</a>
      <a name="f-_Users_ataib_workspace_SFV2_force-app_main_default_classes_SM013_ModificationEntranteServices_Test.cls"/>
      <h3>File /Users/ataib/workspace/SFV2/force-app/main/default/classes/SM013_ModificationEntranteServices_Test.cls</h3>
      <table class="log" border="0" cellpadding="5" cellspacing="2" width="100%">
         <tr>
            <th style="width:60px;">Violation</th>
            <th>Error Description</th>
            <th style="width:40px;">Line</th>
         </tr>
         <tr class="a">
            <td>
               <div class="p2">2</div>
            </td>
            <td>
						[Best Practices.ApexUnitTestClassShouldHaveAsserts]
						 -
						 <a href="https://pmd.github.io/pmd-6.25.0/pmd_rules_apex_bestpractices.html#apexunittestclassshouldhaveasserts">
Apex unit test classes should have at least one System.assert() or assertEquals() or AssertNotEquals() call
</a>
            </td>
            <td>57 - 101</td>
         </tr>
         <tr class="b">
            <td>
               <div class="p2">2</div>
            </td>
            <td>
						[Best Practices.ApexUnitTestClassShouldHaveAsserts]
						 -
						 <a href="https://pmd.github.io/pmd-6.25.0/pmd_rules_apex_bestpractices.html#apexunittestclassshouldhaveasserts">
Apex unit test classes should have at least one System.assert() or assertEquals() or AssertNotEquals() call
</a>
            </td>
            <td>104 - 149</td>
         </tr>
         <tr class="a">
            <td>
               <div class="p2">2</div>
            </td>
            <td>
						[Best Practices.ApexUnitTestClassShouldHaveAsserts]
						 -
						 <a href="https://pmd.github.io/pmd-6.25.0/pmd_rules_apex_bestpractices.html#apexunittestclassshouldhaveasserts">
Apex unit test classes should have at least one System.assert() or assertEquals() or AssertNotEquals() call
</a>
            </td>
            <td>152 - 203</td>
         </tr>
         <tr class="b">
            <td>
               <div class="p2">2</div>
            </td>
            <td>
						[Best Practices.ApexUnitTestClassShouldHaveAsserts]
						 -
						 <a href="https://pmd.github.io/pmd-6.25.0/pmd_rules_apex_bestpractices.html#apexunittestclassshouldhaveasserts">
Apex unit test classes should have at least one System.assert() or assertEquals() or AssertNotEquals() call
</a>
            </td>
            <td>206 - 251</td>
         </tr>
         <tr class="a">
            <td>
               <div class="p2">2</div>
            </td>
            <td>
						[Best Practices.ApexUnitTestClassShouldHaveAsserts]
						 -
						 <a href="https://pmd.github.io/pmd-6.25.0/pmd_rules_apex_bestpractices.html#apexunittestclassshouldhaveasserts">
Apex unit test classes should have at least one System.assert() or assertEquals() or AssertNotEquals() call
</a>
            </td>
            <td>254 - 299</td>
         </tr>
         <tr class="b">
            <td>
               <div class="p2">2</div>
            </td>
            <td>
						[Best Practices.ApexUnitTestClassShouldHaveAsserts]
						 -
						 <a href="https://pmd.github.io/pmd-6.25.0/pmd_rules_apex_bestpractices.html#apexunittestclassshouldhaveasserts">
Apex unit test classes should have at least one System.assert() or assertEquals() or AssertNotEquals() call
</a>
            </td>
            <td>302 - 348</td>
         </tr>
         <tr class="a">
            <td>
               <div class="p2">2</div>
            </td>
            <td>
						[Best Practices.ApexUnitTestClassShouldHaveAsserts]
						 -
						 <a href="https://pmd.github.io/pmd-6.25.0/pmd_rules_apex_bestpractices.html#apexunittestclassshouldhaveasserts">
Apex unit test classes should have at least one System.assert() or assertEquals() or AssertNotEquals() call
</a>
            </td>
            <td>351 - 401</td>
         </tr>
         <tr class="b">
            <td>
               <div class="p2">2</div>
            </td>
            <td>
						[Best Practices.ApexUnitTestClassShouldHaveAsserts]
						 -
						 <a href="https://pmd.github.io/pmd-6.25.0/pmd_rules_apex_bestpractices.html#apexunittestclassshouldhaveasserts">
Apex unit test classes should have at least one System.assert() or assertEquals() or AssertNotEquals() call
</a>
            </td>
            <td>404 - 451</td>
         </tr>
         <tr class="a">
            <td>
               <div class="p2">2</div>
            </td>
            <td>
						[Best Practices.ApexUnitTestClassShouldHaveAsserts]
						 -
						 <a href="https://pmd.github.io/pmd-6.25.0/pmd_rules_apex_bestpractices.html#apexunittestclassshouldhaveasserts">
Apex unit test classes should have at least one System.assert() or assertEquals() or AssertNotEquals() call
</a>
            </td>
            <td>454 - 501</td>
         </tr>
         <tr class="b">
            <td>
               <div class="p2">2</div>
            </td>
            <td>
						[Best Practices.ApexUnitTestClassShouldHaveAsserts]
						 -
						 <a href="https://pmd.github.io/pmd-6.25.0/pmd_rules_apex_bestpractices.html#apexunittestclassshouldhaveasserts">
Apex unit test classes should have at least one System.assert() or assertEquals() or AssertNotEquals() call
</a>
            </td>
            <td>504 - 551</td>
         </tr>
         <tr class="a">
            <td>
               <div class="p2">2</div>
            </td>
            <td>
						[Best Practices.ApexUnitTestClassShouldHaveAsserts]
						 -
						 <a href="https://pmd.github.io/pmd-6.25.0/pmd_rules_apex_bestpractices.html#apexunittestclassshouldhaveasserts">
Apex unit test classes should have at least one System.assert() or assertEquals() or AssertNotEquals() call
</a>
            </td>
            <td>554 - 601</td>
         </tr>
         <tr class="b">
            <td>
               <div class="p2">2</div>
            </td>
            <td>
						[Best Practices.ApexUnitTestClassShouldHaveAsserts]
						 -
						 <a href="https://pmd.github.io/pmd-6.25.0/pmd_rules_apex_bestpractices.html#apexunittestclassshouldhaveasserts">
Apex unit test classes should have at least one System.assert() or assertEquals() or AssertNotEquals() call
</a>
            </td>
            <td>604 - 652</td>
         </tr>
         <tr class="a">
            <td>
               <div class="p2">2</div>
            </td>
            <td>
						[Best Practices.ApexUnitTestClassShouldHaveAsserts]
						 -
						 <a href="https://pmd.github.io/pmd-6.25.0/pmd_rules_apex_bestpractices.html#apexunittestclassshouldhaveasserts">
Apex unit test classes should have at least one System.assert() or assertEquals() or AssertNotEquals() call
</a>
            </td>
            <td>654 - 701</td>
         </tr>
         <tr class="b">
            <td>
               <div class="p2">2</div>
            </td>
            <td>
						[Best Practices.ApexUnitTestClassShouldHaveAsserts]
						 -
						 <a href="https://pmd.github.io/pmd-6.25.0/pmd_rules_apex_bestpractices.html#apexunittestclassshouldhaveasserts">
Apex unit test classes should have at least one System.assert() or assertEquals() or AssertNotEquals() call
</a>
            </td>
            <td>704 - 752</td>
         </tr>
         <tr class="a">
            <td>
               <div class="p2">2</div>
            </td>
            <td>
						[Best Practices.ApexUnitTestClassShouldHaveAsserts]
						 -
						 <a href="https://pmd.github.io/pmd-6.25.0/pmd_rules_apex_bestpractices.html#apexunittestclassshouldhaveasserts">
Apex unit test classes should have at least one System.assert() or assertEquals() or AssertNotEquals() call
</a>
            </td>
            <td>755 - 803</td>
         </tr>
         <tr class="b">
            <td>
               <div class="p2">2</div>
            </td>
            <td>
						[Best Practices.ApexUnitTestClassShouldHaveAsserts]
						 -
						 <a href="https://pmd.github.io/pmd-6.25.0/pmd_rules_apex_bestpractices.html#apexunittestclassshouldhaveasserts">
Apex unit test classes should have at least one System.assert() or assertEquals() or AssertNotEquals() call
</a>
            </td>
            <td>806 - 854</td>
         </tr>
         <tr class="a">
            <td>
               <div class="p2">2</div>
            </td>
            <td>
						[Best Practices.ApexUnitTestClassShouldHaveAsserts]
						 -
						 <a href="https://pmd.github.io/pmd-6.25.0/pmd_rules_apex_bestpractices.html#apexunittestclassshouldhaveasserts">
Apex unit test classes should have at least one System.assert() or assertEquals() or AssertNotEquals() call
</a>
            </td>
            <td>856 - 936</td>
         </tr>
         <tr class="b">
            <td>
               <div class="p2">2</div>
            </td>
            <td>
						[Best Practices.ApexUnitTestClassShouldHaveAsserts]
						 -
						 <a href="https://pmd.github.io/pmd-6.25.0/pmd_rules_apex_bestpractices.html#apexunittestclassshouldhaveasserts">
Apex unit test classes should have at least one System.assert() or assertEquals() or AssertNotEquals() call
</a>
            </td>
            <td>939 - 984</td>
         </tr>
         <tr class="a">
            <td>
               <div class="p2">2</div>
            </td>
            <td>
						[Best Practices.ApexUnitTestClassShouldHaveAsserts]
						 -
						 <a href="https://pmd.github.io/pmd-6.25.0/pmd_rules_apex_bestpractices.html#apexunittestclassshouldhaveasserts">
Apex unit test classes should have at least one System.assert() or assertEquals() or AssertNotEquals() call
</a>
            </td>
            <td>986 - 1034</td>
         </tr>
         <tr class="b">
            <td>
               <div class="p2">2</div>
            </td>
            <td>
						[Best Practices.ApexUnitTestClassShouldHaveAsserts]
						 -
						 <a href="https://pmd.github.io/pmd-6.25.0/pmd_rules_apex_bestpractices.html#apexunittestclassshouldhaveasserts">
Apex unit test classes should have at least one System.assert() or assertEquals() or AssertNotEquals() call
</a>
            </td>
            <td>1036 - 1116</td>
         </tr>
         <tr class="a">
            <td>
               <div class="p2">2</div>
            </td>
            <td>
						[Best Practices.ApexUnitTestClassShouldHaveAsserts]
						 -
						 <a href="https://pmd.github.io/pmd-6.25.0/pmd_rules_apex_bestpractices.html#apexunittestclassshouldhaveasserts">
Apex unit test classes should have at least one System.assert() or assertEquals() or AssertNotEquals() call
</a>
            </td>
            <td>1118 - 1199</td>
         </tr>
         <tr class="b">
            <td>
               <div class="p2">2</div>
            </td>
            <td>
						[Best Practices.ApexUnitTestClassShouldHaveAsserts]
						 -
						 <a href="https://pmd.github.io/pmd-6.25.0/pmd_rules_apex_bestpractices.html#apexunittestclassshouldhaveasserts">
Apex unit test classes should have at least one System.assert() or assertEquals() or AssertNotEquals() call
</a>
            </td>
            <td>1201 - 1249</td>
         </tr>
         <tr class="a">
            <td>
               <div class="p2">2</div>
            </td>
            <td>
						[Best Practices.ApexUnitTestClassShouldHaveAsserts]
						 -
						 <a href="https://pmd.github.io/pmd-6.25.0/pmd_rules_apex_bestpractices.html#apexunittestclassshouldhaveasserts">
Apex unit test classes should have at least one System.assert() or assertEquals() or AssertNotEquals() call
</a>
            </td>
            <td>1251 - 1296</td>
         </tr>
         <tr class="b">
            <td>
               <div class="p2">2</div>
            </td>
            <td>
						[Best Practices.ApexUnitTestClassShouldHaveAsserts]
						 -
						 <a href="https://pmd.github.io/pmd-6.25.0/pmd_rules_apex_bestpractices.html#apexunittestclassshouldhaveasserts">
Apex unit test classes should have at least one System.assert() or assertEquals() or AssertNotEquals() call
</a>
            </td>
            <td>1298 - 1343</td>
         </tr>
         <tr class="a">
            <td>
               <div class="p2">2</div>
            </td>
            <td>
						[Best Practices.ApexUnitTestClassShouldHaveAsserts]
						 -
						 <a href="https://pmd.github.io/pmd-6.25.0/pmd_rules_apex_bestpractices.html#apexunittestclassshouldhaveasserts">
Apex unit test classes should have at least one System.assert() or assertEquals() or AssertNotEquals() call
</a>
            </td>
            <td>1345 - 1360</td>
         </tr>
      </table>
      <a href="#top">Back to top</a>
      <a name="f-_Users_ataib_workspace_SFV2_force-app_main_default_classes_SM013_QuoteLineServices_Test.cls"/>
      <h3>File /Users/ataib/workspace/SFV2/force-app/main/default/classes/SM013_QuoteLineServices_Test.cls</h3>
      <table class="log" border="0" cellpadding="5" cellspacing="2" width="100%">
         <tr>
            <th style="width:60px;">Violation</th>
            <th>Error Description</th>
            <th style="width:40px;">Line</th>
         </tr>
         <tr class="a">
            <td>
               <div class="p3">3</div>
            </td>
            <td>
						[Best Practices.ApexAssertionsShouldIncludeMessage]
						 -
						 <a href="https://pmd.github.io/pmd-6.25.0/pmd_rules_apex_bestpractices.html#apexassertionsshouldincludemessage">
'System.assertEquals' should have 3 parameters.
</a>
            </td>
            <td>271 - 271</td>
         </tr>
         <tr class="b">
            <td>
               <div class="p3">3</div>
            </td>
            <td>
						[Best Practices.ApexAssertionsShouldIncludeMessage]
						 -
						 <a href="https://pmd.github.io/pmd-6.25.0/pmd_rules_apex_bestpractices.html#apexassertionsshouldincludemessage">
'System.assert' should have 2 parameters.
</a>
            </td>
            <td>272 - 272</td>
         </tr>
         <tr class="a">
            <td>
               <div class="p3">3</div>
            </td>
            <td>
						[Best Practices.ApexAssertionsShouldIncludeMessage]
						 -
						 <a href="https://pmd.github.io/pmd-6.25.0/pmd_rules_apex_bestpractices.html#apexassertionsshouldincludemessage">
'System.assert' should have 2 parameters.
</a>
            </td>
            <td>273 - 273</td>
         </tr>
      </table>
      <a href="#top">Back to top</a>
      <a name="f-_Users_ataib_workspace_SFV2_force-app_main_default_classes_SM015_InvoiceServices.cls"/>
      <h3>File /Users/ataib/workspace/SFV2/force-app/main/default/classes/SM015_InvoiceServices.cls</h3>
      <table class="log" border="0" cellpadding="5" cellspacing="2" width="100%">
         <tr>
            <th style="width:60px;">Violation</th>
            <th>Error Description</th>
            <th style="width:40px;">Line</th>
         </tr>
         <tr class="a">
            <td>
               <div class="p3">3</div>
            </td>
            <td>
						[Best Practices.DebugsShouldUseLoggingLevel]
						 -
						 <a href="https://pmd.github.io/pmd-6.25.0/pmd_rules_apex_bestpractices.html#debugsshoulduselogginglevel">
Debug statements should include a LoggingLevel
</a>
            </td>
            <td>49 - 49</td>
         </tr>
      </table>
      <a href="#top">Back to top</a>
      <a name="f-_Users_ataib_workspace_SFV2_force-app_main_default_classes_SM015_InvoiceServices_Test.cls"/>
      <h3>File /Users/ataib/workspace/SFV2/force-app/main/default/classes/SM015_InvoiceServices_Test.cls</h3>
      <table class="log" border="0" cellpadding="5" cellspacing="2" width="100%">
         <tr>
            <th style="width:60px;">Violation</th>
            <th>Error Description</th>
            <th style="width:40px;">Line</th>
         </tr>
         <tr class="a">
            <td>
               <div class="p3">3</div>
            </td>
            <td>
						[Best Practices.DebugsShouldUseLoggingLevel]
						 -
						 <a href="https://pmd.github.io/pmd-6.25.0/pmd_rules_apex_bestpractices.html#debugsshoulduselogginglevel">
Debug statements should include a LoggingLevel
</a>
            </td>
            <td>151 - 151</td>
         </tr>
         <tr class="b">
            <td>
               <div class="p3">3</div>
            </td>
            <td>
						[Best Practices.ApexAssertionsShouldIncludeMessage]
						 -
						 <a href="https://pmd.github.io/pmd-6.25.0/pmd_rules_apex_bestpractices.html#apexassertionsshouldincludemessage">
'System.assertEquals' should have 3 parameters.
</a>
            </td>
            <td>159 - 159</td>
         </tr>
      </table>
      <a href="#top">Back to top</a>
      <a name="f-_Users_ataib_workspace_SFV2_force-app_main_default_classes_SM016_SendMail_Callout.cls"/>
      <h3>File /Users/ataib/workspace/SFV2/force-app/main/default/classes/SM016_SendMail_Callout.cls</h3>
      <table class="log" border="0" cellpadding="5" cellspacing="2" width="100%">
         <tr>
            <th style="width:60px;">Violation</th>
            <th>Error Description</th>
            <th style="width:40px;">Line</th>
         </tr>
         <tr class="a">
            <td>
               <div class="p3">3</div>
            </td>
            <td>
						[Best Practices.DebugsShouldUseLoggingLevel]
						 -
						 <a href="https://pmd.github.io/pmd-6.25.0/pmd_rules_apex_bestpractices.html#debugsshoulduselogginglevel">
Debug statements should include a LoggingLevel
</a>
            </td>
            <td>19 - 19</td>
         </tr>
         <tr class="b">
            <td>
               <div class="p3">3</div>
            </td>
            <td>
						[Best Practices.DebugsShouldUseLoggingLevel]
						 -
						 <a href="https://pmd.github.io/pmd-6.25.0/pmd_rules_apex_bestpractices.html#debugsshoulduselogginglevel">
Debug statements should include a LoggingLevel
</a>
            </td>
            <td>22 - 22</td>
         </tr>
      </table>
      <a href="#top">Back to top</a>
      <a name="f-_Users_ataib_workspace_SFV2_force-app_main_default_classes_SM017_SendDocument_Callout.cls"/>
      <h3>File /Users/ataib/workspace/SFV2/force-app/main/default/classes/SM017_SendDocument_Callout.cls</h3>
      <table class="log" border="0" cellpadding="5" cellspacing="2" width="100%">
         <tr>
            <th style="width:60px;">Violation</th>
            <th>Error Description</th>
            <th style="width:40px;">Line</th>
         </tr>
         <tr class="a">
            <td>
               <div class="p3">3</div>
            </td>
            <td>
						[Best Practices.DebugsShouldUseLoggingLevel]
						 -
						 <a href="https://pmd.github.io/pmd-6.25.0/pmd_rules_apex_bestpractices.html#debugsshoulduselogginglevel">
Debug statements should include a LoggingLevel
</a>
            </td>
            <td>22 - 22</td>
         </tr>
      </table>
      <a href="#top">Back to top</a>
      <a name="f-_Users_ataib_workspace_SFV2_force-app_main_default_classes_SM018_AttachmentService_Test.cls"/>
      <h3>File /Users/ataib/workspace/SFV2/force-app/main/default/classes/SM018_AttachmentService_Test.cls</h3>
      <table class="log" border="0" cellpadding="5" cellspacing="2" width="100%">
         <tr>
            <th style="width:60px;">Violation</th>
            <th>Error Description</th>
            <th style="width:40px;">Line</th>
         </tr>
         <tr class="a">
            <td>
               <div class="p2">2</div>
            </td>
            <td>
						[Best Practices.ApexUnitTestClassShouldHaveAsserts]
						 -
						 <a href="https://pmd.github.io/pmd-6.25.0/pmd_rules_apex_bestpractices.html#apexunittestclassshouldhaveasserts">
Apex unit test classes should have at least one System.assert() or assertEquals() or AssertNotEquals() call
</a>
            </td>
            <td>68 - 139</td>
         </tr>
      </table>
      <a href="#top">Back to top</a>
      <a name="f-_Users_ataib_workspace_SFV2_force-app_main_default_classes_SM019_DocumentList_Callout.cls"/>
      <h3>File /Users/ataib/workspace/SFV2/force-app/main/default/classes/SM019_DocumentList_Callout.cls</h3>
      <table class="log" border="0" cellpadding="5" cellspacing="2" width="100%">
         <tr>
            <th style="width:60px;">Violation</th>
            <th>Error Description</th>
            <th style="width:40px;">Line</th>
         </tr>
         <tr class="a">
            <td>
               <div class="p3">3</div>
            </td>
            <td>
						[Best Practices.DebugsShouldUseLoggingLevel]
						 -
						 <a href="https://pmd.github.io/pmd-6.25.0/pmd_rules_apex_bestpractices.html#debugsshoulduselogginglevel">
Debug statements should include a LoggingLevel
</a>
            </td>
            <td>34 - 34</td>
         </tr>
         <tr class="b">
            <td>
               <div class="p3">3</div>
            </td>
            <td>
						[Best Practices.DebugsShouldUseLoggingLevel]
						 -
						 <a href="https://pmd.github.io/pmd-6.25.0/pmd_rules_apex_bestpractices.html#debugsshoulduselogginglevel">
Debug statements should include a LoggingLevel
</a>
            </td>
            <td>35 - 35</td>
         </tr>
      </table>
      <a href="#top">Back to top</a>
      <a name="f-_Users_ataib_workspace_SFV2_force-app_main_default_classes_SM020_PresinscriptionInvockeService_Test.cls"/>
      <h3>File /Users/ataib/workspace/SFV2/force-app/main/default/classes/SM020_PresinscriptionInvockeService_Test.cls</h3>
      <table class="log" border="0" cellpadding="5" cellspacing="2" width="100%">
         <tr>
            <th style="width:60px;">Violation</th>
            <th>Error Description</th>
            <th style="width:40px;">Line</th>
         </tr>
         <tr class="a">
            <td>
               <div class="p2">2</div>
            </td>
            <td>
						[Best Practices.ApexUnitTestClassShouldHaveAsserts]
						 -
						 <a href="https://pmd.github.io/pmd-6.25.0/pmd_rules_apex_bestpractices.html#apexunittestclassshouldhaveasserts">
Apex unit test classes should have at least one System.assert() or assertEquals() or AssertNotEquals() call
</a>
            </td>
            <td>10 - 56</td>
         </tr>
      </table>
      <a href="#top">Back to top</a>
      <a name="f-_Users_ataib_workspace_SFV2_force-app_main_default_classes_UM001_LogManager_Test.cls"/>
      <h3>File /Users/ataib/workspace/SFV2/force-app/main/default/classes/UM001_LogManager_Test.cls</h3>
      <table class="log" border="0" cellpadding="5" cellspacing="2" width="100%">
         <tr>
            <th style="width:60px;">Violation</th>
            <th>Error Description</th>
            <th style="width:40px;">Line</th>
         </tr>
         <tr class="a">
            <td>
               <div class="p2">2</div>
            </td>
            <td>
						[Best Practices.ApexUnitTestClassShouldHaveAsserts]
						 -
						 <a href="https://pmd.github.io/pmd-6.25.0/pmd_rules_apex_bestpractices.html#apexunittestclassshouldhaveasserts">
Apex unit test classes should have at least one System.assert() or assertEquals() or AssertNotEquals() call
</a>
            </td>
            <td>17 - 25</td>
         </tr>
      </table>
      <a href="#top">Back to top</a>
      <a name="f-_Users_ataib_workspace_SFV2_force-app_main_default_classes_UM002_TestDataFactory_Test.cls"/>
      <h3>File /Users/ataib/workspace/SFV2/force-app/main/default/classes/UM002_TestDataFactory_Test.cls</h3>
      <table class="log" border="0" cellpadding="5" cellspacing="2" width="100%">
         <tr>
            <th style="width:60px;">Violation</th>
            <th>Error Description</th>
            <th style="width:40px;">Line</th>
         </tr>
         <tr class="a">
            <td>
               <div class="p3">3</div>
            </td>
            <td>
						[Best Practices.ApexAssertionsShouldIncludeMessage]
						 -
						 <a href="https://pmd.github.io/pmd-6.25.0/pmd_rules_apex_bestpractices.html#apexassertionsshouldincludemessage">
'System.assert' should have 2 parameters.
</a>
            </td>
            <td>48 - 48</td>
         </tr>
         <tr class="b">
            <td>
               <div class="p3">3</div>
            </td>
            <td>
						[Best Practices.ApexAssertionsShouldIncludeMessage]
						 -
						 <a href="https://pmd.github.io/pmd-6.25.0/pmd_rules_apex_bestpractices.html#apexassertionsshouldincludemessage">
'System.assert' should have 2 parameters.
</a>
            </td>
            <td>49 - 49</td>
         </tr>
         <tr class="a">
            <td>
               <div class="p3">3</div>
            </td>
            <td>
						[Best Practices.ApexAssertionsShouldIncludeMessage]
						 -
						 <a href="https://pmd.github.io/pmd-6.25.0/pmd_rules_apex_bestpractices.html#apexassertionsshouldincludemessage">
'System.assert' should have 2 parameters.
</a>
            </td>
            <td>55 - 55</td>
         </tr>
         <tr class="b">
            <td>
               <div class="p2">2</div>
            </td>
            <td>
						[Best Practices.ApexUnitTestClassShouldHaveAsserts]
						 -
						 <a href="https://pmd.github.io/pmd-6.25.0/pmd_rules_apex_bestpractices.html#apexunittestclassshouldhaveasserts">
Apex unit test classes should have at least one System.assert() or assertEquals() or AssertNotEquals() call
</a>
            </td>
            <td>81 - 86</td>
         </tr>
         <tr class="a">
            <td>
               <div class="p3">3</div>
            </td>
            <td>
						[Best Practices.ApexAssertionsShouldIncludeMessage]
						 -
						 <a href="https://pmd.github.io/pmd-6.25.0/pmd_rules_apex_bestpractices.html#apexassertionsshouldincludemessage">
'System.assert' should have 2 parameters.
</a>
            </td>
            <td>101 - 101</td>
         </tr>
         <tr class="b">
            <td>
               <div class="p3">3</div>
            </td>
            <td>
						[Best Practices.ApexAssertionsShouldIncludeMessage]
						 -
						 <a href="https://pmd.github.io/pmd-6.25.0/pmd_rules_apex_bestpractices.html#apexassertionsshouldincludemessage">
'System.assert' should have 2 parameters.
</a>
            </td>
            <td>102 - 102</td>
         </tr>
         <tr class="a">
            <td>
               <div class="p3">3</div>
            </td>
            <td>
						[Best Practices.ApexAssertionsShouldIncludeMessage]
						 -
						 <a href="https://pmd.github.io/pmd-6.25.0/pmd_rules_apex_bestpractices.html#apexassertionsshouldincludemessage">
'System.assertEquals' should have 3 parameters.
</a>
            </td>
            <td>103 - 103</td>
         </tr>
         <tr class="b">
            <td>
               <div class="p3">3</div>
            </td>
            <td>
						[Best Practices.ApexAssertionsShouldIncludeMessage]
						 -
						 <a href="https://pmd.github.io/pmd-6.25.0/pmd_rules_apex_bestpractices.html#apexassertionsshouldincludemessage">
'System.assert' should have 2 parameters.
</a>
            </td>
            <td>119 - 119</td>
         </tr>
         <tr class="a">
            <td>
               <div class="p3">3</div>
            </td>
            <td>
						[Best Practices.ApexAssertionsShouldIncludeMessage]
						 -
						 <a href="https://pmd.github.io/pmd-6.25.0/pmd_rules_apex_bestpractices.html#apexassertionsshouldincludemessage">
'System.assert' should have 2 parameters.
</a>
            </td>
            <td>120 - 120</td>
         </tr>
         <tr class="b">
            <td>
               <div class="p3">3</div>
            </td>
            <td>
						[Best Practices.ApexAssertionsShouldIncludeMessage]
						 -
						 <a href="https://pmd.github.io/pmd-6.25.0/pmd_rules_apex_bestpractices.html#apexassertionsshouldincludemessage">
'System.assert' should have 2 parameters.
</a>
            </td>
            <td>136 - 136</td>
         </tr>
         <tr class="a">
            <td>
               <div class="p3">3</div>
            </td>
            <td>
						[Best Practices.ApexAssertionsShouldIncludeMessage]
						 -
						 <a href="https://pmd.github.io/pmd-6.25.0/pmd_rules_apex_bestpractices.html#apexassertionsshouldincludemessage">
'System.assert' should have 2 parameters.
</a>
            </td>
            <td>137 - 137</td>
         </tr>
         <tr class="b">
            <td>
               <div class="p3">3</div>
            </td>
            <td>
						[Best Practices.ApexAssertionsShouldIncludeMessage]
						 -
						 <a href="https://pmd.github.io/pmd-6.25.0/pmd_rules_apex_bestpractices.html#apexassertionsshouldincludemessage">
'system.assertEquals' should have 3 parameters.
</a>
            </td>
            <td>153 - 153</td>
         </tr>
      </table>
      <a href="#top">Back to top</a>
      <a name="f-_Users_ataib_workspace_SFV2_force-app_main_default_classes_UM009_Callback.cls"/>
      <h3>File /Users/ataib/workspace/SFV2/force-app/main/default/classes/UM009_Callback.cls</h3>
      <table class="log" border="0" cellpadding="5" cellspacing="2" width="100%">
         <tr>
            <th style="width:60px;">Violation</th>
            <th>Error Description</th>
            <th style="width:40px;">Line</th>
         </tr>
         <tr class="a">
            <td>
               <div class="p3">3</div>
            </td>
            <td>
						[Best Practices.AvoidGlobalModifier]
						 -
						 <a href="https://pmd.github.io/pmd-6.25.0/pmd_rules_apex_bestpractices.html#avoidglobalmodifier">
Avoid using global modifier
</a>
            </td>
            <td>1 - 5</td>
         </tr>
      </table>
      <a href="#top">Back to top</a>
      <a name="f-_Users_ataib_workspace_SFV2_force-app_main_default_classes_VFC001_GenererDocAnn2_Test.cls"/>
      <h3>File /Users/ataib/workspace/SFV2/force-app/main/default/classes/VFC001_GenererDocAnn2_Test.cls</h3>
      <table class="log" border="0" cellpadding="5" cellspacing="2" width="100%">
         <tr>
            <th style="width:60px;">Violation</th>
            <th>Error Description</th>
            <th style="width:40px;">Line</th>
         </tr>
         <tr class="a">
            <td>
               <div class="p2">2</div>
            </td>
            <td>
						[Best Practices.ApexUnitTestClassShouldHaveAsserts]
						 -
						 <a href="https://pmd.github.io/pmd-6.25.0/pmd_rules_apex_bestpractices.html#apexunittestclassshouldhaveasserts">
Apex unit test classes should have at least one System.assert() or assertEquals() or AssertNotEquals() call
</a>
            </td>
            <td>10 - 34</td>
         </tr>
      </table>
      <a href="#top">Back to top</a>
      <hr size="1" width="100%" align="left"/>
   </body>
</html>