// ignore_for_file: prefer_const_constructors, use_build_context_synchronously

import 'package:finmind/helper/app_constants.dart';
import 'package:finmind/helper/app_secure_file_manager.dart';
import 'package:finmind/helper/salesforce_oauth2_controller.dart';
import 'package:finmind/modules/account/all_accounts.dart';
import 'package:finmind/modules/calendar/calendar.dart';
import 'package:finmind/modules/login/login.dart';
import 'package:finmind/modules/message/all_messages.dart';
import 'package:finmind/modules/transaction/all_transactions.dart';
import 'package:finmind/widgets/appbar_widget.dart';
import 'package:finmind/widgets/tile_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:intl/intl.dart';
import 'package:logger/logger.dart';

class AppHomePage extends StatefulWidget {

  const AppHomePage({super.key, required this.title});
  
  final String title;

  @override
  State<AppHomePage> createState() => _AppHomePageState();
}

class _AppHomePageState extends State<AppHomePage> {
    
  static final Logger log = Logger();

  // static bool isLoggedIn = false;
  // static String? accessToken;


  dynamic Function(String) onLoadComplete = (result) {
    log.d('Table loaded Result from HomeScreen0 => $result');
  };

  // late double screenWidth;
  // late double screenHeight; 

  // late double row1Width;
  late double row1Height;

  // late double row2Width;
  late double row2Height;

  // late double row3Width;
  late double row3Height;

  // late double row4Width;
  late double row4Height;

  // late double row5Width;
  late double row5Height;

  late double padding;


  @override
  void initState() {
    super.initState();
    row1Height = 80;    // row1Width = 80;
    row2Height = 80;
    row3Height = 80;    // row3Width = 80;
    row4Height = 320;   // row4Width = 240;
    row5Height = 120;   // row5Width = 120;
    padding = 4;
  }
   
