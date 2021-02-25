global class DeleteSuncLogsScheduler implements Schedulable {

	public static String JOB_NAME = 'DeleteSuncLogsScheduler';
	public static String CRON_EXPR = '0 0 0 ? * 1 *';

	public void execute(SchedulableContext sc) {
		DeleteSuncLogsBatch b = new DeleteSuncLogsBatch();
		Database.executeBatch(b, 1);
	}
	public static void scheduleIt() {
		Integer scheduleInProgress = [
			SELECT count()
			FROM CronTrigger
			WHERE CronJobDetail.Name = :JOB_NAME
		];
		if (scheduleInProgress == 0) {
			System.schedule(JOB_NAME, CRON_EXPR, new DeleteSuncLogsScheduler());
		}
	}

}