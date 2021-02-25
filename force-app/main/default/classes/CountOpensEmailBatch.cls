public class CountOpensEmailBatch implements Database.Batchable<sObject> {
	
	String query;
	
	public CountOpensEmailBatch() {
		this.query = ' SELECT Name, Id, Of_Times_Opened__c, (SELECT Id, TimesOpened FROM EmailStatuses) FROM Contact';

	}
	
	public Database.QueryLocator start(Database.BatchableContext BC) {
		return Database.getQueryLocator(query);
	}

   	public void execute(Database.BatchableContext BC, List<sObject> scope) {
   		List<Contact> updateListContact = new List<Contact>();
   		for (Sobject s : scope) {
   			Contact itemContact = (Contact) s;
   			Integer countOpens = 0;
   			for (EmailStatus email : itemContact.EmailStatuses) {
   				countOpens += email.TimesOpened;
   			}
   			if (itemContact.Of_Times_Opened__c == NULL || (itemContact.Of_Times_Opened__c != NULL && itemContact.Of_Times_Opened__c != countOpens)) {
   				itemContact.Of_Times_Opened__c = countOpens;
				updateListContact.add(itemContact);
   			}
		}
		update updateListContact;
	}
	
	public void finish(Database.BatchableContext BC) {}
	
}