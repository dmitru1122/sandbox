@isTest
public with sharing class DeleteSuncLogsBatchTest {
	@isTest
	public static void DeleteSuncLogsBatchTest() {

		Account testAccount = new Account(
			Name = 'TestAcc'
		);
		insert testAccount;

		Account testAccount2 = new Account(
			Name = 'TestAcc2'
		);
		insert testAccount2;

		List<RadEx__Error_Log__c> errList = new List<RadEx__Error_Log__c>();
		for (Integer i = 0; i < 200; i++ ) {
			RadEx__Error_Log__c err = new RadEx__Error_Log__c();
			err.RadEx__ORG__c = testAccount.Id;
			err.RadEx__Severity__c = 'CONTENT_SYNC';
			err.RadEx__Error_Code__c = 'COURSE';
			err.RadEx__Error_Message__c = 'test_Error_Message' + i;
			err.RadEx__Class_Name__c = 'Test Class_Name';
			err.RadEx__Event_Date__c = Date.valueOf('2018-03-01');
			errList.add(err);
		}
		insert errList;

		List<RadEx__Error_Log__c> errList2 = new List<RadEx__Error_Log__c>();
		for (Integer i = 0; i < 30; i++ ) {
			RadEx__Error_Log__c err = new RadEx__Error_Log__c();
			err.RadEx__ORG__c = testAccount2.Id;
			err.RadEx__Severity__c = 'CONTENT_SYNC';
			err.RadEx__Error_Code__c = 'COURSE';
			err.RadEx__Error_Message__c = 'test_Error_Message' + i;
			err.RadEx__Class_Name__c = 'Test Class_Name';
			err.RadEx__Event_Date__c = Date.today();
			errList2.add(err);
		}
		insert errList2;

		test.startTest();

		DeleteSuncLogsBatch testBatch = new DeleteSuncLogsBatch();
		Database.executeBatch(testBatch);

		test.stopTest();
		System.assertEquals(30, [select count() FROM RadEx__Error_Log__c]);
	}

}