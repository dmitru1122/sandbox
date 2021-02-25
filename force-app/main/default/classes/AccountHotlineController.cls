public with sharing class AccountHotlineController {
    public AccountHotlineController() {

    }

    public List<Account> getHotlineAccounts() {
        return [SELECT Id, Name, Customer_Acronym__c, Incident_Reporting_URL__c FROM Account WHERE Hotline_Customer__c = true AND Incident_Reporting_URL__c != null AND Active__c = 'Yes' ORDER BY Name];
    }
}