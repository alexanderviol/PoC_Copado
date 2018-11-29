<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <alerts>
        <fullName>Email_Alert_if_approved</fullName>
        <description>Email Alert if approved</description>
        <protected>false</protected>
        <recipients>
            <type>creator</type>
        </recipients>
        <recipients>
            <type>owner</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>unfiled$public/Approval_Action</template>
    </alerts>
    <alerts>
        <fullName>Email_Alert_if_not_approved</fullName>
        <description>Email Alert if not approved</description>
        <protected>false</protected>
        <recipients>
            <type>creator</type>
        </recipients>
        <recipients>
            <type>owner</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>unfiled$public/Rejection_Action</template>
    </alerts>
    <alerts>
        <fullName>MDR_Manager_Review_Rejection_Email_Alert</fullName>
        <description>MDR Manager Review Rejection Email Alert</description>
        <protected>false</protected>
        <recipients>
            <type>owner</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>unfiled$public/MDR_Manager_Review_Rejection</template>
    </alerts>
    <alerts>
        <fullName>MDR_Peer_Review_Rejection_Email_Alert</fullName>
        <description>MDR Peer Review Rejection Email Alert</description>
        <protected>false</protected>
        <recipients>
            <type>owner</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>unfiled$public/MDR_Peer_Review_Rejection</template>
    </alerts>
    <fieldUpdates>
        <fullName>Approval_Status_Approved</fullName>
        <field>approval_status__c</field>
        <literalValue>Approved</literalValue>
        <name>Approval Status - Approved</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Approval_Status_Not_Submitted</fullName>
        <field>approval_status__c</field>
        <literalValue>Not Submitted</literalValue>
        <name>Approval Status - Not Submitted</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Approval_Status_Pending_Mgr_Review</fullName>
        <field>approval_status__c</field>
        <literalValue>Pending Manager Approval</literalValue>
        <name>Approval Status - Pending Mgr Review</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Approval_Status_Pending_Peer_Review</fullName>
        <field>approval_status__c</field>
        <literalValue>Pending Peer Approval</literalValue>
        <name>Approval Status - Pending Peer Review</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Approval_Status_Rejected</fullName>
        <field>approval_status__c</field>
        <literalValue>Rejected</literalValue>
        <name>Approval Status - Rejected</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
</Workflow>
