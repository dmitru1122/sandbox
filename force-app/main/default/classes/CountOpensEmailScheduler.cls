global class CountOpensEmailScheduler implements Schedulable {
	global void execute(SchedulableContext sc) {
		CountOpensEmailBatch ba = new CountOpensEmailBatch();
		Database.ExecuteBatch(ba);
	}
}