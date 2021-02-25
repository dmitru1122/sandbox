public with sharing class TaskRunScriptToCustomerController {

	public Task_Run_Script__c fakeForDate { get; set; }
	public Task_Run_Script__c fakeStartDate { get; set; }
	public Task_Run_Script__c newRunScripts { get; set; } 
	public Boolean AllTime  { get; set; }
	
	public List<StageWrapper> TaskStages  { get; set; } 
	public List<Task_Run_Script__c> ListScripTasks { get; set; }
	public List<Task> ListStandartTask { get; set; }
	public String RunTaskSelectedID  { get; set; }
	public Task_Run_Script__c RunTaskSelected  { get; set; }
	public List<AccountWrapper> listAccountWR   { get; set; }
	public String lastVesionNumber   { get; set; }
	public String TaskSubject { get; set; }
	public Boolean TaskToAccountOwner { get; set; }


	public string COMPLETED_ALL {
		get {
			return 'CompletedAll';
	}}

	public static final String STATUS_COMPLETED = 'Completed';

	private Set<Id> availableAccountRecordTypeIds {
		get {
			return new Set<Id>{
				Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Compliatric_Customer').getRecordTypeId(),
				Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Compliatric_Start_up_Customer').getRecordTypeId()
			};

	}}
	
	
	public Boolean isShowPopUpRunTaskSelected {
		get{
			return String.isNotBlank(RunTaskSelectedID); 
		}
	}
	
	public String Stage { get; set; }

	public Id taskIdChangeStatus  { get; set; }
	public String ChangedStatusTask  { get; set; }
	public String ChangedStatusRunScriptTask  { get; set; }
	public Integer countCompletedTaskSelectedRunScript  { get; set; }
	public Integer countAllTaskSelectedRunScript  { get; set; }

	public Map<String,String> taskStatus { 
		get {
			Map<String,String> pickListValuesList = new Map<String,String>();
			Schema.DescribeFieldResult fieldResult = Task.Status.getDescribe();
			List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
			for( Schema.PicklistEntry pickListVal : ple){
				if( pickListVal.isActive() ) pickListValuesList.put(pickListVal.getValue(), pickListVal.getLabel());
			} 
			return pickListValuesList;
		}
	}

	public Map<String,String> RunTaskStatus { 
		get {
			Map<String,String> pickListValuesList = new Map<String,String>(); 
			Schema.DescribeFieldResult fieldResult = Task_Run_Script__c.Stage__c.getDescribe();
			List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
			for( Schema.PicklistEntry pickListVal : ple){
				if( pickListVal.isActive() ) pickListValuesList.put(pickListVal.getValue(), pickListVal.getLabel());
			} 
			return pickListValuesList;
		}
	}

	public TaskRunScriptToCustomerController() { 
		Stage = 'Started';
		TaskSubject = '';
		AllTime = true;
		TaskToAccountOwner = false;
		countCompletedTaskSelectedRunScript = 0;
		countAllTaskSelectedRunScript = 0;
		
		ListStandartTask = new List<Task>();
		listAccountWR = new List<AccountWrapper>();
		TaskStages = getAllTaskStatus();
		for(StageWrapper item : TaskStages) item.isCheked = item.Val.equals(Stage);
	
		lastVesionNumber = '';
		try {
			List<sfLma__Package__c> listPackage = [SELECT Id, Name, sfLma__Latest_Version__c FROM sfLma__Package__c WHERE Name='Compliatric'];
			if(!listPackage.isEmpty()) lastVesionNumber = listPackage[0].sfLma__Latest_Version__c;
		} catch (Exception e) {}
		

		createNewSobjectRunScript();

		for(Account item : [SELECT Id, Name, OwnerId FROM Account WHERE Active__c = 'Yes' AND RecordTypeId=: availableAccountRecordTypeIds]) listAccountWR.add(new AccountWrapper(item));
		RunTaskSelected = new Task_Run_Script__c();	
		fakeForDate = new Task_Run_Script__c(Due_Date__c = Date.today().addYears(-1).addMonths(-6));
		fakeStartDate = new Task_Run_Script__c(	Due_Date__c = Date.today());

		research();
	}


	public static List<StageWrapper> getAllTaskStatus() { 
	
		List<StageWrapper>  pickListValuesList = new List<StageWrapper> ();
		Schema.DescribeFieldResult fieldResult = Task_Run_Script__c.Stage__c.getDescribe();
		List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
		for( Schema.PicklistEntry pickListVal : ple) {
			if( pickListVal.isActive() ) pickListValuesList.add(new StageWrapper(pickListVal));
		}
		return pickListValuesList;
	}

	public void DoSetStage() {
		research();
		if(String.isNotBlank(Stage)) {
			for(StageWrapper item : TaskStages ) item.isCheked = item.Val.equals(Stage);
		}
	}

	public void doUnselectAllOrg() {
	 	for(AccountWrapper item : listAccountWR )  item.isCheked = false;
	}

	public void research() {

		
		try {
			if(String.isNotBlank(Stage) ) {
				String soqlQuery = 'SELECT Id, Name, After_Version__c, Description__c, Due_Date__c, Script__c, Short_Description__c, Stage__c ';

				soqlQuery += ' FROM ' + Task_Run_Script__c.getSobjectType().getDescribe().getName();
				soqlQuery += ' WHERE Stage__c =:Stage ';

				if(!AllTime) {
					Date startDate = fakeStartDate.Due_Date__c;
					Date endDate = fakeForDate.Due_Date__c;
					soqlQuery += ' AND Due_Date__c >=: startDate AND Due_Date__c <=: endDate';
				} 
				soqlQuery += ' ORDER BY ' + Task_Run_Script__c.Due_Date__c.getDescribe().getName() + '  ASC NULLS LAST';
				ListScripTasks =  Database.query(soqlQuery);
			}
		} catch(Exception e) { ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR, e.getMessage()  +  e.getLineNumber()));}  
		
	}


	public void openTaskThisRunAction() {
		try {
			openTaskThisRun();

		} catch(Exception e) { ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR, e.getMessage()  +  e.getLineNumber()));}  
	}

	public void openTaskThisRun() {
		countAllTaskSelectedRunScript = 0;
		countCompletedTaskSelectedRunScript = 0;

		ListStandartTask.clear();

		RunTaskSelected = new Task_Run_Script__c();

		if(String.isNotBlank(RunTaskSelectedID)) {
			
			ListStandartTask = [
				SELECT Id, Status, Organization__r.Name, Organization__c
				FROM Task
				WHERE WhatId =:RunTaskSelectedID
				AND Type = 'Run Script'
				ORDER BY Organization__r.Name
			]; 

			countAllTaskSelectedRunScript = ListStandartTask.size();
			for(Task itemTask : ListStandartTask ) {
				if(itemTask.Status.equalsIgnoreCase(STATUS_COMPLETED)) countCompletedTaskSelectedRunScript++;
			}

			List<Task_Run_Script__c> tmpListRusnScriptTask = [
				SELECT Id, Name,  After_Version__c, Description__c, Due_Date__c, Script__c, Short_Description__c, Stage__c 
				FROM Task_Run_Script__c
				WHERE Id=:RunTaskSelectedID
			];

			if(!tmpListRusnScriptTask.isEmpty()) RunTaskSelected = tmpListRusnScriptTask[0];
		}
	}

	public class AccountWrapper{
		public Account acc { get; set; }
		public Boolean isCheked { get; set; }

		public AccountWrapper(Account acc ) {
			this.acc = acc;
			this.isCheked = true;
		}
	}

	public class StageWrapper {
		public String Label { get; set; }
		public String Val  { get; set; }
		public Boolean isCheked { get; set; }

		public StageWrapper(Schema.PicklistEntry pickListVal) {
			this.Label = pickListVal.getLabel();
			this.Val = pickListVal.getValue();
			this.isCheked = false;
		}
	}

	private void createNewSobjectRunScript() {

		newRunScripts = new Task_Run_Script__c(
			Stage__c = 'Started',
			Due_Date__c = Date.today().addDays(7),
			After_Version__c = lastVesionNumber,
			Description__c ='',
			Script__c ='',
			Short_Description__c =''
		);
	}

	public void createNewTasks() {

		TaskSubject = String.isNotBlank(TaskSubject) ? TaskSubject : 'Run Script';

		insert newRunScripts;
		List<Task> newTasks = new List<Task>();
		for(AccountWrapper item : listAccountWR ) {
			if(item.isCheked) {

				// Task tmp = new Task(
				// 	Organization__c = item.acc.Id,
				// 	Subject = TaskSubject,
				// 	OwnerId = UserInfo.getUserId(),
				// 	Type = 'Run Script',
				// 	Status = 'Not Started',
				// 	WhatId = newRunScripts.Id
				// );

				// if(TaskToAccountOwner)  tmp.OwnerId = item.acc.OwnerId;

				// newTasks.add(tmp);

				newTasks.add(new Task(
					Organization__c = item.acc.Id,
					Subject = TaskSubject,
					OwnerId = TaskToAccountOwner ? item.acc.OwnerId : UserInfo.getUserId(),
					Type = 'Run Script',
					Status = 'Not Started',
					WhatId = newRunScripts.Id
				));
			}
		}
		insert newTasks;
		createNewSobjectRunScript();
		research();
		TaskSubject = '';
	}

	public void changeStatusSepareteStandartTask() {
		try {
			if(taskIdChangeStatus != NULL && String.isNotBlank(ChangedStatusTask)) {

				List<Task> tmpTaskList = [SELECT Id, Status  FROM Task WHERE Id=: taskIdChangeStatus];
				if(!tmpTaskList.isEmpty()) {
					tmpTaskList[0].Status = ChangedStatusTask;
					update tmpTaskList;
				}
				openTaskThisRun();
				taskIdChangeStatus = null;
				ChangedStatusTask = '';
			} 
		} catch(Exception e) { ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR, e.getMessage()  +  e.getLineNumber()));}  
	}

	public void changeStatusRunRaskScript() {
		try {
			if(RunTaskSelectedID != NULL && String.isNotBlank(ChangedStatusRunScriptTask)) {

				List<Task_Run_Script__c> tmpTaskListRun = [
					SELECT Id, Stage__c
					FROM Task_Run_Script__c
					WHERE Id=: RunTaskSelectedID
				];

				if(!tmpTaskListRun.isEmpty()) {

					if(ChangedStatusRunScriptTask.equalsIgnoreCase(COMPLETED_ALL)) {
						List<Task> tmpTaskList = [SELECT Id, Status  FROM Task WHERE WhatId=: RunTaskSelectedID];
						tmpTaskListRun[0].Stage__c = STATUS_COMPLETED;
						for(Task itemTask : tmpTaskList) itemTask.Status = STATUS_COMPLETED;
						update tmpTaskList;
					} else {
						tmpTaskListRun[0].Stage__c = ChangedStatusRunScriptTask;
					}
					update tmpTaskListRun;
				}
				openTaskThisRun();
				ChangedStatusRunScriptTask = '';
			} 
		} catch(Exception e) { ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR, e.getMessage()  +  e.getLineNumber()));}  
	}
}