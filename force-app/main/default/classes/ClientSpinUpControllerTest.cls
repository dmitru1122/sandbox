@isTest
private class ClientSpinUpControllerTest{
    static testMethod void ClientSpinUpTest() {
       Account a = new Account();
       a.Name = 'Test1';
       
       insert a;
       
       ClientSpinUpController csu = new ClientSpinUpController();
       System.assertEquals(a.name, 'Test1'); 
    }
}