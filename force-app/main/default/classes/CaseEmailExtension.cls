public with sharing class CaseEmailExtension {

public ID csId {get; set;}  // comes from assignTo on component 

public CaseEmailExtension() { }
    
private final Case currentCase;

public CaseEmailExtension(ApexPages.StandardController currentcase) {
    this.currentCase = (Case)currentcase.getRecord();
  }

public List<EmailMessage> getSortEmails(){
  List<EmailMessage> emails = new List<EmailMessage>();
  if(this.csId != null) {
      String contactEmail = [SELECT Id, ContactEmail FROM Case where Id=:csId].get(0).ContactEmail;
      contactEmail = '%'+contactEmail+'%';
      
      emails = [SELECT Id, FromAddress, ToAddress, BCCAddress, CcAddress, MessageDate, Subject, Incoming, TextBody, HtmlBody, CreatedBy.Name   
            from EmailMessage where ParentId =: this.csId ORDER BY MessageDate DESC ];
  }  
  
  return emails;
}  
  
  
}