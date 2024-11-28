// // ignore_for_file: must_be_immutable
// // import 'package:ExpenseManager/widgets/finplan_table_widget.dart';
// import 'package:expenso_app/util/expense_data_generator.dart';
// import 'package:flutter/material.dart';
// import 'package:logger/logger.dart';

// class FinPlanAccountView extends StatelessWidget {
//   static final Logger log = Logger();

//   FinPlanAccountView({super.key});

//   dynamic Function(String) onLoadComplete = (result) {
//     log.d('Table loaded Result from FinPlanAccountView => $result');
//   };

//   @override
//   Widget build(BuildContext context) {
//     return FutureBuilder(
//       future: ExpenseDataGenerator.generateDataForFinPlanAccountViewv2(),
//       builder: (context, AsyncSnapshot<List<Map<String, dynamic>>> snapshot) {
//         if (snapshot.connectionState == ConnectionState.waiting) {
//           return const Center(
//             child: CircularProgressIndicator(),
//           );
//         } 
//         else if (snapshot.hasError) {
//           return Center(
//             child: Text('Error loading data FinPlanAccountView! ${snapshot.error.toString()}'),
//           );
//         }
//         else {
//           return FinPlanBankAccountWidget(data: snapshot.data!);
//           // return FinPlanTableWidget(
//           //   key: key,
//           //   headerNames: const ['Name', 'Balance', 'Last Updated'],
//           //   noRecordFoundMessage: 'Nothing to approve',
//           //   caller: 'FinPlanAccountView',
//           //   columnWidths: const [0.2, 0.25, 0.35],
//           //   data: snapshot.data!,
//           //   onLoadComplete: onLoadComplete,
//           //   defaultSortcolumnName: 'Last Updated', // 2 meaning the Date column
//           //   showSelectionBoxes : false
//           // );
//         }
//       },
//     );
//   }
// }