// import 'package:expenso_app/screens/app_home/finplan__app_home_page.dart';
// import 'package:expenso_app/screens/login_page/finplan__app_login_view.dart';
// import 'package:expenso_app/util/finplan__secure_filemanager.dart';
// import 'package:flutter/material.dart';
// import 'package:logger/logger.dart';

// class FinPlanSplashPage extends StatefulWidget {
//   const FinPlanSplashPage({Key? key, required this.title}) : super(key: key);

//   final String title;

//   @override
//   State<FinPlanSplashPage> createState() => _FinPlanSplashPageState();
// }

// class _FinPlanSplashPageState extends State<FinPlanSplashPage> {
  
//   @override
//   void initState() {
//     super.initState();
//     // No Custom Initialization logic yet
//   }

//   // retrieveTokenData(){
//   //   return SecureFileManager.retrieveTokenData();
//   // }

//   // getExpiryTimeOfToken(){
//   //   return SecureFileManager.getExpiryTimeOfToken();
//   // }

//   @override
//   Widget build(BuildContext context) {
//     Logger().d('Inside the build method FinPlanSplashPage!');
//     return FutureBuilder<String?>(
//       future: getData(),
//       builder: (context, snapshot) {
//         if (snapshot.connectionState == ConnectionState.waiting) {
//           return const Center(child: CircularProgressIndicator());
//         } 
//         else if (snapshot.hasError) {
//           return SafeArea(child: Center(child: Text('Error: ${snapshot.error}')));
//         } 
//         else {
//           Logger().d('Inside the block that shows getAccessToken is finished with value : ${snapshot.data}');
//           if (snapshot.data != null && snapshot.data != '' && !snapshot.data!.toUpperCase().startsWith('ERROR')){
//             // Navigator.of(context).pop();
//             return const Scaffold(
//               body: FinPlanAppHomePage(title: 'Expenso')
//             );
//           } 
//           else {
//             return const Scaffold(
//               body: FinPlanAppLoginPage()
//             );
//           }
//         }
//       },
//     );
//   }
  
//   // The main method that retrieves the access token for further use
//   Future<String> getData() async {
//     Logger().d('Inside getData method');
//     final result = await SecureFileManager.getAccessToken() ?? 'ERROR Occurred inside Splash Page build method';
//     return result;
//   }

// }
