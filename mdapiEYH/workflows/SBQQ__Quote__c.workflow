<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <alerts>
        <fullName>LPCR_AlerteContratToujoursAttenteSignature</fullName>
        <description>Alerte Contrat Toujours En Attente De Signature</description>
        <protected>false</protected>
        <recipients>
            <type>owner</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>unfiled$public/LPCR_Contrat_NonSigne</template>
    </alerts>
    <alerts>
        <fullName>LPCR_ContratRejete</fullName>
        <description>Validation de prix rejeté</description>
        <protected>false</protected>
        <recipients>
            <type>owner</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>unfiled$public/LPCR_DevisRejete</template>
    </alerts>
    <alerts>
        <fullName>LPCR_Contratvalide</fullName>
        <description>Contrat validé</description>
        <protected>false</protected>
        <recipients>
            <type>owner</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>unfiled$public/LPCR_DevisAccepte</template>
    </alerts>
    <alerts>
        <fullName>LPCR_ValidationAcceptee</fullName>
        <description>Validation de prix acceptée</description>
        <protected>false</protected>
        <recipients>
            <type>owner</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>unfiled$public/LPCR_DevisAccepte</template>
    </alerts>
    <fieldUpdates>
        <fullName>LPCR_StatutBrouillon</fullName>
        <field>SBQQ__Status__c</field>
        <literalValue>Draft</literalValue>
        <name>STATUTBROUILLON</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>true</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>LPCR_StatutEnRevue</fullName>
        <field>SBQQ__Status__c</field>
        <literalValue>In Review</literalValue>
        <name>STATUTENREVUE</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>true</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>LPCR_StatutValide</fullName>
        <field>SBQQ__Status__c</field>
        <literalValue>Approved</literalValue>
        <name>STATUTVALIDE</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>true</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>LPCR_UpdateRTQuote</fullName>
        <field>RecordTypeId</field>
        <lookupValue>Contrat_Accueil</lookupValue>
        <lookupValueType>RecordType</lookupValueType>
        <name>Update RT Quote</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>LookupValue</operation>
        <protected>false</protected>
    </fieldUpdates>
    <rules>
        <fullName>Indexation Des Prix</fullName>
        <!--
        <actions>
            <name>LPCR_MiseaJourValeurIndexation</name>
            <type>Task</type>
        </actions>
        -->
        <active>false</active>
        <criteriaItems>
            <field>SBQQ__Quote__c.LPCR_RenouvellementConvenu__c</field>
            <operation>equals</operation>
            <value>Non</value>
        </criteriaItems>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
        <workflowTimeTriggers>
            <offsetFromField>SBQQ__Quote__c.LPCR_DateFin__c</offsetFromField>
            <timeLength>-60</timeLength>
            <workflowTimeTriggerUnit>Days</workflowTimeTriggerUnit>
        </workflowTimeTriggers>
    </rules>
    <rules>
        <fullName>LPCR_ContratNonSigné</fullName>
        <active>false</active>
        <criteriaItems>
            <field>SBQQ__Quote__c.SBQQ__Status__c</field>
            <operation>equals</operation>
            <value>Envoyé pour signature</value>
        </criteriaItems>
        <triggerType>onCreateOnly</triggerType>
        <workflowTimeTriggers>
            <actions>
                <name>LPCR_AlerteContratToujoursAttenteSignature</name>
                <type>Alert</type>
            </actions>
            <timeLength>10</timeLength>
            <workflowTimeTriggerUnit>Days</workflowTimeTriggerUnit>
        </workflowTimeTriggers>
    </rules>
    <rules>
        <fullName>Update RT Quote</fullName>
        <actions>
            <name>LPCR_UpdateRTQuote</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <formula>SBQQ__Account__r.RecordType.DeveloperName = &quot;Famille&quot;</formula>
        <triggerType>onCreateOnly</triggerType>
    </rules>
    <!--
    <tasks>
        <fullName>LPCR_MiseaJourValeurIndexation</fullName>
        <assignedTo>Quote Owner</assignedTo>
        <assignedToType>user</assignedToType>
        <description>Bonjour,

La valeur de l&#39;indexation pour le contrat {!SBQQ__Quote__c.Name} n&#39;est pas à jour. 
Merci de faire le nécessaire. 

Lien vers le Contrat : {!SBQQ__Quote__c.Link}

Bien cordialement,

Admin LPCR</description>
        <dueDateOffset>30</dueDateOffset>
        <notifyAssignee>false</notifyAssignee>
        <priority>Normal</priority>
        <protected>false</protected>
        <status>Open</status>
        <subject>Mise à Jour De La Valeur De l&#39;indexation</subject>
    </tasks>
    -->
</Workflow>
