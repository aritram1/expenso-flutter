// Custom Wavy Clipper
import 'package:flutter/material.dart';

class WavyClipperWidget extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    Path path = Path();
    path.lineTo(0, size.height - 100); // Starting point of the curve
    path.quadraticBezierTo(
      size.width / 2, size.height, // Control point and peak of the curve
      size.width, size.height - 100, // Ending point of the curve
    );
    path.lineTo(size.width, 0); // Line to top-right corner
    path.close(); // Close the path
    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) {
    return false; // No need to reclip as the path doesn't change
  }
}