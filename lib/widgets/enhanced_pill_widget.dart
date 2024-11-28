// ignore_for_file: must_be_immutable, no_leading_underscores_for_local_identifiers, non_constant_identifier_names

import 'package:finmind/helper/app_constants.dart';
import 'package:flutter/material.dart';
import 'package:logger/logger.dart';

class EnhancedPillWidget extends StatelessWidget {
  EnhancedPillWidget({
    super.key,
    required this.data,    
    required this.onPillSelected,
  });

  final List<Map<String, dynamic>> data;
  final Function onPillSelected;
  late Map<String, List<Map<String, dynamic>>> dataMapByTypes;

  @override
  Widget build(BuildContext context) {

    dataMapByTypes = generateTypesFromData();
    List<String> allTypes = [];
    
    
    // The following lines ensure the order of the pills are correct. 
    // First three pills should be All, Credit and Debit
    for(String type in dataMapByTypes.keys){
      if(type != 'All' && type != 'Credit' && type != 'Debit'){
        allTypes.add(type);
      }
    }
    allTypes.sort();
    allTypes = ['All', 'Credit', 'Debit', ...allTypes];
    Logger().d('All Types are inside build in enhancedPill widget => $allTypes');
    
    return Container(
      decoration: BoxDecoration(
        //color: Colors.blue.shade50, // Set desired background color
        borderRadius: BorderRadius.circular(5), // Make borders circular
      ),
      padding: const EdgeInsets.all(4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: generatePills(allTypes)
      ),
    );
  }


  // This method converts the input `data` to a `dataMap` - grouped by beneficiary / expense types
  Map<String, List<Map<String, dynamic>>> generateTypesFromData() {
    Map<String, List<Map<String, dynamic>>> fMap = {};
    Logger().d('Data passed is => ${data.length}');
    
    for (Map<String, dynamic> each in data) { // The `data` is the record list that has been passed to this widget

      // Classify by beneficiary type
      String beneficiaryType = each['BeneficiaryType'];
      List<Map<String, dynamic>> existing = fMap[beneficiaryType] ?? [];
      existing.add(each);
      fMap[beneficiaryType] = existing;

      // Classify by Credit/Debit
      String creditDebitType = each['Type'] == 'credit' ? 'Credit' : 'Debit';
      List<Map<String, dynamic>> creditDebitEntries = fMap[creditDebitType] ?? [];
      creditDebitEntries.add(each);
      fMap[creditDebitType] = creditDebitEntries;

      // Classify by none - meaning consider all entries
      String allType = 'All';
      List<Map<String, dynamic>> allEntries = fMap[allType] ?? [];
      allEntries.add(each);
      fMap[allType] = allEntries;

    }
    Logger().d('Currently the map in fMap => $fMap}');
    return fMap;
  }
  
  String generatePillLabel(String eachType) {
    
    int count = 0;
    String label;

    if(eachType == 'All'){
      count = data.length;
    }
    // only for credit type
    else if(eachType == 'Credit' || eachType == 'Debit'){
      count = dataMapByTypes[eachType]?.length ?? 0;
    }
    // // only for debit type
    // else if(eachType == 'Debit'){
    //   for(var each in data){
    //     if(each['Type'] == 'Debit') {
    //       count++;
    //     }
    //   }
    // }
    // For all other types
    else{
      count = dataMapByTypes[eachType]?.length ?? 0;
    }
    label = '$eachType ($count)';
    return label;
  }

  // Get the specific icon for the specific beneficiary type from the constant map (as defined in FinPlanconstants file)
  IconData getPillIcon(String type) {
    IconData iconData =  AppConstants.ICON_LABEL_DATA[type]?[1] ?? Icons.miscellaneous_services;
    return iconData;
  }

  // Get the specific label for the specific beneficiary type
  String getPillLabel(String eachType) {
    int count = dataMapByTypes[eachType]?.length ?? 0;
    Logger().d('count is $count and type is $eachType');
    return '$eachType ${count.toString()}';
    // return '$label-$count';
  }
  
  List<Widget> generatePills(List<String> availableTypes) {
    
    // Set<String> _allTypes = {...availableTypes, 'All', 'Credit', 'Debit'}; // Add these three hardcoded values as well
    Logger().d('availableTypes inside generatePills=> $availableTypes');
    List<Widget> allPills = [];
    for (String eachType in availableTypes){
      Widget each = Padding(
        padding: const EdgeInsets.all(4.0),
        child : 
        ElevatedButton.icon(
          icon: Icon(getPillIcon(eachType)),    // Icon on the button
          label: Text(getPillLabel(eachType)),  // Text on the button
          onPressed: () {
            onPillSelected(eachType);
          },
        ),
      );

      allPills.add(each);
      allPills.add(const SizedBox(width: 4));
    }     
    return allPills;
  }

}