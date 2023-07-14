import 'package:flutter/material.dart';

class FormButton extends StatelessWidget {
  const FormButton({super.key, required this.horizontalPadding, required this.buttonText});

  final String buttonText;

  final double horizontalPadding;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: horizontalPadding, vertical: 0),
      child: ElevatedButton(
        onPressed: () {},
        style: ButtonStyle(
          backgroundColor: MaterialStateProperty.all(Colors.green[600]),
        ),
        child: Center(
          child: Text(
            buttonText,
            style: const TextStyle(
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }
}
