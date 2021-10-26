/**
* @author Saurabh
* @created 27/06/2020
* @description HttpCalloutMock class: MCK001_LPCRHttpCalloutMockImpl.
*/

global class MCK001_LPCRHttpCalloutMockImpl implements HttpCalloutMock{

    global boolean failResponse = false;

    global MCK001_LPCRHttpCalloutMockImpl(){

    }
    global MCK001_LPCRHttpCalloutMockImpl(boolean fail){
        this.failResponse = fail;
    }

    global HTTPResponse respond(HTTPRequest req) {
        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'application/json');
        String sendDocumentEndpoint;
        String getDocumentEndpoint;
        String getDocumentListEndpoint;
        String sendMailEndpoint;
        String sendContactEndpoint;
        String downloadDocumentEndpoint;
        LPCR_Environnement__c envCS = LPCR_Environnement__c.getInstance();
        if('UAT'.equals(envCS.Nom__c)){
            sendDocumentEndpoint = 'UAT_SEND_DOCUMENT';
            getDocumentEndpoint = 'UAT_GET_DOCUMENT';
            // getDocumentListEndpoint = 'UAT_DOCUMENT_LISTE';
            // sendMailEndpoint = 'UAT_SEND_MAIL';
            getDocumentListEndpoint = 'LPCR_UAT_DOCUMENT_LIST';
            sendMailEndpoint = 'LPCR_UAT_SEND_MAIL';
            sendContactEndpoint = 'UAT_ENVOIE_CONTACT_ENTREPRISE';
            downloadDocumentEndpoint = 'LPCR_UAT_DOCUMENT_DOWNLOAD';
        }
        else if('PROD'.equals(envCS.Nom__c)){
            sendDocumentEndpoint = 'PROD_SEND_DOCUMENT';
            getDocumentEndpoint = 'PROD_GET_DOCUMENT';
            // getDocumentListEndpoint = 'PROD_DOCUMENT_LISTE';
            // sendMailEndpoint = 'PROD_SEND_MAIL';
            getDocumentListEndpoint = 'LPCR_PRO_DOCUMENT_LIST';
            sendMailEndpoint = 'LPCR_PRO_SEND_MAIL';
            sendContactEndpoint = 'PROD_ENVOIE_CONTACT_ENTREPRISE';
            downloadDocumentEndpoint = 'LPCR_PRO_DOCUMENT_DOWNLOAD';

        }
        else{
            sendDocumentEndpoint = 'DEV_SEND_DOCUMENT';
            getDocumentEndpoint = 'DEV_GET_DOCUMENT';
            // getDocumentListEndpoint = 'DEV_DOCUMENT_LISTE';
            // sendMailEndpoint = 'DEV_SEND_MAIL';
            getDocumentListEndpoint = 'LPCR_DEV_DOCUMENT_LIST';
            sendMailEndpoint = 'LPCR_DEV_SEND_MAIL';
            sendContactEndpoint = 'DEV_ENVOIE_CONTACT_ENTREPRISE';
            downloadDocumentEndpoint = 'LPCR_DEV_DOCUMENT_DOWNLOAD';
        }
        if(req.getEndpoint().contains(sendDocumentEndpoint)){
            System.debug(req.getBody());
            WRP004_APISaveDocument data = (WRP004_APISaveDocument) JSON.deserialize(req.getBody(), WRP004_APISaveDocument.class);
            if(!failResponse){
                if(String.isNotBlank(data.OwnerSfId)){
                    res.setBody('{"result":"200"}');
                    res.setStatusCode(200);
                }else{
                    res.setBody('{"result":"503"}');
                    res.setStatusCode(503);
                }  
            }else {
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
            // if(String.isNotBlank(data.OwnerSfId)){
            if(data.owners.size()>0){
                // res.setBody('[{"id":"10212021","DocumentType":"Facture"}]');
                res.setBody('{"totalResultSize": 2,"pageResult": [{"guid": "b080a081-f596-4ba6-a76c-8c3e2c517af8","owners": ["0011j000017CBiWAAW"],"fileName": "test","fileCategory": "Facture","versions": [{"blobGUID": "d6511858-ad20-4e25-9d08-6154851659e7","fileExtension": "txt","fileSize": 16,"date": "2021-10-07T13:34:38.631834","checksum": "DiyVXGD0KaEvfl2BA5sg+Ti0PB8D7qu7heC/aQd1PfI=","modifiedBy": "2bb19ad2-27e3-41b6-b7f9-9e0858373ac7"}]}]}');
                res.setStatusCode(200);
            }else{
                res.setBody('{"result":"503"}');
                res.setStatusCode(503);
            }
        }else if(req.getEndpoint().contains(sendMailEndpoint)){
            System.debug(req.getBody());
            System.debug(req.getEndpoint());
            res.setBody('{"result":"200"}');
            res.setStatusCode(200);
        }else if(req.getEndpoint().contains(sendContactEndpoint) || req.getEndpoint().contains(downloadDocumentEndpoint)){
            System.debug(req.getBody());
            System.debug(req.getEndpoint());
            res.setBody('true');
            res.setStatusCode(200);
        }     
        return res;
    }
}