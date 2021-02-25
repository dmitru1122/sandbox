trigger emailTrg on EmailMessage (after insert) {
	if (Trigger.isAfter && Trigger.isInsert) {
		Set<Id> activity = new Set<Id>();
		for (EmailMessage email : Trigger.new) {
			activity.add(email.ActivityId);
		}

		List<Task> taskList = [SELECT Id, WhoId FROM Task WHERE Id=:activity];
		Set<Id> contactIds = new Set<Id>();
		for (Task itemTask : taskList) {
			contactIds.add(itemTask.WhoId);
		}

		List<Contact> clst = [
			Select Name, Id,
				(SELECT Id, TimesOpened
				FROM EmailStatuses)
			FROM Contact
			WHERE Id =:contactIds
		];

		List<Contact> updateListContact = new List<Contact>();
		for (Contact itemContact : clst) {
			Contact con = new Contact(
				Id = itemContact.Id,
				Of_Emails_Sent__c = itemContact.EmailStatuses.size()
			);
			updateListContact.add(con);
		}
		update updateListContact;
	}
}