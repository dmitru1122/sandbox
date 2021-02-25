public inherited sharing class CompliatricUserManagement {
	private static final String SIGNATURE_KEY = 'gl4k5j7kj45h7l-547kl6j54-4m7lk5-457845mkjnlk';
	public static final String HTTP_HEADER_CONTENT_TYPE = 'Content-Type';
	public static final String HTTP_HEADER_AUTH_SIGNATURE = 'auth-signature';
	public static final String HTTP_HEADER_TIME_STAMP = 'timestamp';
	public static final String STATUS_OK ='OK';
	public static final String RESULT_REQUEST ='RESULT';
	public static final String STATUS = 'Status'; 
	public static final String MESSAGE = 'Message';
	public static final String STATUS_ERROR ='ERROR';

	private static final String endpointHerokuUsers { get {
		return (CompliatricCRMSettings__c.getValues('UserManagement.Endpoint') != NULL ? CompliatricCRMSettings__c.getValues('UserManagement.Endpoint').Value__c : '');
	}}
	
	public static final String pointGetAllUsersFromOrg { get { return '/api/users/'; }}

	public static Map<String,Object> getAllUsersFromOrg( String orgId , AuthorizationDetails__c detail) {
		Map<String,Object> result = new Map<String,Object>();

		Datetime x =  Datetime.now();
		String timeStamp = String.valueOf( x.getTime() ) ; 
		String EndpointName = 'getusers';

		String endpointHeroku = endpointHerokuUsers;
		if( String.isBlank( orgId ) ) return result;
		if( String.isBlank(endpointHeroku) ) { result.put(STATUS, STATUS_ERROR); result.put(MESSAGE, 'endPoint Heroku empty'); return result; }
		if( String.isBlank(detail.InstanceURL__c) ) { result.put(STATUS, STATUS_ERROR); result.put(MESSAGE, 'InstanceURL empty'); return result; }
		if( String.isBlank( detail.RefreshToken__c) ) { result.put(STATUS, STATUS_ERROR); result.put(MESSAGE, 'RefreshToken empty'); return result; }

		StateWrapper stateInstance = new StateWrapper( detail.RefreshToken__c, detail.InstanceURL__c );

		String EndpointParam = endpointHeroku + pointGetAllUsersFromOrg +  orgId + '?state=' + EncodingUtil.Base64Encode(Blob.valueOf( JSON.serialize(stateInstance) ));

		Http http = new Http();
		HttpRequest request = new HttpRequest();
		HttpResponse httpResponse;
		request.setTimeout(120 * 1000);
		request.setMethod('GET');
		request.setHeader(HTTP_HEADER_CONTENT_TYPE, 'application/x-www-form-urlencoded');
		request.setHeader(HTTP_HEADER_TIME_STAMP,  String.valueOf( timeStamp ));
		request.setHeader(HTTP_HEADER_AUTH_SIGNATURE,  getSignature(orgId, EndpointName, timeStamp) );
		request.setEndpoint(EndpointParam );

		//System.debug( 'EndpointParam ' + EndpointParam );
		try {
			httpResponse = http.send(request);
			String response = httpResponse.getBody();

		//	System.debug( 'response ' +  response );

			Map<String, Object> deserializeResult = (Map<String, Object>) JSON.deserializeUntyped( response );
			Boolean isSuccess = false;

			if( deserializeResult.containsKey('status') ) {
				String statusResult =  (String) deserializeResult.get('status');
				isSuccess = statusResult.equalsIgnoreCase('Success');
			}
			
			if( isSuccess ) {
				result.put(STATUS, STATUS_OK);

			//	System.debug('tttt ' + deserializeResult.get('result') );

				result.put(RESULT_REQUEST, deserializeResult.containsKey('result') ? (List<Object>) deserializeResult.get('result') : new List<Object>() );


			} else {
				System.debug( ' step Cl 1: ');
				result.put( STATUS, STATUS_ERROR);
				String ErrorMessage = deserializeResult.containsKey('message') ? (String) deserializeResult.get('message') : 'Empty message';
				System.debug( ' step Cl 2: ');
				result.put( MESSAGE, ErrorMessage );
				System.debug( ' step Cl 3: ');
			}
		} catch (Exception e) {
			System.debug('Compliatric_Error ' + e.getMessage() + ' ' +  e.getLineNumber());
			result.put(STATUS, STATUS_ERROR); result.put(MESSAGE, e.getMessage() + ' Z ' +  e.getLineNumber()); return result;
		}
		return result;
	}

	private static String getSignature(String orgId, String endpoint, String timeStamp) {
		List<String> argsSignature = new List<String>();
		argsSignature.add(orgId);
		argsSignature.add(endpoint);
		argsSignature.add(timeStamp);
		return createSignature(argsSignature, SIGNATURE_KEY);
	}
  
	public static String createSignature(List<String> args, String key) {

		String stringToSign = '';
		String signature = '';
		String signKey = key;

		stringToSign = String.join(args, '-');

		String companyKey = (CompliatricCRMSettings__c.getValues('UserManagement.SignatureKey') != NULL ? CompliatricCRMSettings__c.getValues('UserManagement.SignatureKey').Value__c : '');
		if( String.isNotBlank( companyKey )) signKey = companyKey;
		if( String.isBlank( signKey )) return '';
		
		Blob sig = Crypto.generateMac('HmacSHA1', Blob.valueOf(stringToSign), Blob.valueOf(signKey));
		signature = EncodingUtil.base64Encode(sig);
		return signature;
	}


	private class StateWrapper {
		public String refreshToken { get; private set; }
		public String instanceUrl { get; private set; }
		public Boolean isSandbox { get; set; }

		public StateWrapper(String refreshToken, String instanceUrl) {
			this.refreshToken = refreshToken;
			this.instanceUrl = instanceUrl;
			this.isSandbox = false;
		}
	}

}