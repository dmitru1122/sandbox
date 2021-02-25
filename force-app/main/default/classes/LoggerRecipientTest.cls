@isTest
private class LoggerRecipientTest {
	
	@testSetup
	static void startTestSetup() {

		Account testAc = new Account(Name ='Test org', Org_Id__c='a1U0L000006zBn3456');
		insert testAc;



		List<Radex__Error_Log__c> logList = new List<Radex__Error_Log__c>();

		Radex__Error_Log__c logInside = new Radex__Error_Log__c(
			Radex__Severity__c = 'ERROR',
			Radex__OutSide__c = false,
			Radex__Class_Name__c = 'className0',
			Radex__Error_Message__c = 'textMessage0',
			Radex__External_Id__c = testAc.Org_Id__c,
			Radex__Help_Desk_Link__c = testAc.Org_Id__c,
			Radex__Subject__c =  NULL,
			Radex__Send__c = false
		);
		logList.add(logInside);

		Radex__Error_Log__c logInsidSent = new Radex__Error_Log__c(
			Radex__Severity__c = 'INSIDE',
			Radex__OutSide__c = false,
			Radex__Class_Name__c = 'className8',
			Radex__Error_Message__c = 'textMessage8',
			Radex__Subject__c =  NULL,
			Radex__External_Id__c = '45756rey7568',
			Radex__Send__c = true
		);
		logList.add(logInsidSent);

		for(Integer i = 0; i<100;i++) {
			Radex__Error_Log__c war = new Radex__Error_Log__c(
				Radex__Class_Name__c = 'className',
				Radex__Error_Message__c = 'textMessage',
				Radex__Severity__c = 'WARNING',
				Radex__Subject__c =  NULL,
				Radex__OutSide__c = false,
				Radex__External_Id__c = '457567568',
				Radex__Send__c = false
			);
			logList.add(war);
		}

		for(Integer i = 0; i<50;i++) {
			Radex__Error_Log__c fatal = new Radex__Error_Log__c(
				Radex__Class_Name__c = 'className2',
				Radex__Error_Message__c = 'textMessage2',
				Radex__Severity__c = 'FATAL',
				Radex__Subject__c =  NULL ,
				Radex__OutSide__c = true,
				Radex__External_Id__c = testAc.Org_Id__c,
				Radex__Help_Desk_Link__c = testAc.Org_Id__c,
				Radex__Date__c = Date.today(),
				Radex__Send__c = false
			);
			logList.add(fatal);
		}

		insert logList;

		System.assertEquals(152, [SELECT COUNT() FROM Radex__Error_Log__c]);
	}

	@isTest
	static void testSuccess() {

		RestRequest req = new RestRequest();
		RestResponse res = new RestResponse();
		req.addHeader('httpMethod', 'POST');
		req.requestUri = '/services/apexrest/Logger/v1'; 

		List<Radex__Error_Log__c> listLog = [
			SELECT Id, Name, 
			Radex__Class_Name__c, Radex__Error_Message__c, Radex__Severity__c, Radex__Subject__c,
			Radex__OutSide__c, Radex__External_Id__c, Radex__Date__c, Radex__Send__c, CreatedDate
			FROM Radex__Error_Log__c
		];
		List<RadEx.ExternalLogWrapper> wrapList = new List<RadEx.ExternalLogWrapper>();
		//for(Radex__Error_Log__c item : listLog)  wrapList.add(new RadEx.ExternalLogWrapper(item) );

		String jsomRez = JSON.serialize(listLog);
		req.addParameter('logsArray', jsomRez);
		RestContext.request = req;
		RestContext.response= res;

		Test.startTest();

        	LoggerRecipient.setLogList(jsomRez);

        Test.stopTest();

        System.assertEquals(304, [SELECT COUNT() FROM Radex__Error_Log__c]);


	}
	
	@isTest static void testFail() {

		RestRequest req = new RestRequest();
		RestResponse res = new RestResponse();
		req.addHeader('httpMethod', 'POST');
		req.requestUri = '/services/apexrest/Logger/v1'; 

		RestContext.request = req;
		RestContext.response= res;

		Test.startTest();

        	LoggerRecipient.setLogList('Fail');

        Test.stopTest();

        System.assertEquals(152, [SELECT COUNT() FROM Radex__Error_Log__c]);
	}



	
}