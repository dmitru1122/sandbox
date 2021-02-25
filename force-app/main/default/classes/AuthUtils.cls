public with sharing class AuthUtils {
    public static final String REDIRECT_URI = 'oob';
    public static final String MANUAL_AUTH = 'Manual';
    public static final String AUTO_AUTH = 'Automatic';
    public static final String SESSION_EXPIRE = 'The token for the org has expired. Please re-authenticate the org by using the Edit button on the Org details page.';
    private static Credentials__c credentials = Credentials__c.getOrgDefaults();

    public static AuthenticateDetails authenticateAnOrg(String organisationId) {
        AuthenticateDetails authResult = new AuthenticateDetails();
        authResult.isSuccess = false;
        authResult.needToUpdateDetails = false;

        List<Organisation__c> orgLi = [SELECT Id,Username__c,Name, Organisation_ID__c from Organisation__c Where Id = :organisationId LIMIT 1];
        if (orgLi != null && orgLi.size() > 0) {
            List<AuthorizationDetails__c> detailLi = [
                    SELECT AuthorisedUser__c, Name, AccessToken__c, RefreshToken__c, InstanceURL__c, Connected_App_Type__c
                    FROM AuthorizationDetails__c
                    WHERE AuthorisedUser__c = :orgLi[0].Username__c
                    LIMIT 1
            ];
            if (detailLi != null && detailLi.size() > 0) {
                try {
                    Boolean  isValid = authAccessToken(detailLi[0].InstanceURL__c,detailLi[0].AccessToken__c);
                    if(isValid){
                        authResult.isSuccess = true;
                        authResult.details = detailLi[0];
                    }else{
                        authResult.isSuccess = false;
                    }
                    authResult.orgId = orgLi[0].Organisation_ID__c;
                    setOAuth2(authResult, detailLi[0].Connected_App_Type__c);
                    if (!authResult.isSuccess) {
                        String endpoint;
                        //Authentication with refresh token - the primary key probably was expired
                        endpoint = detailLi[0].InstanceURL__c + '/services/oauth2/token?grant_type=refresh_token' +
                                '&refresh_token=' + detailLi[0].RefreshToken__c;
                        if (detailLi[0].Connected_App_Type__c == AUTO_AUTH) {
                            endpoint += '&client_id=' + credentials.Consumer_Key_Auto__c +
                                    '&client_secret=' + credentials.Consumer_Secret_Auto__c;
                        } else {
                            endpoint += '&client_id=' + credentials.ConsumerKey__c +
                                    '&client_secret=' + credentials.ConsumerSecret__c;
                        }

                        HttpRequest httpReq = new HttpRequest();
                        httpReq.setEndpoint(endpoint);
                        httpReq.setMethod('POST');
                        httpReq.setTimeout(120000);
                        Http pipe = new Http();
                        HttpResponse res = pipe.send(httpReq);
                        if (res.getStatusCode() == 200) {
                            System.debug('Refresh token 200'+ res);
                            System.debug('body'+res.getBody());
                            String response = res.getBody();
                            if (response != null && response != '') {
                                Map<String, Object> params = (Map<String, Object>) JSON.deserializeUntyped(response);
                                if (params.containsKey('access_token') && params.get('access_token') != null) {
                                    detailLi[0].AccessToken__c = (String) params.get('access_token');
                                    if (params.containsKey('refresh_token') && params.get('refresh_token') != null)
                                        detailLi[0].RefreshToken__c = (String) params.get('refresh_token');

                                    isValid = authAccessToken(detailLi[0].InstanceURL__c,detailLi[0].AccessToken__c);
                                    if(isValid){
                                        authResult.details = detailLi[0];
                                        authResult.isSuccess = true;
                                        authResult.needToUpdateDetails = true;
                                    }else{
                                        authResult.isSuccess = false;
                                    }        
                                }
                            }
                        }
                    }
                } catch (Exception ex) {
                    authResult.errorMessage = ex.getMessage();
                }
            }
        }
        if (authResult.isSuccess)
            authResult.infoMessage = 'Authentication was successful'; else if (authResult.errorMessage == null)
            authResult.errorMessage = SESSION_EXPIRE;
        return authResult;
    }

    public static Boolean  authAccessToken(String instanceURL,String accessToken){
        Boolean  validConnection = false;
        String endpoint = instanceURL + '/services/data/v43.0/';
        HttpRequest httpReq = new HttpRequest();
        httpReq.setEndpoint(endpoint);
        httpReq.setHeader('Authorization', 'Bearer ' + accessToken);
        httpReq.setMethod('GET');
        httpReq.setTimeout(120000);
        Http pipe = new Http();
        HttpResponse res = pipe.send(httpReq);
        System.debug(res.getStatusCode());
        if (res.getStatusCode() == 200) {
            System.debug('Access token 200'+ res);
            System.debug('body'+res.getBody());
            String response = res.getBody();
            Map<String, Object> params = (Map<String, Object>) JSON.deserializeUntyped(response);
            if (params.containsKey('Error')) {
                //Authentication Failed.
                validConnection = false;
            } else {
                //Return in case of success.
                validConnection = true;
            }
        }
        System.debug(validConnection);
        return validConnection;
    }

    private static void setOAuth2(AuthenticateDetails details, String authType) {
        if (authType == AUTO_AUTH) {
            details.oAuth2.clientId = credentials.Consumer_Key_Auto__c;
            details.oAuth2.clientSecret = credentials.Consumer_Secret_Auto__c;
            details.oAuth2.redirectUri = credentials.Redirect_URL_Auto__c;
        } else {
            details.oAuth2.clientId = credentials.ConsumerKey__c;
            details.oAuth2.clientSecret = credentials.ConsumerSecret__c;
            details.oAuth2.redirectUri = credentials.Redirect_URL__c;
        }
    }


    public class OAuth2 {
        public String clientId;
        public String clientSecret;
        public String redirectUri;

    }

    public class AuthenticateDetails {
        public boolean needToUpdateDetails;
        public boolean isSuccess { get; private set; }
        public String errorMessage;
        public String infoMessage;
        public String orgId;
        public AuthorizationDetails__c details { get; private set; }
        public OAuth2 oAuth2 { get; private set; }

        public AuthenticateDetails() {
            oAuth2 = new OAuth2();
        }
    }

    public class AuthWrapper {
        public String orgId;
        public String accessKey;
        public String refreshKey;
        public String endPoint;
        public OAuth2 oAuth2;
        public String msg;
    }
}