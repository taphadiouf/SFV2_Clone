public with sharing class SM029_AccountService {
    public static Id entrepriseRecTypeId = EM003_RecordTypeEntity.getRecTypeIdByObjectAndName(Label.LPCR_Account,Label.LPCR_Entreprise);
    public static void defautCounterCTNum(Map<Id, Account> newAccountsMap){
        List<Account>lstAccountUpdate=new List<Account>();
        //get latest CTNUM 
        Long counter= 4110000001L;
        Pattern p = Pattern.compile('^411[0-9]{7}$');
        for(Account acc :[SELECT LPCR_IDSage__c FROM Account where LPCR_IDSage__c != null  and RecordTypeId =:entrepriseRecTypeId and LPCR_IsNumericIDSage__c=true ORDER BY LPCR_IDSage__c DESC limit 1]){
            if(p.matcher(acc.LPCR_IDSage__c).matches()){
                counter=Long.valueof(acc.LPCR_IDSage__c);
                counter++;
            }
            
        }
        //get LPCR Groupe
        List<blng__LegalEntity__c> socFacExsitant=[SELECT Id, Name FROM blng__LegalEntity__c where Name=:Label.LPCR_LPCRGroupe limit 1];
        for(Id key : newAccountsMap.keyset()){
            if(socFacExsitant.size() >0 && newAccountsMap.get(key).RecordTypeId != entrepriseRecTypeId){
                Account acc = new Account(LPCR_SocieteFacturanteCompte__c=socFacExsitant[0].Id,ID=newAccountsMap.get(key).ID);
                lstAccountUpdate.add(acc);
            }
            
            //for RT entreprise only
            if(newAccountsMap.get(key).RecordTypeId == entrepriseRecTypeId){
                String sLong = String.valueOf(counter);
                lstAccountUpdate.add(new Account(LPCR_IDSage__c=(String)sLong,ID=newAccountsMap.get(key).ID,LPCR_SocieteFacturanteCompte__c=newAccountsMap.get(key).LPCR_SocieteFacturanteCompte__c == null ? socFacExsitant.size() > 0 ?socFacExsitant[0].Id:null :newAccountsMap.get(key).LPCR_SocieteFacturanteCompte__c )); 
                counter++; 
            }
            
            
        }
        if(lstAccountUpdate.size() >0 ){
            update lstAccountUpdate;
        }
    }
    //method to initialise variable on lead conversion to synch record types
    public static void initialiseVariableLeadConversion(Map<Id, Account> newAccountsMap){
        SM007_LeadServices.accountsIds = new Set<Id>(newAccountsMap.keySet());
        
    }
}
