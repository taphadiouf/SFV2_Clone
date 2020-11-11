/**
* @author Achraf ABOUL
* @created 26/02/2020
* @description Services class on Lead Object
*/
public class SM007_LeadServices {
    
    public static Set<Id> opportunitiesIds;
    public static Set<Id> accountsIds;
    public static Set<Id> contactsIds;
    public static void syncRecordTypesWithLeads(List<Lead> leadsList){
        //Map : target Object API Name => (Map : Lead recordtype developerName =>  target Recordtype DeveloperName)
        Map<String, Map<String, String>> leadRtToTargetRtMap = new Map<String, Map<String, String>>();
        leadRtToTargetRtMap.put('Opportunity', new Map<String, String>());
        leadRtToTargetRtMap.put('Account', new Map<String, String>());
        leadRtToTargetRtMap.put('Contact', new Map<String, String>());
        LPCR_LeadConversionRTMapping__mdt tempEachLeadConvRTMap;
        //This loop populates leadRtToTargetRtMap
        for(SObject eachLeadConvRTMapping : new EM013_LeadConversionRTMappingEntity().getAllWithAllFields()){
            tempEachLeadConvRTMap = (LPCR_LeadConversionRTMapping__mdt) eachLeadConvRTMapping;
            leadRtToTargetRtMap.get('Opportunity').put(tempEachLeadConvRTMap.LPCR_LeadRT__c, tempEachLeadConvRTMap.LPCR_OpportunityRT__c);
            leadRtToTargetRtMap.get('Account').put(tempEachLeadConvRTMap.LPCR_LeadRT__c, tempEachLeadConvRTMap.LPCR_AccountRT__c);
            leadRtToTargetRtMap.get('Contact').put(tempEachLeadConvRTMap.LPCR_LeadRT__c, tempEachLeadConvRTMap.LPCR_ContactRT__c);
        }
        
        //Map : Object API Name => (Map : recordtype DeveloperName =>  Recordtype Id)
        Map<String, Map<String, Id>> rtNamesToIdsMap = new Map<String, Map<String, String>>();
        rtNamesToIdsMap.put('Opportunity', new Map<String, Id>());
        rtNamesToIdsMap.put('Account', new Map<String, Id>());
        rtNamesToIdsMap.put('Contact', new Map<String, Id>());
        //End Map Def
        //Map : Lead RecordTypeId => Lead recordtype Developer Name
        Map<Id, String> leadRTIdToName = new Map<Id, String>();
        //End Map  Def
        
        //This loop populates rtNamesToIdsMap and leadRTIdToName
        for(RecordType eachRT : [SELECT Id, SObjectType, DeveloperName FROM RecordType 
                                 WHERE (SobjectType = 'Lead' AND DeveloperName IN :leadRtToTargetRtMap.get('Opportunity').keySet())  
                                 OR (SobjectType = 'Opportunity' AND DeveloperName IN :leadRtToTargetRtMap.get('Opportunity').values())  
                                 OR (SobjectType = 'Account' AND DeveloperName IN :leadRtToTargetRtMap.get('Account').values())
                                 OR (SobjectType = 'Contact' AND DeveloperName IN :leadRtToTargetRtMap.get('Contact').values())]){
                                     if(eachRT.SObjectType.equals('Lead')){
                                         leadRTIdToName.put(eachRT.Id, eachRT.DeveloperName);
                                     }
                                     else{
                                         rtNamesToIdsMap.get(eachRT.SObjectType).put(eachRT.DeveloperName, eachRT.Id);
                                     }
                                 }
        
        //Map : targetObject API Name => (Map : target record Id => Lead recordTypeId)
        Map<String, Map<Id, Id>> targetIdToLeadRtIdMap = new Map<String, Map<Id, Id>>();
        targetIdToLeadRtIdMap.put('Opportunity', new Map<Id, Id>());
        targetIdToLeadRtIdMap.put('Account', new Map<Id, Id>());
        targetIdToLeadRtIdMap.put('Contact', new Map<Id, Id>());
        //End Map def
        
        //This loop populates opportunitiesMap, accountsMap and  contactsMap with the mapping between (target record Id) => (Lead recordtypeId)
        for(Lead eachLead : leadsList){
            if(SM007_LeadServices.opportunitiesIds != null && SM007_LeadServices.opportunitiesIds.contains(eachLead.convertedOpportunityId)){
                targetIdToLeadRtIdMap.get('Opportunity').put(eachLead.convertedOpportunityId, eachLead.recordTypeId);
            } 
            if(SM007_LeadServices.accountsIds != null && SM007_LeadServices.accountsIds.contains(eachLead.convertedAccountId)){
                targetIdToLeadRtIdMap.get('Account').put(eachLead.convertedAccountId, eachLead.recordTypeId);               
            }
            if(SM007_LeadServices.contactsIds != null && SM007_LeadServices.contactsIds.contains(eachLead.convertedContactId)){
                targetIdToLeadRtIdMap.get('Contact').put(eachLead.convertedContactId, eachLead.recordTypeId);
            }
        }
        Map<String, List<SObject>> targetRecordsMap = new Map<String, List<SObject>>();
        Set<String> targetFields = new Set<String>();
        targetFields.add('RecordTypeId');
        targetRecordsMap.put('Opportunity', new EM004_OpportunityEntity().getByIds(targetIdToLeadRtIdMap.get('Opportunity').keySet(), targetFields));
        targetRecordsMap.put('Account', new EM005_AccountEntity().getByIds(targetIdToLeadRtIdMap.get('Account').keySet(), targetFields));
        targetRecordsMap.put('Contact', new EM011_ContactEntity().getByIds(targetIdToLeadRtIdMap.get('Contact').keySet(), targetFields));
        
        Id tmpLeadRecordTypeId;
        String tmpLeadRecordTypeName;
        String tmpTargetRecordTypeName;
        Id tmpTargetId;
        List<SObject> recordsToUpdate = new List<SObject>();
        for(String eachObjectName : targetRecordsMap.keySet()){
            for(SObject eachRecord : targetRecordsMap.get(eachObjectName)){
                tmpLeadRecordTypeId = targetIdToLeadRtIdMap.get(eachObjectName).get(eachRecord.Id);
                tmpLeadRecordTypeName = leadRTIdToName.get(tmpLeadRecordTypeId);
                tmpTargetRecordTypeName = leadRtToTargetRtMap.get(eachObjectName).get(tmpLeadRecordTypeName);
                tmpTargetId = rtNamesToIdsMap.get(eachObjectName).get(tmpTargetRecordTypeName);
                eachRecord.put('RecordTypeId', tmpTargetId);
            }
            recordsToUpdate.addAll(targetRecordsMap.get(eachObjectName));
        }
        PAD.log('SM007_LeadServices','syncRecordTypesWithLeads','recordsToUpdate list size'+recordsToUpdate.size());
        try{
            update recordsToUpdate;
        }catch(Exception ex){
            System.debug('*** Exception : '+ ex.getMessage());
            throw new AuraHandledException(ex.getMessage());
        }
        
        
    }
    public static void  createLiensCrecheLead(List<Lead> leadsList){
        List<LPCR_LienCrecheLead__c> liensCrechesLeads = new  List<LPCR_LienCrecheLead__c>();
        for(Lead eachLead : leadsList){
            if(!String.isEmpty(eachLead.LPCR_CodeCreche1__c)){
                liensCrechesLeads.add(new LPCR_LienCrecheLead__c(
                    LPCR_Creche__c = eachLead.LPCR_CodeCreche1__c,
                    LPCR_Lead__c = eachLead.Id,
                    LPCR_OrdrePreference__c = 1
                ));
            }
            if(!String.isEmpty(eachLead.LPCR_CodeCreche2__c)){
                liensCrechesLeads.add(new LPCR_LienCrecheLead__c(
                    LPCR_Creche__c = eachLead.LPCR_CodeCreche2__c,
                    LPCR_Lead__c = eachLead.Id,
                    LPCR_OrdrePreference__c = 2
                ));
            }
            if(!String.isEmpty(eachLead.LPCR_CodeCreche3__c)){
                liensCrechesLeads.add(new LPCR_LienCrecheLead__c(
                    LPCR_Creche__c = eachLead.LPCR_CodeCreche3__c,
                    LPCR_Lead__c = eachLead.Id,
                    LPCR_OrdrePreference__c = 3
                ));
            }
        }
        EM018_LienCrecheLead cl = new EM018_LienCrecheLead();
        String methodName = 'createLiensCrecheLead';
        cl.dmlExecuteRequest('insert', (List<SObject>) liensCrechesLeads, true, methodName, DM000_SObject.ProcessType.TRIGGER_SRC);
    }
    
