@isTest
public with sharing class GlobalHelpersTest {

	static testMethod void testButtonNextActiveAccountNumber() {
		List<Account> accList = new List<Account>();
		for (Integer i = 0; i < 500; i++) {
			Account acc = new Account();
			acc.Active__c = 'Yes';
			acc.Name = 'test' + String.valueOf(i);
			if (i > 15) {
				acc.AccountNumber = String.valueOf(i);
			}
			accList.add(acc);
		}
		insert accList;

		Test.startTest();
			String idRecords =  GlobalHelpers.ButtonNextActiveAccount(String.valueOf(accList[100].Id));
		Test.stopTest();
		Id searchId = Id.valueOf(idRecords);

		Account searchRecord = [SELECT Id, AccountNumber, Name FROM Account WHERE Id =:searchId];
		System.assertEquals(searchRecord.AccountNumber, accList[101].AccountNumber);
		System.assertEquals(searchRecord.Name, accList[101].Name);
		System.assertEquals(searchRecord.Id, accList[101].Id);
	}

	static testMethod void testButtonNextActiveAccountName() {
		List<Account> accList = new List<Account>();
        Id rt = Schema.SObjectType.Account.getRecordTypeInfosByName().get('External Organizations').getRecordTypeId();
		for (Integer i = 0; i < 10; i++) {
			Account acc = new Account();
			acc.Name = 'test' + String.valueOf(i);
			acc.Active__c = 'Yes';
            acc.RecordTypeId = rt;
            acc.Next_Action_Date__c = Date.today();
			accList.add(acc);
		}
		insert accList;

		Test.startTest();
			String idRecords =  GlobalHelpers.ButtonNextActiveAccount(String.valueOf(accList[5].Id));
		Test.stopTest();
		Id searchId = Id.valueOf(idRecords);
		Account searchRecord = [SELECT Id, Name FROM Account WHERE Id =:searchId];
		System.assertEquals(searchRecord.Name, accList[6].Name);
		System.assertEquals(searchRecord.Id, accList[6].Id);
	}

	static testMethod void testButtonNextActiveFail() {
		List<Account> accList = new List<Account>();
		for (Integer i = 0; i < 500; i++) {
			Account acc = new Account();
			acc.Active__c = 'Yes';
			acc.Name = 'test' + String.valueOf(i);
			if (i > 15) {
				acc.AccountNumber = String.valueOf(i);
			}
			accList.add(acc);
		}
		insert accList;

		Test.startTest();
			String idRecords =  GlobalHelpers.ButtonNextActiveAccount('');
		Test.stopTest();
		System.assertEquals(idRecords, '');
	}

	static testMethod void testButtonNextUnworkedAccountNumber() {
		List<Account> accList = new List<Account>();
		for (Integer i = 0; i < 500; i++) {
			Account acc = new Account();
			acc.Active__c = 'Yes';
			acc.Name = 'test' + String.valueOf(i);
			acc.AccountNumber = String.valueOf(i);
			acc.Prospect_Scrub_Date__c = NULL;
			accList.add(acc);
		}
		insert accList;

		Test.startTest();
			String idRecords =  GlobalHelpers.ButtonNextUnworkedAccount(String.valueOf(accList[100].Id));
		Test.stopTest();
		Id searchId = Id.valueOf(idRecords);

		Account searchRecord = [SELECT Id, AccountNumber, Name FROM Account WHERE Id =:searchId];
		System.assertEquals(searchRecord.AccountNumber, accList[101].AccountNumber);
		System.assertEquals(searchRecord.Name, accList[101].Name);
		System.assertEquals(searchRecord.Id, accList[101].Id);
	}

	static testMethod void testButtonNextUnworkedAccountName() {
		List<Account> accList = new List<Account>();
		for (Integer i = 0; i < 10; i++) {
			Account acc = new Account();
			acc.Name = 'test' + String.valueOf(i);
			acc.Active__c = 'Yes';
			acc.Prospect_Scrub_Date__c = NULL;
			accList.add(acc);
		}
		insert accList;

		Test.startTest();
			String idRecords =  GlobalHelpers.ButtonNextUnworkedAccount(String.valueOf(accList[5].Id));
		Test.stopTest();
		Id searchId = Id.valueOf(idRecords);
		Account searchRecord = [SELECT Id, Name FROM Account WHERE Id =:searchId];
		System.assertEquals(searchRecord.Name, accList[6].Name);
		System.assertEquals(searchRecord.Id, accList[6].Id);
	}

	static testMethod void testButtonNextUnworkedFAIL() {
		List<Account> accList = new List<Account>();
		for (Integer i = 0; i < 10; i++) {
			Account acc = new Account();
			acc.Name = 'test' + String.valueOf(i);
			acc.Active__c = 'Yes';
			acc.Prospect_Scrub_Date__c = DateTime.newInstance(1997, 1, 31, 7, 8, 16);
			accList.add(acc);
		}
		insert accList;

		Test.startTest();
			String idRecords =  GlobalHelpers.ButtonNextUnworkedAccount('');
		Test.stopTest();

		System.assertEquals(idRecords, '');

	}

	static testMethod void testButtonNextActiveAccountRecordType() {
		List<Account> accList = new List<Account>();
		Id rtId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Internal_Organization').getRecordTypeId();
		for (Integer i = 0; i < 500; i++) {
			Account acc = new Account(RecordTypeId = rtId);
			acc.Active__c = 'Yes';
			acc.Name = 'test' + String.valueOf(i);
			if (i > 15) {
				acc.AccountNumber = String.valueOf(i);
			}
			accList.add(acc);
		}
		insert accList;

		Test.startTest();
			String idRecords =  GlobalHelpers.ButtonNextActiveAccountByRecordType(String.valueOf(accList[100].Id));
		Test.stopTest();
		Id searchId = Id.valueOf(idRecords);

		Account searchRecord = [SELECT Id, AccountNumber, Name FROM Account WHERE Id =:searchId];
		System.assertEquals(searchRecord.AccountNumber, accList[101].AccountNumber);
		System.assertEquals(searchRecord.Name, accList[101].Name);
		System.assertEquals(searchRecord.Id, accList[101].Id);
	}
}