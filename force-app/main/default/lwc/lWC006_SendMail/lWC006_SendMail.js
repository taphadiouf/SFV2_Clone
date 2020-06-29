import {
    LightningElement,
    wire,
    api
} from 'lwc';
import getAllMailTemplates from '@salesforce/apex/APC004_SendMailController.getAllMailTemplates';
import sendMail from '@salesforce/apex/APC004_SendMailController.sendMail';
import {
    ShowToastEvent
} from 'lightning/platformShowToastEvent';

export default class LWC006_SendMail extends LightningElement {
    @api
    openmodal;
    @api
    preinscriptionIds;

    emailTemplates;
    emailTemplatesMap;
    currentEmailTemplate;
    value;

    constructor() {
        super();
        this.openmodel = false;
        this.currentEmailTemplate = {};
        this.emailTemplates = [];
        this.emailTemplatesMap = {};
    }
    @wire(getAllMailTemplates,{})
    getAllMailTemplatesF({error, data}){
        console.log("data");
        console.log(data);
        if(data){
            this.emailTemplates = [];
            for (let i = 0; i < data.length; i++) {
                this.emailTemplates.push({
                    label: data[i].Name,
                    value: data[i].Id
                });
                this.emailTemplatesMap[data[i].Id] = {
                    subject: data[i].Subject,
                    body: data[i].HtmlValue
                };
            }
        }
        if(error){
            console.error(error);
        }
    }
    handleTemplateChange(event) {
        const currentTemplateId = event.target.value;
        this.currentEmailTemplate = this.emailTemplatesMap[currentTemplateId];

    }
    sendMailF() {
        console.log('sendMail method invoked');
        sendMail({
                subject: this.currentEmailTemplate.subject,
                body: this.currentEmailTemplate.body,
                preInscriptionIds: this.preinscriptionIds
            })
            .then(() => {
                this.dispatchEvent(new ShowToastEvent({
                    title: "Succès!",
                    message: "Les emails sont envoyés avec succès!",
                    variant: "success"
                }));
            })
            .catch(err=>{
                console.error(err);
                    this.dispatchEvent(new ShowToastEvent({
                        title: "Erreur!",
                        message: err.body.message,
                        variant: "error"
                    
                    }));
             
            });
        this.openmodal = false
    }
    closeModal() {
        this.openmodal = false;
    }
}