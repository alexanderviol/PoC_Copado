/**
* @author:			snpa
*					T-Systems Multimedia Solutions GmbH
*					Riesaer Strasse 5,
*					01129 Dresden
*					www.t-systems-mms.com
*
* @description      SAFBIO-2325 This class refreshed Order sharing when Manager on User is changed
*                  
*
* @date             10.22.2018
* 
*/
global class BatchAllocateOrderSharing implements Database.Batchable<sObject>{
	global final String Query;
    global set<Id> orderIdSet;
	global map<id, user> oldUserMap;
    global map<id, user> newUserMap;
    
    global BatchAllocateOrderSharing(map<id, user> oldUserMap, map<id, user> newUserMap, set<Id> orderIdSet) {
        this.oldUserMap = oldUserMap;
        this.newUserMap = newUserMap;
		this.orderIdSet = orderIdSet;
        this.query = 'SELECT Id,rep_at_implant__c,rep_for_credit__c,pricebook__c, OwnerId FROM Order WHERE Id IN: orderIdSet';
	}

	global Database.QueryLocator start(Database.BatchableContext BC){
      	return Database.getQueryLocator(query);
	}

	global void execute(Database.BatchableContext BC, List<Order> scope){
		System.debug('scope --' + scope);
        OrderSharing.refreshUserSharings(scope, oldUserMap, newUserMap);
    }

	global void finish(Database.BatchableContext BC){
	}	
    
}