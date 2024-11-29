import 'dart:convert';
import 'dart:io';
import 'package:expenso/helper/app_constants.dart';
import 'package:expenso/helper/app_exception.dart';
import 'package:expenso/helper/app_secure_file_manager.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:logger/logger.dart';
import 'package:webview_flutter/webview_flutter.dart';

class LoginViaGooglePage extends StatefulWidget {
  final String authUrl;
  final String clientId;
  final String redirectUri;
  final String tokenUrl;
  final BuildContext currentContext;

  const LoginViaGooglePage({super.key, 
    required this.authUrl,
    required this.clientId,
    required this.redirectUri,
    required this.tokenUrl,
    required this.currentContext,
  });

  @override
  LoginViaGooglePageState createState() => LoginViaGooglePageState();
}

class LoginViaGooglePageState extends State<LoginViaGooglePage> {
  
  late WebViewController webViewController;

  @override
  Widget build(BuildContext context) {
    
    String componentName = 'login_via_google.dart';
    Logger().d('Build Method run for : $componentName');

    String url = '${widget.authUrl}?response_type=code&client_id=${widget.clientId}&redirect_uri=${widget.redirectUri}';

    return Scaffold(
      body: SafeArea(
        child: WebView(
          initialUrl: url,
          javascriptMode: JavascriptMode.unrestricted,
          onWebViewCreated: (controller) {
            webViewController = controller;
          },
          navigationDelegate: (NavigationRequest request) async {
            Logger().d('Navigating to: ${request.url}');
            Logger().d('RedirectURI is ${widget.redirectUri}');
        
            if (request.url.startsWith(widget.redirectUri)) {
              final uri = Uri.parse(request.url);
              final code = uri.queryParameters['code'];
              Logger().d('Code is $code');
              if (code != null) {
                final tokenResponse = await http.post(
                  Uri.parse(widget.tokenUrl),
                  headers: {
                    HttpHeaders.contentTypeHeader: 'application/x-www-form-urlencoded',
                  },
                  body: {
                    'grant_type': 'authorization_code',
                    'client_id': widget.clientId,
                    'redirect_uri': widget.redirectUri,
                    'code': code,
                  },
                );
                if (tokenResponse.statusCode == AppConstants.STATUS_CODE_OK) { // Status Code = 200 OK
                  Logger().d('Status Code, 200, OK detected! Response text : ${tokenResponse.body}');
                  
                  // Save the entire response in secure storage for later use
                  await SecureFileManager.setLoginResponse(tokenResponse.body);

                  Map<String, dynamic> parsedResponse = jsonDecode(tokenResponse.body);
                  
                  if (parsedResponse['access_token'] != null || parsedResponse['instance_url'] != null) {
                    await SecureFileManager.saveReponseToSecureStorage(parsedResponse);
                    // await SecureFileManager.setAccessToken(parsedResponse['access_token']);
                    // await SecureFileManager.setRefreshToken(parsedResponse['refresh_token']);
                    // await SecureFileManager.setInstanceURL(parsedResponse['instance_url']);
                    // await SecureFileManager.setExpiryTimeOfToken(
                    //   DateTime.now().add(const Duration(minutes: AppConstants.TOKEN_TIMEOUT_MINUTES)).toString()
                    // );
                  } 
                  else {
                    throw AppException('Failed to get Access Token: ${tokenResponse.body}');
                  }

                  // Pop the webview and return the parsed response
                  Navigator.of(widget.currentContext).pop(parsedResponse);
                } else {
                  // Handle failure
                  Logger().d('Failed to get access token: ${tokenResponse.body}');
                  Navigator.of(widget.currentContext).pop(null);
                }
              }
              return NavigationDecision.prevent;
            }
            return NavigationDecision.navigate;
          },
        ),
      ),
    );
  }
}
