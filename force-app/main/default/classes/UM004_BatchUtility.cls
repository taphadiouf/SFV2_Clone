/**
   * @author Ayoub Ouarti
   * @date 17/03/2020
   * @Utilities for running batches
*/

public with sharing class UM004_BatchUtility{

    public static final String DRAFT = 'Draft';
    public static final String ACTIVATED = 'Activated';
    public static final String COMPLETED = 'Completed';
    public static final String INPROGRESS = 'In-Progress';
    public static final Boolean BOOLEAN_TRUE = true;
    public static final Boolean BOOLEAN_FALSE = false;
    public static final String YES = 'Yes';
    public static final String NO = 'No';
    public static final String INVOICEGROUPING_CONTRACTNUMBER = 'Contract Number';
    public static final String RENEWALPRICINGMETHOD_UPLIFT = 'Uplift';
    public static final String RENEWALPRICINGMETHOD_LEGAL_ENTITY_PERCENTAGE = 'Legal Entity Uplift Percentage';
    public static final String RENEWALPRICINGMETHOD_CPI_PERCENTAGE = 'CPI Uplift Percentage';
    public static final String INVOICE_STATUS_POSTED = 'Posted';
    public static final String INVOICE_STATUS_POST_IN_PROGRESS = 'Post In progress';
    public static final String INVOICE_STATUS_DRAFT = 'Draft';
    public static final String QUOTE_TYPE_RENEWAL = 'Renewal';
    public static final String QUOTE_TYPE_AMENDMENT = 'Amendment';
    public static final String BILLING_FREQUENCY_MULTI_YEARS_PREPAID = 'Prepaid Subscription Term';
    public static final String BILLING_FREQUENCY_MONTHLY = 'Monthly';
    public static final String CHARGE_TYPE_ONE_TIME = 'One-Time';
    public static final String BILLING_TYPE_ARREARS = 'Arrears';
    public static final String RENEWALPRICINGMETHOD_LIST = 'List';
    public static final String RENEWALPRICINGMETHOD_SAME = 'Same';
    public static final String OPPORTUNITYSTAGE_PROCUREMENT = 'Procurement';
    public static final String OPPORTUNITYSTAGE_PROPTOSPONSOR = 'Proposal to Sponsor';
    public static final String OPPORTUNITYSTAGE_CLOSEDWON = 'Closed Won';
    public static final String LEGALENTITY_CA_SITEIMPROVE = 'CA Siteimprove';
    public static final String LEGALENTITY_US_SITEIMPROVE = 'US Siteimprove';
    public static final String INVOICE_BATCH_PO_NORTH_AMERICA = 'PO North America';
    public static final String INVOICE_BATCH_PO_INTERNATIONAL = 'PO International';
    public static final String INVOICE_BATCH_INVOICEPLAN = 'Invoice Plan';
    public static final String TAXCOUNTRY_TAXEXEMPT = 'TaxExempt'; 
    public static final String TAXCOUNTRY_ZEROTAX_CROSSBORDER = 'ZeroTax-Crossborder';    

    public static final String COUNTRY_ICELAND = 'Iceland';  
    public static final String COUNTRY_DENMARK = 'Denmark';  
    
    /** current max batch job count */
    @TestVisible
    private static final Integer MAX_APEX_BATCH_JOB_COUNT = 5;

    /**
     * isBatchJobRunning method checks if the provided className has a batch job currently running.
     *
     * @param className
     *
     * @return true if job is running
     */
    public static Boolean isBatchJobRunning(String className) {
        // schedule the apex class only if their is not existing job running
        return [
                SELECT COUNT()
                FROM AsyncApexJob
                WHERE Status IN ('Preparing', 'Processing', 'Queued', 'Holding')
                AND ApexClass.Name = :className
                AND JobType IN ('BatchApex', 'BatchApexWorker')
        ] > 0;
    }

    /**
     * determines whether we are over max concurrent jobs
     *
     * @return if we are over max jobs
     */
    public static Boolean isBatchJobQueueFull() {
        //check if there are MAX_APEX_BATCH_JOB_COUNT active batch jobs
        //In some cases, might need to add "Status='Queued' " to the criteria
        return [
                SELECT COUNT()
                FROM AsyncApexJob
                WHERE JobType = 'BatchApex' AND Status IN ('Preparing', 'Processing', 'Queued', 'Holding')
        ] >= MAX_APEX_BATCH_JOB_COUNT;
    }

}