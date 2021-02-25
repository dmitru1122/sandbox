@isTest
public class CompliatricUserManagementMock implements HttpCalloutMock {
	protected Integer code;
	protected String status;
	protected String body;
	protected Map<String, String> responseHeaders;
	protected String typePost;

	private static final Integer DEFAULT_CODE = 200;
	private static final String DEFAULT_STATUS = 'OK';
	private static final String DEFAULT_BODY = '';

	private static final String DEFAULT_STATUS_ERROR = 'ERROR';
	private static final Map<String, String> DEFAULT_HEADERS = new Map<String, String>{'Content-Type:' => 'application/json'};

	public CompliatricUserManagementMock() {
		this.code = DEFAULT_CODE;
		this.status = DEFAULT_STATUS;
		this.body = DEFAULT_BODY;
		this.responseHeaders = DEFAULT_HEADERS;
	}

	public HTTPResponse respond(HTTPRequest req) {
		HttpResponse res = new HttpResponse();
		System.assertNotEquals(res, null);
		String endpoint = req.getEndpoint();

		String sig = req.getHeader( CompliatricUserManagement.HTTP_HEADER_AUTH_SIGNATURE );
		String timeStamp = req.getHeader( CompliatricUserManagement.HTTP_HEADER_TIME_STAMP );

		System.assert( String.isNotBlank(sig) , 'Signature doesn\'t exist' );
		System.assert( String.isNotBlank(timeStamp) , 'Time stamp doesn\'t exist' );

		for (String key : this.responseHeaders.keySet()) {
			res.setHeader(key, this.responseHeaders.get(key));
		}
		
		res.setStatusCode(this.code);
		res.setStatus(this.status);


		Map<String,Object> resultAnswer = new Map<String,Object>();

		if (endpoint.containsIgnoreCase( CompliatricUserManagement.pointGetAllUsersFromOrg )) {

			System.debug( ' step org: ' + endpoint);
			

			String orgId = endpoint.substringBetween('/api/users/', '?state');

			System.debug( ' step org 2 : ' + orgId);

			if( String.isBlank(orgId) ) {
				resultAnswer.put('status', 'Error');
				resultAnswer.put('message', 'Org Not Found');
				this.body = JSON.serialize( resultAnswer );
			} else {
				System.debug( ' step 6: ');
				Set<String> allAlias = new Set<String>{'Viktoria', 'testUser'};
				List<User> users = [Select Id, Name, UserName, IsActive, Profile.UserLicense.Name, Title, Email, Profile.Name FROM User WHERE Alias =:allAlias ];
				System.assertEquals( 2, users.size(), 'Users for test not found' );
				List<Map<String,Object>> resultUserList = new List<Map<String,Object>>();
				for( User item : users ) {
					Map<String,Object> userItem = new Map<String,Object>();
					userItem.put('Name', item.Name);
					userItem.put('Id', item.Id);
					userItem.put('Username', item.UserName);
					userItem.put('IsActive', item.IsActive);
					userItem.put('Profile.UserLicense.Name', item.Profile.UserLicense.Name);
					userItem.put('IsActive', item.IsActive);
					userItem.put('Title', item.Title);
					userItem.put('Email', item.Email);
					userItem.put('Profile.Name', item.Profile.Name);
					resultUserList.add( userItem );

				}
				System.debug( ' step 7: ' + users.size());
				resultAnswer.put('status', 'Success');

				String resultJSON =  JSON.serialize(resultUserList);
				System.debug( ' step 7-1: ' + resultJSON);
				resultAnswer.put('result', resultUserList );
				System.debug( ' step 8: ');
				this.body = JSON.serialize( resultAnswer );

			}

		}

		

		res.setBody(this.body);
		return res;
	}
}