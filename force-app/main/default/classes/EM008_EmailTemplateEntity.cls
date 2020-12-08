/**
* @author Achraf ABOUL
* @date 06/03/2020
* @Description Queries about EmailTemplate
*/
public class EM008_EmailTemplateEntity {
    
    public static List<EmailTemplate> getAllEmailTemplates(){
        return [SELECT Id,Name,Subject,Body,HtmlValue FROM EmailTemplate];
    }
}