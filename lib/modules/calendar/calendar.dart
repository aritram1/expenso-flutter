// ignore_for_file: prefer_const_constructors
import 'package:expenso/helper/model_task.dart';
import 'package:expenso/modules/calendar/new_task.dart';
import 'package:expenso/modules/calendar/util_calendar.dart';
import 'package:expenso/widgets/listview_widget.dart';
import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'package:table_calendar/table_calendar.dart';

class FinPlanCalendar extends StatefulWidget {
  final Function onCallBack;
  const FinPlanCalendar({super.key, required this.onCallBack});
  @override State<FinPlanCalendar> createState() => _FinPlanCalendarState();
}

class _FinPlanCalendarState extends State<FinPlanCalendar> {
  late Map<String, dynamic> data;
  static final Logger log = Logger();
  Set<String> selectedIds = {};

  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;

  @override
  void initState() {
    super.initState();
    data = {}; // Initialize data map
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Calendar and Tasks'),
        actions: [
          GestureDetector(
            onTap: () {
              // Logic for notification icon tap
            },
            child: const Icon(Icons.notifications),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Column(
        children: [
          getCalendar(),
          const SizedBox(height: 8),
          Divider(indent: 12, endIndent: 20),
          const SizedBox(height: 12),
          getTasks(),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.green,
        onPressed: () {
          Navigator.push(
            context, 
            MaterialPageRoute(
              builder: (context)=>  
                Scaffold(
                  appBar: AppBar(), 
                  body : FinPlanCreateNewTaskPage(
                    selectedDay : _selectedDay ?? _focusedDay, // if selectedDay is lready selected use that, else use focusedDay
                    onCallBack: (){
                      setState(() {
                        // just to rebuild the widget
                      });
                      Logger().d('FinPlanCalendarTask completed!');
                    }
                  )
                )
              )
            );
          },
          child: const Icon(Icons.add),
      ),
    );
  }
  
  getCalendar() {
    _selectedDay = _selectedDay ?? _focusedDay; // When the calendar loads, _selectedDay is same as _focusedDay
    return Padding(
      padding: const EdgeInsets.all(4.0),
      child: TableCalendar(
        calendarFormat: _calendarFormat,
        focusedDay: _focusedDay,
        firstDay: DateTime(2010),
        lastDay: DateTime(2050),
        selectedDayPredicate: (day) {
          return isSameDay(_selectedDay, day);
        },
        onDaySelected: (selectedDay, focusedDay) {
          Logger().d('selectedDay is $selectedDay');
          Logger().d('focused day is $focusedDay');
          setState(() {
            _selectedDay = selectedDay;
            _focusedDay = focusedDay; // update `_focusedDay` here as well
          });
        },
        onFormatChanged: (format) {
          setState(() {
            _calendarFormat = format;
          });
        },
        onPageChanged: (focusedDay) {
          _focusedDay = focusedDay;
        },
      ),
    );
  }
  
  // getTasks(String? taskDateTime) {
  getTasks() {
    return Expanded(
      child: FutureBuilder(
        future: FinPlanCalendarUtil().getTasksFromSalesforce(day: _selectedDay.toString()), 
        builder: (context, snapshot){
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: SizedBox(
                height: 40,
                width: 40,
                child: const CircularProgressIndicator(),
              ),
            ); // Show loading indicator while waiting for data
          }
          else if (snapshot.hasError) {
            return Text("Error: ${snapshot.error}"); // Show error if any
          }
          // else if (snapshot.hasData) {
          else{
            Logger().d('snapshot.data from getTasks is ${snapshot.data}');
            List<FinPlanTask> finplanTasks = snapshot.data ?? [];
            if(finplanTasks.isNotEmpty){
              // List<Map<String, dynamic>> allRecords = finplanTasks.map((item) {
              //   return item.toMap();
              // }).toList();
              List<Map<String, dynamic>> allRecords = [];
              for(FinPlanTask task in finplanTasks){
                allRecords.add(task.toMap());
              }
              return ListViewWidget(
                records: allRecords,
                onRecordSelected: (input){
                  handleRecordSelection(input);
                }
              );
            } 
            else {
              return const Text('No Events for the day'); // Handle case where no data is returned
            }
          }
        },
      ),
    );
  }
  
  dynamic handleRecordSelection(dynamic input) {
    log.d('Inside the handle Record Selection method!');
  }

}
