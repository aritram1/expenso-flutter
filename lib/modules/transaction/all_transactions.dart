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
    
    allData = await getAllTransactionTransactions(selectedStartDate, selectedEndDate);
    // tableData = allData;
    // filteredDataMap = generateDataMap(allData);

    // To force rebuild the state so that dependent widgets gets rebuilt
    setState(() {
      tableData = allData;
      filteredDataMap = generateDataMap(allData);
      isLoading = false;
    });
  }

  Future<List<Map<String, dynamic>>> getAllTransactions() async {
    return getAllTransactionTransactions(selectedStartDate, selectedEndDate);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Transactions'),
        actions: [
          GestureDetector(
            onTap: () async {
              if (isLoading) {
                return; // Early return in case the page is already loading
              }
              BuildContext currentContext = context;
              // Get an alert dialog as a confirmation box
              bool shouldProceed = await showConfirmationBox(currentContext, AppConstants.SYNC);
              if (shouldProceed) {

                // Set the loading indicator
                setState(() {
                  isLoading = true;
                });

                var result = await FinPlanTransactionUtil.syncWithSalesforce(); // Call the method now
                Logger().d('result is=> $result');

                // TB checked if required
                // After sync, reload data based on current date selections
                // var result = await handleDateRangeSelection(selectedStartDate, selectedEndDate);

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

  // method to get widget data
  Future<List<Map<String, dynamic>>> getAllTransactionTransactions(DateTime startDate, DateTime endDate) async {
    try {
      allData = await FinPlanTransactionUtil.getAllTransactionMessages(startDate: startDate, endDate: endDate);
      Logger().d('${allData.length} records are retrieved.'); // LOL allData is: $allData');
      
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
    
    allData = await getAllTransactionTransactions(selectedStartDate, selectedEndDate);

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
Future<dynamic> showConfirmationBox(BuildContext context, String opType) {
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
        content: Text(content),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(false); // User clicked No
            },
            child: Text(choiceNo),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(true); // User clicked Yes
              // setState(() {
              //   isLoading = true;
              // });
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
