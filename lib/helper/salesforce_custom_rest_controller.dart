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

class SalesforceCustomRestController{

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

  

  // Method to connect to custom REST API
  static Future<String> callSalesforceAPI({required String endpointUrl, required httpMethod, dynamic body}) async{
    
    if(!initialized) await init();
    accessToken = await SecureFileManager.getAccessToken() ?? 'ERROR occurred to get Access Token';
    instanceUrl = await SecureFileManager.getInstanceURL() ?? 'ERROR occurred to get Instance URL';
  
    String epUrl = '$instanceUrl$endpointUrl'; 

    if(detaildebug) log.d('epUrl=>' + epUrl);   
    dynamic resp = await _callSalesforceAPI(httpMethod : httpMethod, epUrl : epUrl, body : body);
    
    if(detaildebug) log.d('resp.body=> ${resp.body}');
    
    return resp.body;
  }
  
  // private method  - gets called from `callSalesforceAPI` method
  static dynamic _callSalesforceAPI({required String httpMethod, required String epUrl, dynamic body}) async {
    dynamic resp;
    if(httpMethod == AppConstants.GET){
      resp = await http.get(
        Uri.parse(epUrl), 
        headers: SalesforceUtil.generateLoggedInRequestHeader(accessToken)
      );
    }
    else if(httpMethod == AppConstants.POST){
      resp = await http.post(
        Uri.parse(epUrl), 
        headers: SalesforceUtil.generateLoggedInRequestHeader(accessToken), 
        body: jsonEncode(body)
      );
    }
    else if(httpMethod == AppConstants.PATCH){
      resp = await http.patch(
        Uri.parse(epUrl), 
        headers: SalesforceUtil.generateLoggedInRequestHeader(accessToken),
        body: jsonEncode(body)); 
    }
    else if(httpMethod == AppConstants.DELETE){
      resp = await http.delete(
        Uri.parse(epUrl), 
        headers: SalesforceUtil.generateLoggedInRequestHeader(accessToken), 
        body: jsonEncode(body)
      );
    }
    if(detaildebug) log.d('epUrl $epUrl');
    return resp;
  }
  
}
