// ignore: depend_on_referenced_packages
// ignore_for_file: prefer_interpolation_to_compose_strings, avoid_print, constant_identifier_names, 

import 'dart:convert';
import 'dart:core';
import 'package:finmind/helper/app_constants.dart';
import 'package:finmind/helper/app_exception.dart';
import 'package:finmind/helper/app_secure_file_manager.dart';
import 'package:http/http.dart' as http;
import 'package:logger/logger.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
class SalesforceLoginController{

  // const static String VERSION = '59.0'

  // Declare required variables
  static String clientId = '';
  static String clientSecret = '';
  // static String userName = '';
  // static String pwdWithToken = '';
  static String tokenEndpoint = '';
  static String tokenGrantType = '';
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

    queryUrl              = AppConstants.QUERY_URL;
    debug                 = AppConstants.DEBUG;
    detaildebug           = AppConstants.DETAIL_DEBUG;

    initialized = true;

  }

  // Method to Login to Salesforce via OTP
  static Future<Map<String, dynamic>> loginToSalesforceWithOTP({required String phone}) async{
    if(!initialized) await init();
    Map<String, dynamic> response = {};
    Logger().d('Response within loginToSalesforceWithRefreshToken => ' + response.toString());
    return Future.value(response);
  }

  // Method to Login to Salesforce with Refresh Token
  static Future<Map<String, dynamic>> loginToSalesforceWithRefreshToken({required String refreshToken}) async{
    if(!initialized) await init();
    Map<String, dynamic> loginResponse = {};
    String? newAccessToken;
    
    try{
      newAccessToken = await getAccessTokenWithRefreshToken(refreshToken: refreshToken);
    
      if(newAccessToken!.isNotEmpty){
        loginResponse['data'] = newAccessToken;
      }
      else{
        // Log an error
        String errorMessage = 'Error occurred to retrieve access token with refresh token!';
        loginResponse['error'] = errorMessage;
        throw AppException(errorMessage);
      }
    }
    catch(error, stacktrace){
      if(detaildebug) log.e('Error occurred while logging into Salesforce. Error is : ${error.toString()}, stacktrace : ${stacktrace.toString()}');
      loginResponse['error'] = error.toString();
    }
    Logger().d('Response within loginToSalesforceWithRefreshToken => ' + loginResponse.toString());
    return loginResponse;
  }


  static Future<String?> getAccessTokenWithRefreshToken({required String refreshToken}) async {
    
    final Logger logger = Logger();

    try {
      
      // Make the POST request to the Salesforce token endpoint
      final response = await http.post(
        Uri.parse(tokenEndpoint),
        headers: {'Content-Type': 'application/x-www-form-urlencoded'},
        body: {
          'grant_type': 'refresh_token',
          'client_id': clientId,
          'client_secret': clientSecret,
          'refresh_token': refreshToken, // 'redirect_uri': redirectUri, // Optional depending on the setup of your Connected App
        },
      );

      // Check for a successful response (status code 200)
      if (response.statusCode == AppConstants.STATUS_CODE_OK) { // Status Code 200 OK

        logger.d('Refresh token request successful. New token ${jsonDecode(response.body)['access_token']}');
        // logger.e('response=>${response.body}');
        
        // Parse the JSON response
        Map<String, dynamic> responseData = jsonDecode(response.body);
        accessToken = responseData['access_token'];
        instanceUrl = responseData['instance_url'];
        refreshToken = responseData['refresh_token'];
        String expiryTimeOfToken = DateTime.now().add(const Duration(minutes: AppConstants.TOKEN_TIMEOUT_MINUTES)).toString();

        // Store the response and other info like token values
        await SecureFileManager.setLoginResponse(response.body);
        await SecureFileManager.setAccessToken(accessToken);
        await SecureFileManager.setInstanceURL(instanceUrl);
        await SecureFileManager.clearRefreshToken();
        await SecureFileManager.setRefreshToken(refreshToken);
        await SecureFileManager.setExpiryTimeOfToken(expiryTimeOfToken);  
        return responseData['access_token'];
      } 
      else {
        logger.e('Failed to refresh token. Status code: ${response.statusCode}, Body: ${response.body}');
        return null;
      }
    } 
    catch (e) {
      logger.e(e);
      logger.e('Error refreshing token');
      return null;
    }
  }
  
}
