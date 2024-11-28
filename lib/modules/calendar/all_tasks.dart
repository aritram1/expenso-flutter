// // ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables

// import 'package:expenso_app/db/model/finplan__task.dart';
// import 'package:expenso_app/util/finplan__AppConstants.dart';
// import 'package:expenso_app/util/finplan__salesforce_util.dart';
// import 'package:expenso_app/widgets/finplan__button_stateful.dart';
// import 'package:flutter/material.dart';
// import 'package:logger/logger.dart';

// class FinPlanCalendarAllTasks extends StatefulWidget {
//   final Function onCallBack;
//   final DateTime? selectedDay;

//   const FinPlanCalendarAllTasks({super.key, required this.onCallBack, required this.selectedDay});

//   @override
//   State<FinPlanCalendarAllTasks> createState() => _FinPlanCalendarAllTasksState();
// }

// class _FinPlanCalendarAllTasksState extends State<FinPlanCalendarAllTasks> {
  
//   late FinPlanTask task;
//   late DateTime selectedDate;  
//   bool isRecurring = false;
//   List<String> recurringDays = [];
//   bool isAllDay = false;
//   final List<String> daysOfWeekWithSingleLetter = FinPlanAppConstants.DAYS_OF_WEEK_WITH_SINGLE_LETTER;

//   final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
//   final TextEditingController taskNameController = TextEditingController();
//   final TextEditingController taskTimeController = TextEditingController();

//   @override
//   void initState() {
//     super.initState();
//     selectedDate = widget.selectedDay!;
//   }

//   @override
//   Widget build(BuildContext context) {
//     BuildContext ctx = context;
//     return 
//     Padding(
//       padding: const EdgeInsets.all(16.0),
//       child: Center(
//         child : 
//         Form(
//           key: _formKey,
//           child: Column(
//             mainAxisAlignment: MainAxisAlignment.start,
//             children: <Widget>[
//               TextFormField(
//                 controller: taskNameController,
//                 decoration: InputDecoration(
//                   labelText: 'Subject',
//                   hintText: 'Enter the Task Subject'
//                 ),
//                 validator: (value) {
//                   if (value == 'Start') {
//                     return null;
//                   } 
//                   else {
//                     return ('Enter Start');
//                   }             
//                 },
//                 onChanged: (value) {
//                   Logger().d('Inside onchanged with $value');
//                 },
//               ),
//               SizedBox(height: 24),
//               Row(
//                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                 children: [
//                   Text('When is it ?', style: TextStyle(fontSize: 16), selectionColor: Colors.red),
//                   ElevatedButton(
//                     onPressed: () async {
//                       final DateTime? pickedDate = await showDatePicker(
//                         context: ctx,
//                         initialDate: selectedDate,
//                         firstDate: DateTime.now().add(const Duration(days : -365)), // Can select date upto one year back
//                         lastDate: DateTime.now().add(const Duration(days : 365)),
//                       );
//                       if(pickedDate != null){
//                         setState(() {
//                           selectedDate = pickedDate;  
//                         });
//                         Logger().d('Date picked as => $pickedDate');
//                       }
//                     },
//                     child: Text(selectedDate.toString().split(' ')[0]),
//                   ),
//                 ],
//               ),
//               SizedBox(height: 24),
//               Row(
//                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                 children: [
//                   Text('Recurring?', style: TextStyle(fontSize: 16), selectionColor: Colors.red),
//                   Checkbox(
//                     value: isRecurring, 
//                     onChanged: (value){
//                       setState(() {
//                         isRecurring = value ?? false;
//                       });
//                     }
//                   ),
//                 ],
//               ),
//               SizedBox(height: 12),
//               Visibility(
//                 visible : isRecurring,
//                 child: Column(
//                   mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                   children: [
//                     Text('Every', style: TextStyle(fontSize: 16), selectionColor: Colors.red),
//                     const SizedBox(height: 8.0),
//                     Row(
//                       children: List.generate(daysOfWeekWithSingleLetter.length, (index) => 
//                         Container(
//                           margin: const EdgeInsets.only(right: 8.0),
//                           child: FinPlanStatefulButton(
//                             text: daysOfWeekWithSingleLetter[index], 
//                             isSelected: true,
//                             value: daysOfWeekWithSingleLetter[index], 
//                             onSelectionChanged: (day) {
//                               Logger().d('Before Selected Days : $recurringDays');
//                               Logger().d('Returned day : $day');
//                               if(recurringDays.contains(day)){
//                                 recurringDays.remove(day);
//                               }
//                               else{
//                                 recurringDays.add(day);
//                               }
//                               Logger().d('After Selected Days : $recurringDays');
//                             }
//                           ),
//                         )
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//               SizedBox(height: 12),
//               ElevatedButton(
//                 onPressed: () async{
//                   Map<String, dynamic> result = await saveNewTask();
//                   Logger().d('=> ${result['data']}');
//                   Navigator.of(ctx).pop();
//                 }, 
//                 child: Text('Save')
//               ),
//             ],
//         ),
//         )
//       ),
//     );
//   }
  

//   Future<Map<String, dynamic>> saveNewTask() async {
//     Logger().d('selectedDate=> $selectedDate');
//     Map<String, dynamic> newTaskCreatedResponse = await SalesforceUtil.dmlToSalesforce(
//         opType: FinPlanAppConstants.INSERT,
//         objAPIName : 'Task', 
//         fieldNameValuePairs : [{
//           "Subject": taskNameController.text,
//           "ActivityDate": selectedDate,
//           "Description" : 'Created from Flutter App $taskNameController.text',
//           // recurring: isRecurring, 
//         }]
//     );
//     Logger().d('New Task creation response.body=> ${newTaskCreatedResponse.toString()}');
//     return Future.value(newTaskCreatedResponse);
//   }
// }
