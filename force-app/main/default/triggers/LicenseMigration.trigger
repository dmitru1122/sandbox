trigger LicenseMigration on sfLma__License__c (after update, after insert) {
    try {
        if (System.Trigger.isInsert || System.Trigger.isUpdate) {
            createAndUpdateAccount(Trigger.new);
        }
    }
    catch (Exception e) {}
    
    public void createAndUpdateAccount (List<sfLma__License__c> listLicense) {
        Set<Id> setLead = new Set<Id>();
        Set<String> setOrgId = new Set<String>();
        for(sfLma__License__c pro : listLicense) {
            if (pro.sfLma__Subscriber_Org_ID__c != null) {
                setOrgId.add(pro.sfLma__Subscriber_Org_ID__c);
            }
            if (pro.sfLma__Lead__c != null) {
                setLead.add(pro.sfLma__Lead__c);
            }
       }
       Map<Id, Lead> mapLead = new Map<Id, Lead>([SELECT Id, Company FROM Lead WHERE Id IN: setLead]);
       List<Account> oldAccounts = [SELECT Id, Name, IsLMA__c, Org_Id__c, Org_Type__c, Package_Status__c , Version_Package__c
                                        FROM Account
                                        WHERE Org_Id__c IN: setOrgId AND IsLMA__c = true];
       Map<String, Account> mapAccounts = new Map<String, Account>();
       for (Account oneAcc: oldAccounts) {
            mapAccounts.put(oneAcc.Org_Id__c, oneAcc);
       }
       List<Account> setUpsert = new List<Account>();
       for(sfLma__License__c pro : listLicense) {
            Account newAcc = mapAccounts.get(pro.sfLma__Subscriber_Org_ID__c) != null ? mapAccounts.get(pro.sfLma__Subscriber_Org_ID__c) : new Account();
            if (newAcc != null) {
                newAcc.IsLMA__c = true;
                newAcc.Org_Id__c = pro.sfLma__Subscriber_Org_ID__c;
                newAcc.Org_Type__c = pro.sfLma__Subscriber_Org_Is_Sandbox__c ? 'Sandbox' : 'Prod/Dev';
                newAcc.Package_Status__c = pro.sfLma__Status__c;
                newAcc.Version_Package__c = pro.sfLma__Version_Number__c;
                Lead newLead = mapLead.get(pro.sfLma__Lead__c) != null ? mapLead.get(pro.sfLma__Lead__c) : new Lead();
                newAcc.Name = newLead.Company != null ? newLead.Company : 'None';
                setUpsert.add(newAcc);
            }
        }
        upsert setUpsert;
    }
}