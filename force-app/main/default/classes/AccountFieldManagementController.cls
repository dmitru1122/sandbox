public with sharing class AccountFieldManagementController {

	public Id recordId {get; set;}
	public String selectedFieldSet { get; set;}
	public String retURL {get; set;}
	public Account acc {get; set;}
	public Boolean showForm {get; set;}
	public Map<String, String> setFields {get; set;}
	public List<String> orderedFilds {get; set;}
	public Account objAccount {get; set;}

	public AccountFieldManagementController() {
		String tempId = ApexPages.currentPage().getParameters().get('id');
		this.selectedFieldSet = ApexPages.currentPage().getParameters().get('fieldSet');
		this.retURL = ApexPages.currentPage().getParameters().get('retURL');
		this.showForm = true;
		if (String.isNotBlank(tempId)) {
			try {
				this.recordId = (Id)tempId;
			} catch(Exception e) {
				this.showForm = false;
				ApexPages.addmessage(new ApexPages.message(ApexPages.Severity.ERROR, 'Invalid Id!'));
				return;
			}

			this.setFields = new Map<String, String>();
			this.orderedFilds = new List<String>();
			Boolean invalidFieldSet = false;
			if(Schema.getGlobalDescribe().get('Account').getDescribe().FieldSets.getMap().get(this.selectedFieldSet) != NULL) {
				for(Schema.FieldSetMember fieldSetMemberObj : Schema.getGlobalDescribe().get('Account').getDescribe().FieldSets.getMap().get(this.selectedFieldSet).getFields()) {
					this.setFields.put(fieldSetMemberObj.getFieldPath(), fieldSetMemberObj.getLabel());
					this.orderedFilds.add(fieldSetMemberObj.getFieldPath());
				}
			} else {
				invalidFieldSet = true;
			}
			this.objAccount = getRecordObject(recordId);

			if(invalidFieldSet) {
				this.showForm = false;
				ApexPages.addmessage(new ApexPages.message(ApexPages.Severity.ERROR, 'Invalid FieldSet for Account ' + this.objAccount.Name + '!'));
				return;
			}
		} else {
			this.showForm = false;
			ApexPages.addmessage(new ApexPages.message(ApexPages.Severity.ERROR, 'No record Id!'));
		}
	}

	public Account getRecordObject(Id recId) {
		Account obj;
		if(recId != NULL) {
			String query = 'SELECT Id, Name';
			String queryFieldSet = '';
			for(String field : this.orderedFilds) {
				if(!field.equals('Name') && !field.equals('Id')) {
					queryFieldSet += ', ' + field;
				}
			}
			query += queryFieldSet;
			query += ' FROM Account WHERE Id =: recId LIMIT 1';
			return Database.query(query);
		}
		return  obj;
	}

	public PageReference doSaveAccount() {
		try {
			update this.objAccount;
			ApexPages.addmessage(new ApexPages.message(ApexPages.Severity.CONFIRM, 'Account updated successfully!'));
		} catch (Exception e) {
			this.showForm = false;
			ApexPages.addmessage(new ApexPages.message(ApexPages.Severity.ERROR, e.getMessage()));
		}
		return null;
	}
}