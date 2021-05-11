@isTest
public class EM003_RecordTypeEntity_Test {
    
    @isTest
    static void EM003_RecordTypeEntityTest() {

        Id expId = [SELECT id FROM RecordType Where sObjectType=:Label.LPCR_Account AND developername =:Label.LPCR_Famille].id;
        Test.startTest();
        Id familleAccountRT = EM003_RecordTypeEntity.getRecTypeIdByObjectAndName(Label.LPCR_Account, Label.LPCR_Famille);
        //Assertion 2 : Null : 
        System.assertEquals(null, EM003_RecordTypeEntity.getRecTypeIdByObjectAndName(Label.LPCR_Account, ''));
        Test.stopTest();
        //Assertion 1 : return the right Id.
        System.assertEquals(expId, familleAccountRT);

    }
}