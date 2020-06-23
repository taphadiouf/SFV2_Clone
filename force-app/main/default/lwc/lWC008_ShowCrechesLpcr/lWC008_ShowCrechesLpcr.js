import { LightningElement, api, track } from 'lwc';
import leaflet from '@salesforce/resourceUrl/Leaflet';
import redmarker from '@salesforce/resourceUrl/redmarker';
import getLocations from '@salesforce/apex/APC007_ShowCrechesLpcrController.getLocations';

export default class LWC008_ShowCrechesLpcr extends LightningElement {
    @api recordId;
    @api modeAffich;
    showMap = false;
    @track locations;
    @track center;
    icon;
    initiated = false;
    constructor(){
        super();
        this.icon = redmarker;
    }
    connectedCallback() {
        getLocations({ currentId: this.recordId, modeAffich: this.modeAffich })
            .then(result => {
                console.log(result);
                let jsonLocationsConfig = JSON.parse(result);
                this.locations = jsonLocationsConfig.locations;
                this.center = jsonLocationsConfig.center;
                console.log('-->locations', this.locations);
                this.showMap = true;
            })
            .catch(error => {
                this.error = error;
            });
    }
}
