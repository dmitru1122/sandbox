@isTest
global  class ValidationUtilsMockAuthOrg implements HttpCalloutMock{
    private Boolean err;

    public ValidationUtilsMockAuthOrg (Boolean error) {
        this.err = error;
    }
    // Implement this interface method
    global HTTPResponse respond(HTTPRequest request) {
        // Create a fake response
        HttpResponse response = new HttpResponse();
        response.setHeader('Content-Type', 'application/json');
        if (this.err) {
            response.setBody('{"Error": ["TestValue1"], "access_token": "test_tocken", "refresh_token" : "test_refresh_token"}');
        }
        else {response.setBody('{"access_token": "test_tocken", "refresh_token" : "test_refresh_token"}');}
        response.setStatusCode(200);
        return response;
    }
}