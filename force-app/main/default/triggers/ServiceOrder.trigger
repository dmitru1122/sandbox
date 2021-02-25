trigger ServiceOrder on CHANNEL_ORDERS__Service_Order__c (before insert, before update, after insert, after update) {

	if (Trigger.isBefore) {
		Set<Id> customerMap = new Set<Id>();

		if (Trigger.isInsert || Trigger.isUpdate) {
			for (CHANNEL_ORDERS__Service_Order__c order : Trigger.new) {
				if (order.CHANNEL_ORDERS__Customer__c != NULL) {
					customerMap.add(order.CHANNEL_ORDERS__Customer__c);
				}  
			}
		}


		Map<Id, CHANNEL_ORDERS__Customer__c> mapCustomerAccount = new Map<Id, CHANNEL_ORDERS__Customer__c>([
			SELECT Id, Account__c 
			FROM CHANNEL_ORDERS__Customer__c
			WHERE Id=:customerMap
			AND Account__c != NULL
		]);

		for (CHANNEL_ORDERS__Service_Order__c order : Trigger.new) {
			if (order.CHANNEL_ORDERS__Customer__c != NULL && mapCustomerAccount.containsKey(order.CHANNEL_ORDERS__Customer__c)) {
				order.Account__c = mapCustomerAccount.get(order.CHANNEL_ORDERS__Customer__c).Account__c;
			}
		}
	}

	if (Trigger.isAfter) {
		Set<Id> accountIs = new Set<Id>();

		for (CHANNEL_ORDERS__Service_Order__c order : Trigger.new) {
			if (order.Account__c != NULL) {
				accountIs.add(order.Account__c);
			}  
		}
		List<Account> updateAccountList = new List<Account>();

		Map<Id,Account> accountMap = new Map<Id,Account>([
			SELECT Id, Salesforce_com_Initial_Order_Date__c, 
				(SELECT Id, CHANNEL_ORDERS__Service_Start_Date__c FROM Service_Orders__r)
			FROM Account
			WHERE Id=:accountIs	
		]);


		for (Id itemIdAcc :accountMap.keySet()) {
			Date startServiceDate;
			for(CHANNEL_ORDERS__Service_Order__c itemOrder : accountMap.get(itemIdAcc).Service_Orders__r) {
				if (itemOrder.CHANNEL_ORDERS__Service_Start_Date__c != NULL) {
					if (startServiceDate == NULL) {
						startServiceDate = itemOrder.CHANNEL_ORDERS__Service_Start_Date__c;
					} else if (itemOrder.CHANNEL_ORDERS__Service_Start_Date__c < startServiceDate) {
						startServiceDate = itemOrder.CHANNEL_ORDERS__Service_Start_Date__c;
					}
				}
			}

			if (startServiceDate != NULL && accountMap.get(itemIdAcc).Salesforce_com_Initial_Order_Date__c != startServiceDate) {
				accountMap.get(itemIdAcc).Salesforce_com_Initial_Order_Date__c = startServiceDate;
				updateAccountList.add(accountMap.get(itemIdAcc));
			}
		}
		update updateAccountList;
	}
}