@isTest
public with sharing class ViewerSuncLogExtentionTest {
	@isTest
	public static void testViewerSuncLogExtention() {
		Account testAccount = new Account(
			Name = 'TestAcc'
		);
		insert testAccount;
		
		test.startTest();

		Account mockAccount = new Account();
		mockAccount.Id = testAccount.Id;
		PageReference pageRef = Page.ViewerSuncLogExtention;
		Test.setCurrentPage(pageRef);

		ApexPages.standardController controller = new ApexPages.standardController(mockAccount);
		ViewerSuncLogExtentionController testController = new ViewerSuncLogExtentionController(controller);

		testController.actionOnLoadPage();
		test.stopTest();

		System.assertEquals(1, [select count() from CronTrigger where CronJobDetail.Name = :DeleteSuncLogsScheduler.JOB_NAME]);
	}
}