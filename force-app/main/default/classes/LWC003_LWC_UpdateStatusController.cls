public with sharing class LWC003_LWC_UpdateStatusController {


    /*public class CustomSelectOptions{
            @AuraEnabled public String label {get;set;}
            @AuraEnabled public String value {get;set;}
            public CustomSelectOptions() {
                this.label = '';
                this.value = '';
            }
            public CustomSelectOptions(String lab, String val) {
                this.label = lab;
                this.value = val;
            }
        }
        



            @AuraEnabled
        public static List<CustomSelectOptions> getPicklistValues(String sObj, String field) {
    
            List<CustomSelectOptions> options = new List<CustomSelectOptions>();
            Map<String, Schema.SObjectField> fieldMap = Schema.getGlobalDescribe().get(sObj).getDescribe().fields.getMap();
            Schema.SObjectField sObjfield = fieldMap.get(field);
            Schema.DescribeFieldResult fieldDesc = sObjfield.getDescribe();
            List<Schema.PicklistEntry> ple = fieldDesc.getPicklistValues();
                for( Schema.PicklistEntry f : ple) {
                options.add(new CustomSelectOptions(f.getLabel(), f.getValue()));
               }       
               return options;
        }*/

       @AuraEnabled 
        public static List<String> getPicklistvalues(){
        
        List<String> lstPicklistValue = new List<String>();
        Schema.DescribeFieldResult describeFieldRslt = LPCR_Preinscription__c.LPCR_Statut__c.getDescribe();
        List<Schema.PicklistEntry> pickListEntries = describeFieldRslt.getPicklistValues();
        
        for(Schema.PicklistEntry eachEntry : pickListEntries ) {
            lstPicklistValue.add(eachEntry.getValue());
        }
       
        return lstPicklistValue;
        
    }


}
