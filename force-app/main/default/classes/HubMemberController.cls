public with sharing class HubMemberController {

    public static final String POST = 'POST';
    public static final String GET = 'GET';
    public static final String STATUS_ENDPOINT = 'https://api-zuppio.succraft.com/compliatric/history';
    public static final String TASKS_ENDPOINT = 'https://api-zuppio.succraft.com/compliatric/tasks';
    public static final String SESSION_EXPIRE = 'The token for the org has expired. Please re-authenticate the org by using the Edit button on the Org details page.';
    
    @AuraEnabled
    public static String getTenantId(){
        return UserInfo.getOrganizationId();
    }

    @AuraEnabled
    public static List<AuthorizationDetails__c> getAuthList() {
        List<AuthorizationDetails__c> authDetails = new List<AuthorizationDetails__c>();
        authDetails = AuthorizationDetails__c.getAll().values();
        return authDetails;
    }

    @AuraEnabled
    public static List<sObject> getHubMembersList() {
        if (isProdOrg()) {
            return Database.query('SELECT Id, DisplayName, MemberEntity, Metadata_Source_Org__r.DisplayName, DO_NOT_UPDATE__c, Hide_From_Hub_Navigator__c FROM EnvironmentHubMember');
        } else {
            String query = '';
            query += 'SELECT ';
            query += 'Id, ';
            query += 'Name, ';
            query += 'MemberEntity__c, ';
            query += 'Metadata_Source_Org__r.Name__c, ';
            query += 'DO_NOT_UPDATE__c, ';
            query += 'Last_Success__c, ';
            query += 'Last_Failure__c, ';
            query += 'Hide_From_Hub_Navigator__c ';
            query += 'FROM ';
            query += 'EnvironmentHubMember__c';
            return Database.query(query);
        }
    }

    @AuraEnabled
    public static String getDataToAuth() {
        Credentials__c creds = (
            Credentials__c.getOrgDefaults() != null &&
            Credentials__c.getOrgDefaults().id != null
        )
            ? Credentials__c.getOrgDefaults()
            : new Credentials__c();

        OrgDetail dataLI = new OrgDetail();

        DataToAuth data = new DataToAuth(
            null, creds, dataLI
        );

        return JSON.serialize(data);
    }

    @AuraEnabled
    public static String getTokens(String code) {
        String instanceType = '';
        instanceType = String.valueOf('https://login.salesforce.com');
        instanceType = instanceType.toLowerCase();

        Credentials__c creds = (
            Credentials__c.getOrgDefaults() != null &&
            Credentials__c.getOrgDefaults().id != null
        )
            ? Credentials__c.getOrgDefaults()
            : new Credentials__c();

        DataToAuth data = new DataToAuth(
            null, 
            creds, 
            null
        );

        String endpoint = instanceType;
        endpoint += '/services/oauth2/token';
        endpoint += '?';
        endpoint += 'grant_type=authorization_code';
        endpoint += '&code=';
        endpoint += EncodingUtil.urlEncode(code,'UTF-8');
        endpoint += '&client_id=';
        endpoint += EncodingUtil.urlEncode(data.creds.Consumer_Key_Auto__c,'UTF-8');
        endpoint += '&redirect_uri=';
        endpoint += EncodingUtil.urlEncode(data.creds.Redirect_URL_Hub__c,'UTF-8');
        endpoint += '&client_secret=';
        endpoint += EncodingUtil.urlEncode(data.creds.Consumer_Secret_Auto__c,'UTF-8');
                    
        HttpResponse res = sendRequest(endpoint, POST);

        if (res != null && res.getStatusCode() == 200) {
            TokenData tokenData =  setTokenData(res.getBody());

            updateAuthData(
                tokenData.orgId, 
                tokenData.accessToken, 
                tokenData.refereshToken, 
                getValue(res.getBody(),'instance_url') != null
                    ? getValue(res.getBody(),'instance_url').toLowerCase()
                    : getValue(res.getBody(),'instance_url')
            );
            
            return JSON.serialize(
                getTokenResult('token update correct', true, tokenData.accessToken, tokenData.refereshToken, creds.Instance_URL_Hub__c)
            );
            
        } else {
            return JSON.serialize( getTokenResult('token update request error', false, '', '', '') );
        }
    }

    @AuraEnabled
    public static String openInBrowser(String orgId) {
        String instanceType = '';
        instanceType = String.valueOf('https://login.salesforce.com');
        instanceType = instanceType.toLowerCase();

        Credentials__c creds = (
            Credentials__c.getOrgDefaults() != null &&
            Credentials__c.getOrgDefaults().id != null
        )
            ? Credentials__c.getOrgDefaults()
            : new Credentials__c();

        AuthenticateDetails authResult = new AuthenticateDetails(false, false);

        List<AuthorizationDetails__c> detailLi = [
            SELECT
                AuthorisedUser__c, Name, AccessToken__c, RefreshToken__c, InstanceURL__c, Connected_App_Type__c, Is_Expired__c
            FROM AuthorizationDetails__c
            WHERE Name LIKE : orgId
            LIMIT 1
        ];

        String result = '';

        if (detailLi != null && detailLi.size() > 0) {
            String endpoint = '';
            endpoint += instanceType;
            endpoint += '/services/oauth2/token?';
            endpoint += 'grant_type=refresh_token';
            endpoint += '&refresh_token=';
            endpoint += detailLi[0].RefreshToken__c;
            endpoint += '&client_id=';
            endpoint += creds.Consumer_Key_Auto__c;
            endpoint += '&client_secret=';
            endpoint += creds.Consumer_Secret_Auto__c;

            HttpResponse res =  sendRequest(endpoint, POST);
            if (res != null && res.getStatusCode() == 200) {
                TokenData tokenData =  setTokenData(res.getBody());

                updateAuthData(
                    tokenData.orgId, 
                    tokenData.accessToken, 
                    tokenData.refereshToken, 
                    getValue(res.getBody(),'instance_url') != null
                        ? getValue(res.getBody(),'instance_url').toLowerCase()
                        : getValue(res.getBody(),'instance_url')
                );
                         
                System.debug(detailLi[0].InstanceURL__c + '/secur/frontdoor.jsp?sid=' + tokenData.accessToken + '&retURL=/');

                result += detailLi[0].InstanceURL__c;
                result += '/secur/frontdoor.jsp?sid=';
                result += tokenData.accessToken;
                result += '&retURL=/';
                return result;
            }           
        }
        return result;
    }

    @AuraEnabled
    public static String runDeploy(String body){
        HttpResponse res = sendRequestJson(TASKS_ENDPOINT, body, POST);
        if (res != null) {
            return res.getBody();
        } else {
            return JSON.serialize(new Map<String, Object>{
                'status' => 'error',
                'message' => 'Unknown error'
            });
        }
    }

    @AuraEnabled
    public static String getStatus(){
        String endpoint = STATUS_ENDPOINT;
        endpoint += '?prod=';
        endpoint += isProdOrg();
        endpoint += '&tenantId=';
        endpoint += UserInfo.getOrganizationId();

        HttpRequest req = new HttpRequest();
        req.setEndpoint(endpoint);
        req.setMethod('GET');

        Http http = new Http();
        HTTPResponse res = http.send(req);
        if (res != null) {
            return res.getBody();
        } else {
            return JSON.serialize(new Map<String, Object>{
                'status' => 'error',
                'message' => 'Unknown error'
            });
        }
    }

    @AuraEnabled
    public static String getHistory(String orgId) {
        // GET compliatric/history/:orgId?prod=:isProd&tenantId=:tenantId
        // orgId - Salesforce organization Id
        // isProd - boolean
        // tenantId - org Id

        String endpoint = STATUS_ENDPOINT;
        endpoint += '/';
        endpoint += orgId;
        endpoint += '?prod=';
        endpoint += isProdOrg();
        endpoint += '&tenantId=';
        endpoint += UserInfo.getOrganizationId();

        HttpRequest req = new HttpRequest();
        req.setEndpoint(endpoint);
        req.setMethod('GET');

        Http http = new Http();
        HTTPResponse res = http.send(req);
        if (res != null) {
            return res.getBody();
        } else {
            return JSON.serialize(new Map<String, Object>{
                'status' => 'error',
                'message' => 'Unknown error'
            });
        }
    }

    @AuraEnabled
    public static void updateStatusesData(String jsonStatusesStr){
        List<String> ids = new List<String>();
        List<SObject> members = new List<SObject>();
        List<StatusData> statuses = new List<StatusData>();
        String fieldKey;

        List<Object> objects = (List<Object>)JSON.deserializeUntyped(jsonStatusesStr);

        for(Object item : objects){
            Map<String, Object> dataItem = (Map<String, Object>)item;

            StatusData newStatus = new StatusData(
                ((String)dataItem.get('id')).substring(0, 15), (Long)dataItem.get('lastSuccess'), (Long)dataItem.get('lastFailure')
            );

            statuses.add(newStatus);
            ids.add(((String)dataItem.get('id')).substring(0, 15));
        }

        if (isProdOrg()) {
            members = Database.query('SELECT Id, MemberEntity, Last_Success__c, Last_Failure__c FROM EnvironmentHubMember WHERE MemberEntity IN : ids'); fieldKey = 'MemberEntity';
        } else {
            members = Database.query('SELECT Id, MemberEntity__c, Last_Success__c, Last_Failure__c FROM EnvironmentHubMember__c WHERE MemberEntity__c IN : ids'); fieldKey = 'MemberEntity__c';
        }

        for (SObject member : members) {
            for (StatusData status : statuses) {
                if (member.get(fieldKey) == status.id) {
                    if (status.lastSuccess != null) member.put('Last_Success__c', status.lastSuccess);
                    if (status.lastFailure != null) member.put('Last_Failure__c', status.lastFailure);
                }
            }
        }
        Database.update(members);
    }

    public static void addoAuth2Params(AuthenticateDetails authResult, String orgId, Credentials__c creds){
        authResult.orgId = orgId;
        authResult.oAuth2.clientId = creds.Consumer_Key_Auto__c;
        authResult.oAuth2.clientSecret = creds.Consumer_Secret_Auto__c;
        authResult.oAuth2.redirectUri = creds.Redirect_URL_Auto__c;
    }

    public static UpdateTokenResult getTokenResult(String message, Boolean flag, String accessToken, String refreshToken, String instanceUrl){
        return new UpdateTokenResult(message, flag, accessToken, refreshToken, instanceUrl);
    }

    public static void updateAuthData(String orgId, String aToken, String rToken, String InstanceUrl){
        AuthorizationDetails__c authItem;
        List<AuthorizationDetails__c> authDetailsList = [SELECT Name, AccessToken__c, RefreshToken__c FROM AuthorizationDetails__c WHERE Name LIKE : orgId];

        if(authDetailsList.size() > 0){
            authItem = authDetailsList[0];

            authItem.AccessToken__c = (aToken != null ? aToken : authItem.AccessToken__c);
            authItem.RefreshToken__c = (rToken != null ? rToken : authItem.RefreshToken__c);
        }else{
            authItem = new AuthorizationDetails__c();

            authItem.Name = orgId;
            authItem.InstanceURL__c = InstanceUrl;
            authItem.AccessToken__c = aToken;
            authItem.RefreshToken__c = rToken;
        }

        upsert authItem;
    }

    private static String getValue(String response, String key){
        Map<String,Object> params = (Map<String,Object>)JSON.deserializeUntyped(response);
        return (String)params.get(key);
    }

    public static HttpResponse sendRequestJson(String endpoint, String body, String method){
        System.debug(body);
        HttpRequest req = new HttpRequest();
        req.setEndpoint(endpoint);
        req.setHeader('Content-Type','application/json');
        req.setMethod(method);
        req.setBody(body);

        req.setTimeout(2000);
        Http h = new Http();
        HttpResponse res = h.send(req);
        return res;
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

    @AuraEnabled
    public static Boolean isProdOrg () {
        return ![SELECT Id, isSandbox FROM Organization LIMIT 1].isSandbox;
    }

    @AuraEnabled
    public static String getResponseInfo () {
        Map<String, Object> result = new Map<String, Object>();
        result.put('prod', HubMemberController.isProdOrg());
        
        Map<String, Object> executor = new Map<String, Object>();
        executor.put('id', UserInfo.getUserId());
        executor.put('name', UserInfo.getUserName());
        executor.put('email', UserInfo.getUserEmail());
        result.put('executor', executor);

        return JSON.serialize(result);
    }

    @AuraEnabled
    public static Boolean hideHubMember (String id) {
        SObject hubMember = null;

        if (HubMemberController.isProdOrg()) hubMember = Database.query('SELECT Id, Hide_From_Hub_Navigator__c FROM EnvironmentHubMember WHERE Id = :id');
        else hubMember = Database.query('SELECT Id, Hide_From_Hub_Navigator__c FROM EnvironmentHubMember__c WHERE Id = :id');

        if (hubMember != null) {
            hubMember.put('Hide_From_Hub_Navigator__c', true);
            Database.update(hubMember);
            return true;
        }

        return false;
    }

    @AuraEnabled
    public static Boolean deAuthorizeHubMember (String orgId) {
        if (orgId == null) return false;
        List<AuthorizationDetails__c> authorizationDetail = [SELECT Id, Name FROM AuthorizationDetails__c WHERE Name = :orgId LIMIT 1];
        if (authorizationDetail == null || authorizationDetail.size()  == 0) return false;
        delete authorizationDetail;
        return true;
    }

    @AuraEnabled
    public static Boolean setMetadataSourceOrg (String id, String sourceOrgId) {
        SObject hubMember = null;
        if (HubMemberController.isProdOrg()) hubMember = Database.query('SELECT Id, Metadata_Source_Org__c FROM EnvironmentHubMember WHERE Id = :id');
        else hubMember = Database.query('SELECT Id, Metadata_Source_Org__c FROM EnvironmentHubMember__c WHERE Id = :id');

        if (hubMember != null) {
            hubMember.put('Metadata_Source_Org__c', sourceOrgId);
            Database.update(hubMember);
            return true;
        }
        return false;
    }

    public static TokenData setTokenData(String body){
        String refereshToken = getValue(body,'refresh_token');
        String accessToken = getValue(body,'access_token');
        String orgId = getValue(body,'id').split('id/')[1].split('/')[0];

        return new TokenData(refereshToken, accessToken, orgId);
    }

    public static UserData setUserData(String body){
        String orgUserName = getValue(body,'username');
        String userFullName = getValue(body,'display_name');
        String organisationId = getValue(body,'organization_id');

        return new UserData(orgUserName, userFullName, organisationId);
    }

    public class UserData{
        public String orgUserName;
        public String userFullName;
        public String organisationId;

        public UserData(String orgUserName, String userFullName, String organisationId){
            this.orgUserName = orgUserName;
            this.userFullName = userFullName;
            this.organisationId = organisationId;
        }
    }

    public class TokenData{
        public String refereshToken;
        public String accessToken;
        public String orgId;

        public TokenData(String refereshToken, String accessToken, String orgId){
            this.refereshToken = refereshToken;
            this.accessToken = accessToken;
            this.orgId = orgId;
        }
    }

    public class DataToAuth{
        public Credentials__c org;
        public Credentials__c creds;
        public OrgDetail dataLI;

        public DataToAuth(Credentials__c org, Credentials__c creds, OrgDetail dataLI){
            this.org = org;
            this.creds = creds;
            this.dataLI = dataLI;
        }
    }

    public class InstanceType{
        public Boolean checked;
        public String instanceType;
        public String errorMessage;
    }

    public class OrgDetail{
        public String Id;
        public String orgType;
        public String orgName;
        public String hostName;
    }

    public class UpdateTokenResult{
        public boolean tokenUpdate;
        public String message;
        public String accessToken;
        public String refreshToken;
        public String instanceUrl;

        public UpdateTokenResult(String message, boolean tokenUpdate, String accessToken, String refreshToken, String instanceUrl){
            this.message = message;
            this.tokenUpdate = tokenUpdate;
            this.accessToken = accessToken;
            this.refreshToken = refreshToken;
            this.instanceUrl = instanceUrl;
        }
    }

    public class OAuth2 {
        public String clientId;
        public String clientSecret;
        public String redirectUri;

    }

    public class AuthenticateDetails {
        public boolean needToUpdateDetails;
        public boolean isSuccess;
        public String errorMessage;
        public String infoMessage;
        public String orgId;
        public AuthorizationDetails__c details;
        public OAuth2 oAuth2;

        public AuthenticateDetails(boolean isSuccess, boolean needToUpdateDetails){
            this.isSuccess = isSuccess;
            this.needToUpdateDetails = needToUpdateDetails;
            this.oAuth2 = new OAuth2();
        }

        public AuthenticateDetails() {
            oAuth2 = new OAuth2();
        }
    }

    public class StatusData{
        public String id;
        public Datetime lastSuccess;
        public Datetime lastFailure;

        public StatusData(String id, Long lastSuccess, Long lastFailure){
            this.id = id;
            this.lastSuccess = (lastSuccess != null ? Datetime.newInstance(lastSuccess) : null);
            this.lastFailure = (lastFailure != null ? Datetime.newInstance(lastFailure) : null);

            System.debug('id: ' + id + ' lastSuccess: ' + lastSuccess + ' lastFailure: ' + lastFailure);
        }
    }


    //
    //  FAKE
    //

    public static void fakeMethods() {
        Map<String, Object> result = new Map<String, Object>();
        result.put('getChildsList', HubMemberController.getChildsList());
        result.put('getEnrolmentYearClassesList', HubMemberController.getEnrolmentYearClassesList());
        result.put('getEnrolmentYearGendersList', HubMemberController.getEnrolmentYearGendersList());
        result.put('getTargetsList', HubMemberController.getTargetsList());
        result.put('getPeriodsList', HubMemberController.getPeriodsList());
        result.put('getStagesList', HubMemberController.getStagesList());
    }

    public static List<Map<String, String>> getChildsList() {
        List<Map<String, String>> childs = new List<Map<String, String>>();
    
        childs.add(new Map<String, String>{
          'value' => 'teachers',
          'label' => 'Teachers',
          'order' => '0'
        });
    
        childs.add(new Map<String, String>{
          'value' => 'extern',
          'label' => 'Extern',
          'order' => '1'
        });
    
        return childs;
    }
    
    public static List<Map<String, String>> getEnrolmentYearClassesList() {
        List<Map<String, String>> result = new List<Map<String, String>>();
        result.add(new Map<String, String>{
          'value' => 'class9',
          'label' => 'Class 9',
          'order' => '0'
        });
        result.add(new Map<String, String>{
          'value' => 'class8',
          'label' => 'Class 8',
          'order' => '1'
        });
        result.add(new Map<String, String>{
          'value' => 'class7',
          'label' => 'Class 7',
          'order' => '2'
        });
        result.add(new Map<String, String>{
          'value' => 'class6',
          'label' => 'Class 6',
          'order' => '3'
        });
        result.add(new Map<String, String>{
          'value' => 'class5',
          'label' => 'Class 5',
          'order' => '4'
        });
        result.add(new Map<String, String>{
          'value' => 'class4',
          'label' => 'Class 4',
          'order' => '5'
        });
        result.add(new Map<String, String>{
          'value' => 'class3',
          'label' => 'Class 3',
          'order' => '6'
        });
        result.add(new Map<String, String>{
          'value' => 'class2',
          'label' => 'Class 2',
          'order' => '7'
        });
        result.add(new Map<String, String>{
          'value' => 'class1',
          'label' => 'Class 1',
          'order' => '8'
        });
        result.add(new Map<String, String>{
          'value' => 'classT',
          'label' => 'Class T',
          'order' => '9'
        });
        result.add(new Map<String, String>{
          'value' => 'total',
          'label' => 'Total',
          'order' => '10'
        });
        return result;
    }

    public static List<Map<String, String>> getEnrolmentYearGendersList() {
        List<Map<String, String>> result = new List<Map<String, String>>();
        result.add(new Map<String, String>{
          'value' => 'boy',
          'label' => 'Boys',
          'order' => '0'
        });
        result.add(new Map<String, String>{
          'value' => 'girl',
          'label' => 'Girls',
          'order' => '1'
        });
        result.add(new Map<String, String>{
          'value' => 'total',
          'label' => 'Total',
          'order' => '2'
        });
        return result;
    }

    public static List<Map<String, String>> getTargetsList() {
        List<Map<String, String>> targets = new List<Map<String, String>>();
    
        targets.add(new Map<String, String>{
          'value' => 'previous',
          'label' => 'Previous',
          'order' => '0'
        });
    
        targets.add(new Map<String, String>{
          'value' => 'current',
          'label' => 'Current',
          'order' => '1'
        });
    
        targets.add(new Map<String, String>{
          'value' => 'difference',
          'label' => 'Difference',
          'order' => '2'
        });
    
        targets.add(new Map<String, String>{
          'value' => 'target',
          'label' => 'Target',
          'order' => '3'
        });
    
        targets.add(new Map<String, String>{
          'value' => 'remains',
          'label' => 'Remains',
          'order' => '4'
        });
    
        return targets;
    }

    public static List<Map<String, String>> getPeriodsList() {
        List<Map<String, String>> periods = new List<Map<String, String>>();
    
        periods.add(new Map<String, String>{
          'value' => 'previous',
          'label' => 'Previous',
          'order' => '0'
        });
    
        periods.add(new Map<String, String>{
          'value' => 'current',
          'label' => 'Current',
          'order' => '1'
        });
    
        return periods;
    }

    public static List<Map<String, String>> getStagesList() {
        List<Map<String, String>> stages = new List<Map<String, String>>();
    
        stages.add(new Map<String, String>{
          'value' => 'ART',
          'label' => 'Applications Received and Treated',
          'order' => '0'
        });
    
        stages.add(new Map<String, String>{
          'value' => 'Accepted',
          'label' => 'Accepted',
          'order' => '1'
        });
    
        stages.add(new Map<String, String>{
          'value' => 'Admitted',
          'label' => 'Admitted',
          'order' => '2'
        });
    
        stages.add(new Map<String, String>{
          'value' => 'Refused',
          'label' => 'Refused',
          'order' => '3'
        });
    
        stages.add(new Map<String, String>{
          'value' => 'WBA',
          'label' => 'Withdrawn Before Acceptation',
          'order' => '4'
        });
    
        stages.add(new Map<String, String>{
          'value' => 'WAA',
          'label' => 'Withdrawn After Acceptation',
          'order' => '5'
        });
    
        stages.add(new Map<String, String>{
          'value' => 'Waitlist',
          'label' => 'Waitlist',
          'order' => '6'
        });
    
        stages.add(new Map<String, String>{
          'value' => 'Deferred',
          'label' => 'Deferred',
          'order' => '7'
        });
    
        stages.add(new Map<String, String>{
          'value' => 'Pipeline',
          'label' => 'Pipeline',
          'order' => '8'
        });
    
        stages.add(new Map<String, String>{
          'value' => 'BR',
          'label' => 'Beds Reserved',
          'order' => '9'
        });
    
        stages.add(new Map<String, String>{
          'value' => 'R1',
          'label' => '1st Round',
          'order' => '10'
        });
    
        stages.add(new Map<String, String>{
          'value' => 'R2',
          'label' => '2nd Round',
          'order' => '11'
        });
    
        stages.add(new Map<String, String>{
          'value' => 'RI',
          'label' => 'Re-Inscriptions',
          'order' => '12'
        });
    
        return stages;
    }
}