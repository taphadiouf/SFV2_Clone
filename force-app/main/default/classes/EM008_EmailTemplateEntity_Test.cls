@isTest
public class EM008_EmailTemplateEntity_Test {
    
    @isTest
    static void EM008_EmailTemplateEntity_Test() {

        EmailTemplate emTemplate = UM002_TestDataFactory.createEmailTemplate('Test', 'Test', 'custom');
        insert emTemplate;

        List<EmailTemplate> res = EM008_EmailTemplateEntity.getAllEmailTemplates();
        System.assertNotEquals(0, res.size());
    
    }
}
