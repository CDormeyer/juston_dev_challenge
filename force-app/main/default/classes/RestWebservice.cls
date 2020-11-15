@RestResource(urlMapping='/RestRequest/*')
global with sharing class RestWebservice {
    
    @HttpPost
    global static void CreateRequest() {

        //Definine Rest Request
        RestRequest req = RestContext.request;
        RestResponse res = RestContext.response;
        //Defining Custom Object to stre the request in SF
        RestRequest__c resReq = new RestRequest__c();

        //Putting the received JSON ina  String
        String jsonString = req.requestBody.toString();

        //Creating the Parsers to read the JSON //TODO: Really necessary to have 2 parsers?
        JSONParser parserAddr = JSON.createParser(jsonString);
        JSONParser parserMeta = JSON.createParser(jsonString);
        //Getting the data out of the JSON for both classes Address and Meta
        Address adr = createAddress(parserAddr);
        Meta meta = createMeta(parserMeta);

        //Creating the simple sum of all values within Address
        Integer sum = summarize(adr.values);
        //Storing the Results in the defined Result class - also calculating the digitsum of the sum of the values from before
        Result result = new Result(digitsum(sum));

        //Filling in the rest response
        res.addHeader('Content-Type', 'application/json');
        res.responseBody = Blob.valueOf(JSON.serializePretty(result));
        res.statusCode = 200;  

        //Storing the data in Custom Object
        resReq.Request_Header__c = req.headers.toString();
        resReq.Request_Body__c = req.requestBody.toString();
        resReq.Address_colorKeys__c = adr.colorKeys.toString();
        resReq.Address_values__c = adr.values.toString();
        resReq.Meta_digits__c = String.valueOf(meta.digits);
        resReq.meta_processingPattern__c = meta.processingPattern;
        resReq.result__c = String.valueOf(result.result);
        resReq.Response_Header__c = res.headers.toString();
        resReq.Response_Body__c = res.responseBody.toString();

        //Inserting the Custom Object
        insert resReq;        
    }

    //Creating the Address class based on provided parser created from JSON
    public static Address createAddress(JSONParser parser){
        
        //Define variables
        List<String> ckeys = new List<String>();
        List<Integer> vals = new List<Integer>();
        Integer digits;
        String processingPattern;
        
        
        while (parser.nextToken() != null) {
            //Find the Array Start in JSON
            if (parser.getCurrentToken() == JSONToken.START_ARRAY) {
                //And check if this array is for "colorKeys"
                if(parser.getCurrentName() == 'colorKeys'){
                    //Store "colorKeys" values in List
                    while(parser.nextToken() != JSONToken.END_ARRAY){
                        ckeys.add(parser.getText());
                        //System.debug('Added to ckeys List: ' + parser.getText());
                    }
                //else we check if this array is for the "values"
                }else if (parser.getCurrentName() == 'values') {
                    //Store "values" values in List
                    while(parser.nextToken() != JSONToken.END_ARRAY){
                        vals.add(parser.getIntegerValue());
                        //System.debug('Added to vals List: ' + parser.getText());
                    }
                }
            }

        }
        //Return filled in Address 
        Address adr = new Address(ckeys, vals);
        return adr;
    }

    //Creating the Meta class based on provided parser created from JSON
    public static Meta createMeta(JSONParser parser){
        //Define variables
        Integer digits;
        String processingPattern;
        //Go through all tokens
        while (parser.nextToken() != null) {
            //Find the "digits" field
            if(parser.getText() == 'digits'){
                parser.nextToken(); //Grab next token to get the actual value of the field
                digits = parser.getIntegerValue(); //and store it in digits variable
            }else if(parser.getText() == 'processingPattern'){
                parser.nextToken(); //Grab next token to get the actual value of the field
                processingPattern = parser.getText(); //and store it in processingPattern variable
            }

        }
        //Return filled in Meta
        Meta meta = new Meta(digits, processingPattern);
        return meta;
    }

    public static Integer summarize(List<Integer> numbers){
        
        Integer sum = 0;
        for(Integer i : numbers){
                sum += i;
            }
        return sum;
    }
    
    public static Integer digitSum(Integer num){
        Integer digitSum = 0;

        while (num > 0) {
            digitSum = digitSum + (math.mod(num, 10));
            System.debug('Digitsum: ' + digitsum);
            num = num / 10;
            System.debug('Num: ' + num);
        }
        
        return digitSum;
    }

    //Defining the classes based on provided JSON
    public class Address {
		public List<String> colorKeys {get;set;} 
		public List<Integer> values {get;set;} 

		public Address(List<String> ckeys, List<Integer> vals) {
            colorKeys = ckeys;
            values = vals;
        }  
	}
	public class Meta {
		public Integer digits {get;set;} 
		public String processingPattern {get;set;} 

		public Meta(Integer dig, String proc) {
            digits = dig;
            processingPattern = proc; 
		}
    }
    
    public class Result{
		public Integer result {get;set;} 

		public Result(Integer value) {
            result = value;
		}
    }

}