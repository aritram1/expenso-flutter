import 'dart:async';
import 'package:finmind/helper/app_constants.dart';
import 'package:finmind/helper/salesforce_login_controller.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:logger/logger.dart';

class SecureFileManager{

  static String clientId = dotenv.env['clientId'] ?? '';
  static String redirectUri = dotenv.env['redirectUri'] ?? '';
  static String tokenUrl = dotenv.env['tokenEndpoint'] ?? '';
  static String authUrl = dotenv.env['authUrlEndpoint'] ?? '';
  static String revokeUrlEndpoint = dotenv.env['revokeUrlEndpoint'] ?? '';

  static const storage = FlutterSecureStorage();
  
  // Access Token Methods
  ////////////////////////////////////////////////////////////////////////
  static Future<String?> getAccessToken() async {
    Logger().d('Inside getAccessToken method of SecureFilemanager class');
    String? accessToken;
    bool expired = await isTokenExpired();
    String? refreshToken = await SecureFileManager.getRefreshToken();
    Logger().d('Inside getAccessToken method of SecureFilemanager class : token expired? ${expired ? 'Yes' : 'No'}');
    if(!expired){
      accessToken = await storage.read(key: 'access_token');
      Logger().d('Token not expired. So returned old token $accessToken');
    }
    else if(expired && refreshToken != null){
      accessToken = await getNewAccessToken(refreshToken);
      Logger().d('Token expired, so this is the new token $accessToken');
    }
    else{
      Logger().d('The refresh token is not present, meaning it is first time login to the app');
      // throw FinPlanException('First time login redirect to login page!');
    }
    return accessToken;
  } 

  static Future<void> setAccessToken(String accesstoken) async {
    await storage.write(key: 'access_token', value: accesstoken);
  }

  static Future<void> clearAccessToken() async {
    await storage.delete(key: 'access_token');
  }

  static Future<String?> getNewAccessToken(String refreshToken) async {
    Logger().d('Inside getNewAccessToken method of SecureFilemanager class. RefreshToken is $refreshToken');
    if(refreshToken.isNotEmpty){
      await SalesforceLoginController.loginToSalesforceWithRefreshToken(refreshToken : refreshToken);
      String newAccessToken = await storage.read(key: 'access_token') ?? 'ERROR';
      return newAccessToken;
    }
    else{
      Logger().d('In SecureFileManager class, refreshToken is retrieved as empty!');
      return null;
    }
  }

  // Since access_token is expired, request a new access_token with the help of refresh_token
  // Login to Salesforce programmatically with help of refresh Token    
  static Future<bool> isTokenExpired() async {
    String? expiryTimeString = await getExpiryTimeOfToken();
    return (
      (expiryTimeString == null) || // meaning the expiryTime is not set at all
      (DateTime.now().isAfter(DateTime.parse(expiryTimeString))) // meaning the token expiry time has already passed
    );
  }

  // Instance URL methods
  //////////////////////////////////////////////////////////////////////////
  static Future<String?> getInstanceURL() async {
    String? instanceUrl = await storage.read(key: 'instance_url');
    return instanceUrl;
  }

  static Future<void> setInstanceURL(String instanceUrl) async {
    await storage.write(key: 'instance_url', value: instanceUrl);
  }

  static Future<void> clearInstanceURL() async {
    await storage.delete(key: 'instance_url');
  }

  // Refresh Token methods
  //////////////////////////////////////////////////////////////////////////
  static Future<String?> getRefreshToken() async {
    String? refreshToken = await storage.read(key: 'refresh_token');
    return refreshToken;
  }

  static Future<void> setRefreshToken(String refreshToken) async {
    await storage.write(key: 'refresh_token', value: refreshToken);
  }

  static Future<void> clearRefreshToken() async {
    await storage.delete(key: 'refresh_token');
  }

  // expiry_time methods
  //////////////////////////////////////////////////////////////////////////
  static Future<String?> getExpiryTimeOfToken() async {
    String? expiryTime = await storage.read(key: 'expiry_time');
    return expiryTime;
  }

  static Future<void> setExpiryTimeOfToken(String time) async {
    await storage.write(key: 'expiry_time', value: time);
  }

  // The entire login response is saved and retrieved in these methods
  //////////////////////////////////////////////////////////////////////////
  static Future<String?> getLoginResponse() async {
    String? loginResponse = await storage.read(key: 'login_response');
    return loginResponse;
  }

  static Future<void> setLoginResponse(String loginResponse) async {
    await storage.write(key: 'login_response', value: loginResponse);
  }

  static Future<void> clearLoginResponse() async {
    await storage.delete(key: 'login_response');
  }

  static Future<void> saveReponseToSecureStorage(Map<String, dynamic> responseData) async {
    await SecureFileManager.setLoginResponse(responseData.toString());
    await SecureFileManager.setAccessToken(responseData['access_token']);
    await SecureFileManager.setInstanceURL(responseData['instance_url']);
    await SecureFileManager.setRefreshToken(responseData['refresh_token']);
    await SecureFileManager.setExpiryTimeOfToken(DateTime.now().add(const Duration(minutes: AppConstants.TOKEN_TIMEOUT_MINUTES)).toString());
  }

}