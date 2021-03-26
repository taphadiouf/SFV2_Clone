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

}
