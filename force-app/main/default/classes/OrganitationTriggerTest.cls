@IsTest
public with sharing class OrganitationTriggerTest {

    @testSetup static void setup() {
        Account acc = new Account(  Name = 'Test ',
                                    Active__c = 'Yes');
        insert acc;
        Datetime DateMigration = Date.today();
        List<Organisation__c> orgList = new List<Organisation__c>();

        for(Integer a = 0; a <100; a++) {
            orgList.add(new Organisation__c(Name = 'test' + a,
                                            Last_Success_Layout_Migration_Date__c = DateMigration,
                                            isActive__c = true,
                                            Organisation_ID__c = 'test'));
        }
        insert orgList;
    }

    @isTest
    static void testDataFromOrg() {
        List<Account> accTestList = [SELECT id, Name, Last_Successful_Migration_Date__c
                                    FROM Account
                                    WHERE Name LIKE 'test'
                                    LIMIT 1];

        List<Organisation__c> orgTestList = [SELECT id, Name, Org_id__c, Last_Success_Layout_Migration_Date__c
                                            FROM Organisation__c
                                            WHERE Name LIKE '%test%'];
        Id idAcc;
        Datetime accDatetime;
        List<Datetime> orgDatetime = new List<Datetime>();
        Map<Datetime, String> uniqueOrgDate = new Map<Datetime, String>();

        for(Account item : accTestList){
            idAcc=item.id;
        }

        List<Organisation__c> orgTestListUpdate = new List<Organisation__c>();
        for(Organisation__c item : orgTestList){
            item.Org_id__c = idAcc;
            orgDatetime.add(item.Last_Success_Layout_Migration_Date__c);
            orgTestListUpdate.add(item);
            uniqueOrgDate.put(item.Last_Success_Layout_Migration_Date__c, 'test');
        }
        update orgTestListUpdate;

        List<Account> accTestListUpdate = [ SELECT id, Name, Last_Successful_Migration_Date__c
                                            FROM Account
                                            WHERE Name = 'test' LIMIT 1];

        for(Account item : accTestListUpdate){
            accDatetime = item.Last_Successful_Migration_Date__c;
        }
        System.assertEquals(orgDatetime.get(0),accDatetime);
        System.assertEquals(orgDatetime.get(20),accDatetime);
        System.assertEquals(orgDatetime.get(40),accDatetime);
        System.assertEquals(orgDatetime.get(60),accDatetime);
        System.assertEquals(orgDatetime.get(80),accDatetime);
        System.assertEquals(1,uniqueOrgDate.size());
    }
}