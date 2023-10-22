import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:vidar/AppCouleur.dart';
import 'package:vidar/editeurMessages.dart';
import 'package:vidar/patrons/OutilsUtiles.dart';

import 'Postier.dart';
import 'patrons/Utilisateur.dart';


class ListeMessages extends StatefulWidget {

  final String idUti;

  const ListeMessages({super.key, required this.idUti});

  @override
  State<ListeMessages> createState() => _ListeMessagesState();
}

class _ListeMessagesState extends State<ListeMessages> with TickerProviderStateMixin {

  late laPoste monPostier;
  late FlutterTts monTTS;
  FirebaseFirestore db = FirebaseFirestore.instance;
  bool charge = false;

  @override
  void initState() {
    super.initState();
    OutilsOutils.ConfigureTTS().then((value) => monTTS=value);
    monPostier = laPoste(firebaseFirestore: db);
  }

  @override
  Widget build(BuildContext context) {
   return Scaffold(
     appBar: AppBar(
       automaticallyImplyLeading: false,
       title: Container(
           width: double.infinity,
           decoration: const BoxDecoration(
             border:  Border(
               bottom: BorderSide(width: 8.0, color: AppCouleur.tete),
             ),
           ),
           padding: const EdgeInsets.fromLTRB(15,25,15,10),
           child: const Text(" Messages enregistrés ", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18), textAlign: TextAlign.center,)
       ),
     ),
     body:MediaQuery.of(context).size.width>MediaQuery.of(context).size.height?Row(
       crossAxisAlignment: CrossAxisAlignment.start,
       children: [
         Expanded(flex:1,child: Padding(padding: const EdgeInsets.all(10),child: MessagesPerso(),),),
         Expanded(flex:1,child: Padding(padding: const EdgeInsets.all(10),child: MessagesDeBase(),)),
       ],
     ):Column(
       children: [
         Expanded(flex:1,child: Padding(padding: const EdgeInsets.all(10),child: MessagesPerso(),),),
         Expanded(flex:1,child: Padding(padding: const EdgeInsets.all(10),child: MessagesDeBase(),)),
       ],
     ),
     floatingActionButton: FloatingActionButton.extended(
       onPressed: ()=>{
         Navigator.of(context).push(PageRouteBuilder(
           pageBuilder: (_, __, ___) => EditeurMessages(titre: "",corps: "",idUt: widget.idUti,),
           transitionDuration: const Duration(milliseconds: 500),
           transitionsBuilder: (_, a, __, c) => FadeTransition(opacity: a, child: c),
         ))
       },
       label: const Text('Nouveau message'),
       icon:  const Icon(Icons.add),
     ),
   );
  }

  Widget MessagesPerso() {
  return StreamBuilder(
      stream: monPostier.prendPersonnel(widget.idUti), // a previously-obtained Future<String> or null
      builder: (BuildContext context, AsyncSnapshot<DocumentSnapshot<Utilisateur>> snapshot) {
        List<Widget> enfants = [
          const Row(
            crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Expanded(
                    child: Divider()
                ),
                Text(" Messages Pré-Enregistrés "),
                Expanded(
                    child: Divider()
                ),
              ]),
        ];
        if (snapshot.hasData && snapshot.data?.data() != null && (snapshot.data?.data() as Utilisateur).messages != null && (snapshot.data?.data() as Utilisateur).messages!.isNotEmpty) {
          final Map<String, String>? monUti = (snapshot.data!.data() as Utilisateur).messages;
          for (MapEntry<String, String> messageEntree in monUti?.entries ?? {}) {
            enfants.add(creeMessage(messageEntree.key,messageEntree.value));
          }
        }else{
          enfants.add(const Center(
            child:Padding(padding:EdgeInsets.all(15),child:Text(textAlign: TextAlign.center,"Aucun message créé"))
          ));
        }
        return ListView(
          shrinkWrap: true,
          children: enfants,
        );
      }
    );
}

  MessagesDeBase() {
    return FutureBuilder(
        future: monPostier.prendMessagesParDefaut(), // a previously-obtained Future<String> or null
        builder: (BuildContext context, AsyncSnapshot<DocumentSnapshot<Map<String, dynamic>>> snapshot) {
          List<Widget> enfants = [
            const Row(
                children: <Widget>[
                  Expanded(
                      child: Divider()
                  ),
                  Text(" Messages par défaut "),
                  Expanded(
                      child: Divider()
                  ),
                ]),
          ];
          if (snapshot.hasData && (snapshot.data!.data()!= null && snapshot.data!.data()!.isNotEmpty)) {
            final x = snapshot.data!.data() as Map<String,dynamic>;
            x.forEach((key, value) {
              enfants.add(creeMessage(key,value,true ));
            });
          }else{
            enfants.add(const Center(
                child:Text(textAlign: TextAlign.center,"Impossible de charger les messages par défaut.")
            ));
          }
          return ListView(
            shrinkWrap: true,
            children: enfants,
          );
        }
    );
  }

  Widget creeMessage(String titre, String corps, [bool defaut = false]) {
    return Padding(
      padding: const EdgeInsets.all(10),
      child: GestureDetector(
        onTap: (){
          Navigator.push(context,
            PageRouteBuilder(
              pageBuilder: (_, __, ___) => EditeurMessages(titre: titre, corps: corps,idUt: widget.idUti,defaut: defaut,),
              transitionDuration: const Duration(milliseconds: 500),
              transitionsBuilder: (_, a, __, c) => FadeTransition(opacity: a, child: c),
            ),
          );
        },
          child:Container(
            color: AppCouleur().grisTresClair,
          padding: const EdgeInsets.all(15),
          child: Row(children: [
            Expanded(flex:1,child: Text(titre,style: TextStyle(color: defaut?AppCouleur().indyBlue:AppCouleur.spaceCadet),)),
            Expanded(flex:0,child: Padding(padding: const EdgeInsets.all(5),child:
              MediaQuery.of(context).size.width>800?
              ElevatedButton.icon(onPressed: ()=>{monTTS.speak(corps)}, icon: const Icon(Icons.volume_up_rounded), label: const Text("Lire le message")):
              IconButton(onPressed: ()=>{monTTS.speak(corps)}, icon: const Icon(Icons.volume_up_rounded), tooltip: "Lire le message")
            ))
          ],),
        )
      )
    ,) ;
  }
}