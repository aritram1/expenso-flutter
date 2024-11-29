// ignore_for_file: must_be_immutable

import 'package:flutter/material.dart';
import 'package:logger/logger.dart';

class PillWidget extends StatelessWidget {
  const PillWidget({
    super.key,
    required this.types,
    required this.onPillSelected,
  });

  final Set<String> types;
  final Function onPillSelected;

  @override
  Widget build(BuildContext context) {
    
    String componentName = 'pill_widget.dart';
    Logger().d('Build Method run for : $componentName');
    
    String selectedPillName = '';
    return Container(
      decoration: BoxDecoration(
        //color: Colors.blue.shade50, // Set your desired background color
        borderRadius: BorderRadius.circular(5), // Make borders circular
      ),
      padding: const EdgeInsets.all(4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children:[
          for (String eachType in types)
            Padding(
              padding: const EdgeInsets.all(4.0),
              child: ElevatedButton(
                onPressed: () {
                  selectedPillName = eachType;
                  onPillSelected(selectedPillName);
                },
                child: Text(
                  eachType,
                  style: const TextStyle(fontSize: 12),
                ),
              ),
            ),
            const SizedBox(width: 8),
          ]
      ),
    );
  }
}