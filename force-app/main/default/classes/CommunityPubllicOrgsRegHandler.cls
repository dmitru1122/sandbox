public with sharing class CommunityPubllicOrgsRegHandler  implements Auth.RegistrationHandler{
    public User createUser(Id portalId, Auth.UserData data){

        String CommunityUserName = Test.isRunningTest() ? 'test.knowledge.base@compliatric.com' :  'knowledge.base@compliatric.com'; 

        //List<User> uList = [SELECT Id FROM User Where Id='0053C000001rwyK'];
        List<User> uList = [
            SELECT Id 
            FROM User
            WHERE Username =: CommunityUserName
            LIMIT 1
        ];

        if(!uList.isEmpty() ) {
            return uList[0];
        } else { throw new RegHandlerException('Cannot find public User. For help, contact your administrator.');  }
    }

    public void updateUser(Id userId, Id portalId, Auth.UserData data){
        User u = new User(id=userId);
    }

    class RegHandlerException extends Exception {}

}