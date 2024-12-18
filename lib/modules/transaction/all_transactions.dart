// ignore_for_file: prefer_const_literals_to_create_immutables, prefer_const_constructors
import 'package:expenso/helper/app_constants.dart';
import 'package:expenso/helper/app_exception.dart';
import 'package:expenso/modules/transaction/util_transaction.dart';
import 'package:expenso/widgets/datepicker_panel_widget.dart';
import 'package:expenso/widgets/enhanced_pill_widget.dart';
import 'package:expenso/widgets/table_widget.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:logger/logger.dart';

class FinPlanAllTransactions extends StatefulWidget {
  const FinPlanAllTransactions({super.key});

  @override
  FinPlanAllTransactionsState createState() => FinPlanAllTransactionsState();
}

class FinPlanAllTransactionsState extends State<FinPlanAllTransactions> {
  // Declare the required state variables for this page

  static final Logger log = Logger();
  static DateTime selectedStartDate =DateTime.now().add(const Duration(days: -7));
  static DateTime selectedEndDate = DateTime.now();
  static bool showDatePickerPanel = false;
  List<Map<String, dynamic>> tableData = [];
  static List<Map<String, dynamic>> allData = [];
  static Set<String> availableTypes = {};
  Map<String, List<Map<String, dynamic>>> filteredDataMap = {};
  static int countOfMessagesToRetrieve = 0;
  
  static bool isLoading = false;

  dynamic Function(String) onLoadComplete = (result) {
    if (result == 'SUCCESS') {
      log.d('Table loaded Result from FinPlanAllTransactions => $result');
    } else {
      log.d('Table load failed with result => $result');
    }
  };

  @override
  void initState() {
    super.initState();
    initTransactions();
  }

  void initTransactions() async {
    setState(() {
      isLoading = true;
    });
    await loadTransactions();
    setState(() {
      isLoading = false;
    });
  }

  Future<void> loadTransactions() async {
    allData = await getAllTransactionInRange(selectedStartDate, selectedEndDate);
    tableData = allData;
    filteredDataMap = generateDataMap(allData);
  }

