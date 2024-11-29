// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables

import 'package:flutter/material.dart';
import 'package:logger/logger.dart';

class TileWidget extends StatefulWidget {
  
  const TileWidget({
    super.key,
    this.padding = 8.0,
    this.borderRadius = 20,
    this.borderColor = const Color(0xFFE1BEE7), // Colors.purple.shade100
    this.gradientColors = const [Color(0xFFE1BEE7), Color(0xFFCE93D8)], // [Colors.purple.shade100, Colors.purple.shade200]
    this.title, 
    this.topLeft,
    this.topMid,
    this.topRight,
    this.centerLeft,
    this.center,
    this.centerRight,
    this.bottomLeft,
    this.bottomMid,
    this.bottomRight,
    required this.onCallBack,
  });

  final double padding;
  final double borderRadius;
  final List<Color> gradientColors;
  final Color borderColor;
  final String? title;
  final Widget? topLeft;
  final Widget? topMid;
  final Widget? topRight;
  final Widget? centerLeft;
  final Widget? center;
  final Widget? centerRight;
  final Widget? bottomLeft;
  final Widget? bottomMid;
  final Widget? bottomRight;
  final Function onCallBack;
  @override
  State<TileWidget> createState() => _TileWidgetState();
}

class _TileWidgetState extends State<TileWidget> {

  static final Logger log = Logger();
  
  // @override
  // void initState() {
  //   // initialize state variables
  //   super.initState();
  // }

  @override
  Widget build(BuildContext context) {
    
    String componentName = 'tile_widget.dart';
    Logger().d('Build Method run for : $componentName');
    
    return Padding(
      padding: EdgeInsets.all(0.0),
      child: GestureDetector(
        onTap: (){
          log.d('Callback is invoked for the TileWidget widget!');
          widget.onCallBack();
        },
        child: Container(
          decoration:BoxDecoration(
            gradient: LinearGradient(colors: widget.gradientColors),
            border: Border.all(
              color: widget.borderColor,
              width: 1.0,
            ),
            borderRadius: BorderRadius.circular(widget.borderRadius),
            // boxShadow: [
            //   BoxShadow(blurRadius: 2, color: Colors.purple.shade300, offset: Offset(1, -1)), 
            //   // BoxShadow(blurRadius: 10, color: Colors.purple.shade100), 
            //   // BoxShadow(blurRadius: 10, color: Colors.purple.shade100), 
            // ]
          ),
          child: Stack(
            children: [
          
              // Position 1 : Top left
              Visibility(
                visible: widget.topLeft != null,
                child: Positioned(
                  top: 0,
                  left: 0,
                  child: Padding(
                    padding: EdgeInsets.all(widget.padding),
                    child: widget.topLeft,
                  )
                ),
              ),
          
              // Position 2 : Top Middle
              Visibility(
                visible: widget.topMid != null,
                child: Positioned(
                  bottom: 0,
                  right: 0,
                  left: 0,
                  child: Padding(
                    padding: EdgeInsets.all(widget.padding),
                    child: widget.topMid,
                  )
                ),
              ),
          
              // Position 3 : Top Right
              Visibility(
                visible: widget.topRight != null,
                child: Positioned(
                  top: 0,
                  right: 0,
                  child: Padding(
                    padding: EdgeInsets.all(widget.padding),
                    child: widget.topRight,
                  )
                ),
              ),
          
              // Position 4 : Center Left
              Visibility(
                visible: widget.centerLeft != null,
                child: Positioned(
                  top: 0,
                  bottom: 0,
                  left: 0,
                  child: Padding(
                    padding: EdgeInsets.all(widget.padding),
                    child: widget.centerLeft,
                  )
                ),
              ),
              
              // Position 5 : Center
              Visibility(
                visible: widget.center != null,
                child: Center(
                  child: widget.center,
                ),
              ),
          
              // Position 6 : Center Right
              Visibility(
                visible: widget.centerRight != null,
                child: Positioned(
                  top: 0,
                  bottom: 0,
                  right: 0,
                  child: Padding(
                    padding: EdgeInsets.all(widget.padding),
                    child: widget.centerRight,
                  )
                ),
              ),
          
              // Position 7 : Bottom Left
              Visibility(
                visible: widget.bottomLeft != null,
                child: Positioned(
                  bottom: 0,
                  left: 0,
                  child: Padding(
                    padding: EdgeInsets.all(widget.padding),
                    child: widget.bottomLeft,
                  )
                ),
              ),
          
              // Position 8 : Bottom Middle
              Visibility(
                visible: widget.bottomMid != null,
                child: Positioned(
                  left: 0,
                  right: 0,
                  bottom: 0,
                  child: Padding(
                    padding: EdgeInsets.all(widget.padding),
                    child: widget.bottomMid,
                  )
                ),
              ),
          
              // Position 9 : Bottom Right
              Visibility(
                visible: widget.bottomRight != null,
                child: Positioned(
                  bottom: 0,
                  right: 0,
                  child: Padding(
                    padding: EdgeInsets.all(widget.padding),
                    child: widget.bottomRight,
                  )
                ),
              )
            ]
          ),
        ),
      ),
    );
  }
    
}