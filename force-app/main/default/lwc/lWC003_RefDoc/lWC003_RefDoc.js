/*
 * @ author Ayoub Ouarti
 * @created 28/02/2020
 * @description LWC : The goal of this part is to realize the component which will allow the management of document sending + document consultation of the LPCR document repository
 */


/* eslint-disable no-undef */
/* eslint-disable no-console */
/* eslint-disable no-alert */
import { LightningElement, track, api,wire } from 'lwc';
import getAllAttachments from "@salesforce/apex/APC002_AttachmentController.getAllAttachments";
import { CurrentPageReference } from "lightning/navigation";
import { registerListener, unregisterAllListeners } from "c/pubsub";
const columns = [
    { label: 'Titre', fieldName: 'Name' ,sortable: true},
    { label: 'Type', fieldName: 'Description',sortable: true},
    { label: 'Date de création', fieldName: 'CreatedDate', type: 'date' ,sortable: true}
];

export default class Lwc003_RefDoc extends LightningElement {
    @api recordId;
    value;

    @track
    title ='Gestion document LPCR';

    @track data = [];
    @track columns = columns;

    attachmentsFromDB = [];
    @track attachments = [];
    @track columns = columns;
    @track errorMsg;
    @track sortBy;
    @track sortDirection;
    @wire(CurrentPageReference) pageRef;
    @track numberOfData = 10;
    @track currentPage = 1;
    @track numberOfAllPages;
    paginationApex = false;

    

    disconnectedCallback() {
        // unsubscribe from bearListUpdate event
        unregisterAllListeners(this);
      }
    
      async connectedCallback() {
        // get All attachments from DB
        if (!this.paginationApex) {
          this.attachmentsFromDB = await getAllAttachments();
        }
        this.totalData = this.attachmentsFromDB.length;
        this.dataTreatment(this.attachmentsFromDB);
    
        // Subscribe to handleOrderListResult event to receive data from The Search Component
        registerListener("handleCreatedAttachment", this.handleCreatedAttachment, this);
      }
    
  //Handle Data from the Search Component
  handleCreatedAttachment(attachment) {
      
      this.attachments = [ attachment, ...this.attachments ];
      this.errorMsg = undefined;
      this.attachmentsFromDB = attachments;
      this.totalData = attachments.length;
      this.dataTreatment(attachments);

  }


      dataTreatment(attachments) {
        if (this.paginationApex) {
          getAllattachmentsWithOffset({
            numberOfData: this.numberOfData,
            currentPage: this.currentPage
          }).then(result => {
            attachments = result;
            this.attachments = attachments;
          });
        }
        if (attachments !== undefined) {
          // reset numberOfAllPages to 1
          if (this.numberOfData === 0 || this.numberOfData === "") {
            this.numberOfAllPages = 1;
          } else if (this.totalData <= this.numberOfData) {
            // reset numberOfAllPages & currentPage to 1
            this.numberOfAllPages = 1;
            this.currentPage = 1;
          } else if (this.totalData > this.numberOfData) {
            //calculate number of all pages from the size of attachments
            this.numberOfAllPages = Math.ceil(this.totalData / this.numberOfData);
            this.currentPage = 1;
          }
        }
    
        if (!this.paginationApex) {
          //get the range  of attachments from  currentPage , numberOfData
          this.attachments = attachments.slice(
            this.currentPage * this.numberOfData - this.numberOfData,
            this.currentPage * this.numberOfData
          );
        }
      }
      handlNumberOfData(event) {
        this.numberOfData = event.detail.value;
        //Preparing data with the new value of lines to print
        if (this.numberOfData !== "" && this.attachmentsFromDB !== undefined) {
          this.dataTreatment(this.attachmentsFromDB);
        }
        if (this.numberOfData === "" || this.numberOfData === 0) {
          this.numberOfAllPages = 1;
          this.currentPage = 1;
        }
      }
    
      handelPrevious() {
        if (this.currentPage !== 1) {
          this.currentPage -= 1;
          if (!this.paginationApex) {
            //get the range  of attachments from  currentPage , numberOfData
            this.attachments = this.attachmentsFromDB.slice(
              this.currentPage * this.numberOfData - this.numberOfData,
              this.currentPage * this.numberOfData
            );
          } else {
            getAllattachmentsWithOffset({
              numberOfData: this.numberOfData,
              currentPage: this.currentPage
            }).then(result => {
              this.attachments = result;
            });
          }
        }
      }
      handelForward() {
        if (this.currentPage !== this.numberOfAllPages) {
          this.currentPage += 1;
          if (!this.paginationApex) {
            //get the range  of attachments from  currentPage , numberOfData
            this.attachments = this.attachmentsFromDB.slice(
              this.currentPage * this.numberOfData - this.numberOfData,
              this.currentPage * this.numberOfData
            );
          } else {
            getAllattachmentsWithOffset({
              numberOfData: this.numberOfData,
              currentPage: this.currentPage
            }).then(result => {
              this.attachments = result;
            });
          }
        }
      }
    
    
    
      handleSortdata(event) {
        if (this.attachments !== undefined) {
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
        let parseData = JSON.parse(JSON.stringify(this.attachments));
    
        // Return the value stored in the field
        let keyValue = a => {
          return a[fieldname];
        };
    
        // cheking reverse direction
        let isReverse = direction === "asc" ? 1 : -1;
    
        // sorting data
        parseData.sort((x, y) => {
          x = keyValue(x) ? keyValue(x) : ""; // handling null values
          y = keyValue(y) ? keyValue(y) : "";
    
          // sorting values based on direction
          return isReverse * ((x > y) - (y > x));
        });
    
        // set the sorted data to data table data
        this.attachments = parseData;
      }
}
