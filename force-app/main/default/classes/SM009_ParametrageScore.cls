/**
* @author Ayoub Ouarti
* @date 05/03/2020
* @description Service class for SM009_ParametrageScore
*/
public with sharing class SM009_ParametrageScore {

public static void setScoreOnpreinscriptions(List<LPCR_Preinscirption__c> preinscriptions){

Map<Id,LPCR_ParametrageScore__c> mapParametrageScore = new Map<Id,LPCR_ParametrageScore__c>([SELECT Id,LPCR_Anciennete__c,LPCR_NbJourGarde__c,LPCR_Revenu__c,LPCR_Score__c,LPCR_DateEntreeCreche__c FROM LPCR_ParametrageScore__c]);


for(LPCR_Preinscirption__c eachPreinscription : preinscriptions){
    scoreCalculation(eachPreinscription , mapParametrageScore);
}

}



public  Decimal scoreCalculation(LPCR_Preinscirption__c preinscription,Map<Id,LPCR_ParametrageScore__c> mapParametrageScore){

    Decimal[] previousTranchTab= new Decimal[]{-1,-1,-1,-1,-1};
    Decimal[] scoreTab= new Decimal[]{-1,-1,-1,-1,-1};
    Decimal scoreFinal =0;
    for(LPCR_ParametrageScore__c eachParam : mapParametrageScore.values()){

        //Anciennete
        if(preinscription.LPCR_Anciennete__c!=null && preinscription.LPCR_Anciennete__c  <= eachParam.LPCR_Anciennete__c && (previousTranchTab[0] > eachParam.LPCR_Anciennete__c && scoreTab[0]!=-1)){
            scoreTab[0] = eachParam.LPCR_Score__c;
            previousTranchTab[0] = eachParam.LPCR_Anciennete__c;
            continue;
        }


     // Nombre de jour de garde par semaine
        if(preinscription.LPCR_NombreJours__c!=null  && preinscription.LPCR_NombreJours__c  <= eachParam.LPCR_NbJourGarde__c && (previousTranchTab[1] > eachParam.LPCR_NbJourGarde__c && scoreTab[1]!=-1)){
            scoreTab[1] = eachParam.LPCR_Score__c;
            previousTranchTab[1] = eachParam.LPCR_NbJourGarde__c;
            continue;
        }

/*
    // Revenus
        if( preinscription.LPCR_Revenu__c !=null  && preinscription.LPCR_Revenu__c  <= eachParam.LPCR_Revenu__c && (previousTranchTab[2] > eachParam.LPCR_Revenu__c && scoreTab[2]!=-1)){
            scoreTab[2] = eachParam.LPCR_Score__c;
            previousTranchTab[2] = eachParam.LPCR_Revenu__c;
            continue;
        }
*/
    // La demande et/ou réponse de la crèche municipale 
        if(preinscription.LPCR_ReponseCrecheMunicipale__c!=null &&  preinscription.LPCR_ReponseCrecheMunicipale__c == eachParam.LPCR_ReponseCrecheMunicipale__c ){
                scoreTab[3] = eachParam.LPCR_Score__c;
                continue;
        }

  
     // La date d’entrée 
        if(preinscription.LPCR_DateEntreeCreche__c!=null  && preinscription.LPCR_DateEntreeCreche__c  <= eachParam.LPCR_DateEntreeCreche__c && (previousTranchTab[4] > eachParam.LPCR_NbJourGarde__c && scoreTab[4]!=-1)){
            scoreTab[4] = eachParam.LPCR_Score__c;
            previousTranchTab[4] = eachParam.LPCR_DateEntreeCreche__c;
            continue;
        }
        
       
    }

    for(Integer i=0; i<5 ;i++){
        if(scoreTab[i]!=-1){
            scoreFinal+=scoreTab[i];
        }
    }


    return scoreFinal;
}
    
}