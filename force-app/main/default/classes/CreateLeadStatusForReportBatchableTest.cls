@isTest 
private class CreateLeadStatusForReportBatchableTest{
    static testMethod void validateCreateLead() 
    {
        Account a = new Account();  
        a.Name = 'AtestAccont';
        a.Lead_Target__c = 'FQHC';
        a.CRM_Tier__c = 'Tier 1';
        
        Id recordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName()
                  .get('Prospect Account').getRecordTypeId();
        
        a.RecordTypeId = recordTypeId;       
        
        insert a;
        List<Contact> contacts = new List<Contact>();
        for(Integer i=0 ;i <2;i++)
        {
            Contact c= new Contact();
            c.PPS_Contact_Status__c = 'Open';
            c.LastName = 'TestContaftcLastName'+i;
            contacts.add(c);
        }
        
        for(Integer i=0 ;i <2;i++)
        {
            Contact c= new Contact();
            c.PPS_Contact_Status__c = '';
            c.LastName = 'TestContaftcLastName'+i;
            contacts.add(c);
        }
        
        for(Integer i=0 ;i <2;i++)
        {
            Contact c= new Contact();
            c.PPS_Contact_Status__c = 'Cosed';
            c.LastName = 'TestContaftcLastName'+i;
            contacts.add(c);
        }
        
        for(Integer i=0 ;i <2;i++)
        {
            Contact c= new Contact();
            c.PPS_Contact_Status__c = 'Closed';
            c.LastName = 'TestContaftcLastName'+i;
            contacts.add(c);
        }
        
        for(Integer i=0 ;i <2;i++)
        {
            Contact c= new Contact();
            c.PPS_Contact_Status__c = 'Working';
            c.LastName = 'TestContaftcLastName'+i;
            contacts.add(c);
        }
        
        insert contacts;
        
        Test.startTest();

        CreateLeadStatusForReportBatchable obj = new CreateLeadStatusForReportBatchable('FQHC');
        DataBase.executeBatch(obj); 
            
        Test.stopTest();
    }
    
    public static testMethod void testschedule() 
    {
        Test.StartTest();
        CreateLeadStatusForReportSchedulable sh1 = new CreateLeadStatusForReportSchedulable();

        String sch = '0 0 23 * * ?'; 
        system.schedule('Test Territory Check', sch, sh1); 
        Test.stopTest(); 
    }
    
}