import 'package:flutter/material.dart';

class AppStyles {

  TextStyle kTextStyle10(Color? color) {
    return TextStyle(fontSize: 10, color: color);
  }

  TextStyle kTextStyle12(Color? color) {
    return TextStyle(fontSize: 12, color: color);
  }

  TextStyle kTextStyle12B(Color? color) {
    return TextStyle(fontSize: 12, color: color, fontWeight: FontWeight.bold);
  }
  TextStyle kTextStyle10B(Color? color) {
    return TextStyle(fontSize: 10, color: color, fontWeight: FontWeight.bold);
  }

  TextStyle kTextStyle14(Color? color) {
    return TextStyle(fontSize: 14, color: color);
  }

  TextStyle kTextStyle14B(Color? color) {
    return TextStyle(fontSize: 14, color: color, fontWeight: FontWeight.bold);
  }

  TextStyle kTextStyle14B5(Color? color) {
    return TextStyle(fontSize: 14, color: color, fontWeight: FontWeight.w500);
  }

  TextStyle kTextStyle12B5(Color? color) {
    return TextStyle(fontSize: 12, color: color, fontWeight: FontWeight.w500);
  }

  TextStyle kTextStyle14LT(Color? color) {
    return TextStyle(
        fontSize: 14,
        color: color,
        // fontWeight: FontWeight.bold,
        decoration: TextDecoration.lineThrough);
  }

  TextStyle kTextStyle16(Color? color) {
    return TextStyle(fontSize: 16, color: color);
  }

  TextStyle kTextStyle16B(Color? color) {
    return TextStyle(fontSize: 16, color: color, fontWeight: FontWeight.bold);
  }

  TextStyle kTextStyle16B5(Color? color) {
    return TextStyle(fontSize: 16, color: color, fontWeight: FontWeight.w500);
  }

  TextStyle kTextStyle16U(Color? color) {
    return TextStyle(
      fontSize: 16,
      color: color,
      decoration: TextDecoration.underline,
      decorationColor: color,
    );
  }

  TextStyle kTextStyle18(Color? color) {
    return TextStyle(
      fontSize: 18,
      color: color,
    );
  }

  TextStyle kTextStyle18B(Color? color) {
    return TextStyle(fontSize: 18, color: color, fontWeight: FontWeight.bold);
  }

  TextStyle kTextStyle18UB(Color? color) {
    return TextStyle(
      fontSize: 18,
      color: color,
      fontWeight: FontWeight.bold,
      decoration: TextDecoration.underline,
      decorationColor: color,
    );
  }

  TextStyle kTextStyle20(Color? color) {
    return TextStyle(fontSize: 20, color: color);
  }

  TextStyle kTextStyle20B(Color? color) {
    return TextStyle(fontSize: 20, color: color,fontWeight: FontWeight.bold);
  }

  TextStyle kTextStyle26(Color? color) {
    return TextStyle(fontSize: 26, color: color,fontWeight: FontWeight.w600);
  }

  BoxDecoration kBoxDecoration(Color? color) {
    return BoxDecoration(
      color: color,
      borderRadius: BorderRadius.circular(10),
    );
  }

  BoxDecoration kBoxBorderDecoration() {
    return BoxDecoration(
        borderRadius: BorderRadius.circular(11),
        border: Border.all(color: Colors.grey, width: 1));
  }

  BoxDecoration kBoxDecorationS() {
    return BoxDecoration(
        borderRadius: BorderRadius.circular(11),
        border: Border.all(color: Colors.white, width: 1));
  }

  BoxDecoration kBoxLandRBorderDecoration(Color? color) {
    return BoxDecoration(
        color: color,
        borderRadius: const BorderRadius.only(
            topRight: Radius.circular(30), topLeft: Radius.circular(30)),
        border: Border.all(color: Colors.white, width: 0));
  }
}
