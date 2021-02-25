@isTest
public with sharing class DeleteSuncLogsSchedulerTest {
	@isTest static void testDeleteSuncLogsScheduler() {
		Test.startTest();
		String cronExp = DeleteSuncLogsScheduler.CRON_EXPR;
		String jobId = System.schedule(DeleteSuncLogsScheduler.JOB_NAME, cronExp, new DeleteSuncLogsScheduler());

		CronTrigger ct = [select id, CronExpression, TimesTriggered, NextFireTime from CronTrigger where id = :jobId];

		System.assertEquals(cronExp, ct.CronExpression);
		System.assertEquals(0, ct.TimesTriggered);

		Test.stopTest();
	}
}