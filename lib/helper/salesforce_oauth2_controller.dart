import 'dart:async';
import 'dart:convert';
import 'package:expenso/helper/app_constants.dart';
import 'package:expenso/helper/app_exception.dart';
import 'package:expenso/helper/app_secure_file_manager.dart';
import 'package:expenso/helper/salesforce_custom_rest_controller.dart';
import 'package:expenso/modules/login/login_via_salesforce.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:logger/logger.dart';
import 'package:webview_flutter/webview_flutter.dart';

class SalesforceAuth2Controller {

  static String clientId = AppConstants.OAUTH2_CLIENT_ID_EXPENSO;
  static String redirectUri = dotenv.env['redirectUri'] ?? '';
  static String tokenUrl = AppConstants.OAUTH2_TOKEN_ENDPOINT;
  static String authUrl = AppConstants.OAUTH2_AUTH_ENDPOINT;
  static String revokeAccessEndpoint = AppConstants.OAUTH2_REVOKE_ACCESS_ENDPOINT;

  static late final WebViewController webViewController;

  static Future<String?> authenticate(BuildContext context) async {
    return Navigator.push( // Experimantal, can we use pushReplacement?
      context,
      MaterialPageRoute(
        builder: (context) => LoginViaSalesforcePage(
          authUrl: authUrl,
          clientId: clientId,
          redirectUri: redirectUri,
          tokenUrl: tokenUrl,
          currentContext: context,
        ),
      ),
    )
    .then((result) {
      if (result != null) {
        return jsonEncode(result); // The authentication was successful, return the access token.
      } 
      else {
        return null;
      }
    });
  }

  // The method for (logout) from the app
  static Future<void> logout() async {
    String? accessToken = await SecureFileManager.getAccessToken();
    Logger().d('access_token before logout is => $accessToken');
    if(accessToken != null && accessToken != '' && !accessToken.toUpperCase().startsWith('ERROR')) {
      await revokeAccessTokenInSalesforce(accessToken);
    }
    Logger().d('access_token after logout is => ${await SecureFileManager.getAccessToken()}');
  }

  static dynamic revokeAccessTokenInSalesforce(String? accessToken) async{
    final response = await http.post(
      Uri.parse(revokeAccessEndpoint),
      headers: {
        'Content-Type': 'application/x-www-form-urlencoded',
      },
      body: {
        'token': accessToken,
      },
    );
    
    // Handle the Status 200 (Status: OK)
    // Logout successful, ensure to remove the access token
    if (response.statusCode == 200) {
      await SecureFileManager.clearAccessToken();
    }
    
    // Handle the status 302, (STATUS: Redirection)
    else if (response.statusCode == 302) {

      Logger().d('Redirection Happened during logout from the app!');
      final String? redirectedUrl = response.headers['location'];
      Logger().d('redirectedUrl=>${response.headers['location']}');
      
      if (redirectedUrl != null) {
        final redirectedResponse = await http.get(Uri.parse(redirectedUrl));
        Logger().d('After redirection status code: ${redirectedResponse.statusCode}');
        await SecureFileManager.clearAccessToken(); // Logout successful, ensure to remove the access token from the token file
        
      } 
      else {
        Logger().e('Error : StatusCode 302 : RedirectionUrl is empty!');
        throw AppException('Error : StatusCode 302 : RedirectionUrl is empty');
      }
    }
    else {
      // Failed to logout for some strange thing :-]
      throw AppException('Failed to logout: ${response.body}, response status code is ${response.statusCode}');
    }
  }

  static Future<String> loginViaOTP() async{
    final result = SalesforceCustomRestController.callSalesforceAPI(
      endpointUrl: AppConstants.LOGIN_VIA_OTP_ENDPOINT, 
      httpMethod: AppConstants.POST);
    Logger().d('Response inside => $result');
    return result;
  }

}

// Example response structure
// {
//     "access_token": "00D5i00000CIhxb...",
//     "refresh_token": "psdfdd....",
//     "signature": "n2WIUfT8o...",
//     "scope": "cdp_ingest_api custom_permissions cdp_segment_api content cdp_api interaction_api chatbot_api cdp_identityresolution_api wave_api cdp_calculated_insight_api einstein_gpt_api web api id eclair_api pardot_api lightning visualforce cdp_query_api sfap_api openid cdp_profile_api refresh_token pwdless_login_api user_registration_api chatter_api forgot_password full",
//     "id_token": "eyJraW...",
//     "instance_url": "https://home406-dev-ed.develop.my.salesforce.com",
//     "id": "https://login.salesforce.com/id/00D5i00000CIhxbEAD/0055i000007pIKjAAM",
//     "token_type": "Bearer",
//     "issued_at": "171070976...",
//     "api_instance_url": "https://api.salesforce.com..."
// }
