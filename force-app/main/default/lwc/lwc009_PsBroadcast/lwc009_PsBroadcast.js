import { LightningElement, api, wire, track } from 'lwc';
import  getAllPermissionSet from '@salesforce/apex/APC009_PsBroadcastController.getAllPermissionSet';
import  executeAsyncPsUpdate from '@salesforce/apex/APC009_PsBroadcastController.executeAsyncPsUpdate';

export default class Lwc009_PsBroadcast extends LightningElement {

    @track permissionSetlist;
    @track PsApiNameSelected;
    @track error;

    settingCreate;
    settingDelete;
    settingRead;
    settingEdit;

    constructor(){
        super();
    }

    @wire(getAllPermissionSet, {}) getAllPermissionSetFunction({error, data}) {
        if (data) {
            
            this.permissionSetlist = [];
            for (let i = 0; i < data.length; i++) {
                this.permissionSetlist.push({
                    label: data[i].Name,
                    value: data[i].Name
                });
            }
            
            this.error = undefined;
        }
        if (error) {
            console.error(error);
        }
    }

    handleChange(event) {
        this.value = event.detail.value;
    }
    handleCreateCheckbox(event) {
        this.settingCreate = event.target.checked;
    }
    handleDeleteCheckbox(event) {
        this.settingDelete = event.target.checked;
    }
    handleReadCheckbox(event) {
        this.settingRead = event.target.checked;
    }
    handleEditCheckbox(event) {
        this.settingEdit = event.target.checked;
    }
    handlePsChosen(event){
        this.PsApiNameSelected = event.target.value;
    }

    handelValidation(){

        console.log('>>> HERE handleValidation - START');
        console.log('>>> HERE handleValidation - this.settingRead:' + this.settingRead);
        console.log('>>> HERE handleValidation - this.settingEdit:' + this.settingEdit);
        console.log('>>> HERE handleValidation - this.PsApiNameSelected:' + this.PsApiNameSelected);

        executeAsyncPsUpdate({ tmpCreate: this.settingCreate, tmpDelete: this.settingDelete, tmpRead: this.settingRead, tmpEdit: this.settingEdit, tmpPsName: this.PsApiNameSelected })
            .then((result) => {
                this.error = undefined;
            })
            .catch((error) => {
                this.error = error;
                console.log('>>> ERROR :' + this.error);
            });

        console.log('>>> HERE handleValidation - FINISH');
        
    }

    
}
