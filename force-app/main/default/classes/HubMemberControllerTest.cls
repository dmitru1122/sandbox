@isTest
public with sharing class HubMemberControllerTest {

    @TestSetup
    static void setup(){
        AuthorizationDetails__c authDetails = new AuthorizationDetails__c();
        authDetails.Name = 'test';
        authDetails.AccessToken__c = 'skjdfsdilfid';
        authDetails.RefreshToken__c = 'ashdsahhdksauds';
        authDetails.InstanceURL__c = 'login.salesforce.com';
        authDetails.Is_Expired__c = false;
        insert authDetails;

        Credentials__c creds = new Credentials__c();
        creds.Consumer_Key_Auto__c = 'test';
        creds.Redirect_URL_Hub__c = 'test';
        creds.Consumer_Secret_Auto__c = 'test';
        creds.Instance_URL_Hub__c = 'test';
        creds.Redirect_URL_Auto__c = 'test';
        insert creds;
    }

    @isTest
    public static void getHubMembersListTest(){
        List<Object> objList = HubMemberController.getHubMembersList();
        System.assertNotEquals(objList, null);
    }
    
    @isTest
    public static void getAuthListTest(){
        List<AuthorizationDetails__c> authDetails = HubMemberController.getAuthList();

        System.assertNotEquals(authDetails.size(), 0);
    }

    @isTest
    public static void getDataToAuthTest(){
        String dataToAuth = HubMemberController.getDataToAuth();

        System.assertNotEquals(dataToAuth.length(), 0);
    }

    @isTest
    public static void getTokensTest(){
        Test.setMock(HttpCalloutMock.class, new HubMemberSendRequestMock());
        Test.setMock(HttpCalloutMock.class, new HubMemberSendRequestWithTokenMock());

        Test.startTest();
        String url = HubMemberController.getTokens('testCode');
        Test.stopTest();
    }

    @isTest
    public static void getHistoryTest(){
        Test.setMock(HttpCalloutMock.class, new HubMemberSendRequestMockHistory());

        Test.startTest();
        String url = HubMemberController.getHistory('00D36000001FqOlEAK');
        Test.stopTest();
    }

    @isTest
    public static void runDeployTest(){
        Test.setMock(HttpCalloutMock.class, new HubMemberSendRequestMock());

        Test.startTest();
        String url = HubMemberController.runDeploy('{"source":"test"}');
        Test.stopTest();
    }

    @isTest
    public static void getStatusTest(){
        Test.setMock(HttpCalloutMock.class, new HubMemberSendRequestMock());

        Test.startTest();
        String url = HubMemberController.getStatus();
        Test.stopTest();
    }

    @isTest
    public static void openInBrowserTest(){
        Test.setMock(HttpCalloutMock.class, new HubMemberSendRequestRefreshToken());

        Test.startTest();
        String url = HubMemberController.openInBrowser('test');
        Test.stopTest();
    }

    @isTest
    public static void isProdOrgTest(){
        Boolean isProd = ![SELECT Id, isSandbox FROM Organization LIMIT 1].isSandbox;
        Boolean isProdTest = HubMemberController.isProdOrg();

        System.assertEquals(isProd, isProdTest);
    }

    @isTest
    public static void getTokenResultTest(){
        HubMemberController.UpdateTokenResult updateResult = HubMemberController.getTokenResult('test', true, 'accessToken', 'refreshToken', 'testUrl');

        System.assertEquals(updateResult.tokenUpdate, true);
        System.assertEquals(updateResult.message, 'test');
    }

    @isTest
    public static void updateAuthDataTest(){
        AuthorizationDetails__c authDetails = [SELECT Name, AccessToken__c, RefreshToken__c FROM AuthorizationDetails__c].get(0);

        HubMemberController.updateAuthData('test', 'testAtoken', 'testRtoken', 'testUrl');

        AuthorizationDetails__c authDetails2 = [SELECT Name, AccessToken__c, RefreshToken__c FROM AuthorizationDetails__c].get(0);

        System.assertEquals(authDetails.Name, authDetails2.Name);

        System.assertNotEquals(authDetails.AccessToken__c, authDetails2.AccessToken__c);
        System.assertNotEquals(authDetails.RefreshToken__c, authDetails2.RefreshToken__c);


        List<AuthorizationDetails__c> authDetailsList = [SELECT Name, AccessToken__c, RefreshToken__c FROM AuthorizationDetails__c];

        System.assertEquals(authDetailsList.size(), 1);

        HubMemberController.updateAuthData('test2', 'testAtoken', 'testRtoken', 'testUrl');

        authDetailsList = [SELECT Name, AccessToken__c, RefreshToken__c FROM AuthorizationDetails__c];

        System.assertEquals(authDetailsList.size(), 2);
    }

    @isTest
    public static void setTokenDataTest(){
        String jsonInput = '{\n' +
        ' "refresh_token" :"refreshToken",\n' +
        ' "access_token" : "accessToken",\n' + 
        ' "id" :"https://login.salesforce.com/id/00D2w000005lwpHEAQ/0052w000003FDAoAAO"\n' +
        '}';

        HubMemberController.TokenData tokenData = HubMemberController.setTokenData(jsonInput);

        System.assertEquals(tokenData.refereshToken, 'refreshToken');
        System.assertEquals(tokenData.accessToken, 'accessToken');
        System.assertEquals(tokenData.orgId, '00D2w000005lwpHEAQ');
    }

    @isTest
    public static void addoAuth2ParamsTest(){
        Credentials__c creds = Credentials__c.getOrgDefaults();
        HubMemberController.AuthenticateDetails authResult = new HubMemberController.AuthenticateDetails(false, false);
        String orgId = 'test';

        HubMemberController.addoAuth2Params(authResult, orgId, creds);

        System.assertEquals(authResult.orgId, orgId);
        System.assertEquals(authResult.oAuth2.clientId , creds.Consumer_Key_Auto__c);
        System.assertEquals(authResult.oAuth2.clientSecret, creds.Redirect_URL_Auto__c);
    }

    @isTest
    public static void setUserDataTest(){
        String jsonInput = '{\n' +
        ' "username" :"username",\n' +
        ' "display_name" : "display_name",\n' + 
        ' "organization_id" :"organization_id"\n' +
        '}';

        HubMemberController.UserData userData = HubMemberController.setUserData(jsonInput);

        System.assertEquals(userData.orgUserName, 'username');
        System.assertEquals(userData.userFullName, 'display_name');
        System.assertEquals(userData.organisationId, 'organization_id');
    }

    @isTest
    public static void getResponseInfoTest(){
        HubMemberController.getResponseInfo();
    }

    @isTest
    public static void deAuthorizeHubMemberTest(){
        HubMemberController.deAuthorizeHubMember('0016s000006icoZAAQ');
    }

    @isTest
    public static void fakeMethodsTest(){
        HubMemberController.fakeMethods();
    }

}