@isTest
public with sharing class AccountHotlineControllerTest{

    public static testmethod void AccountHotlineControllerTester(){

        Account a = new Account();
        a.Name = 'Test Account 1';
        a.Active__c = 'Yes';
        a.Customer_Acronym__c = 'TA1';
        a.Incident_Reporting_URL__c = 'https://Test1';
        a.Hotline_Customer__c = true;

        insert a;

        Account a2 = new Account();
        a2.Name = 'Test Account 2';
        a2.Active__c = 'No';
        a2.Customer_Acronym__c = 'TA2';
        a2.Incident_Reporting_URL__c = 'https://Test1';
        a2.Hotline_Customer__c = true;

        insert a2;

        Account a3 = new Account();
        a3.Name = 'Test Account 2';
        a3.Active__c = 'Yes';
        a3.Customer_Acronym__c = 'TA2';
        a3.Incident_Reporting_URL__c = '';
        a3.Hotline_Customer__c = true;

        insert a3;        
        
        Test.startTest();

        AccountHotlineController ahc = new AccountHotlineController();
            List<Account> accts = ahc.getHotlineAccounts();
            
            System.assertEquals(accts.size(), 1);
        Test.stopTest();
    }

}