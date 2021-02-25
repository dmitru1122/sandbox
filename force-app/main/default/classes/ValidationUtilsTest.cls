@IsTest
public class ValidationUtilsTest {
    @IsTest
    public static void startTest() {
        prepareData();
        List<Organisation__c> orgList = [SELECT Id,Username__c,Name,Organisation_ID__c FROM Organisation__c LIMIT 1];
        List<AuthorizationDetails__c> detailLi = [SELECT AuthorisedUser__c, Name, AccessToken__c, RefreshToken__c, InstanceURL__c, Connected_App_Type__c FROM AuthorizationDetails__c LIMIT 1];
        // it is necessary to make start / stop
        // to avoid error "You have uncommitted work pending. Please commit or rollback before calling out"
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new ValidationUtilsMockAuthOrg(true)); // no fake error in the Mock
        ValidationUtils.AuthenticateDetails validationAnOrg = ValidationUtils.validationOrg(orgList[0],detailLi[0]);
        System.assertEquals(false,validationAnOrg.isSuccess);

        Test.setMock(HttpCalloutMock.class, new ValidationUtilsMockAuthOrg(false)); // fake error in the Mock
        validationAnOrg = ValidationUtils.validationOrg(orgList[0],detailLi[0]);
        System.assertEquals(true,validationAnOrg.isSuccess);

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