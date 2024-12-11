// ignore_for_file: constant_identifier_names
import 'dart:convert';
import 'package:expenso/helper/app_exception.dart';
import 'package:expenso/helper/salesforce_query_controller.dart';
import 'package:expenso/model/model_task.dart';
import 'package:logger/logger.dart';

class FinPlanCalendarUtil {
  
  List<FinPlanTask> allTasks = [];
  // List<Map<String, dynamic?>> processedTasks = [];

  Future<List<Map<String, dynamic>>> getTasksForTesting({String? day}) async {
    day = (day != null) ? day.split(' ')[0] : DateTime.now().toString().split(' ')[0]; // 2024-04-17
    List<Map<String, dynamic>> testData = [
      {'id': '100', 'name': 'Task 1', 'when': '2020-03-05 00:00:00Z', 'details': 'One Sample Task', 'priority': 1, 'allDay': false, 'recurring': false, 'completed': false},
      {'id': '200', 'name': 'Task 2', 'when': '2024-12-31 00:00:00Z', 'details': 'Two Sample Task', 'priority': 2, 'allDay': false, 'recurring': false, 'completed': false},
      {'id': '300', 'name': 'Task 3', 'when': '2013-11-04 00:00:00Z', 'details': '3rd Sample Task', 'priority': 3, 'allDay': false, 'recurring': false, 'completed': false},
      {'id': '400', 'name': 'Task 4', 'when': '2018-01-06 00:00:00Z', 'details': '4th Sample Task', 'priority': 1, 'allDay': false, 'recurring': false, 'completed': false},
      {'id': '500', 'name': 'Task 5', 'when': '2018-01-06 00:00:00Z', 'details': '5th Sample Task', 'priority': 1, 'allDay': false, 'recurring': false, 'completed': false},
      {'id': '600', 'name': 'Task 6', 'when': '2018-01-06 00:00:00Z', 'details': '6th Sample Task', 'priority': 1, 'allDay': false, 'recurring': false, 'completed': false},
    ];
    return Future.value(testData);
  }

  // A function to get the list of tasks from salesforce
  Future<List<FinPlanTask>> getTasksFromSalesforce({String? day}) async {
    
    String dayStr = (day != null) ? day.split(' ')[0] 
                                  : DateTime.now().toString().split(' ')[0]; // 2024-04-17
    
    Map<String, dynamic> response = await SalesforceQueryController.queryFromSalesforce(
      objAPIName: 'Task', 
      fieldList: ['Id', 'CreatedDate', 'ACtivityDate', 'Subject', 'Status', 'IsRecurrence', 'WhatId', 'Priority', 'CompletedDateTime', 'Description'], 
      whereClause: dayStr.isNotEmpty ? 'ActivityDate = $dayStr' : '',
      orderByClause: 'ActivityDate desc',
      count : 20
    );
    if(response['error'] != null){
      Logger().d('Inside error block!');
      throw AppException('Error occurred while retrieving tasks from SF => ${jsonEncode(response['error'] as Map<String, dynamic>)})');
    }
    else{
      Logger().d('Hi here too1');
      allTasks = processTasks(response['data']['data']);
      return Future.value(allTasks);
    }

    //   List<dynamic> dataList = response['data']['data'];
    //   Logger().d('dataList => ${jsonEncode(dataList)})');
    //   if(dataList.isNotEmpty){
    //     List<Map<String, dynamic>> allTasks = dataList.map((item) {
    //       return item as Map<String, dynamic>;
    //     }).toList();
    //     Logger().d('allTasks => $allTasks');
    //     processedTasks = processTasks(allTasks);
    //     Logger().d('all processed tasks => $processedTasks');
    //   }
    //   return Future.value(processedTasks);
    // }
  }

  List<FinPlanTask> processTasks(List<dynamic> salesforceTasks){
    Logger().d('Hi here too2');
    List<FinPlanTask> finPlanTasks = [];
    for(dynamic task in salesforceTasks){
      Map<String, dynamic> t = task as Map<String, dynamic>;
      finPlanTasks.add(FinPlanTask.fromMap(t));
    }
    return finPlanTasks;
  }

  // A function to get the list of tasks from local db
  // Future<Map<String, dynamic>> getTasksFromLocalDB({String? day}) async {
    // final db = await DatabaseService.instance.database;
    // List<Map<String, Object?>> tasks = await db.rawQuery('SELECT * FROM task');
    // // List<Map<String, Object>> tasksAsObject = tasks.map((task) => task as Map<String, Object>).toList();
    // for(Map<String, Object?> each in tasks){
    //   Logger().d('Each Task => ${each.toString}');
    //   var dbTask = {
    //     'id' : each['id'] ?? 9999,
    //     'name' : each['name'] ?? 'DEFAULT_NAME',
    //     'when' : (each['when'] ?? DateTime.now()).toString(),
    //     'details' : (each['details'] ?? '').toString(),
    //     'priority' : each['priority'] ?? 1, // in case priority is not null 
    //     'allDay' : each['allDay'] ?? false,
    //     'recurring' : each['recurring'] ?? false,
    //     'completed' : each['completed'] ?? false,
    //   };
    //   data['data']?.add(dbTask);
    // }
    // Logger().d('La la Data=> ${data['data']}');
    // return data;
    // }


}