    /* 
public static void syncOppRecordType(String leadRecordTypeName, String oppRecordTypeName, List<Lead> leadsList){
Id leadRecordTypeId = EM003_RecordTypeEntity.getRecTypeIdByObjectAndName('Lead',leadRecordTypeName);
Id opportunityRecordTypeId = EM003_RecordTypeEntity.getRecTypeIdByObjectAndName('Opportunity', oppRecordTypeName);
Set<Id> oppsIdsToSync = new Set<Id>();
for(Lead eachLead : leadsList){
if(eachLead.recordTypeId != null && (''+eachLead.recordTypeId).equals(''+leadRecordTypeId)){
oppsIdsToSync.add(eachLead.convertedOpportunityId);
}
}
Set<String> oppFields = new Set<String>();
oppFields.add('RecordTypeId');
List<Opportunity> oppsToSync = new EM004_OpportunityEntity().getByIds(oppsIdsToSync, oppFields);
for(Opportunity eachOpp : oppsToSync){
eachOpp.RecordTypeId = opportunityRecordTypeId;
}
update oppsToSync;
}
public static void syncRecordTypeWithLead(String sObjectAPIName, String leadRecordTypeName, String targetRecordTypeName, List<Lead> leadsList){
Id leadRecordTypeId = EM003_RecordTypeEntity.getRecTypeIdByObjectAndName('Lead',leadRecordTypeName);
Id targetRecordTypeId = EM003_RecordTypeEntity.getRecTypeIdByObjectAndName(sObjectAPIName, targetRecordTypeName);
EM001_AbstractObjectEntity objectEntity;
String targetReferenceField;
switch on sObjectAPIName{
when 'Opportunity'{
objectEntity  =  new EM004_OpportunityEntity();
targetReferenceField =  'convertedOpportunityId';
}
when 'Account'{
objectEntity  =  new EM005_AccountEntity();
targetReferenceField =  'convertedAccountId';

}
when 'Contact'{
objectEntity  =  new EM011_ContactEntity();
targetReferenceField =  'convertedContactId';            
}
}
Set<Id> targetIdsToSync = new Set<Id>();
for(Lead eachLead : leadsList){
if(eachLead.recordTypeId != null && (''+eachLead.recordTypeId).equals(''+leadRecordTypeId)){
targetIdsToSync.add((Id) eachLead.get(targetReferenceField));
}
}
Set<String> oppFields = new Set<String>();
oppFields.add('RecordTypeId');

List<SObject> recordsToSync = objectEntity.getByIds(targetIdsToSync, oppFields);
for(SObject eachRecord : recordsToSync){
eachRecord.put('RecordTypeId', targetRecordTypeId);
}
update recordsToSync;
}
*/
    
