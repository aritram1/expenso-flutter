// ignore_for_file: must_be_immutable

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class SavingsAccountWidget extends StatelessWidget {
  const SavingsAccountWidget({
    super.key,
    required this.data,
    required this.onCardSelected,
  });

  final Map<String, dynamic> data;
  final Function onCardSelected;

 static String getTimeDifferenceInString(String lastModifiedStr){
  int daysDiff = DateTime.now().difference(DateTime.parse(lastModifiedStr)).inDays;
  String lastUpdated;
  switch(daysDiff){
      case 0:
        lastUpdated = 'Today';
        break;
      case 1:
        lastUpdated = 'Yesterday';
        break;
      default:
        lastUpdated = '$daysDiff days ago';
        break;
    }
    return lastUpdated;
 }

  @override
  Widget build(BuildContext context) {

    // String code = data['FinPlan__Account_Code__c'];
    String name = data['Name'];
    double lastBalance = data['FinPlan__Last_Balance__c'] ?? 0;
    // String lastUpdatedOn = DateFormat('dd-MM-yyyy').format(DateTime.parse(data['LastModifiedDate']));
    String lastUpdated = getTimeDifferenceInString(data['LastModifiedDate']);    

    return Card(
      color: Colors.blue.shade100,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15.0),
      ),
      child: ListTile(
        leading: const Icon(Icons.savings),
        title: Text(name),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Last Updated $lastUpdated', style: const TextStyle(fontSize: 10)),
            // Text('Update Date/Time: $lastUpdatedOn', style: const TextStyle(fontSize: 10)),
          ],
        ),
        // trailing: FinPlanTile(
        //   center: const Text('Hello'),
        //   onCallBack: (){}
        // ),
        trailing: Text(NumberFormat.currency(locale: 'en_IN', symbol: '₹').format(lastBalance))
      )
    );  
  }

}