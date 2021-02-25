@isTest
public with sharing class Email2CaseSupportTest {
    @isTest
    static void testhandleInboundEmail(){
        Account acc = new Account(Name='TestAccount');
        insert acc;
        Contact con = new Contact(LastName = 'Test', Email = 'someaddress@email.com', AccountId = acc.Id);
        insert con;

        Messaging.InboundEmail email = new Messaging.InboundEmail();
        Messaging.InboundEnvelope env = new Messaging.InboundEnvelope();
        
        email.subject = 'Create Case';
        email.fromAddress = 'someaddress@email.com';
        email.toAddresses = new List<String>{'support@test.com'};
        email.plainTextBody = 'email body';
        Messaging.InboundEmail.BinaryAttachment attachment = new Messaging.InboundEmail.BinaryAttachment();
        attachment.body = blob.valueOf('my attachment text');
        attachment.fileName = 'textfile.txt';
        attachment.mimeTypeSubType = 'text/plain';

        Messaging.InboundEmail.TextAttachment textAttachment = new Messaging.InboundEmail.TextAttachment();
        textAttachment.body = 'Body';
        textAttachment.fileName = 'demoFile';

        email.binaryAttachments = new Messaging.inboundEmail.BinaryAttachment[] { attachment };
        email.textAttachments = new Messaging.inboundEmail.TextAttachment[] { textAttachment };
        
        Email2CaseSupport  testInbound = new Email2CaseSupport ();
        testInbound.handleInboundEmail(email, env);

        System.assertEquals(1, [SELECT Id FROM Case].size());
    }

    @isTest
    static void testhandleInboundEmailWithoutContact(){
        Messaging.InboundEmail email = new Messaging.InboundEmail();
        Messaging.InboundEnvelope env = new Messaging.InboundEnvelope();
        
        email.subject = 'Create Case';
        email.fromAddress = 'someaddress@email.com';
        email.toAddresses = new List<String>{'support@test.com'};
        email.plainTextBody = 'email body';
        Messaging.InboundEmail.BinaryAttachment attachment = new Messaging.InboundEmail.BinaryAttachment();
        attachment.body = blob.valueOf('my attachment text');
        attachment.fileName = 'textfile.txt';
        attachment.mimeTypeSubType = 'text/plain';

        Messaging.InboundEmail.TextAttachment textAttachment = new Messaging.InboundEmail.TextAttachment();
        textAttachment.body = 'Body';
        textAttachment.fileName = 'demoFile';

        email.binaryAttachments = new Messaging.inboundEmail.BinaryAttachment[] { attachment };
        email.textAttachments = new Messaging.inboundEmail.TextAttachment[] { textAttachment };
        email.fromName = 'Test User';
        
        Email2CaseSupport  testInbound = new Email2CaseSupport ();
        testInbound.handleInboundEmail(email, env);

        System.assertEquals(1, [SELECT Id FROM Contact].size());
    }

}