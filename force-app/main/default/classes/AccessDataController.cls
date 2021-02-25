public class AccessDataController {
    private Account acct;
    public Access_Data__c AccessData{get;set;}
    public Boolean NotError{get;set;}
    public AccessDataController(ApexPages.StandardController stdController) {
        NotError = true;
        acct = (Account)stdController.getRecord();
        acct = [SELECT Id, Org_Type__c, IsLMA__c, Access_Data__c FROM Account WHERE Id =: acct.Id];
        List<Access_Data__c> listData = new List<Access_Data__c>();
        if (acct.Access_Data__c != null) {
        	listData = [SELECT Id, Password__c, Username__c, Token__c FROM Access_Data__c WHERE Id =: acct.Access_Data__c];
        }
        if (listData == null || listData.isEmpty()) {
            AccessData = new Access_Data__c();
        }
        else {
            AccessData = listData[0];
        }
        if (!acct.IsLMA__c) {
            NotError = false;
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR,'This account is not of LMA');
			ApexPages.addMessage(myMsg);
        }
    }
    
    public PageReference Save() {
        if (!String.isBlank(AccessData.Password__c) && !String.isBlank(AccessData.Username__c)) {
            upsert AccessData;
            acct.Access_Data__c = AccessData.Id;
            upsert acct;
            return new PageReference('/' + acct.Id);
        }
        else {
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR,'Fields are not filled');
			ApexPages.addMessage(myMsg);
        }
        return null;
    } 
    
    public PageReference Back() {
        return new PageReference('/' + acct.Id);
    }
    
    public PageReference Backs() {
        String BacksTo = '/';
        acct = [SELECT Id, Org_Type__c, IsLMA__c, Access_Data__c FROM Account WHERE Id =: acct.Id];
        if (acct != null) {
            BacksTo = BacksTo + acct.Org_Type__c;
            BacksTo = BacksTo + '&';
            BacksTo = BacksTo + acct.IsLMA__c;
            BacksTo = BacksTo + '&';
            BacksTo = BacksTo + acct.Access_Data__c;
            BacksTo = BacksTo + '&';
            BacksTo = BacksTo + acct.Id;
        }
        if (BacksTo != '/') {
            PageReference ref = new PageReference(BacksTo);
            return ref;
        }
        return null;
    }
    
    
}