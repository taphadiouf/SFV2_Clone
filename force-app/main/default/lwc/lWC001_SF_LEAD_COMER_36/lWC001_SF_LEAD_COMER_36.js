import { LightningElement, track } from 'lwc';

export default class LWC001_SF_LEAD_COMER_36 extends LightningElement {
    @track openmodel = false;
    @track areDetailsVisible = false; 
    @track DetailsVisible = false;

    openmodal() {
        this.openmodel = true
    }
    closeModal() {
        this.openmodel = false
    } 
    saveMethod() {
        alert('save method invoked');
        this.closeModal();
    }
    handleChange(event) {
        this.areDetailsVisible = event.target.checked;
    }
    handleChange2(event) {
        this.DetailsVisible = event.target.checked;
    }
}
