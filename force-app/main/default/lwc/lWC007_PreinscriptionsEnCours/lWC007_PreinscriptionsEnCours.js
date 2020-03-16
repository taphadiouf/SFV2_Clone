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
    @api
    accId;
    columns;
    selectedIds = [];
    @wire(CurrentPageReference) pageRef;
    constructor() {
        super();
        this.columns = [{
                label: '',
                fieldName: '',
                type: ''
            },
            {
                label: 'Statut',
                fieldName: 'statut',
                type: ''
            },
            {
                label: 'Crèche',
                fieldName: 'creche',
                type: ''
            },
            {
                label: 'Nom Enfant',
                fieldName: 'nomEnfant',
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
        console.log('accId : ' + this.accId);
        registerListener(
            "refreshPreInscList",
            () => {
                refreshApex(this.preInscriptionsList);

            },
            this
        );
    }
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

    openSend() {
        let selectedElements = this.template.querySelector('lightning-datatable').getSelectedRows();
        this.selectedIds = [];
        for (let i = 0; i < selectedElements.length; i++) {
            this.selectedIds.push(selectedElements[i].recId);
        }
        this.template.querySelector('c-l-w-c006_-send-mail').openmodal = true;
    }
    changeStatus() {
        let selectedElements = this.template.querySelector('lightning-datatable').getSelectedRows();
        this.selectedIds = [];
        for (let i = 0; i < selectedElements.length; i++) {
            this.selectedIds.push(selectedElements[i].recId);
        }
        this.template.querySelector('c-l-w-c005_-update-status').openmodal = true;
    }

}