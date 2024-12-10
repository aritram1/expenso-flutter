// The model class to represent any task

import 'package:intl/intl.dart';
import 'package:logger/logger.dart';

class FinPlanTask{
       
  String id;
  String subject;
  String details;
  String when;
  String priority;
  String status;
  bool allDay;
  bool recurring;
  bool completed;

  FinPlanTask({
    required this.id,
    required this.subject, 
    required this.when,
    this.details = 'Default detail text', 
    this.status = 'Not Started',
    this.priority = 'Normal',
    this.recurring = false, 
    this.allDay = false,
    this.completed = false
  });

  static String formatDate(String dateString){
    DateTime activityDate = DateTime.parse(dateString.replaceAll('T', ' '));
    return DateFormat('yyyy-MM-dd').format(activityDate);
  }

  factory FinPlanTask.fromMap(Map<String, dynamic> task){
    Logger().d('Task=> $task}');
    FinPlanTask finplantask = FinPlanTask(
      id: task['Id'] ?? 'Default Id', 
      subject: task['Subject'] ?? 'Default Subject For The Task',
      when: task['ActivityDate'] != null ? formatDate(task['ActivityDate']) : '2020-03-05',
      details: task['Description'] ?? 'Default Description',
      priority: task['Priority'] ?? task['Priority'], 
      status: task['Status'] ?? task['Status'], 
      allDay: false,  // hardcoded for now
      recurring: task['IsRecurrence'] == true ? true : false,
      completed: task['Status'] == 'Completed' ? true : false
    ); 
    return finplantask;
  }

  // factory FinPlanTask.fromMap(Map<String, dynamic> task){
  //   DateTime activityDate = DateTime.parse(task['ActivityDate'].replaceAll('T', ' '));
  //   FinPlanTask fpt = FinPlanTask(
  //     id: task['Id'] ?? 'Default Id', 
  //     subject: (task['Subject'] != null) ? task['Subject'] : 'Default Subject For The Task',
  //     when: (task['ActivityDate'] != null) ?  DateFormat('yyyy-MM-dd').format(activityDate) : '2020-03-05 00:00:00',
  //     details: (task['Description'] != null) ?  task['Description'] : 'Default Description',
  //     priority: (task['Priority'] != null) ?  task['Priority'] : 'Low', 
  //     allDay: false,  // hardcoded for now
  //     recurring: task['IsRecurrence'] == true ? true : false,
  //     completed: task['Status'] == 'Completed' ? true : false
  //   ); 
  //   return fpt;
  // }

  Map<String, dynamic> toMap(){
    return {
      'id' : id,
      'subject' : subject,
      'details' : details,
      'when' : when,
      'allDay' : allDay,
      'recurring' : recurring,
      'priority' : priority,
      'status' : status,
      'completed' : completed,
    };
  }
}
