import { LightningElement, api } from 'lwc';

export default class LWC010_TableBodyCell extends LightningElement {
    @api
    fieldname;
    @api 
    record;

    get getCellVal(){
        return this.record[this.fieldname];
    }
}