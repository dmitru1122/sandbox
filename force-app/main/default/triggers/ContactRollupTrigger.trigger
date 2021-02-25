trigger ContactRollupTrigger on Contact (after insert, after update, after delete, after undelete) {
	List<Contact> ctlist;
    Decimal EmailsSent = 0;
    Decimal EmailsOpened = 0;
    Id acctId;
    
    if(Trigger.isDelete) {
        ctlist = Trigger.old;
    }
    else
    {
        ctlist = Trigger.new;
    }
    
    Set<Id> acctIds = new Set<Id>();
    
    for(Contact ct : ctlist) {
        if(ct.AccountId != null) {
            acctIds.add(ct.AccountId);
        }        
    }
    
    if(acctIds.size() > 0) {
    
        List<AggregateResult> agglist = [
            SELECT AccountId, SUM(Of_Emails_Sent__c) EmailsSent, SUM(Of_Times_Opened__c) EmailsOpened 
            FROM Contact 
            WHERE AccountId IN :acctIds
            GROUP BY AccountId
        ];
        
        Map<Id,Decimal> ctsEmailsSent = new Map<Id,Decimal>();
        Map<Id,Decimal> ctsTimesOpened = new Map<Id,Decimal>();
        
        for(AggregateResult ar : agglist) {
            acctId = (Id)ar.get('AccountId');
            EmailsSent = (Decimal)ar.get('EmailsSent');
            EmailsOpened = (Decimal)ar.get('EmailsOpened');
            ctsEmailsSent.put(acctId, EmailsSent);
            ctsTimesOpened.put(acctId, EmailsOpened);
        }    
        
        Map<Id, Account> acctsToUpdate = new Map<Id, Account>([
            SELECT Id, 
            Number_Of_Emails_Sent__c,
            Number_Of_Times_Opened__c
            FROM Account
            WHERE Id IN :acctIds
        ]);
        
        for(Account acct : acctsToUpdate.values()) {
            acct.Number_Of_Emails_Sent__c = ctsEmailsSent.get(acct.Id);
            acct.Number_Of_Times_Opened__c = ctsTimesOpened.get(acct.Id);
        }
        
        update acctsToUpdate.values();
    }
    
}