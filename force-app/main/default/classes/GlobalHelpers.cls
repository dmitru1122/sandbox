global with sharing class GlobalHelpers {

	Webservice static String ButtonNextActiveAccount(String accountID) {

		if (String.isBlank(accountID)) return '';

		Id accountMainId = Id.valueOf(accountID);
		Account accountMain  = [
			SELECT Id, AccountNumber, RecordTypeId, Name, CRM_Tier__c, Lead_Target__c, Owner.Name, Owner.Id
			FROM Account
			WHERE Id=:accountMainId
		];	

		if (String.isNotBlank(accountMain.AccountNumber) && accountMain.AccountNumber.isNumeric()) {

			Integer numberForSearch = Integer.valueOf(accountMain.AccountNumber);
			List<Account> accountListNumber  = [
				SELECT Id, AccountNumber, Name, Owner.Name, Owner.Id
				FROM Account
				WHERE Active__c = 'Yes'
				AND Owner.Id =: accountMain.Owner.Id
				AND AccountNumber != NULL
				ORDER BY AccountNumber ASC
				LIMIT 9000
			];
			List<AccountSortingWrapper> lisaSortingAccount = new List<AccountSortingWrapper>();

			for (Account acc : accountListNumber) {
				if (acc.AccountNumber.isNumeric()) {
					Integer tmp = Integer.valueOf(acc.AccountNumber);
					lisaSortingAccount.add(new AccountSortingWrapper(acc, tmp));
				}
			}
			lisaSortingAccount.sort();

			Boolean isFoundRecordForNumber = false;
			for (AccountSortingWrapper acc : lisaSortingAccount) {
                if (isFoundRecordForNumber) return String.valueOf(acc.account.Id);
                
				isFoundRecordForNumber = acc.accountNumber == numberForSearch;
			}
		}
		if (String.isNotBlank(accountMain.Name)) {
			List<Account> accountList  = [
				SELECT Id, AccountNumber, Name, Owner.Id
				FROM Account
				WHERE (Active__c = 'Yes'
				AND Owner.Id =: accountMain.Owner.Id
				AND RecordTypeId =: accountMain.RecordTypeId
				AND Next_Action_Date__c <= TODAY)
				OR Id =: accountMain.Id
				ORDER BY Name ASC
				LIMIT 1000
			];
			Boolean isFoundRecordForName = false;
			for (Account acc : accountList) {
                if (isFoundRecordForName) {
                    return String.valueOf(acc.Id);
                }
				isFoundRecordForName = acc.Name == accountMain.Name;
			}
            if(!accountList.isEmpty()) return String.valueOf(accountList.get(0).Id);
		}
		return '';
	}

	Webservice static String ButtonNextActiveAccountByRecordType(String accountID) {

		if (String.isBlank(accountID)) return '';

		Id accountMainId = Id.valueOf(accountID);
		Account accountMain  = [
			SELECT Id, AccountNumber, RecordTypeId, Name, CRM_Tier__c, Lead_Target__c, Owner.Name, Owner.Id
			FROM Account
			WHERE Id=:accountMainId
		];	

		if (String.isNotBlank(accountMain.AccountNumber) && accountMain.AccountNumber.isNumeric()) {

			Integer numberForSearch = Integer.valueOf(accountMain.AccountNumber);
			List<Account> accountListNumber  = [
				SELECT Id, RecordTypeId, AccountNumber, Name, Owner.Name, Owner.Id
				FROM Account
				WHERE Active__c = 'Yes'
				AND RecordTypeId =: accountMain.RecordTypeId
				AND AccountNumber != NULL
				ORDER BY AccountNumber ASC
				LIMIT 9000
			];
			List<AccountSortingWrapper> lisaSortingAccount = new List<AccountSortingWrapper>();

			for (Account acc : accountListNumber) {
				if (acc.AccountNumber.isNumeric()) {
					Integer tmp = Integer.valueOf(acc.AccountNumber);
					lisaSortingAccount.add(new AccountSortingWrapper(acc, tmp));
				}
			}
			lisaSortingAccount.sort();

			Boolean isFoundRecordForNumber = false;
			for (AccountSortingWrapper acc : lisaSortingAccount) {
                if (isFoundRecordForNumber) return String.valueOf(acc.account.Id);
                
				isFoundRecordForNumber = acc.accountNumber == numberForSearch;
			}
		}
		if (String.isNotBlank(accountMain.Name)) {
			List<Account> accountList  = [
				SELECT Id, AccountNumber, Name, Owner.Id
				FROM Account
				WHERE (Active__c = 'Yes'
				AND Owner.Id =: accountMain.Owner.Id
				AND RecordTypeId =: accountMain.RecordTypeId
				AND Next_Action_Date__c <= TODAY)
				OR Id =: accountMain.Id
				ORDER BY Name ASC
				LIMIT 1000
			];
			Boolean isFoundRecordForName = false;
			for (Account acc : accountList) {
                if (isFoundRecordForName) {
                    return String.valueOf(acc.Id);
                }
				isFoundRecordForName = acc.Name == accountMain.Name;
			}
            if(!accountList.isEmpty()) return String.valueOf(accountList.get(0).Id);
		}
		return '';
	}


	Webservice static String ButtonNextUnworkedAccount(String accountID) {

		if (String.isBlank(accountID)) return '';
		Id accountMainId = Id.valueOf(accountID);
		Account accountMain  = [
			SELECT Id, AccountNumber, Name, CRM_Tier__c	, Lead_Target__c
			FROM Account
			WHERE Id=:accountMainId
		];

		if (String.isNotBlank(accountMain.AccountNumber) && accountMain.AccountNumber.isNumeric()) {
			Integer numberForSearch = Integer.valueOf(accountMain.AccountNumber);
			List<Account> accountListNumber  = [
				SELECT Id, AccountNumber, Name, CRM_Tier__c	
				FROM Account
				WHERE Active__c = 'Yes'
				AND Lead_Target__c =: accountMain.Lead_Target__c
				AND CRM_Tier__c	 =: accountMain.CRM_Tier__c
				AND Prospect_Scrub_Date__c = NULL
				AND AccountNumber != NULL
				ORDER BY AccountNumber ASC
				LIMIT 9000
			];
			List<AccountSortingWrapper> lisaSortingAccount = new List<AccountSortingWrapper>();

			for (Account acc : accountListNumber) {
				if (acc.AccountNumber.isNumeric()) {
					Integer tmp = Integer.valueOf(acc.AccountNumber);
					lisaSortingAccount.add(new AccountSortingWrapper(acc, tmp));
				}
			}
			lisaSortingAccount.sort();


			Boolean isFoundRecordForNumber = false;
			for (AccountSortingWrapper acc : lisaSortingAccount) {
				if (isFoundRecordForNumber) return String.valueOf(acc.account.Id);
				isFoundRecordForNumber = acc.accountNumber == numberForSearch;
			}
			if (lisaSortingAccount.size() == 1) return String.valueOf(lisaSortingAccount.get(0).account.Id);
		}
		if (String.isNotBlank(accountMain.Name)) {
			List<Account> accountList  = [
				SELECT Id, AccountNumber, Name
				FROM Account
				WHERE Active__c = 'Yes'
				AND Lead_Target__c =: accountMain.Lead_Target__c
				AND CRM_Tier__c	 =: accountMain.CRM_Tier__c
				AND Prospect_Scrub_Date__c = NULL
				ORDER BY Name ASC
				LIMIT 1000
			];
			Boolean isFoundRecordForName = false;
			for (Account acc : accountList) {
				if (isFoundRecordForName) return String.valueOf(acc.Id);
				isFoundRecordForName = acc.Name == accountMain.Name;
			}
		}
		return '';
	}

	private class AccountSortingWrapper implements Comparable {
		public Account account;
		public Integer accountNumber;
		public AccountSortingWrapper(Account acc, Integer accountNum) {
			account = acc;
			accountNumber = accountNum;
		}

		public Integer compareTo(Object compareTo) {
			AccountSortingWrapper compareToOppy = (AccountSortingWrapper)compareTo;
			Integer returnValue = 0;
			if (accountNumber > compareToOppy.accountNumber) {
				returnValue = 1;
			} else if (accountNumber < compareToOppy.accountNumber) {
				returnValue = -1;
			}
			return returnValue;
		}
	}
}