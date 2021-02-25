public class CommunityCrossOrgsRegHandler implements Auth.RegistrationHandler{
    public static final string ProfileName = 'Custom Customer Community Login User';
    
    public User createUser(Id portalId, Auth.UserData data){

        //Check that User doesn't already exist

        String customAttributes = data.attributeMap.get('custom_attributes');
        String orgId; String orgName;

        try {
            if(customAttributes.contains('OrgId=')) {
               String tmpOrgId = customAttributes.substringBetween('OrgId=',',');
               orgId = String.isNotBlank(tmpOrgId) ? tmpOrgId.left(15) : ''; 
            }
        } catch (Exception e) {}

        String firstName = data.firstName;
        String lastName = data.lastName;
        String Email = data.email;
        String Username = data.username;
        String UsernameDuplicate = data.username;
        Username = username.substringBefore('@') + '@helpcenter.com';
        UsernameDuplicate = UsernameDuplicate.substringBeforeLast('.') + '.helpcenter.com';

        User u;
        List<User> uList = [
            SELECT Id, ContactId, Profile.Name, username
            FROM User
            WHERE (Username = :username OR Username = :UsernameDuplicate)
            AND FirstName = :firstname 
            AND LastName = :lastname
            AND Email = :email 
            AND isActive = true
            AND Profile.Name =: profileName
        ];

        if(uList.size() > 0) {
            return uList[0];
        } else if(String.isNotBlank(orgId)){
            String searchOrg = '%' + orgId + '%';
            Account a;
            List<Account> aList = [
                SELECT Name
                FROM Account
                WHERE Org_Id__c LIKE :searchOrg
            ];


            if(aList.isEmpty()){
                throw new RegHandlerException('Cannot find Account for User. For help, contact your administrator.');
            } else {
                a = aList[0];
                orgName = a.Name;
            }

            Contact c;
            String searchText = '%' + firstname + '%';

            List<Contact> cList = [
                SELECT Id, FirstName, LastName, Email, AccountId 
                FROM Contact
                WHERE FirstName LIKE :searchText
                AND LastName =:lastname 
                AND Email =:email
                AND AccountId = :a.Id
            ];
            
            if(cList.isEmpty()) {
                
                String indetificator = String.isBlank(orgName) ? string.valueof(system.now()) : orgName;

                c = new Contact();
                c.AccountId = a.Id;
                c.Email = email;
                c.FirstName = firstName + ' ' + indetificator;
                c.LastName = lastName;
                c.FirstName = String.isNotBlank(c.FirstName) ? c.FirstName.left(39) : c.FirstName;

                insert(c);

            } else {
                c = cList[0];
            }
            //The user is authorized, so create their Salesforce User
            u = new User();
            Profile p = [SELECT Id FROM profile WHERE name =: profileName];

            Integer countDuplicates = [SELECT count() FROM User WHERE Username = :username];

            String newUserName = '';
            if( countDuplicates == 0 ) newUserName = username;
            else newUserName = UsernameDuplicate;
            
            //Customize the Username as per your required format.
            //Also check that the Username doesn't already exist.
            //Possibly ensure there are enough org licenses to create a user. Must be 80 characters or less.
            u.username = newUserName; 
            u.email = email;
            u.lastName = lastName;
            u.firstName = firstName;
            String alias = username;
             
            //Alias must be 8 characters or less
            if(alias.length() > 8) alias = alias.substring(0, 8);
            
            u.alias = alias;
            u.languagelocalekey = UserInfo.getLocale();
            u.localesidkey = UserInfo.getLocale();
            u.emailEncodingKey = 'UTF-8';
            u.timeZoneSidKey = 'America/Los_Angeles';
            u.profileId = p.Id;
            u.ContactId = c.Id;
            return u;
             
        } else { throw new RegHandlerException('Cannot find Account. For help, contact your administrator.'); }
         
    }

    // updateUser is called when there is a match with an existing user
    public void updateUser(Id userId, Id portalId, Auth.UserData data){
        User u = new User(id=userId);
        //update(u);
    }

     class RegHandlerException extends Exception {}
}