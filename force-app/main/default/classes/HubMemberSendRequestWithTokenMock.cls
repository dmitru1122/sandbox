@isTest
global class HubMemberSendRequestWithTokenMock implements HttpCalloutMock {
    global HTTPResponse respond(HTTPRequest req) {
        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'application/json');
        res.setStatusCode(200);
        res.setBody('{"instance_url":"oloo.ru", "access_token":"iddqd","refresh_token":"5Aep861ZBQbtA4s3JV8qifDpT7eh8SkpW0hH6LEzTc5v5QjWkot439s1ggpeipYVISIe.54RSuChkWxCIpP9YEg", "id":"https://login.salesforce.com/id/00D2w000005lwpHEAQ/0052w000003FDAoAAO","asserted_user":true,"user_id":"0052w000003FDAoAAO","organization_id":"00D2w000005lwpHEAQ","username":"max@mclaren.com","nick_name":"max","display_name":"Evgen Orlovski","email":"orloffski@gmail.com","email_verified":true,"first_name":"Evgen"}');
        return res;
    }
}