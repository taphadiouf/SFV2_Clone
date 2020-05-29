import { LightningElement, wire } from 'lwc';
import getAccount from '@salesforce/apex/APC007_ShowCrechesLpcrController.getAccounts';

export default class LWC008_ShowCrechesLpcr extends LightningElement {
    modeAffich;
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