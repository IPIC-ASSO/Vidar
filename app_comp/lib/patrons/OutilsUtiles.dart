import 'package:flutter/material.dart';

Widget messagePoissonRouge(
    {required String corps,
      required EdgeInsetsGeometry? margin,
      BorderRadius? bords,
      Color? color,
      Color? textColor}) {
  return Container(
    padding: const EdgeInsets.all(10),
    margin: margin,
    width: 250,
    decoration: BoxDecoration(
      color: color,
      borderRadius: bords??BorderRadius.zero,
    ),
    child: SelectableText(
      corps,
      style: TextStyle(fontSize: 16, color: textColor),
    ),
  );
}