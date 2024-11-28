// ignore_for_file: prefer_const_constructors
import 'package:expenso/modules/message/message_detail.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:intl/intl.dart';
import 'package:logger/logger.dart';

class TableWidget extends StatefulWidget {

  // header will have name and type of the field to display 
  // [
  //  {'label' : 'Id', 'type' : 'int'}, 
  //  {'label' : 'Name', 'type' : 'String'}, 
  //  {'label' : 'Amount', 'type' : 'double'},
  //  {'label' : 'Active?', 'type' : 'bool'},
  //  {'label' : 'Last Updated', 'type' : 'DateTime'},
  // ]
  final List<Map<String, String>> header; 

  // `data` represents the data to show in the table. It should have type as [<String, dynamic>]
  // [
  //  {
  //    'Id' : 123, 
  //    'Name' : 'John Doe',
  //    'Phone' : null,
  //    'Amount' : 123.55,
  //    'Active?' : true,
  //    'Last Updated' : 2024-12-11 11:45:44Z,
  // ]
  final List<Map<String, dynamic>> data;

  // `onLoadComplete` method gets invoked once the widget completes loading.
  // the function will have structure as :
  // (String input){
  //    return poutput;
  // }
  final Function(String) onLoadComplete;

  final String noRecordFoundMessage; // e.g. 'Default Message for no records!'
  final List<double> columnWidths;  // e.g. [0.3, 0.2, 0.2]
  final String defaultSortcolumnName; // e.g. Name
  final String tableButtonName; // This button applies a common action for all selected records
  final bool showSelectionBoxes; // records are selected with this checkbox
  final bool showNavigation; // this helps to navigate to row specific pages
  
  const TableWidget({
    Key? key,
    required this.header, 
    required this.data,
    required this.onLoadComplete,
    required this.columnWidths,
    required this.defaultSortcolumnName,
    required this.tableButtonName,
    this.noRecordFoundMessage = 'Default Message for no records!',
    this.showSelectionBoxes = true,
    this.showNavigation = false,

  }) : super(key: key);

  @override
  TableWidgetState createState() => TableWidgetState();
}

class TableWidgetState extends State<TableWidget> {

  List<String> numericColumns = [];//['Amount', 'Balance'];
  List<String> dateColumns = []; // ['Date'];
  List<String> dateTimeColumns = []; // ['Last Updated'];
  final int constNameColumnId = 0;
  final int constAmountColumnId = 1;
  final int constDateColumnId = 2;

  final Logger log = Logger();
  static bool debug = bool.parse(dotenv.env['debug'] ?? 'false');
  static bool detaildebug = bool.parse(dotenv.env['detaildebug'] ?? 'false');
  
  List<Map<String, dynamic>> tableData = [];
  List<String> selectedRowIds = [];
  bool isLoading = false;
  int sortColumnIndex = 0;
  bool _sortAscending = false;
  List<IconData?> _sortIcons = [];
  int onLoadDefaultDescendingColumnId = 2; // default order declared

  @override
  void initState() {

    super.initState();

    // If the `deafultSortColumn` is not present in passed `header`, throw an exception
    // TB Optimized
    //
    // if(!widget.header.contains(widget.defaultSortcolumnName)) {
    //   throw FinPlanException('default sorting column "${widget.defaultSortcolumnName}" is not present in table header !') ;
    // }

    for(var each in widget.header){
      String colName = each['label']!;
      String colType = each['type']!;
      if(colType == 'int' || colType == 'double'){
        numericColumns.add(colName);
      }
      if(colType == 'DateTime'){
        dateTimeColumns.add(colName);
      }
      if(colType == 'date'){
        dateColumns.add(colName);
      }
    }
    
    // Initialize tableData based on whether widget.data is empty or not
    tableData = widget.data.isNotEmpty ? widget.data : [];
    
    int defaultSortcolumnIndex = 0;
    _sortIcons = List.generate(widget.header.length, (colIndex) {
      if (widget.header[colIndex]['label'] == widget.defaultSortcolumnName) {
        defaultSortcolumnIndex = colIndex;
        // Set default sorting icon as ascending on load, so it will be reversed in the sortColumn method
        return Icons.arrow_upward;
      } 
      else {
        return null; // no specific rule for other columns
      }
    });
    
    if(debug) log.d('defaultSortcolumnIndex is=> $defaultSortcolumnIndex');
    sortColumn(defaultSortcolumnIndex); // Sort the table on load, based on `defaultColumnIndex`

    // Set error callback in case some error occurs while loading the widget
    FlutterError.onError = (FlutterErrorDetails details) {
      // Custom error handling logic
      String exceptionDetails = details.exception.toString();
      String errorStack = (details.stack != null) ? details.stack.toString() : 'N/A';
      widget.onLoadComplete('Error occurred while loading table : Details : $exceptionDetails | Stack : $errorStack');
    };

    // Notify onLoadComplete based on the initialization result
    widget.onLoadComplete(tableData.isNotEmpty ? 'SUCCESS' : 'Error: Empty data sent to table');
  }

