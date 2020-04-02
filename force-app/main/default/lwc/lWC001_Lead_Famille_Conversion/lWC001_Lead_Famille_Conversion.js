

/**
 * author Makboub Hanae
 * @ created 17/02/2020
 * @ description Javascript file 
 */



/* eslint-disable no-undef */
/* eslint-disable no-console */
/* eslint-disable no-alert */
import { LightningElement, track, api } from 'lwc';
import  getAccountsByRecordtype from '@salesforce/apex/APC001_LeadFaConverController.getAccountsByRecordtype';
import LPCR_PopConLT from '@salesforce/label/c.LPCR_PopConLT';
import LPCR_PopConLT2 from '@salesforce/label/c.LPCR_PopConLT2';
import LPCR_CrecheWA from '@salesforce/label/c.LPCR_CrecheWA';




export default class LWC001_Lead_Famille_Conversion extends LightningElement {
    label = {
        LPCR_PopConLT,
        LPCR_PopConLT2,
        LPCR_CrecheWA,
    };
    @api recordId = '';
    value;
    options;
    recType = 'Creche';

    @track areDetailsVisible = false; 
    @track DetailsVisible = false;

    constructor(){
        super();
        console.log("constructor2!")
        this.options = [];
    }
    connectedCallback(){

        console.log("ConnectedCallback5!")
        
        
        getAccountsByRecordtype(
            {
                recordtypeId : this.recType
            }
        )
        .then(accounts=>{
            for(let i=0; i< accounts.length; i++){
                this.options.push({
                    label: accounts[i].Name,
                    value: accounts[i].Name
                });
            }
        })
        .catch(err=>{
            console.error(err);
        });
        
    }
    
    handleChange(event) {
        this.areDetailsVisible = event.target.checked;
    }
    handleChange2(event) {
        this.DetailsVisible = event.target.checked;
    }
}
