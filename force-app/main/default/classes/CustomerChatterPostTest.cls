@isTest
private class CustomerChatterPostTest {

	@testSetup
	static void startTestSetup() {

		Account testAc = new Account(Name ='Test org', Org_Id__c='a1U0L000006zBn3456');
		insert testAc;



		List<Radex__Customer_Chatter_Post__c> logPost = new List<Radex__Customer_Chatter_Post__c>();

		Radex__Customer_Chatter_Post__c post1 = new Radex__Customer_Chatter_Post__c(
			Radex__Customer_ORGs_Ids__c = 'ERROR',
			Radex__Date_Post__c = Date.today(),
			Radex__Type__c = 'Link And Text Post',
			Radex__Push_To_All_ORG__c = true,
			Radex__Link__c = 'https://mail.google.com/',
			Radex__Link_Name__c = 'google',
			Radex__Body__c =  'body',
			Radex__Active__c = true
		);
		logPost.add(post1);

		Radex__Customer_Chatter_Post__c post2 = new Radex__Customer_Chatter_Post__c(
			Radex__Customer_ORGs_Ids__c = 'ERROR',
			Radex__Date_Post__c = Date.today(),
			Radex__Type__c = 'File And Text Post',
			Radex__Push_To_All_ORG__c = true,
			Radex__Link__c = 'https://mail.google.com/',
			Radex__Link_Name__c = 'google',
			Radex__Body__c =  'body',
			Radex__Active__c = true

		);
		logPost.add(post2);

		Radex__Customer_Chatter_Post__c post3 = new Radex__Customer_Chatter_Post__c(
			Radex__Customer_ORGs_Ids__c = 'ERROR',
			Radex__Date_Post__c = Date.today(),
			Radex__Type__c = 'Text Post',
			Radex__Push_To_All_ORG__c = true,
			Radex__Link__c = 'https://mail.google.com/',
			Radex__Link_Name__c = 'google',
			Radex__Body__c =  'body',
			Radex__Active__c = true

		);
		logPost.add(post3);

		Radex__Customer_Chatter_Post__c post4 = new Radex__Customer_Chatter_Post__c(
			Radex__Customer_ORGs_Ids__c = 'ERROR',
			Radex__Date_Post__c = Date.today(),
			Radex__Type__c = 'Text Post',
			Radex__Push_To_All_ORG__c = false,
			Radex__Link__c = 'https://mail.google.com/',
			Radex__Link_Name__c = 'google',
			Radex__Body__c =  'body',
			Radex__Active__c = true

		);
		logPost.add(post4);



		insert logPost;

		System.assertEquals(4, [SELECT COUNT() FROM Radex__Customer_Chatter_Post__c]);
	}

	@isTest
	static void testSuccess() {



		RestRequest req = new RestRequest();
		RestResponse res = new RestResponse();
		req.addHeader('httpMethod', 'POST');
		req.requestUri = '/services/apexrest/ChatterPost/v1/getAll'; 

		String resStr = '';

		
		req.addParameter('orgId', 'erhgrhg');
		req.addParameter('lastDate', String.valueOf(Date.today()));	
		RestContext.request = req;
		RestContext.response = res;

		Test.startTest();

        	resStr = CustomerChatterPost.getChatterPost();

        Test.stopTest();

        System.assert(String.isNotBlank(resStr));
	}


	@isTest
	static void getFileForId() {



		ContentVersion cv = new ContentVersion(
			Title = 'titleFile',
			PathOnClient =  'titleFile.pdf',
			VersionData = Blob.valueOf('UNIT.TEST'),
			ContentLocation = 'S'
		);
		insert cv; 

		RestRequest req = new RestRequest();
		RestResponse res = new RestResponse();
		req.addHeader('httpMethod', 'GET');
		req.requestUri = '/services/apexrest/ChatterPost/v1/getFileForId'; 

	
		req.addParameter('fileId', cv.Id);

		RestContext.request = req;
		RestContext.response = res;

		String response = '';

		Test.startTest();

        	response = CustomerChatterPost.getChatterPost();

        Test.stopTest();

        System.assert(String.isNotBlank(response));
	}
	
	@isTest static void testPost() {

		Id postId = [SELECT Id FROM Radex__Customer_Chatter_Post__c WHERE Radex__Active__c = true LIMIT 1].Id;


		RestRequest req = new RestRequest();
		RestResponse res = new RestResponse();
		req.addHeader('httpMethod', 'POST');
		req.requestUri = '/services/apexrest/ChatterPost/v1/getPostForId';
		req.addParameter('postId', postId);
		String response = '';

		RestContext.request = req;
		RestContext.response= res;

		Test.startTest();

        	response = CustomerChatterPost.getChatterPost();

        Test.stopTest();

        System.assert(String.isNotBlank(response));
	}
}