  @override
  Widget build(BuildContext context) {

    return 
      Scaffold(
          appBar: PreferredSize(
            preferredSize: AppBar().preferredSize,
            child: AppBarWidget(
              title: widget.title,
              leadingIcon: Icons.savings,
              leadingIconAction: ({String input = ''}){ 
                return true; 
              },
              availableActions: [
                {
                  Icons.key: ({input = ''}) async{
                    await showLoginDetailsInDialogBox(context);
                    return true;
                  },
                  Icons.access_alarm : ({input = ''}) async{
                    return true;
                  },
                  Icons.satellite : ({input = ''}) async{
                    return true;
                  },
                  Icons.logout : ({input = ''}) async{
                    try{
                      // logout from the app and on success show login page without login button
                      await SalesforceAuth2Controller.logout();
                      Navigator.pushReplacement(context, 
                                                MaterialPageRoute(builder: (context) => 
                                                  AppLoginPage(
                                                    message: AppConstants.LOGIN_PAGE_OVERRIDDEN_MESSAGE, 
                                                    showLoginButton: false
                                                  )
                                                ));
                    }
                    catch(error, stacktrace){
                      log.e('Error while doing logout : $error, stacktrace : $stacktrace');
                    }
                    return true;
                  }
                },
              ],
            ),
          ),
          body: Padding(
            padding: const EdgeInsets.all(8.0),
            child: SingleChildScrollView(
              child: Column(
                children : [
                  // First Row
                  /////////////////////////////////////////////// Row 1 ///////////////////////////////////////////
                  Row(
                    children: [
                      // First Row, First Column
                      Expanded(
                        flex: 1,
                        child: Container(
                          height: row1Height,
                          // width: row1Width,
                          padding: EdgeInsets.all(padding),
                          child: TileWidget(
                            center: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: const [
                                Icon(Icons.calendar_month),
                                SizedBox(height: 2),
                                Text('Cal')
                              ],
                            ),
                            onCallBack: (){
                              var currentContext = context;
                              navigateTo(currentContext, Scaffold(
                                // appBar: AppBar(), 
                                body: FinPlanCalendar(
                                  onCallBack: ()=>{

                                  }
                                )
                              ));
                            }
                          )
                        ),
                      ),
                      // First Row, Second Column
                      Expanded(
                        flex: 1,
                        child: Container(
                          padding: EdgeInsets.all(padding),
                          height: row1Height,
                          // width: row1Width,
                          child: TileWidget(
                            center: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: const [
                                Icon(Icons.bar_chart),
                                SizedBox(height: 2),
                                Text('Chart')
                              ],
                            ),
                            onCallBack: () async{
                              var currentContext = context;
                              final accessToken = await SecureFileManager.getAccessToken() ?? 'Error : no token found!'; 
                              navigateTo(currentContext, Scaffold(appBar: AppBar(), body: Center(child: Text(accessToken)))); 
                            }
                          )
                        ),
                      ),
                      // First Row, Third Column
                      Expanded(
                        flex: 2,
                        child: Container(
                          height: row1Height,
                          // width: row1Width,
                          padding: EdgeInsets.all(padding),
                          child: TileWidget(
                            center: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: const [
                                Icon(Icons.spa)
                              ],
                            ),
                            onCallBack: (){
                              var currentContext = context;
                              navigateTo(currentContext, null);
                            }
                          )
                        ),
                      ),
                    ],
                  ),
                  /////////////////////////////////////////////// Row 2 ///////////////////////////////////////////
                  // Second Row
                  Column(
                    children: [
                      // Second Row, First Column
                      Row(
                        children: [
                          Expanded(
                            child: Container(
                              height: row2Height,
                              width: MediaQuery.of(context).size.width,
                              padding: EdgeInsets.all(padding),
                              child: TileWidget(
                                center: 
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: const [
                                    Icon(Icons.account_balance),
                                    SizedBox(width: 10),
                                    Text('Accounts')
                                  ],
                                ),
                                topRight: Icon(Icons.arrow_outward),
                                onCallBack: (){
                                  var currentContext = context;
                                  navigateTo(currentContext, Scaffold(body: AllAccounts()));
                                }
                              )
                            ),
                          ),
                        ],
                      ),
                      // Second Row, Second Column
                      // Second Row, Third Column
                    ],
                  ),
                  // Third Row
                  /////////////////////////////////////////////// Row 3 ///////////////////////////////////////////
                  Column(
                    children: [
                      Row(
                        children: [
                          // Third Row, First Column
                          Expanded(
                            flex: 1,
                            child: Container(
                              height: row3Height,
                              // width: row3Width,
                              padding: EdgeInsets.all(padding),
                              child: TileWidget(
                                center: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: const [
                                    Icon(Icons.payments),
                                    Text('Transaction')
                                  ],
                                ),
                                onCallBack: (){
                                  var currentContext = context;
                                  navigateTo(currentContext, Scaffold(body: FinPlanAllTransactions()));
                                }
                              )
                            ),
                          ),
                          // Third Row, Second Column
                          Expanded(
                            flex: 1,
                            child: Container(
                              height: row3Height,
                              // width: row3Width,
                              padding: EdgeInsets.all(padding),
                              child: TileWidget(
                                center: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: const [
                                    Icon(Icons.message_rounded),
                                    SizedBox(height: 2),
                                    Text('Message')
                                  ],
                                ),
                                onCallBack: (){
                                  var currentContext = context;
                                  navigateTo(currentContext, Scaffold(body: FinPlanAllMessages()));
                                }
                              )
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  /////////////////////////////////////////////// Row 4 ///////////////////////////////////////////
                  // Fourth Row
                  Column(
                    children: [
                      // Fourth Row, First Column
                      Row(
                        children: [
                          Expanded(
                            flex: 1,
                            child: Container(
                              height: row4Height,
                              // width: row4Width,
                              padding: EdgeInsets.all(padding),
                              child: TileWidget(
                                center: Icon(Icons.cabin),
                                topRight: Container(
                                  height: 80,
                                  width: 80,
                                  padding: EdgeInsets.all(padding),
                                  child: TileWidget(
                                    borderColor: Colors.purple.shade100,
                                    gradientColors: [Colors.purple.shade100, Colors.purple.shade200],
                                    center: Icon(Icons.near_me),
                                    onCallBack: (){
                                      var currentContext = context;
                                      navigateTo(currentContext, null);   
                                    }
                                  ),
                                ),
                                onCallBack: (){
                                  var currentContext = context;
                                  navigateTo(currentContext, null);  
                                }
                              )
                            ),
                          ),
                        ],
                      ),
                      // Fourth Row, Second Column
                      // Fourth Row, Third Column
                    ],
                  ),
                  // Fifth Row 
                  /////////////////////////////////////////////// Row 5 ///////////////////////////////////////////
                  Column(
                    children: [
                      Row(
                        children: [
                          // Fifth Row, First Column
                          Expanded(
                            flex: 2,
                            child: Container(
                              height: row5Height,
                              // width: row5Width,
                              padding: EdgeInsets.all(padding),
                              child: TileWidget(
                                center: Icon(Icons.spa),
                                onCallBack: (){
                                  var currentContext = context;
                                  navigateTo(currentContext, null);  
                                }
                              )
                            ),
                          ),
                          Expanded(
                            flex: 3,
                            child: Container(
                              height: row5Height,
                              // width: row5Width,
                              padding: EdgeInsets.all(padding),
                              child: TileWidget(
                                center: Icon(Icons.spa),
                                onCallBack: (){
                                  var currentContext = context;
                                  navigateTo(currentContext, null);  
                                }
                              )
                            ),
                          ),
                          // Fifth Row, Second Column
                          // Fifth Row, Third Column  
                        ],
                      ),
                    ],
                  ),
                ]
              )
            ),
          ),
          // floatingActionButton: FloatingActionButton(
          //   onPressed: (){},
          //   tooltip: 'Hello World!',
          //   child: const Icon(Icons.emoji_transportation_sharp),
          // ),
        );
      }

