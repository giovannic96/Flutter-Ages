import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

/* DATE FORMATTER */
String dateFormatted() {
  var now = DateTime.now();

  var formatter = new DateFormat("EEE, MMM d, ''yy");
  String formatted = formatter.format(now);

  return formatted;
}

String dateBirthFormatted(DateTime date) {
  
  var formatter = new DateFormat("yyyy-MM-dd");
  String formatted = formatter.format(date);

  return formatted;
}

/* COLOR FORMATTER */
Color hexToColor(String str) {
  return new Color(int.parse(str, radix: 16));
}

String stringToHex(String colorStr)  {
  return colorStr.toString().substring(37,45);
}

/* STRING FORMATTER */
String firstTwoLetters(String str) {
  List<String> splitted = str.split(" ");
  return splitted.length == 1 ? splitted[0][0].toUpperCase() : splitted[0][0].toUpperCase() + splitted[1][0].toUpperCase();
}

