global class UpdateNotificationOrderDate implements Schedulable {
	global void execute(SchedulableContext sc) {
		UpdateAccound();
	}


	private void UpdateAccound() {

		List<Account> updateAccountList = new List<Account>();
		Map<Id,Account> accountMap = new Map<Id,Account>([
			SELECT Id, Salesforce_com_Initial_Order_Date__c, Salesforce_com_Notification_Start_Order__c, 
				(SELECT Id, CHANNEL_ORDERS__Service_Start_Date__c FROM Service_Orders__r)
			FROM Account
			WHERE Active__c = 'Yes'
			AND RecordType.DeveloperName = 'Compliatric_Customer'
			LIMIT 1000
		]);

		for (Id itemIdAcc :accountMap.keySet()) {
			if (accountMap.get(itemIdAcc).Salesforce_com_Initial_Order_Date__c == NULL && accountMap.get(itemIdAcc).Service_Orders__r.size() > 0) {
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
			} else if (accountMap.get(itemIdAcc).Salesforce_com_Initial_Order_Date__c != NULL) {
				Date notificationDate = Date.newInstance(Date.today().year(),
					accountMap.get(itemIdAcc).Salesforce_com_Initial_Order_Date__c.month(), 
					accountMap.get(itemIdAcc).Salesforce_com_Initial_Order_Date__c.day());

				notificationDate = iterateDate(notificationDate);

				if (accountMap.get(itemIdAcc).Salesforce_com_Notification_Start_Order__c == NULL ||
					accountMap.get(itemIdAcc).Salesforce_com_Notification_Start_Order__c != notificationDate) {
					accountMap.get(itemIdAcc).Salesforce_com_Notification_Start_Order__c = notificationDate;
					updateAccountList.add(accountMap.get(itemIdAcc));
				}
			}
		}
		update updateAccountList;
	}


	private Date iterateDate(Date dateNotification) {
		while (dateNotification < Date.today()) {
			dateNotification = dateNotification.addYears(1);

		}
		return dateNotification;
	}
}