@isTest
private class testTriggers {
	
	@isTest static void testEmail() {
		

		Case c = new Case();
        c.Subject = 'Om Test';  
        c.Status ='New';
        c.Priority = 'Medium';
        c.Origin = 'Email';
        insert c;

        //Insert emailmessage for case
        EmailMessage email = new EmailMessage();
        email.FromAddress = 'test@abc.org';
        email.Incoming = True;
        email.ToAddress= 'test@xyz.org';
        email.Subject = 'Test email';
        email.HtmlBody = 'Test email body';
        email.ParentId = c.Id; 
        insert email;

		

		System.assertNotEquals(email.Subject , NULL);
	}
}