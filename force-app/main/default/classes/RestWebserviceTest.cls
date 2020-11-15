@isTest
private class RestWebserviceTest {
    @isTest static void testCreateRequest() {

        //Prepare necessary json data to send
        String jsonstring = 
        '{ ' 
        + '"address": { '
            + '"colorKeys": [ '
                + '"A","G","Z"],'
            + '"values": ['
                + '74,117,115,116,79,110]'
                + '},'
            + '"meta": {'
                + '"digits": 33,'
                + '"processingPattern": "d{5}+[a-z&$§]"'
            + '}'
        +'}';

        //Creating Rest Request and response to store response in
        RestRequest request = new RestRequest();
        RestResponse response = new RestResponse();
        request.requestUri = 'https://juston3-dev-ed.my.salesforce.com/services/apexrest/RestRequest/';
        request.httpMethod = 'POST';
        request.addHeader('Content-Type', 'application/json');
        request.requestBody = Blob.valueOf(jsonstring);

        RestContext.request = request;
        RestContext.response = response;

        //Starting test and calling webservice
        Test.startTest();
        RestWebservice.CreateRequest();
        Test.StopTest();   

        //Checking for Status Code 200 = "OK. The request has succeeded."
        System.assertEquals(200, response.statuscode);
    }   
}
