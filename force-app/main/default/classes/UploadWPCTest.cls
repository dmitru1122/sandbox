@isTest
private class UploadWPCTest {
	
	@isTest
	static void NewObjectsWPC() {
		String orgId = 'TestOrgId';
 
		Account acc = new Account(
			Name = 'Test Slide',
			RadEx__Inactive__c = false,
			Compliatric_Customer_Type__c = 'All',
			Org_Id__c = orgId,
			RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Compliatric_Customer').getRecordTypeId()
		);
		insert acc;

		
		RestRequest req = new RestRequest();
		RestResponse res = new RestResponse();
		req.addHeader('httpMethod', 'GET');
		req.requestUri = '/services/apexrest/wpc/v1/getIdsNewObjectsWPC';  

		Map<String, Object> ObjectIdentifierSetup = new Map<String, Object>{
			'IdObject' => 'a2w6F000001u1j0QAA',
			'DateLastUpdateConverted' => null, 
			'DateLastUpdate' => '2018-12-24 03:20:34'
		};

		String JsonString = JSON.serialize(new List<Map<String, Object>>{ObjectIdentifierSetup});


		req.addParameter('orgId', orgId);
		req.addParameter('existIds', EncodingUtil.urlEncode(JsonString, 'UTF-8'));
		RestContext.request = req;
		RestContext.response = res;

		String response = '';

		Test.startTest();
        	response = UploadWPC.getContent();
        Test.stopTest();


        System.assert(String.isNotBlank(response));
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
		req.requestUri = '/services/apexrest/wpc/v1/getFileForId'; 

	
		req.addParameter('fileId', cv.Id);

		RestContext.request = req;
		RestContext.response = res;

		String response = '';

		Test.startTest();

        	response = UploadWPC.getContent();

        Test.stopTest();

        System.assert(String.isNotBlank(response));
	}

	@isTest
	static void getFileForIdFail() {

		RestRequest req = new RestRequest();
		RestResponse res = new RestResponse();
		req.addHeader('httpMethod', 'GET');
		req.requestUri = '/services/apexrest/wpc/v1/getFileForId'; 

		req.addParameter('fileId', '');

		RestContext.request = req;
		RestContext.response = res;

		String response = '';

		Test.startTest();

        	response = UploadWPC.getContent();

        Test.stopTest();

        System.assert(String.isNotBlank(response));
	}


	@isTest static void getSlideList() {


		Radex__Slide_Set__c setSlide = new Radex__Slide_Set__c(
			Radex__Description__c = 'Description External',
			Radex__Title__c = 'testTitle External',
			Radex__Show_Title_Bar__c = true,
			Radex__Allow_Print__c = true,
			Radex__isActive__c = true,
			Radex__External_Resource__c = true
		);

		insert setSlide;
		Set<String> idsS = new Set<String>{setSlide.Id};


		RestRequest req = new RestRequest();
		RestResponse res = new RestResponse();
		req.addHeader('httpMethod', 'GET');
		req.requestUri = '/services/apexrest/wpc/v1/getListObject';

		String orgId = 'TestOrgId';

		req.addParameter('Ids', JSON.serialize(idsS));
		RestContext.request = req;
		RestContext.response = res;

		String response = '';

		Test.startTest();

        	response = UploadWPC.getContent();

        Test.stopTest();

        System.assert(String.isNotBlank(response));
	}
	
	//// POST 
	@isTest
	static void NewObjectsWPCPOST() {
		String orgId = 'TestOrgId';
 
		Account acc = new Account(
			Name = 'Test Slide',
			RadEx__Inactive__c = false,
			Compliatric_Customer_Type__c = 'All',
			Org_Id__c = orgId,
			RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Compliatric_Customer').getRecordTypeId()
		);
		insert acc;

		Map<String, Object> ObjectIdentifierSetup = new Map<String, Object>{
			'IdObject' => 'a2w6F000001u1j0QAA',
			'DateLastUpdateConverted' => null, 
			'DateLastUpdate' => '2018-12-24 03:20:34'
		};

		String JsonString = JSON.serialize(new List<Map<String, Object>>{ObjectIdentifierSetup});
		String existIdsJSON =  EncodingUtil.urlEncode(JsonString, 'UTF-8');

		String typeRequest = 'getIdsNewObjectsWPC';
		String response = '';

		Test.startTest();

			response = UploadWPC.getContentPost(orgId, existIdsJSON, NULL, typeRequest,'1.924','');

		Test.stopTest();

		System.assert(String.isNotBlank(response));


	}
	

	@isTest static void getSlideListPost() {


		Radex__Slide_Set__c setSlide = new Radex__Slide_Set__c(
			Radex__Description__c = 'Description External',
			Radex__Title__c = 'testTitle External',
			Radex__Show_Title_Bar__c = true,
			Radex__Allow_Print__c = true,
			Radex__isActive__c = true,
			Radex__External_Resource__c = true
		);

		insert setSlide;
		Set<String> idsS = new Set<String>{setSlide.Id};

		String existIdsJSON =  JSON.serialize(idsS);
		String typeRequest = 'getListObject';

		String response = '';

		Test.startTest();

			response = UploadWPC.getContentPost(NULL, NULL, existIdsJSON, typeRequest, '1.924','');

		Test.stopTest();

		System.assert(String.isNotBlank(response));
	}
	
}