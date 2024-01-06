import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
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
  FirebaseFirestore db = FirebaseFirestore.instance;
  bool charge = false;
  TextEditingController txt_section = TextEditingController();

  @override
  void initState() {
    super.initState();
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
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10,vertical: 5),
            child:ElevatedButton.icon(
            onPressed: (){
              showDialog(context: context, builder: (context)=> AlertDialog(
                title: const Text("Nouveau groupe de messages"),
                content: TextField(
                  textInputAction:TextInputAction.done,
                  keyboardType: TextInputType.text,
                  textCapitalization: TextCapitalization.sentences,
                  controller: txt_section,
                  decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      hintText: 'Nom de la section'
                  ),
                  onSubmitted: (value) {
                    nouvelleSection();
                  },
                ),
                actions: [
                  MaterialButton(onPressed: ()=>{nouvelleSection()},child: const Text("Valider"),),
                  TextButton(onPressed: ()=>{Navigator.of(context).pop()},child: const Text("Annuler"),)
                ],
              ));
            },
            icon: const Icon(Icons.create_new_folder_outlined),
            label: const Text("Nouvelle section", style:TextStyle(fontWeight: FontWeight.bold, fontSize: 17),),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppCouleur().eco,
              foregroundColor : AppCouleur.white,
              minimumSize:Size(MediaQuery.of(context).size.width/(MediaQuery.of(context).size.aspectRatio>1?2:1),50),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(5.0)
              ),
            ),
          ),)
        ];
        if (snapshot.hasData && snapshot.data?.data() != null && (snapshot.data?.data() as Utilisateur).messages != null && (snapshot.data?.data() as Utilisateur).messages!.isNotEmpty) {
          final Map<String, dynamic>? monUti = (snapshot.data!.data() as Utilisateur).messages;
          for (MapEntry<String, dynamic> messageEntree in monUti?.entries ?? {}) {
            enfants.add(creeGroupe(messageEntree.key,messageEntree.value));
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
        future: monPostier.prendMessagesParDefaut(),
        builder: (BuildContext context, AsyncSnapshot<QuerySnapshot<Map<String, dynamic>>> snapshot) {
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
          if (snapshot.hasData && snapshot.data!.docs.isNotEmpty) {
            snapshot.data?.docs.forEach((element) {
              enfants.add(creeGroupe(element.id,element.data(),true));
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

  Widget creeMessage(String section, String titre, String corps, [bool defaut = false]) {
    return Padding(
      padding: const EdgeInsets.all(10),
      child: GestureDetector(
        onTap: (){
          Navigator.push(context,
            PageRouteBuilder(
              pageBuilder: (_, __, ___) => EditeurMessages(titre: titre,section: section, corps: corps,idUt: widget.idUti,defaut: defaut,),
              transitionDuration: const Duration(milliseconds: 500),
              transitionsBuilder: (_, a, __, c) => FadeTransition(opacity: a, child: c),
            ),
          );
        },
          child:Container(
            decoration: BoxDecoration(
              borderRadius: const BorderRadius.all(Radius.circular(5)),
              color: AppCouleur().grisTresClair,
            ),
          padding: const EdgeInsets.all(15),
          child: Row(children: [
            Expanded(flex:1,child: Text(titre,style: TextStyle(color: defaut?AppCouleur().indyBlue:AppCouleur.spaceCadet),)),
            Expanded(flex:0,child: Padding(padding: const EdgeInsets.all(5),child:
              MediaQuery.of(context).size.width>800?
              ElevatedButton.icon(onPressed: ()=>{OutilsOutils.afficheTTS(context,corps)}, icon: const Icon(Icons.volume_up_rounded), label: const Text("Lire le message")):
              IconButton(onPressed: ()=>{OutilsOutils.afficheTTS(context,corps)}, icon: const Icon(Icons.volume_up_rounded), tooltip: "Lire le message")
            ))
          ],),
        )
      )
    ,) ;
  }

  Widget creeGroupe(String titre, Map<String,dynamic> messages,  [bool defaut = false]) {
      List<Widget> mesEnfants = [];
      (messages as Map<String,dynamic>).forEach((key, value) {
        mesEnfants.add(creeMessage(titre, key,value.toString(),defaut ));
      });
      if (mesEnfants.isEmpty)mesEnfants.add(
        const Padding(
          padding: EdgeInsets.all(15),
          child: Text("Cette section est vide, créez un message avec l'icon vert",style: TextStyle(fontStyle:FontStyle.italic),textAlign: TextAlign.center,),
        )
      );
      return Card(
        child:Theme(
          data: ThemeData().copyWith(dividerColor: Colors.transparent),
          child:ExpansionTile(
          leading: defaut?null:IconButton(
            color: AppCouleur.banni,
            icon: const Icon(Icons.delete),
            onPressed: ()=>{
            monPostier.enleveSection(widget.idUti,titre)
            },
          ),
          trailing: defaut?null:IconButton(
            color: AppCouleur().eco,
            icon: const Icon(Icons.add),
            onPressed: ()=>{
              Navigator.of(context).push(PageRouteBuilder(
                pageBuilder: (_, __, ___) => EditeurMessages(section:titre,titre: "",corps: "",idUt: widget.idUti,defaut: defaut,),
                transitionDuration: const Duration(milliseconds: 500),
                transitionsBuilder: (_, a, __, c) => FadeTransition(opacity: a, child: c),
              ))
            },
          ),
          title: Text(titre),
          children: mesEnfants,
        ))
      );
  }

  void nouvelleSection() {
    monPostier.creeSection(widget.idUti,txt_section.text);
    Navigator.pop(context);
  }
}