// ignore_for_file: must_be_immutable, non_constant_identifier_names

import 'package:expenso/helper/app_constants.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:intl/intl.dart';
import 'package:logger/logger.dart';

class DatepickerPanelWidget extends StatefulWidget {

  final List<String> dateRanges;
  final void Function (DateTime sDate, DateTime eDate) onDateRangeSelected;

  DatepickerPanelWidget({
    Key? key,
    this.dateRanges = AppConstants.FAVORITE_DATE_RANGES,
    required this.onDateRangeSelected,
  }) : super(key: key){
    assert(() {
      for (var range in dateRanges) {
        if (!AppConstants.VALID_DATE_RANGES.contains(range)) {
          throw AssertionError('Invalid date range: $range. Please provide any of these ranges : ${AppConstants.VALID_DATE_RANGES}');
        }
      }
      return true;
    }());
  }
  
  @override
  DatepickerPanelWidgetState createState() => DatepickerPanelWidgetState();
  
}

class DatepickerPanelWidgetState extends State<DatepickerPanelWidget> {

  // Class variables
  late DateTime startDate; // = DateTime.now();
  late DateTime endDate; // = DateTime.now();
  late bool showDatePanel; // = true;

  static Logger log = Logger();
  static bool debug = bool.parse(dotenv.env['debug'] ?? 'false');
  static bool detaildebug = bool.parse(dotenv.env['detaildebug'] ?? 'false');
  
  final String DATE_FORMAT_IN = 'dd-MM-yyyy'; // FinPlanConstants.IN_DATE_FORMAT;

  @override
  void initState() {
    super.initState();
    startDate = DateTime.now().add(const Duration(days: -7)); // default start date is today - 7
    endDate = DateTime.now(); // default end date is now
    showDatePanel = true;
    if(detaildebug) log.d('The init state has run');
  }
  
  @override
  Widget build(BuildContext context) {
    if(detaildebug) log.d('The build method has run');
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 0.0, vertical: 0.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Show the date ranges buttons if calling widget requires.
          Visibility(
            visible: widget.dateRanges.isNotEmpty,
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: getFavoriteDateRangedButtons(),
                ),
              ),
            ),
          ),

          // Show the start date picker
          Visibility(
            visible: showDatePanel,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 0.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Start Date:'),
                  TextButton(
                    onPressed: () => _selectDate(context, startDate, startOrEndDate: 'start'),
                    child: Text(
                      DateFormat(DATE_FORMAT_IN).format(startDate), // DATE_FORMAT_IN is MM-DD-YYYY
                      style: const TextStyle(fontSize: 16),
                    ),
                  ),
                ],
              ) ,
            )
          ),

          // Show the end date picker
          Visibility(
            visible: showDatePanel,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 0.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('End Date:'),
                  TextButton(
                    onPressed: () => _selectDate(context, endDate, startOrEndDate: 'end'),
                    child: Text(
                      DateFormat(DATE_FORMAT_IN).format(endDate), // DATE_FORMAT_IN is MM-DD-YYYY
                      style: const TextStyle(fontSize: 16),
                    ),
                  ),
                ],
              ),
            )
          ),
        ],
      ),
    );
  }

  Future<void> _selectDate(BuildContext context, DateTime selectedDate, {required String startOrEndDate}) async {
    
    DateTime? picked;

    if (startOrEndDate == 'start') {
      picked = await showDatePicker(
        context: context,
        initialDate: selectedDate,
        firstDate: DateTime.now().add(const Duration(days : -365)), // Can select date upto one year back
        lastDate: endDate,
      );
    } else {
      picked = await showDatePicker(
        context: context,
        initialDate: selectedDate,
        firstDate: startDate,
        lastDate: DateTime.now(),
      );
    }

    log.d('picked date is $picked');


    if (picked != null) {
      setState(() {
        if (startOrEndDate == 'start') {
          log.d('start picked date is $picked');
          startDate = picked!;
        } else {
          log.d('end picked date is $picked');
          endDate = picked!;
        }
        // showDatePanel = true;
      });
      if(debug){
        log.d('Manually changed StartDate $startDate');
        log.d('Manually changed EndDate $endDate');
      }
      widget.onDateRangeSelected(startDate, endDate);
    }
  }

  // A specialized function to show specific date ranges like `Today`, `Tomorrow`, `Last 7 days`, `Last 30 days` etc.
  dynamic getFavoriteDateRangedButtons() {
    
    List<String> favoriteDateRanges = widget.dateRanges; 
    List<Widget> rangedButtons = [];
    SizedBox sBox = const SizedBox(width: 8);

    for(String dateRange in favoriteDateRanges){
      // Add the stateless button
      ElevatedButton eButton = ElevatedButton(
        onPressed: () { 
          handleFavoriteDateRangeButtonClick(dateRange); 
        },
        child: Text(
          dateRange, 
          style: const TextStyle(fontSize: 12) // Adjust font size as needed
        )
      );

      // Add the stateful button
      // FinPlanStatefulButton eButton = FinPlanStatefulButton(
      //   text: dateRange,
      //   value: dateRange,
      //   onSelectionChanged: (selectedValue) { 
      //     handleFavoriteDateRangeButtonClick(selectedValue); 
      //   }
      // );

      rangedButtons.add(eButton);

      // Add the sized box to keep gap between buttons
      rangedButtons.add(sBox);
    }
    return rangedButtons;
  }

  // An utility function to update the state variables e.g. `startDate`, `endDate`, `showDatePickerPanel`, `data` etc..
  handleFavoriteDateRangeButtonClick(String range){
    log.d('I am here with range $range');
    DateTime sDate, eDate;
    // bool show;
    switch (range) {
      case 'All':
        sDate = DateTime.now().add(const Duration(days: -365));
        eDate = DateTime.now();
      case 'Today':
        sDate = DateTime.now();
        eDate = DateTime.now();
        break;
      case 'Yesterday':
        sDate = DateTime.now().add(const Duration(days: -1));
        eDate = DateTime.now().add(const Duration(days: -1));
        break;
      case 'Last 7 days':
        sDate = DateTime.now().add(const Duration(days: -7));
        eDate = DateTime.now();
        break;
      case 'Last 30 days':
        sDate = DateTime.now().add(const Duration(days: -30));
        eDate = DateTime.now();
        break;
      case 'Last 6 months':
        sDate = DateTime.now().add(const Duration(days: -180));
        eDate = DateTime.now();
        break;
      case 'Last 12 months':
        sDate = DateTime.now().add(const Duration(days: -360));
        eDate = DateTime.now();
        break;
      case 'Custom':
        sDate = DateTime.now();
        eDate = DateTime.now();
        break;
      default:  
        sDate = DateTime.now();
        eDate = DateTime.now();
        break;
    }
    
    setState(() {
      startDate = sDate;
      endDate = eDate;
      // showDatePanel = show; // TBD if it will be helpful to hide/show the panel for specific date ranges, <3 suggested to drop this ;)
      widget.onDateRangeSelected(startDate, endDate); 
    });  
  }

}
