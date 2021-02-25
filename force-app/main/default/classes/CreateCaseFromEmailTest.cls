@isTest
private class CreateCaseFromEmailTest {
	
	@isTest
	static void testSuccessCreateCaseFromEmail() {
    	Messaging.InboundEmail email = new Messaging.InboundEmail() ;
        Messaging.InboundEnvelope env    = new Messaging.InboundEnvelope();
        Account acc = new Account(Name = 'TestAccount', Org_Id__c = 'TestOrgId');
        insert acc;
        CreateCaseFromEmail createC = new CreateCaseFromEmail();

        CreateCaseFromEmail.EmailRequest request = new CreateCaseFromEmail.EmailRequest('TestManufacturer', 'Test SDS Product Name', Date.newInstance(2018, 2, 17), 'TestEmail@email.com', 'TestName', 'TestOrgId');
        email.subject = 'Create Case';
        email.plainTextBody = JSON.serialize(request);
        env.fromAddress = 'testemail@gmail.com';

        Messaging.InboundEmailResult result = createC.handleInboundEmail(email, env );
		System.assertEquals(true, result.success);
        List<Case> cases = [Select id from Case];
        System.assertEquals(1, cases.size());
    }

	@isTest
	static void testExceptionCreateCaseFromEmail() {
    	Messaging.InboundEmail email = new Messaging.InboundEmail() ;
        Messaging.InboundEnvelope env    = new Messaging.InboundEnvelope();
        email.subject = 'Create Case';
        email.plainTextBody = '{Exception}';
        env.fromAddress = 'testemail@gmail.com';
        CreateCaseFromEmail creatC = new CreateCaseFromEmail();
        Test.startTest();
        Messaging.InboundEmailResult result = creatC.handleInboundEmail(email, env );
        Test.stopTest();
		System.assertEquals(false, result.success);
    }
}