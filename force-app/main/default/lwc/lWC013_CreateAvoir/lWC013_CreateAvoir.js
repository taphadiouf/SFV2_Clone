/* eslint-disable no-dupe-class-members */
import {
    LightningElement,
    api,
    wire,track
  } from 'lwc';
  import getLigneFacture from '@salesforce/apex/APC012_CreateAvoir.getLigneFacture';
  import getPicklistvalues from '@salesforce/apex/APC012_CreateAvoir.getPicklistvalues';
  import saveAvoir from '@salesforce/apex/APC012_CreateAvoir.saveAvoir';
  import { CloseActionScreenEvent } from 'lightning/actions';
  import {ShowToastEvent} from 'lightning/platformShowToastEvent';
  import {
    CurrentPageReference
  } from 'lightning/navigation';
  import { NavigationMixin } from 'lightning/navigation';
  export default class lWC013_CreateAvoir extends LightningElement {
    loaded = false;
    @api recordId;
    @track isAvoirTotal;
    @track isAvoirPartiel;
    @track showAll=false;
   
    columns;
   title='';
    selectedIds = [];
    @wire(CurrentPageReference) pageRef;
    @track errorMsg;
    get options() {
      return [
          { label: 'Avoir total', value: 'Avoir total' },
          { label: 'Avoir partiel', value: 'Avoir partiel' }
      ];
    }
    isAvoirTotal=false;
    isAvoirPartiel=false;
    @track visibleLines
    totalLigneFacture
    @api allselectedRows=[];
    @api allselectedRowsBeforeEvt=[];
    @track preselectedRows=[];
     @api arrayIds=[];
     
     
    handleChange(event){
      this.value = event.detail.value;
      if(this.value && this.value=='Avoir total'){
        this.isAvoirPartiel=false;
        this.isAvoirTotal=true;
      }
      if(this.value && this.value=='Avoir partiel'){
        this.isAvoirTotal=false;
        this.isAvoirPartiel=true;
      }
      if(this.value && (this.value=='Avoir partiel' || this.value=='Avoir total')){
          this.showAll=true;
      }
    }
    handleChangeNature(event){
      this.natureavoir = event.detail.value;
    }
    
    @wire(getPicklistvalues, {})
    getPicklistvaluesF({
        error,
        data
    }) {
        if (data) {
            this.optionsNature = [];
            for (let i = 0; i < data.length; i++) {
                this.optionsNature.push({
                    label: data[i],
                    value: data[i]
                });
            }
        }
        if (error) {
            console.error(error);
        }

    }
    @wire(getLigneFacture, { invId :'$recordId'})
      wiredaccount({error, data}){
        if(data){
          this.totalLigneFacture =  JSON.parse(data);
          for(let i=0;i<this.totalLigneFacture.length;i++){
            this.totalLigneFacture[i].selected=false;
          }
          this.loaded = true;
        }
        if(error){
            console.error(error)
        }
      }
    get ctnum() {
      if (this.totalLigneFacture) {
        let arr=[];
        arr=this.totalLigneFacture;
        return arr[0].ctNum;
      }
      return '';
      
      
    }
    get socfac() {
      if (this.totalLigneFacture) {
        let arr=[];
        arr=this.totalLigneFacture;
        return arr[0].socfac;
      }
      return '';
      
      
    }
    constructor() {
        super();
        this.columns = [{
                label: '',
                fieldName: '',
                type: ''
            },
            {
                label: 'Name',
                fieldName: 'name',
                type: ''
            },
            {
                label: 'ID',
                fieldName: 'recId',
                type: ''
            },
            {
                label: 'Montant',
                fieldName: 'Montant',
                type: ''
            }
        ];
    }
    
    
    updateLinesHandler(event){
    
      let selectedRow=this.template.querySelector('lightning-datatable').getSelectedRows();
     
      
      let selectedIds=[];
      let visibleIds=[];
      if(this.visibleLines){
        for (let i = 0; i < selectedRow.length; i++) {
          selectedIds.push(selectedRow[i].recId)
        }
        for(let i=0;i< this.visibleLines.length;i++){
          visibleIds.push(this.visibleLines[i].recId);
        }
        
        for (let i = 0; i < this.totalLigneFacture.length; i++) {
          if(visibleIds.indexOf(this.totalLigneFacture[i].recId) != -1){
            if(selectedIds.indexOf(this.totalLigneFacture[i].recId) != -1 ){
              this.totalLigneFacture[i].selected=true;
              
            }else{
              this.totalLigneFacture[i].selected=false;
            }
          }
          
        }
        
      }
      
      this.visibleLines=[...event.detail.records]
      selectedIds=[];
      for (let i = 0; i < this.visibleLines.length; i++) {
        if(this.visibleLines[i].selected){
          selectedIds.push(this.visibleLines[i].recId);
        }
      }
      this.preselectedRows=selectedIds;
      
    }
    
    closeAction() {
      this.dispatchEvent(new CloseActionScreenEvent());
    }
    handleSave(){
      this.loaded = false;
      let datedebut=new Date();
      let objettosend={};
      if(this.recordId){
        objettosend.invoiceID=this.recordId;
      }
      if(this.value){
        objettosend.typeAvoir=this.value;
      }
      var inp=this.template.querySelectorAll("lightning-input");
      inp.forEach(function(element){
          if(element.name=="datedebut"){
            datedebut=element.value ? element.value : ''
            this.DateDebut=element.value ? element.value : ''
            objettosend.datedebut=element.value ? element.value : ''
          }
          if(element.name=="datefin"){
            objettosend.datefin=element.value ? element.value : '';
            this.DateFin=element.value ? element.value : '';
          }
          if(element.name=="nomavoir"){
            objettosend.nomavoir=element.value ? element.value : '';
            this.nomavoir=element.value ? element.value : '';
          }
          if(element.name=="avoirmontant"){
            objettosend.avoirmontant=element.value ? element.value : '';
            this.montantavoir=element.value ? element.value : '';
          }
          if(element.name =="checkApply"){
            this.checkApplyAll=element.checked;
            objettosend.checkboxApplyAll=element.checked ;
          }
          
          
      },this);
      
    var txtArea=this.template.querySelectorAll("lightning-textarea");
    txtArea.forEach(function(element){
      objettosend.descavoir=element.value ? element.value : '';
      this.desc=element.value ? element.value : '';
    },this)
    if( this.isAvoirPartiel){
      let LinesSave=[];
      let LineNew=[];
      let selectedRow=JSON.parse(JSON.stringify(this.template.querySelector('lightning-datatable').getSelectedRows()));
      LineNew=selectedRow;
      let unsavedIDs=[];
      let tosaveIDS=[];
      for (let i = 0; i < LineNew.length; i++) {
          if(!LineNew[i].selected){
              unsavedIDs.push(LineNew[i].recId);
          }
      }
      for (let i = 0; i < this.totalLigneFacture.length; i++) {
          if(unsavedIDs.indexOf(this.totalLigneFacture[i].recId) != -1){
              this.totalLigneFacture[i].selected=true;
          }
      }
      for (let i = 0; i < this.totalLigneFacture.length; i++) {
          if(this.totalLigneFacture[i].selected){
          LinesSave.push(this.totalLigneFacture[i]);
          tosaveIDS.push(this.totalLigneFacture[i].recId);
          }
      }
      this.preselectedRows=tosaveIDS;
      if(LinesSave) objettosend.LineList=LinesSave;  
      
    }
     objettosend.TypeAvoir=this.value
     objettosend.NatureAvoir=this.natureavoir
      // debugger
      
      saveAvoir({resp : JSON.stringify(objettosend)})
      .then(result => {
        this.loaded = true;
        this.errorMsg=result.errorMessage
        if(!this.errorMsg){
          this.dispatchEvent(new CloseActionScreenEvent());
        }
        
      
      })
      .then(result=> {
        if(!this.errorMsg){
            this.dispatchEvent(new ShowToastEvent({
                title: "Succès!",
                message: "L'avoir est crée avec succès!",
                variant: "success"
              }));
        }else{
            this.dispatchEvent(new ShowToastEvent({
                title: "Erreur!",
                message:this.errorMsg,
                variant: "error"
            }));
        }
        
      })
      .catch(error => {
        this.loaded = true;
        this.dispatchEvent(new ShowToastEvent({
            title: "Erreur!",
            message: error.body.message,
            variant: "error"
        }));
       
      })
      
    }
    handleSaveTbl(){
      console.log('pdo this is save from tble ');
    }
    redirect(invID){
      this[NavigationMixin.Navigate]({
          type: 'standard__recordPage',
          attributes: {
              recordId: invID,
              objectApiName: 'blng__Invoice__c',
              actionName: 'view'
          }
      });
  }
  
  }