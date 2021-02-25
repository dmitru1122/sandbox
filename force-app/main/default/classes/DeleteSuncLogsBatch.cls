public with sharing class DeleteSuncLogsBatch implements Database.Batchable<sObject> {
	
	public Database.QueryLocator start(Database.BatchableContext BC) {
		String query = 'SELECT Id ' +
			           'FROM RadEx__Error_Log__c ' +
			           'WHERE RadEx__Event_Date__c < LAST_N_MONTHS:3';

		return Database.getQueryLocator(query);
	}

	public void execute(Database.BatchableContext BC, List<sObject> scope) {
		delete scope;
	}

	public void finish(Database.BatchableContext BC) {}

}