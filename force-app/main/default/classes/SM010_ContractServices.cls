/**
* @author Ayoub Ouarti
* @created 23/03/2020
* @description Service class for Contract Object
*/
public class SM010_ContractServices {

    public static void setContractFields(List<Contract> contracts){
		Set<String> quoteIds = UM003_TypeManager.getFieldsOfListObjects(contracts,'SBQQ__Quote__c');
        Map<Id,SBQQ__Quote__c> quoteMap = new  Map<Id,SBQQ__Quote__c>([SELECT Id,LPCR_RenouvellementConvenu__c  from SBQQ__Quote__c WHERE Id in :quoteIds]);
        
        for (Contract eachContract : contracts){
            if(quoteMap.containsKey(eachContract.SBQQ__Quote__c)){
                eachContract.LPCR_RenouvellementConvenu__c=quoteMap.get(eachContract.SBQQ__Quote__c).LPCR_RenouvellementConvenu__c;
            }
        }
    }
}