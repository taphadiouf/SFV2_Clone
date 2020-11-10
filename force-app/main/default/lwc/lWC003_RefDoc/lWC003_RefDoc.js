/*
 * @ author Ayoub Ouarti
 * @created 28/02/2020
 * @description LWC : The goal of this part is to realize the component which will allow the management of document sending + document consultation of the LPCR document repository
 */

/* eslint-disable no-undef */
/* eslint-disable no-console */
/* eslint-disable no-alert */
import { LightningElement, track, api, wire } from 'lwc';
import getDocumentListCallout from '@salesforce/apex/SM019_DocumentList_Callout.getDocumentListCallout';
import getDocumentBySFIdCallout from '@salesforce/apex/SM023_GetDocument_Callout.getDocumentBySFIdCallout';
import { CurrentPageReference } from 'lightning/navigation';
import { registerListener, unregisterAllListeners } from 'c/pubsub';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

const columns = [
  { label: 'Titre', fieldName: 'name', sortable: true },
  { label: 'Type', fieldName: 'documentType', sortable: true },
  { label: 'File Type', fieldName: 'fileType', type: 'text', sortable: true },
];

export default class LWC003_RefDoc extends LightningElement {
  @api recordId;
  value;

  @track
  title = 'Gestion des documents';
  Lines = 'Lignes';
  In = 'sur';
  @track data = [];
  @track columns = columns;

  @track recordsFromWS = [];
  @track records = [];

  @track errorMsg;
  @track sortBy;
  @track sortDirection;
  @wire(CurrentPageReference) pageRef;
  @track numberOfData = 10;
  @track currentPage = 1;
  @track numberOfAllPages = 1;

  // Filter values with checkboxes only in Account Object
  value1 = this.options1.map( v => v.value);
  value2 = this.options2.map( v => v.value);
  get options1() {
      return [{ label: 'Contrat Accueil',         value: 'Contrat Accueil' }, 
              { label: 'Contrat de Réservation',  value: 'Contrat Réservataire' },
              { label: 'Facture Famille',         value: 'Facture Famille' }];
  }
  get options2() {
      return [{ label: 'Facture Entreprise',      value: 'Facture Entreprise' },
              { label: 'Pièce justificative',     value: 'Pièce justificative' },
              { label: 'Autres',                  value: 'Autres' }];
  }
  handleChangeFilter(e) {
      if(e.target.name == 'Group1'){
        this.value1 = e.detail.value
      }else if(e.target.name == 'Group2'){
        this.value2 = e.detail.value
      }
      this.dataTreatment(this.recordsFromWS.filter( rec => { return ((this.value1.indexOf(rec.name) > -1) || (this.value2.indexOf(rec.name) > -1)) }));
  }
  get inAccountObject () {
    return (this.pageRef.attributes.objectApiName == 'Account');
  }
  // 

