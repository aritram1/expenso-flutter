// ignore: depend_on_referenced_packages
// ignore_for_file: prefer_interpolation_to_compose_strings, avoid_print, constant_identifier_names, 

import 'dart:convert';
import 'dart:core';
import 'dart:math';
import 'package:finmind/helper/app_constants.dart';
import 'package:finmind/helper/app_secure_file_manager.dart';
import 'package:finmind/helper/salesforce_util.dart';
import 'package:finmind/modules/account/util_account.dart';
import 'package:http/http.dart' as http;
import 'package:logger/logger.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
class SalesforceDMLController{

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

    accessToken = await SecureFileManager.getAccessToken() ?? 'ERROR occurred to get Access Token';
    instanceUrl = await SecureFileManager.getInstanceURL() ?? 'ERROR occurred to get Instance URL';
    
    initialized = true;

  }

  // Method to create, update or delete records to/from Salesforce
  static Future<Map<String, dynamic>> dmlToSalesforce({
    String opType = '', 
    String objAPIName = '', 
    List<Map<String, dynamic>> fieldNameValuePairs = const [], 
    List<String> recordIds = const [], 
    bool hardDelete = false, 
    int batchSize = 200}) async{
    
    if(!initialized) await init();
    
    Map<String, dynamic> dmlToSalesforceResponse = SalesforceUtil.getGenericResponseTemplate();
    
    List<Map<String, dynamic>> eachInsertUpdateBatch = [];
    List<String> eachDeleteBatch = [];
    
    int eachBatchSize;
    int batchCount = 0;
    Map<String, dynamic> resp;

    if(opType == AppConstants.DELETE){
      while(recordIds.isNotEmpty){
        eachBatchSize = min(recordIds.length, batchSize); // check the size of the list and split in a batch of 200
        for(int i=0; i<eachBatchSize; i++){
          eachDeleteBatch.add(recordIds.removeLast());
        }
        resp = await _deleteFromSalesforce(objAPIName, eachDeleteBatch, batchCount , hardDelete);
        if(detaildebug) log.d('resp in delete : $resp');

        // Process the response
        dmlToSalesforceResponse = processDMLResponse1(resp : resp, inputResponse : dmlToSalesforceResponse);
        
        eachDeleteBatch = [];
        batchCount++;
      }
    }
    else if(opType == AppConstants.INSERT || opType == AppConstants.UPDATE){
      while(fieldNameValuePairs.isNotEmpty){
        
        // Add the required value attribute and reference as applicable for successful insert/update
        for(int i=0; i<fieldNameValuePairs.length; i++){
          dynamic each = fieldNameValuePairs[i];
          if(!each.containsKey('attributes')){
            each['attributes'] = {
              "type": objAPIName,
              "referenceId": "ref$i"
            };
          }
        }

        // check the size of the list and split in a batch of `batchSize` which by default is 200
        eachBatchSize = min(fieldNameValuePairs.length, batchSize); 
        
        for(int i=0; i<eachBatchSize; i++){
          eachInsertUpdateBatch.add(fieldNameValuePairs.removeLast());
        }
        resp = await _dmlToSalesforce(opType, objAPIName, eachInsertUpdateBatch, batchCount : batchCount);
        log.d('resp in insert update : $resp');
       
        // Process the response
        dmlToSalesforceResponse = processDMLResponse1(resp : resp, inputResponse : dmlToSalesforceResponse);
        eachInsertUpdateBatch = [];
        batchCount++;
      }
    }
    if(detaildebug) log.d('Final value of dmlToSalesforceResponse=>' + dmlToSalesforceResponse.toString());
    return dmlToSalesforceResponse;
  }

  // private method  - gets called from `dmlToSalesforce` method
  static Future<Map<String, dynamic>> _dmlToSalesforce(String opType, String objAPIName, List<Map<String, dynamic>> fieldNameValuePairs, {int batchCount = 0}) async{
    Map<String, dynamic> dmlResponse = SalesforceUtil.getGenericResponseTemplate();

    Map<String, dynamic> body = {};
    try{
      if(opType == AppConstants.INSERT){
        body = await _insertToSalesforce(objAPIName, fieldNameValuePairs, batchCount);
        // if(detaildebug) log.d('body for insert : $body');
      }
      else{
        body = await _updateToSalesforce(objAPIName, fieldNameValuePairs, batchCount);
        // if(detaildebug) log.d('body for update : $body');
      }

      if(detaildebug) log.d('I am here line 236');
      if(detaildebug) log.d('body[] : ${body.toString()}');
      // Collate the response for all batches
      if(body.containsKey('data') && body['data'].isNotEmpty){
        List<dynamic> existingData = dmlResponse['data'];
        for(dynamic each in body['data'] as List<dynamic>){
          existingData.add(each);
        }
        dmlResponse['data'] = existingData;
      }
      if(body.containsKey('errors') && body['errors'].isNotEmpty){
        List<dynamic> existingErrors = dmlResponse['errors'];

        if (body['errors'] is List) { // If 'errors' is a list, iterate over it
          for (dynamic each in body['errors'] as List<dynamic>) {
            existingErrors.add(each);
          }
        } 
        else if (body['errors'] is String) { // If 'errors' is a string, add it directly
          existingErrors.add(body['errors']);
        } 
        else {
          // Handle other types if necessary (e.g., Map, or null)
          print('Unexpected error format: ${body['errors']}');
        }

        // for(dynamic each in body['errors'] as List<dynamic>){
        //   existingErrors.add(each);
        // }

        dmlResponse['errors'] = existingErrors;
      }
    }
    catch(error,stacktrace){
      // if(detaildebug) log.d('body for error scenario : $body');
      List<dynamic> catchBlockErrors = [];
      catchBlockErrors.add(error.toString() + 'stacktrace => ' + stacktrace.toString());
      dmlResponse['errors'] = catchBlockErrors;
    }
    if(detaildebug) log.d('DML response for $batchCount : $dmlResponse');
    return dmlResponse;
  }

  // private method - gets called from private method `_dmlToSalesforce`
  static Future<Map<String, dynamic>> _insertToSalesforce(String objAPIName, List<Map<String, dynamic>> fieldNameValuePairs, int batchCount) async{
    
    Map<String, dynamic> insertResponse = SalesforceUtil.getGenericResponseTemplate(); 
    
    Map<String, dynamic> body = {};
    dynamic resp;
    try{
      resp = await http.post(
        Uri.parse(SalesforceUtil.generateEndpointUrl(opType : AppConstants.INSERT, instanceUrl: instanceUrl, objAPIName : objAPIName)), // both are required params
        headers: SalesforceUtil.generateLoggedInRequestHeader(accessToken),
        body: jsonEncode(SalesforceUtil.generateBody(opType : AppConstants.INSERT, objAPIName : objAPIName, fieldNameValuePairs : fieldNameValuePairs, batchCount : batchCount)),
      );
      int statusCode = resp.statusCode;
      
      log.d('_insertToSalesforce StatusCode $statusCode');
      log.d('_insertToSalesforce response ${resp.body.toString()}');
      
      body = json.decode(resp.body);
      if(detaildebug) log.d('ResponseBody for _insertToSalesforce => ${body.toString()}');
      if(statusCode == 201 && !body['hasErrors']){
        if(detaildebug) log.d('Inside 201 $body');
        insertResponse['data'] = body['results'];
      }
      else{ // non 201 code is returned
        // if(detaildebug) log.d('Response code other than 200/201 detected $statusCode');
        if(detaildebug) log.d('outside 201 $body');
        if(body['hasErrors']){
          insertResponse['errors'] = body['results'];
        }
      } 
    }
    catch(error, stacktrace){
      insertResponse['errors'] = error.toString() + 'stacktrace :' + stacktrace.toString();
    }
    if(detaildebug) log.d('Final insertResponse output : $insertResponse');
    return insertResponse;
  }

  // private method - gets called from private method `_dmlToSalesforce`
  static Future<Map<String, dynamic>> _updateToSalesforce(String objAPIName, List<Map<String, dynamic>> fieldNameValuePairs, int batchCount) async{
    Map<String, dynamic> updateResponse = SalesforceUtil.getGenericResponseTemplate();
    
    // Not required to check loggin info here, since we check them with expiry_time of token value
    // if(!isLoggedIn()) await loginToSalesforce();
    
    try{
      dynamic resp = await http.patch(
        Uri.parse(SalesforceUtil.generateEndpointUrl(opType : AppConstants.UPDATE, instanceUrl: instanceUrl, objAPIName : objAPIName)), // required param is opType
        headers: SalesforceUtil.generateLoggedInRequestHeader(accessToken),
        body: jsonEncode(SalesforceUtil.generateBody(opType : AppConstants.UPDATE, objAPIName : objAPIName, fieldNameValuePairs : fieldNameValuePairs, batchCount : batchCount)),
      );
      final List<dynamic> body = json.decode(resp.body);
      // if(detaildebug) log.d('Inside _updateToSalesforce StatusCode: ${resp.statusCode} || body: $body || updateResponse: $updateResponse');
      updateResponse = processDMLResponse2(statusCode : resp.statusCode, inputBody : body, inputResponse : updateResponse);
    }
    catch(error, stacktrace){
      updateResponse['error'] = error.toString() + 'stacktrace : ' + stacktrace.toString();
    }
    // if(detaildebug) log.d('Response from _updateToSalesforce $updateResponse');
    return updateResponse;
  }

  // private method - gets called from private method `_dmlToSalesforce`
  static Future<Map<String, dynamic>> _deleteFromSalesforce(String objAPIName, List<String> recordIds, int batchCount, bool hardDelete) async{
    Map<String, dynamic> deleteResponse = SalesforceUtil.getGenericResponseTemplate();
    
    try{
      dynamic resp = await http.delete(
        Uri.parse(
          SalesforceUtil.generateEndpointUrl(
            opType : AppConstants.INSERT, 
            instanceUrl: instanceUrl,
            objAPIName : objAPIName, 
            recordIds : recordIds, 
            batchCount : batchCount, 
            hardDelete : hardDelete)),
        headers: SalesforceUtil.generateLoggedInRequestHeader(accessToken),
        // body : <not_applicable> since body is not required for delete call
      );
      final List<dynamic> body = json.decode(resp.body);
      // if(detaildebug) log.d('StatusCode: ${resp.statusCode} || body: $body || deleteResponse : $deleteResponse');
      deleteResponse = processDMLResponse2(statusCode : resp.statusCode, inputBody : body, inputResponse: deleteResponse);
      // if(detaildebug) log.d('After processResponse $deleteResponse');
    }
    catch(error, stacktrace){
      deleteResponse['error'] = error.toString() + 'stacktrace ' + stacktrace.toString();
    }
    // if(detaildebug) log.d('Response from _deleteResponse $deleteResponse');
    return deleteResponse;  
  }

  // Part 1 : Part 1 of the specific method to process the DML response (especially for multi part results)
  static Map<String, dynamic> processDMLResponse1({required dynamic resp, required Map<String, dynamic> inputResponse}){
    if(resp.containsKey('data') && resp['data'].isNotEmpty){
      List<dynamic> existingData = inputResponse['data'];
      for(dynamic each in resp['data']){
        existingData.add(each);
      }
      inputResponse['data'] = existingData;
    }
    if(resp.containsKey('errors') && resp['errors'].isNotEmpty){
      List<dynamic> existingErrors = inputResponse['errors'];
      for(dynamic each in resp['errors']){
        existingErrors.add(each);
      }
      inputResponse['errors'] = existingErrors;
    }
    return inputResponse;
  }
  
  // Part 2 : Part 2 of the specific method to process the DML response (especially for multi part results)
  static dynamic processDMLResponse2({required int statusCode, required List<dynamic> inputBody, required Map<String, dynamic> inputResponse}){
    for(dynamic rec in inputBody){
      if(statusCode == 200){
        if(rec.containsKey('success') && rec['success']){ // i.e. rec['success'] exists and it's value is true
          dynamic recordId = rec['id'];
          List<dynamic> existingData = inputResponse['data'];
          existingData.add(recordId);
          inputResponse['data'] = existingData;
        }
        else{
          dynamic errorMessage;
          List<dynamic> existingErrors = inputResponse['errors'];
          for(dynamic e in rec['errors']){
            errorMessage = '${rec['id']} : ${e['message']}';
            existingErrors.add(errorMessage);
          }
          inputResponse['errors'] = [existingErrors];
        } 
      }
      else{
        if(detaildebug) log.d('Response code other than 200 detected : $statusCode');
        inputResponse['errors'] = ['${inputBody.toString()} url: $compositeUrlForUpdate}'];
      }
    }
    return inputResponse;
  }
  
}
