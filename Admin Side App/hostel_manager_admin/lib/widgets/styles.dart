import 'package:flutter/material.dart';

BoxDecoration cardStyle() => BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(20),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.08),
          blurRadius: 20,
        ),
      ],
    );

BoxDecoration pillStyle() => BoxDecoration(
      color: Colors.grey.shade300,
      borderRadius: BorderRadius.circular(30),
    );

InputDecoration inputStyle() => InputDecoration(
      filled: true,
      fillColor: Colors.grey.shade300,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(30),
        borderSide: BorderSide.none,
      ),
    );

ButtonStyle blackButton({double radius = 20}) =>
    ElevatedButton.styleFrom(
      backgroundColor: Colors.black87,
      foregroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(radius),
      ),
    );
