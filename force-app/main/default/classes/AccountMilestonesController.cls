public with sharing class AccountMilestonesController {

    public Id goalId { get; set; }
    public Id projectId { get; set; }

    public AccountMilestonesController (ApexPages.StandardController controller) {

        this.goalId = controller.getId();

        System.debug(goalId);

            Account goal = [
            SELECT Id, Startup_Project__c
            FROM Account
            WHERE Id =: goalId
        ];

        this.projectId = goal.Startup_Project__c;
    }


    public PageReference redirectToMillestoneTaskManagement { get {

        return redirectToMillestone();
    }}

    public PageReference redirectToMillestone (){

        PageReference pageRef = Page.RadEx__MillestoneTaskManagement;

        if (projectId != NULL){
            pageRef.getParameters().put('id', projectId);
        }
        else {
            pageRef.getParameters().put('updateId', goalId);
            pageRef.getParameters().put('new', '1');
        }

        pageRef.getParameters().put('retUrl', '/' + goalId);
        pageRef.setRedirect(true);
        return pageRef;

    }

    public List<RadEx__Project_Milestones__c> getMilestones() {

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