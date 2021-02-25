@isTest
public with sharing class PasswordSetResetTest {


	@testSetup static void setupTestData() {
		Profile adminUserProfile = [SELECT Id FROM Profile WHERE Name='System Administrator'];
		User user1 = new User(
			Alias = 'test1',
			Email = 'test1@clrmail.com',
			LanguageLocaleKey = 'en_US',
			EmailEncodingKey = 'UTF-8',
			FirstName = 'John',
			LastName = 'Doe',
			LocaleSidKey = 'en_US',
			ProfileId = adminUserProfile.id,
			TimeZoneSidKey = 'America/Los_Angeles',
			UserName = '4John@clrmail.com'
		);

		

		User userAdmin = new User(
			Alias = 'vitTest',
			Email = 'yttfefwefuelvf@clrmail.com',
			LanguageLocaleKey = 'en_US',
			EmailEncodingKey = 'UTF-8',
			FirstName = 'Johnfehn',
			LastName = 'Dfefceoe',
			LocaleSidKey = 'en_US',
			ProfileId = adminUserProfile.id,
			TimeZoneSidKey = 'America/Los_Angeles',
			UserName = '4Johnffdeuelvf@clrermail.com'
		);
		
		insert new List<User>{user1, userAdmin };
	}

	@isTest 
	static void test_method_one() {

		List<User> UserListResult = PasswordSetResetController.SearchUser('test1');
		System.assertEquals(1, UserListResult.size());

		List<User> UserListResult2 = PasswordSetResetController.SearchUser('Johnffdeuelvf@clrermail.com');
		System.assertEquals(1, UserListResult2.size());

		List<User> UserListResult3 = PasswordSetResetController.SearchUser('4John');
		System.assertEquals(2, UserListResult3.size());
	}
	
	@isTest 
	static void test_method_two() {

		List<User> UserListResult4 = [ SELECT Id FROM User WHERE UserName =: '4John@clrmail.com'];
	
		Case resetCase = new Case( subject = 'Test Case 2');
		insert resetCase;
		PasswordSetResetController.SetPassowrd(UserListResult4[0].Id, resetCase.Id );
		Case CaseSetTest = [SELECT Id, Status FROM Case WHERE Id=:resetCase.Id];
		System.assertEquals('Agent Responded', CaseSetTest.Status);
	}

	@isTest 
	static void test_method_three() {
		List<User> UserListResult4 = [ SELECT Id FROM User WHERE UserName =: '4John@clrmail.com' ];
	   
		Case resetCaseList = new Case( subject = 'Test Case');
		insert resetCaseList;
		PasswordSetResetController.ResetPassowrd(UserListResult4[0].Id, resetCaseList.Id );

		Case resetCaseTest = [SELECT Id, Status FROM Case WHERE Id=:resetCaseList.Id];
		System.assertEquals('Agent Responded', resetCaseTest.Status);
	}
}