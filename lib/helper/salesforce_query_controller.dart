// ignore: depend_on_referenced_packages
// ignore_for_file: prefer_interpolation_to_compose_strings, avoid_print, constant_identifier_names, 

import 'dart:convert';
import 'dart:core';
import 'package:expenso/helper/app_constants.dart';
import 'package:expenso/helper/app_secure_file_manager.dart';
import 'package:expenso/helper/salesforce_util.dart';
import 'package:http/http.dart' as http;
import 'package:logger/logger.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
class SalesforceQueryController{

  // const static String VERSION = '59.0'

  // Declare required variables
  static String clientId = '';
  static String clientSecret = '';
  // static String userName = '';
  // static String pwdWithToken = '';
  static String tokenEndpoint = '';
  static String tokenGrantType = '';
  static String compositeUrlForInsert = '';
  static String compositeUrlForUpdate = '';
  static String compositeUrlForDelete = '';
  static String queryUrl = '';
  static bool debug = false; 
  static bool detaildebug = false;

  static String accessToken = '';
  static String instanceUrl = '';
  static String refreshToken = '';
  static String expiryTime = '';
  
  static Logger log = Logger();

  static bool initialized = false;

  static init() async {
    // Load environment variables from the .env file and assign to class variables
    await dotenv.load(fileName: ".env");
    clientId              = AppConstants.OAUTH2_CLIENT_ID_EXPENSO;
    clientSecret          = AppConstants.OAUTH2_CLIENT_SECRET_EXPENSO;
    // userName              = dotenv.env['userName'] ?? '';
    // pwdWithToken          = dotenv.env['pwdWithToken'] ?? '';
    tokenEndpoint         = AppConstants.OAUTH2_TOKEN_ENDPOINT;
    tokenGrantType        = dotenv.env['tokenGrantType'] ?? '';

    compositeUrlForInsert = dotenv.env['compositeUrlForInsert'] ?? ''; // Standard Insert API from Salesforce - '/services/data/v59.0/composite/tree/'
    compositeUrlForUpdate = dotenv.env['compositeUrlForUpdate'] ?? ''; // Standard Update API from Salesforce - '/services/data/v59.0/composite/sobjects/'
    compositeUrlForDelete = dotenv.env['compositeUrlForDelete'] ?? ''; // Standard Delete API from Salesforce - '/services/data/v59.0/composite/sobjects?ids='
    queryUrl              = dotenv.env['queryUrl'] ?? '';              // Standard Query API from Salesforce  - '/services/data/v59.0/query?q='

    debug                 = bool.parse(dotenv.env['debug'] ?? 'false');
    detaildebug           = bool.parse(dotenv.env['detaildebug'] ?? 'false');

    initialized = true;

  }

  // Method to query Salesforce data
  static Future<Map<String, dynamic>> queryFromSalesforce({ required String objAPIName, List<String> fieldList = const [], String whereClause = '', String orderByClause = '', int? count}) async {
    
    if(!initialized) await init();
    accessToken = await SecureFileManager.getAccessToken() ?? 'ERROR occurred to get Access Token';
    instanceUrl = await SecureFileManager.getInstanceURL() ?? 'ERROR occurred to get Instance URL';

    if(detaildebug) log.d('haha instanceUrl inside queryFromSalesforce $instanceUrl');

    Map<String, dynamic> queryFromSalesforceResponse = SalesforceUtil.getGenericResponseTemplate();
    Map<String, dynamic> resp = await _queryFromSalesforce(objAPIName, fieldList, whereClause, orderByClause, count);
    if(detaildebug) log.d('Response is for records : ${resp.toString()}');
    
    // Handle the error scenario with an early return a.k.a. `guard clause` ;)
    if(resp.containsKey('error')){
      queryFromSalesforceResponse['error'] = resp['error'];
      return queryFromSalesforceResponse;
    }

    // Handle the success scenario where data is retrieved,
    // for large data volume like size > 200, the response is chunked 
    // based on the variable `done` in the response, and are collated here
    bool done = (resp.containsKey('done') && resp['done']) ? true : false;
    if(done){
      if(resp.containsKey('data')){
        queryFromSalesforceResponse['data'] = resp;
        if(detaildebug) log.d('I am here ${queryFromSalesforceResponse['data'].toString()}');
      }
      else if(resp.containsKey('error')){
        queryFromSalesforceResponse['errors'] = resp;
      }
    }
    else{
      String nextRecordsUrl = resp['nextRecordsUrl'];
      if(detaildebug) log.d('queryFromSalesforce nextRecordsUrl =>$nextRecordsUrl');
      if(detaildebug) log.d('queryFromSalesforce url =>$instanceUrl$nextRecordsUrl');
      dynamic restRecordsResponse = await http.get(
        Uri.parse('$instanceUrl$nextRecordsUrl'),
        headers: SalesforceUtil.generateLoggedInRequestHeader(accessToken),
        // body: [], //not required for query call
      );
      final Map<String, dynamic> body = json.decode(restRecordsResponse.body);
      if(detaildebug) log.d('Rest query response : ${body.toString()}');
      bool done = (resp.containsKey('done') && resp['done']) ? true : false;
      if(done){
        // Handle when record count is more than 2000
        // Collate the response for all batches
        if(body.containsKey('data') && body['data'].isNotEmpty){
          List<dynamic> existingData = queryFromSalesforceResponse['data'];
          for(dynamic each in body['data']){
            existingData.add(each);
          }
          queryFromSalesforceResponse['data'] = existingData;
        }
        if(body.containsKey('errors') && body['errors'].isNotEmpty){
          List<dynamic> existingErrors = queryFromSalesforceResponse['errors'];
          for(dynamic each in body['errors']){
            existingErrors.add(each);
          }
          queryFromSalesforceResponse['errors'] = existingErrors;
        }
      }
      else{
        // Handle when record count is more than 4000
      }
    }
    if(detaildebug) log.d('Result from queryFromSalesforceResponse $queryFromSalesforceResponse');
    return queryFromSalesforceResponse;
  }

