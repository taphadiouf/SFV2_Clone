/**
* @author Ayoub Ouarti
* @created 23/03/2020
* @description Service class for Contract Object
* @Updated By Achraf ABOUL(aaboul@salesforce.com) 08/05/2020
*/
public class SM010_ContractServices {

    public static void setContractFields(List<Contract> contracts){
		Set<String> quoteIds = UM003_TypeManager.getFieldsOfListObjects(contracts,'SBQQ__Quote__c');
        Map<Id,SBQQ__Quote__c> quoteMap = new  Map<Id,SBQQ__Quote__c>([SELECT Id,LPCR_TypeFacturation__c,SBQQ__BillingFrequency__c,LPCR_IndexationConvenue__c,LPCR_MasterDevis__c,LPCR_RenouvellementConvenu__c,LPCR_DateDebut__c,LPCR_DateFin__c,LPCR_ChiffreAffaire__c, LPCR_MethodeRenouvellement__c,SBQQ__RenewalUpliftRate__c,LPCR_TypeEntreprise__c, LPCR_ContratEntreprise__c , recordtype.name  from SBQQ__Quote__c WHERE Id in :quoteIds]);
        
        for (Contract eachContract : contracts){
            if(quoteMap.containsKey(eachContract.SBQQ__Quote__c)){
                eachContract.LPCR_IndexationConvenue__c = quoteMap.get(eachContract.SBQQ__Quote__c).LPCR_IndexationConvenue__c;

                eachContract.LPCR_TypeFacturation__c = quoteMap.get(eachContract.SBQQ__Quote__c).LPCR_TypeFacturation__c;

                eachContract.LPCR_BillingFrequency__c = quoteMap.get(eachContract.SBQQ__Quote__c).SBQQ__BillingFrequency__c;

                eachContract.LPCR_MasterDevis__c = quoteMap.get(eachContract.SBQQ__Quote__c).LPCR_MasterDevis__c;
                
                eachContract.LPCR_RenouvellementConvenu__c = quoteMap.get(eachContract.SBQQ__Quote__c).LPCR_RenouvellementConvenu__c;
                
                eachContract.LPCR_DateDebut__c = quoteMap.get(eachContract.SBQQ__Quote__c).LPCR_DateDebut__c;
                
                eachContract.LPCR_DateFin__c = quoteMap.get(eachContract.SBQQ__Quote__c).LPCR_DateFin__c;
                
                eachContract.LPCR_ChiffreAffaire__c = quoteMap.get(eachContract.SBQQ__Quote__c).LPCR_ChiffreAffaire__c;
                
                eachContract.LPCR_MethodeRenouvellement__c = quoteMap.get(eachContract.SBQQ__Quote__c).LPCR_MethodeRenouvellement__c;
                
                eachContract.LPCR_RenouvellementAutomatique__c = quoteMap.get(eachContract.SBQQ__Quote__c).SBQQ__RenewalUpliftRate__c == null ? false : true;
                
                if(quoteMap.get(eachContract.SBQQ__Quote__c).recordtype.name == Label.LPCR_ContratA) {
                    eachContract.LPCR_ContratEntreprise__c = quoteMap.get(eachContract.SBQQ__Quote__c).LPCR_ContratEntreprise__c;
                }
            }
        }
    }
}