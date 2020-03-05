import { LightningElement, wire, api,track } from 'lwc';
import  getPicklistvalues from '@salesforce/apex/LWC003_LWC_UpdateStatusController.getPicklistvalues';


export default class LWC005_LWC_UpdateStatus extends LightningElement {
    @track openmodel = false;
    value;
    options;
    


    constructor(){
        super();
        console.log("constructor2!")
        this.options = [];
    }
    



    connectedCallback(){

        console.log("ConnectedCallback5!")
        
        
        getPicklistvalues()
        .then(options=>{
            for(let i=0; i< options.length; i++){
                this.options.push({
                    label: options[i],
                    value: options[i]
                });
            }
            console.log(options);
        })
        .catch(err=>{
            console.error(err);
        });
        
    }







    openmodal() {
        this.openmodel = true
    }
    closeModal() {
        this.openmodel = false
    } 
    updateMethod() {
        alert('save method invoked');
        this.closeModal();
    }
}