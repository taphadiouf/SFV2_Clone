/* eslint-disable no-dupe-class-members */
import {
    LightningElement,
    api,
    wire
} from 'lwc';
import getPreInscriptionsByAcc from '@salesforce/apex/APC005_PreinscriptionsEnCoursCtrl.getPreInscriptionsByAcc';
import {
    refreshApex
} from '@salesforce/apex';
import {
    registerListener
} from 'c/pubsub';
import {
    CurrentPageReference
} from 'lightning/navigation';

export default class LWC007_PreinscriptionsEnCours extends LightningElement {
    @api accId;
    columns;
    selectedIds = [];
    @wire(CurrentPageReference) pageRef;
    @wire(getPreInscriptionsByAcc, {
        accId: '$accId'
    })
    preInscriptionsList;
    get getPreInscriptionsByAcc() {
        if (this.preInscriptionsList.data) {
            return JSON.parse(this.preInscriptionsList.data);
        }
        const l = [];
        return l;
    }
    constructor() {
        super();
        this.columns = [{
                label: '',
                fieldName: '',
                type: ''
            },
            {
                label: 'Préinscription',
                fieldName: 'name',
                type: ''
            },
            {
                label: 'Compte Famille',
                fieldName: 'compteFamille',
                type: ''
            },
            {
                label: 'Compte Crèche',
                fieldName: 'creche',
                type: ''
            },
            {
                label: 'Contact Parent',
                fieldName: 'contactParent',
                type: ''
            },
            {
                label: 'Enfant',
                fieldName: 'nomEnfant',
                type: ''
            },
            {
                label: 'Statut',
                fieldName: 'statut',
                type: ''
            },
            {
                label: 'Date Entrée',
                fieldName: 'dateEntree',
                type: ''
            }
        ];
    }
    connectedCallback() {
        registerListener(
            "refreshPreInscList",
            () => {
                console.log('refresh called!!');
                refreshApex(this.preInscriptionsList);
            },
            this
        );
    }
    openSend() {
        let selectedElements = this.template.querySelector('lightning-datatable').getSelectedRows();
        this.selectedIds = [];
        if(selectedElements.length > 0){
            for (let i = 0; i < selectedElements.length; i++) {
                this.selectedIds.push(selectedElements[i].recId);
            }
            this.template.querySelector('c-l-w-c006_-send-mail').openmodal = true;
        }
        
    }
    changeStatus() {
        let selectedElements = this.template.querySelector('lightning-datatable').getSelectedRows();
        this.selectedIds = [];
        if(selectedElements.length > 0){
            for (let i = 0; i < selectedElements.length; i++) {
                this.selectedIds.push(selectedElements[i].recId);
            }
            this.template.querySelector('c-l-w-c005_-update-status').openmodal = true;
        }
       
    }

}