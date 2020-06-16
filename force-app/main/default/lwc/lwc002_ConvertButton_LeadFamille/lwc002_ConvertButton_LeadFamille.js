/**
 * @ author Makboub Hanae
 * @ created 21/02/2020
 * @ description LWC for the convert button in the lead famille convertion process
 */




/* eslint-disable no-console */
import { LightningElement, api, wire} from 'lwc';
import  convertLeadCtrl from '@salesforce/apex/APC001_LeadFaConverController.convertLeadCtrl';
import { NavigationMixin } from 'lightning/navigation';
import {CurrentPageReference} from 'lightning/navigation';
import {registerListener, unregisterAllListeners} from 'c/pubsub';
import {ShowToastEvent} from 'lightning/platformShowToastEvent';

export default class Lwc002_ConvertButton_LeadFamille extends NavigationMixin(LightningElement) {
    @api recordId;
    contactId;
    enfantsIndexes;
    chosenCrecheId;
    chosenCompteId;
    
    @wire(CurrentPageReference)
    pageRef;

    connectedCallback(){
        registerListener("changedEnfants",this.handleChangedEnfants,this);
        registerListener("chosenCrecheChanged", this.handleChosenCrecheChanged, this);
        registerListener("chosenCompteChanged", this.handleChosenCompteChanged, this);
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
    handleChosenCompteChanged(chosenCompteId){
        this.chosenCompteId = chosenCompteId;
    }
    convertLeadCtrlF() {
        convertLeadCtrl({
            leadId : this.recordId,
            enfantsIndexes : this.enfantsIndexes,
            chosenCrecheId : this.chosenCrecheId,
            chosenCompteId : this.chosenCompteId
        })
        .then(()=>{
            this.redirect();
        })
        .then(()=>{
            this.dispatchEvent(new ShowToastEvent({
                title: "Succès!",
                message: "Le Lead famille est converti avec succès!",
                variant: "success"
            }));
            
        })
        .catch(err=>{
            console.error(err);
                this.dispatchEvent(new ShowToastEvent({
                    title: "Erreur!",
                    message: err.body.message,
                    variant: "error"
                
                }));
         
        });
    }
    redirect(){
        this[NavigationMixin.Navigate]({
            type: 'standard__objectPage',
            attributes: {
                objectApiName: 'Lead',
                actionName: 'home'
            }
        });
    }
}