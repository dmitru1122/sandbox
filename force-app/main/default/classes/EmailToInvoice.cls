global class EmailToInvoice implements Messaging.InboundEmailHandler {
	public static final String APPLICATION_PDF = 'application/pdf';
	public static final String FILE_TYPE_ATTACHMENT = 'pdf';
	public static final String ACCOUNT_NAME = 'Account Name:';
	public static final String ACCOUNT_NUMBER = 'Account Number:';
	public static final String CONTACT_NUMBER = 'Contract Number:';
	public static final String NAME_EMAIL_TEMPLATE = 'Notice_of_Failure_To_Attach_Invoice';
	global Messaging.InboundEmailResult handleInboundEmail(Messaging.inboundEmail email, Messaging.InboundEnvelope env) {

		Messaging.InboundEmailResult result = new Messaging.InboundEmailResult();  
		try {
			List<Attachment> attachments = new List<Attachment>();

			if(email.textAttachments != null) {
				for (Messaging.Inboundemail.TextAttachment textAttachment : email.textAttachments) {
					String fileName = getTypeFile(textAttachment.fileName);
					Attachment attachment = new Attachment (
						Name = textAttachment.fileName,
						Body = Blob.valueOf(textAttachment.body)
					);

					if (textAttachment.mimeTypeSubType == APPLICATION_PDF || fileName.containsIgnoreCase(FILE_TYPE_ATTACHMENT)) {
						attachments.add(attachment);
					}
				}
			}

			if(email.binaryAttachments != null) {
				for (Messaging.Inboundemail.BinaryAttachment binaryAttachment : email.binaryAttachments) {
					String fileName = getTypeFile(binaryAttachment.fileName);
					Attachment attachment = new Attachment (
						Name = binaryAttachment.fileName,
						Body = binaryAttachment.body
					);
					if (binaryAttachment.mimeTypeSubType == APPLICATION_PDF || fileName.containsIgnoreCase(FILE_TYPE_ATTACHMENT)) {
						attachments.add(attachment);
					}

				}
			}

			String myPlainText = email.plainTextBody;
			String accountNameFromBody;
			String accountNumberFromBody;


			if (String.isNotBlank(myPlainText) && myPlainText.containsIgnoreCase(ACCOUNT_NAME) && myPlainText.containsIgnoreCase(ACCOUNT_NUMBER)) {
				accountNameFromBody = myPlainText.substringBetween(ACCOUNT_NAME, ACCOUNT_NUMBER).trim();
				accountNumberFromBody = myPlainText.substringBetween(ACCOUNT_NUMBER, CONTACT_NUMBER).trim();
			}

			if (attachments.size() > 0 && String.isNotBlank(email.subject)) {
				String subjectEmail = email.subject;
				subjectEmail = subjectEmail.SubstringAfterLast (',').trim();

				if (String.isNotBlank(subjectEmail)) {
					String searchAccount = String.escapeSingleQuotes(subjectEmail);
					List<Account> accountsList = [SELECT Id	FROM Account WHERE SF_Invoice_Account_Name__c =: searchAccount ];	   

					if (accountsList.isEmpty() && String.isNotBlank(accountNameFromBody)) {	accountsList = [SELECT Id FROM Account WHERE SF_Invoice_Account_Name__c =: accountNameFromBody]; }

					if (accountsList.isEmpty() && String.isNotBlank(accountNumberFromBody)) { accountsList = [SELECT Id FROM Account WHERE SFDC_ACCT__c =: accountNumberFromBody];	}
				   
					if (!accountsList.isEmpty()) {
						attachmentInsert(accountsList[0].Id, attachments);
					} else {
						List<EmailTemplate> eTemplateList = [SELECT Id FROM EmailTemplate WHERE IsActive = true	AND DeveloperName =:NAME_EMAIL_TEMPLATE LIMIT 1 ];

						List<User> userList =  [SELECT Id FROM User WHERE IsActive = true AND (Username ='dmonaghan@compliatric.com' OR Username ='ForOnlyTest@compliatric.com') LIMIT 1];

						String  subjectLetter = 'Failure To Attach Invoice; Subject email: ';
						if (String.isNotBlank(email.subject)) {
							subjectLetter += email.subject;
						}

						if (!eTemplateList.isEmpty() && !userList.isEmpty()) {
							List<Messaging.SingleEmailMessage> mailsList = new List<Messaging.SingleEmailMessage>();
							Messaging.SingleEmailMessage msg = new Messaging.SingleEmailMessage();
							msg.setTemplateId(eTemplateList[0].Id);
							msg.setTargetObjectId(userList[0].Id);
							msg.setCcAddresses(new List<String>{'compliatricap@compliatric.com'});
							msg.setSaveAsActivity(false);
							msg.setSubject(subjectLetter);
							mailsList.add(msg);
							if (!Test.isRunningTest()) {
								Messaging.sendEmail(mailsList, false);
							}
						}
					}
				}
			}
			result.success = true;
		} catch(Exception e){
			result.success = false;
		}
		return result;
	}

	private void attachmentInsert(Id accountDestnationIs, List<Attachment> attList) {
		for (Attachment att : attList) {
			att.ParentId = accountDestnationIs;
		}
		insert attList;
	}

	private String getTypeFile(String nameFile) {
		if (nameFile == NULL || String.isBlank(nameFile)) {
			return '';
		}
		return  nameFile.substringAfterLast('.');
	}
}