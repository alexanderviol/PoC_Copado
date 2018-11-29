<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <alerts>
        <fullName>QIDC__OneKey_Apex_Job_Failure_Email_IMS</fullName>
        <description>OneKey Apex Job Failure Email</description>
        <protected>false</protected>
        <recipients>
            <type>creator</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>QIDC__OneKey_Emails_IMS/QIDC__OneKey_Apex_Job_Failure_IMS</template>
    </alerts>
    <alerts>
        <fullName>QIDC__OneKey_Apex_Job_Success_Email_IMS</fullName>
        <description>OneKey Apex Job Success Email</description>
        <protected>false</protected>
        <recipients>
            <type>creator</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>QIDC__OneKey_Emails_IMS/QIDC__OneKey_Apex_Job_Success_IMS</template>
    </alerts>
    <rules>
        <fullName>QIDC__Refresh_My_OneKey_Statistics_Status_Failed_IMS</fullName>
        <actions>
            <name>QIDC__OneKey_Apex_Job_Failure_Email_IMS</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>QIDC__Refresh_My_OneKey_Statistics_ims__c.QIDC__Status_ims__c</field>
            <operation>equals</operation>
            <value>Failed</value>
        </criteriaItems>
        <description>Refresh My OneKey Statistics Status Failed</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>QIDC__Refresh_My_OneKey_Statistics_Status_Success_IMS</fullName>
        <actions>
            <name>QIDC__OneKey_Apex_Job_Success_Email_IMS</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>QIDC__Refresh_My_OneKey_Statistics_ims__c.QIDC__Status_ims__c</field>
            <operation>equals</operation>
            <value>Completed</value>
        </criteriaItems>
        <description>Refresh My OK Statistics Status Success</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
</Workflow>
