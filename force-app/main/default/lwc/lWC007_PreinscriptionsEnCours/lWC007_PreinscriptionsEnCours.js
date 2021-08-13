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
                fieldName: 'recId',
                type: 'url',
                typeAttributes: {label: { fieldName: 'name' }, target: '_blank'}
            },
            {
                label: 'Compte Famille',
                fieldName: 'compteFamilleId',
                type: 'url',
                typeAttributes: {label: { fieldName: 'compteFamille' }, target: '_blank'}
            },
            {
                label: 'Compte Crèche',
                fieldName: 'crecheId',
                type: 'url',
                typeAttributes: {label: { fieldName: 'creche' }, target: '_blank'}
            },
            {
                label: 'Contact Parent',
                fieldName: 'contactParentId',
                type: 'url',
                typeAttributes: {label: { fieldName: 'contactParent' }, target: '_blank'}
            },
            {
                label: 'Enfant',
                fieldName: 'contactEnfantId',
                type: 'url',
                typeAttributes: {label: { fieldName: 'nomEnfant' }, target: '_blank'}
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