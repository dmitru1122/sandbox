@isTest
private class CountOpensEmailBatchTest {
	




	@testSetup static void SetupMethod() {


		ID rtid = [SELECT Id FROM RecordType WHERE SObjectType ='Contact' AND DeveloperName = 'External' LIMIT 1].Id;
		Contact con = new Contact(LastName ='Nik', RecordTypeId = rtid);
		insert con;

		System.assertEquals([SELECT COUNT() FROM Contact WHERE Of_Times_Opened__c = NULL], 1);
	}



	











	@isTest static void tesBatch() {

		Profile adminUserProfile = [SELECT Id FROM Profile WHERE Name = 'System Administrator'];
		User userAdmin = createTestUser(adminUserProfile.id, 'admin', 'admin', true);
		insert userAdmin;

		System.runAs(userAdmin) {
			Test.startTest();
				CountOpensEmailBatch ba = new CountOpensEmailBatch();
				Database.ExecuteBatch(ba);
			Test.stopTest();
		}

		System.assertEquals([SELECT COUNT() FROM Contact WHERE Of_Times_Opened__c != NULL], 1);
	}


	@isTest static void testShedulable() {

		Profile adminUserProfile = [SELECT Id FROM Profile WHERE Name = 'System Administrator'];
		User userAdmin = createTestUser(adminUserProfile.id, 'admin', 'admin', true);
		insert userAdmin;

		System.runAs(userAdmin) {
			Test.startTest();
				CountOpensEmailScheduler sch = new CountOpensEmailScheduler();
				sch.execute(NULL);
			Test.stopTest();
		}
		System.assertEquals([SELECT COUNT() FROM Contact WHERE Of_Times_Opened__c != NULL], 1);
	}
	

	public static User createTestUser(Id profID, String fName, String lName, Boolean active) {
		String orgId = UserInfo.getOrganizationId();
		String dateString = String.valueof(Datetime.now()).replace(' ','').replace(':','').replace('-','');
		Integer randomInt = Integer.valueOf(math.rint(math.random()*1000000));
		String uniqueName = orgId + dateString + randomInt;
		User tuser = new User(  firstname = fName,
			lastName = lName, email = uniqueName + '@test' + orgId + '.org',
			Username = uniqueName + '@test' + orgId + '.org', EmailEncodingKey = 'UTF-8',
			Alias = uniqueName.substring(18, 23), TimeZoneSidKey = 'America/Los_Angeles',
			LocaleSidKey = 'en_US', LanguageLocaleKey = 'en_US',
			ProfileId = profId, IsActive = active);
		return tuser;
	}
}