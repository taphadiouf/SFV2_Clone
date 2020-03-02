/*
 * @ author Ayoub Ouarti
 * @created 28/02/2020
 * @description LWC : The goal of this part is to realize the component which will allow the management of document sending + document consultation of the LPCR document repository
 */


/* eslint-disable no-undef */
/* eslint-disable no-console */
/* eslint-disable no-alert */
import { LightningElement, track, api } from 'lwc';
//import  getAccountsByRecordtype from '@salesforce/apex/APC001_IS241_LeadFaConverController.getAccountsByRecordtype';

const columns = [
    { label: 'Titre', fieldName: 'Titre' },
    { label: 'Type', fieldName: 'type', type: 'url' },
    { label: 'Date de création', fieldName: 'Date de création', type: 'date' }
];

export default class LWC003_RefDoc extends LightningElement {
    @api recordId = '';
    value;

    @track data = [];
    @track columns = columns;


    @track PopUpVisible = false;

    constructor(){
        super();
        console.log("constructor2!")
        //this.options = [];
    }
    async connectedCallback(){

        console.log("connectedCallback !")
      //  const data = await this.fetchDataHelper( 100 );
       // this.data = data;
        /*
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
        */
    }
    handleChangePopUp(event) {
        this.PopUpVisible = !this.PopUpVisible;
    }
 
    

}
