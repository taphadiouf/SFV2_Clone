/**
 * @ author Makboub Hanae
 * @ created 21/02/2020
 * @ description LWC for the convert button in the lead famille convertion process
 */




/* eslint-disable no-console */
import { LightningElement, api,track } from 'lwc';
import  createAccountFromLead from '@salesforce/apex/APC001_LeadFaConverController.createAccountFromLead';
import { NavigationMixin } from 'lightning/navigation';
export default class Lwc002_ConvertButton_LeadFamille extends NavigationMixin(LightningElement) {
    @api recordId = '';
    @track contactId;
    saveMethod() {
        console.log("recordId : " + this.recordId);
        createAccountFromLead({
            leadId : this.recordId,
        })
        .then((result)=>{
            console.log('saveMethod: contactId:',result);
            this.contactId = result;
            console.log("thecontactId: "+result);
            this.redirect();
           
        })
        .catch(err=>{
            console.error(err);
        });
        
    }
    redirect(){
        this[NavigationMixin.Navigate]({
            type: 'standard__recordPage',
            attributes: {
                recordId: this.contactId ,
                objectApiName: 'Contact',
                actionName: 'view'
            }
        });
    }
}