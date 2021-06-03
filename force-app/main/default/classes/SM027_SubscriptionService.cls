/**
* @author  PDO
* @created 19/03/2021
* @description Trigger on SBQQ__Subscription__c Object
*/
public class SM027_SubscriptionService {
    //Nombre de berceau sur contrat B2B pour calcul l'ARPU journalier
    public static void updateContratNombreBerceau(Map<Id, SBQQ__Subscription__c> newSubscriptionMap){
        Map<Id,Integer> mapContratIDNombreBerceau=new Map<Id,Integer>();
        List<Contract> lstContractUpdate=new List<Contract>();
        for(Id key : newSubscriptionMap.keyset()){
            //accueil occasionel pour contrat reservataire
            if(newSubscriptionMap.get(key).SBQQ__ProductName__c.startsWith(Label.LPCR_ProduitBerceauNom) || newSubscriptionMap.get(key).SBQQ__ProductName__c.equals(Label.LPCR_BerceauOccasionel) ){
                if(!mapContratIDNombreBerceau.containsKey(newSubscriptionMap.get(key).SBQQ__Contract__c)){
                    mapContratIDNombreBerceau.put(newSubscriptionMap.get(key).SBQQ__Contract__c,(Integer)(1*newSubscriptionMap.get(key).LPCR_QuantiteProduits__c));
                }else{
                    mapContratIDNombreBerceau.put(newSubscriptionMap.get(key).SBQQ__Contract__c,mapContratIDNombreBerceau.get(newSubscriptionMap.get(key).SBQQ__Contract__c)+(Integer)(1*newSubscriptionMap.get(key).LPCR_QuantiteProduits__c));
                }
            }
            
        }
        for(Id key : mapContratIDNombreBerceau.keyset()){
            lstContractUpdate.add(new Contract(Id=key,LPCR_NombreDeBerceaux__c=mapContratIDNombreBerceau.get(key)));
        }
        if(lstContractUpdate.size() > 0 )update lstContractUpdate;
        
        
    }
    public static void updateBonDachat(Map<Id, SBQQ__Subscription__c> newSubscriptionMap){
        Map<String,ID> mapCrecheIDEnfantSubscription=new Map<String,ID>();
        Map<String,ID> mapCrecheIDEnfantBonDachat=new Map<String,ID>();
        Set<Id> setCreche =new Set<Id>();
        Set<Id> setContrat =new Set<Id>();
        Set<Id> setContactEnfant =new Set<Id>();
        List<SBQQ__Subscription__c> lstSubscriptionUpdate=new List<SBQQ__Subscription__c>();
        Map<Id,Id> mapContactEnfantContrat = new Map<Id,Id>();
        for(Id key : newSubscriptionMap.keyset()){
           if(newSubscriptionMap.get(key).LPCR_Creche__c != null && newSubscriptionMap.get(key).LPCR_ContactEnfant__c != null  ){
                if(!mapCrecheIDEnfantSubscription.containsKey(newSubscriptionMap.get(key).LPCR_Creche__c+'-'+newSubscriptionMap.get(key).LPCR_ContactEnfant__c)){
                    mapCrecheIDEnfantSubscription.put(newSubscriptionMap.get(key).LPCR_Creche__c+'-'+newSubscriptionMap.get(key).LPCR_ContactEnfant__c,key);
                    setCreche.add(newSubscriptionMap.get(key).LPCR_Creche__c);
                    setContrat.add(newSubscriptionMap.get(key).SBQQ__Contract__c);
                    setContactEnfant.add(newSubscriptionMap.get(key).LPCR_ContactEnfant__c);
                }
            }
        }
        //look for bon dachat and LPCR_ContratReservataire__c IN:setContrat 
        for(LPCR_BonAchatPartenaire__c bda :[SELECT Id, LPCR_Creche__c, LPCR_ContactEnfant__c ,LPCR_ContratReservataire__c  FROM LPCR_BonAchatPartenaire__c where LPCR_Creche__c IN:setCreche  and LPCR_ContactEnfant__c IN:setContactEnfant ]){
            if(!mapCrecheIDEnfantBonDachat.containsKey(bda.LPCR_Creche__c+'-'+bda.LPCR_ContactEnfant__c)){
                mapCrecheIDEnfantBonDachat.put(bda.LPCR_Creche__c+'-'+bda.LPCR_ContactEnfant__c,bda.Id);
            }
            
        }
        //look for contrat Acceuil famille with enfant LPCR_ContactEnfant__c
        for (Contract  con : [select Id ,LPCR_ContactEnfant__c from Contract where LPCR_ContactEnfant__c IN:setContactEnfant]){
            mapContactEnfantContrat.put(con.LPCR_ContactEnfant__c,con.Id);
            
        }
        
        //loop in all newly created subscription 
        for(String key : mapCrecheIDEnfantSubscription.keyset()){
            String[] keySplit=key.split('-');
            SBQQ__Subscription__c sub=new SBQQ__Subscription__c(Id=mapCrecheIDEnfantSubscription.get(key));
            if(!mapCrecheIDEnfantBonDachat.isEmpty() && mapCrecheIDEnfantBonDachat.containsKey(key) ){
                // lstSubscriptionUpdate.add(new SBQQ__Subscription__c(Id=mapCrecheIDEnfantSubscription.get(key),LPCR_BonDachatPartenaire__c=mapCrecheIDEnfantBonDachat.get(key)));
                sub.LPCR_BonDachatPartenaire__c=mapCrecheIDEnfantBonDachat.get(key);
            }
            if(keySplit[1] !=null){
                sub.LPCR_ContratFamille__c=mapContactEnfantContrat.get(keySplit[1]);
            }
            lstSubscriptionUpdate.add(sub);
            
        }
        if(lstSubscriptionUpdate.size() > 0 ){
            update lstSubscriptionUpdate;
        }
        
    }
    

}