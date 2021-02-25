@isTest
private class ReferColleagueTest {


	@isTest
	static void createCase() { 

		Map<String, Object> response = new Map<String, Object>();
		response.put('type', 'ErrorNotify');
		response.put('Subject', 'Subject');
		response.put('UserName', 'UserName');
		response.put('UserId', 'UserId');
		response.put('Description', 'Description');
		response.put('recodError', 'recodError');
		response.put('orgId', '4547');

		String dataMessage = ReferColleague.getContentPost(JSON.serialize(response));
		Map<String, Object> mResult = (Map<String, Object>)  JSON.deserializeUntyped(dataMessage);
		System.assert(mResult.containsKey('RECORD_ID'));
	}


	@isTest
	static void createLead() { 

        Map<String, Object> response = new Map<String, Object>();


        Map<String,String> messageData = new Map<String,String>();

        messageData.put('ReferrerUser', 'ReferrerUser');
        messageData.put('ReferrerOrganization', 'ReferrerOrganization');
        messageData.put('ReferrerPhoneNumber', '+365748');
        messageData.put('OrganizationYouAreReferringUsTo', 'OrganizationYouAreReferringUsTo');
        messageData.put('SuggestedPersonWeContact', 'SuggestedPersonWeContact');
        messageData.put('SuggesteEmail', 'SuggesteEmail@gmail.com');
        messageData.put('SuggestePhoneNumber', '+6987322145');

		response.put('type', 'LeadRecoment');
		response.put('FirstName', 'Subject');
		response.put('LastName', 'UserName');
        response.put('UserEmail', 'UserId@gmail.com');
        
        response.put('message', JSON.serialize(messageData));
        
        String dataMessage = ReferColleague.getContentPost(JSON.serialize(response));
        Map<String, Object> mResult = (Map<String, Object>)  JSON.deserializeUntyped(dataMessage);
        System.assert(mResult.containsKey(ReferColleague.STATUS));
        System.assertEquals(ReferColleague.STATUS_OK, mResult.get(ReferColleague.STATUS));

        

	}

}