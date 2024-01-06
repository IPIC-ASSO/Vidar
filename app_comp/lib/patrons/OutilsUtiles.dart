import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vidar/AppCouleur.dart';
import 'package:vidar/parametres.dart';

Widget messagePoissonRouge(
    {required String corps,
      required EdgeInsetsGeometry? margin,
      BorderRadius? bords,
      Color? color,
      Color? textColor,
      bool? expansion,
      required BuildContext context,
      Function? enreMesss,
    }) {
  return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children:[
    Container(
      constraints: const BoxConstraints(minWidth: 50, maxWidth: 250),
      padding: const EdgeInsets.all(10),
      margin: margin,

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
      duration: const Duration(milliseconds: 500),
      padding: EdgeInsets.all((expansion??false)?5:0),
      width: (expansion??false)?110:0,
      height: (expansion??false)?50:0,
      decoration: BoxDecoration(
        color: AppCouleur().grisTresClair,
        borderRadius: BorderRadius.circular(15),
      ),
      child: Visibility(
        visible: expansion??false,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            IconButton(onPressed: ()=>{OutilsOutils.afficheTTS(context,corps)}, icon: const Icon(Icons.volume_up_outlined, color: AppCouleur.tertiaire,)),
            IconButton(onPressed: ()=>{enreMesss!(corps)}, icon: const Icon(Icons.save_rounded, color: AppCouleur.tertiaire)),
          ],
        ),
      ),
    )
  ]);
}
 class OutilsOutils{

  static Future<(FlutterTts,double)> ConfigureTTS() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final FlutterTts monTTS = FlutterTts();
    await monTTS.setLanguage(prefs.getString("localite")??"fr-FR");
    await monTTS.setSpeechRate(0.5);
    await monTTS.setVolume(1.0);
    await monTTS.setPitch(1.0);
    monTTS.setVoice({
      "name":prefs.getString("voix")??"Karen",
      "locale":prefs.getString("localite")??"fr-FR",
    });
    return (monTTS,prefs.getDouble("vitesse")??0.5);
  }

  static afficheTTS(BuildContext context, String texte) async {
    var (monTTS, vitesse) = await ConfigureTTS();
    bool pause = false;
    monTTS.speak(texte);
    showModalBottomSheet<void>(
        context: context,
        builder: (BuildContext context){
          return StatefulBuilder(
            builder: (BuildContext context, StateSetter setState) {
              return SizedBox(
              height: 200,
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    const Text('Lire le Texte',style: TextStyle(fontSize: 18,fontWeight: FontWeight.bold),),
                    Row(
                      mainAxisSize: MainAxisSize.max,
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                      IconButton(onPressed: (){
                        monTTS.stop();
                        monTTS.speak(texte);
                        setState(() {
                          pause = false;
                        });
                      }, icon: const Icon(Icons.replay),),
                      IconButton(
                        iconSize: 40.0,
                        icon: Icon(pause?Icons.play_arrow:Icons.pause),
                        onPressed: () {
                          if(pause)monTTS.speak(texte);
                          else monTTS.pause();
                          setState(() {
                            pause = !pause;
                          });
                        }
                      ),
                      IconButton(
                        icon: const Icon(Icons.settings),
                        onPressed: () => Navigator.of(context).push(PageRouteBuilder(
                          pageBuilder: (_, __, ___) => const Parametres(vitefait: true,),
                          transitionDuration: const Duration(milliseconds: 500),
                          transitionsBuilder: (_, a, __, c) => FadeTransition(opacity: a, child: c),
                        ))
                      ),
                    ],),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      mainAxisSize: MainAxisSize.max,
                      children: [
                        const Text("Vitesse"),
                        Slider(
                          value: vitesse*4,
                          max: 4.0,
                          onChanged: (double value){
                            monTTS.setSpeechRate(value/4);
                            setState(() {
                              vitesse = value/4;
                            });
                          }),
                      ],
                    )
                  ],
                ),
              ),
            );
          }
        );
      }
    );
  }
 }