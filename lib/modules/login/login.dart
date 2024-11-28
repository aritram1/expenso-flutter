// ignore_for_file: prefer_const_constructors

import 'package:finmind/helper/app_constants.dart';
import 'package:finmind/helper/app_exception.dart';
import 'package:finmind/helper/salesforce_oauth2_controller.dart';
import 'package:finmind/modules/home/home.dart';
import 'package:finmind/widgets/wavy_clipper_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:logger/logger.dart';
import 'package:finmind/modules/login/login_via_otp.dart';
import 'package:finmind/modules/login/login_via_salesforce.dart';
import 'package:finmind/widgets/login_provider_widget.dart';

class AppLoginPage extends StatefulWidget {
  const AppLoginPage({
    super.key,
    this.message = AppConstants.LOGIN_PAGE_DEFAULT_MESSAGE,
    this.buttonNameSalesforce = AppConstants.LOGIN_PAGE_BUTTON_LOGIN_WITH_SALESFORCE,
    this.buttonNameGoogle = AppConstants.LOGIN_PAGE_BUTTON_LOGIN_WITH_GOOGLE,
    this.buttonNameOTP = AppConstants.LOGIN_PAGE_BUTTON_LOGIN_WITH_OTP,
    this.showLoginButton = true,
  });

  final String message;
  final String buttonNameSalesforce;
  final String buttonNameGoogle;
  final String buttonNameOTP;
  final bool showLoginButton;

  @override
  LoginPageState createState() => LoginPageState();
}

class LoginPageState extends State<AppLoginPage> {
  bool isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Blue Background
          Container(
            color: Colors.blue,
          ),
          // Wavy Purple Section
          ClipPath(
            clipper: WavyClipperWidget(),
            child: Container(
              height: 300,
              color: Colors.purple,
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 48),
                  child: Text(
                    widget.message,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ),
          ),
          // Content Section (Owl Image and Buttons)
          Positioned.fill(
            top: 200, // Adjust this to place content below the wavy section
            child: Container(
              color: Colors.transparent, // Let the blue background show through
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Image Container
                  Container(
                    height: 300,
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.primary,
                      image: const DecorationImage(
                        image: NetworkImage(
                          'https://flutter.github.io/assets-for-api-docs/assets/widgets/owl-2.jpg',
                        ),
                        fit: BoxFit.cover,
                      ),
                      border: Border.all(
                        width: 2,
                        color: Colors.white,
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  const SizedBox(height: 24.0),
                  // Login Buttons
                  Visibility(
                    visible: widget.showLoginButton,
                    child: Column(
                      children: [
                        // Text: Login With
                        Center(
                          child: Text(
                            'Login With',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        
                        const SizedBox(height: 24.0),

                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            LoginProviderWidget(
                              name: widget.buttonNameSalesforce,
                              image: 'assets/appLoginPage/salesforceIcon.png',
                              onTap: () async {
                                BuildContext bc = context;
                                loginWithSalesforce(bc);
                              },
                            ),
                            LoginProviderWidget(
                              name: widget.buttonNameGoogle,
                              image: 'assets/appLoginPage/googleIcon.png',
                              onTap: () async {
                                loginWithGoogle();
                              },
                            ),
                            LoginProviderWidget(
                              name: widget.buttonNameOTP,
                              image: 'assets/appLoginPage/dialerIcon.png',
                              onTap: () async {
                                loginWithOTP();
                              },
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void loginWithSalesforce (BuildContext currentContext) async {

    String? token;

    try{
      token = await SalesforceAuth2Controller.authenticate(context);
      if(token == null) throw AppException('Token is null in FinPlanLoginPage build');
    }
    catch(error, stacktrace){
      Logger().d('Error occurred in Login Page build : $error, stacktrace : $stacktrace}');
    }
    
    setState(() {
      isLoading = false;
    });
          
    Logger().d('Token is $token');

    if (token != null) {
      Navigator.pushReplacement(
        currentContext,
        MaterialPageRoute(
          builder: (currentContext) => const AppHomePage(title: 'Expenso'),
        ),
      );
    } else {
      // Send to Login
      Logger().d('Error');
      Navigator.pushReplacement(
        currentContext,
        MaterialPageRoute(
          builder: (currentContext) => const AppLoginPage(),
        ),
      );
    }
    
    // final String clientId = dotenv.env['clientId'] ?? '';
    // final String redirectUri = dotenv.env['redirectUri'] ?? '';
    // final String tokenUrl = dotenv.env['tokenEndpoint'] ?? '';
    // final String authUrl = dotenv.env['authUrlEndpoint'] ?? '';

    // Logger().d('Trying to login via Salesforce!');
    // Navigator.push(
    //   context,
    //   MaterialPageRoute(builder: (context) => LoginViaSalesforcePage(
    //     authUrl: authUrl, 
    //     clientId: clientId, 
    //     redirectUri: redirectUri, 
    //     tokenUrl: tokenUrl, 
    //     currentContext: context,
    //   )),
    // );
  }

  void loginWithGoogle() async {
    Logger().d('Trying to login via Google!');
    // Implement Google login or navigation logic here
  }

  void loginWithOTP() async {
    Logger().d('Trying to login via OTP!');
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => LoginViaOTPPage()), // Replace with your actual page
    );
  }
}