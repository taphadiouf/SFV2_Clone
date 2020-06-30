/**
* @author Saurabh
* @created 30/06/2020
* @description Trigger actions on Attachment Object
*/
public with sharing class TM015_AttachmentTrigger extends TM000_TriggerHandler{
	private Map<Id, Attachment> newAttachmentMap;
    private Map<Id, Attachment> oldAttachmentMap;
    private List<Attachment> newAttachmentList;
    
    public TM015_AttachmentTrigger() {
        this.newAttachmentMap = (Map<Id, Attachment>) Trigger.newMap;
        this.oldAttachmentMap = (Map<Id, Attachment>) Trigger.oldMap;
        this.newAttachmentList = (List<Attachment>) Trigger.new;
    }
    
    protected override void afterInsert() {
        if (!FeatureManagement.checkPermission('LPCR_ByPass')){
            SM018_AttachmentService.sendLPCRDocumentByCallout(newAttachmentList);
        }
    }
}