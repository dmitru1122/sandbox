@isTest
private class TaskRunScriptToCustomerControllerTest {

	@testSetup static void setupTestData() {	 

		List<Account> reger = new List<Account>();
	
		for(Integer i = 1 ; i <= 30 ; i++ ) {
			reger.add(new Account(
				Name = 'ergreerg'+i,
				Active__c = 'Yes',
				RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Compliatric_Customer').getRecordTypeId()
			));
		}
		insert reger;
	}

	@isTest static void testEmpty() {

		TaskRunScriptToCustomerController con = new TaskRunScriptToCustomerController();
		System.assert(!con.isShowPopUpRunTaskSelected);
		System.assertEquals(con.ListScripTasks.size(), 0);
		System.assertEquals(con.listAccountWR.size(), 30);
		con.createNewTasks();
		System.assertEquals(con.ListScripTasks.size(), 1);
		con.AllTime = false;
		Map<String,String> taskStatus = con.taskStatus;
		Map<String,String> RunTaskStatus = con.RunTaskStatus;
		con.research();
		System.assertEquals(con.ListScripTasks.size(), 0);
		con.AllTime = true;
		con.research();
		System.assertEquals(con.ListScripTasks.size(), 1);

		con.Stage = TaskRunScriptToCustomerController.STATUS_COMPLETED;
		con.DoSetStage();
		System.assertEquals(con.ListScripTasks.size(), 0);
		con.Stage = 'Started';
		con.DoSetStage();	
		System.assertEquals(con.ListScripTasks.size(), 1);

		con.RunTaskSelectedID = con.ListScripTasks[0].Id;
		con.openTaskThisRunAction();
		System.assertEquals(con.countCompletedTaskSelectedRunScript, 0);
		System.assertEquals(con.countAllTaskSelectedRunScript, 30);
		System.assertEquals(con.ListStandartTask.size(), 30);

		con.taskIdChangeStatus = con.ListStandartTask[0].Id;
		con.ChangedStatusTask = TaskRunScriptToCustomerController.STATUS_COMPLETED;

		con.changeStatusSepareteStandartTask();
		System.assertEquals(con.countCompletedTaskSelectedRunScript, 1);

		con.RunTaskSelectedID = con.ListScripTasks[0].Id;
		con.ChangedStatusRunScriptTask = 'in Progress';
		con.changeStatusRunRaskScript();
		con.RunTaskSelectedID = con.ListScripTasks[0].Id;
		con.ChangedStatusRunScriptTask = con.COMPLETED_ALL;

		con.changeStatusRunRaskScript();

		con.doUnselectAllOrg();
		Integer countSelected = 0;
		for(TaskRunScriptToCustomerController.AccountWrapper item : con.listAccountWR ){
			if(item.isCheked) countSelected++;
		}  
		System.assertEquals(0, countSelected);
		System.assertEquals(con.countCompletedTaskSelectedRunScript, 30);
		System.assertEquals(con.countAllTaskSelectedRunScript, 30);
	}

	@isTest static void testTaskOwner() {

		Profile standardProfile = [SELECT Id FROM Profile WHERE Name='System Administrator'];


		User userWithCourseExempt = createUser('Employee object will be created in future',
			'rndsdfksdf@assd.com','rnd_sfdosjf@sdf.com', standardProfile);


		System.runAs(userWithCourseExempt) {

			TaskRunScriptToCustomerController con = new TaskRunScriptToCustomerController();
			System.assert(!con.isShowPopUpRunTaskSelected);
			System.assertEquals(con.ListScripTasks.size(), 0);
			System.assertEquals(con.listAccountWR.size(), 30);
			con.createNewTasks();
			System.assertEquals(con.ListScripTasks.size(), 1);


			Account acc  = con.listAccountWR[0].acc;

			List<Task> listTaks = [
				SELECT Id, OwnerId
				FROM Task
				WHERE Organization__c  =:acc.Id
			];
			System.assertEquals(UserInfo.getUserId(), listTaks[0].OwnerId);

			delete listTaks;


			TaskRunScriptToCustomerController con2 = new TaskRunScriptToCustomerController();
			System.assertEquals(con2.ListScripTasks.size(), 1);
			System.assertEquals(con2.listAccountWR.size(), 30);
			con2.TaskToAccountOwner = true;
			con2.createNewTasks();
			System.assertEquals(con2.ListScripTasks.size(), 2);

			List<Task> listTaks2 = [
				SELECT Id, OwnerId
				FROM Task
				WHERE Organization__c  =:acc.Id
			];

			System.assertEquals(acc.OwnerId, listTaks2[0].OwnerId);
		}
	}

	private static User createUser(String name, String email, String user_name, Profile p) {
		return new User(Alias = 'test_usr', Email=email, LastName=name, UserName=user_name,
						EmailEncodingKey='UTF-8', LanguageLocaleKey='en_US',
						LocaleSidKey='en_US', ProfileId = p.Id,
						TimeZoneSidKey='America/Los_Angeles', isActive = true);
	}
	
}