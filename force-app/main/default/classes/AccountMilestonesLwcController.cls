/**
 * Created by sergeyzh on 13.10.20.
 */

public with sharing class AccountMilestonesLwcController {

    @AuraEnabled (cacheable=true)
    public static id getProjectId (id goalId) {

        Account goal = [
                SELECT Id, Startup_Project__c
                FROM Account
                WHERE Id =: goalId

        ];

        //return goal.Startup_Project__c;
        return id.valueOf('a2x6s0000008RPSAA2');

    }

    @AuraEnabled (cacheable=true)
    public static List<RadEx__Project_Milestones__c> getMilestones(id projectId) {

        List<RadEx__Project_Milestones__c> milestones = [
                SELECT
                        Id, Name, RadEx__Actual_Milestone_Hours__c, RadEx__Estimated_Milestone_Complete_Date__c,
                        RadEx__Milestone_Percent_Complete__c, RadEx__Milestone_Percent_of_Goal__c, RadEx__Milestone_Manager__c
                FROM RadEx__Project_Milestones__c
                WHERE RadEx__Goal_Name__c =: projectId
                ORDER BY RadEx__Milestone_order__c
        ];

        return milestones ;
    }



}