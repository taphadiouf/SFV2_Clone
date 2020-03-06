import { LightningElement, wire, api,track } from 'lwc';
import  getPicklistvalues from '@salesforce/apex/LWC003_LWC_UpdateStatusController.getPicklistvalues';



export default class LWC005_LWC_UpdateStatus extends LightningElement {
    @track openmodel = false;
    value;
    options;

    constructor(){
        super();
        this.options = [];
    }
    



    connectedCallback(event){

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
            this.value = event.detail.value;
            console.log(this.value);
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
    updatePreinscription() {
        console.log('Laliste modifiée');
        updateLstPreinscription({
            statut :this.value
        })
        console.log('test')
        console.log('hanae'+this.statut)
        .then((result)=>{
            this.lstPreinscription = result;
            console.log('Laliste modifiée'+result);
        })
        .catch(err=>{
            console.error(err);
        });
    }
}