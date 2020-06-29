/**
* @author Ayoub Ouarti
* @date 05/03/2020
* @description Service class for SM009_ParametrageScoreServices
*/
public with sharing class SM009_ParametrageScoreServices {
    
    public static void setScoreOnpreinscriptions(List<LPCR_Preinscription__c> preinscriptions){
        
        Map<Id,LPCR_ParametrageScore__c> mapParametrageScore = new Map<Id,LPCR_ParametrageScore__c>([SELECT Id,LPCR_ReponseCrecheMunicipale__c,LPCR_Anciennete__c,LPCR_NbJourGarde__c,LPCR_Revenu__c,LPCR_Score__c,LPCR_DateEntree__c FROM LPCR_ParametrageScore__c]);
        
        if(mapParametrageScore!=null){
            for(LPCR_Preinscription__c eachPreinscription : preinscriptions){
                eachPreinscription.LPCR_Score__c= scoreCalculation(eachPreinscription , mapParametrageScore);
            } 
        }        
    }
    
    public static Decimal scoreCalculation(LPCR_Preinscription__c preinscription,Map<Id,LPCR_ParametrageScore__c> mapParametrageScore){
        
        Decimal[] previousTranchTab= new Decimal[]{-1,-1,-1,-1};
        Date previousDate = null;
        Decimal[] scoreTab= new Decimal[]{-1,-1,-1,-1,-1};
        Decimal finalScore =0;
        for(LPCR_ParametrageScore__c eachParam : mapParametrageScore.values()){
            
           //Anciennete
            if(eachParam.LPCR_Anciennete__c!=null &&
               preinscription.LPCR_Anciennete__c  >= eachParam.LPCR_Anciennete__c && 
               (previousTranchTab[0] ==-1 || (previousTranchTab[0] < eachParam.LPCR_Anciennete__c && scoreTab[0]!=-1))){
                scoreTab[0] = eachParam.LPCR_Score__c;
                previousTranchTab[0] = eachParam.LPCR_Anciennete__c;
               continue;
            }
            
            
            // Nombre de jour de garde par semaine
            if(eachParam.LPCR_NbJourGarde__c!=null  
               && preinscription.LPCR_NombreJours__c  >= eachParam.LPCR_NbJourGarde__c 
               && (previousTranchTab[1]==-1 || (previousTranchTab[1] < eachParam.LPCR_NbJourGarde__c && scoreTab[1]!=-1))){
                scoreTab[1] = eachParam.LPCR_Score__c;
                previousTranchTab[1] = eachParam.LPCR_NbJourGarde__c;
                 continue;
            }
            
            
            // Revenus
            if( eachParam.LPCR_Revenu__c !=null  
               && preinscription.LPCR_Revenu__c  >= eachParam.LPCR_Revenu__c
               && (previousTranchTab[2]==-1 || (previousTranchTab[2] < eachParam.LPCR_Revenu__c && scoreTab[2]!=-1))){
                scoreTab[2] = eachParam.LPCR_Score__c;
                previousTranchTab[2] = eachParam.LPCR_Revenu__c;
                  continue;
               
            }
            
         
            
            // La date d’entrée 
            if(eachParam.LPCR_DateEntree__c!=null  
               && preinscription.LPCR_DateEntreeCreche__c  >= eachParam.LPCR_DateEntree__c 
               && (previousDate==null || (previousDate < eachParam.LPCR_DateEntree__c && scoreTab[4]!=-1))){
                scoreTab[4] = eachParam.LPCR_Score__c;
                previousDate = eachParam.LPCR_DateEntree__c;
                 continue;
            }
            
           
               // La demande et/ou réponse de la crèche municipale 
            if(eachParam.LPCR_Anciennete__c==null && eachParam.LPCR_NbJourGarde__c==null && eachParam.LPCR_Revenu__c ==null && eachParam.LPCR_DateEntree__c==null  
               && eachParam.LPCR_ReponseCrecheMunicipale__c!=null &&  scoreTab[3]==-1  ){
                if(preinscription.LPCR_ReponseCrecheMunicipale__c ==  eachParam.LPCR_ReponseCrecheMunicipale__c){
                    scoreTab[3] = eachParam.LPCR_Score__c;
                    continue;
                }
               
                
            }
            
        }
        
        for(Integer i=0; i<5 ;i++){
            if(scoreTab[i]!=-1){
                finalScore+=scoreTab[i];
            }
        }
        
        
        return finalScore;
    }
    
}