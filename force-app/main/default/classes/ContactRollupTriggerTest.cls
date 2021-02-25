@isTest
private class ContactRollupTriggerTest {
    @isTest
    static void testTriggerUpdateRecords() {
        Account acc = new Account(
            Name = 'Test Account',
            Number_Of_Emails_Sent__c = 0,
            Number_Of_Times_Opened__c = 0
        );
        
        insert acc;
        
        List<Contact> cts = new List<Contact>();
        
        Contact ct1 = new Contact(
        	FirstName = 'Boyd',
            LastName = 'Contact',
            Email = 'test@example.com',
            Of_Emails_Sent__c = 0,
            Of_Times_Opened__c = 0,
            AccountId = acc.Id
        );
        
        Contact ct2 = new Contact(
        	FirstName = 'Boyd',
            LastName = 'Contact 2',
            Email = 'test@example.com',
            Of_Emails_Sent__c = 0,
            Of_Times_Opened__c = 0,
            AccountId = acc.Id
        );
        
        Contact ct3 = new Contact(
        	FirstName = 'Boyd',
            LastName = 'Contact 3',
            Email = 'test@example.com',
            Of_Emails_Sent__c = 0,
            Of_Times_Opened__c = 0,
            AccountId = acc.Id
        );
        
        cts.add(ct1);
        cts.add(ct2);
        cts.add(ct3);
        
        insert cts;
        
        //System.assertEquals(0,acc.Number_of_Emails_Sent__c);
        //System.assertEquals(0,acc.Number_of_Times_Opened__c);
        
        Test.startTest();
        
        ct2.Of_Emails_Sent__c = 3;
        ct2.Of_Times_Opened__c = 2;
        ct3.Of_Emails_Sent__c = 4;
        ct3.Of_Times_Opened__c = 4;
		
        List<Database.SaveResult> result = Database.update(cts,false);
        
        Test.stopTest();
        
        for(Database.SaveResult sr : result) {            
            System.assert(sr.isSuccess());
            System.assert(sr.getErrors().size() == 0);
        }
        
        
        
    }
    
    @isTest    
    static void testTriggerDeleteRecords() {
        Account acc = new Account(
            Name = 'Test Account',
            Number_Of_Emails_Sent__c = 0,
            Number_Of_Times_Opened__c = 0
        );
        
        insert acc;
        
        List<Contact> cts = new List<Contact>();
        
        Contact ct1 = new Contact(
        	FirstName = 'Boyd',
            LastName = 'Contact',
            Email = 'test@example.com',
            Of_Emails_Sent__c = 3,
            Of_Times_Opened__c = 3,
            AccountId = acc.Id
        );
        
        Contact ct2 = new Contact(
        	FirstName = 'Boyd',
            LastName = 'Contact 2',
            Email = 'test@example.com',
            Of_Emails_Sent__c = 8,
            Of_Times_Opened__c = 7,
            AccountId = acc.Id
        );
        
        Contact ct3 = new Contact(
        	FirstName = 'Boyd',
            LastName = 'Contact 3',
            Email = 'test@example.com',
            Of_Emails_Sent__c = 4,
            Of_Times_Opened__c = 4,
            AccountId = acc.Id
        );
        
        cts.add(ct1);
        cts.add(ct2);
        cts.add(ct3);
        
        insert cts;
        
        Test.startTest();
		
        Database.DeleteResult dresult = Database.delete(ct2,false);
        
        Test.stopTest();
        
        System.assert(dresult.isSuccess());
        System.assert(dresult.getErrors().size() == 0);
    }
}