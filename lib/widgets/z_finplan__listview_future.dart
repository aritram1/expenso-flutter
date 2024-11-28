// // ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables

// import 'package:expenso_app/widgets/finplan__listview.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter/material.dart';

// class FinPlanListViewFuture extends StatefulWidget {
//   FinPlanListViewFuture({
//     Key? key,
//     required this.futureRecords,
//     required this.onRecordSelected,
//   }) : super(key: key);

//   final Future<List<Map<String, dynamic>>> futureRecords;
//   final Function(dynamic) onRecordSelected;

//   @override
//   _FinPlanListViewFutureState createState() => _FinPlanListViewFutureState();
// }

// class _FinPlanListViewFutureState extends State<FinPlanListViewFuture> {

//   @override
//   Widget build(BuildContext context) {
//     return FutureBuilder(
//       future : getFutureData(),
//       builder: (context, snapshot) {
//         if(snapshot.connectionState == ConnectionState.waiting){
//           return CircularProgressIndicator();
//         }
//         else if(snapshot.hasError){
//           return Text("Some Error occurred ${snapshot.error.toString()}");
//         }
//         else{
//           return FinPlanListView(
//             records: snapshot.data!,
//             onRecordSelected: (input){

//             },
//           );
//           }
//       }
//     );
//   }

//   f
  
  
// }
