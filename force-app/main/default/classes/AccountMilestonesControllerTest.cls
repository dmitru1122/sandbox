@isTest
public with sharing class AccountMilestonesControllerTest{


    public static testmethod void GoalsPMilestonesControllerTester(){

        RadEx__Projects__c proj1 = new RadEx__Projects__c();
        insert proj1;
        
        Account act = new Account();
        act.Name = 'test';
        act.Startup_Project__c = proj1.Id;
        insert act;
        
        Test.startTest();

            AccountMilestonesController goalPMilestonesController = new AccountMilestonesController (
                new ApexPages.StandardController(act)
            );
            List<RadEx__Project_Milestones__c> milestones = goalPMilestonesController .getMilestones();
            PageReference pageRef = goalPMilestonesController.redirectToMillestoneTaskManagement;
            PageReference pafeRefFromMethod = goalPMilestonesController.redirectToMillestone();
            System.assertEquals(act.name, 'test');
        Test.stopTest();
    }

}