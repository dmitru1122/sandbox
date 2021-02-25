@RestResource(urlMapping='/Notify/*')
global with sharing class ReferColleague {
	public static final String STATUS_OK ='OK';
	public static final String STATUS = 'StatusInfo';
	private static final String MESSAGE = 'MessageInfo';
	private static final String STATUS_ERROR ='ERROR';
	
	@HttpPost
	global static String getContentPost(String dataMessage) {

		Map<String, Object> response = new Map<String, Object>();

		try {
			Map<String, Object> mResult = (Map<String, Object>)  JSON.deserializeUntyped(dataMessage);

			if(mResult.containsKey('type')) {

				

				if(mResult.get('type') == 'ErrorNotify' && mResult.containsKey('orgId')) {

					String SubjectData = mResult.containsKey('Subject') ? String.valueof( mResult.get('Subject'))  : '';
					String UserName = mResult.containsKey('UserName') ? String.valueof( mResult.get('UserName'))  : '';
					String UserId = mResult.containsKey('UserId') ? String.valueof( mResult.get('UserId'))  : '';
					String DescriptionData = mResult.containsKey('Description') ? String.valueof( mResult.get('Description') ) : '';
					String RecordErrorId = mResult.containsKey('recodError') ? String.valueof( mResult.get('recodError') ) : '';

					String shortId =   String.valueof( mResult.get('orgId') ).left(15) + '%';

					List<Account> acclist = [
						SELECT Id, RecordTypeId, RecordType.DeveloperName
						FROM Account
						WHERE Org_Id__c LIKE :shortId 
						AND RadEx__Inactive__c = false
						LIMIT 1
					];

					Case cse = new Case(
						Subject = EncodingUtil.urlDecode(SubjectData,  'UTF-8'),
						Description = EncodingUtil.urlDecode(DescriptionData,  'UTF-8'),
						External_Org_Id__c = String.valueof( mResult.get('orgId')),
						External_User_Id__c = UserName,
						External_User_Name__c = UserId,
						Record_Error_Id__c = RecordErrorId

					);
					if(!acclist.isEmpty()) cse.AccountId = acclist[0].Id;
					insert cse;
					response.put('RECORD_ID', cse.Id);
					response.put(STATUS, 'OK');
					
				} else if(mResult.get('type') == 'LeadRecoment' && mResult.containsKey('message') ) {

					String message = mResult.containsKey('message') ? String.valueof( mResult.get('message'))  : '';
					String FirstName = mResult.containsKey('FirstName') ? String.valueof( mResult.get('FirstName'))  : '';
					String LastName = mResult.containsKey('LastName') ? String.valueof( mResult.get('LastName'))  : '';
					String UserEmail = mResult.containsKey('UserEmail') ? String.valueof( mResult.get('UserEmail'))  : '';

					Map<String,String> messageData = (Map<String,String>) JSON.deserialize(message, Map<String,String>.class);


					String ReferrerOrganization = messageData.containsKey('ReferrerOrganization') ? String.valueof( messageData.get('ReferrerOrganization'))  : '';

					String ReferrerUser = messageData.containsKey('ReferrerUser') ? String.valueof( messageData.get('ReferrerUser'))  : '';
					String ReferrerPhoneNumber = messageData.containsKey('ReferrerPhoneNumber') ? String.valueof( messageData.get('ReferrerPhoneNumber'))  : '';
					String OrganizationYouAreReferringUsTo = messageData.containsKey('OrganizationYouAreReferringUsTo') ? String.valueof( messageData.get('OrganizationYouAreReferringUsTo'))  : '';
					String SuggestedPersonWeContact = messageData.containsKey('SuggestedPersonWeContact') ? String.valueof( messageData.get('SuggestedPersonWeContact'))  : '';
					String SuggesteEmail = messageData.containsKey('SuggesteEmail') ? String.valueof( messageData.get('SuggesteEmail'))  : '';
					String SuggestePhoneNumber = messageData.containsKey('UserEmail') ? String.valueof( messageData.get('SuggestePhoneNumber'))  : '';
					

					if(FirstName.length() > Lead.FirstName.getDescribe().getLength())  FirstName.left(Lead.FirstName.getDescribe().getLength());
					if(LastName.length() > Lead.LastName.getDescribe().getLength())  LastName.left(Lead.LastName.getDescribe().getLength());

					if(ReferrerUser.length() > Lead.Referrer_User_Full_Name__c.getDescribe().getLength())  ReferrerUser.left(Lead.Referrer_User_Full_Name__c.getDescribe().getLength());
					if(ReferrerOrganization.length() > Lead.Referrer_s_Organization__c.getDescribe().getLength())  ReferrerOrganization.left(Lead.Referrer_s_Organization__c.getDescribe().getLength());

					
					if(ReferrerPhoneNumber.length() > Lead.Referrer_Phone_Number__c.getDescribe().getLength())  ReferrerPhoneNumber.left(Lead.Referrer_Phone_Number__c.getDescribe().getLength());
					if(OrganizationYouAreReferringUsTo.length() > Lead.Referrer_Organization_you_are_referring__c.getDescribe().getLength())  OrganizationYouAreReferringUsTo.left(Lead.Referrer_Organization_you_are_referring__c.getDescribe().getLength());
					if(SuggestedPersonWeContact.length() > Lead.Referrer_Suggested_Person_we_Contact__c.getDescribe().getLength())  SuggestedPersonWeContact.left(Lead.Referrer_Suggested_Person_we_Contact__c.getDescribe().getLength());
					
					if(SuggestePhoneNumber.length() > Lead.Referrer_Suggeste_Phone_Number__c.getDescribe().getLength())  SuggestePhoneNumber.left(Lead.Referrer_Suggeste_Phone_Number__c.getDescribe().getLength());

					Lead newLead = new Lead(
						Status = 'Open',
						FirstName = FirstName,
						LastName = LastName,
						Company = ReferrerOrganization,
						Referrer_User_Name__c = FirstName + ' ' + LastName,
						Referrer_User_Email__c = UserEmail,
						Referrer_User_Full_Name__c = ReferrerUser, 
						Referrer_s_Organization__c = ReferrerOrganization,
						Referrer_Phone_Number__c = ReferrerPhoneNumber,
						Referrer_Organization_you_are_referring__c = OrganizationYouAreReferringUsTo,
						Referrer_Suggested_Person_we_Contact__c = SuggestedPersonWeContact,
						Referrer_Email__c = SuggesteEmail,
						Referrer_Suggeste_Phone_Number__c = SuggestePhoneNumber
					);

					insert newLead;

					response.put(STATUS, 'OK');
				}
			}
	
		} catch(Exception e) { response.put(STATUS, STATUS_ERROR);	response.put(MESSAGE, e.getMessage() + ' ' + e.getLineNumber()); 	}
		return JSON.serialize(response);
	}
}