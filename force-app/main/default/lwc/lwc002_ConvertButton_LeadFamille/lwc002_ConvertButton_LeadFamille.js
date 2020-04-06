/**
 * @ author Makboub Hanae
 * @ created 21/02/2020
 * @ description LWC for the convert button in the lead famille convertion process
 */




/* eslint-disable no-console */
import { LightningElement, api, wire} from 'lwc';
import  convertLead from '@salesforce/apex/APC001_LeadFaConverController.convertLead';
import { NavigationMixin } from 'lightning/navigation';
import {CurrentPageReference} from 'lightning/navigation';
import {registerListener, unregisterAllListeners} from 'c/pubsub';

export default class Lwc002_ConvertButton_LeadFamille extends NavigationMixin(LightningElement) {
    @api recordId;
    contactId;
    enfantsIndexes;
    chosenCrecheId;
    @wire(CurrentPageReference)
    pageRef;
    connectedCallback(){
        registerListener("changedEnfants",this.handleChangedEnfants,this);
        registerListener("chosenCrecheChanged", this.handleChosenCrecheChanged, this);
    }
    disconnectedCallback(){
        unregisterAllListeners(this);
    }
    handleChangedEnfants(enfantsIndexes){
        this.enfantsIndexes  = enfantsIndexes;
    }
    handleChosenCrecheChanged(chosenCrecheId){
        this.chosenCrecheId = chosenCrecheId;
    }
    convertLeadF() {
        console.log("recordId : " + this.recordId);
        convertLead({
            leadId : this.recordId,
            enfantsIndexes : this.enfantsIndexes,
            chosenCrecheId : this.chosenCrecheId
        })
        .then((result)=>{
            console.log('saveMethod: contactId:',result);
            this.contactId = result;
            console.log("thecontactId: "+result);
            this.redirect();
           
        })
        .catch(err=>{
            console.error(err);
        });
        
    }
    redirect(){
        this[NavigationMixin.Navigate]({
            type: 'standard__recordPage',
            attributes: {
                recordId: this.contactId ,
                objectApiName: 'Contact',
                actionName: 'view'
            }
        });
    }
}