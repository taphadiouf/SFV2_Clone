

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
import  getCurrentLead from '@salesforce/apex/APC001_LeadFaConverController.getCurrentLead';
import LPCR_PopConLT from '@salesforce/label/c.LPCR_PopConLT';
import LPCR_PopConLT2 from '@salesforce/label/c.LPCR_PopConLT2';
import LPCR_CrecheWA from '@salesforce/label/c.LPCR_CrecheWA';




export default class LWC001_Lead_Famille_Conversion extends LightningElement {
    label; 
    @api recordId = '';
    value;
    options;
    recType;
    creche1Value;
    creche2Value;
    showCreches1;
    showCreches2;
    creches;
    enfants;
    constructor(){
        super();
        console.log("constructor2!")
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
        this.enfants = {};
    }
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
    @wire(getCurrentLead, {leadId : "$recordId"})
    getCurrentLeadF({error, data}){
        if(data){
            console.log(data);
            let tempNomField;
            let tempPrenomField;
            for(let i = 1; i<4 ; i++){
                tempNomField = "LPCR_NomEnfant" + i + "__c";
                tempPrenomField = "LPCR_PrenomEnfant" + i + "__c";
                if(data[tempNomField] && data[tempPrenomField]){
                    this.enfants["enfant" + i] = {
                        nom : data[tempNomField],
                        prenom : data[tempPrenomField]
                    };
                }
            }
        }
        else if(error){
            console.error(error);
        }
    }

    connectedCallback(){
        console.log("ConnectedCallback11!");
    }
    get showEnfants(){
        let c = 0;
        for(let i = 1; i < 4; i++){
            if(this.enfants["enfant" + i] != null){
                c++;
            }
        }
        return c > 1;
    }
    handleContrDaccCheckbox(event) {
        this.showCreches1 = event.target.checked;
    }
    handleSponsCheckbox(event) {
        this.showCreches2 = event.target.checked;
    }
}
