<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <fieldUpdates>
        <fullName>LPCR_UpdateRTOppty</fullName>
        <field>RecordTypeId</field>
        <lookupValue>Famille</lookupValue>
        <lookupValueType>RecordType</lookupValueType>
        <name>Update RT Oppty</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>LookupValue</operation>
        <protected>false</protected>
    </fieldUpdates>
    <rules>
        <fullName>Update RT Oppty</fullName>
        <actions>
            <name>LPCR_UpdateRTOppty</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Account.RecordTypeId</field>
            <operation>equals</operation>
            <value>Famille</value>
        </criteriaItems>
        <triggerType>onCreateOnly</triggerType>
    </rules>
</Workflow>