  @override
  Widget build(BuildContext context) {
    
    String componentName = 'all_transactions.dart';
    Logger().d('Build Method run for : $componentName');
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Transactions'),
        actions: [
          GestureDetector(
            onTap: () async {
              if (isLoading) {
                return; // Early return in case the page is already loading
              }
              
              // Get an alert dialog as a confirmation box
              BuildContext currentContext = context;
              bool shouldProceed = await showConfirmationBox(
                context : currentContext, 
                opType : AppConstants.SYNC, 
                onConfirmed : (int messageCount) {
                  setState(() {
                    countOfMessagesToRetrieve = messageCount;
                    Logger().d('Updated countOfMessagesToRetrieve in setState => $messageCount');
                  });
                },  
              );
              
              Logger().d('Count of messages inside build = >$countOfMessagesToRetrieve');

              if (shouldProceed) {

                // Set the loading indicator
                setState(() {
                  isLoading = true;
                });
                
                // For testing : To mock async method `syncWithSalesforceWithPE`, use below line.
                // await Future.delayed(Duration(seconds: 1));

                // Deprecated method
                // Direct insertion to SMS__c records
                // var result = await FinPlanTransactionUtil.syncWithSalesforce(); 
                
                // New method
                // Insertion via platform event : SMS_Platform_Event__e
                // List<String> results = await FinPlanTransactionUtil.syncWithSalesforceWithPE(countOfMessagesToRetrieve); // here PE are sent
                
                // newer method : now with API
                List<String> results = await FinPlanTransactionUtil.syncWithSalesforceWithAPI(countOfMessagesToRetrieve); // here PE are sent
                
                Logger().d('message sync result is=> $results');

                // Unset the loading indicator
                setState(() {
                  isLoading = false;
                });

              }
            },
            child: Icon(Icons.refresh),
          ),
          const SizedBox(width: 12),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: Column(
              children: [
                DatepickerPanelWidget(
                  onDateRangeSelected: handleDateRangeSelection,
                ),
              ]
            ),
          ),
          if(isLoading)
            Center(
              child: CircularProgressIndicator(),
            )
          else
            ...<Widget>[
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: EnhancedPillWidget(
                    data: allData,
                    onPillSelected: onPillSelected,
                  ),
                ),
              ),
              Expanded(
                child: TableWidget(
                  header: const [
                    {'label': 'Paid To', 'type': 'String'},
                    {'label': 'Amount', 'type': 'double'},
                    {'label': 'Date', 'type': 'date'},
                  ],
                  defaultSortcolumnName: 'Date',
                  tableButtonName: 'Total : ',
                  noRecordFoundMessage: 'Nothing to show',
                  columnWidths: const [0.3, 0.2, 0.2],
                  data: tableData,
                  onLoadComplete: onLoadComplete,
                  showNavigation: true,
                  showSelectionBoxes: true,
                ),
              ),
            ],
          // else ends here
        ],
      ),
    );
  }

  void onPillSelected(String pillName) {
    Logger().d('Pill name is $pillName');
    setState(() {
      tableData = filterData(pillName);
      Logger().d('Inside setState data is=> $tableData');
    });
  }



  // Util methods for this widget
  Icon getIcon(dynamic row) {
    Icon icon;
    String type = row['BeneficiaryType'];
    switch (type) {
      case 'Grocery':
        icon = const Icon(Icons.local_grocery_store);
        break;
      case 'Bills':
        icon = const Icon(Icons.receipt);
        break;
      case 'Food and Drinks':
        icon = const Icon(Icons.restaurant);
        break;
      case 'Others':
        icon = const Icon(Icons.miscellaneous_services);
        break;
      default:
        icon = const Icon(Icons.person);
        break;
    }
    return icon;
  }

  // An overridden method to get widget data. Note even if the start/end date is not provided.
  // It defaults values here, so it can call the next method 
  // `getAllTransactions(DateTime startDate, DateTime endDate)`
  Future<List<Map<String, dynamic>>> getAllTransactions() async {
    return getAllTransactionInRange(selectedStartDate, selectedEndDate);
  }

  // method to get widget data
  Future<List<Map<String, dynamic>>> getAllTransactionInRange(DateTime startDate, DateTime endDate) async {
    try {
      allData = await FinPlanTransactionUtil.getAllTransactionMessages(startDate: startDate, endDate: endDate);
      Logger().d('${allData.length} records are retrieved.');
      
      filteredDataMap = generateDataMap(allData);
      Logger().d('filteredDataMap is: $filteredDataMap');

      return Future.value(allData);
      // return data;
    } catch (error, stackTrace) {
      log.e('Error in getAllTransactionTransactions: $error');
      log.e('Stack trace: $stackTrace');
      return Future.value([]);
    }
  }

  // This method converts the data to a map of records based on beneficiary type.
  Map<String, List<Map<String, dynamic>>> generateDataMap(List<Map<String, dynamic>> data) {
    Map<String, List<Map<String, dynamic>>> fMap = {};
    for (Map<String, dynamic> each in data) {
      // if type is blank or null then set it to `Others`
      String type = (each['BeneficiaryType'] != '') ? each['BeneficiaryType'] : 'Other';
      List<Map<String, dynamic>> existing = filteredDataMap[type] ?? [];
      existing.add(each);
      fMap[type] = existing;
    }
    Logger().d('Filtered map => $filteredDataMap');
    return fMap;
  }

  // method to handle date range click
  void handleDateRangeSelection(DateTime startDate, DateTime endDate) async {

    log.d('Inside handleDateRangeSelection method : startDate $startDate, endDate $endDate');

    // setState(() {
    //   selectedStartDate = startDate;
    //   selectedEndDate = endDate;
    //   getAllTransactionTransactions(startDate, endDate);
    // });

    setState(() {
      isLoading = true; // Show loading indicator while fetching data
      selectedStartDate = startDate;
      selectedEndDate = endDate;
    });
    
    allData = await getAllTransactionInRange(selectedStartDate, selectedEndDate);

    setState(() {  
      tableData = allData;
      filteredDataMap = generateDataMap(allData);
      isLoading = false; // Hide loading indicator once data is fetched
    });

  }
  
  Set<String> getAvailableTypes() {
    if(filteredDataMap.isEmpty) throw AppException('Filtered Map is empty! But why! check this method getAvailableTypes()');
    return filteredDataMap.keys.toSet();
  }
  
  // Filtered data
  List<Map<String, dynamic>> filterData(String pillName) {
    Logger().d('Inside filterData pillname is=> $pillName');
    Logger().d('Inside filterData data is=> $allData');
    Logger().d('Inside filterData data size is=> ${allData.length}');
    List<Map<String, dynamic>> temp = [];

    for(Map<String, dynamic> each in allData){
      Logger().d('each[beneficiaryType] is ${each['beneficiaryType']}');
      
      // To show - back all records without any filter
      if(pillName == 'All'){
        temp.add(each);
      }
      else if(pillName == 'Credit' && each['Type'] == 'Credit'){
        temp.add(each);
      }
      else if(pillName == 'Debit' && each['Type'] == 'Debit'){
        temp.add(each);
      }
      // For rest entries
      else if(each['BeneficiaryType'] == pillName){
        temp.add(each);
      }

    }
    Logger().d('Inside Filter data method, return is=> $temp');
    return temp;
  }
}

