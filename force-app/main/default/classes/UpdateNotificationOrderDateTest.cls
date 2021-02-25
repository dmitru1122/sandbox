@isTest
private class UpdateNotificationOrderDateTest {
	
	@isTest static void test_method_one() {


		Id recordTypeCustomerId = [
			SELECT Id 
			FROM RecordType
			WHERE 
			DeveloperName = 'Compliatric_Customer'
			AND SobjectType =: Account.sObjectType.getDescribe().getName()
			LIMIT 1
		].Id;


		String orgId = UserInfo.getOrganizationId();

		CHANNEL_ORDERS__Partner_Contract_Terms__c newContract = new CHANNEL_ORDERS__Partner_Contract_Terms__c();
		insert newContract;

		Account newAcc = new Account(
			Name = 'Test',
			Active__c = 'Yes',
			RecordTypeId = recordTypeCustomerId
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

		List<Account> acc = [SELECT Id, Salesforce_com_Initial_Order_Date__c, Salesforce_com_Notification_Start_Order__c FROM Account WHERE Id=:newAcc.Id];
		acc[0].Salesforce_com_Initial_Order_Date__c = NULL;
		acc[0].Salesforce_com_Notification_Start_Order__c = NULL;
		update acc;


		Test.startTest();
			UpdateNotificationOrderDate sch = new UpdateNotificationOrderDate();
			sch.execute(NULL);
		Test.stopTest();


		List<Account> acc2 = [SELECT Id, Salesforce_com_Initial_Order_Date__c, Salesforce_com_Notification_Start_Order__c FROM Account WHERE Id=:newAcc.Id];
		System.assertNOtEquals(acc2[0].Salesforce_com_Initial_Order_Date__c, NULL);


	}
	
	@isTest static void test_method_two() {

		Id recordTypeCustomerId = [
			SELECT Id 
			FROM RecordType
			WHERE 
			DeveloperName = 'Compliatric_Customer'
			AND SobjectType =: Account.sObjectType.getDescribe().getName()
			LIMIT 1
		].Id;

		Account newAcc = new Account(
			Name = 'Test',
			Active__c = 'Yes',
			RecordTypeId = recordTypeCustomerId
		);

		insert new List<Account>{newAcc};


		List<Account> acc = [SELECT Id, Salesforce_com_Initial_Order_Date__c, Salesforce_com_Notification_Start_Order__c FROM Account WHERE Id=:newAcc.Id];
		acc[0].Salesforce_com_Initial_Order_Date__c = Date.today().addDays(-10);
		update acc;


		Test.startTest();
			UpdateNotificationOrderDate sch = new UpdateNotificationOrderDate();
			sch.execute(NULL);
		Test.stopTest();


		List<Account> acc2 = [SELECT Id, Salesforce_com_Initial_Order_Date__c, Salesforce_com_Notification_Start_Order__c FROM Account WHERE Id=:newAcc.Id];
		System.assertEquals(acc2[0].Salesforce_com_Notification_Start_Order__c, Date.today().addYears(1).addDays(-10));
	}

	@isTest
	static void test_method_three() {


		Id recordTypeCustomerId = [
			SELECT Id 
			FROM RecordType
			WHERE 
			DeveloperName = 'Compliatric_Customer'
			AND SobjectType =: Account.sObjectType.getDescribe().getName()
			LIMIT 1
		].Id;

		Account newAcc = new Account(
			Name = 'Test',
			Active__c = 'Yes',
			RecordTypeId = recordTypeCustomerId
		);

		insert new List<Account>{newAcc};


		List<Account> acc = [SELECT Id, Salesforce_com_Initial_Order_Date__c, Salesforce_com_Notification_Start_Order__c FROM Account WHERE Id=:newAcc.Id];
		acc[0].Salesforce_com_Initial_Order_Date__c = Date.today().addDays(-10).addYears(-5);
		update acc;


		Test.startTest();
			UpdateNotificationOrderDate sch = new UpdateNotificationOrderDate();
			sch.execute(NULL);
		Test.stopTest();


		List<Account> acc2 = [SELECT Id, Salesforce_com_Initial_Order_Date__c, Salesforce_com_Notification_Start_Order__c FROM Account WHERE Id=:newAcc.Id];
		System.assertEquals(acc2[0].Salesforce_com_Notification_Start_Order__c, Date.today().addYears(1).addDays(-10));
	}

	@isTest
	static void test_method_four() {

		
		Id recordTypeCustomerId = [
			SELECT Id 
			FROM RecordType
			WHERE 
			DeveloperName = 'Compliatric_Customer'
			AND SobjectType =: Account.sObjectType.getDescribe().getName()
			LIMIT 1
		].Id;

		Account newAcc = new Account(
			Name = 'Test',
			Active__c = 'Yes',
			RecordTypeId = recordTypeCustomerId
		);

		insert new List<Account>{newAcc};


		List<Account> acc = [SELECT Id, Salesforce_com_Initial_Order_Date__c, Salesforce_com_Notification_Start_Order__c FROM Account WHERE Id=:newAcc.Id];
		acc[0].Salesforce_com_Initial_Order_Date__c = Date.today().addDays(10).addYears(-5);
		acc[0].Salesforce_com_Notification_Start_Order__c = Date.today().addDays(15).addYears(-4);
		update acc;


		Test.startTest();
			UpdateNotificationOrderDate sch = new UpdateNotificationOrderDate();
			sch.execute(NULL);
		Test.stopTest();


		List<Account> acc2 = [SELECT Id, Salesforce_com_Initial_Order_Date__c, Salesforce_com_Notification_Start_Order__c FROM Account WHERE Id=:newAcc.Id];
		System.assertEquals(acc2[0].Salesforce_com_Notification_Start_Order__c, Date.today().addDays(10));
	}
	
}