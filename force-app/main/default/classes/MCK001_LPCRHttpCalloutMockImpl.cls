/**
* @author Saurabh
* @created 27/06/2020
* @description HttpCalloutMock class: MCK001_LPCRHttpCalloutMockImpl.
*/

global class MCK001_LPCRHttpCalloutMockImpl implements HttpCalloutMock{
    global HTTPResponse respond(HTTPRequest req) {
        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'application/json');
        if(req.getEndpoint().contains('LPCR_API_SaveDocument')){
            System.debug(req.getBody());
            WRP004_APISaveDocument data = (WRP004_APISaveDocument) JSON.deserialize(req.getBody(), WRP004_APISaveDocument.class);
            if(String.isNotBlank(data.DocumentType) && String.isNotBlank(data.OwnerSfId) && String.isNotBlank(data.DocumentStatus) && String.isNotBlank(data.Name) && String.isNotBlank(data.FileType)){
                res.setBody('{"result":"200"}');
                res.setStatusCode(200);
            }else{
                res.setBody('{"result":"503"}');
                res.setStatusCode(503);
            }                        
        }else if(req.getEndpoint().contains('LPCR_API_GetBySfId/')){
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
        }else if(req.getEndpoint().contains('LPCR_API_DocList')){
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
        }else if(req.getEndpoint().contains('DEV_SEND_MAIL')){
            System.debug(req.getBody());
            System.debug(req.getEndpoint());
            res.setBody('{"result":"503"}');
            res.setStatusCode(503);
        }              
        return res;
    }
}