  connectedCallback() {
    // Subscribe to handleOrderListResult event to receive data from The Search Component
    registerListener('handleCreateddocument', this.handleCreateddocument, this);
    this.getDocumentListCalloutF(this.recordId);
  }
  getDocumentListCalloutF(ownerid){
    getDocumentListCallout({ ownerid: ownerid, doc_type: '' })
    .then(result=>{
      console.log("called getDocumentListCalloutF");
      if (result) {
        if (result.result && result.result == '200') {
          this.recordsFromWS = result.response;
          this.recordsLength = this.recordsFromWS.length;
          this.dataTreatment(this.recordsFromWS);
        }
      } 
    })
    .catch(error=>{
      console.log('*****Error : ' + error);
      console.log(error);
      this.dispatchEvent(
        new ShowToastEvent({
          title: 'Erreur',
          message: error.body.message,
          variant: 'error',
        }),
      );
    })
  }
  handleSentDocument(event) {
    console.log('*****called handleSentDocument');
    this.getDocumentListCalloutF(this.recordId);
  }
  disconnectedCallback() {
    // unsubscribe from bearListUpdate event
    unregisterAllListeners(this);
  }
  //Handle Data from the Search Component
  handleCreateddocument(document) {
    this.records = [document, ...this.records];
    this.errorMsg = undefined;
    this.recordsFromWS = records;
    this.recordsLength = records.length;
    this.dataTreatment(records);
  }
  dataTreatment(records) {
    if (records !== undefined) {
      // reset numberOfAllPages to 1
      if (this.numberOfData === 0 || this.numberOfData === '') {
        this.numberOfAllPages = 1;
      } else if (this.recordsLength <= this.numberOfData) {
        // reset numberOfAllPages & currentPage to 1
        this.numberOfAllPages = 1;
        this.currentPage = 1;
      } else if (this.recordsLength > this.numberOfData) {
        //calculate number of all pages from the size of records
        this.numberOfAllPages = Math.ceil(this.recordsLength / this.numberOfData);
        this.currentPage = 1;
      }
    }
    //get the range  of records from  currentPage , numberOfData
    this.records = [];
    this.records = records.slice(this.currentPage * this.numberOfData - this.numberOfData, this.currentPage * this.numberOfData);
  }
  handlNumberOfData(event) {
    this.numberOfData = event.detail.value;
    //Preparing data with the new value of lines to print
    if (this.numberOfData !== '' && this.recordsFromWS !== undefined) {
      this.dataTreatment(this.recordsFromWS);
    }
    if (this.numberOfData === '' || this.numberOfData === 0) {
      this.numberOfAllPages = 1;
      this.currentPage = 1;
    }
  }

  handelPrevious() {
    if (this.currentPage !== 1) {
      this.currentPage -= 1;

      //get the range  of records from  currentPage , numberOfData
      this.records = this.recordsFromWS.slice(
        this.currentPage * this.numberOfData - this.numberOfData,
        this.currentPage * this.numberOfData,
      );
    }
  }
  handelForward() {
    if (this.currentPage !== this.numberOfAllPages) {
      this.currentPage += 1;

      //get the range  of records from  currentPage , numberOfData
      this.records = this.recordsFromWS.slice(
        this.currentPage * this.numberOfData - this.numberOfData,
        this.currentPage * this.numberOfData,
      );
    }
  }

  handleSortdata(event) {
    if (this.records !== undefined) {
      // field name
      this.sortBy = event.detail.fieldName;

      // sort direction
      this.sortDirection = event.detail.sortDirection;

      // calling sortdata function to sort the data based on direction and selected field
      this.sortData(event.detail.fieldName, event.detail.sortDirection);
    }
  }

  sortData(fieldname, direction) {
    // serialize the data before calling sort function
    let parseData = JSON.parse(JSON.stringify(this.records));

    // Return the value stored in the field
    let keyValue = a => {
      return a[fieldname];
    };

    // cheking reverse direction
    let isReverse = direction === 'asc' ? 1 : -1;

    // sorting data
    parseData.sort((x, y) => {
      x = keyValue(x) ? keyValue(x) : ''; // handling null values
      y = keyValue(y) ? keyValue(y) : '';

      // sorting values based on direction
      return isReverse * ((x > y) - (y > x));
    });

    // set the sorted data to data table data
    this.records = parseData;
  }
  handleDownloadDocClicked(event) {
    let docId = event.target.dataset.documentid;
    let ownerid = event.target.dataset.ownerid;
    let name = event.target.dataset.name;
    let filetype = event.target.dataset.filetype;
    getDocumentBySFIdCallout({ docId: docId, ownerid: ownerid })
      .then(result => {
        console.log('result : ');
        console.log(result);
        var a = document.body.appendChild(document.createElement('a'));
        a.download = name+'.' + filetype.toLowerCase();
        a.href = 'data:text/plain;base64,' + result;
        a.innerHTML = 'download';
        a.click();
        document.body.removeChild(a);
      })
      .catch(error => {
        console.error('error');
        console.error(error);
      });
  }
}