    public static void linkStructureAOsToOpps(List<Lead> convertedLeadsList){
        Id aoPublicReservationRT = EM003_RecordTypeEntity.getRecTypeIdByObjectAndName('Lead', 'AO_PublicReservation');
        Id aoPublicDSPRT = EM003_RecordTypeEntity.getRecTypeIdByObjectAndName('Lead', 'AO_PublicDSP');
        
        Map<Id, Lead> wantedLeadsMap = new Map<Id, Lead>();
        for(Lead eachLead : convertedLeadsList){
            if(!String.isEmpty(eachLead.recordTypeId) && (eachLead.recordTypeId.equals(aoPublicReservationRT) || eachLead.recordTypeId.equals(aoPublicDSPRT))){
                wantedLeadsMap.put(eachLead.id, eachLead);
            }
        }
        List<LPCR_Structure_AO__c> aoStructures = EM009_StructureAOEntity.getStructuresAOByLeads(wantedLeadsMap.keySet());
        for(LPCR_Structure_AO__c eachStructureAO : aoStructures){
            eachStructureAO.opportunite__c = wantedLeadsMap.get(eachStructureAO.LPCR_Lead__c).convertedOpportunityId;
        }
        EM009_StructureAOEntity cl = new EM009_StructureAOEntity();
        String methodName = 'linkStructureAOsToOpps';
        cl.dmlExecuteRequest('update', (List<SObject>) aoStructures, true, methodName, DM000_SObject.ProcessType.TRIGGER_SRC);
    }

