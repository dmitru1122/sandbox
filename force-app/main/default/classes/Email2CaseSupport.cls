global class Email2CaseSupport implements Messaging.InboundEmailHandler {

// 2020-03-05 (bpetrie) - removed "insertCaseComment" functions since emails can be displayed as a related list

    global Messaging.InboundEmailResult handleInboundEmail(Messaging.inboundEmail email, 
                                                           Messaging.InboundEnvelope env){

        // Create an InboundEmailResult object for returning the result of the 
        // Apex Email Service
        Messaging.InboundEmailResult result = new Messaging.InboundEmailResult();

        String myPlainText= '';

        String caseId = getCaseId(email.subject);

        // Add the email plain text into the local variable
        myPlainText = email.plainTextBody;

        if(caseId == null){ // its a new Case
            Id contactId;
            Id accountId;
            List<Account> accountList = new List<Account>();
            List<Contact> contactList = [SELECT Id, Name, Email, AccountId FROM Contact WHERE Email = :email.fromAddress];
            if(contactList.size() > 0){
                contactId = contactList[0].Id;
                accountId = contactList[0].AccountId;
            } else {
                
                // Look for similar email domain to match up account
                String[] emailParts = email.fromAddress.split('@');
                String emailDomain = emailParts[1];
                String emailDomainSearch = '%' + emailDomain;
                System.debug('##### Email Domain: ' + emailDomain);
                String accountIdMatch = null;
                
                List<AggregateResult> contactsEmailMatch = [SELECT AccountId, COUNT(Id) Qty FROM Contact WHERE Email LIKE :emailDomainSearch GROUP BY AccountId ORDER BY COUNT(Id) DESC];
                
                if(contactsEmailMatch.size() > 0) {
                    accountIdMatch = (String)contactsEmailMatch[0].get('AccountId');
                }
                
                //create new contact
                Id contactRecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName()
                      .get('Customer').getRecordTypeId();
                
                String fullName = email.fromName;
                String firstName = '';
                String lastName = '';
                if(fullName != null && fullName.contains(' ') && fullName.split(' ').size() > 1){
                    firstName = fullName.split(' ')[0];
                    lastName = fullName.split(' ')[1];
                } else if (fullName.contains(',')) {
                    firstName = fullName.split(',')[1];
                    lastName = fullName.split(',')[0];
                }                
                else {
                    lastName = email.fromName;
                }
                Contact contact = new Contact(
                    FirstName = firstName,
                    LastName = lastName,
                    Email = email.fromAddress,
                    RecordTypeId = contactRecordTypeId,
                    AccountId = accountIdMatch
                );
                insert contact;
                contactId = contact.Id;
            }

            Case newCase = new Case(Description =  myPlainText,
                                    Priority = 'Normal',
                                    Status = 'New',
                                    Subject = email.subject,
                                    Origin = 'Email',
                                    ContactId = contactId,
                                    AccountId = accountId);
            insert newCase;

            insertAttachments(email, newCase.Id);
            insertEmailMessage(email, newCase.Id);
            //insertCaseComment(email, newCase.Id); // Commented out on 2020/03/05
        } else {
            insertAttachments(email, caseId);
            insertEmailMessage(email, caseId);
            //insertCaseComment(email, caseId); // Commented out on 2020/03/05
        }
    
        // Set the result to true. No need to send an email back to the user
        // with an error message
        result.success = true;
        
        // Return the result for the Apex Email Service
        return result;
    }
    
    //Utility method to get caseId from subject
    private String getCaseId(String subject) {
        String caseId;
        // Get email thread ID
        String emailThreadId = subject.substringBetween('ref:', ':ref');
        String caseNumber = subject.substringBetween('Compliatric Case # ', ':');
        // Call Apex method to retrieve case ID from email thread ID
        if(emailThreadId != null){
            caseId = Cases.getCaseIdFromEmailThreadId(emailThreadId);
        } else if(caseNumber != null){
            List<Case> caseList = [SELECT Id FROM Case WHERE CaseNumber = :caseNumber];
            if(!caseList.isEmpty()){
                caseId = caseList[0].Id;
            }
        }
        return caseId;
    }

    private void insertAttachments(Messaging.inboundEmail email, String parentId){
        List<Attachment> attachList = new List<Attachment>();
        if(email.binaryAttachments != null && email.binaryAttachments.size() > 0){
            for(Integer i = 0; i < email.binaryAttachments.size(); i++){
                Attachment attach = new Attachment();
                attach.Name = email.binaryAttachments[i].fileName;
                attach.body = email.binaryAttachments[i].body;
                attach.parentId = parentId;
                attachList.add(attach);
            }
        }

        if(email.textAttachments != null && email.textAttachments.size() > 0){
            for(Integer i = 0; i < email.textAttachments.size(); i++){
                Attachment attach = new Attachment();
                attach.Name = email.textAttachments[i].fileName;
                attach.body = Blob.valueOf(email.textAttachments[i].body);
                attach.parentId = parentId;
                attachList.add(attach);
            }
        }

        if(!attachList.isEmpty()){
            insert attachList;
        }
    }

    private void insertEmailMessage(Messaging.inboundEmail email, String caseId){
        EmailMessage newEmail = new EmailMessage(
            FromAddress = email.fromAddress,
            FromName = email.fromName,
            ToAddress = email.toAddresses[0],
            Subject = email.subject,
            TextBody = email.plainTextBody,
            HtmlBody = email.htmlBody,
            ParentId = Id.valueOf(caseId),
            Status = '0',
            MessageDate = system.now(),
            Incoming = true
        );
        insert newEmail;
        insertAttachments(email, newEmail.Id);
    }

    /*
    private void insertCaseComment(Messaging.inboundEmail email, String caseId){
        CaseComment comment = new CaseComment(
            IsPublished = true,
            ParentId    = caseId,
            CommentBody = email.plainTextBody
        );
        insert comment;
    }
	*/
}