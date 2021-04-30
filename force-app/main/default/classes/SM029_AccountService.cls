public with sharing class SM029_AccountService {
    public static Id entrepriseRecTypeId = EM003_RecordTypeEntity.getRecTypeIdByObjectAndName(Label.LPCR_Account,Label.LPCR_Entreprise);
    public static void defautCounterCTNum(Map<Id, Account> newAccountsMap){
        List<Account> lstAccountUpdate=new List<Account>();
        //get latest CTNUM 
        Long counter= 4110000001L;
        
        for(Account acc :[SELECT LPCR_CTNum__c FROM Account where LPCR_CTNum__c != null  ORDER BY LPCR_CTNum__c DESC limit 1]){
            counter=(Long)acc.LPCR_CTNum__c;
            counter++;
        }
        for(Id key : newAccountsMap.keyset()){
            //for RT entreprise only
            if(newAccountsMap.get(key).RecordTypeId == entrepriseRecTypeId){
                lstAccountUpdate.add(new Account(LPCR_CTNum__c=counter,ID=newAccountsMap.get(key).ID)); 
                counter++; 
            }
            
        }
        if(lstAccountUpdate.size() > 0){
            update lstAccountUpdate;
        }
    }
}