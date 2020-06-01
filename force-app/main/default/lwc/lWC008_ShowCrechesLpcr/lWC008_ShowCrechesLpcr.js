import { LightningElement, api, wire } from 'lwc';
import getAccounts from '@salesforce/apex/APC007_ShowCrechesLpcrController.getAccounts';

export default class LWC008_ShowCrechesLpcr extends LightningElement {
    @api modeAffich;
    accounts;
    error;
    showFooter = true ;
     @wire(getAccounts)
     wiredAccountsF({error,data}) {
         if (data) {
             this.accounts = data;
             console.log(data);
             console.log(JSON.stringify(data, null, '\t'));
         } else if (error) {
             console.log(error);
             this.error = error;
         }
     }
}