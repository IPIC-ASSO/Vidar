import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

class AppCouleur {
  static const Color charge = Color(0xff2b3a67);
  static const Color droitier = Color(0xE62877FF);
  Color principal = const Color(0xE6C1CBFF);
  Color secondaire = const Color(0xE653C2F5);
  static const Color tertiaire = Color(0xE6316AE3);
  Color quartenaire = const Color(0xFF37CB86);
  static const Color gaucher = Color(0xFF00A9DC);
  static const Color banni = Color(0xFFFA0000);
  static const Color tete = Color(0xFFFF5D5D);
  static const Color modification = Color(0xFF009F08);
  Color eco = const Color(0xFF00D90A);
  static const Color orangeWeb = Color(0xFFf59400);
  Color blanc = const Color(0xffffffff);
  Color noir = const Color(0xff000000);
  static const Color white = Color(0xFFf5f5f5);
  static const Color greyColor = Color(0xffaeaeae);
  Color grisTresClair = const Color(0xffE8E8E8);
  static const Color grisClair = Color(0xff928a8a);
  static const Color burgundy = Color(0xFF880d1e);
  Color indyBlue = const Color(0xFF0098AD);
  static const Color spaceCadet = Color(0xFF2a2d43);


  AppCouleur(){

    if(SchedulerBinding.instance.platformDispatcher.platformBrightness==Brightness.dark){
      grisTresClair  = const Color(0xff8d8686);
      eco = const Color(0xFF22B629);
      principal = const Color(0xE63DA6DE);
      quartenaire = const Color(0xFF00CE69);
      indyBlue = const Color(0xFFFFFFFF);
      secondaire = const Color(0xE676D1FF);
      blanc = const Color(0xFF000000);
      noir = const Color(0xffffffff);
    }
  }
}
