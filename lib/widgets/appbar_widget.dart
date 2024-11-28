// ignore_for_file: prefer_const_constructors

import 'package:flutter/material.dart';
class AppBarWidget extends StatelessWidget {

  const AppBarWidget({
    Key? key,
    required this.title,
    required this.leadingIconAction,
    required this.leadingIcon, 
    required this.availableActions,
  }) : super(key: key);

  final String title;
  final IconData leadingIcon;
  final bool Function({String input}) leadingIconAction;
  final List<Map<IconData, Future<bool> Function({String input})>> availableActions;

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: Text(title),
      leading: IconButton(
        icon: Icon(leadingIcon),
        onPressed: () => leadingIconAction(),
      ),
      actions: [
        for (var action in availableActions)
          for (var entry in action.entries)
            IconButton(
              icon: Icon(entry.key),
              onPressed: () => entry.value(),
            ),
      ],
    );
  }
  
  // generateActions() {
  //   List<IconButton> actions = [];
  //   Map<IconData, String? Function({String input})> each;
  //   for(each in availableActions){
  //     actions.add(
  //       IconButton(
  //         icon: Icon(each.entries.first.key),
  //         onPressed: each.entries.first.value,
  //       )
  //     );
  //   }
  // }

}
