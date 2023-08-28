import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:vidar/AppCouleur.dart';
import 'package:vidar/Postier.dart';
import 'package:vidar/interfaceDiscussion.dart';
import 'package:vidar/nouvelleConversation.dart';
import 'package:vidar/patrons/convDeListe.dart';
import 'package:vidar/usineDeBiscottesGrillees.dart';

class Conversations extends StatefulWidget {

  const Conversations({super.key});

  @override
  State<Conversations> createState() => _ConversationsState();
}

class _ConversationsState extends State<Conversations> with TickerProviderStateMixin{

  final user = FirebaseAuth.instance.currentUser;
  late laPoste monPostier;

  @override
  void initState() {
    super.initState();
    monPostier = laPoste(firebaseFirestore: FirebaseFirestore.instance);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: double.infinity,
            decoration: BoxDecoration(
                border:  Border(
                  bottom: BorderSide(width: 3.0, color: AppCouleur.tete),
                ),
            ),
            padding: EdgeInsets.fromLTRB(15,25,15,10),
            child: Text("Liste des conversations en cours", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18), textAlign: TextAlign.center,)
          ),
          StreamBuilder(
              stream: monPostier.prendConv(user?.uid??""),
              builder: (BuildContext context, AsyncSnapshot<QuerySnapshot<Discussion>> snapshot) {
                if(snapshot.hasData && snapshot.data!.docs.length>0){
                  List<Widget> enfants = [];
                  snapshot.data!.docs.forEach((element) async {
                    final dis = element.data() as Discussion;
                    if((dis.supr==null || dis.supr!=user!.uid) && (dis.utilisateur1==user!.uid ||dis.utilisateur2==user!.uid)){
                      print(dis.utilisateur1);
                      enfants.add(construitConv(dis));
                    }
                  });
                  if (enfants.isEmpty)
                    return Padding(
                      padding: EdgeInsets.all(15),
                      child: Text("Aucune conversation enregistrée\nCommencez en une avec le petit bouton bleu clair", textAlign: TextAlign.center,),
                    );
                  return ListView(
                    shrinkWrap: true,
                    children: enfants);
                }else if(snapshot.hasError){
                  return const Center(
                    child: Column(
                      children: [
                        Icon(Icons.error),
                        Text("Une erreur est survenue", textAlign: TextAlign.center,)
                      ],
                    )
                  );
                }else{
                  return Padding(
                    padding: EdgeInsets.all(15),
                    child: Text("Aucune conversation enregistrée\nCommencez en une avec le petit bouton bleu clair", textAlign: TextAlign.center,),
                  );
                }
              }
          )
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: ()=>{
          Navigator.of(context).push(PageRouteBuilder(
            pageBuilder: (_, __, ___) => NouvConv(idUti: user?.uid??"erreur",),//TODO
            transitionDuration: const Duration(milliseconds: 500),
            transitionsBuilder: (_, a, __, c) => FadeTransition(opacity: a, child: c),
          ))
        },
        label: const Text('Nouvelle Conversation'),
        icon:  Icon(Icons.add),
      ),
    );
  }



  Widget construitConv(Discussion dis) {
    return Padding(
      padding: EdgeInsets.all(10),
        child:FutureBuilder(
          future: monPostier.prendPseudo(dis.utilisateur1==user!.uid?dis.utilisateur2:dis.utilisateur1),
           builder: (BuildContext context, AsyncSnapshot<String> snapshot) {
            if(snapshot.hasData){
              dis.pseudo = snapshot.data??"Inconnu au bataillon";
              return GestureDetector(
                  onTap: (){
                    Navigator.push(context,
                      PageRouteBuilder(
                        pageBuilder: (_, __, ___) => InterfaceDiscussion(idUti: user!.uid, idConv: dis.utilisateur1+dis.utilisateur2, pseudoDest: dis.pseudo, supr: dis.supr!=null,),
                        transitionDuration: const Duration(milliseconds: 500),
                        transitionsBuilder: (_, a, __, c) => FadeTransition(opacity: a, child: c),
                      ),
                    );
                  },
                  child:Container(
                    decoration: BoxDecoration(
                      color: dis.supr!=null?AppCouleur.tete:AppCouleur.grisTresClair,
                      borderRadius: BorderRadius.all(Radius.circular(15)),
                      boxShadow: [
                        BoxShadow(
                          offset: const Offset(3.0, 3.0,),
                          blurRadius: 3.0,
                        ), //BoxShadow
                        BoxShadow(
                          color: Colors.white,
                          offset: const Offset(0.0, 0.0),
                          blurRadius: 0.0,
                          spreadRadius: 0.0,
                        ), //BoxShadow
                      ],
                    ),
                    padding: EdgeInsets.all(5),
                    child: Row(
                      children: [
                        Expanded(
                            flex: 0,
                            child: Padding(
                              padding: EdgeInsets.all(3),
                              child: Icon(Icons.account_circle_rounded),
                            )
                        ),
                        Expanded(
                            flex: 1,
                            child: Padding(
                                padding: EdgeInsets.all(3),
                                child: Text(textAlign: TextAlign.center, dis.pseudo, style: TextStyle(fontSize: 16),)
                            )
                        ),
                        Expanded(
                            flex: 0,
                            child: Padding(
                                padding: EdgeInsets.all(3),
                                child: IconButton(
                                  color: dis.supr!=null?AppCouleur.spaceCadet:AppCouleur.banni,
                                  onPressed: () => {
                                    confSupr(dis)
                                  },
                                  icon: Icon(Icons.delete_forever),
                                  tooltip: "Supprimer la conversation")
                            )
                        ),
                      ],
                    ),
                  ));
            }else{
              return LinearProgressIndicator();
            }
           }
        ));
  }

  confSupr(Discussion dis) {
    showDialog(
        context: context,
        builder: (context)=>AlertDialog(
          title: Text("Supprimer la conversation"),
          content: Text("Voulez vous supprimez cette conversation?\nCette action est irréversible."),
          actions: [
            TextButton(onPressed: (){
              Navigator.of(context).pop();
              laPoste(firebaseFirestore: FirebaseFirestore.instance).suprConv(dis.utilisateur1+dis.utilisateur2,user?.uid??"erreur",dis.supr).then((value){
                if(value=="0")Usine.montreBiscotte(context, "Supprimé !", this, true);
                else{
                  log(value);
                  Usine.montreBiscotte(context, "Une erreur est survenue: $value", this);
                }
              });
            }, child: const Text("Valider", style: TextStyle(fontWeight: FontWeight.bold),),),
            MaterialButton(onPressed: ()=>{Navigator.of(context).pop()}, child: const Text("Annuler"),)
          ],
        ));
  }
}
