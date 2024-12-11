// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables

import 'package:expenso/helper/app_constants.dart';
import 'package:expenso/helper/salesforce_dml_controller.dart';
import 'package:expenso/model/model_task.dart';
import 'package:expenso/widgets/stateful_button_widget.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:logger/logger.dart';

class FinPlanCreateNewTaskPage extends StatefulWidget {
  final Function onCallBack;
  final DateTime? selectedDay;

  const FinPlanCreateNewTaskPage({super.key, required this.onCallBack, required this.selectedDay});

  @override
  State<FinPlanCreateNewTaskPage> createState() => _FinPlanCreateNewTaskPageState();
}

class _FinPlanCreateNewTaskPageState extends State<FinPlanCreateNewTaskPage> {
  
  late FinPlanTask task;
  late DateTime selectedDate;  
  bool isRecurring = false;
  List<String> recurringDays = [];
  bool isAllDay = false;
  String _selectedPriority = 'Normal';
  final List<String> daysOfWeekWithSingleLetter = AppConstants.DAYS_OF_WEEK_WITH_SINGLE_LETTER;

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController taskNameController = TextEditingController();
  final TextEditingController taskTimeController = TextEditingController();

  @override
  void initState() {
    super.initState();
    selectedDate = widget.selectedDay!;
  }

  @override
  Widget build(BuildContext context) {
    String componentName = 'new_task.dart';
    Logger().d('Build Method run for : $componentName');
    return 
    Padding(
      padding: const EdgeInsets.all(16.0),
      child: Center(
        child : 
        Form(
          key: _formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              TextFormField(
                controller: taskNameController,
                decoration: InputDecoration(
                  labelText: 'Task Subject',
                  hintText: 'Enter the Task Subject'
                ),
                validator: (value) {
                  if (value == 'Start') {
                    return null;
                  } 
                  else {
                    return ('Enter Start');
                  }             
                },
                onChanged: (value) {
                  Logger().d('Inside onchanged with $value');
                },
              ),
              SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('When is it ?', style: TextStyle(fontSize: 16), selectionColor: Colors.red),
                  ElevatedButton(
                    onPressed: () async {
                      final DateTime? pickedDate = await showDatePicker(
                        context: context,
                        initialDate: selectedDate,
                        firstDate: DateTime.now().add(const Duration(days : -365)), // Can select date upto one year back
                        lastDate: DateTime.now().add(const Duration(days : 365)),
                      );
                      if(pickedDate != null){
                        setState(() {
                          selectedDate = pickedDate;  
                        });
                        Logger().d('Date picked as => $pickedDate');
                      }
                    },
                    child: Text(selectedDate.toString().split(' ')[0]),
                  ),
                ],
              ),
              SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Priority'),
                  DropdownButton<String>(
                    value: AppConstants.TASK_STATUS_NORMAL, // Default value is "Normal"
                    onChanged: (String? newValue) {
                      setState(() {
                        _selectedPriority = newValue!; // Update the selected value
                      });
                    },
                    items: <String>['Normal', 'High', 'Low'] // Dropdown options
                        .map<DropdownMenuItem<String>>((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(value),
                        );
                    }).toList(),
                  ),
                ],
              ),
              SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Recurring?', style: TextStyle(fontSize: 16), selectionColor: Colors.red),
                  Checkbox(
                    value: isRecurring, 
                    onChanged: (value){
                      setState(() {
                        isRecurring = value ?? false;
                      });
                    }
                  ),
                ],
              ),

              SizedBox(height: 12),
              Visibility(
                visible : isRecurring,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Every', style: TextStyle(fontSize: 16), selectionColor: Colors.red),
                    const SizedBox(height: 8.0),
                    Row(
                      children: List.generate(daysOfWeekWithSingleLetter.length, (index) => 
                        Container(
                          margin: const EdgeInsets.only(right: 8.0),
                          child: StatefulButtonWidget(
                            text: daysOfWeekWithSingleLetter[index], 
                            isSelected: true,
                            value: daysOfWeekWithSingleLetter[index], 
                            onSelectionChanged: (day) {
                              Logger().d('Before Selected Days : $recurringDays');
                              Logger().d('Returned day : $day');
                              if(recurringDays.contains(day)){
                                recurringDays.remove(day);
                              }
                              else{
                                recurringDays.add(day);
                              }
                              Logger().d('After Selected Days : $recurringDays');
                            }
                          ),
                        )
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 12),
              ElevatedButton(
                onPressed: () async {
                  await saveNewTask();
                  Navigator.of(context).pop();
                  setState(() {
                    
                  });
                }, 
                child: Text('Save')
              ),
            ],
        ),
        )
        
      ),
    );
  }

  Future<String> saveNewTask() async {

    String formattedDate = DateFormat('yyyy-MM-dd').format(selectedDate);
    Logger().d('selectedDate=> $selectedDate');
    
    List<Map<String, dynamic>> fieldNameValues = [{
      "Subject": taskNameController.text,
      "ActivityDate": formattedDate,
      "Status" : _selectedPriority,
      "Description" : 'Created from Flutter App ${taskNameController.text}',
      // recurring: isRecurring,
    }];
    Logger().d('fieldNameValues=> $fieldNameValues');

    Map<String, dynamic> newTaskCreatedResponse = await SalesforceDMLController.dmlToSalesforce(
      opType: AppConstants.INSERT,
      objAPIName : 'Task', 
      fieldNameValuePairs : fieldNameValues
    );
    Logger().d('New Task creation response.body=> ${newTaskCreatedResponse.toString()}');
    String newTaskId = newTaskCreatedResponse['data'][0]['id'];
    return Future.value(newTaskId);
  }

}
