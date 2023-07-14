import 'package:flutter/material.dart';

class MyTextField extends StatelessWidget {
  const MyTextField({super.key, required this.hintText, this.controller, required this.obscureText, required this.iconName});

  final String hintText;
  final dynamic controller;
  final bool obscureText;
  final dynamic iconName;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      decoration: InputDecoration(
        suffixIcon: iconName,
        hintText: hintText,
        enabledBorder: OutlineInputBorder(
          borderSide: const BorderSide(
             width: 2, color: Colors.white),
          borderRadius: BorderRadius.circular(10),
        ),
        fillColor: Colors.grey.shade300,
        filled: true,
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(
              color: Colors.grey.shade300
          ),
          borderRadius: BorderRadius.circular(10),
        ),
        focusedErrorBorder: const OutlineInputBorder(
            borderSide: BorderSide(
                color: Colors.red
            )
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 0),
      ),
    );
  }
}

