import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:vidar/AppCouleur.dart';
import 'package:vidar/main.dart';
import 'package:universal_html/html.dart' as html;
import 'package:vidar/qrcode.dart';
import 'package:vidar/usineDeBiscottesGrillees.dart';
import 'Postier.dart';
import 'nouvelleConversation.dart';

class Accueil extends StatefulWidget {

  const Accueil({super.key});

  @override
  State<Accueil> createState() => _AccueilState();
}

class _AccueilState extends State<Accueil> with TickerProviderStateMixin{

  final FirebaseAuth auth = FirebaseAuth.instance;

  @override
  void initState() {
    super.initState();
    auth.authStateChanges().listen((User? user) {
      if(user!=null){
        Future.delayed(Duration.zero).then((value) => Navigator.of(context).push(PageRouteBuilder(
          pageBuilder: (_, __, ___) => const MyHomePage(sessionConnecte: true,),
          transitionDuration: const Duration(milliseconds: 500),
          transitionsBuilder: (_, a, __, c) => FadeTransition(opacity: a, child: c),
        )));
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppCouleur.blanc,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text("Bienvenue"),
        elevation: 20,
      ),
      body: Container(
        padding: const EdgeInsets.all(5),
        child: ListView(
          shrinkWrap: true,
          children: [
            Center(
              child: Image.asset(
                "assets/images/vidar_logo.png",
                width: 200,
              ),
            ),
              Column(
                children: [
                 Padding(
                  padding: const EdgeInsets.all(10),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Padding(
                          padding: const EdgeInsets.all(10),
                          child:ElevatedButton(
                            onPressed: ()=>{
                              Navigator.of(context).push(PageRouteBuilder(
                                pageBuilder: (_, __, ___) => const MyHomePage(sessionConnecte: true,),
                                transitionDuration: const Duration(milliseconds: 500),
                                transitionsBuilder: (_, a, __, c) => FadeTransition(opacity: a, child: c),
                              ))
                            },
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.all(5),
                              backgroundColor: AppCouleur.principal,
                              foregroundColor : AppCouleur.white,
                              minimumSize:Size(MediaQuery.of(context).size.width/(MediaQuery.of(context).size.aspectRatio>1?2:1),50),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10.0)
                              ),
                            ),
                            child: const Text("Session connectée", style: TextStyle(fontSize: 18),)
                          )
                      ),
                      const Padding(
                      padding: EdgeInsets.all(5),
                        child: Tooltip(
                          preferBelow: false,
                          textStyle: TextStyle(fontSize: 16, color: AppCouleur.blanc),
                          message: "Utilisation d'un compte, pour utiliser des messages pré-enregistrés, conserver les conversations, et les continuer sur n'importe quel appareil.",
                          child: Icon(Icons.info_outline),
                        )
                      )

                    ],
                  ),
                 ),
                  Padding(
                    padding: const EdgeInsets.all(10),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Padding(
                            padding: const EdgeInsets.all(10),
                            child:ElevatedButton(
                                onPressed: ()=>{temporise()},
                                style: ElevatedButton.styleFrom(
                                  padding: const EdgeInsets.all(5),
                                  backgroundColor: AppCouleur.tertiaire,
                                  foregroundColor : AppCouleur.white,
                                  minimumSize:Size(MediaQuery.of(context).size.width/(MediaQuery.of(context).size.aspectRatio>1?2:1),50),
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10.0)
                                  ),
                                ),
                                child: const Text("Session temporaire", style: TextStyle(fontSize: 18),)
                            )
                        ),
                        const Padding(
                            padding: EdgeInsets.all(5),
                            child:Tooltip(
                              textStyle: TextStyle(fontSize: 16, color: AppCouleur.blanc),
                              preferBelow: false,
                              message: "Continuez sans vous connectez, pour un usage occasionel et rapide.",
                              child: Icon(Icons.info_outline),
                            )
                        )
                      ],
                    ),
                  ),
                  const Padding(
                    padding: EdgeInsets.all(15),
                    child: Text(
                      "Vidar est un outil de messagerie instanée multiplateforme conçue pour aider au quotidien les personnes ayant des difficultés à s'exprimer oralement.\nLes échanges sont sécurisés, confidentiels, et garantissent votre anonymat. Aucune donnée personelle ne sera utlisée.\nPour toute réclamation, contactez IPIC-ASSO.",
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 18),
                    ),
                  )
                ],
              )
          ],
        ),
      ),
    );
  }

  temporise() async {
    try {
      final credit = await auth.signInAnonymously();
      final int nb = await laPoste(firebaseFirestore: FirebaseFirestore.instance).creeUti(credit.user!.uid,"Utilisateur ${DateTime.now().millisecond}",);
      if(Uri.base.queryParameters["dest"]!=null && credit.user!=null){
        await traiteCode(Uri.base.queryParameters["dest"]!,credit.user!.uid,FirebaseFirestore.instance,context);
        html.window.history.pushState(null, 'iren', '#/iren');
      }else{
        Future.delayed(Duration.zero).then((value) => Navigator.of(context).push(PageRouteBuilder(
          pageBuilder: (_, __, ___) => MontreQrCode(idUt:credit.user!.uid,messageAffiche:"",messageDebut:"",messageLu:"",tempo: true,nb:nb),
          transitionDuration: const Duration(milliseconds: 500),
          transitionsBuilder: (_, a, __, c) => FadeTransition(opacity: a, child: c),
        )));
      }
    } on FirebaseException catch(e){
      switch (e.code){
        case 'not-found':
          Usine.montreBiscotte(context, "Code invalide", this);
          break;
        default:
          Usine.montreBiscotte(context, "La base de donnée refuse la transaction", this);
      }
    }
    catch (e) {
      log(e.toString());
      Usine.montreBiscotte(context, "Une erreur est survenue", this);
    }

  }

}