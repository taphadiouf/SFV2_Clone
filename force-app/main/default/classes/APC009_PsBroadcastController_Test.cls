@isTest
public with sharing class APC009_PsBroadcastController_Test {
    @isTest
    static void testGetAllPermissionSet() {
        List<PermissionSet> sets = [SELECT Id,Name,Label FROM PermissionSet where name like 'LPCR%'];
        Test.startTest();
        List<PermissionSet> testSets = APC009_PsBroadcastController.getAllPermissionSet();
        Test.stopTest();
        system.assertEquals(sets.size(),testSets.size());
    }

    @isTest
    static void testGetAllObject() {
        Test.startTest();
        List<String> objectsNames = APC009_PsBroadcastController.getAllObject();
        Test.stopTest();
        system.assert(objectsNames.size()!=0);
    }

    @isTest
    static void testExecuteAsyncPsUpdatePositive() {
        Test.startTest();
        APC009_PsBroadcastController.executeAsyncPsUpdate('true','true','true','true','LPCR_Admin','Account');
        Test.stopTest();
        PermissionSet TmpPs = [select id, Name FROM PermissionSet where name = :'LPCR_Admin'];
        ObjectPermissions tmpOpList = [Select Id, parent.Name, parentId, SobjectType, 
                                            PermissionsCreate, 
                                            PermissionsRead, 
                                            PermissionsEdit 
                                            from ObjectPermissions 
                                            where Parent.Id = :TmpPs.Id  and SobjectType = :'Account' ];
        system.assertEquals(true,tmpOpList.PermissionsCreate);
    }

    @isTest
    static void testExecuteAsyncPsUpdateNegative() {
        User usr = [Select id from User where Id = :UserInfo.getUserId()];
        System.RunAs(usr){
            Test.startTest();
            APC009_PsBroadcastController.executeAsyncPsUpdate('false','false','true','false','LPCR_ADV','Account');
            Test.stopTest();
        }
        PermissionSet TmpPs = [select id, Name FROM PermissionSet where name = :'LPCR_ADV'];
        ObjectPermissions tmpOpList = [Select Id, parent.Name, parentId, SobjectType, 
                                            PermissionsCreate, 
                                            PermissionsRead, 
                                            PermissionsEdit 
                                            from ObjectPermissions 
                                            where Parent.Id = :TmpPs.Id  and SobjectType = :'Account' ];
        system.assertEquals(true,tmpOpList.PermissionsRead);
    }

}