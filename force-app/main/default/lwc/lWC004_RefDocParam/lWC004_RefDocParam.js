/*
 * @ author Ayoub Ouarti
 * @created 28/02/2020
 * @description LWC : The goal of this part is to realize the component which will allow the management of document sending + document consultation of the LPCR document repository
 */


/* eslint-disable no-undef */
/* eslint-disable no-console */
/* eslint-disable no-alert */
import { LightningElement, api,track } from "lwc";
import save from '@salesforce/apex/APC002_AttachmentController.save';
import {ShowToastEvent} from 'lightning/platformShowToastEvent';
export default class Lwc004_RefDocParam extends LightningElement {
 
  @api recordId;
@track skip="Annuler";
@track submit="Envoyer";
@track uploadFile='Charger un nouveau fichier';
@track type='Type';
@track attachment='Fichier';
@track uploadFiles='Upload Files';
@track orDropFiles='or Drop Files';
@track uploadFileHeader='Charger un fichier';
@track picklistTypeValue = [{ label: 'PDF', value: 'PDF', selected: true },{ label: 'DOC', value: 'DOC' }];
@track data  ={type:'',file  :File};
    @track fileName = '';
    @track UploadFile = 'Upload File';
    @track showLoadingSpinner = false;
    @track isTrue = false;
    selectedRecords;
    filesUploaded = [];
    file;
    fileContents;
    fileReader;
    content;
    MAX_FILE_SIZE = 1500000;


constructor(){
  super();
  if(this.picklistTypeValue === undefined || this.picklistTypeValue == null){
    this.picklistTypeValue = [{ label: 'PDF', value: 'PDF', selected: true },{ label: 'DOC', value: 'DOC' }];
  }
 
}
async connectedCallback(){

  if(this.picklistTypeValue === undefined || this.picklistTypeValue == null){
    this.picklistTypeValue = [{ label: 'PDF', value: 'PDF', selected: true },{ label: 'DOC', value: 'DOC' }];
  }
 

}



  handlePopup() {
    this.template.querySelector("section").classList.remove("slds-hide");
    this.template
      .querySelector("div.modalBackdrops")
      .classList.remove("slds-hide");
  }

  handleSkip() {
    this.showLoadingSpinner = false;

    this.template.querySelector("section").classList.add("slds-hide");
    this.template
      .querySelector("div.modalBackdrops")
      .classList.add("slds-hide");
  }


handleChangeFields(event) {
  const field = event.target.name;
  if (field === 'type') { this.data.type = event.target.value; }

}


 // getting file 
 handleFilesChange(event) {
  if(event.target.files.length > 0) {
      this.filesUploaded = event.target.files;
      this.fileName = event.target.files[0].name;
  }
}

handleSave() {
  if(this.filesUploaded.length > 0) {
      this.uploadHelper();
  }
  else {
      this.fileName = 'Merci de choisir un ficher !';
  }
}

uploadHelper() {
  this.file = this.filesUploaded[0];
 if (this.file.size > this.MAX_FILE_SIZE) {
      window.console.log('File Size is to long');
      return ;
  }
  this.showLoadingSpinner = true;
  // create a FileReader object 
  this.fileReader= new FileReader();
  // set onload function of FileReader object  
  this.fileReader.onloadend = (() => {
      this.fileContents = this.fileReader.result;
      let base64 = 'base64,';
      this.content = this.fileContents.indexOf(base64) + base64.length;
      this.fileContents = this.fileContents.substring(this.content);
      
      // call the uploadProcess method 
      this.saveToFile();
  });

  this.fileReader.readAsDataURL(this.file);
}

// Calling apex class to insert the file
saveToFile() {
  save({ description: this.data.type, idParent: this.recordId, strFileName: this.file.name, base64Data: encodeURIComponent(this.fileContents)})
  .then(result => {
      window.console.log('result ====> ' +result);
      // refreshing the datatable
      this.getRelatedFiles();

      this.fileName = this.fileName + ' - Uploaded Successfully';
      this.UploadFile = 'File Uploaded Successfully';
      this.isTrue = true;
      this.showLoadingSpinner = false;

      // Showing Success message after file insert
      this.dispatchEvent(
          new ShowToastEvent({
              title: 'Success!!',
              message: this.file.name + ' - Uploaded Successfully!!!',
              variant: 'success',
          }),
      );

  })
  .catch(error => {
      // Showing errors if any while inserting the files
      window.console.log(error);
      this.dispatchEvent(
          new ShowToastEvent({
              title: 'Error while uploading File',
              message: error.message,
              variant: 'error',
          }),
      );
  });
}

}