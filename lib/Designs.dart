import 'package:flutter/material.dart';

Color blueColor = Color(0xff0040a9);
Color whiteColor = Colors.white;
Color redColor = Color(0xffcb1522);

// TextField
class CustomTextFromField extends StatelessWidget {
  final TextEditingController controller;
  final String labelText;
  final String hintText;
  final IconData? prefixIcon;
 final String? Function(String?)? validator;
final void Function(String)? onChanged;
  CustomTextFromField(
      {required this.controller,
      required this.labelText,
      required this.hintText,
      required this.prefixIcon,this.validator,this.onChanged});
     

  @override
  Widget build(BuildContext context) {
    return TextFormField(
        style: TextStyle(color: Colors.black),
        controller: controller,
        validator: validator,
        onChanged: onChanged,
        decoration: CustomInputDecoration(labelText, hintText, prefixIcon));
  }
}

//Decoration for textFields
InputDecoration CustomInputDecoration(String labelText, String hintText, IconData? prefixIcon) {
  return InputDecoration(
    filled: true,
    fillColor: Colors.white,
    labelText: labelText,
    hintText: hintText,
    labelStyle: TextStyle(
        color: blueColor,
        fontSize: 16,
        fontWeight: FontWeight.bold // Set the color of the label text
        ),
    prefixIcon: prefixIcon!=null ? Icon(
      prefixIcon,
      size: 20,
      color:blueColor,
    ):null,
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(15.0),
      borderSide: BorderSide(
          color: Colors.black), // Set the color of the border when the TextFormField is focused
    ),
    enabledBorder: OutlineInputBorder(
      borderSide: BorderSide(color: blueColor),
      borderRadius: BorderRadius.circular(
          15.0), // Set the color of the border when the TextFormField is not focused
    ),
  );
}

//text style
TextStyle CustomTextStyle(double fontSize, Color color, FontWeight fontWeight) {
  return TextStyle(
    fontSize: fontSize,
    color: color,
    fontWeight: fontWeight,
  );
}
Widget CustomButton(String text,Color Background,Color textcolor, Function() onPressed) {
  return ElevatedButton(
    onPressed: onPressed,
    child: Text(
      text,
      style: CustomTextStyle(15, textcolor, FontWeight.normal),
    ),
    style: ElevatedButton.styleFrom(
      backgroundColor: Background,
      padding: EdgeInsets.symmetric(horizontal: 50, vertical: 10),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
    ),
  );
}
String? Function(String?) EmptyValidator(String message) {
  return (String? value) {
    if (value == null || value.isEmpty) {
      return message;
    }
    return null; // Return null when the field is valid
  };
}