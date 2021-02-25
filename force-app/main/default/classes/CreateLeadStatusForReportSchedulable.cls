global class CreateLeadStatusForReportSchedulable implements System.Schedulable 
{
    global void execute(SchedulableContext ctx)
    {
        CreateLeadStatusForReportBatchable c= new CreateLeadStatusForReportBatchable('FQHC');
        Database.executeBatch(c);
        CreateLeadStatusForReportBatchable c2 = new CreateLeadStatusForReportBatchable('2018 Prospect');
        Database.executeBatch(c2);
    }

}