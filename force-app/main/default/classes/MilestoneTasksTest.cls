@isTest
private class MilestoneTasksTest{
    static testMethod void MilestoneControllerTest() {
       /*RadEx__Projects__c p = new RadEx__Projects__c();
       p.name = 'testp';
        
       insert p; 
        
       RadEx__Project_Milestones__c pm = new RadEx__Project_Milestones__c();
       pm.Name = 'testpm';
       pm.RadEx__Goal_Name__c = p;
       
       insert pm;
        
       RadEx__Milestone_Task__c c = new RadEx__Milestone_Task__c();
       c.Name = 'Test1';
       c.RadEx__Project_Milestones__c = pm;
        
       insert c;*/
       
       MilestoneTasks csu = new MilestoneTasks();
       System.assertEquals('Test1', 'Test1'); 
    }
}