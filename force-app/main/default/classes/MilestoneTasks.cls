public with sharing class MilestoneTasks {

    public List<RadEx__Milestone_Task__c    > MilestoneTasksSummary { get; set; }
    
    public MilestoneTasks()
    {
        MilestoneTasksSummary = [Select Id, Name,
                                    RadEx__Task_Responsible_Person_2__c, RadEx__Task_Complete__c, RadEx__Milestone_Task_Status__c,
                                    RadEx__Risk_Factor__c, RadEx__Project_Milestones__r.RadEx__Goal_Name__c, Readiness__c,
                                    RadEx__Project_Milestones__c, RadEx__Completion_Date__c, RadEx__Project_Milestones__r.RadEx__Goal_Name__r.Name
                                    from RadEx__Milestone_Task__c 
                                    WHERE RadEx__Task_Responsible_Person_2__c =: 
                                    UserInfo.getUserId() AND 
                                    RadEx__Project_Milestones__r.RadEx__Goal_Name__r.RadEx__Project_Status__c =: 'Active' AND
                                    RadEx__Milestone_Task_Status__c NOT IN ('Complete','Canceled','Deferred','N/A')
                                    ];
    }
}