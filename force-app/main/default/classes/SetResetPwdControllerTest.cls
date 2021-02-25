@isTest(SeeAllData=true)
public class SetResetPwdControllerTest {

    @isTest
    static void getConnectedOrgsTest(){
        String jsonData = SetResetPwdController.getConnectedOrgs('TestAuth1');
    }

    @isTest
    static void getContactTest(){
        Id contactId = createContact();

        Contact con = SetResetPwdController.getContact(String.valueOf(contactId));
        Contact con2 = SetResetPwdController.getContact('notIdString');

        System.assertNotEquals(con, null);
        System.assertEquals(con2, null);
    }

    @isTest
    static void getAccountTest(){
        Id accountId = createAccount();

        Account acc = SetResetPwdController.getAccount(String.valueOf(accountId));
        Account acc2 = SetResetPwdController.getAccount('notIdString');

        System.assertNotEquals(acc, null);
        System.assertEquals(acc2, null);
    }

    @isTest
    static void requestToServerTest(){
        Test.setMock(HttpCalloutMock.class, new SetResetPwdControllerTestMock());
        Test.setMock(HttpCalloutMock.class, new SetResetPwdControllerWithTokenMock());

        Test.startTest();
        String result = SetResetPwdController.requestToServer('00D2E00000145MDUAY', 'endpoint', 'query', 'APEX');
        System.debug(result);

        System.assertNotEquals(result, null);
        Test.stopTest();
    }

    @isTest
    static void updateCaseDataTest(){
        Id caseId = createCase();
        String status = 'Closed';
        String newPasswrod = 'Ololo6712V4f';

        SetResetPwdController.updateCaseData(String.valueOf(caseId), status, newPasswrod);

        Case tmpCase = [SELECT Id, Status, Temporary_Password__c FROM Case WHERE Id =: caseId].get(0);

        System.assertEquals(tmpCase.Status, status);
        System.assertEquals(tmpCase.Temporary_Password__c, newPasswrod);
    }

    /*
    @testSetup
    static void setup() {
        List<AuthorizationDetails__c> authList = new List<AuthorizationDetails__c>();
        for(Integer i =0;i<5;i++){
            AuthorizationDetails__c auth=new AuthorizationDetails__c();
            if(i==0){
                auth.AccessToken__c='token'+i;
                auth.Name='TestAuth'+i;
                auth.AuthorisedUser__c='tso@mycompany.com';
                auth.InstanceURL__c='TestInstance'+i;
                authList.add(auth);
            }
            else{
            auth.AccessToken__c='token'+i;
            auth.Name='TestAuth'+i;
            auth.AuthorisedUser__c='testorg' + i + '@mycompany.com';
            auth.InstanceURL__c='TestInstance'+i;
            authList.add(auth);
            }
        }
        insert authList;
        sfLma__License__c sourceOrgLicense = new sfLma__License__c(sfLma__Subscriber_Org_ID__c='00D36000001FqOl',sfLma__Version_Number__c='1');
        insert  sourceOrgLicense;
    }*/

    static Id createContact(){
        Contact con = new Contact();

        con.saleswings__Full_Name__c = 'Test';
        con.LastName = 'Testerov';

        insert con;

        return con.Id;
    }

    static Id createAccount(){
        Account acc = new Account();

        acc.Name = 'Test';

        insert acc;

        return acc.Id;
    }

    static Id createCase(){
        Case tmpCase = [SELECT Id, Status, Temporary_Password__c FROM Case WHERE Status != 'Closed'].get(0);
        return tmpCase.Id;
    }
}