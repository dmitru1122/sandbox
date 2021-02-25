public with sharing class ClientSpinUpController {

    public List<Account> ClientSpinUpSummary { get; set; }
    
    
    
    public ClientSpinUpController () {                 
        ClientSpinUpSummary = [Select Id, Name, Owner.Name, OwnerId, RecordType.Name, Startup_Project__c, 
                                RadEx__Default_Survey_Contact__c, Startup_Project__r.Name, Time_Zone__c,
                                    Project_Complete__c, Client_Primary_Project_Contact__c,
                                        Lic_Ordered__c, Kit_Delivered__c, Kick_Off_Call_Completed__c,
                                            Go_Live_Date_BASIC_USERS__c,
                                            Data_Loaded__c, Org_Tested__c, Users_Deployed__c, Training_Complete__c,
                                                Startup_Project__r.RadEx__Desired_Completion_Date__c, Startup_Project__r.RadEx__Project_Estimated_Completed_Date__c,
                                                Startup_Project__r.RadEx__ProjectPerComplete__c, Compliance_Manual_Sent__c
                                     from Account WHERE RecordType.Name =: 'Compliatric Start-up Customer' AND Active__c ='Yes'];
    
    }
    

}