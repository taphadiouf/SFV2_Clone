@isTest
public class EM007_PreinscriptionEntity_Test {
    
    @isTest
    static void EM007_PreinscriptionEntity_Test() {
        Account acc = UM002_TestDataFactory.createAccount('test');
        insert acc;

        UM002_TestDataFactory.ContactTdf c = new UM002_TestDataFactory.ContactTdf();
        Contact contact= c.create('Test','Test', acc);
        contact.RecordTypeId = EM003_RecordTypeEntity.getRecTypeIdByObjectAndName(System.Label.LPCR_Contact, System.Label.LPCR_Enfant);
        insert contact;

        List<LPCR_Preinscription__c> lstPreinscrition = UM002_TestDataFactory.createPreinscForEntreprise(10,'nomEnfant','prenom',null,acc.Id,contact.Id);
        insert lstPreinscrition;
        
        List<LPCR_Preinscription__c> res = EM007_PreinscriptionEntity.getPreinscriptionsByAccId(acc.Id);
        System.assertEquals(10, res.size());

        List<LPCR_Preinscription__c> res2 = EM007_PreinscriptionEntity.getListofPreinscriptionById(new List<Id>{lstPreinscrition.get(0).id});
        System.assertEquals(1, res2.size());

    }
}