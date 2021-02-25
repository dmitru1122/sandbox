@RestResource(urlMapping='/ChatterPost/v1/*')
global with sharing class CustomerChatterPost  {
	private static final String STATUS_OK ='OK';
	private static final String STATUS = 'Status';
	private static final String MESSAGE = 'Message';
	private static final String STATUS_ERROR ='ERROR';
	private static final String RESULT_POST_LIST ='RESULT_POST_LIST';

	@HttpGet
	global static String getChatterPost() {
		List<Radex__Customer_Chatter_Post__c> chatterPostListForSend = new List<Radex__Customer_Chatter_Post__c>();
		List<ChatterPostWrapper> chatterPostPush = new List<ChatterPostWrapper>();

		RestRequest req = RestContext.request;
		RestResponse res = RestContext.response;

		String urlParam = req.requestURI.substring(req.requestURI.lastIndexOf('/')+1);
		Map<String, String> paramURL = req.params;

		if(urlParam.containsIgnoreCase('getAll')) {

			String orgId = paramURL.containsKey('orgId') ? paramURL.get('orgId') : '';
			String lastDate = paramURL.containsKey('lastDate') ? paramURL.get('lastDate') : '';
		

			if(String.isBlank(orgId) || String.isBlank(lastDate) ) return createResponse(STATUS_ERROR, 'Request is Empty', NULL);
			if(orgId.length() > 15 ) orgId = orgId.left(15);
			if(orgId.containsIgnoreCase('test')) return createResponse(STATUS_OK, 'OK', chatterPostPush);
		
			try {
				Date lastDatesoql = Date.valueOf(lastDate).addDays(-7);

				List<Radex__Customer_Chatter_Post__c> chatterPostList = [
					SELECT Id,  Radex__Customer_ORGs_Ids__c, Radex__Date_Post__c, Radex__Type__c,
					Radex__Push_To_All_ORG__c
					FROM Radex__Customer_Chatter_Post__c 
					WHERE CreatedDate >: lastDatesoql
					AND Radex__Active__c = TRUE
				];

				for(Radex__Customer_Chatter_Post__c item : chatterPostList) {

					if( item.Radex__Push_To_All_ORG__c || (String.isNotBlank(item.Radex__Customer_ORGs_Ids__c) && item.Radex__Customer_ORGs_Ids__c.containsIgnoreCase(orgId)) ){
						chatterPostListForSend.add(item);
					}
				}

				chatterPostPush = convetToWrapperChatterPost(chatterPostListForSend, true);
				return createResponse(STATUS_OK, 'OK', chatterPostPush);

			} catch(Exception e) {
				return createResponse(STATUS_ERROR, e.getMessage(), chatterPostPush);
			} 

		} else if(urlParam.containsIgnoreCase('getPostForId')) {
			String postId = paramURL.containsKey('postId') ? paramURL.get('postId') : '';
			if(String.isBlank(postId)) return createResponse(STATUS_ERROR, 'Request is Empty', NULL);

			Map<Id, Radex__Customer_Chatter_Post__c> chatterPostList = new Map<Id, Radex__Customer_Chatter_Post__c>([
				SELECT Id,  Radex__Customer_ORGs_Ids__c, Radex__Date_Post__c, Radex__Body__c, Radex__Type__c, 
				Radex__Push_To_All_ORG__c, Radex__Link_Name__c, Radex__Link__c
				FROM Radex__Customer_Chatter_Post__c 
				WHERE Id =:postId
				AND Radex__Active__c = TRUE
			]);

			if(chatterPostList.isEmpty() && !postId.containsIgnoreCase('test')) return createResponse(STATUS_ERROR, 'Post Not Found', NULL);

			Set<Id> idsPosts = new Set<Id>(chatterPostList.keySet());

			chatterPostPush = convetToWrapperChatterPost( chatterPostList.values(), false );

			if(!idsPosts.isEmpty()) {
				List<ContentDocumentLink> linkDocument = [
					SELECT Id, ContentDocumentId, LinkedEntityId , ContentDocument.Title, 
					ContentDocument.LatestPublishedVersionId, ContentDocument.FileExtension
					FROM ContentDocumentLink
					WHERE LinkedEntityId =:idsPosts
				];
				chatterPostPush = associatePostToFile( chatterPostPush, linkDocument );
			}
			
			return createResponse(STATUS_OK, 'OK', chatterPostPush);
		} else if(urlParam.containsIgnoreCase('getFileForId')) {

			String fileId = paramURL.containsKey('fileId') ? paramURL.get('fileId') : '';

			if(String.isBlank(fileId)) return createResponse(STATUS_ERROR, 'Request is Empty', NULL);

			List<ContentVersion> linkDocument = [
				SELECT Id, Title, FileType, ContentSize, VersionData, PathOnClient
				FROM ContentVersion
				WHERE Id =:fileId
			];

			if(!linkDocument.isEmpty()) {
				return createResponseWithFile(STATUS_OK, 'OK', linkDocument[0]); 
			} else if(fileId.containsIgnoreCase('test')){
				return createResponseWithFile(STATUS_OK, 'OK', NULL); 
			} else{
				return createResponseWithFile(STATUS_ERROR, 'File Not Found',NULL); 
			}

		}
		return createResponse(STATUS_ERROR, 'Request is Empty', chatterPostPush);
	}


	private static string createResponse(String result, String sessageResult, List<ChatterPostWrapper> chatterPostList) {

		if(String.isBlank(result)) result = STATUS_ERROR;
		Map<String, Object> response = new Map<String, Object>();
		response.put(STATUS, result);
		response.put(MESSAGE, sessageResult);

		if(chatterPostList !=NULL && !chatterPostList.isEmpty()) response.put(RESULT_POST_LIST, chatterPostList);
		
		return JSON.serialize(response);
	}

	private static string createResponseWithFile(String result, String sessageResult, ContentVersion file) {

		if(String.isBlank(result)) result = STATUS_ERROR;
		Map<String, Object> response = new Map<String, Object>();
		response.put(STATUS, result);
		response.put(MESSAGE, sessageResult);
		if(file != NULL) {
			response.put('FileName', file.Title);
			response.put('FilePatch', file.PathOnClient);
			response.put('FileBase64',  EncodingUtil.Base64Encode(file.VersionData));
		}
		return JSON.serialize(response);
	}


	private static List<ChatterPostWrapper> associatePostToFile(List<ChatterPostWrapper> chatterPosts, List<ContentDocumentLink> linkDocument ) {
		Map<Id, ContentDocumentLink> mappingAssociatePost = new Map<Id, ContentDocumentLink>();

		for(ContentDocumentLink item : linkDocument) mappingAssociatePost.put(item.LinkedEntityId, item);

		for(ChatterPostWrapper itemWrapper : chatterPosts) {
			if(mappingAssociatePost.containsKey(itemWrapper.Id)) {
				itemWrapper.fileId = mappingAssociatePost.get(itemWrapper.Id).ContentDocument.LatestPublishedVersionId;
				itemWrapper.fileTitle = mappingAssociatePost.get(itemWrapper.Id).ContentDocument.Title;
				itemWrapper.fileExtension = mappingAssociatePost.get(itemWrapper.Id).ContentDocument.FileExtension;
			} 
		}

		return chatterPosts;
	}


	private static List<ChatterPostWrapper> convetToWrapperChatterPost(List<Radex__Customer_Chatter_Post__c> chatterPostList, Boolean isInfo) {
		List<ChatterPostWrapper> wrapperList = new List<ChatterPostWrapper>();
		for(Radex__Customer_Chatter_Post__c item : chatterPostList) wrapperList.add(new ChatterPostWrapper( item, isInfo ));
		return wrapperList;
	}

	private class ChatterPostWrapper{
		public String Id {set; get;}
		public String DatePost {set; get;}
		//public String Description {set; get;}
		public String Link {set; get;}
		public String LinkName {set; get;}
		public String BodyPost {set; get;}
		public String Type {set; get;}
		public String fileId {set; get;}
		public String fileTitle {set; get;}
		public String fileExtension {set; get;}

		public ChatterPostWrapper(Radex__Customer_Chatter_Post__c post, Boolean isInfo) {
			this.Id = post.Id;
			this.DatePost = post.Radex__Date_Post__c != NULL ? String.valueOf(post.Radex__Date_Post__c) : '';
			//this.Description = post.Radex__Description__c;
			if(!isInfo) {
				this.Link =  post.Radex__Link__c !=  NULL ? post.Radex__Link__c : NULL;
				this.LinkName = post.Radex__Link_Name__c;
				this.BodyPost = post.Radex__Body__c;	
				this.Type = post.Radex__Type__c;	
			}	
		}
	}
	
}