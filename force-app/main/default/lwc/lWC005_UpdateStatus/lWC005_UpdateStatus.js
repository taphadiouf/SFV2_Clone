import {
    LightningElement,
    api,
    wire
} from 'lwc';
import getPicklistvalues from '@salesforce/apex/LWC003_UpdateStatusController.getPicklistvalues';
import updateLstPreinscription from '@salesforce/apex/LWC003_UpdateStatusController.updateLstPreinscription';
import {
    NavigationMixin
} from 'lightning/navigation';
import {
    ShowToastEvent
} from 'lightning/platformShowToastEvent';
import {
    fireEvent
} from 'c/pubsub';
import {
    CurrentPageReference
} from 'lightning/navigation';



export default class LWC005_UpdateStatus extends NavigationMixin(LightningElement) {
    @api openmodal = false;
    value;
    options;
    @api
    preinscriptionIds
    @wire(CurrentPageReference) pageRef;

    @wire(getPicklistvalues, {})
    getPicklistvaluesF({
        error,
        data
    }) {
        if (data) {
            this.options = [];
            for (let i = 0; i < data.length; i++) {
                this.options.push({
                    label: data[i],
                    value: data[i]
                });
            }
        }
        if (error) {
            console.error(error);
        }

    }
    handleValueChange(event) {
        this.value = event.detail.value;
    }
    updatePreinscription() {
        updateLstPreinscription({
                statut: this.value,
                preinscriptionIds: this.preinscriptionIds
            })
            .then(() => {
                this.dispatchEvent(new ShowToastEvent({
                    title: "Succès!",
                    message: "Les statuts sont mis à jour avec succès!",
                    variant: "success"
                }));
                //this.redirect();
            })
            .then(() => {
                this.openmodal = false;
                fireEvent(this.pageRef, "refreshPreInscList", null);
            })
            .catch(err => {
                console.error(err);
            });
    }
    closeModal() {
        this.openmodal = false;
    }
    /*
    redirect() {
        this[NavigationMixin.Navigate]({
            type: 'standard__objectPage',
            attributes: {
                objectApiName: 'LPCR_Preinscription__c',
                actionName: 'list'
            },
            state: {
                filterName: 'Recent'
            }

        });
    }
    */
}