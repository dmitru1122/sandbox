@isTest 
Public class CaseEmailExtensionTest{

     static testMethod void EmailExtension() {
      
      Contact TestCon= new Contact();
      TestCon.LastName='Testemail';
      TestCon.Email='Test@sdad.com';
      Insert TestCon;
      
      Case Testcase= new Case();
      Testcase.Status='New';
      Testcase.Origin='Phone';
      Testcase.Contact=TestCon;
      Insert Testcase;
      
      EmailMessage TestEmail = new EmailMessage();
      TestEmail.ValidatedFromAddress='test@xyz.com';
      TestEmail.ToAddress='TestTo@xxy.com';
      TestEmail.Subject='TestSubject';
      TestEmail.Parent=Testcase;
       Test.startTest();
       
       ApexPages.StandardController sc = new ApexPages.StandardController(Testcase);
       CaseEmailExtension Objcon= new CaseEmailExtension();
       CaseEmailExtension Obj= new CaseEmailExtension(sc);
       Obj.csId= Testcase.Id;
       Obj.getSortEmails();       
      Test.stopTest();
    }
}