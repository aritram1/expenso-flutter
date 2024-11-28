import 'package:flutter/material.dart';

class LoginProviderWidget extends StatelessWidget {
  
  final String name, image;
  final void Function()? onTap;
  
  const LoginProviderWidget({
    super.key, 
    required this.name, 
    required this.image, 
    this.onTap
  });

  @override
  Widget build(BuildContext context) {
    return 
    GestureDetector(
      onTap: onTap,
      child : Container(
        height: 64,
        width : 64,
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.primary,
          image: DecorationImage(
            image: AssetImage(image),
            fit: BoxFit.cover,
          ),
          border: Border.all(
            width: 1,
            color: Colors.white
          ),
          borderRadius: BorderRadius.circular(8),
        ),
      )
    );
  }
}