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
            if(String.isNotBlank(data.doc_type) && String.isNotBlank(data.doc_owner_sf_id) && String.isNotBlank(data.doc_status) && String.isNotBlank(data.doc_name) && String.isNotBlank(data.doc_file_type)){
                res.setBody('{"result":"200"}');
                res.setStatusCode(200);
            }else{
                res.setBody('{"result":"400"}');
                res.setStatusCode(400);
            }                        
        }else if(req.getEndpoint().contains('LPCR_API_GetBySfId/')){
            System.debug(req.getBody());
            System.debug(req.getEndpoint());
            WRP005_APIGetBySfId data = (WRP005_APIGetBySfId) JSON.deserialize(req.getBody(), WRP005_APIGetBySfId.class);
            if(String.isNotBlank(data.Sfid)){
                res.setBody('{"result":"200"}');
                res.setStatusCode(200);
            }else{
                res.setBody('{"result":"400"}');
                res.setStatusCode(400);
            } 
        }else if(req.getEndpoint().contains('LPCR_API_DocList')){
            System.debug(req.getBody());
            System.debug(req.getEndpoint());
            SM019_DocumentList_Callout.DocumentListStructureWrapper data = (SM019_DocumentList_Callout.DocumentListStructureWrapper) JSON.deserialize(req.getBody(), SM019_DocumentList_Callout.DocumentListStructureWrapper.class);
            if(String.isNotBlank(data.ownerid)){
                res.setBody('{"result":"200"},[{"id":"000000000000000","Facture"}]');
                res.setStatusCode(200);
            }else{
                res.setBody('{"result":"400"}');
                res.setStatusCode(400);
            }
        }              
        return res;
    }
}