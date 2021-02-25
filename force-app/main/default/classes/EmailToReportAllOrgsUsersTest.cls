@isTest
private class EmailToReportAllOrgsUsersTest {

    static testmethod void testParseUsers() {

        Account newAccount = new Account(Name = 'testName');
        newAccount.Org_Id__c = '01r6F000000qhhP';
        insert newAccount;


        String jsonStringData = '{  "OrganizationId" : "01r6F000000qhhP",  "powerIsActive" : 5,  "powerIsNotActive" : 0,  "basicIsActive" : 3,  "basicIsNotActive" : 0,'+ 
            '"otherIsActive" : 15,  "otherIsNotActive" : 1, "UnusedLicenses" :  15, "percentActivUsers" : "28%", "TotalOfLlogins" : 5, "UserLastActive" : 20}';

        Messaging.InboundEmail email = new Messaging.InboundEmail() ;
        Messaging.InboundEnvelope env = new Messaging.InboundEnvelope();

        email.plainTextBody = jsonStringData; 


        Test.startTest();

            EmailToReportAllOrgsUsers emailProcess = new EmailToReportAllOrgsUsers();
            emailProcess.handleInboundEmail(email, env);

        Test.stopTest();

        List<Account> testAccount = [SELECT Id, (SELECT Id, DateReport__c, ActiveBasicUsers__c, ActiveOtherUsers__c, ActivePowerUsers__c,
            Unused_Licenses__c, Unique_Users_Percent__c, Unique_Users_Logged__c,
            InActiveBasicUsers__c, InActiveOtherUsers__c, InActivePowerUsers__c FROM ReportsToUsersAllOrgs__r) FROM Account WHERE Id=:newAccount.Id];


        System.assertEquals(testAccount.size(), 1);
        System.assertEquals(testAccount[0].ReportsToUsersAllOrgs__r.size(), 1);

        System.assertEquals(testAccount[0].ReportsToUsersAllOrgs__r[0].DateReport__c, System.today());

        System.assertEquals(testAccount[0].ReportsToUsersAllOrgs__r[0].ActiveBasicUsers__c, 3);
        System.assertEquals(testAccount[0].ReportsToUsersAllOrgs__r[0].InActiveBasicUsers__c, 0);

        System.assertEquals(testAccount[0].ReportsToUsersAllOrgs__r[0].ActivePowerUsers__c, 5);
        System.assertEquals(testAccount[0].ReportsToUsersAllOrgs__r[0].InActivePowerUsers__c, 0);

        System.assertEquals(testAccount[0].ReportsToUsersAllOrgs__r[0].ActiveOtherUsers__c, 15);
        System.assertEquals(testAccount[0].ReportsToUsersAllOrgs__r[0].InActiveOtherUsers__c, 1);

        System.assertEquals(testAccount[0].ReportsToUsersAllOrgs__r[0].Unused_Licenses__c, 15);
        System.assertEquals(testAccount[0].ReportsToUsersAllOrgs__r[0].Unique_Users_Percent__c, 86.96);
        System.assertEquals(testAccount[0].ReportsToUsersAllOrgs__r[0].Unique_Users_Logged__c, 20);
    }

}