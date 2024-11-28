// ignore_for_file: prefer_const_literals_to_create_immutables, prefer_const_constructors
import 'package:expenso/modules/splash/splash.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:logger/logger.dart';
import 'package:permission_handler/permission_handler.dart';

void main() {

  // initialize dot env
  loadDotEnvFile();

  // If not granted, request for permissions (sms read etc) on app startup
  handlePermissions();

  runApp(const MyApp());
}

// initialize dot env
loadDotEnvFile() async{
  await dotenv.load(fileName: ".env"); 
}

// If not granted, request for permissions (sms read etc) on app startup
handlePermissions() async{
  PermissionStatus status = await Permission.sms.status;
  if (status != PermissionStatus.granted) {
    await Permission.sms.request();
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    Logger().d('Oh hello!');
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'FiNest Main App',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      // home: LoginViaOTPPage()
      home: AppSplashPage()
    );
  }
}


