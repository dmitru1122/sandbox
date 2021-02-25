@isTest
private class EmailToInvoiceTest {

	static testmethod void testEmailToInvoiceFail() {
		EmailTemplate validEmailTemplate = new EmailTemplate();
		validEmailTemplate.isActive = true;
		validEmailTemplate.Name = 'name';
		validEmailTemplate.DeveloperName = EmailToInvoice.NAME_EMAIL_TEMPLATE;
		validEmailTemplate.TemplateType = 'text';
		validEmailTemplate.FolderId = UserInfo.getUserId();
		insert validEmailTemplate;


		User user = getUser();
		insert user;

		Messaging.InboundEmail email = new Messaging.InboundEmail() ;
		Messaging.InboundEnvelope env = new Messaging.InboundEnvelope();

		Messaging.InboundEmail.BinaryAttachment testBinaryTextAttachment = new Messaging.InboundEmail.BinaryAttachment();
		testBinaryTextAttachment.body = blob.valueOf('TestBinaryAttachment');
		testBinaryTextAttachment.fileName = 'TestBinaryFileName';
		testBinaryTextAttachment.mimeTypeSubType = 'text/plain';

		Messaging.InboundEmail.TextAttachment testTextAttachment = new Messaging.InboundEmail.TextAttachment();
		testTextAttachment.body = 'TestTextAttachment';
		testTextAttachment.fileName = 'TestTextFileName.pdf';
		testTextAttachment.mimeTypeSubType = 'application/pdf';

		email.subject = 'Do Not Send Payment: salesforce.com Invoice blablabla, blablabla' ;
		email.fromname = 'FirstName LastName';
		email.plainTextBody = 'email test text body';
		email.textAttachments = new Messaging.inboundEmail.TextAttachment[] { testTextAttachment };
		email.binaryAttachments = new Messaging.inboundEmail.BinaryAttachment[] { testBinaryTextAttachment };

		Test.startTest();
			EmailToInvoice emailProcess = new EmailToInvoice();
			emailProcess.handleInboundEmail(email, env);
		Test.stopTest();

		System.assertEquals(email.plainTextBody, 'email test text body');
		System.assertEquals(email.fromname, 'FirstName LastName');
	}



	static testmethod void testEmailToInvoice() {


		Account acc = new Account(Name = 'testAcc');
		acc.SF_Invoice_Account_Name__c = 'blablabla';
		insert acc;

		Messaging.InboundEmail email = new Messaging.InboundEmail() ;
		Messaging.InboundEnvelope env = new Messaging.InboundEnvelope();

		Messaging.InboundEmail.BinaryAttachment testBinaryTextAttachment = new Messaging.InboundEmail.BinaryAttachment();
		testBinaryTextAttachment.body = blob.valueOf('TestBinaryAttachment');
		testBinaryTextAttachment.fileName = 'TestBinaryFileName';
		testBinaryTextAttachment.mimeTypeSubType = 'text/plain';

		Messaging.InboundEmail.TextAttachment testTextAttachment = new Messaging.InboundEmail.TextAttachment();
		testTextAttachment.body = 'TestTextAttachment';
		testTextAttachment.fileName = 'TestTextFileName.pdf';
		testTextAttachment.mimeTypeSubType = 'application/pdf';

		email.subject = 'Do Not Send Payment: salesforce.com Invoice blablabla, blablabla' ;
		email.fromname = 'FirstName LastName';
		email.plainTextBody = 'email test text body';
		email.textAttachments = new Messaging.inboundEmail.TextAttachment[] { testTextAttachment };
		email.binaryAttachments = new Messaging.inboundEmail.BinaryAttachment[] { testBinaryTextAttachment };

		Test.startTest();
			EmailToInvoice emailProcess = new EmailToInvoice();
			emailProcess.handleInboundEmail(email, env);
		Test.stopTest();

		System.assertEquals(email.plainTextBody, 'email test text body');
		System.assertEquals(email.fromname, 'FirstName LastName');
		System.assertEquals(1, [SELECT Id FROM Attachment WHERE ParentId =:acc.Id].size());
	}


	private static User getUser() {
		Profile platformUser = [select id from Profile where Name = 'System Administrator'];
		return  new User(
			FirstName = 'firstName',
			LastName = 'lastName',
			Email = 'bob@123.com',
			Username = 'ForOnlyTest@compliatric.com',
			ProfileId = platformUser.Id,
			Alias = 'last',
			CommunityNickname = 'last',
			TimeZoneSidKey = 'America/Chicago',
			LocaleSidKey = 'en_US',
			EmailEncodingKey = 'UTF-8',
			LanguageLocaleKey = 'en_US'
		);
	}

	static testmethod void testEmailFail() {


		Account acc = new Account(Name = 'testAcc');
		acc.SF_Invoice_Account_Name__c = 'blablabla';
		insert acc;

		Messaging.InboundEmail email = new Messaging.InboundEmail() ;
		Messaging.InboundEnvelope env = new Messaging.InboundEnvelope();

		Messaging.InboundEmail.BinaryAttachment testBinaryTextAttachment = new Messaging.InboundEmail.BinaryAttachment();
		testBinaryTextAttachment.body = blob.valueOf('TestBinaryAttachment');
		testBinaryTextAttachment.mimeTypeSubType = 'text/plain';

		Messaging.InboundEmail.TextAttachment testTextAttachment = new Messaging.InboundEmail.TextAttachment();
		testTextAttachment.body = 'TestTextAttachment';
		testTextAttachment.mimeTypeSubType = 'application/octet-stream';

		email.subject = 'Do Not Send Payment: salesforce.com Invoice blablabla, blablabla' ;
		email.fromname = 'FirstName LastName';
		email.plainTextBody = 'email test text body';
		email.textAttachments = new Messaging.inboundEmail.TextAttachment[] { testTextAttachment };
		email.binaryAttachments = new Messaging.inboundEmail.BinaryAttachment[] { testBinaryTextAttachment };

		Test.startTest();
			EmailToInvoice emailProcess = new EmailToInvoice();
			emailProcess.handleInboundEmail(email, env);
		Test.stopTest();

		System.assertEquals(0, [SELECT Id FROM Attachment WHERE ParentId =:acc.Id].size());
		//System.assertEquals(email.fromname, 'FirstName LastName');
	}

}