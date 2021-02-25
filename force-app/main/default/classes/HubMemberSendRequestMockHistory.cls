@isTest
global with sharing class HubMemberSendRequestMockHistory implements HttpCalloutMock {
    global HTTPResponse respond(HTTPRequest req) {
        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'application/json');
        res.setStatusCode(200);
        res.setBody('{"status":"success","result":[{"runId":326,"fromVersion":"1.942.0.2","source":{"id":"00D36000001FqOlEAK","name":"00000003"},"toVersion":null,"status":"created","testMode":true,"started":1609408165107}]}');
        return res;
    }
}