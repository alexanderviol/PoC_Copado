/**
* @author:			arwe
*					T-Systems Multimedia Solutions GmbH
*					Riesaer Strasse 5,
*					01129 Dresden
*					www.t-systems-mms.com
* modified by:      snpa
*
* @description      SAFBIO-2150 This class creates order sharing for 'Rep at Implant' and 'Rep for credit'
*                  
*
* @date             03.10.2018
* 
*/

public without sharing class OrderSharing {

    @TestVisible
    private static final String SHARING_ACCESS_LEVEL = Constants.SHARING_ACCESS_LEVEL_EDIT;

    /**
     * This is a wrapper class for potential or existing sharing
     */
    private class OrderSharingWrapper {

        public String key; // unique key
        public Id orderId;
        public Id userId;
        public Id orderShareId;

        public OrderSharingWrapper(Id orderId, Id userId) {
            this.orderId = orderId;
            this.userId = userId;
            key = getConcatID(orderId, userId);
        }
        
        public OrderSharingWrapper(OrderShare orderShare) {
            this(orderShare.OrderId, orderShare.UserOrGroupId);
            orderShareId = orderShare.Id;
        }

        private OrderShare createSharing() {
            OrderShare newSharing = new OrderShare(OrderId = orderId, UserOrGroupId = userId);
            newSharing.OrderAccessLevel = SHARING_ACCESS_LEVEL;
            return newSharing;
        }

        private String getConcatID(Id orderId, Id userId) {
            return orderId + '-' + userId;
        }
    }

    // maps that holds our sharing data
    private Map<String, OrderSharingWrapper> sharingsAdd;
    private Map<String, OrderSharingWrapper> sharingsDelete;
    private Map<String, OrderSharingWrapper> sharingsOld;
    // map of orders for error handling
    private Map<Id, Order> orderMap;
    private map<id, user> userMap;
    private map<id, user> oldUserMap;


    /**
     * Constructor initiates used maps
     */
    private OrderSharing(List<Order> newOrders) {
        orderMap = new Map<Id, Order>(newOrders);
        sharingsAdd = new Map<String, OrderSharing.OrderSharingWrapper>();
        sharingsDelete = new Map<String, OrderSharing.OrderSharingWrapper>();
        sharingsOld = new Map<String, OrderSharing.OrderSharingWrapper>();
    }


    /**
     * Creates or deletes Sharing for a list of orders
     *
     * @param newOrders new orders as a List
     * @param oldOrders old version of orders as a map; on insert can be null
     */
    public static void createSharings(List<Order> newOrders, Map<Id, Order> oldOrders) {

        OrderSharing orderSharing = new OrderSharing(newOrders);
		
        orderSharing.getUserData(newOrders, oldOrders);
        // get old OrderSharing
        orderSharing.getOldOrdersSharing(newOrders);        
        orderSharing.assignSharing(newOrders, oldOrders);
        orderSharing.insertSharing();
        orderSharing.removeSharing();
    }
    
    public static void refreshUserSharings(list<order> orderList, map<id, user> oldUserMap, map<id, user> newUserMap) {
        
        OrderSharing orderSharing = new OrderSharing(orderList);
        orderSharing.getOldOrdersSharing(orderList);
        orderSharing.userMap = newUserMap;
        orderSharing.oldUserMap = oldUserMap;
        orderSharing.assignSharing(orderList, null);
        orderSharing.insertSharing();
        orderSharing.removeSharing();
    }
    
    /**
     * Deletes sharings for removed Reps and Managers
     *
     * Created by :  snpa
     */
    private void removeSharing() {
    	// Key is orderShareId Value is order Id needed for errordanling
        map<Id, Id> sharingIdsToRemove = new map<Id, Id>();
		
        // get order Sharing for Deletion
        for (OrderSharingWrapper orderSharingWrapper : sharingsDelete.values()) {
            if (sharingsOld.containsKey(orderSharingWrapper.key)) {
                orderSharingWrapper.orderShareId = sharingsOld.get(orderSharingWrapper.key).orderShareId;
            }
            
            if (orderSharingWrapper.orderShareId != null) {
                sharingIdsToRemove.put(orderSharingWrapper.orderShareId, orderSharingWrapper.orderId);
            }
        }
        
        // delete sharing which are removed
        if (sharingIdsToRemove.size() != 0) {
            List<Database.DeleteResult> deleteResults = Database.delete(new List<Id>(sharingIdsToRemove.keySet()), false);
            // error handling delete sharing
            for (Integer i = 0; i < deleteResults.size(); i++) {
                if (!deleteResults[i].isSuccess()) {
                    Order orderWithError = orderMap.get(sharingIdsToRemove.get(deleteResults[i].getId()));
                    for (Database.Error error : deleteResults[i].getErrors()) {
                        // get depending Order
                        orderWithError.addError(Label.ERR_REMOVE_SHARING + ' ' + error);
                    }
                }
            }
        }    
    }
    
    /**
     * Inserts new sharings for Reps and Managers
     *
     * Created by :  snpa
     */
    private void insertSharing() {
        List<OrderShare> newOrderSharings = new List<OrderShare>();
        
        // get all valid sharing from wrapper
        for (OrderSharingWrapper orderSharingWrapper : sharingsAdd.values()) {
            if (orderSharingWrapper.userId != null && orderSharingWrapper.orderId != null) {
                newOrderSharings.add(orderSharingWrapper.createSharing());
            }
        }

        // insert new sharing
        if (newOrderSharings.size() != 0) {
            List<Database.SaveResult> saveResults = Database.insert(newOrderSharings, false);
            // error Handling new sharing
            for (Integer i = 0; i < saveResults.size(); i++) {
                if (!saveResults[i].isSuccess()) {
                    Order orderWithError = orderMap.get(newOrderSharings[i].OrderId);
                    for (Database.Error error : saveResults[i].getErrors()) {
                        // get depending Order
                        orderWithError.addError(Label.ERR_SET_SHARING + ' ' + error);
                    }
                }
            }
        } 
    }
    
    /**
     * Fills old order sharing map from database with sharing from order
     *
     * @param orders list of orders
     */
    private void getOldOrdersSharing(List<Order> orders) {

        Set<Id> orderIds = (new Map<Id, Order>(orders)).keySet();

        for (OrderShare orderShare : [SELECT Id, UserOrGroupId, OrderId FROM OrderShare WHERE OrderId IN :orderIds
                                     	AND RowCause = 'Manual']) {
            OrderSharingWrapper orderSharingWrapper = new OrderSharingWrapper(orderShare);
            sharingsOld.put(orderSharingWrapper.key, orderSharingWrapper);
        }
    }
    
    /**
     * Populates User's manager for old and new values
     *
     * @param newOrders list of new orders
     * @param oldOrders map of old orders
     * 
     * Created by : snpa
     */
    private void getUserData(List<Order> newOrders, Map<Id, Order> oldOrders) {
    	set<id> userIds = new set<id>();
        
        for (Order order : newOrders) {
            if (oldOrders != null) {
                userIds.add(oldOrders.get(order.Id).rep_for_credit__c);
                userIds.add(oldOrders.get(order.Id).rep_at_implant__c);
            }  
            userIds.add(order.rep_for_credit__c);
            userIds.add(order.rep_at_implant__c);
        }
        userMap = new map<id, user>([SELECT managerid, manager_vi__c  FROM User WHERE id IN : userIds]);    
    }    
    
    /**
     * Assigns assigns required values and calls add and remove methods
     *
     * Created by :  snpa
     */
    private void assignSharing(List<Order> newOrders, Map<Id, Order> oldOrders) {
        
        set<id> idToShare = new set<id>();        
        for (Order order : newOrders) {            
            set<id> idsToShareWith = new set<id>();
            
            Order oldOrder;
            if(oldOrders != null && oldOrders.containskey(order.id)) {
            	oldOrder = oldOrders.get(order.id);    
            }
            
            Id newCrmRepAtImplantManager = (userMap.containsKey(order.rep_at_implant__c) ? userMap.get(order.rep_at_implant__c).managerid : null);
            Id newCrmRepForCreditManager = (userMap.containsKey(order.rep_for_credit__c) ? userMap.get(order.rep_for_credit__c).managerid : null);
            Id newViRepAtImplantManager = (userMap.containsKey(order.rep_at_implant__c) ? userMap.get(order.rep_at_implant__c).manager_vi__c : null);
            Id newViRepForCreditManager = (userMap.containsKey(order.rep_for_credit__c) ? userMap.get(order.rep_for_credit__c).manager_vi__c : null);
            
            checkAddConditions(order,
                               newCrmRepAtImplantManager, 
                               newCrmRepForCreditManager,
                               newViRepAtImplantManager,
                               newViRepForCreditManager);
            
            if(userMap != null && oldOrder != null) {                
                checkRemoveConditions (order,  oldOrder , 
                                           newCrmRepAtImplantManager, 
                                           newCrmRepForCreditManager,
                                           newViRepAtImplantManager,
                                           newViRepForCreditManager);
            }   
            if(oldUserMap != null) {
                checkRemoveManagerConditions(order,
                                           newCrmRepAtImplantManager, 
                                           newCrmRepForCreditManager,
                                           newViRepAtImplantManager,
                                           newViRepForCreditManager);
            }
        }        
    }
    
    /**
     * Method handles all add sharing scenarios
     *
     * Created by :  snpa
     */
    private void checkAddConditions(Order order, 
                                       Id newCrmRepAtImplantManager, 
                                       Id newCrmRepForCreditManager,
                                       Id newViRepAtImplantManager,
                                       Id newViRepForCreditManager) {
		if(isCrmOrder(order)) {                    
        	checkCriteriaAndAdd(order.id, newCrmRepAtImplantManager, order.ownerId);
        	checkCriteriaAndAdd(order.id, newCrmRepForCreditManager, order.ownerId);            		
		}
		if(isViOrder(order)) {
            checkCriteriaAndAdd(order.id, newViRepAtImplantManager, order.ownerId);
        	checkCriteriaAndAdd(order.id, newViRepForCreditManager, order.ownerId);    
		}
        checkCriteriaAndAdd(order.id, order.rep_for_credit__c, order.ownerId); 
        checkCriteriaAndAdd(order.id, order.rep_at_implant__c, order.ownerId);
    }
    
    /**
     * Method handles all remove sharing scenarios from User change
     *
     * Created by :  snpa
     */
    private void checkRemoveManagerConditions(Order order,
                                       Id newCrmRepAtImplantManager, 
                                       Id newCrmRepForCreditManager,
                                       Id newViRepAtImplantManager,
                                       Id newViRepForCreditManager) {
    	id oldCrmRepAtImplantManager = (order.rep_at_implant__c != null && oldUserMap.containsKey(order.rep_at_implant__c))
                                        	?oldUserMap.get(order.rep_at_implant__c).managerid 
                                        	: null;
        id oldCrmRepForCreditManager =  order.rep_for_credit__c != null && (oldUserMap.containsKey(order.rep_for_credit__c))
                                         ? oldUserMap.get(order.rep_for_credit__c).managerid 
                                         : null; 
        id oldViRepAtImplantManager = order.rep_at_implant__c != null && oldUserMap.containsKey(order.rep_at_implant__c) 
                                          ? oldUserMap.get(order.rep_at_implant__c).manager_vi__c : 
                                            null;
        id oldViRepForCreditManager = order.rep_for_credit__c != null && oldUserMap.containsKey(order.rep_for_credit__c) 
                                           ? oldUserMap.get(order.rep_for_credit__c).manager_vi__c 
                                           : null;
        
        if(isCrmOrder(order)) {
            if(newCrmRepAtImplantManager != oldCrmRepAtImplantManager) {
            	checkCriteriaAddToDelete(order.id, oldCrmRepAtImplantManager, order.ownerId);    
            }
            if(newCrmRepForCreditManager != oldCrmRepForCreditManager) {
            	checkCriteriaAddToDelete(order.id, oldCrmRepForCreditManager, order.ownerId);    
            }
        }
        if(isViOrder(order)) {
            if(newViRepAtImplantManager != oldViRepAtImplantManager) {
            	checkCriteriaAddToDelete(order.id, oldViRepAtImplantManager, order.ownerId);    
            }
            if(newViRepForCreditManager != oldViRepForCreditManager) {
            	checkCriteriaAddToDelete(order.id, oldViRepForCreditManager, order.ownerId);    
            }
        }                                 
    }
    
    /**
     * Method handles all remove sharing scenarios from Orders
     *
     * Created by :  snpa
     */
    private void checkRemoveConditions(Order order, 
                                       Order oldOrder, 
                                       Id newCrmRepAtImplantManager, 
                                       Id newCrmRepForCreditManager,
                                       Id newViRepAtImplantManager,
                                       Id newViRepForCreditManager) {
    	id oldCrmRepAtImplantManager = (oldOrder.rep_at_implant__c != null && userMap.containsKey(oldOrder.rep_at_implant__c))
                                        	? userMap.get(oldOrder.rep_at_implant__c).managerid 
                                        	: null;
        id oldCrmRepForCreditManager =  oldOrder.rep_for_credit__c != null && (userMap.containsKey(oldOrder.rep_for_credit__c))
                                         ? userMap.get(oldOrder.rep_for_credit__c).managerid 
                                         : null; 
        id oldViRepAtImplantManager = oldOrder.rep_at_implant__c != null && userMap.containsKey(oldOrder.rep_at_implant__c) 
                                          ? userMap.get(oldOrder.rep_at_implant__c).manager_vi__c : 
                                            null;
        id oldViRepForCreditManager = oldOrder.rep_for_credit__c != null && userMap.containsKey(oldOrder.rep_for_credit__c) 
                                           ? userMap.get(oldOrder.rep_for_credit__c).manager_vi__c 
                                           : null;
        
        if(order.rep_for_credit__c != oldOrder.rep_for_credit__c) {
            checkCriteriaAddToDelete(order.id, oldOrder.rep_for_credit__c, order.ownerId);     
        }
        if(order.rep_at_implant__c != oldOrder.rep_at_implant__c) {
            checkCriteriaAddToDelete(order.id, oldOrder.rep_at_implant__c, order.ownerId);     
        }
        if(isCrmOrder(order)) {
            if(newCrmRepAtImplantManager != oldCrmRepAtImplantManager) {
            	checkCriteriaAddToDelete(order.id, oldCrmRepAtImplantManager, order.ownerId);    
            }
            if(newCrmRepForCreditManager != oldCrmRepForCreditManager) {
            	checkCriteriaAddToDelete(order.id, oldCrmRepForCreditManager, order.ownerId);    
            }
        }
        if(isViOrder(order)) {
            if(newViRepAtImplantManager != oldViRepAtImplantManager) {
            	checkCriteriaAddToDelete(order.id, oldViRepAtImplantManager, order.ownerId);    
            }
            if(newViRepForCreditManager != oldViRepForCreditManager) {
            	checkCriteriaAddToDelete(order.id, oldViRepForCreditManager, order.ownerId);    
            }
        }                                 
    }
    
    /**
     * Checks whether order is CRM Order
     *
     * Created by :  snpa
     */
    private boolean isCrmOrder(Order order) {
    	if(String.isNotBlank(order.pricebook__c) && order.pricebook__c.equalsIgnoreCase(Constants.CRM_ORDER) )
            return true;
        return false;
    }
    
    /**
     * Checks whether order is VI Order
     *
     * Created by :  snpa
     */
    private boolean isViOrder(Order order) {
    	if(String.isNotBlank(order.pricebook__c) && (order.pricebook__c.equalsIgnoreCase(Constants.CVI_ORDER) || 
                                                     order.pricebook__c.equalsIgnoreCase(Constants.PVI_ORDER)
                                                    ))
            return true;
        return false;
    }    
    
    /**
     * Checks criteria and adds to delete map
     *
     * Created by :  snpa
     */
    private void checkCriteriaAddToDelete(id orderId, id userIdToRemove,id ownerId) {
        
        if(userIdToRemove != null 
           	&& (sharingsAdd == null || !sharingsAdd.containsKey(orderId + '-' + userIdToRemove))
            && ownerId != userIdToRemove  
            && (sharingsOld != null && sharingsOld.containsKey(orderId + '-' + userIdToRemove))
          ) {
        	OrderSharingWrapper addSharing = new OrderSharingWrapper(orderId, userIdToRemove);
            sharingsDelete.put(addSharing.key, addSharing);    
        }
    }
    
    /**
     * Checks criteria and adds to add map
     *
     * Created by :  snpa
     */
    private void checkCriteriaAndAdd(id orderId, id userIdToAdd, id ownerId) {
        if(userIdToAdd != null && userIdToAdd != ownerId) {
        	OrderSharingWrapper addSharing = new OrderSharingWrapper(orderId, userIdToAdd);
            sharingsAdd.put(addSharing.key, addSharing);    
        }
    }    
}