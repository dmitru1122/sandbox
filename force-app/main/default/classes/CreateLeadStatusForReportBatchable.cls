public class CreateLeadStatusForReportBatchable implements Database.Batchable<sObject>
{
    @TestVisible private string query;  
    @TestVisible private string LeadTarget;
    @TestVisible private string RecordTypeName = 'Prospect Account';
    @TestVisible private string Tier = 'Tier 1';
    
    public CreateLeadStatusForReportBatchable(string LeadTargetParam) 
    {
        LeadTarget = LeadTargetParam;
    }
    
    public void execute(Database.BatchableContext BC, List<Contact> scope) 
    {
        // Variables
        String[] Open;
        String[] Working;
        String[] Closed;
        double dblOpen;
        double dblWorking;
        double dblClosed;
        List<LeadStatus__c> leadStatusList;        
        
        // Variable initializers
        dblOpen = 0;
        dblClosed = 0;
        dblWorking = 0;        
        leadStatusList = new List<LeadStatus__c>();
        
        // If no parameter is passed, set a default
        if(LeadTarget == null) {
            LeadTarget = 'FQHC';
        }  
            
        Lead_Status__mdt[] statuses = [SELECT Id, DeveloperName, MasterLabel, BucketStatus__c FROM Lead_Status__mdt ];
        Map<String,String> qtys = new Map<String,String>();
        Map<String,double> totals = new Map<String,double>();
        
        totals.put('Open',0);
        totals.put('Closed',0);
        totals.put('Working',0);
        
        qtys.put('','Open');
        
        for(Lead_Status__mdt ls : statuses) {
            qtys.put(ls.MasterLabel,ls.BucketStatus__c);
        }
        
        // Using SOQL aggregate to collect counts of PPS Contact Statuses
        AggregateResult[] agg = [SELECT COUNT(Id)Qty, PPS_Contact_Status__c FROM Contact WHERE Contact.Account.Lead_Target__c = :LeadTarget AND Contact.Account.RecordType.Name = :RecordTypeName AND Contact.Account.CRM_Tier__c = :Tier GROUP BY PPS_Contact_Status__c];
        
        // Loop through aggregate results to essentially BUCKET the values into OPEN, CLOSED, and WORKING
        for(AggregateResult ar : agg) 
        {
            string fld = (string)ar.get('PPS_Contact_Status__c');            
            string bucket = qtys.get(fld);            
            
            if(totals.containsKey(bucket)) {
                totals.put(bucket, totals.get(bucket) + (double)ar.get('Qty'));
            }
            else {
                totals.put(bucket,(double)ar.get('Qty'));
            }
        }
        
        LeadStatus__c ls = new LeadStatus__c();
        ls.Open__c = (double)totals.get('Open');
        ls.Closed__c = (double)totals.get('Closed');
        ls.Working__c = (double)totals.get('Working');
        ls.Date_Completed__c = Date.today();
        ls.Lead_Target__c = LeadTarget;
        
        leadStatusList.add(ls);
            
        Database.SaveResult[] sr = Database.insert(leadStatusList);
    }
    
    public Database.QueryLocator start(Database.BatchableContext BC) 
    {       
        query = 'SELECT Id, PPS_Contact_Status__c FROM CONTACT WHERE Contact.Account.Lead_Target__c = \'' + LeadTarget + '\' AND Contact.Account.RecordType.Name = \'' + RecordTypeName + '\' LIMIT 200';
        return Database.getQueryLocator(query);
    }
    
    public void finish(Database.BatchableContext BC)
    {
        
    }
    
    
}