/**
* @author Erwan Yhuellou
* @created 22/06/2020
* @description Apex class used for lwc009. Mass Editing a Permission Set 
*/
public with sharing class APC009_PsBroadcastController {


    @AuraEnabled(cacheable=true)
    public static List<PermissionSet> getAllPermissionSet() {
        
        return [SELECT Id,Name,Label FROM PermissionSet where name like 'LPCR%'];

    }
 
    @AuraEnabled(cacheable=true)
    public static Boolean executeAsyncPsUpdate(String tmpCreate, String tmpDelete, String tmpRead, String tmpEdit, String tmpPsName) {
        
        Boolean pCreate = (tmpCreate == 'true') ? true : false;
        Boolean pDelete = (tmpDelete == 'true') ? true : false;
        Boolean pRead = (tmpRead == 'true') ? true : false;
        Boolean pEdit = (tmpEdit == 'true') ? true : false;

        execAsync(pCreate, pDelete, pRead, pEdit, tmpPsName);
        return true;

    }



    public static Boolean objectPermissionAlreadyExists(String objectName, List<ObjectPermissions> tmpList) {
        
        for (ObjectPermissions o : tmpList) {
            if (o.SobjectType == objectName) {
                return true;
            }
        }
        return false;		        
    }
    
    public static List<FieldPermissions> cleanFpList(List<FieldPermissions> tmpList, String tmpObj) {
        
        SObjectType tmpObjType = Schema.getGlobalDescribe().get(tmpObj);
        Map<String,Schema.SObjectField> tmpMapFields = tmpObjType.getDescribe().fields.getMap();
        
        
        List<FieldPermissions> res = new List<FieldPermissions>();
        
        for (FieldPermissions f : tmpList) {
                    
            List<String> parts = f.field.split('\\.' , 2);
        
            
            if (tmpMapFields.get(parts[1]) == null) {
                PAD.log('APC009_PsBroadcastController', 'cleanFpList', 'cleanFpList', parts[1]) ;
            }
            else {
                if (tmpMapFields.get(parts[1]) != null) {
                    res.add(f);
                }
            }
        }
        
        return res;	        
    }
    
    public static Boolean fieldPermissionAlreadyExists(String fieldName, List<FieldPermissions> tmpList, Map<String,Schema.SObjectField> tmpMapfields, String tmpObj) {
                
        for (FieldPermissions f : tmpList) {
            
            if (f.SobjectType == tmpObj) {
            
                List<String> parts = f.field.split('\\.' , 2);
                Schema.Sobjectfield field = tmpMapfields.get(parts[1]);
                Schema.Describefieldresult fieldDesc = field.getDescribe();
                String fieldAPIName = fieldDesc.getName();             
                
                if (fieldAPIName == fieldName) {
                    return true;
                }
            }
        }
        return false;		        
    }
    
    public static Id getFieldPermissionByFieldNameAndPermissionSet(String tmpFieldName, Id tmpParentId, List<FieldPermissions> tmpList, Map<String,Schema.SObjectField> tmpMapfields, String tmpObj) {
        
        for (FieldPermissions f : tmpList) {
            
            if (f.SobjectType == tmpObj) {
                
                List<String> parts = f.field.split('\\.' , 2);
                Schema.Sobjectfield field = tmpMapfields.get(parts[1]);
                Schema.Describefieldresult fieldDesc = field.getDescribe();
                                
                String fieldAPIName = fieldDesc.getName();
                
                if (fieldAPIName == tmpFieldName) {
                    return f.Id;
                }
            }
        }
        return null;
    }
    
    
    @future 
    public static void execAsync(Boolean tmpCreate, Boolean tmpDelete, Boolean tmpRead, Boolean tmpEdit, String PsName) {
        
        
        PermissionSet TmpPs = [select id, Name FROM PermissionSet where name = :PsName];
        
        Map<String, Schema.SObjectType> gd = Schema.getGlobalDescribe();
        Set<String> OBKeys = gd.keySet();
        
        Set<String> tmpObjSet = new Set<String>();
        Set<String> tmpFldSet = new Set<String>();
        
        for(String OBKey: OBKeys) {
            
            Schema.SobjectType sobjecttype = gd.get(OBKey);
            Schema.DescribeSObjectResult r = sobjecttype.getDescribe();   

            if (!r.isCreateable()) {
                continue;
            }
            
            

            if ((r.getName().contains('LPCR_') || 
                    r.getName() == 'Account' ||
                    r.getName() == 'Contact' || 
                    r.getName() == 'Opportunity' ||
                    r.getName() == 'Case' //||
                    //r.getName() == 'Order' ||
                    //r.getName() == 'OrderItem' ||
                    //r.getName() == 'Contract'
            )
                
                && !r.getName().endsWith('Event') && !r.getName().endsWith('History') && !r.getName().endsWith('Share')) {
                    //LPCR_TemplateSignatureElectronique__c + LPCR_LeadConversionRTMapping__mdt probleme picklist à identifier
                    //
                    //Don't take controlled by parent object
                    if (//r.getName() != 'LPCR_Preinscription__c' && 
                        r.getName() != 'LPCR_ParametrePreinscription__c' && 
                        //r.getName() != 'LPCR_BonAchatPartenaire__c' && 
                        //r.getName() != 'LPCR_PlanningPrevisionnel__c' && 
                        //r.getName() != 'LPCR_LienCrecheLead__c' && 
                        r.getName() != 'LPCR_TemplateSignatureElectronique__c' //&&
                        //r.getName() != 'LPCR_LeadConversionRTMapping__mdt' &&
                        //r.getName() != 'LPCR_TypeContrat__mdt' && 
                        //r.getName() != 'LPCR_Type_Evenement_Intranet__mdt' && 
                        //r.getName() != 'LPCR_LienCrecheOpportunite__c'
                        )
                        
                        tmpObjSet.add(r.getName()); 
                	}
        }
        
        List<ObjectPermissions> tmpOpList = [Select Id, parent.Name, parentId, SobjectType, PermissionsCreate, PermissionsRead, PermissionsEdit from ObjectPermissions where Parent.Id = :TmpPs.Id  and SobjectType in :tmpObjSet ];
        Map<String, ObjectPermissions> tmpMapOp = new Map<String, ObjectPermissions>();
        
        System.Debug('>>> tmpObjSet:' + tmpObjSet);        
        System.Debug('>>> tmpOpList.size():' + tmpOpList.size());
        
        for (ObjectPermissions tmpOp : tmpOpList) {
            tmpMapOp.put(tmpOp.SobjectType, tmpOp);
        }
        
        List<ObjectPermissions> tmpUpdate = new List<ObjectPermissions>();
        List<ObjectPermissions> tmpInsert = new List<ObjectPermissions>();        
        
        for (String s : tmpObjSet) {
            
            System.Debug('>>> s:' + s);
            
            if (objectPermissionAlreadyExists(s, tmpOpList) == true) {
                ObjectPermissions tmpOp = new ObjectPermissions();
                tmpOp.Id          = tmpMapOp.get(s).Id;
                tmpOp.PermissionsCreate = tmpCreate;
                tmpOp.PermissionsRead   = tmpRead;
                tmpOp.PermissionsEdit   = tmpEdit;
                tmpUpdate.add(tmpOp);
            }
            else {
                ObjectPermissions tmpOp = new ObjectPermissions();
                tmpOp.parentId          = TmpPs.Id;
                tmpOp.SobjectType = s;
                tmpOp.PermissionsCreate = tmpCreate;
                tmpOp.PermissionsRead   = tmpRead;
                tmpOp.PermissionsEdit   = tmpEdit;
                tmpOp.PermissionsDelete = tmpDelete;
                tmpOp.PermissionsModifyAllRecords = false;
                tmpOp.PermissionsViewAllRecords = false;

                tmpInsert.add(tmpOp);
            }
        }
        update tmpUpdate;
        insert tmpInsert;
        
        List<FieldPermissions> tmpFpListToInsert = new List<FieldPermissions>();
        List<FieldPermissions> tmpFpListToUpdate = new List<FieldPermissions>();
        List<FieldPermissions> tmpFpList = [Select Id, Field, ParentId, SobjectType, PermissionsEdit, PermissionsRead from FieldPermissions where ParentId = :TmpPs.Id  and SobjectType in :tmpObjSet];
        Map<String, FieldPermissions> tmpMapFp = new Map<String, FieldPermissions>();
        
        for (String obj : tmpObjSet) { // Nom Objet
            
            SObjectType tmpObj = Schema.getGlobalDescribe().get(obj);
            Map<String,Schema.SObjectField> mfields = tmpObj.getDescribe().fields.getMap();
            
            for (Schema.SObjectField sField : mfields.values()) { // All objects Fields
                
                schema.DescribeFieldResult fieldDesc = sField.getDescribe(); 
                String fieldAPIName = fieldDesc.getName();  

                
                Schema.Sobjectfield field = mfields.get(fieldAPIName);
                if (field == null || !fieldAPIName.startsWith('LPCR_')) {
                    continue;
                }
                                
                List<FieldPermissions> tmpFpListRes = new List<FieldPermissions>();
                tmpFpListRes = cleanFpList(tmpFpList, obj);              
               
                if (fieldDesc.isAccessible() && fieldDesc.isPermissionable() && !fieldDesc.isRestrictedPicklist()) {  
                    
                    FieldPermissions tmpFp = new FieldPermissions();
                    tmpFp.PermissionsRead   = tmpRead; 
                    
                    if (fieldDesc.isAccessible() && fieldDesc.isUpdateable()) {
                        tmpFp.PermissionsEdit   = tmpEdit;
                    }
                    
                    if (fieldPermissionAlreadyExists(fieldAPIName, tmpFpListRes, mfields, obj)) {
                        
                        tmpFp.Id = getFieldPermissionByFieldNameAndPermissionSet(fieldAPIName, TmpPs.Id, tmpFpListRes, mfields, obj);
                        PAD.log('APC009_PsBroadcastController', 'execAsync', 'Field setted by upd :', obj + '.' + fieldAPIName) ;
                        tmpFpListToUpdate.add(tmpFp);
                    }
                    else {
                        
                            tmpFp.ParentId = TmpPs.Id;
                            tmpFp.SobjectType = obj;
                            tmpFp.Field = obj + '.' + fieldAPIName;
                            PAD.log('APC009_PsBroadcastController', 'execAsync', 'Field setted by ins :', obj + '.' + fieldAPIName) ;
                            tmpFpListToInsert.add(tmpFp);
                    }
                }  
            }
        }

        PAD.log('APC009_PsBroadcastController', 'execAsync', 'tmpFpListToUpdate.size():', String.valueOf(tmpFpListToUpdate.size()));
        PAD.log('APC009_PsBroadcastController', 'execAsync', 'tmpFpListToInsert.size():', String.valueOf(tmpFpListToInsert.size()));
        
        update tmpFpListToUpdate;
        PAD.log('APC009_PsBroadcastController', 'execAsync', 'tmpFpListToUpdate finished');
        insert tmpFpListToInsert;
        PAD.log('APC009_PsBroadcastController', 'execAsync', 'tmpFpListToInsert finished');
        PAD.log('APC009_PsBroadcastController', 'execAsync', 'process finished');
    }  
}
