/**
* @author Saurabh
* @created 27/06/2020
* @description HttpCalloutMock class: MCK001_LPCRHttpCalloutMockImpl.
*/

global class MCK001_LPCRHttpCalloutMockImpl implements HttpCalloutMock{
    global HTTPResponse respond(HTTPRequest req) {
        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'application/json');
        String sendDocumentEndpoint;
        String getDocumentEndpoint;
        String getDocumentListEndpoint;
        String sendMailEndpoint;
        LPCR_Environnement__c envCS = LPCR_Environnement__c.getInstance();
        if('UAT'.equals(envCS.Nom__c)){
            sendDocumentEndpoint = 'UAT_SEND_DOCUMENT';
            getDocumentEndpoint = 'UAT_GET_DOCUMENT';
            getDocumentListEndpoint = 'UAT_DOCUMENT_LISTE';
            sendMailEndpoint = 'UAT_SEND_MAIL';

        }
        else if('PROD'.equals(envCS.Nom__c)){
            sendDocumentEndpoint = 'PROD_SEND_DOCUMENT';
            getDocumentEndpoint = 'PROD_GET_DOCUMENT';
            getDocumentListEndpoint = 'PROD_DOCUMENT_LISTE';
            sendMailEndpoint = 'PROD_SEND_MAIL';

        }
        else{
            sendDocumentEndpoint = 'DEV_SEND_DOCUMENT';
            getDocumentEndpoint = 'DEV_GET_DOCUMENT';
            getDocumentListEndpoint = 'DEV_DOCUMENT_LISTE';
            sendMailEndpoint = 'DEV_SEND_MAIL';
        }
        if(req.getEndpoint().contains(sendDocumentEndpoint)){
            System.debug(req.getBody());
            WRP004_APISaveDocument data = (WRP004_APISaveDocument) JSON.deserialize(req.getBody(), WRP004_APISaveDocument.class);
            if(String.isNotBlank(data.OwnerSfId)){
                res.setBody('{"result":"200"}');
                res.setStatusCode(200);
            }else{
                res.setBody('{"result":"503"}');
                res.setStatusCode(503);
            }                        
        }else if(req.getEndpoint().contains(getDocumentEndpoint)){
            System.debug(req.getBody());
            System.debug(req.getEndpoint());
            if(req.getEndpoint().split('/').size() > 1){
                String jsonResponse = '{'+
                ' \"binaryDocument\":\"Test file content\"' +
                '}';
                res.setBody(jsonResponse);
                res.setStatusCode(200);
            }else{
                res.setBody('');
                res.setStatusCode(500);
            } 
        }else if(req.getEndpoint().contains(getDocumentListEndpoint)){
            System.debug(req.getBody());
            System.debug(req.getEndpoint());
            SM019_DocumentList_Callout.DocumentListStructureWrapper data = (SM019_DocumentList_Callout.DocumentListStructureWrapper) JSON.deserialize(req.getBody(), SM019_DocumentList_Callout.DocumentListStructureWrapper.class);
            if(String.isNotBlank(data.OwnerSfId)){
                res.setBody('[{"id":"102120210212021021","DocumentType":"Facture"}]');
                res.setStatusCode(200);
            }else{
                res.setBody('{"result":"503"}');
                res.setStatusCode(503);
            }
        }else if(req.getEndpoint().contains(sendMailEndpoint)){
            System.debug(req.getBody());
            System.debug(req.getEndpoint());
            res.setBody('{"result":"503"}');
            res.setStatusCode(503);
        }              
        return res;
    }
}