  // private method - gets called from private method `queryFromSalesforce`
  static Future<Map<String, dynamic>> _queryFromSalesforce(String objAPIName, List<String> fieldList, String whereClause, String orderByClause, int? count) async {
    
    Map<String, dynamic> queryFromSalesforceResponse = {};
    
    try{
      dynamic resp = await http.get(
        Uri.parse(SalesforceUtil.generateQueryEndpointUrl(instanceUrl, objAPIName, fieldList, whereClause, orderByClause, count)),
        headers: SalesforceUtil.generateLoggedInRequestHeader(accessToken),  
        // body: [], //not required for query call
      );
      if(detaildebug) log.d('_queryFromSalesforce response.statusCode ${resp.statusCode}');
      if(detaildebug) log.d('_queryFromSalesforce response.body ${resp.body}');
      
      // Now we need to check the statuscode, 
      // A - if its a 200 its a proper data response
      // B - for any error like `Session expired`, the status code is 401

      if (resp.statusCode == 200) {
        // It's status 200, body will be Map<String, dynamic> type
        // e.g. [{"message":"Session expired or invalid","errorCode":"INVALID_SESSION_ID"}] // TBU
        final Map<String, dynamic> body = json.decode(resp.body);      
        
        if(detaildebug) log.d('_queryFromSalesforce Status code (200 block) ${resp.statusCode}');
        if(detaildebug) log.d('_queryFromSalesforce Body (200 block) : ${body.toString()}');
        
        queryFromSalesforceResponse['data'] = body['records'];
        queryFromSalesforceResponse['totalSize'] = body['totalSize'];
        queryFromSalesforceResponse['done'] = body['done'];
        queryFromSalesforceResponse['nextRecordsUrl'] = body['nextRecordsUrl'];
      }
      else if(resp.statusCode == 401){
        // It's status 401, body will be List<dynamic> type
        // e.g. [{"message":"Session expired or invalid","errorCode":"INVALID_SESSION_ID"}]  

        final List<dynamic> respBody = json.decode(resp.body);
        final Map<String, dynamic> body = respBody[0];
        if(detaildebug) log.d('_queryFromSalesforce Status code (401 block) ${resp.statusCode}');
        if(detaildebug) log.d('_queryFromSalesforce Status body (401 block) ${body.toString()}');
        queryFromSalesforceResponse['error'] = body.toString();
      }
      else{
        if(detaildebug) log.d('Status code other than 200, 401 detected.');
        final List<dynamic> respBody = json.decode(resp.body);
        final Map<String, dynamic> body = respBody[0];
        queryFromSalesforceResponse['error'] = body.toString();
      }
    }
    catch(error, stacktrace){
      if(detaildebug) log.e('Error occurred while querying data from Salesforce. Error is : $error, stacktrace : $stacktrace');
      queryFromSalesforceResponse['error'] = error.toString();
    }
    // if(detaildebug) log.d('queryFromSlesforceResponse=> $queryFromSlesforceResponse');
    return queryFromSalesforceResponse;
  }

}