  @override
  Widget build(BuildContext context) {
    BuildContext currentContext = context;
    return Stack(
      children: [
        SingleChildScrollView( 
          scrollDirection: Axis.vertical,
          child: widget.data.isEmpty
            ? _buildEmptyTableMessage()
            : isLoading
              ? const Center(child: CircularProgressIndicator())
              : Column(
                  children: [
                    DataTable(
                      showCheckboxColumn: widget.showSelectionBoxes,
                      columnSpacing: 0.0,
                      headingRowHeight: 40.0,
                      sortAscending: _sortAscending,
                      columns: _generateColumns(),
                      rows: _generateRows(),
                      // rows: _generateRows(currentContext),
                    ),
                  ],
                ),
        ),
        Align(
          alignment: Alignment.bottomCenter,
          child: Visibility(
            visible: selectedRowIds.isNotEmpty,
            child : Padding(
              padding: EdgeInsets.all(8), 
              child: createTableButton(widget.tableButtonName)
            )
          ),
        ),
      ],
    );
  }

  Future<void Function()?> handleTotal () async{
    await handleApproveSMS(selectedRowIds);
    setState(() {
      selectedRowIds.clear();
    });
  }

  // createTableButton(String buttonName, {String count = ''}){
  createTableButton(String buttonName){
    // The button name should show in a format => 'Approve 123' (where 123 is the count of rows selected)
    // If no rows are selected it should just show the name of the button as => 'Approve'
    // old code changed 20oct
    // String btnName = '$buttonName ${selectedRowIds.isEmpty ? '' : selectedRowIds.length.toString()}';
    String btnName = '$buttonName ${selectedRowIds.isEmpty ? '' : getTotalAmount(selectedRowIds)}';
    // Logger().d('Hi here!');
    return
      ElevatedButton.icon(
        onPressed: handleTotal,
        icon: const Icon(Icons.check), //, color: Color.fromARGB(255, 194, 127, 233)), // Set the icon color
        label: Text(btnName),
        style: ButtonStyle(
          backgroundColor: MaterialStateProperty.resolveWith<Color>(
            (Set<MaterialState> states) {
              // Define the background color based on the button's state
              if (states.contains(MaterialState.pressed)) {
                return Colors.grey; // Grey color when pressed
              }
              return Colors.blue.shade50; // Default background color
            },
          ),
          elevation: MaterialStateProperty.all<double>(0.0),
          shape: MaterialStateProperty.all<OutlinedBorder>(
            RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15.0), // Adjust the border radius
            ),
          ),
        ),
      );
  }

  _generateColumns() {
    return List.generate(widget.header.length, (index) {
      return DataColumn(
        label: SizedBox(
          width: MediaQuery.of(context).size.width * widget.columnWidths[index], // Use provided column width
          child: GestureDetector(
            onTap: () {
              log.d('Index : $index');
              sortColumn(index);
            },
            child: Row(
              children: [
                Text(widget.header[index]['label'] ?? 'DefaultColumnLabel'),
                if (index < _sortIcons.length && _sortIcons[index] != null)
                  Icon(
                    _sortIcons[index],
                    size: 15.0, // Adjust the size as needed
                  ),
              ],
            ),
          ),
        ),
        onSort: (columnIndex, ascending) {
          sortColumn(columnIndex);
        },
        numeric: false,
      );
    });
  }

  // _generateRows(BuildContext context) {
  _generateRows() {
    return widget.data.asMap().entries.map((entry) {
      final String rowIndex = entry.value['Id'];
      final row = entry.value;

      return DataRow(
        selected: selectedRowIds.contains(rowIndex), // Updated line
        onSelectChanged: (selected) {
          handleRowSelection(selected, rowIndex);
        },
        // onLongPress: navigateToMessage(context, rowIndex),
        cells: List.generate(widget.header.length, (index) {

          String headerLabel = widget.header[index]['label']!;
          
          return DataCell(
            SizedBox(
              width: MediaQuery.of(context).size.width * widget.columnWidths[index], // Use provided column width
              child: Padding(
                padding: const EdgeInsets.all(1.0),
                child : Text(
                  getFormattedCellData(headerLabel, row), 
                  style: getTextStyle(headerLabel, row),
                  maxLines: 2
                )
              )
            ),
          );
        }),
      );
    }).toList();
  }

  void sortColumn(int colIndex) async {
    setState(() {
      // Show the spinner till the sorting is completed
      isLoading = true;
    });

    await _sortColumn(colIndex);

    // Way to create async mocking
    await Future.delayed(const Duration(milliseconds: 100));

    setState(() {
      // stop the spinner because the sorting is completed
      isLoading = false;
    });
  }

  Future<void> _sortColumn(int columnIndex) async {
    // Start the sorting

    for (int i = 0; i < _sortIcons.length; i++) {
      if (i == columnIndex) {
        if (_sortIcons[i] == Icons.arrow_upward) {
          _sortIcons[i] = Icons.arrow_downward;
          _sortAscending = false;
        } else {
          _sortIcons[i] = Icons.arrow_upward;
          _sortAscending = true;
        }
      } else {
        _sortIcons[i] = null;
      }
    }

    sortColumnIndex = columnIndex;

    if (detaildebug) log.d('I am here sortColumnIndex and sortascending values => $sortColumnIndex $_sortAscending');
    
    widget.data.sort((a, b) {

      int result = 0;

      if(detaildebug){
        // log.d('a => $a');
        // log.d('b => $b');
      }
      String columnName = widget.header[sortColumnIndex]['label']!;

      if(detaildebug){
        log.d('a[columnName] => ${a[columnName]}');//I am here sortColumnIndex => $sortColumnIndex $_sortAscending');
        log.d('b[columnName] => ${b[columnName]}');//log.d('I am here sortColumnIndex => $sortColumnIndex $_sortAscending');
      }
      
      if (columnIndex == constNameColumnId) { // constNameColumnId = 0;
        result = compareStrings(a[columnName], b[columnName]);
      }
      else if (columnIndex == constAmountColumnId) {  // constAmountColumnId = 1;
        result = compareNumeric(a[columnName], b[columnName]);
      }
      else if (columnIndex == constDateColumnId) {  // constDateColumnId = 2
        // Logger().d('columnIndex => $columnIndex');
        // Logger().d('a => $a');
        // Logger().d('b => $b');

        result = compareDates(a[columnName], b[columnName]);
      }
      if(detaildebug) log.d('Interim result : $result');

      // Second layer sorting 
      // If the first column comparison is equal, use another column for sorting. See the default order below
      if (result == 0) {

        String name1 = a[widget.header[constNameColumnId]['label']];
        double amount1 = a[widget.header[constAmountColumnId]['label']];
        DateTime lupdated1 = a[widget.header[constDateColumnId]['label']];

        String name2 = b[widget.header[constNameColumnId]['label']];
        double amount2 = b[widget.header[constAmountColumnId]['label']];
        DateTime lupdated2 = b[widget.header[constDateColumnId]['label']];


        if(detaildebug){
          log.d('name1 : $name1');
          log.d('amt1 : $amount1');
          log.d('lupdated1 : $lupdated1');
          log.d('name2 : $name2');
          log.d('amt2 : $amount2');
          log.d('lupdated2 : $lupdated2');
        }

        if (columnIndex == constNameColumnId) {
          result = compareDates(lupdated1, lupdated2); // If `names` are same sort by `date`
          if (result == 0) {
            result = compareNumeric(amount2, amount2); // If still `dates` are same finally sort by amount
          }
        } 
        else if (columnIndex == constAmountColumnId) {
          result = compareStrings(name1, name2);  // If `amounts` are same sort by `name`
          if (result == 0) {
            result = compareDates(lupdated1, lupdated2);  // If still `names` are same sort by `date`
          }
        } 
        else if (columnIndex == constDateColumnId) {
          result = compareStrings(name1, name2); // If dates are same sort by names
          if (result == 0) {
            result = compareNumeric(amount2, amount2); // If still names are same finally sort by amount
          }
        }
      }
      if (detaildebug){
        log.d('_sortAscending ? result : -result => ${_sortAscending ? result : -result}');
      }
      return result;
    });
  }

  // Helper method to compare strings case insensitive
  int compareStrings(String a, String b) {
    a = a.toUpperCase();
    b = b.toUpperCase();
    return _sortAscending ? a.compareTo(b) : b.compareTo(a);
  }

  // Helper method to compare numeric values, removing unnecessary spaces, commas, and currency symbols
  int compareNumeric(double aValue, double bValue) {
    return _sortAscending ? aValue.compareTo(bValue) : bValue.compareTo(aValue);
  }

  // Helper method to compare date values
  int compareDates(DateTime aDate, DateTime bDate) {
    return _sortAscending ? aDate.compareTo(bDate) : bDate.compareTo(aDate);
  }

  Widget _buildEmptyTableMessage() {
    if (widget.data.isEmpty) {
      return Padding(
        padding: const EdgeInsets.all(16.0),
        child: 
        Center(
          child: Text(
            widget.noRecordFoundMessage,
            // style: const TextStyle(fontSize: 16),
          ),
        ),
      );
    } else {
      return const CircularProgressIndicator();
    }
  }

  void handleRowSelection(bool? selected, String rowIndex) {
    setState(() {
      if (selected != null) {
        if (selected) {
          selectedRowIds.add(rowIndex);
        } else {
          selectedRowIds.remove(rowIndex);
        }
      }
    });
  }

  TextStyle getTextStyle(String? headerName, dynamic row) { 
    // Logger().d('row= $row');
    String txnType = row['Type'].toUpperCase();// CREDIT or DEBIT
    Color color = Colors.black;
    if(headerName == 'Amount'){
      switch(txnType){
        case 'CREDIT':
          color = Colors.green;
          break;
        case 'DEBIT':
          color = Theme.of(context).primaryColor;
          break;
        default:
          break;
      }
    }
    return TextStyle(color: color);
  }

  Icon getIcon(String columnName, dynamic row){
    Icon icon = const Icon(Icons.other_houses_sharp);
    String type = row['BeneficiaryType'] ?? '';
    switch (type) {
      case 'Grocery':
        icon = const Icon(Icons.local_grocery_store);
        break;
      case 'Bills':
        icon = const Icon(Icons.local_activity);
        break;
      case 'Others':
        icon = const Icon(Icons.other_houses_sharp);
        break;
      default:
        break;
    }
    return icon;
  }

  String getFormattedCellData(String columnName, dynamic row){
    
    String formattedCellData = '';
    
    /////////////////////////// For Date type columns ///////////////////////////////////////
    if(dateColumns.contains(columnName)){
      String yyyymmdd = row[columnName].toString().substring(0, 10);
      String yy = yyyymmdd.split('-')[0].substring(2,4);  // Instead of `2023` just show `23`
      String mm = yyyymmdd.split('-')[1];
      String dd = yyyymmdd.split('-')[2];
      formattedCellData = '$dd/$mm/$yy';
      // Logger().d('formattedCellData=> $formattedCellData');
    }
    /////////////////////////// For DateTime type columns ////////////////////////////////////
    else if(dateTimeColumns.contains(columnName)){
      
      // Convert UTC time to Local Time (+ 5.30 hrs)
      DateTime localDateTime = DateTime.parse(row[columnName].toString()).add(const Duration(hours: 5, minutes: 30));

      if(detaildebug) log.d('LocalDate Time column => ${localDateTime.toString()}');
      String yyyymmdd = localDateTime.toString().split(' ')[0];
      String hhmmss = localDateTime.toString().split(' ')[1].split('.')[0];
      String yy = yyyymmdd.split('-')[0].substring(2,4);
      String mm = yyyymmdd.split('-')[1];
      String dd = yyyymmdd.split('-')[2];
      formattedCellData = '$dd/$mm/$yy $hhmmss';
    }
    /////////////////////////// For Numeric / Currency type columns ///////////////////////////
    else if (numericColumns.contains(columnName)){
      double numericValue = double.parse((row[columnName] ?? 0).toString());
      formattedCellData = NumberFormat.currency(locale: 'en_IN', symbol: '₹').format(numericValue);
    }
    /////////////////////////// For All other and text type columns ////////////////////////////
    else{
      formattedCellData = row[columnName].toString();
    }
    return formattedCellData;
  }



  // String getFormattedCellData(String columnName, dynamic row){
    
  //   String formattedCellData = '';
    
  //   /////////////////////////// For Date type columns ///////////////////////////////////////
  //   if(dateColumns.contains(columnName)){
  //     String yyyymmdd = row[columnName].toString().substring(0, 10);
  //     String yy = yyyymmdd.split('-')[0].substring(2,4);  // Instead of `2023` just show `23`
  //     String mm = yyyymmdd.split('-')[1];
  //     String dd = yyyymmdd.split('-')[2];
  //     formattedCellData = '$dd/$mm/$yy';
  //   }
  //   /////////////////////////// For DateTime type columns ////////////////////////////////////
  //   else if(dateTimeColumns.contains(columnName)){
      
  //     // Convert UTC time to Local Time (+ 5.30 hrs)
  //     DateTime localDateTime = DateTime.parse(row[columnName].toString()).add(const Duration(hours: 5, minutes: 30));

  //     if(detaildebug) log.d('LocalDate Time column => ${localDateTime.toString()}');
  //     String yyyymmdd = localDateTime.toString().split(' ')[0];
  //     String hhmmss = localDateTime.toString().split(' ')[1].split('.')[0];
  //     String yy = yyyymmdd.split('-')[0].substring(2,4);
  //     String mm = yyyymmdd.split('-')[1];
  //     String dd = yyyymmdd.split('-')[2];
  //     formattedCellData = '$dd/$mm/$yy $hhmmss';
  //   }
  //   /////////////////////////// For Numeric / Currency type columns ///////////////////////////
  //   else if (numericColumns.contains(columnName)){
  //     double numericValue = double.parse((row[columnName] ?? 0).toString());
  //     formattedCellData = NumberFormat.currency(locale: 'en_IN', symbol: '₹').format(numericValue);
  //   }
  //   /////////////////////////// For All other and text type columns ////////////////////////////
  //   else{
  //     formattedCellData = row[columnName].toString();
  //   }
  //   return formattedCellData;
  // }


  Future<void> handleApproveSMS(List<String> recordIds) async {
    
    // Set the flag to true when starting the approval process
    setState(() {
      isLoading = true;
    });
    
    Map<String, dynamic> response = {}; // TBD // await DataGenerator.approveSelectedMessages(objAPIName :'FinPlan__SMS_Message__c', recordIds : recordIds);
    if(debug) log.d('Response for handleApproveSMS ${response.toString()}');

    await Future.delayed(const Duration(milliseconds: 100));

    setState(() {
      // Reset the flag when the approval process is completed
      isLoading = false;
    });
  }
  
  navigateToMessage(BuildContext context, String smsId) {
    Logger().d('Inside navigate method of sms detail with id : $smsId');
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => FinPlanMessageDetail(sms: smsId, onCallBack: (){},),
    ));
  }
  
  String getTotalAmount(List<String> selectedRowIds) {
    double total = 0;
    for(final each in tableData){
      if(selectedRowIds.contains(each['Id'])){
        log.d('Each is=> $each');
        double amount = each['Amount'] as double;
        total = total + amount;
      }
    }
    return NumberFormat.currency(locale: 'en_IN', symbol: '₹').format(total);
  }
  
}