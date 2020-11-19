import { LightningElement , api } from 'lwc';
import  getContractDetails from '@salesforce/apex/APC010_AmendLexContractController.getContractDetails';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

export default class LWC011_AmendLexContract extends LightningElement {

    @api recordId;

    connectedCallback(){
        this.getContractDetailsF();
    }

    getContractDetailsF() {
        getContractDetails({
            contractId : this.recordId
        })
        .then((data)=>{
            //If the response is null it means the start date is defined. we redirect the user.
            if(data == null){
                window.open('/apex/sbqq__AmendContract?id=' + this.recordId,'_blank');
                this.closeQuickAction();
            }else{
                this.dispatchEvent(new ShowToastEvent({
                    title: "Erreur!",
                    message: data,
                    variant: "error"
                }));
                this.closeQuickAction();
                
            }
            console.log("launched the lwc and apc010. The response is : " + data );
        })
        .catch(err=>{
            console.error('getting error from apc010 : ' + err);
            this.dispatchEvent(new ShowToastEvent({
                title: "System Error!",
                message: err.body.message,
                variant: "error"
            }));
        });
    }

    closeQuickAction() {
        const closeQA = new CustomEvent('close');
        this.dispatchEvent(closeQA);
    }

}