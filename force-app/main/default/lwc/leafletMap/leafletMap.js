import { LightningElement, api } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { loadScript, loadStyle } from 'lightning/platformResourceLoader';
import leaflet from '@salesforce/resourceUrl/Leaflet';

export default class LeafletMap extends LightningElement {
    @api markers;
    @api center;
    @api zoom;
    @api icon;
    @api centerIcon;
    
    renderedCallback() {
        Promise.all([
            loadScript(this, leaflet + '/leaflet.js'),
            loadStyle(this, leaflet + '/leaflet.css')
        ])
            .then(() => {
                this.initializeleaflet();
            })
            .catch(error => {
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Error loading D3',
                        message: error.message,
                        variant: 'error'
                    })
                );
            });
    }

    initializeleaflet() {

        let options;
        if (this.icon) {
            //custom marker
            let customMarker = L.icon({
                iconUrl: this.icon,
                iconSize: [40, 45], // size of the icon
                shadowSize: [50, 64], // size of the shadow
                shadowAnchor: [4, 62],  // the same for the shadow
            });
            options = { icon: customMarker };
        }
        let centerOptions;
        if (this.centerIcon) {
            //custom marker
            let customMarker = L.icon({
                iconUrl: this.centerIcon,
                iconSize: [40, 45], // size of the icon
                shadowSize: [50, 64], // size of the shadow
                shadowAnchor: [4, 62],  // the same for the shadow
            });
            centerOptions = { icon: customMarker };
        }

        let markerLayers = [];
        for(let i in this.markers){
            let marker = this.markers[i];
            if(marker.isCenter === true){
                markerLayers.push(L.marker([marker.latitude, marker.longitude], centerOptions).bindPopup(marker.content));
            }
            else{
                markerLayers.push(L.marker([marker.latitude, marker.longitude], options).bindPopup(marker.content));
            }
        }
        var areas = L.layerGroup(markerLayers);

        var baseLayer = L.tileLayer(
            'http://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png', {
            attribution: '&copy; ' + ' Contributors',
            maxZoom: 18,
        });

        const mapRoot = this.template.querySelector(".map-root");
        var map = L.map(mapRoot, {
            center: [this.center.latitude, this.center.longitude],
            zoom: this.zoom || 16,
            layers: [baseLayer, areas]
        });

    }
}