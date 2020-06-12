import { LightningElement, api, wire } from 'lwc';
import getAccounts from '@salesforce/apex/APC007_ShowCrechesLpcrController.getAccounts';

export default class LWC008_ShowCrechesLpcr extends LightningElement {
    @api recordId;
    @api modeAffich;
    accounts;
    center;
    zoomLevel = 12;
    showFooter = false;
    listView = 'hidden';
     connectedCallback(){
        getAccounts({currentId : this.recordId, modeAffich: this.modeAffich})
        .then(res=>{
            let jsonResult = JSON.parse(res);
            this.accounts = jsonResult.mapMarkers;
            this.center = jsonResult.center;
        })
        .catch(err=>{
            console.log(err);
        });
     }
}