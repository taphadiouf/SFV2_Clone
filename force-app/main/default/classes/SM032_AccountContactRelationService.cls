public with sharing class SM032_AccountContactRelationService {
    public static Id conCollabRecTypeId = EM003_RecordTypeEntity.getRecTypeIdByObjectAndName(Label.LPCR_Contact,Label.LPCR_ContactColl);
    public static Id accCrecheRecTypeId = EM003_RecordTypeEntity.getRecTypeIdByObjectAndName(Label.LPCR_Account,Label.LPCR_Creche);

    public static void setIdSalesforceAccountContact(List<AccountContactRelation> newAccountContactRelationsList){
        Set<String> setIdExtCompte = new Set<String>();
        Set<String> setIdContact = new Set<String>();

        for(AccountContactRelation accConRel : newAccountContactRelationsList){
            if(accConRel.LPCR_AccountIdExterne__c<> null){
                setIdExtCompte.add(accConRel.LPCR_AccountIdExterne__c);
            }
            if(accConRel.LPCR_IdExterne_Contact__c<> null){
                setIdContact.add(accConRel.LPCR_IdExterne_Contact__c);
            }
        }

        Map<String,Id> mapIdExtIdSalesforce = new Map<String,Id>(); 

        for(Account acc : [SELECT id,LPCR_IdExterne_Compte__c,recordtypeId FROM Account WHERE LPCR_IdExterne_Compte__c IN :setIdExtCompte]){
            if(acc.LPCR_IdExterne_Compte__c<> null && acc.recordtypeId==accCrecheRecTypeId){
                mapIdExtIdSalesforce.put(acc.LPCR_IdExterne_Compte__c,acc.id);
            }
        }
        for(Contact con : [SELECT id,LPCR_IdExterne_Contact__c,recordtypeId FROM Contact WHERE LPCR_IdExterne_Contact__c IN :setIdContact]){
            if(con.LPCR_IdExterne_Contact__c<> null && con.recordtypeId==conCollabRecTypeId){
                mapIdExtIdSalesforce.put(con.LPCR_IdExterne_Contact__c,con.id);
            }
        }
        for(Integer i=0 ;i<newAccountContactRelationsList.size();i++){
            if(mapIdExtIdSalesforce.containsKey(newAccountContactRelationsList[i].LPCR_AccountIdExterne__c)){
                if(mapIdExtIdSalesforce.containsKey(newAccountContactRelationsList[i].LPCR_IdExterne_Contact__c)){
                    newAccountContactRelationsList[i].AccountId = mapIdExtIdSalesforce.get(newAccountContactRelationsList[i].LPCR_AccountIdExterne__c);
                    newAccountContactRelationsList[i].ContactId = mapIdExtIdSalesforce.get(newAccountContactRelationsList[i].LPCR_IdExterne_Contact__c);
                }
            }
        }
    }
}