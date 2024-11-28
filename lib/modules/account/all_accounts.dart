// ignore_for_file: must_be_immutable
// import 'package:ExpenseManager/widgets/finplan_table_widget.dart';
import 'package:finmind/modules/account/util_account.dart';
import 'package:finmind/widgets/credit_card_widget.dart';
import 'package:finmind/widgets/savings_account_widget.dart';
import 'package:finmind/widgets/digital_wallet_widget.dart';
import 'package:finmind/widgets/table_widget.dart';
import 'package:flutter/material.dart';
import 'package:logger/logger.dart';

class AllAccounts extends StatefulWidget {
  
  const AllAccounts({super.key});
  
  static final Logger log = Logger();

  @override
  State<AllAccounts> createState() => _AllAccountsState();
}

class _AllAccountsState extends State<AllAccounts> {
  
  String showType = 'card'; // showType can be either `table` or `card`

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: AccountUtil.getAllAccountsData(),
      builder: (context, AsyncSnapshot<List<Map<String, dynamic>>> snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        } 
        else if (snapshot.hasError) {
          return Center(
            child: Text('Error loading data in All Accounts view ! ${snapshot.error.toString()}'),
          );
        } 
        else {
          return Scaffold(
            appBar: AppBar(
              title: const Text('All accounts'),
              actions: [
                GestureDetector(
                  onTap: () async {
                    setState(() {
                      showType = (showType == 'card') ? 'table' : 'card'; //toggle the value
                    });
                  },
                  child: (showType == 'table') ? const Icon(Icons.card_giftcard) : const Icon(Icons.table_chart),
                ),
                const SizedBox(width: 12),
              ]
            ),
            body: (showType == 'card') ? cardView(snapshot.data!) : tableView(snapshot.data!)
          );
        }
      },
    );
  }

  Widget tableView(tableData){
    // return const Center(child: Text('This is an interim Sample table view'),);
    return Expanded(
                child: TableWidget(
                  header : const [
                    {'label': 'Paid To', 'type': 'String'},
                    {'label': 'Amount', 'type': 'double'},
                    {'label': 'Last Updated', 'type': 'date'},
                  ],
                  noRecordFoundMessage: 'No recent bank accounts to show',
                  columnWidths: const [0.2, 0.25, 0.35],
                  onLoadComplete: (input){},
                  defaultSortcolumnName: 'Last Updated', // 2 meaning the Date column
                  showSelectionBoxes : false, 
                  tableButtonName: 'N/A', // table button name is not required because show selection boxes are not shown here
                  // columnWidths: const [0.3, 0.2, 0.2],
                  data: tableData,
                  // onLoadComplete: (input){}, // onLoadComplete,
                  showNavigation: true,
                ),
    );
  }

  Widget cardView(var data){
    return ListView(
      children: List.generate(data!.length,(index) {
        var each = data![index];
        if (each['FinPlan__Account_Code__c'].contains('-SA')) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 4.0, left: 8.0, right: 8.0),
            child: SavingsAccountWidget(data: each, onCardSelected: () {}),
          );
        } 
        else if (each['FinPlan__Account_Code__c'].contains('-CC')) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 4.0, left: 8.0, right: 8.0),
            child: CreditCardWidget(data: each, onCardSelected: () {}),
          );
        } 
        else if (each['FinPlan__Account_Code__c'].contains('-WA')) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 4.0, left: 8.0, right: 8.0),
            child: DigitalWalletWidget(data: each, onCardSelected: () {}),
          );
        } 
        else {
          return Padding(
            padding: const EdgeInsets.all(4.0),
            child: Card(
              color: Colors.grey.shade100,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15.0),
              ),
              child: ListTile(
                leading: const Icon(Icons.device_unknown),
                title: Text(each['N/A'] ?? ''),
                subtitle: const Text('N/A'),
                trailing: Text(each['N/A'] ?? ''),
              ),
            ),
          );
        }
      }),
    );
  }

} // End of class