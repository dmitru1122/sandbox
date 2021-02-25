@RestResource(urlMapping='/wpc/*')
global with sharing class UploadWPC  {
	private static final String STATUS_OK ='OK';
	private static final String STATUS = 'StatusInfo';
	private static final String MESSAGE = 'MessageInfo';
	private static final String STATUS_ERROR ='ERROR';

	private static Set<Id> availableAccountRecordTypeIds {
		get {
			return new Set<Id>{
				Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Compliatric_Customer').getRecordTypeId(),
				Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Compliatric_Start_up_Customer').getRecordTypeId()
			};
	}} 

	@HttpGet
	global static String getContent() {
		// only for File request

		RestRequest req = RestContext.request;
		RestResponse res = RestContext.response;
		String urlParam = req.requestURI;
		Map<String, String> paramURL = req.params;

		if(urlParam.containsIgnoreCase('v1/getIdsNewObjectsWPC')) { 
			// deprecated
			Map<String, Object> response = new Map<String, Object>();
			response.put(STATUS, STATUS_ERROR);
			response.put(MESSAGE, 'Deprecated patch');
			return JSON.serialize(response);

		} else if(urlParam.containsIgnoreCase('v1/getFileForId')) {
			
			Map<String, Object> response = new Map<String, Object>();

			String fileId = paramURL.containsKey('fileId') ? paramURL.get('fileId') : '';

			if(String.isBlank(fileId)) {
				response.put(STATUS, STATUS_ERROR);
				response.put(MESSAGE, 'Request is Empty');
				return JSON.serialize(response);
			}

			String resWr = RadEx.DownloadWPCHelper.getFileCRMJSON(fileId);
			return	resWr;

		} else if(urlParam.containsIgnoreCase('v1/getListObject')) {
			// deprecated
			Map<String, Object> response = new Map<String, Object>();
			response.put(STATUS, STATUS_ERROR);
			response.put(MESSAGE, 'Deprecated patch');
			return JSON.serialize(response);
		} 
		return '';
	}

	@HttpPost
	global static String getContentPost(String orgId, String existIds, String Ids, String typeRequest, String requestVersion, String contentType) {

		if(String.isBlank(typeRequest)) return '';

		Map<String, Object> response = new Map<String, Object>();
		// here you can pull out the version (v1/v2) and branch out

		if(typeRequest.containsIgnoreCase('getIdsNewObjectsWPC')) {

			Map<String, String> paramAdditional = new Map<String, String>();

			if(String.isNotBlank(requestVersion)) paramAdditional.put('VersionPackage', requestVersion);
			if(String.isNotBlank(contentType)) paramAdditional.put('contentType', contentType);
		
			Map<String, Datetime> existObjectIdentifier = new Map<String, Datetime>();
			String existSlideIdsString = String.isNotBlank(existIds) ? EncodingUtil.urlDecode(existIds, 'UTF-8')  : '';

			try {
				if(String.isNotBlank(existSlideIdsString)) {

					List<RadEx.DownloadWPCHelper.ObjectIdentifier> existSlideIds =  (List<RadEx.DownloadWPCHelper.ObjectIdentifier>) JSON.deserialize(existSlideIdsString, List<RadEx.DownloadWPCHelper.ObjectIdentifier>.class);
					for(RadEx.DownloadWPCHelper.ObjectIdentifier itemId : existSlideIds) {
						try {
							if(String.isNotBlank(itemId.IdObject)) {
								Id objectId = Id.valueOf(itemId.IdObject);
								itemId.convertDateTime();
								existObjectIdentifier.put(objectId, itemId.DateLastUpdateConverted);
							}
						} catch(Exception e) { }
					}
				}
				if(String.isNotBlank(orgId)) response = getNewObjectAndFileIdsFiltred(orgId, existObjectIdentifier, paramAdditional);

				response.put(STATUS, 'OK');

			} catch(Exception e) { response.put(STATUS, STATUS_ERROR); response.put(MESSAGE, e.getMessage()); }
			
			return JSON.serialize(response);

		} else if(typeRequest.containsIgnoreCase('getListObject')) {
		
			if(String.isBlank(Ids)) return '';

			try {
				Set<String> slideIds = (Set<String>) JSON.deserializeStrict(Ids, Set<String>.class);
				String resWr = RadEx.DownloadWPCHelper.getSlideCRMJSON(slideIds);
				return	resWr;
			} catch (Exception e) {	response.put(STATUS, STATUS_ERROR);	response.put(MESSAGE, e.getMessage() + ' ' + e.getLineNumber()); }

			return JSON.serialize(response);
		} 

		return '';
	}


	private static Map<String, Object>  getNewObjectAndFileIdsFiltred(String orgId, Map<String, Datetime> existObjectIdentifier, Map<String, String> paramAdditional) {

		Map<String, Object> result = new Map<String, Object>();

		String shortId = orgId.left(15) + '%';

		List<Account> acclist = [
			SELECT Id, Compliatric_Customer_Type__c, RecordTypeId, RecordType.DeveloperName
			FROM Account
			WHERE Org_Id__c LIKE :shortId 
			AND RadEx__Inactive__c = false
			AND RecordTypeId=: availableAccountRecordTypeIds
			LIMIT 1
		];

		if(!acclist.isEmpty() ) {
			List<String> typesCustomer = new List<String>();
			if( String.isNotBlank(acclist[0].Compliatric_Customer_Type__c)) {
				String typeCustomerString = acclist[0].Compliatric_Customer_Type__c;
				typesCustomer = typeCustomerString.split(';');
			}	
			result = RadEx.DownloadWPCHelper.getNewObjectAndFileIdsExistCRM(existObjectIdentifier, typesCustomer, paramAdditional);
		}
		return result;
	}

}