

/**
 * author Makboub Hanae
 * @ created 17/02/2020
 * @ description Javascript file 
 */



/* eslint-disable no-undef */
/* eslint-disable no-console */
/* eslint-disable no-alert */
import { LightningElement, api, wire } from 'lwc';
import  getAccountsByRecordtype from '@salesforce/apex/APC001_LeadFaConverController.getAccountsByRecordtype';
import  getRelatedCreches from '@salesforce/apex/APC001_LeadFaConverController.getRelatedCreches';
import  getEnfants from '@salesforce/apex/APC001_LeadFaConverController.getEnfants';
import LPCR_PopConLT from '@salesforce/label/c.LPCR_PopConLT';
import LPCR_PopConLT2 from '@salesforce/label/c.LPCR_PopConLT2';
import LPCR_CrecheWA from '@salesforce/label/c.LPCR_CrecheWA';
import LPCR_CompteWA from '@salesforce/label/c.LPCR_CompteWA';
import {fireEvent} from 'c/pubsub';
import {CurrentPageReference} from 'lightning/navigation';
export default class LWC001_Lead_Famille_Conversion extends LightningElement {
    label; 
    @api recordId;
    value;
    options;
    recType;
    chosenCrecheId;
    chosenCompteId;
    showCreches;
    showComptes;
    creches;
    comptes;
    enfants;
    enfantsIndexes;
    
    constructor(){
        super();
        console.log("constructor3!")
        this.options = [];
        this.label = {
            LPCR_PopConLT,
            LPCR_PopConLT2,
            LPCR_CrecheWA,
            LPCR_CompteWA
        };
        this.recType = 'Creche';
        this.showCreches = false;
        this.showComptes = false;
        this.creches = [];
        this.enfants = [];
    }
    @wire(CurrentPageReference)
    pageRef;
    /*
    @wire(getAccountsByRecordtype, {recordTypeName : "$recType"})
    getAccountsByRecordtypeF({error, data}){
        if(data){
            for(let i=0; i< data.length; i++){
                this.creches.push({
                    label: data[i].Name,
                    value: data[i].Name
                });
            }
        }
        else if(error){
            console.error(error);
        }
    }*/
    @wire(getRelatedCreches, {leadId : "$recordId"})
    getRelatedCrechesF({error, data}){
        if(data){
            this.creches = [];
            for(let i = 0; i < data.length ; i++){
                this.creches.push({
                    label : data[i].Name,
                    value : data[i].Id
                });
            }
        }
        if(error){
            console.error(error);
        }
    }

    @wire(getEnfants, {leadId : "$recordId"})
    getEnfantsF({error, data}){
        if(data){
            this.enfants = JSON.parse(data);
        }
        else if(error){
            console.error(error);
        }
    }
    connectedCallback(){
        console.log("ConnectedCallback18");
    }
    get showEnfants(){
        return this.enfants.length > 1;
    }
    handleContrDaccCheckbox(event) {
        this.showCreches = event.target.checked;
    }
    handleEnfantCheckbox(event){
        this.enfantsIndexes[event.target.num] = event.target.checked;
        fireEvent(this.pageRef, "changedEnfants", this.enfantsIndexes);
    }
    handleCrecheChosen(event){
        this.chosenCrecheId = event.target.value;
        fireEvent(this.pageRef, "chosenCrecheChanged", this.chosenCrecheId);
    }
    handleSponsCheckbox(event) {
        this.showComptes = event.target.checked;
    }
    handleCompteChosen(event){

    }
}
