@isTest
public class CommunityCrossOrgsRegHandlerTest { 
    
    @isTest
    static void testCreateAndUpdateUser() {


        Test.startTest();

            Account a = new Account(Name = 'sourcedomain', Org_Id__c = '123456789012345');
            insert a;

            Profile userProfile = [SELECT Id FROM Profile WHERE Name='System Administrator'];

            CommunityCrossOrgsRegHandler handler = new CommunityCrossOrgsRegHandler();

            Auth.UserData sampleData = new Auth.UserData('testId', 'testFirst', 'testLast',
            'testFirst testLast', 'testuser@example.org', null, 'testusername@example.org', 'en_US', 'salesforce',
                                                            null, new Map<String, String>{'language' => 'en_US', 'urls' => 'https://sourcedomain.com', 'custom_attributes' => '{FirstName=customFirstname, LastName=customLastname, Email=custom@email.com, Username=custom@username.com, OrgId=123456789012345, OrgName=cust, omOrgName}'});
            User u = handler.createUser(null, sampleData);
            System.assertEquals('testusername@helpcenter.com', u.userName);
            System.assertEquals('testuser@example.org', u.email);
            System.assertEquals('testLast', u.lastName);
            System.assertEquals('testFirst', u.firstName);
            System.assertEquals('testuser', u.alias);

            

        Test.stopTest();
            
           
        insert u;

        String uid = u.Id;
        
        sampleData = new Auth.UserData('testId', 'testFirst', 'testLast',
        'testFirst testLast', 'testuser@example.org', null, 'testusername@example.org', 'en_US', 'salesforce',
                                                        null, new Map<String, String>{'language' => 'en_US', 'urls' => 'https://sourcedomain.com', 'custom_attributes' => '{FirstName=customFirstname, LastName=customLastname, Email=custom@email.com, Username=custom@username.com, OrgId=123456789012345, OrgName=customOrgName}'});
        handler.updateUser(uid, null, sampleData);
        
        User updatedUser = [SELECT userName, email, firstName, lastName, alias, Profile.Name FROM user WHERE id=:uid];
        System.assertEquals('testLast', updatedUser.lastName);
        System.assertEquals('testFirst', updatedUser.firstName);
        System.assertEquals(CommunityCrossOrgsRegHandler.ProfileName, updatedUser.Profile.Name);

    }
    

    @isTest
    static void testIfAccountExists2(){

    
        Test.startTest();

            Account a = new Account(Name = 'sourcedomain', Org_Id__c = '123456789012345');
            insert a;
            CommunityCrossOrgsRegHandler handler = new CommunityCrossOrgsRegHandler();
            Auth.UserData sampleData = new Auth.UserData('testId', 'testFirst', 'testLast',
                'testFirst testLast', 'testuser@example.org', null, 'testusername@example.org', 'en_US', 'salesforce',
                                                            null, new Map<String, String>{'language' => 'en_US', 'urls' => 'https://sourcedomain.com', 'custom_attributes' => '{FirstName=customFirstname, LastName=customLastname, Email=custom@email.com, Username=custom@username.com, OrgId=123456789012345, OrgName=customOrgName}'});
            User u = handler.createUser(null, sampleData);

        Test.stopTest();
        insert u;
        
        User usr = [SELECT Id, ContactId FROM User WHERE Id = :u.id];
        Contact c = [SELECT Id, AccountId FROM Contact WHERE Id = :usr.ContactId];
        Account acc = [SELECT Id, Name FROM Account WHERE Id = :c.AccountId];
        System.assertEquals(acc.Name, 'sourcedomain');
    }

     @isTest
    static void testIfAccountFail(){

        CommunityCrossOrgsRegHandler handler = new CommunityCrossOrgsRegHandler();
        Auth.UserData sampleData = new Auth.UserData('testId', 'testFirst', 'testLast',
            'testFirst testLast', 'testuser@example.org', null, 'testusername@example.org', 'en_US', 'salesforce',
                                                         null, new Map<String, String>{'language' => 'en_US', 'urls' => 'https://sourcedomain.com', 'custom_attributes' => '{FirstName=customFirstname, LastName=customLastname, Email=custom@email.com, Username=custom@username.com, OrgId=123456789012345, OrgName=customOrgName}'});
       
       try {
            User u = handler.createUser(null, sampleData);
            insert u;
            System.assert(false, 'new user should not be inserted without an account 1');
        } catch(Exception e ) {
            System.assert(true, 'new user should not be inserted without an account 2');
        }
    }
}