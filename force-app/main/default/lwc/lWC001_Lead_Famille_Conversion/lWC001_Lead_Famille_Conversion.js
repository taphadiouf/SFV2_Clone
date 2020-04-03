

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
import  getEnfants from '@salesforce/apex/APC001_LeadFaConverController.getEnfants';
import LPCR_PopConLT from '@salesforce/label/c.LPCR_PopConLT';
import LPCR_PopConLT2 from '@salesforce/label/c.LPCR_PopConLT2';
import LPCR_CrecheWA from '@salesforce/label/c.LPCR_CrecheWA';
import {fireEvent} from 'c/pubsub';
import {CurrentPageReference} from 'lightning/navigation';
export default class LWC001_Lead_Famille_Conversion extends LightningElement {
    label; 
    @api recordId;
    value;
    options;
    recType;
    creche1Value;
    creche2Value;
    showCreches1;
    showCreches2;
    creches;
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
        };
        this.recType = 'Creche';
        this.showCreches1 = false;
        this.showCreches2 = false;
        this.creches = [];
        this.enfants = [];
    }
    @wire(CurrentPageReference)
    pageRef;
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
        console.log("ConnectedCallback14!");
    }
    get showEnfants(){
        return this.enfants.length > 1;
    }
    handleEnfantCheckbox(event){
        this.enfantsIndexes[event.target.num] = event.target.checked;
        fireEvent(this.pageRef, "changedEnfants", this.enfantsIndexes);

    }
    handleContrDaccCheckbox(event) {
        this.showCreches1 = event.target.checked;
    }
    handleSponsCheckbox(event) {
        this.showCreches2 = event.target.checked;
    }
}
