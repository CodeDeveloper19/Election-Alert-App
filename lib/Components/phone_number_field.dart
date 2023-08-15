import 'package:flutter/material.dart';
import 'package:intl_phone_number_input/intl_phone_number_input.dart';

class PhoneNumberTextField extends StatefulWidget {
  PhoneNumberTextField({super.key, required this.updateUserPhoneNumber, required this.userPhoneNumber, required this.updateIsPhoneNumberValid, required this.isPhoneNumberValid, required this.phoneController});

  final Function(String) updateUserPhoneNumber;
  String userPhoneNumber;
  final Function(bool) updateIsPhoneNumberValid;
  bool isPhoneNumberValid;
  final dynamic phoneController;

  @override
  State<PhoneNumberTextField> createState() => _PhoneNumberTextFieldState();
}

class _PhoneNumberTextFieldState extends State<PhoneNumberTextField> {
  PhoneNumber number = PhoneNumber(isoCode: 'NG');

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 15, bottom: 10),
      padding: EdgeInsets.only(left: 20, bottom: (widget.isPhoneNumberValid || widget.userPhoneNumber == '' || widget.userPhoneNumber == '+234') ? 0 : 12),
      decoration: BoxDecoration(
        color: Colors.grey[300],
        borderRadius: BorderRadius.circular(10),
      ),
      child: InternationalPhoneNumberInput(
        onInputChanged: (PhoneNumber number) {
          widget.updateUserPhoneNumber(number.phoneNumber!);
        },
        onInputValidated: (bool value) {
          widget.updateIsPhoneNumberValid(value);
        },
        textFieldController: widget.phoneController,
        countries: ["NG"],
        initialValue: number,
        hintText: 'Phone Number',
        ignoreBlank: true,
        maxLength: 12,
        autoValidateMode: AutovalidateMode.always,
        selectorButtonOnErrorPadding: 0,
        inputDecoration: InputDecoration(
          hintText: 'Enter phone number',
          // Customize the appearance here
          border: InputBorder.none, // Remove the underline
          contentPadding: EdgeInsets.symmetric(horizontal: 0, vertical: (widget.isPhoneNumberValid || widget.userPhoneNumber == '' || widget.userPhoneNumber == '+234') ? 12 : 0), // Add padding around the input
        ),
      ),
    );
  }
}
