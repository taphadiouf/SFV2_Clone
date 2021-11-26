import { LightningElement , api } from 'lwc';
import  GenererAvoir from '@salesforce/apex/APC011_GenererAvoir.GenererAvoir';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

export default class LWC012_GenererAvoir extends LightningElement {
    @api recordId;
    @api isLoaded = false;

    connectedCallback(){
        console.log('this is get connected callack ');
        this.GenererAvoirF();
    }

    GenererAvoirF() {
        console.log('this is get con methis ');
        GenererAvoir({
            AccountID : this.recordId
        })
        .then((data)=>{
            //If the response is null it means the start date is defined. we redirect the user.
            if(data == null){
                this.dispatchEvent(new ShowToastEvent({
                    title: "Suceesfully generated",
                    message: data,
                    variant: "success"
                }));
                this.isLoaded = !this.isLoaded;
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