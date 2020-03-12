/* eslint-disable no-dupe-class-members */
import { LightningElement, api, wire } from 'lwc';
import getPreInscriptionsByAcc from '@salesforce/apex/APC005_PreinscriptionsEnCoursController.getPreInscriptionsByAcc';

export default class LWC007_PreinscriptionsEnCours extends LightningElement {
    @api
    accId;
    preInscriptionsList;
    columns;
    selectedIds =[];
    constructor(){
        super();
        this.columns = [
            {label : '', fieldName: '', type : ''},
            {label : 'Statut', fieldName: 'statut', type : ''},
            {label : 'Crèche', fieldName: 'creche', type : ''},
            {label : 'Nom Enfant', fieldName: 'nomEnfant', type : ''},
            {label : 'Date Entrée', fieldName: 'dateEntree', type : ''}
        ];
    }
    connectedCallback(){
        console.log('accId : ' + this.accId);
    }

    
    @wire(getPreInscriptionsByAcc, {accId : '$accId'})
    getPreInscriptionsByAccF({error, data}){
        debugger;
        console.log('hello from wired method');
        if(data){
            console.log("data");
            console.log(data);
            this.preInscriptionsList = JSON.parse(data);
        }
        if(error){
            console.error(error);
        }
    }
    
    openSend(){
        console.log('clickeeed open send mail');
        let selectedElements = this.template.querySelector('lightning-datatable').getSelectedRows();
        this.selectedIds = [];
        for(let i=0; i< selectedElements.length; i++){
            this.selectedIds.push(selectedElements[i].recId);
        }
        this.template.querySelector('c-l-w-c006_-send-mail').openmodal = true;
        //this.openSendMail = true;
    }
    changeStatus(){
        console.log('clickeeed change status');
        let selectedElements = this.template.querySelector('lightning-datatable').getSelectedRows();
        this.selectedIds = [];
        for(let i=0; i< selectedElements.length; i++){
            this.selectedIds.push(selectedElements[i].recId);
        }
        this.template.querySelector('c-l-w-c005_-update-status').openmodal = true;
        //this.openUpdateStatus = true;
    }

}