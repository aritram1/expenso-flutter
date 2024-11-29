import 'package:flutter/material.dart';
import 'package:logger/logger.dart';

class StatefulButtonWidget extends StatelessWidget {
  final String text;
  final String value;
  final bool isSelected; // New property to indicate whether the button is selected
  final ValueChanged<String> onSelectionChanged;

  const StatefulButtonWidget({
    Key? key,
    required this.text,
    required this.value,
    required this.isSelected, // Accepts whether the button is selected or not
    required this.onSelectionChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    
    String componentName = 'stateful_button_widget.dart';
    Logger().d('Build Method run for : $componentName');
    
    return ElevatedButton(
      onPressed: () {
        onSelectionChanged(value); // Notify parent of the selected value
      },
      style: ElevatedButton.styleFrom(
        foregroundColor: Colors.white, backgroundColor: isSelected ? Theme.of(context).colorScheme.primary : Colors.grey.shade400,
      ),
      child: Text(
        text,
        style: const TextStyle(fontSize: 12),
      ),
    );
  }
}
