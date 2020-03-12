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
    @wire(getAllMailTemplates)
    getAllMailTemplatesF() {
        getAllMailTemplates()
            .then((templates) => {
                this.emailTemplates = [];
                for (let i = 0; i < templates.length; i++) {
                    this.emailTemplates.push({
                        label: templates[i].Name,
                        value: templates[i].Id
                    });
                    this.emailTemplatesMap[templates[i].Id] = {
                        subject: templates[i].Subject,
                        body: templates[i].HtmlValue
                    };
                }
            });
    }
    handleTemplateChange(event) {
        console.log(event);
        const currentTemplateId = event.target.value;
        this.currentEmailTemplate = this.emailTemplatesMap[currentTemplateId];
        console.log(this.currentEmailTemplate);

    }
    openmodal() {
        this.openmodal = true
    }
    closeModal() {
        this.openmodal = false
    }
    sendMailF() {
        console.log('sendMail method invoked');
        sendMail({
            subject: this.currentEmailTemplate.subject,
            body: this.currentEmailTemplate.body,
            preInscriptionIds : this.preinscriptionIds
        })
        .then(()=>{
            this.dispatchEvent(new ShowToastEvent({
                title: "Succès!",
                message: "Les emails sont envoyés avec succès!",
                variant: "success"
            }));})
        .catch();
        this.closeModal();
    }
}