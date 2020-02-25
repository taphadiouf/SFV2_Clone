

/**
 * author Makboub Hanae
 * @ created 17/02/2020
 * @ description Javascript file 
 */



/* eslint-disable no-undef */
/* eslint-disable no-console */
/* eslint-disable no-alert */
import { LightningElement, track, api } from 'lwc';
import  getAccountsByRecordtype from '@salesforce/apex/APC001_IS_241Controller.getAccountsByRecordtype';



export default class LWC001_SF_LEAD_COMER_36 extends LightningElement {
    @api recordId = '';
    value;
    options;
    recType = 'Crèche';

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
