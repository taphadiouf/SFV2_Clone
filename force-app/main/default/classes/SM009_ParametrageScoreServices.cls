/**
* @author Ayoub Ouarti
* @date 05/03/2020
* @description Service class for SM009_ParametrageScoreServices
*/
public with sharing class SM009_ParametrageScoreServices {
    
    public static void setScoreOnpreinscriptions(List<LPCR_Preinscription__c> preinscriptions){
        List<String> lstFields = new List<String>();
        
        Set<String> accountIds = UM003_TypeManager.getFieldsOfListObjects(preinscriptions,'LPCR_CompteEntreprise__c');
        Map<id, List<LPCR_ParametrageScore__c>> paramScoreMap = new Map <id, List<LPCR_ParametrageScore__c>>();
        
        for(LPCR_ParametrageScore__c paramScore : [SELECT Id, LPCR_ApiFieldName__c, LPCR_Format__c, LPCR_Valeur__c, LPCR_Score__c, LPCR_Account__c FROM LPCR_ParametrageScore__c where LPCR_Account__c in: accountIds]){
            if(!paramScoreMap.containsKey(paramScore.LPCR_Account__c)){
                List<LPCR_ParametrageScore__c> paramScoreList = new List<LPCR_ParametrageScore__c>();
                paramScoreList.add(paramScore);
                paramScoreMap.put(paramScore.LPCR_Account__c,paramScoreList);
            }
            else{
                List<LPCR_ParametrageScore__c> paramScoreList = paramScoreMap.get(paramScore.LPCR_Account__c);
                paramScoreList.add(paramScore);
                paramScoreMap.put(paramScore.LPCR_Account__c,paramScoreList);
            }
        }
        
        for(LPCR_Preinscription__c eachPreinscription : preinscriptions){
            if(paramScoreMap.containsKey(eachPreinscription.LPCR_CompteEntreprise__c)){
                eachPreinscription.LPCR_Score__c= scoreCalculation(eachPreinscription , paramScoreMap.get(eachPreinscription.LPCR_CompteEntreprise__c));
                
            }
        }        
    }
    
    public static Decimal scoreCalculation(LPCR_Preinscription__c preinscription,List<LPCR_ParametrageScore__c> parametrageScoreList){
        
        map<string, Decimal> mapScore = new Map<string,Decimal>();
        map<string, Decimal> mapValeurNum = new Map<string, Decimal>();
        map<string, Date> mapValeurDate = new Map<string, Date>();

        for(LPCR_ParametrageScore__c eachParam : parametrageScoreList){
            string field = eachParam.LPCR_ApiFieldName__c;
            System.debug('##Score:' + eachParam);

            if(eachParam.LPCR_Format__c != null && eachParam.LPCR_Valeur__c != null && eachParam.LPCR_ApiFieldName__c != null && preinscription.get(field) != null){
                if(eachparam.LPCR_Format__c == 'Nombre'){
                    String n = String.valueOf(preinscription.get(field));
                    Decimal ValeurPres = Decimal.valueOf(n);
                    Decimal ValeurParam = Decimal.valueOf(eachParam.LPCR_Valeur__c);

                    if(ValeurPres >= ValeurParam && (!mapValeurNum.containsKey(field) || mapValeurNum.get(field) < ValeurParam)){
                        mapValeurNum.put(field, ValeurParam);
                        mapScore.put(field,eachParam.LPCR_Score__c );
                    }
                }
                
                else if(eachparam.LPCR_Format__c == 'Date'){
                    Date ValeurPres = null;
                    if(preinscription.get(field) instanceof Date) {
                        ValeurPres = Date.valueOf(preinscription.get(field));
                    }
                    else if(preinscription.get(field) instanceof String){
                        string ExtractedPresDate = String.valueof(preinscription.get(field));
                        list<String> lstSplitPresDate = ExtractedPresDate.split('/');
                        ValeurPres = date.newinstance(Integer.valueOf(lstSplitPresDate[2]), Integer.valueOf(lstSplitPresDate[1]), Integer.valueOf(lstSplitPresDate[0]));
                    }
                    
                    String ExtractedParamDate = eachParam.LPCR_Valeur__c;
                    list<String> lstSplitParamDate = ExtractedParamDate.split('/');
                    Date ValeurParam = date.newinstance(Integer.valueOf(lstSplitParamDate[2]), Integer.valueOf(lstSplitParamDate[1]), Integer.valueOf(lstSplitParamDate[0]));
         
                    if(ValeurPres >= ValeurParam && (!mapValeurDate.containsKey(field) || mapValeurDate.get(field) < ValeurParam)){
                        mapValeurDate.put(field, ValeurParam);
                        mapScore.put(field,eachParam.LPCR_Score__c );
                    }
                }
                
                else if(eachparam.LPCR_Format__c == 'Texte' || eachparam.LPCR_Format__c == 'Case à cocher'){
                    String ValeurPres = String.valueOf(preinscription.get(field));
                    String ValeurParam = String.valueOf(eachParam.LPCR_Valeur__c);
                    
                    if(ValeurPres == ValeurParam){
                        mapScore.put(field,eachParam.LPCR_Score__c );
                    }
                }
            }
        }
        
        Decimal totalScore = 0;
        for(Decimal score: mapScore.values()){
            totalScore = totalScore + score; 
        }
        return totalScore;
    }
    
}