public with sharing class SetResetPwdController {

    public class ApexException extends Exception {}

    private static final String APEX_ENDPOINT_SUBPATH = '/services/data/v42.0/tooling/executeAnonymous?anonymousBody=';
    private static final String SOQL_ENDPOINT_SUBPATH = '/services/data/v42.0/query?q=';

    @AuraEnabled
    public static String getConnectedOrgs(String orgId){
        List<AuthDetailData> data = new List<AuthDetailData>();
        List<SObject> members = new List<SObject>();
        String fieldOrgId;
        
        if(isProdOrg()){
            if(orgId != ''){
                members = Database.query('SELECT Id, MemberEntity, Name FROM EnvironmentHubMember WHERE MemberEntity LIKE \'%' + orgId + '%\'');
            }else{
                members = Database.query('SELECT Id, MemberEntity, Name FROM EnvironmentHubMember');
            }
            
            fieldOrgId = 'MemberEntity';
        }else{
            if(orgId != ''){
                members = Database.query('SELECT Id, MemberEntity__c, Name FROM EnvironmentHubMember__c WHERE MemberEntity__c LIKE \'%' + orgId + '%\'');
            }else{
                members = Database.query('SELECT Id, MemberEntity__c, Name FROM EnvironmentHubMember__c');
            }
            
            fieldOrgId = 'MemberEntity__c';
        }

        for(AuthorizationDetails__c item : AuthorizationDetails__c.getAll().values()){
            for(SObject member : members){
                if(item.Name.indexOf((String)member.get(fieldOrgId)) != -1){
                    AuthDetailData dataItem = new AuthDetailData();
                    dataItem.hostName = item.InstanceURL__c;
                    dataItem.orgId = item.Name;
                    dataItem.orgName = (String)member.get('Name');

                    data.add(dataItem);
                }
            }
        }

        return JSON.serialize(data);
    }

    @AuraEnabled
    public static Boolean isProdOrg () {
        return ![SELECT Id, isSandbox FROM Organization LIMIT 1].isSandbox;
    }

    @AuraEnabled
    public static Contact getContact(String contactId){
        List<Contact> contacts = new List<Contact>([SELECT Id, Name, Account.Org_Id__c FROM Contact WHERE Id =: contactId]);

        if(contacts.size() > 0){
            return contacts.get(0);
        }else{
            return null;
        }
    }

    @AuraEnabled
    public static Account getAccount(String accountId){
        List<Account> accounts = new List<Account>([SELECT Id, Name, Org_Id__c FROM Account WHERE Id =: accountId]);

        if(accounts.size() > 0){
            return accounts.get(0);
        }else{
            return null;
        }
    }

    @AuraEnabled
    public static void updateCaseData(String caseId, String caseStatus, String tmpRassword){
        Case tmpCase = [SELECT Id, Status, Temporary_Password__c FROM Case WHERE Id =: caseId].get(0);

        tmpCase.Status = caseStatus;
        tmpCase.Temporary_Password__c = tmpRassword;

        upsert tmpCase;
    }

    @AuraEnabled
    public static String requestToServer(String orgId, String instanceURL, String query, String requestType){
        String endpoint;
        query = EncodingUtil.urlEncode(query, 'UTF-8').replaceAll('\\+','%20');

        if(requestType == 'SOQL'){
            endpoint = instanceURL + SOQL_ENDPOINT_SUBPATH + query;
        }else if(requestType == 'APEX'){
            endpoint = instanceURL + APEX_ENDPOINT_SUBPATH + query;
        }

        String accessToken = getAccessToken(orgId);

        if(accessToken == ''){
            return '';
        }

        HttpRequest httpReq = new HttpRequest();
        httpReq.setEndpoint(endpoint);
        httpReq.setHeader('Authorization', 'Bearer ' + accessToken);
        httpReq.setMethod('GET');
        httpReq.setTimeout(120000);
        Http pipe = new Http();
        HttpResponse res = pipe.send(httpReq);
        System.debug(res.getStatusCode());
        if (res.getStatusCode() == 200) {
            if(requestType == 'SOQL'){
                return JSON.serialize('[' + res.getBody().substringBetween('[', ']') + ']');
            }else if(requestType == 'APEX'){
                return JSON.serialize(res.getBody());
            }
        }

        return '';
    }

    private static String getAccessToken(String orgId){
        String instanceType = String.valueOf('https://login.salesforce.com').toLowerCase();
        Credentials__c creds = (Credentials__c.getOrgDefaults() != null && Credentials__c.getOrgDefaults().id != null) ? Credentials__c.getOrgDefaults() : new Credentials__c();
        List<AuthorizationDetails__c> detailLi = [
                    SELECT AuthorisedUser__c, Name, AccessToken__c, RefreshToken__c, InstanceURL__c, Connected_App_Type__c, Is_Expired__c
                    FROM AuthorizationDetails__c
                    WHERE Name LIKE : orgId
                    LIMIT 1
            ];
        
        String endpoint = instanceType + '/services/oauth2/token?grant_type=refresh_token' +
            '&refresh_token=' + detailLi[0].RefreshToken__c + 
            '&client_id=' + creds.Consumer_Key_Auto__c +
            '&client_secret=' + creds.Consumer_Secret_Auto__c;

        HttpResponse res =  sendRequest(endpoint, 'POST');
        if(res != null && res.getStatusCode() == 200){
            return getValue(res.getBody(),'access_token');                        
        }else{
            return '';
        }
    }

    private static String getValue(String response, String key){
        Map<String,Object> params = (Map<String,Object>)JSON.deserializeUntyped(response);
        return (String)params.get(key);
    }

    public static HttpResponse sendRequest(String endpoint, String method){
        HttpRequest req = new HttpRequest();
        req.setEndpoint(endpoint);
        req.setMethod(method);

        req.setTimeout(2000);
        Http h = new Http();
        HttpResponse res = h.send(req);
        return res;
    }

    public class AuthDetailData{
        public String orgName;
        public String orgId;
        public String hostName;
    }
}