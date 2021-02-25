@isTest
private class ViewerSuncLogComponentControllerTest {

	@testSetup 
	static void setupTestData() {

								
		Account act = new Account(Name = 'testViewer');
	
		insert act;

		List<RadEx__Error_Log__c> logsList = new List<RadEx__Error_Log__c>();

		for(Integer i = 0; i<100;i++) {
			RadEx__Error_Log__c war = new RadEx__Error_Log__c(
				RadEx__Class_Name__c = 'className',
				RadEx__Error_Message__c = 'textMessage',
				RadEx__Severity__c = 'CONTENT_SYNC',
				RadEx__Subject__c =  NULL ,
				RadEx__OutSide__c = false,
								RadEx__ORG__c = act.Id,
								RadEx__Error_Code__c = 'PROGRAMM'
			);
			logsList.add(war);
		}

		for(Integer i = 0; i<50;i++) {
			RadEx__Error_Log__c fatal = new RadEx__Error_Log__c(
				RadEx__Class_Name__c = 'className2',
				RadEx__Error_Message__c = 'textMessage2',
				RadEx__Severity__c = 'CONTENT_SYNC',
				RadEx__Subject__c =  NULL ,
				RadEx__OutSide__c = true,
				RadEx__Event_Date__c = Date.today(),
				RadEx__ORG__c = act.Id,
				RadEx__Error_Code__c = 'POLICY'
			);
			logsList.add(fatal);
		}

		for(Integer i = 0; i<50;i++) {
			RadEx__Error_Log__c fatal = new RadEx__Error_Log__c(
				RadEx__Class_Name__c = 'className3',
				RadEx__Error_Message__c = 'textMessage3',
				RadEx__Severity__c = 'CONTENT_SYNC',
				RadEx__Subject__c =  NULL ,
				RadEx__OutSide__c = true,
				RadEx__Event_Date__c = Date.today(),
								RadEx__ORG__c = act.Id,
								RadEx__Error_Code__c = 'TEST'
			);
			logsList.add(fatal);
		}

		for(Integer i = 0; i<50;i++) {
			RadEx__Error_Log__c fatal = new RadEx__Error_Log__c(
				RadEx__Class_Name__c = 'className4',
				RadEx__Error_Message__c = 'textMessage4',
				RadEx__Severity__c = 'CONTENT_SYNC_ERROR',
				RadEx__Subject__c =  NULL ,
				RadEx__OutSide__c = true,
				RadEx__Event_Date__c = Date.today(),
								RadEx__ORG__c = act.Id,
								RadEx__Error_Code__c = 'SLIDE'
			);
			logsList.add(fatal);
		}

		for(Integer i = 0; i<10;i++) {
			RadEx__Error_Log__c fatal = new RadEx__Error_Log__c(
				RadEx__Class_Name__c = 'className5',
				RadEx__Error_Message__c = 'textMessage5',
				RadEx__Severity__c = 'CONTENT_SYNC_ERROR',
				RadEx__Subject__c =  NULL ,
				RadEx__OutSide__c = true,
				RadEx__Event_Date__c = Date.today(),
								RadEx__ORG__c = act.Id,
								RadEx__Error_Code__c = 'TEST'
			);
			logsList.add(fatal);
		}

		insert logsList;
	}

	@isTest
	static void testViewerErrorLogsController() {

		List<Account> testAccount = [SELECT Id, Name FROM Account WHERE Name ='testViewer' LIMIT 1];
		
		Test.setCurrentPage(Page.ViewerSuncLogExtention);
		ViewerSuncLogComponentController con = new ViewerSuncLogComponentController();
		con.AccountMainId = testAccount[0].Id;
		con.LimitSize = 2;
		con.isExtensionMode = false;

		Date fromDateDate = Date.today().addMonths(-3);
		Date toDateDate =  Date.today().addDays(1); 

		List<ViewerSuncLogComponentController.LogWrapper> testList = con.listLogController;


		System.assertEquals(2, con.listLogController.size());
		System.assertEquals(0, con.listLogSelected.size());
		System.assertEquals(3, con.totalRecs);
		System.assertEquals(0, con.OffsetSize);
		System.assert(!con.getnxt());
		System.assert(con.getprev());

		con.next();
		System.assert(con.getnxt());
		System.assert(!con.getprev());
		con.previous();
		con.LastPage();
		con.FirstPage();


		con.SelectedType = 'className';

		System.assertEquals(2, con.listLogSelected.size());
		System.assertEquals(100, con.totalRecsSelected);
		System.assertEquals(0, con.OffsetSizeSelected);

		System.assert(!con.getnxtSelected());
		System.assert(con.getprevSelected());

		con.nextSelected();
		System.assert(!con.getnxtSelected());
		System.assert(!con.getprevSelected());
		con.previousSelected();
		con.LastPageSelected();
		con.FirstPageSelected();

		con.clearSelected();

		System.assertEquals('', con.SelectedType);

		ApexPages.currentPage().getParameters().put('selectedfieldsuccess',  RadEx__Error_Log__c.RadEx__Class_Name__c.getDescribe().getName());
		con.doResearchSuccess();

		// TEST ERRoR LOG 

		System.assertEquals(2, con.listLogErrorSelected.size());
		System.assertEquals(0, con.OffsetSizeError);
		
		System.assertEquals(60, con.totalRecsError);
		System.assert(!con.getnxtError());
		System.assert(con.getprevError());

		con.nextError();
		System.assert(!con.getnxtError());
		System.assert(!con.getprevError());
		con.previousError();
		con.LastPageError();
		con.FirstPageError();

		con.selectedTypeSync = 'SLIDE';

		System.assertEquals(2, con.listLogErrorSelected.size());
		
		
		System.assertEquals(60, con.totalRecsError);
		System.assertEquals(0, con.OffsetSizeError);
		System.assert(!con.getnxtError());
		System.assert(con.getprevError());

		con.nextError();
		System.assert(!con.getnxtError());
		System.assert(!con.getprevError());
		con.previousError();
		con.LastPageError();
		con.FirstPageError();

		con.selectedTypeSync = 'TEST';

		System.assertEquals(2, con.listLogErrorSelected.size());
		
		
		System.assertEquals(60, con.totalRecsError);
		System.assertEquals(0, con.OffsetSizeError);
		System.assert(!con.getnxtError());
		System.assert(con.getprevError());

		con.nextError();
		System.assert(!con.getnxtError());
		System.assert(!con.getprevError());
		con.previousError();
		con.LastPageError();
		con.FirstPageError();

		ApexPages.currentPage().getParameters().put('selectedfield',  RadEx__Error_Log__c.RadEx__Class_Name__c.getDescribe().getName());
		con.doResearchError();
	}
}