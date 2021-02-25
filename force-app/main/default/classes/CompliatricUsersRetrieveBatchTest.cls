@isTest 
private class CompliatricUsersRetrieveBatchTest {
	@isTest
	static void testStart() {  

		Id rt2 = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Compliatric Customer').getRecordTypeId();
		Id rt3 = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Internal Organization').getRecordTypeId();

		insert new CompliatricCRMSettings__c(Name = 'UserManagement.Endpoint', Value__c = 'https://testEndpoint');
		insert new CompliatricCRMSettings__c(Name = 'UserManagement.SignatureKey', Value__c = 'gl4k5j7kj45h7l-547kl6j54-4m7lk5-457845mkjnlk');


		List<Account> accountList = new List<Account>();
		accountList.add( new Account(Name = 'TestAccount', Org_Id__c = 'fakeOrgId', RecordTypeId = rt2, Active__c = 'Yes'));
		accountList.add( new Account(Name = 'TestAccount2', Org_Id__c = 'fakeOrgId2', RecordTypeId = rt2, Active__c = 'No'));
		accountList.add( new Account(Name = 'Test Fail', Org_Id__c = 'fakeOrgId3', RecordTypeId = rt3, Active__c = 'Yes'));

		insert accountList;

		Profile adminUserProfile = [SELECT Id FROM Profile WHERE Name='System Administrator'];

		List<User> userList = new List<User>();

		User testAdmin = new User(
			Alias = 'testUser',
			Email = 'yttuelvf@clrmail.com',
			LanguageLocaleKey = 'en_US',
			EmailEncodingKey = 'UTF-8',
			Title = 'Mentor',
			FirstName = 'John',
			LastName = 'Doe',
			LocaleSidKey = 'en_US',
			ProfileId = adminUserProfile.id,
			TimeZoneSidKey = 'America/Los_Angeles',
			UserName = 'yttuelvf@compliatric.com'
		);

		userList.add( testAdmin );

		userList.add(  new User(
			Alias = 'Viktoria',
			Email = 'gugo@example.com',
			LanguageLocaleKey = 'en_US',
			EmailEncodingKey = 'UTF-8',
			Title = 'Writer',
			FirstName = 'Viktor',
			LastName = 'Gugo',
			LocaleSidKey = 'en_US',
			ProfileId = adminUserProfile.id,
			TimeZoneSidKey = 'America/Los_Angeles',
			UserName = 'gugo@compliatric.com'
		));

				// contactListExist.add(
		// 	new Contact(  // test by insert new 
		// 		FirstName = 'Viktor',
		// 		LastName = 'Gugo',
		// 		RadEx__Active__c = true,
		// 		Title = 'Writer',
		// 		Email = 'gugo@example.com',
		// 		Of_Emails_Sent__c = 0,
		// 		Of_Times_Opened__c = 0,
		// 		AccountId = accountList[0].Id
		// 	)
		// );

        insert userList;

		List<Contact> contactListExist = new List<Contact>();
		contactListExist.add(
			new Contact( // test by IsActive and Title Update 
				FirstName = 'Boyd',
				LastName = 'Contact',
				RadEx__Active__c = false,
				Title = 'Professor',
				Email = 'yttuelvf@clrmail.com',
				Of_Emails_Sent__c = 0,
				Of_Times_Opened__c = 0,
				AccountId = accountList[0].Id
			)
		);

		

		// contactListExist.add(
		// 	new Contact(  // test by insert new 
		// 		FirstName = 'Viktor',
		// 		LastName = 'Gugo',
		// 		RadEx__Active__c = true,
		// 		Title = 'Writer',
		// 		Email = 'gugo@example.com',
		// 		Of_Emails_Sent__c = 0,
		// 		Of_Times_Opened__c = 0,
		// 		AccountId = accountList[0].Id
		// 	)
		// );

		contactListExist.add(
			new Contact(  // test by doesn't exist in server answer 
				FirstName = 'Pelevin',
				LastName = 'Maksim',
				RadEx__Active__c = true,
				Title = 'Hunter',
				Email = 'hunter@example.com',
				Of_Emails_Sent__c = 0,
				Of_Times_Opened__c = 0,
				AccountId = accountList[0].Id
			)
		);
	
		insert contactListExist;

		AuthorizationDetails__c authDetails = new AuthorizationDetails__c(AuthorisedUser__c = UserInfo.getUserName() , Name = accountList[0].Org_Id__c,
				AccessToken__c = 'testtoken', RefreshToken__c = 'testrefreshtoken', InstanceURL__c = 'testurl',
				Connected_App_Type__c = 'testconapp');
		insert authDetails;

		Test.setMock(HttpCalloutMock.class, new CompliatricUserManagementMock());

		Test.startTest();
			CompliatricUsersRetrieveBatch ba = new CompliatricUsersRetrieveBatch();
			Database.executeBatch(ba);

		Test.stopTest();


		System.assertEquals( 3 , [SELECT COUNT() FROM Contact WHERE AccountId =:accountList[0].Id]);
		List<Account> accountListTest = [SELECT Id, Compliatric_Users_Retrieve_Last_Update__c, Compliatric_Users_Retrieve_Status__c FROM Account WHERE Id=:accountList[0].Id];
		System.assert( accountListTest[0].Compliatric_Users_Retrieve_Last_Update__c != NULL , 'Last_Update account ampty');
		System.assertEquals('Success' , accountListTest[0].Compliatric_Users_Retrieve_Status__c, 'broken Status after account update');

		List<Contact> contactUpdated = [SELECT Title, external_id__c, Email, RadEx__Active__c FROM Contact WHERE Id=: contactListExist[0].Id];
		System.assertNotEquals( contactListExist[0].Title , contactUpdated[0].Title, 'equals Titile');
		System.assertEquals( contactListExist[0].Email , contactUpdated[0].Email, 'equals Email');
		System.assert(  String.isNotBlank( contactUpdated[0].external_id__c ), 'not blank external_id__c');
		System.assertNotEquals( contactListExist[0].RadEx__Active__c , contactUpdated[0].RadEx__Active__c , 'equals Active');

		List<Contact> contactInsereted = [SELECT Title, external_id__c, Email, RadEx__Active__c FROM Contact WHERE Email = 'gugo@example.com' LIMIT 1];
		System.assertEquals( userList[1].Email , contactInsereted[0].Email, 'equals Active 2');
		System.assert(  String.isNotBlank( contactInsereted[0].external_id__c ), 'not blank external_id__c 2');
		System.assert( contactInsereted[0].RadEx__Active__c, 'Active 2' );
		
	}


	@isTest
	static void testNotFoundOrgId() { 


	}
}