getAllTiles(var data) {
  List<Widget> allTiles = [];
  for (int i = 0; i < data.length; i++) {
    dynamic each = data[i];
    allTiles.add(
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 4.0),
        child: Container(
          decoration: BoxDecoration(
              border: Border.all(color: Colors.purple.shade100, width: 1),
              gradient: LinearGradient(
                  colors: [Colors.purple.shade100, Colors.purple.shade200]),
              borderRadius: BorderRadius.circular(10)),
          child: ListTile(
            selected: true,
            //leading: getIcon(each),
            title: Text(
              each['Paid To'],
              style: const TextStyle(fontSize: 16, color: Colors.black),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                    NumberFormat.currency(locale: 'en_IN', symbol: '₹')
                        .format(each['Amount']),
                    style: const TextStyle(fontSize: 18, color: Colors.black)),
                Text(DateFormat('dd-MM-yyyy').format(each['Date']),
                    style: const TextStyle(fontSize: 12, color: Colors.black)),
              ],
            ),
            trailing: GestureDetector(
              child: Icon(Icons.navigate_next),
              onTap: () {
                // String smsId = each['Id'];
                // Navigator.push(context, MaterialPageRoute(
                //   builder: (_)=>
                //     Scaffold(
                //       appBar: AppBar(),
                //       body: Center(
                //         child: SizedBox(
                //           height: 200,
                //           width: 200,
                //           child: FinPlanTransactionDetail(
                //             sms: jsonEncode(each),
                //             onCallBack: (){}
                //           ),
                //         ),
                //       )
                //     )
                //   )
                // );
              },
            ),
          ),
        ),
      ),
    );
  }
  return SingleChildScrollView(
    child: Column(
      mainAxisAlignment: MainAxisAlignment.start,
      children: allTiles,
    )
  );
}

// A confirmation box to show if its ok to proceed with sync and delete operation
Future<dynamic> showConfirmationBox({required BuildContext context, required String opType, required Function(int) onConfirmed}) {
  
  final TextEditingController inputMessageCountController = TextEditingController();
  inputMessageCountController.text = AppConstants.MAX_COUNT_OF_MESSAGES_TO_RETRIEVE.toString();
  
  String title = 'Please confirm';
  String choiceYes = 'Yes';
  String choiceNo = 'No';
  String content = (opType == AppConstants.SYNC)
      ? 'This will delete existing Transactions and recreate them. Proceed?'
      : 'This will delete all Transactions and transactions. Proceed?';

  return showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text(title),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(content),
            SizedBox(height: 20),
            TextField(
              controller: inputMessageCountController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                labelText: "How many messages to Sync?",
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(false); // User clicked No
            },
            child: Text(choiceNo),
          ),
          TextButton(
            onPressed: () {
              int messageCount = inputMessageCountController.text.isEmpty ? 0 : int.parse(inputMessageCountController.text);
              Logger().d('Count of messages inside showConfirmationBox method => $messageCount');
              onConfirmed(messageCount);
              Navigator.of(context).pop(true); // User clicked Yes
            },
            child: Text(choiceYes),
          ),
        ],
      );
    },
  );
}

// Archive
// json format for data for this widget
// {
//   'Paid To': '',
//   'Amount': '',
//   'Date': '',
//   'Id': '',
//   'BeneficiaryType': '',
// }