  // A generic method to handle routes
  void navigateTo(BuildContext context, Widget? widget) async {
    String accessToken = await SecureFileManager.getAccessToken() ?? 'Error! You are not logged in yet';
    String refreshToken = await SecureFileManager.getRefreshToken() ?? 'Error! You are not logged in yet';
    String instanceUrl = await SecureFileManager.getInstanceURL() ?? 'Error! You are not logged in yet';
    String expiryTime = await SecureFileManager.getExpiryTimeOfToken() ?? 'Error! You are not logged in yet';
    String resultText = 'accessToken => $accessToken || refreshToken => $refreshToken || instanceUrl => $instanceUrl || expiryTime => $expiryTime';
    Logger().d('Inside navigate to method resultText is : $resultText');
    Navigator.push(
      context, 
      MaterialPageRoute(
        builder: (context)=> widget ??  
          Scaffold(
            appBar: AppBar(), 
            body : Container(
              padding: EdgeInsets.all(8),
              // child: // FinPlanMonthView()
              child: Center(
                child: Text(resultText),
              ),
            )
          )
      )
    );
  }

  // Function that shows the dialog box with login information
  Future<dynamic> showLoginDetailsInDialogBox(BuildContext context) async {
    String title = 'Login Details';
    String choiceOk = 'Ok';
    String accessToken = await SecureFileManager.getAccessToken() ?? 'No Access Token present';
    String instanceUrl = await SecureFileManager.getInstanceURL() ?? 'No instance url present';
    String refreshToken = await SecureFileManager.getRefreshToken() ?? 'No Refresh token Present';

    String expiryTimeStr = await SecureFileManager.getExpiryTimeOfToken() ?? '';
    DateTime expiryTime = DateTime.parse(expiryTimeStr);
    String expiryTimeFormatted = DateFormat('yyyy-MM-dd HH:mm:ss').format(expiryTime);

    Duration durationDifference = expiryTime.difference(DateTime.now());
    String durationDifferenceStr = durationDifference.isNegative ? '${durationDifference.inMinutes} mins ago..' : '${durationDifference.inMinutes} mins to go..';
        
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: Column(
            mainAxisSize: MainAxisSize.min,  // Ensures the column takes up minimum space
            crossAxisAlignment: CrossAxisAlignment.start,  // Aligns text to the left
            children: [
              // Adds spacing between the fields with `SizedBox`
              Text('Instance URL: $instanceUrl'),
              SizedBox(height: 8),
              Text('Access Token: $accessToken'),
              SizedBox(height: 8),
              Text('Refresh Token: $refreshToken'),
              SizedBox(height: 8),
              Text('Expiry Time: $expiryTimeFormatted'),
              Text('($durationDifferenceStr)'),
              
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(false); // User clicked No
              },
              child: Text(choiceOk),
            ),
          ],
        );
      },
    );
  }

}