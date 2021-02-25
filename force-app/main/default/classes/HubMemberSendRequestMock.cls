@isTest
global class HubMemberSendRequestMock implements HttpCalloutMock {
    global HTTPResponse respond(HTTPRequest req) {
        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'application/json');
        res.setStatusCode(200);
        res.setBody('{"access_token":"iddqd","refresh_token":"5Aep861ZBQbtA4s3JV8qifDpT7eh8SkpW0hH6LEzTc5v5QjWkot439s1ggpeipYVISIe.54RSuChkWxCIpP9YEg","signature":"UTs4ARmoeB5wI1cZCOzx7Hw/W6loYorj3Ni0Vk42gIc=","scope":"visualforce refresh_token wave_api web custom_permissions openid chatter_api api id full","id_token":"eyJraWQiOiIyMjgiLCJ0eXAiOiJKV1QiLCJhbGciOiJSUzI1NiJ9.eyJhdF9oYXNoIjoicWNVM0p4R0IwSU45Qk9nSjFO","instance_url":"ololo.ru","id":"test"}');
        return res;
    }
}