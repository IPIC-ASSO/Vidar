import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:vidar/AppCouleur.dart';
import 'package:vidar/Connexion.dart';
import 'package:vidar/Postier.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:vidar/main.dart';
import 'package:vidar/patrons/MesConstantes.dart';
import 'package:vidar/patrons/OutilsUtiles.dart';
import 'package:vidar/patrons/convDeListe.dart';
import 'package:vidar/usineDeBiscottesGrillees.dart';

class InterfaceDiscussion extends StatefulWidget {

  final String idUti;
  final String idConv;
  final String pseudoDest;
  final String message;
  final bool supr;
  final bool tempo;

  const InterfaceDiscussion({super.key, required this.idUti, required this.idConv, required this.pseudoDest, this.message="", this.supr=false, this.tempo= false});

  @override
  State<InterfaceDiscussion> createState() => _InterfaceDiscussionState();
}

class _InterfaceDiscussionState extends State<InterfaceDiscussion> with TickerProviderStateMixin {

  final user = FirebaseAuth.instance.currentUser;
  FirebaseFirestore db = FirebaseFirestore.instance;
  late laPoste monPostier;
  late FlutterTts monTTS = FlutterTts();
  List<Map<String,String>> listeMessages = [];
  final TextEditingController redaction = TextEditingController();
  final TextEditingController titre = TextEditingController();
  final ScrollController controleSkrol = ScrollController();
  int _limite = 20;
  final int _ajoutLimite = 20;
  bool modif = false;
  bool marque = false;
  int indiceMessageModif=0;
  int indiceMessageTouche = 0;
  Map<String,String> listeMessagesEnr = {};
  final _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    setState(() {
      OutilsOutils.ConfigureTTS().then((value) => monTTS=value);
    });
    monPostier = laPoste(firebaseFirestore: db);
    initializeDateFormatting('fr_FR');
    if(widget.message.isNotEmpty)versLaPoste(widget.message);
    prendMessages();
    FirebaseAuth.instance.authStateChanges().listen((User? user) {
      if (user == null) {
        Navigator.of(context).push(PageRouteBuilder(
          pageBuilder: (_, __, ___) => const MyHomePage(),
          transitionDuration: const Duration(milliseconds: 500),
          transitionsBuilder: (_, a, __, c) => FadeTransition(opacity: a, child: c),
        ));
      }
    });
    denotifie();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        monPostier.renotifie(widget.idUti);
        return true;
      },
      child:Scaffold(

        appBar: AppBar(
          title: Text(modif?"Modification":widget.pseudoDest),
          backgroundColor: modif?AppCouleur.principal:null,
          automaticallyImplyLeading: false,
          elevation: 5,
          actions: [
            Visibility(visible: !widget.tempo, child: IconButton(onPressed: ()=>{confSupr()}, icon: const Icon(Icons.delete_forever))),
            Visibility(visible: widget.tempo, child: IconButton(
              tooltip: "Se connecter/S'inscrire",
              onPressed: ()=>{
              Navigator.of(context).push(PageRouteBuilder(
                pageBuilder: (_, __, ___) =>  Connexion(tempo: widget.idUti,),
                transitionDuration: const Duration(milliseconds: 500),
                transitionsBuilder: (_, a, __, c) => FadeTransition(opacity: a, child: c),
            ))}, icon: const Icon(Icons.login))),

          ],
          leading: Visibility(
            visible: !widget.tempo,
            child:IconButton(onPressed: ()=>{
              Navigator.of(context).push(PageRouteBuilder(
                pageBuilder: (_, __, ___) => const MyHomePage(),
                transitionDuration: const Duration(milliseconds: 500),
                transitionsBuilder: (_, a, __, c) => FadeTransition(opacity: a, child: c),
              ))
          }, icon: const Icon(Icons.home))),
        ),
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 6),
            child: Column(
              children: [
                ConstruitListeMessage(),
                widget.supr?
                const Padding(padding: EdgeInsets.all(15),child:Text("Conversation supprimée par votre interlocuteur", style: TextStyle(fontSize:16,fontStyle: FontStyle.italic,color: AppCouleur.banni),),):
                ConstruitRedacteur(),
              ],
            ),
          ),
        ),
      )
    );
  }

  Widget ConstruitListeMessage() {
    return Flexible(
        child: StreamBuilder<DocumentSnapshot>(
            stream: monPostier.prendLesChatsDuQuartier(widget.idConv),
            builder: (BuildContext context, AsyncSnapshot<DocumentSnapshot> snapshot) {
              if (snapshot.hasData && (snapshot.data)!.data()!= null) {
                final listeIntermediaire = (snapshot.data)!.data() as Map<String, dynamic>;
                final DocumentSnapshot listeInt1 = (snapshot.data)!;
                final Map<String,Map<String,String>> listeInt2= {};
                listeIntermediaire.forEach((key, value) {
                  listeInt2[key] = {
                    MesConstantes.envoyeur:listeInt1[key][MesConstantes.envoyeur],
                    MesConstantes.message:listeInt1[key][MesConstantes.message]
                  };
                });
                listeMessages = (
                    Map.fromEntries(listeInt2.entries.toList()
                      ..sort((e1, e2) => e2.key.compareTo(e1.key)))
                        .map((key, value) {value["temps"] = key;return(MapEntry(key,value));})
                        .values.toList())
                    .sublist(0,min(_limite,listeInt2.keys.length));
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
                    child: Text('Aucun message n\'a encore été envoyé'),
                  );
                }
              }else if(snapshot.hasData){
                return const Center(
                  child: Text('Pas de messages...'),
                );
              }else{
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
                    icon: const Icon(Icons.delete_forever, size: 28,color: Colors.black,)):
                IconButton(
                  onPressed:()=>{montreMessagesEnr()},
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
                          versLaPoste(redaction.text);
                        },
                      ))),
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(30),
                    color: modif?AppCouleur.eco:AppCouleur.principal
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
                onDoubleTap: ()=>modifMessage(index),
                child:messagePoissonRouge(
                    corps: chaton.corps,
                    color: (modif && indiceMessageModif==index)?AppCouleur.modification:AppCouleur.droitier,
                    textColor: AppCouleur.white,
                    expansion: (modif && indiceMessageModif==index),
                    monTTS: monTTS,
                    enreMesss: montreEnregistreMessage,
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
            GestureDetector(
            onDoubleTap: ()=>marqueMessage(index),
            child:messagePoissonRouge(
              color: AppCouleur.gaucher,
              textColor: AppCouleur.white,
              corps: chaton.corps,
              expansion: (marque && indiceMessageTouche==index),
              monTTS: monTTS,
              enreMesss: montreEnregistreMessage,
              bords:BorderRadius.only(
                bottomLeft:  unMessageRecu(index)?const Radius.circular(10.0):const Radius.circular(0),
                bottomRight: unMessageRecu(index)?const Radius.circular(10.0):const Radius.circular(0),
                topRight:unAncienMessageRecu(index)?const Radius.circular(10.0):const Radius.circular(0),),
              margin: const EdgeInsets.fromLTRB(3,1,0,1),
            ),),
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
      marque = false;
      indiceMessageModif = index;
    });
    redaction.text = Message.fromDocument(listeMessages[index]).corps;
  }

  marqueMessage(int index){
    setState(() {
      marque = true;
      modif = false;
      indiceMessageTouche = index;
    });
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
      Usine.montreBiscotte(context, "Une erreur est survenue!", this);
    }
  }

  verslaPosteModif(String corps, int index) async {
    setState(() {
      modif = false;
    });
    listeMessages[index][MesConstantes.message] = redaction.text;
    redaction.clear();

    final resultat = await monPostier.modifie( widget.idConv, listeMessages[index]);
    if(resultat==0) {
      Usine.montreBiscotte(context, "Modifié!", this,true);
    } else {
      Usine.montreBiscotte(context, "Une erreur est survenue!", this);
    }
  }

  annuleModif(){
    if(modif){
      setState(() {
        modif = false;
        marque = false;
      });
      redaction.clear();
    }
  }

  void versLaPoste(String corps) async {
    if (corps.trim().isNotEmpty) {
      redaction.clear();
      int resultat = await monPostier.envoie(corps, widget.idConv, widget.idUti);
      if (resultat == 1) Usine.montreBiscotte(context, "Une erreur est survenue!", this);
      if(listeMessages.isNotEmpty)controleSkrol.animateTo(0, duration: const Duration(milliseconds: 300), curve: Curves.easeOut);

    } else {
      Usine.montreBiscotte(context, "Oups, votre message est vide!", this);
    }
  }

  Future<void> prendMessages() async {
    final mesEnre = await monPostier.prendPersoStatiques(widget.idUti);
    if(mesEnre.data()!=null && mesEnre.data()!.messages!= null){
      listeMessagesEnr.addAll(mesEnre.data()!.messages!);
    }
    final DocumentSnapshot<Map<String, dynamic>> lesEnre = await monPostier.prendMessagesParDefaut();
    if(lesEnre.data()!=null && lesEnre.data()!= null){
      final x = Map<String,String>.from(lesEnre.data()!);
      listeMessagesEnr.addAll(x);
    }
  }

  confSupr() {
    showDialog(
        context: context,
        builder: (BuildContext Lecontext)=>AlertDialog(
          title: const Text("Supprimer la conversation"),
          content: const Text("Voulez vous supprimez cette conversation?\nCette action est irréversible."),
          actions: [
            TextButton(onPressed: () async {
              Navigator.of(Lecontext).pop();
              Discussion dis= await monPostier.prendLAconv(widget.idConv);
              monPostier.suprConv(dis.utilisateur1+dis.utilisateur2,user?.uid??"erreur",dis.supr).then((value){
                if(value=="0") {
                  Navigator.of(context).push(PageRouteBuilder(
                    pageBuilder: (_, __, ___) => const MyHomePage(),
                    transitionDuration: const Duration(milliseconds: 500),
                    transitionsBuilder: (_, a, __, c) => FadeTransition(opacity: a, child: c),
                  ));
                }
                else{
                  Usine.montreBiscotte(context, "Une erreur est survenue: $value", this);
                }
              });
            }, child: const Text("Valider", style: TextStyle(fontWeight: FontWeight.bold),),),
            MaterialButton(onPressed: ()=>{Navigator.of(context).pop()}, child: const Text("Annuler"),)
          ],
        ));
  }

  montreMessagesEnr() {
    showDialog(context: context, builder: (context)=>AlertDialog(
      title: const Text("Charger un message"),
      content: widget.tempo?const Text("Cette fonction est indisponible en session temporaire\nConnectez vous ou inscrivez vous pour enregistrer des messages."):
      listeMessagesForme(),
      actions: [
        widget.tempo?TextButton(onPressed: ()=>{
          Navigator.of(context).push(PageRouteBuilder(
            pageBuilder: (_, __, ___) =>  Connexion(tempo: widget.idUti,),
            transitionDuration: const Duration(milliseconds: 500),
            transitionsBuilder: (_, a, __, c) => FadeTransition(opacity: a, child: c),
          ))
        },child: const Text("Session connectée"),):const SizedBox.shrink(),
        MaterialButton(onPressed: ()=>{Navigator.of(context).pop()},child: const Text("Annuler"),)
      ],
    ),
    );
  }

  Widget listeMessagesForme() {
    return Container(width: 1000,
        child: ListView.builder(
            shrinkWrap: true,
            itemCount: listeMessagesEnr.keys.length,
            itemBuilder: (BuildContext context, int index) {
              return ListTile(
                title: Text(listeMessagesEnr.keys.toList()[index]),
                onTap: () {
                  redaction.text += listeMessagesEnr.values.toList()[index];
                  Navigator.of(context).pop();
                },
                trailing: IconButton(
                  icon: const Icon(Icons.volume_up),
                  onPressed: ()=>{monTTS.speak(listeMessagesEnr.values.toList()[index])},
                ),
              );
            }
        )
    );
  }

  montreEnregistreMessage(corps){
    showDialog(context: context, builder: (contex)=>AlertDialog(
      title: const Text("Enregistrer le message"),
      content: widget.tempo?const Text("Cette fonction est indisponible en session temporaire\nConnectez vous ou inscrivez vous pour enregistrer des messages."):
      Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text("Indiquez l'intitulé du message à enregistrer"),
          TextField(
            textInputAction:TextInputAction.done,
            keyboardType: TextInputType.text,
            textCapitalization: TextCapitalization.sentences,
            controller: titre,
            decoration: const InputDecoration(
                border: OutlineInputBorder(),
                hintText: 'Intitulé'
            ),
            onSubmitted: (value) {
              nvMessage(corps);
            },
          ),
        ],
      ),
      actions: [
        widget.tempo?TextButton(onPressed: ()=>{
          Navigator.of(context).push(PageRouteBuilder(
            pageBuilder: (_, __, ___) =>  Connexion(tempo: widget.idUti,),
            transitionDuration: const Duration(milliseconds: 500),
            transitionsBuilder: (_, a, __, c) => FadeTransition(opacity: a, child: c),
          ))
        },child: const Text("Session connectée"),):TextButton(onPressed: ()=>{nvMessage(corps)},child: const Text("Enregistrer"),),
        MaterialButton(onPressed: ()=>{Navigator.of(context).pop()},child: const Text("Annuler"),)
      ],
    ));
  }

  Future<void> nvMessage(String corps) async {
    if (titre.text.isNotEmpty && corps.isNotEmpty) {
      final resultat = await monPostier.EnregistreMessage(
          widget.idUti, "", titre.text, corps);
      if (resultat == 0) {
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Enregistré !'),
              backgroundColor: AppCouleur.secondaire,
              behavior: SnackBarBehavior.floating,
            )
        );
        Navigator.of(context).pop();
      } else {
        Usine.montreBiscotte(context, "Une erreur est survenue!", this);
      }
    }else{
      Usine.montreBiscotte(context, "Oups, un intitulé est nécessaire!", this);
    }
  }

  void denotifie() {
    monPostier.denotifie(widget.idUti,widget.idConv);
  }
}