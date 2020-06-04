import { LightningElement, api, wire } from 'lwc';
import getAccounts from '@salesforce/apex/APC007_ShowCrechesLpcrController.getAccounts';

export default class LWC008_ShowCrechesLpcr extends LightningElement {
    @api recordId;
    @api modeAffich;
    accounts;
    center = {
        Street: "Rue Barathon",
        PostalCode: "20250"
    };
    error;
    showFooter = true ;
    /*
    @wire(getAccounts, {currentId : "$recordId", modeAffich: "$modeAffich"})
     wiredAccountsF({error,data}) {
         if (data) {f
             this.accounts = data;
             console.log(data);
             console.log(JSON.stringify(data, null, '\t'));
         } else if (error) {
             console.log(error);
             this.error = error;
         }
     }*/
     connectedCallback(){
         console.log('gello');
         console.log('recordId :' + this.recordId);
         console.log('modAffich : ' + this.modeAffich);
        getAccounts({currentId : this.recordId, modeAffich: this.modeAffich})
        .then(res=>{
            let jsonResult = JSON.parse(res);
            this.accounts = jsonResult.mapMarkers;
            this.center = jsonResult.center;
            console.log('hii');
            console.log(this.accounts);
            console.log(this.center);
        })
        .catch(err=>{
            console.log(err);
        });
     }
}