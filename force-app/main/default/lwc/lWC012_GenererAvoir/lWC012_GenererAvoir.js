import { LightningElement , api } from 'lwc';
import  GenererAvoir from '@salesforce/apex/APC011_GenererAvoir.GenererAvoir';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { CloseActionScreenEvent } from 'lightning/actions';
import { NavigationMixin } from 'lightning/navigation';
export default class LWC012_GenererAvoir extends NavigationMixin(LightningElement) {
    @api recordId;
    @api isLoaded = false;
    
    get options() {
        return [
            { label: 'Générer l\'avoir PDF', value: 'Avoir' },
            { label: 'Générer un avoir proforma', value: 'Avoir proforma' }
        ];
    }
    connectedCallback(){
        console.log('this is get connected callack ');
       // this.GenererAvoirF();
    }
    handleChange(event){
        console.log('pdo this is val',event.detail.value);
        this.value=event.detail.value;
    }
    GenererAvoirF() {
        this.isLoaded =true;
        console.log('this is get con methis ');
        GenererAvoir({
            AccountID : this.recordId,
            typePDF : this.value
        })
        
        .then(result => {
            console.log('first');
            this.loaded = false;
          console.log('this is resi',result);
          console.log('this is resi nav');
          this.redirect(result);
              this.dispatchEvent(new CloseActionScreenEvent());
            
            
          
          })
          .then(result=> {
            console.log('sec');
                this.dispatchEvent(new ShowToastEvent({
                    title: "Succès!",
                    message: "L'avoir est crée avec succès!",
                    variant: "success"
                  }));
           
          })
        .catch(err=>{
            console.error('getting error from apc010 : ' + err);
            this.dispatchEvent(new ShowToastEvent({
                title: "System Error!",
                message: err.body.message,
                variant: "error"
            }));
        });
    }

    closeQuickAction() {
        const closeQA = new CustomEvent('close');
        this.dispatchEvent(closeQA);
    }
    closeAction() {
        this.dispatchEvent(new CloseActionScreenEvent());
    }
    redirect(fileID){
        this[NavigationMixin.Navigate]({
            type: 'standard__recordPage',
            attributes: {
                recordId: fileID,
                objectApiName: 'File',
                actionName: 'view'
            }
          })
    }
}