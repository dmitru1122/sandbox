trigger OrganisationTrigger on Organisation__c (after update) {
    Map <Id, Organisation__c> organisationMigrationMap = new Map<Id, Organisation__c>();
    Set <Id> orgId = new Set<Id>();
    Datetime tempDatetime = null;
    List<Organisation__c> orgList = new List <Organisation__c>();

    if(Trigger.isAfter && Trigger.isUpdate){
        for (Organisation__c org : Trigger.new) {
            if(org.Org_id__c != null && org.Last_Success_Layout_Migration_Date__c != null){
                orgId.add(org.Org_id__c);
            }
        }

        List<Organisation__c> orgsForAcc = [SELECT Org_id__c, isActive__c, Org_id__r.Active__c, Last_Success_Layout_Migration_Date__c
                                            FROM Organisation__c
                                            WHERE Org_id__c IN  :orgId
                                            AND isActive__c = true
                                            AND Org_id__r.Active__c = 'Yes'];

        for (Organisation__c itemOrg : orgsForAcc){
            tempDatetime = itemOrg.Last_Success_Layout_Migration_Date__c;
            orgList.add(itemOrg);

            if(organisationMigrationMap.containsKey(itemOrg.Org_id__c)) {
                Datetime compareDateTime;
                for(Organisation__c orgItem : orgList){
                    compareDateTime= orgItem.Last_Success_Layout_Migration_Date__c;
                }
                if (tempDatetime > compareDateTime){
                    organisationMigrationMap.put(itemOrg.Org_id__c, itemOrg);
                }
            } else {
                organisationMigrationMap.put(itemOrg.Org_id__c, itemOrg);
            }
            orgList.clear();
        }

        if(!organisationMigrationMap.isEmpty()){
            List <Account>  updateLastSuccessfulMigrationDateList = new List<Account>();

            for (Id key : organisationMigrationMap.keySet()) {
                    List<Organisation__c> orgUpdateList = new List<Organisation__c>();
                    orgUpdateList.add(organisationMigrationMap.get(key));

                    for (Organisation__c orgItem : orgUpdateList){
                            updateLastSuccessfulMigrationDateList.add(new Account(
                                    id = key,
                                    Last_Successful_Migration_Date__c = orgItem.Last_Success_Layout_Migration_Date__c));
                    }
                    orgUpdateList.clear();
            }
            update updateLastSuccessfulMigrationDateList;
        }
    }
}