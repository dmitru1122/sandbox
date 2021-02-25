@isTest
public class CommunityPubllicOrgsRegHandlerTest {
    @isTest
    static void testCreateAndUpdateUser() { 


        Profile adminUserProfile = [SELECT Id FROM Profile WHERE Name='System Administrator'];

		User testAdmin = new User(
			Alias = 'testUser',
			Email = 'yttuelvf@clrmail.com',
			LanguageLocaleKey = 'en_US',
			EmailEncodingKey = 'UTF-8',
			FirstName = 'John',
			LastName = 'Doe',
			LocaleSidKey = 'en_US',
			ProfileId = adminUserProfile.id,
			TimeZoneSidKey = 'America/Los_Angeles',
			UserName = 'test.knowledge.base@compliatric.com'
		);

        insert testAdmin;

        CommunityPubllicOrgsRegHandler handler = new CommunityPubllicOrgsRegHandler();

        Auth.UserData sampleData = new Auth.UserData('testId', 'testFirst', 'testLast',
            'testFirst testLast', 'testuser@example.org', null, 'testusername@example.org', 'en_US', 'salesforce',
                                                         null, new Map<String, String>{'language' => 'en_US', 'urls' => 'https://sourcedomain.com', 'custom_attributes' => '{FirstName=customFirstname, LastName=customLastname, Email=custom@email.com, Username=custom@username.com, OrgId=123456789012345, OrgName=customOrgName}'});
        User userItem = handler.createUser(null, sampleData);

        handler.updateUser(testAdmin.Id, null, sampleData);

        System.assertEquals(testAdmin.Id, userItem.Id);
        //System.assertEquals(testAdmin.FirstName, userItem.FirstName);
        //System.assertEquals(testAdmin.LastName, userItem.LastName);
        //System.assertEquals(testAdmin.UserName, userItem.UserName);

       
        //insert u;

    }




}