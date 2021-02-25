@isTest
global class SetResetPwdControllerTestMock implements HttpCalloutMock{

    global HTTPResponse respond(HTTPRequest request) {
        HttpResponse response = new HttpResponse();
        response.setHeader('Content-Type', 'application/json'); 
        response.setBody('{"instanceURL": "endpoint", "accessToken":"access_token", "query":"query", "requestType", "APEX"}');
        response.setStatusCode(200);
        return response;
    }
}