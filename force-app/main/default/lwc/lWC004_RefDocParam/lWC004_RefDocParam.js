/*
 * @ author Ayoub Ouarti
 * @created 28/02/2020
 * @description LWC : The goal of this part is to realize the component which will allow the management of document sending + document consultation of the LPCR document repository
 */


/* eslint-disable no-undef */
/* eslint-disable no-console */
/* eslint-disable no-alert */
import { LightningElement, api,track } from "lwc";

export default class Lwc004_RefDocParam extends LightningElement {
 
  @api recordId;
@track skip="Annuler";

@track submit="Envoyer";
@track uploadFile='Charger un nouveau fichier';
@track type='Type';
@track attachment='Fichier';
@track uploadFiles='Upload Files';
@track orDropFiles='or Drop Files';

  handlePopup() {
    this.template.querySelector("section").classList.remove("slds-hide");
    this.template
      .querySelector("div.modalBackdrops")
      .classList.remove("slds-hide");
  }

  handleSkip() {
    this.template.querySelector("section").classList.add("slds-hide");
    this.template
      .querySelector("div.modalBackdrops")
      .classList.add("slds-hide");
  }



get acceptedFormats() {
    return ['.pdf', '.png'];
}

handleUploadFinished(event) {
    // Get the list of uploaded files
    const uploadedFiles = event.detail.files;
    alert("No. of files uploaded : " + uploadedFiles.length);
}

}