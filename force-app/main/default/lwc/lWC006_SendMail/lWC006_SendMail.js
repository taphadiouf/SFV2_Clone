import {
    LightningElement,
    wire
} from 'lwc';
import getAllMailTemplates from '@salesforce/apex/APC004_SendMailController.getAllMailTemplates';
import sendMail from '@salesforce/apex/APC004_SendMailController.sendMail';
import {
    ShowToastEvent
} from 'lightning/platformShowToastEvent';

export default class LWC006_SendMail extends LightningElement {
    openmodel;
    emailTemplates;
    emailTemplatesMap;
    currentEmailTemplate;
    value;
    preInscriptionIds =['a333N0000008nxaQAA', 'a333N0000008nxVQAQ'];

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
        this.openmodel = true
    }
    closeModal() {
        this.openmodel = false
    }
    sendMailF() {
        console.log('sendMail method invoked');
        sendMail({
            subject: this.currentEmailTemplate.subject,
            body: this.currentEmailTemplate.body,
            preInscriptionIds : this.preInscriptionIds
        })
        .then(()=>{
            this.dispatchEvent(new ShowToastEvent({
                title: "Succès!",
                message: "Les emails sont envoyés avec succès!",
                variant: "success"
            }));        })
        .catch();
        this.closeModal();
    }
}