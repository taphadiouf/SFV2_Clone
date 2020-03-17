import { LightningElement, wire, api,track } from 'lwc';
import  getPicklistvalues from '@salesforce/apex/LWC003_UpdateStatusController.getPicklistvalues';
import  updateLstPreinscription from '@salesforce/apex/LWC003_UpdateStatusController.updateLstPreinscription';
import { NavigationMixin } from 'lightning/navigation';



export default class LWC005_UpdateStatus extends NavigationMixin(LightningElement) {
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
        updateLstPreinscription({
            statut :this.value
        })
       
        .then((result)=>{
            this.lstPreinscription = result;
            console.log('Laliste modifiée '+result);
            this.redirect();
        })
        .catch(err=>{
            console.error(err);
        });
    }
    redirect(){
        this[NavigationMixin.Navigate]({
            type: 'standard__objectPage',
            attributes: {
                objectApiName: 'LPCR_Preinscription__c',
                actionName: 'list'
            },
            state: {
                filterName: 'Recent' 
            }
            
        });
    }
}