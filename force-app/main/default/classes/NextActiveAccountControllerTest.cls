@isTest
public with sharing class NextActiveAccountControllerTest {
    static testMethod void testButtonNextActiveAccountOwner() {
        List<Account> accList = new List<Account>();
		for ( Integer i = 0; i < 500; i++ ) {
			Account acc = new Account();
			acc.Active__c = 'Yes';
			acc.Name = 'test' + String.valueOf(i);
			if( i > 15 ) acc.AccountNumber = String.valueOf(i);
			accList.add(acc);
		}
		insert accList;

        PageReference pageRedirect = Page.LightningNextActiveAccountOwner;
        Test.setCurrentPage(pageRedirect);
		ApexPages.currentPage().getParameters().put('id', accList[100].Id);
        ApexPages.currentPage().getParameters().put('type', 'owner');

        NextActiveAccountOwnerController con = new NextActiveAccountOwnerController();
        PageReference pageGenerated = con.redirectAction();
		PageReference expectedPage  = new PageReference('/' + accList[101].Id);
		System.assertEquals(expectedPage.getUrl(), pageGenerated.getUrl());
    }

    static testMethod void testButtonNextActiveAccountRecordType() {
        List<Account> accList = new List<Account>();
		Id rtId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Internal_Organization').getRecordTypeId();
		for( Integer i = 0; i < 500; i++ ) {
			Account acc = new Account( RecordTypeId = rtId );
			acc.Active__c = 'Yes';
			acc.Name = 'test' + String.valueOf(i);
			if( i > 15 ) acc.AccountNumber = String.valueOf(i);
			accList.add(acc);
		}
		insert accList;

        PageReference pageRedirect = Page.LightningNextActiveAccountOwner;
        Test.setCurrentPage(pageRedirect);
		ApexPages.currentPage().getParameters().put('id', accList[100].Id);
        ApexPages.currentPage().getParameters().put('type', 'rt');

        NextActiveAccountOwnerController con = new NextActiveAccountOwnerController();
        PageReference pageGenerated = con.redirectAction();
		PageReference expectedPage  = new PageReference('/' + accList[101].Id);
		System.assertEquals(expectedPage.getUrl(), pageGenerated.getUrl());
    }
}