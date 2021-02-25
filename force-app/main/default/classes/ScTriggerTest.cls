@isTest
private class ScTriggerTest {
	@isTest static void testServiceOrder() {
		String orgId = UserInfo.getOrganizationId();

		CHANNEL_ORDERS__Partner_Contract_Terms__c newContract = new CHANNEL_ORDERS__Partner_Contract_Terms__c();
		insert newContract;

		Account newAcc = new Account(
			Name = 'Test'
		);

		insert new List<Account>{newAcc};

		CHANNEL_ORDERS__Customer__c customer = new CHANNEL_ORDERS__Customer__c(
			Account__c = newAcc.Id,
			CHANNEL_ORDERS__Customer_Country__c = 'US',
			CHANNEL_ORDERS__Customer_State__c = 'NH',
			CHANNEL_ORDERS__Customer_Org_ID__c = orgId.left(15),
			CHANNEL_ORDERS__Customer_ZIP_Postal_Code__c = '65654413',
			CHANNEL_ORDERS__Customer_Street__c = 'Rstusrthy',
			CHANNEL_ORDERS__Customer_Company_Name__c = 'TestName1',
			CHANNEL_ORDERS__Customer_City__c = 'TestCity'
		);
		insert customer;

		Test.startTest();
			List<CHANNEL_ORDERS__Service_Order__c> listOrder = new List<CHANNEL_ORDERS__Service_Order__c>();
			for (Integer i = 0; i < 10; i++) {
				CHANNEL_ORDERS__Service_Order__c newOrder = new CHANNEL_ORDERS__Service_Order__c(
					CHANNEL_ORDERS__Customer__c = customer.Id,
					CHANNEL_ORDERS__Partner_Contract_Rules__c = newContract.Id,
					CHANNEL_ORDERS__Order_Type__c = 'Reduction',
					CHANNEL_ORDERS__Customer_Org_ID__c = orgId.left(15),
					CHANNEL_ORDERS__Service_Start_Date__c = Date.today().addDays(i),
					CHANNEL_ORDERS__Submitted_By_Email__c = 'tesrd' + i + '@gmail.com'
				);
				listOrder.add(newOrder);
			}
			insert listOrder;


		Test.stopTest();

		Set<Id> seIdOrder = new Set<Id>();

		for (Integer i = 1; i < listOrder.size(); i++) {
			seIdOrder.add(listOrder[i].Id);
		}

		List<CHANNEL_ORDERS__Service_Order__c> listOrderResult = [
			SELECT Id, Account__c
			FROM CHANNEL_ORDERS__Service_Order__c
			WHERE Id =:seIdOrder
		];

		System.assertEquals(listOrderResult.size(), 9);

		for (Integer i = 0; i < listOrderResult.size(); i++) {
			System.assertEquals(listOrderResult[i].Account__c, newAcc.Id);	
		}

		List<Account> accList = [SELECT Id, Salesforce_com_Initial_Order_Date__c FROM Account WHERE Id =:newAcc.Id];
		System.assertEquals(accList[0].Salesforce_com_Initial_Order_Date__c, Date.today());
	}


}