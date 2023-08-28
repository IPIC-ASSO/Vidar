import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:vidar/patrons/MesConstantes.dart';
import 'package:vidar/patrons/OutilsUtiles.dart';
import 'package:vidar/usineDeBiscottesGrillees.dart';

import 'AppCouleur.dart';
import 'interfaceDiscussion.dart';
import 'main.dart';

class MontreQrCode extends StatefulWidget {

  final String idUt;
  final String messageAffiche;
  final String messageLu;
  final String messageDebut;

  const MontreQrCode({super.key, required this.idUt, required this.messageAffiche, required this.messageLu, required this.messageDebut, });

  @override
  State<MontreQrCode> createState() => _MontreQrCodeState();
}

class _MontreQrCodeState extends State<MontreQrCode> with TickerProviderStateMixin {

  FirebaseFirestore db = FirebaseFirestore.instance;
  late final StreamSubscription<DocumentSnapshot<Map<String, dynamic>>> ecouteur;
  String? nomInconnu;
  late FlutterTts monTTS;

  @override
  void initState() {
    super.initState();
    OutilsOutils.ConfigureTTS().then((value) => monTTS=value);
    ecoute();
    FirebaseAuth.instance.authStateChanges().listen((User? user) {
      if (user == null) {
        Navigator.of(context).push(PageRouteBuilder(
          pageBuilder: (_, __, ___) => const MyHomePage(),
          transitionDuration: const Duration(milliseconds: 500),
          transitionsBuilder: (_, a, __, c) => FadeTransition(opacity: a, child: c),
        ));
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Expanded(
            flex: 1,
            child:Padding(padding:EdgeInsets.fromLTRB(15, 25, 15,0),child:QrImageView(
                data: "https://vidar-9e8ac.web.app/?dest=${widget.idUt}",
                version: QrVersions.auto,
              ),)
          ),
          Expanded(
            flex: 0,
            child: Padding(padding:EdgeInsets.all(15),child:Row(
              children: [
              Visibility(
                visible: widget.messageAffiche.isNotEmpty,
                child: Expanded(child:Padding(padding:EdgeInsets.all(5),
                      child:ElevatedButton.icon(
                      icon: Icon(Icons.text_snippet_outlined),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppCouleur.principal,
                        foregroundColor : AppCouleur.white,
                        minimumSize: const Size.fromHeight(50),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10.0)
                        ),
                      ),
                      onPressed: (){
                        showDialog(context: context,
                            builder: (context)=>AlertDialog(
                              title: Text("Vidar-communication"),
                              content: Text(widget.messageAffiche+" \n\nIPIC-ASSO garantit la confidentialité et la sécurité de la communication"),
                              actions: [IconButton(onPressed: ()=>{Navigator.of(context).pop()}, icon: Icon(Icons.close))],
                            ));
                      },
                      label: Text("Afficher le message")
                  ))),),
                Visibility(
                    visible: widget.messageLu.isNotEmpty,
                    child:Expanded(child: Padding(padding:EdgeInsets.all(5),
                      child:ElevatedButton.icon(
                        icon: Icon(Icons.volume_up,),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppCouleur.principal,
                          foregroundColor : AppCouleur.white,
                          minimumSize: const Size.fromHeight(50),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10.0)
                          ),
                        ),
                        onPressed: ()=>{monTTS.speak(widget.messageLu)},
                        label: Text("Lire le message")
                  ))))
              ],
            ))
          )
        ],
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endTop,
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppCouleur.greyColor,
        child: Icon(Icons.close),
        onPressed: ()=>{Navigator.of(context).pop()},
        tooltip: "Fermer",
      ),
    );
  }

  ecoute() {
    ecouteur = db.collection(MesConstantes.cheminUtilisateur).doc(widget.idUt).snapshots().listen((event) async {
      if(event.data()!["contact"]==null)nomInconnu="inconnnnnnnu";
      else if(nomInconnu==null)nomInconnu=event.data()!["contact"];
      else{
        String destinataire = event.data()!["contact"];
        final QuerySnapshot<Map<String, dynamic>> listeConv = await db.collection(MesConstantes.cheminListeMessages).get();
        if(listeConv.docs.any((element) => element.id.contains(widget.idUt) && element.id.contains(destinataire))){
          String idConv = listeConv.docs.firstWhere((element) => element.id.contains(widget.idUt) && element.id.contains(destinataire)).id;
          final doc = await db.collection(MesConstantes.cheminUtilisateur).doc(destinataire).get();
          String pseudo = "inconnu au bataillon";
          if(doc.data()!= null && doc.data()![MesConstantes.nomUti]!= null)pseudo = doc.data()![MesConstantes.nomUti];

          Navigator.push(context,
            PageRouteBuilder(
              pageBuilder: (_, __, ___) => InterfaceDiscussion(idUti: widget.idUt, idConv: idConv, pseudoDest: pseudo,message: widget.messageDebut,),
              transitionDuration: const Duration(milliseconds: 500),
              transitionsBuilder: (_, a, __, c) => FadeTransition(opacity: a, child: c),
            ),
          );

          ecouteur.cancel();
          db.collection(MesConstantes.cheminUtilisateur).doc(widget.idUt).update({MesConstantes.contact:""});
          }else{
          Usine.montreBiscotte(context, "Veuillez scanner le QR-code à nouveau", this);
        }
      }
    });
  }
}