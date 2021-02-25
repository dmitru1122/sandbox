@RestResource(urlMapping='/Logger/v1/*')
global with sharing class LoggerRecipient {
	private static final String STATUS_OK ='OK';
	private static final String STATUS = 'Status';
	private static final String MESSAGE = 'Message';
	private static final String STATUS_ERROR ='ERROR';

	@HttpPost
	global static String setLogList(String logsArray) {
		
		if(String.isBlank(logsArray)) return createResponse(STATUS_OK, 'Request is Empty');
		
		try { 

			Set<String> orgIdKey = new Set<String>();

			List<RadEx.ExternalLogWrapper> logs =  (List<RadEx.ExternalLogWrapper>)JSON.deserialize(logsArray, List<RadEx.ExternalLogWrapper>.class);
		
			List<Radex__Error_Log__c> logsCustom = new List<Radex__Error_Log__c>();

			Set<String> existExternalIds = checkExistExternalIds( logs );

			for(RadEx.ExternalLogWrapper item : logs) {
				if(String.isNotBlank(item.ORG_Id)) orgIdKey.add(item.ORG_Id.left(15));
				if((String.isNotBlank(item.externalId) && !existExternalIds.contains(item.externalId) && !item.externalId.equals('test_externalId')) || String.isBlank(item.externalId) )  {
					logsCustom.add(item.getLogSobject());
				}
			} 
			
			List<Account> acList = [SELECT Id, Name, Org_Id__c FROM Account WHERE Org_Id__c =: orgIdKey];

			Map<String, Id> mappingAccount = new Map<String, Id>();

			for(Account acc : acList) mappingAccount.put(acc.Org_Id__c, acc.Id);

			for(Radex__Error_Log__c itemLog : logsCustom) {
				if(String.isNotBlank(itemLog.Radex__Help_Desk_Link__c)) {

					if(mappingAccount.containsKey( itemLog.Radex__Help_Desk_Link__c.left(15))) {
						itemLog.Radex__ORG__c = mappingAccount.get( itemLog.Radex__Help_Desk_Link__c.left(15) );
					}
				}
			}

			insert logsCustom;


			return createResponse(STATUS_OK, 'Data Updated');
		} catch (Exception e) {

			return createResponse(STATUS_ERROR, e.getMessage());
		}
	} 

	private static string createResponse(String result, String sessageResult) {

		if(String.isBlank(result)) result = STATUS_ERROR;
		Map<String, String> response = new Map<String, String>();
		response.put(STATUS, result);
		response.put(MESSAGE, sessageResult);
		return JSON.serialize(response);
	}

	private static Set<String> checkExistExternalIds(List<RadEx.ExternalLogWrapper> logs) {
		Set<String> externalIds = new Set<String>();
		Set<String> existExternalIds = new Set<String>();

		for(RadEx.ExternalLogWrapper item : logs) {
			if (String.isNotBlank(item.externalId)) externalIds.add(item.externalId);
		}

		List<Radex__Error_Log__c> existLogs = [
			SELECT ID, Radex__External_Id__c
			FROM Radex__Error_Log__c
			WHERE Radex__External_Id__c =: externalIds
		];

		for(Radex__Error_Log__c item : existLogs) {
			if(String.isNotBlank(item.Radex__External_Id__c)) existExternalIds.add(item.Radex__External_Id__c);
		}
		return existExternalIds;
	}

}