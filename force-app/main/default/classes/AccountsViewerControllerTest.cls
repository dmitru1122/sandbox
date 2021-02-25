@isTest
private class AccountsViewerControllerTest {

    @isTest
    static void testAccountViewer() {
        InsertTestData();
        Id rt1 = Schema.SObjectType.Account.getRecordTypeInfosByName().get('External Organizations').getRecordTypeId();
        Id rt2 = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Internal Organization').getRecordTypeId();
        AccountsViewerController con = new AccountsViewerController();

        System.assertEquals(2, con.filtersOptions.size());

        con.selectedRTypes = '["' + rt1  +'","' + rt2 + '"]';
        con.showEmptyTypes = true;
        con.showPrimaryContact = true;
        con.doShowRecords();
        System.assertEquals(2, con.getAccountRecords().size());

        con.selectedPresentation = 'date';
        con.selectedDateField = 'Next_Action_Date__c';
        con.doShowRecords();
        System.assertEquals(6, con.getAccountRecords().size());

        con.selectedPresentation = 'owner';
        con.doShowRecords();
        System.assertEquals(1, con.getAccountRecords().size());

        con.selectedPresentation = 'implementation_phase';
        con.doShowRecords();
        System.assertEquals(7, con.getAccountRecords().size());

        con.selectedPresentation = 'record_type';
        con.doShowRecords();
        con.selectedIdType = rt1;
        con.next();
        con.previous();
        con.selectedFilter = con.filtersOptions.get(1).getValue();
        con.sortingTable();
        System.assertEquals('DESC', con.sortDirection);
        con.showEmptyTypes = false;
        con.doShowRecords();
        System.assertEquals(1, con.getAccountRecords().size());
        con.selectedFilter = con.filtersOptions.get(0).getValue();
        con.doShowRecords();
        con.searchValue = 'Test Name2';
        con.doSearch();
        System.assertEquals(1, con.getAccountRecords().size());

        con.selectedFilter = con.filtersOptions.get(1).getValue();
        Account acc = [SELECT Id FROM Account WHERE Name = 'Test Name1'];
        con.selectedAccountCard = acc.Id;
        con.selectedRecordType = rt2;
        con.doChangeCard();
        System.assertEquals(2, [SELECT COUNT() FROM Account WHERE RecordTypeId =: rt2]);
    }

    private static void InsertTestData(){
        Id rt1 = Schema.SObjectType.Account.getRecordTypeInfosByName().get('External Organizations').getRecordTypeId();
        Id rt2 = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Internal Organization').getRecordTypeId();

        List<Account> listAccount = new List<Account>();
        for(Integer i = 0 ; i < 10; i++) {
            listAccount.add(new Account(Name = 'Test1 Name' + i, RecordTypeId = rt1, Next_Action_Date__c = Date.today()));
        }
        listAccount.add(new Account(Name = 'Test Name1', RecordTypeId = rt1, Next_Action_Date__c = Date.today().addDays(7), Implementation_Phase__c = 'Kick-Off'));
        listAccount.add(new Account(Name = 'Test Name2', RecordTypeId = rt2, Next_Action_Date__c = Date.today().addDays(3), Implementation_Phase__c = 'Third Training'));
        insert listAccount;

        RadEx__Filter__c filter = new RadEx__Filter__c(Name = 'Test Filter', RadEx__Point__c = 'AccountCardViewer', RadEx__Object__c = 'Account');
        filter.RadEx__Query_Expression__c = '((Name = \'' + listAccount.get(0).Name + '\'))';
        insert filter;
    }

    @isTest
    static void testAccountFieldManagementController() {
        Id rt = Schema.SObjectType.Account.getRecordTypeInfosByName().get('External Organizations').getRecordTypeId();
        Account acc = new Account(Name = 'Test Name', RecordTypeId = rt, Next_Action_Date__c = Date.today().addDays(3));
        insert acc;
        PageReference pageProject = Page.AccountFieldManagement;
        Test.setCurrentPage(pageProject);
		ApexPages.currentPage().getParameters().put('id', acc.id);
        ApexPages.currentPage().getParameters().put('fieldSet', 'TestFieldSet');
        ApexPages.currentPage().getParameters().put('retURL', 'testReturnURL');

        AccountFieldManagementController con = new AccountFieldManagementController();
        System.assertEquals(false, con.showForm);
        con.objAccount.Name = 'Test Name Changed';
        con.doSaveAccount();
        System.assertEquals(1, [SELECT COUNT() FROM Account WHERE Name = 'Test Name Changed']);
    }

    @isTest
    static void testAccountFieldManagementInvalidId() {
        Test.startTest();
            PageReference pageProject = Page.AccountFieldManagement;
            Test.setCurrentPage(pageProject);
            ApexPages.currentPage().getParameters().put('id', 'invalid id');
            ApexPages.currentPage().getParameters().put('fieldSet', 'TestFieldSet');
            ApexPages.currentPage().getParameters().put('retURL', 'testReturnURL');

            AccountFieldManagementController con = new AccountFieldManagementController();
            System.assertEquals(false, con.showForm);
        Test.stopTest();

        ApexPages.Message[] messages = ApexPages.getMessages();
		System.assertEquals('Invalid Id!', messages[0].getDetail());
    }

    @isTest
    static void testAccountFieldManagementEmptyId() {
        Test.startTest();
            PageReference pageProject = Page.AccountFieldManagement;
            Test.setCurrentPage(pageProject);
            ApexPages.currentPage().getParameters().put('id', '');
            ApexPages.currentPage().getParameters().put('fieldSet', 'TestFieldSet');
            ApexPages.currentPage().getParameters().put('retURL', 'testReturnURL');

            AccountFieldManagementController con = new AccountFieldManagementController();
            System.assertEquals(false, con.showForm);
        Test.stopTest();

        ApexPages.Message[] messages = ApexPages.getMessages();
		System.assertEquals('No record Id!', messages[0].getDetail());
    }

}