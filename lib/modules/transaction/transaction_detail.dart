// ignore_for_file: prefer_const_literals_to_create_immutables, prefer_const_constructors

import 'package:expenso/widgets/tile_widget.dart';
import 'package:flutter/material.dart';
import 'package:logger/logger.dart';

class FinPlanMessageDetail extends StatefulWidget {
  
  // Declare the class variables
  final String sms;
  final Function onCallBack;

  // Declare the constructor
  const FinPlanMessageDetail({
    super.key,
    required this.sms,
    required this.onCallBack
  });

  // Declare it's state class
  @override
  State<FinPlanMessageDetail> createState() => _FinPlanMessageDetailState();
}

// State class for `FinPlanMessageDetail`
class _FinPlanMessageDetailState extends State<FinPlanMessageDetail> {

  
  static final Logger log = Logger();

  // late Map<String, dynamic> data;
  // @override void initState() {
  //   super.initState();
  //   log.d(' Value=>${jsonDecode(widget.sms)}');
  //   data = jsonDecode(widget.sms);
  //   // data = Map.castFrom(jsonDecode(jsonEncode(widget.sms))) as Map<String, dynamic> ; // String -> dynamic -> Map<String, dynamic>
  // }

  late String data;
  @override void initState() {
    super.initState();
    log.d('Value=> ${widget.sms}');
    data = widget.sms;
    // data = Map.castFrom(jsonDecode(jsonEncode(widget.sms))) as Map<String, dynamic> ; // String -> dynamic -> Map<String, dynamic>
  }

  @override
  Widget build(BuildContext context) {

    String componentName = 'transaction_detail.dart';
    Logger().d('Build Method run for : $componentName');
    
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Container(
        height: 100,
        width: 100,
        decoration:BoxDecoration(
          // color : Colors.red,
          gradient: LinearGradient(colors: [Colors.amber.shade300, Colors.amber.shade500, Colors.amber.shade600]),
          border: Border.all(
            color: Colors.red,
            width: 3.0,
          ),
          borderRadius: BorderRadius.circular(20),
        ),
        child: TileWidget(
          topLeft: Text(widget.sms),
          // center: Text(data['id']),
          onCallBack: (){},
        ),
      ),
    );
  }
    
}

