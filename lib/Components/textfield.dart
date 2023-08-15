import 'package:flutter/material.dart';

class MyTextField extends StatefulWidget {
  const MyTextField({super.key, required this.hintText, this.controller, required this.obscureText, required this.iconName, required this.textCapital});

  final String hintText;
  final dynamic controller;
  final bool obscureText;
  final dynamic iconName;
  final dynamic textCapital;

  @override
  State<MyTextField> createState() => _MyTextFieldState();
}

class _MyTextFieldState extends State<MyTextField> {
  @override
  Widget build(BuildContext context) {
    return TextFormField(
      textCapitalization: widget.textCapital,
      controller: widget.controller,
      obscureText: widget.obscureText,
      decoration: InputDecoration(
        suffixIcon: widget.iconName,
        hintText: widget.hintText,
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

