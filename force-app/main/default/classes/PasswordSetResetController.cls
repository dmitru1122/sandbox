public with sharing class PasswordSetResetController {
	public static final String MessageUserNotFound = 'User Not Found';

	@AuraEnabled(Cacheable=true)
	public static List<User> SearchUser(String searchKey) { 

		if(String.isBlank(searchKey) || searchKey.length() < 2) return new List<sObject>();
		String sTempSearchKey = '%' + searchKey.trim() + '%';
		return [
			SELECT Id, UserName, Email, IsActive, Name
			FROM User
			WHERE (UserName LIKE : sTempSearchKey OR Email LIKE : sTempSearchKey) AND  IsActive = TRUE
		];
	}

	@AuraEnabled
	public static void ResetPassowrd(String UserId, String CaseId) {

		if(String.isBlank(UserId)) throw new CustomException(MessageUserNotFound);

		List<User> userList = [SELECT Id FROM User WHERE Id=:UserId];
		if(userList.isEmpty()) throw new CustomException(MessageUserNotFound);
		System.resetPassword(userList[0].Id, true);

		if(String.isNotBlank(CaseId)) {
			List<Case> cases = [SELECT Id, Status FROM Case WHERE Id=:CaseId];
			if(!cases.isEmpty()) {
				cases[0].Status = 'Agent Responded';
				update cases[0];
			}
		}
	}


	@AuraEnabled
	public static void SetPassowrd(String UserId, String CaseId) {


		Integer randomNumber = Integer.valueof((Math.random() * 10000));
		String newPassword = 'Compliatric' + String.valueOf(randomNumber);

		if(String.isBlank(UserId)) throw new CustomException(MessageUserNotFound);

		List<User> userList = [SELECT Id FROM User WHERE Id=:UserId];
		if(userList.isEmpty()) throw new CustomException(MessageUserNotFound);
		//System.setPassword(userList[0].Id, 'newPassword');

		Messaging.SingleEmailMessage emailMsg =   new Messaging.SingleEmailMessage();  
		emailMsg.setTargetObjectId(userList[0].Id);

		emailMSg.saveAsActivity = false; 
		emailMsg.setSenderDisplayName('Compliatric New password');  
		emailMsg.setSubject('Compliatric New password');  
		emailMsg.setBccSender(false);  
		emailMsg.setUseSignature(false);  
		emailmsg.setPlainTextBody('Your new password: ' + newPassword);  
		Messaging.sendEmail(new Messaging.SingleEmailMessage[] { emailMsg });

		if(String.isNotBlank(CaseId)) {
			List<Case> cases = [SELECT Id, Status FROM Case WHERE Id=:CaseId];
			if(!cases.isEmpty()) {
				//cases[0].Temporary_Password__c = newPassword;
				cases[0].Status = 'Agent Responded';
				update cases[0];
			}
		}	
	}

	public class CustomException extends Exception {}
}