    public static void mapFieldsFromLeadToOpp(List<Lead> convertedLeadsList){
        
        Id aoPublicReservationRT = EM003_RecordTypeEntity.getRecTypeIdByObjectAndName('Lead', 'AO_PublicReservation');
        Id aoPublicDSPRT = EM003_RecordTypeEntity.getRecTypeIdByObjectAndName('Lead', 'AO_PublicDSP');
        // MAP(lead, idopp)
        Map<Lead, Id> filtredLeadsMap = new Map<Lead, Id>();
        for(Lead eachLead : convertedLeadsList){
            if(!String.isEmpty(eachLead.recordTypeId) && (eachLead.recordTypeId.equals(aoPublicReservationRT) || eachLead.recordTypeId.equals(aoPublicDSPRT))){
                filtredLeadsMap.put(eachLead, eachLead.convertedOpportunityId);
            }
        }
        // MAP(idopp, Opp)
        Map<Id,Opportunity> idsOpps = new Map<Id,Opportunity>([SELECT Id,LPCR_IDAO__c,LPCR_ObjetAO__c,LPCR_DebutContrat__c,LPCR_DureeContrat__c,LPCR_FinContrat__c 
                                                                FROM Opportunity
                                                                WHERE id in :filtredLeadsMap.values()]);
        // MAP(lead, opp)
        Map<Lead, Opportunity> LeadOpps = new Map<Lead, Opportunity>();
        for(Lead eachLead : filtredLeadsMap.keyset()){
            LeadOpps.put( eachLead , idsOpps.get(filtredLeadsMap.get(eachLead)) );
        }
        //Process
        for(Lead eachLead : LeadOpps.keyset()){
            //map fields from lead to opportunity
            LeadOpps.get(eachLead).LPCR_IDAO__c = eachLead.LPCR_IDAO__c ;
            LeadOpps.get(eachLead).LPCR_ObjetAO__c = eachLead.LPCR_ObjetAO__c ;
            LeadOpps.get(eachLead).LPCR_DebutContrat__c = eachLead.LPCR_DebutContrat__c ;
            LeadOpps.get(eachLead).LPCR_FinContrat__c = eachLead.LPCR_FinContrat__c ;
        }        
        update LeadOpps.values();
    }
    
    
    public static void blockConversionwithWrongRecType(List<Lead> leadsList){
                
        Set<Id> leadsListIds = UM003_TypeManager.getIdsOfListObjects(leadsList);        
        Map<Id,Lead> mapLead = new Map<Id,Lead>([Select Id, Name, RecordType.DeveloperName,ConvertedAccountId, ConvertedOpportunityId, ConvertedContactId From Lead Where Id In: leadsListIds ]);
        
        Set<String> leadsAccIds = UM003_TypeManager.getFieldsOfListObjects(leadsList,'ConvertedAccountId');
        Map<Id,Account> mapAccount = new Map<Id,Account>([Select Id, Name,RecordTypeId ,RecordType.DeveloperName From Account Where Id In: leadsAccIds]);
        
        Set<String> leadsOppIds = UM003_TypeManager.getFieldsOfListObjects(leadsList,'ConvertedOpportunityId');
        Map<Id,Opportunity> mapOpportunity = new Map<Id,Opportunity>([Select Id, Name,RecordTypeId ,RecordType.DeveloperName From Opportunity Where Id In: leadsOppIds]);
        
        Set<String> leadsConIds = UM003_TypeManager.getFieldsOfListObjects(leadsList,'ConvertedContactId');
        Map<Id,Contact> mapContact = new Map<Id,Contact>([Select Id, Name,RecordTypeId ,RecordType.DeveloperName From Contact Where Id In: leadsConIds]);
        
        
        for(Lead eachLead : leadsList){
            
            if(eachLead.ConvertedAccountId != null) {
                
                if(mapLead.get(eachLead.Id).RecordType.DeveloperName != 'AO_PublicReservation' && mapLead.get(eachLead.Id).RecordType.DeveloperName != 'AO_PublicDSP' ){
                    
                    if(mapLead.get(eachLead.Id).RecordType.DeveloperName != mapAccount.get(eachLead.ConvertedAccountId).RecordType.DeveloperName){
                		eachLead.addError('Le Compte choisi doit être du même type que le Lead');
                	}
                    if(mapLead.get(eachLead.Id).RecordType.DeveloperName != mapContact.get(eachLead.ConvertedContactId).RecordType.DeveloperName){
                		eachLead.addError('Le Contact choisi doit être du même type que le Lead');
                	}
                    if(mapLead.get(eachLead.Id).RecordType.DeveloperName != mapOpportunity.get(eachLead.ConvertedOpportunityId).RecordType.DeveloperName){
                		eachLead.addError('Opportunité choisi doit être du même type que le Lead');
                	}
                }
                else{
                    
                    if(mapAccount.get(eachLead.ConvertedAccountId).RecordType.DeveloperName != 'Entreprise'){
                		eachLead.addError('Le Compte choisi doit être du type entreprise');
                	}
                    if(mapContact.get(eachLead.ConvertedContactId).RecordType.DeveloperName != 'Entreprise'){
                		eachLead.addError('Le Contact choisi doit être du type entreprise');
                	}
                    if(mapLead.get(eachLead.Id).RecordType.DeveloperName == 'AO_PublicReservation' && mapOpportunity.get(eachLead.ConvertedOpportunityId).RecordType.DeveloperName != 'AOPublicReservation'){
                		eachLead.addError('Opportunité choisi doit être du type AO Public Reservation');
                	}
                    if(mapLead.get(eachLead.Id).RecordType.DeveloperName == 'AO_PublicDSP' && mapOpportunity.get(eachLead.ConvertedOpportunityId).RecordType.DeveloperName != 'AOPublicDSP'){
                		eachLead.addError('Opportunité choisi doit être du type AO Public DSP');
                	}
                }
            }
        }
       
    }
}