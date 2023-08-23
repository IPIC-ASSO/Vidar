import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:vidar/AppCouleur.dart';
import 'package:vidar/Postier.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:vidar/patrons/MesConstantes.dart';
import 'package:vidar/patrons/OutilsUtiles.dart';
import 'package:vidar/patrons/convDeListe.dart';
import 'package:vidar/usineDeBiscottesGrillees.dart';

class InterfaceDiscussion extends StatefulWidget {

  final String idUti;
  final String idConv;
  final String pseudoDest;

  const InterfaceDiscussion({super.key, required this.idUti, required this.idConv, required this.pseudoDest});

  @override
  State<InterfaceDiscussion> createState() => _InterfaceDiscussionState();
}

class _InterfaceDiscussionState extends State<InterfaceDiscussion> with SingleTickerProviderStateMixin {

  final user = FirebaseAuth.instance.currentUser;
  FirebaseFirestore db = FirebaseFirestore.instance;
  late laPoste monPostier;

  List<Map<String,String>> listeMessages = [];
  final TextEditingController redaction = TextEditingController();
  final ScrollController controleSkrol = ScrollController();
  int _limite = 20;
  final int _ajoutLimite = 20;
  bool modif = false;
  int indiceMessageModif=0;

  @override
  void initState() {
    super.initState();
    monPostier = laPoste(firebaseFirestore: db);
    initializeDateFormatting('fr_FR');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.pseudoDest),
        actions: [
          IconButton(onPressed: ()=>{confSupr()}, icon: Icon(Icons.delete_forever))
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 6),
          child: Column(
            children: [
              ConstruitListeMessage(),
              ConstruitRedacteur(),
            ],
          ),
        ),
      ),
    );
  }

  Widget ConstruitListeMessage() {
    return Flexible(
        child: StreamBuilder<DocumentSnapshot>(
            stream: monPostier.prendLesChatsDuQuartier(widget.idConv),
            builder: (BuildContext context,
                AsyncSnapshot<DocumentSnapshot> snapshot) {
              if (snapshot.hasData) {
                final listeIntermediaire = (snapshot.data)! as Map<String, Map<String,String>>;
                listeMessages = ((Map.fromEntries(listeIntermediaire.entries.toList()..sort((e1, e2) => e1.key.compareTo(e2.key))).map((key, value) { value["temps"] = key;return(MapEntry(key,value));}).values.toList())).sublist(0,_limite);
                if (listeMessages.isNotEmpty) {
                  return GestureDetector(
                      onDoubleTap: ()=>annuleModif(),
                      child:ListView.builder(
                          itemCount: listeMessages.length,
                          reverse: true,
                          controller: controleSkrol,
                          itemBuilder: (context, index) =>
                              construitChat(index, listeMessages[index])));
                } else {
                  return const Center(
                    child: Text('Pas de messages...'),
                  );
                }
              } else {
                return const Center(
                  child: CircularProgressIndicator(
                    color: AppCouleur.charge,
                  ),
                );
              }
            }
        ));
  }


  Widget ConstruitRedacteur() {
    return SizedBox(
        width: double.infinity,
        height: 90,
        child: Padding(
          padding: const EdgeInsets.all(0),
          child: Row(
            children: [
              Container(
                height: 52,
                width: 52,
                decoration: BoxDecoration(
                  color: modif?AppCouleur.banni:AppCouleur.principal,
                  borderRadius: BorderRadius.circular(30),
                ),
                child: modif?
                IconButton(onPressed: ()=>suprMessage(indiceMessageModif),
                    icon: const Icon(Icons.delete_forever, size: 28,)):
                IconButton(
                  onPressed:()=>{
                    prendMessageEnr()},
                  icon: const Icon(
                    Icons.text_snippet_outlined,
                    size: 28,
                  ),
                ),
              ),
              Flexible(
                  child:Padding(
                      padding: const EdgeInsets.all(4),
                      child: TextField(
                        textInputAction:TextInputAction.newline,
                        keyboardType: TextInputType.multiline,
                        textCapitalization: TextCapitalization.sentences,
                        controller: redaction,
                        maxLines: null,
                        decoration: const InputDecoration(
                            border: OutlineInputBorder(),
                            hintText: 'Votre message'
                        ),
                        onSubmitted: (value) {
                          //versLaPoste(redaction.text, MessageType.texte);
                        },
                      ))),
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(30),
                    color: AppCouleur.principal
                ),
                child: modif?
                IconButton(
                    onPressed: ()=>verslaPosteModif(redaction.text,indiceMessageModif),
                    icon: const Icon(Icons.save_as)):
                IconButton(
                  onPressed: () {
                    versLaPoste(redaction.text,);
                  },
                  icon: const Icon(Icons.send_rounded),

                ),
              ),
            ],
          ),
        )
    );
  }

  Widget construitChat (int index, Map<String,String> doc)  {
      Message chaton = Message.fromDocument(doc);
      if(index >_limite){
        return const SizedBox.shrink();
      }
      if (index == _limite && _limite<listeMessages.length){
        return Visibility(
            visible: _limite<listeMessages.length,
            child: Container(
                constraints: const BoxConstraints(minWidth: 100, maxWidth: 250),
                width: 20,
                padding: const EdgeInsets.all(4),
                child: ElevatedButton(
                  onPressed:(){setState(() {
                    _limite+= _ajoutLimite;
                  });},
                  child: const Text("Charger plus de messages"),
                )
            )
        );
      } else if (chaton.envoyeur == widget.idUti) {  //c'est moi qui envoie--> droite
        return Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                GestureDetector(
                onLongPress: ()=>modifMessage(index),
                onDoubleTap: ()=>modifMessage(index),
                child:messagePoissonRouge(
                    corps: chaton.corps,
                    color: AppCouleur.droitier,//(modif && indiceMessageModif==index)?AppCouleur.modification:AppCouleur.droitier,
                    textColor: AppCouleur.white,
                    margin: const EdgeInsets.fromLTRB(0,1,3,1),
                    bords:BorderRadius.only(
                      bottomLeft:  unMessagePoste(index)?const Radius.circular(10.0):const Radius.circular(0),
                      topLeft: unAncienMessagePoste(index)?const Radius.circular(10.0):const Radius.circular(0),
                      topRight:unAncienMessagePoste(index)? const Radius.circular(10.0):const Radius.circular(0),)))
              ],
            ),
            unMessagePoste(index)
                ? Container(
              margin: const EdgeInsets.only(
                  right: 50,
                  top: 6,
                  bottom: 8),
              child: Text(
                DateFormat('dd MMM yyyy, HH:mm', 'fr_FR').format(
                  DateTime.fromMillisecondsSinceEpoch(
                    int.parse(chaton.temps),
                  ),
                ),
                style: const TextStyle(
                    color: AppCouleur.grisClair,
                    fontSize: 12,
                    fontStyle: FontStyle.italic),
              ),
            )
                : const SizedBox.shrink(),
          ],
        );
      } else {//c'est les autres
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            messagePoissonRouge(
              color: AppCouleur.gaucher,
              textColor: AppCouleur.white,
              corps: chaton.corps,
              bords:BorderRadius.only(
                bottomLeft:  unMessageRecu(index)?const Radius.circular(10.0):const Radius.circular(0),
                bottomRight: unMessageRecu(index)?const Radius.circular(10.0):const Radius.circular(0),
                topRight:unAncienMessageRecu(index)?const Radius.circular(10.0):const Radius.circular(0),),
              margin: const EdgeInsets.fromLTRB(3,1,0,1),
            ),
            unMessageRecu(index) ? Container(
              margin: const EdgeInsets.only(left: 50, top: 6, bottom: 8),
              child: Text(
                DateFormat('dd MMM yyyy, HH:mm', 'fr_FR').format(
                  DateTime.fromMillisecondsSinceEpoch(
                    int.parse(chaton.temps),
                  ),
                ),
                style: const TextStyle(
                    color: AppCouleur.grisClair,
                    fontSize: 12,
                    fontStyle: FontStyle.italic),
              ),
            )
                : const SizedBox.shrink(),
          ],
        );
      }
  }

  bool unMessagePoste(int index) {
    if ((index > 0 && listeMessages[index - 1][MesConstantes.envoyeur] != widget.idUti) ||  index == 0) {
      return true;
    } else {
      return false;
    }
  }
  // message posté!
  bool unAncienMessagePoste(int index) {
    if ((index < listeMessages.length-1 && listeMessages[index + 1][MesConstantes.envoyeur] !=
        widget.idUti) ||  index == listeMessages.length-1) {
      return true;
    } else {
      return false;
    }
  }

  bool unAncienMessageRecu(int index) {
    if ((index < listeMessages.length-1 && listeMessages[index + 1][MesConstantes.envoyeur] !=
        listeMessages[index][MesConstantes.envoyeur]) ||  index == listeMessages.length-1) {
      return true;
    } else {
      return false;
    }
  }

  //facteur qui passe
  bool unMessageRecu(int index) {
    if ((index > 0 && listeMessages[index - 1][MesConstantes.envoyeur] !=
        listeMessages[index][MesConstantes.envoyeur]) ||  index == 0) {
      return true;
    } else {
      return false;
    }
  }

  modifMessage(int index){
    setState(() {
      modif = true;
    });
    indiceMessageModif = index;
    redaction.text = Message.fromDocument(listeMessages[index]).corps;
  }

  suprMessage(int index) async {
    setState(() {
      modif = false;
    });
    redaction.clear();
    final resultat = await monPostier.supprime(listeMessages[index][MesConstantes.temps]??"1676633613878", widget.idConv);
    if(resultat==0) {
      Usine.montreBiscotte(context, "Supprimé!", this,true);
    } else {
      Usine.montreBiscotte(context, "Une erreur est survenue!", this,true);
    }
  }

  verslaPosteModif(String corps, int index) async {
    setState(() {
      modif = false;
    });
    redaction.clear();
    listeMessages[index][MesConstantes.message] = redaction.text;
    final resultat = await monPostier.modifie( widget.idConv, listeMessages[index]);
    if(resultat==0) {
      Usine.montreBiscotte(context, "Modifié!", this,true);
    } else {
      Usine.montreBiscotte(context, "Une erreur est survenue!", this,true);
    }
  }

  annuleModif(){
    if(modif){
      setState(() {
        modif = false;
      });
      redaction.clear();
    }
  }

  void versLaPoste(String corps) async {
    if (corps.trim().isNotEmpty) {
      redaction.clear();
      int resultat = await monPostier.envoie(
          corps, widget.idConv, widget.idUti);
      if (resultat == 1) Usine.montreBiscotte(context, "Une erreur est survenue!", this, true);
      controleSkrol.animateTo(0,
          duration: const Duration(milliseconds: 300), curve: Curves.easeOut);
    } else {
      Usine.montreBiscotte(context, "Oups, votre message est vide!", this);
    }
  }
  
  //TODO:
  prendMessageEnr() {}

  confSupr() {
    showDialog(
        context: context,
        builder: (context)=>AlertDialog(
          title: Text("Supprimer la conversation"),
          content: Text("Voulez vous supprimez cette conversation?\nCette action est irréversible."),
          actions: [
            TextButton(onPressed: () async {
              Navigator.of(context).pop();
              Discussion dis= await monPostier.prendLAconv(widget.idConv);
              monPostier.suprConv(dis.utilisateur1+dis.pseudo,user?.uid??"erreur",dis.supr).then((value){
                if(value=="0")Usine.montreBiscotte(context, "Supprimé !", this, true);
                else{
                  Usine.montreBiscotte(context, "Une erreur est survenue: $value", this);
                }
              });
            }, child: const Text("Valider", style: TextStyle(fontWeight: FontWeight.bold),),),
            MaterialButton(onPressed: ()=>{Navigator.of(context).pop()}, child: const Text("Annuler"),)
          ],
        ));
  }
}