// ignore_for_file: prefer_const_literals_to_create_immutables, prefer_const_constructors

import 'package:finmind/helper/app_constants.dart';
import 'package:finmind/modules/home/home.dart';
import 'package:finmind/modules/login/login.dart';
import 'package:flutter/material.dart';
import 'package:logger/logger.dart';

class AppSplashPage extends StatefulWidget {
  const AppSplashPage({super.key, this.title = AppConstants.SPLASH_PAGE_TITLE});
  final String title;
  @override
  State<AppSplashPage> createState() => _MySplashPageState();
}

class _MySplashPageState extends State<AppSplashPage> {
  
  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: getToken(), 
      builder: (context, snapshot) {

        // Show a loading spinner while waiting for the future to complete
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(
            child: CircularProgressIndicator(),
          );
        }
        // Show an error message if something went wrong
        else if (snapshot.hasError) {
          return Center(
            child: Text('Error: ${snapshot.error}'),
          );
        }
        // Check if token is available
        else if(snapshot.data != null /* && snapshot.data!.isNotEmpty*/){
          final String? token = snapshot.data;
          Logger().d('token is retrieved as $token');
          return const AppHomePage(title : AppConstants.HOME_PAGE_TITLE);
        }
        else {
          final String? result = snapshot.data;
          Logger().d('data is retrieved as $result, redirect to login page');
          return const AppLoginPage();
        }
      },
    );
  }
  

  Future<String?> getToken () async{
    String? token;
    token = await Future.delayed(Duration(seconds: 1));
    // token = await SecureFileManager.getAccessToken();
    // if(token != null){
    //   setToken(token);
    // }
    return token;
  }

  // Future<void> setToken (String token) async{
  //   await Future.delayed(Duration(seconds: 1));
  // }
  
}



