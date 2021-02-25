/**
 * Unit test class for AuthUtils class
 * Nikolai Ivakhnenko
 * 2018
 */

@IsTest
private class AuthUtilsTest {
    @IsTest
    public static void startTest() {
        prepareData();
        Organisation__c org = [SELECT id FROM Organisation__c LIMIT 1];
        // it is necessary to make start / stop
        // to avoid error "You have uncommitted work pending. Please commit or rollback before calling out"
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new AuthUtilsMockAuthOrg(false)); // no fake error in the Mock
        AuthUtils.AuthenticateDetails authenticateAnOrg = AuthUtils.authenticateAnOrg(org.Id);
        Test.setMock(HttpCalloutMock.class, new AuthUtilsMockAuthOrg(true)); // fake error in the Mock
        authenticateAnOrg = AuthUtils.authenticateAnOrg(org.Id);
        Test.stopTest();
    }

    private static void prepareData () {
        String authUserName = 'TestUser';
        Organisation__c org = new Organisation__c(Username__c = authUserName, Name = 'testorg', Organisation_ID__c = 'orgid');
        insert org;
        AuthorizationDetails__c authDetails = new AuthorizationDetails__c(AuthorisedUser__c = org.Username__c, Name = 'user',
                AccessToken__c = 'testtoken', RefreshToken__c = 'testrefreshtoken', InstanceURL__c = 'testurl',
                Connected_App_Type__c = 'testconapp');
        insert authDetails;
    }
}