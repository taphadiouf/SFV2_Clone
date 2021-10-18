

/**
 * author Makboub Hanae
 * @ created 17/02/2020
 * @ description Javascript file 
 */



/* eslint-disable no-undef */
/* eslint-disable no-console */
/* eslint-disable no-alert */
import { LightningElement, api, wire } from 'lwc';
import  getRelatedCreches from '@salesforce/apex/APC001_LeadFaConverController.getRelatedCreches';
import  getAccountsByRecordtypeName from '@salesforce/apex/APC001_LeadFaConverController.getAccountsByRecordtypeName';
import  getEnfants from '@salesforce/apex/APC001_LeadFaConverController.getEnfants';
import LPCR_PopConLT from '@salesforce/label/c.LPCR_PopConLT';
import LPCR_PopConLT2 from '@salesforce/label/c.LPCR_PopConLT2';
import LPCR_CrecheWA from '@salesforce/label/c.LPCR_CrecheWA';
import LPCR_CompteWA from '@salesforce/label/c.LPCR_CompteWA';
import LPCR_EnfantsWA from '@salesforce/label/c.LPCR_EnfantsWA';

import {fireEvent} from 'c/pubsub';
import {CurrentPageReference} from 'lightning/navigation';
export default class LWC001_Lead_Famille_Conversion extends LightningElement {
    label; 
    @api recordId;
    accEntrepriseRT;
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
        this.label = {
            LPCR_PopConLT,
            LPCR_PopConLT2,
            LPCR_CrecheWA,
            LPCR_CompteWA,
            LPCR_EnfantsWA
        };
        this.accEntrepriseRT = 'Entreprise';
        this.showCreches = false;
        this.showComptes = false;
        this.creches = [];
        this.comptes = [];
        this.enfants = [];
        this.enfantsIndexes = [];
    }
    @wire(CurrentPageReference)
    pageRef;
    
    
    getAccountsByRecordtypeNameF() {
        getAccountsByRecordtypeName({
            recordTypeName: this.accEntrepriseRT,
            leadId : this.recordId
        })
        
        .then((data)=>{
            this.comptes = [];
            for(let i=0; i< data.length; i++){
                this.comptes.push({
                    label: data[i].Id,
                    value: data[i].Name
                });
            }
        })
        .catch(err=>{
            console.error(err);
        });
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
    async connectedCallback(){
        console.log("ConnectedCallback8");
        this.getAccountsByRecordtypeNameF();
        await this.getRelatedCrechesF();
    }

    getRelatedCrechesF() {
        getRelatedCreches({
            leadId : this.recordId,
        })
        
        .then((data)=>{
            this.creches = [];
            for(let i = 0; i < data.length ; i++){
                this.creches.push({
                    label : data[i].Id,
                    value : data[i].Name
                });
            }
        })
        .catch(err=>{
            console.error(err);
        });
    }
    get showEnfants(){
        return (this.enfants.length > 0);
    }
    get getEnfantsOptions(){
        let enfantsOptions = [];
        for(let i = 0; i < this.enfants.length; i++){
            enfantsOptions.push({
                label : this.enfants[i].label,
                value : ''+this.enfants[i].num
            });
        }
        return enfantsOptions;
    }
    handleContrDaccCheckbox(event) {
        // IS 2565 send value to aura component parent
        const value = event.target.checked;
        this.showCreches = value;
        const valueChangeEvent = new CustomEvent("valuechange", {
            detail: { value }
        });
        this.dispatchEvent(valueChangeEvent);
    }
    handleEnfantCheckbox(event){
        this.enfantsIndexes = event.detail.value;
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
        this.chosenCompteId = event.target.value.Id;
        fireEvent(this.pageRef, "chosenCompteChanged", this.chosenCompteId);
    }
}