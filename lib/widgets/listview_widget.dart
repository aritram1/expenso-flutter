// ignore_for_file: prefer_const_constructors

import 'package:flutter/material.dart';
import 'package:logger/logger.dart';

class ListViewWidget extends StatefulWidget {
  const ListViewWidget({
    Key? key,
    required this.records,
    required this.onRecordSelected,
  }) : super(key: key);

  final List<Map<String, dynamic>> records;
  final Function(dynamic) onRecordSelected;

  @override
  _ListViewWidgetState createState() => _ListViewWidgetState();
}

class _ListViewWidgetState extends State<ListViewWidget> {

  Set<String> selectedIds = {};

  @override
  Widget build(BuildContext context) {
    
    String componentName = 'listview_widget.dart';
    Logger().d('Build Method run for : $componentName');
    
    final taskList = widget.records;
    if(taskList.isNotEmpty){
      return ListView.separated(
        itemBuilder: (context, index) {
          Map<String, dynamic> each = taskList[index];
          return getEachListTile(context, each); 
        },
        separatorBuilder: (context, index) {
          return SizedBox(height: 4); // Divider();
        },
        itemCount: taskList.length,
      );
    }
    else{
      return const Center(child : Text('No data to show!'));
    }
  }
  
  Widget getEachListTile(BuildContext context, Map<String, dynamic> each) {

    String id = each['id']!.toString();
    String subject = each['subject']!.toString();
    String when = each['when']!.toString();
    String details = each['details']!.toString();
    bool completed = each['completed'] ?? false;
    bool allDay = each['allDay'] ?? false;
    bool recurring = each['recurring'] ?? false;
    String priority = each['priority']!.toString();

    return 
    Padding(
      padding: const EdgeInsets.symmetric(horizontal : 8.0),
      child: Container(
        decoration: BoxDecoration(
          color : getTileColor(priority),
          borderRadius: BorderRadius.circular(10)
        ),
        child: ListTile(
          leading: Checkbox(
            value: selectedIds.contains(id),
            onChanged: (value) {
              setState(() {
                if (value != null && value) {
                  selectedIds.add(id);
                } else {
                  selectedIds.remove(id);
                }
              });
              widget.onRecordSelected(each);
            },
          ),
          title: completed 
            ? Text(subject, style: TextStyle(decoration: TextDecoration.lineThrough)) 
            : Text(subject),
          subtitle: Text(details),
          trailing: Text(when),
          // tileColor: getTileColor(imp),
        ),
      ),
    );
  }
  
  Color getTileColor(String priority) {
    Color color = Colors.black;
    switch (priority) {
      case 'Not Started':
        color = Colors.red.shade200;
        break;
      case 'Closed':
        color = Colors.green.shade200;
        break;
      default:
        color = Colors.amber.shade200;
        break;
    }
    return color;
  }
}
