import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vidar/AppCouleur.dart';

Widget messagePoissonRouge(
    {required String corps,
      required EdgeInsetsGeometry? margin,
      BorderRadius? bords,
      Color? color,
      Color? textColor,
      bool? expansion,
      FlutterTts? monTTS,
      Function? enreMesss,
    }) {
  return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children:[
    Container(
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
    ),
    AnimatedContainer(
      duration: Duration(milliseconds: 500),
      padding: EdgeInsets.all((expansion??false)?5:0),
      width: (expansion??false)?110:0,
      height: (expansion??false)?50:0,
      decoration: BoxDecoration(
        color: AppCouleur.grisTresClair,
        borderRadius: BorderRadius.circular(15),
      ),
      child: Visibility(
        visible: expansion??false,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            IconButton(onPressed: ()=>{monTTS!.speak(corps)}, icon: Icon(Icons.volume_up_outlined, color: AppCouleur.tertiaire,)),
            IconButton(onPressed: ()=>{enreMesss!(corps)}, icon: Icon(Icons.save_rounded, color: AppCouleur.tertiaire)),
          ],
        ),
      ),
    )
  ]);
}
 class OutilsOutils{

  static Future<FlutterTts> ConfigureTTS() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final FlutterTts monTTS = FlutterTts();
    await monTTS.setLanguage(prefs.getString("localite")??"fr-FR");
    await monTTS.setSpeechRate(0.5);
    await monTTS.setVolume(1.0);
    await monTTS.setPitch(1.0);
    print(prefs.getString("voix")??"Karen");
    print(prefs.getString("localite")??"fr-FR");
    monTTS.setVoice({
      "name":prefs.getString("voix")??"Karen",
      "locale":prefs.getString("localite")??"fr-FR",
    });
    return monTTS;
  }
 }