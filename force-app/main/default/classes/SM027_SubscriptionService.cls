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
            if(newSubscriptionMap.get(key).SBQQ__ProductName__c.startsWith(Label.LPCR_ProduitBerceauNom)){
                if(!mapContratIDNombreBerceau.containsKey(newSubscriptionMap.get(key).SBQQ__Contract__c)){
                mapContratIDNombreBerceau.put(newSubscriptionMap.get(key).SBQQ__Contract__c,1);
                }else{
                    mapContratIDNombreBerceau.put(newSubscriptionMap.get(key).SBQQ__Contract__c,mapContratIDNombreBerceau.get(newSubscriptionMap.get(key).SBQQ__Contract__c)+1);
                }
            }
            
        }
        for(Id key : mapContratIDNombreBerceau.keyset()){
            lstContractUpdate.add(new Contract(Id=key,LPCR_NombreDeBerceaux__c=mapContratIDNombreBerceau.get(key)));
        }
        if(lstContractUpdate.size() > 0 )update lstContractUpdate;
        
        
    }

}