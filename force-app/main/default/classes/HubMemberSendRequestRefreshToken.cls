@isTest
global class HubMemberSendRequestRefreshToken implements HttpCalloutMock {
    global HTTPResponse respond(HTTPRequest req) {
        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'application/json');
        res.setStatusCode(200);
        res.setBody('{"access_token":"access_token","refresh_token":"refresh_token","id":"login.salesforce.com/id/12345/12345"}');
        return res;
    }
}