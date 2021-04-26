/**
* @author  PDO
* @created 09/04/2021
* @description Trigger on Invoice Line Object
*/
public class SM028_InvoiceLineService {
    public static void populateNumberDaysBillingUsage(Map<Id, blng__InvoiceLine__c> newInvoiceLineMap,Map<Id, blng__InvoiceLine__c> oldInvoiceLineMap){
        Map<Id,Id>mapInvoiceIdBillingSummary = new Map<Id,Id>();
        Map <Id,String> mapInvoiceDates =new  Map <Id,String>();
        List<blng__Invoice__c> invoiceToUpdateList=new List<blng__Invoice__c>();
        List<Id> billingUsageSummaryList = new List<Id>();
        for(Id key : newInvoiceLineMap.keySet()){
            if(newInvoiceLineMap.get(key).blng__UsageSummary__c!= null){
                billingUsageSummaryList.add(newInvoiceLineMap.get(key).blng__UsageSummary__c );
                mapInvoiceIdBillingSummary.put(newInvoiceLineMap.get(key).blng__UsageSummary__c,newInvoiceLineMap.get(key).blng__Invoice__c);
            }
        }
        for(blng__Usage__c eachBillingUsage : [SELECT  blng__UsageSummary__r.blng__Invoice__c ,blng__StartDateTime__c,blng__EndDateTime__c FROM blng__Usage__c where 	blng__UsageSummary__c IN:billingUsageSummaryList]){
            if(!mapInvoiceDates.containsKey(mapInvoiceIdBillingSummary.get(eachBillingUsage.blng__UsageSummary__c))){
                
                mapInvoiceDates.put(mapInvoiceIdBillingSummary.get(eachBillingUsage.blng__UsageSummary__c),getDaysBetweenDates(eachBillingUsage.blng__StartDateTime__c,eachBillingUsage.blng__EndDateTime__c));
            }else{
                mapInvoiceDates.put(mapInvoiceIdBillingSummary.get(eachBillingUsage.blng__UsageSummary__c),mapInvoiceDates.get(mapInvoiceIdBillingSummary.get(eachBillingUsage.blng__UsageSummary__c))+'\n'+getDaysBetweenDates(eachBillingUsage.blng__StartDateTime__c,eachBillingUsage.blng__EndDateTime__c));
            }
            
        }
        //loop in map and update new field on facture 
        for(Id key :mapInvoiceDates.keySet() ){
            invoiceToUpdateList.add(new blng__Invoice__c(id=key,LPCR_NombreJoursUtilisation__c=mapInvoiceDates.get(key)));
        }
        if(invoiceToUpdateList.size()>0){
            update invoiceToUpdateList;
        }
        
    }
    public static String getDaysBetweenDates(Datetime dateStart,Datetime dateEnd){
        Integer daysBetween=dateStart.date().daysBetween(dateEnd.date());
        String str='';
        For(Integer i=0;i<=daysBetween;i++){
            str=String.isBlank(str)?dateStart.addDays(i).format('dd/MM/yyyy'):str+'\n'+dateStart.addDays(i).format('dd/MM/yyyy');
            
        }
       return str;
    }
    
}