import 'dart:developer';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
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
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    monPostier = laPoste(firebaseFirestore: FirebaseFirestore.instance);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      body: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: double.infinity,
            decoration: const BoxDecoration(
                border:  Border(
                  bottom: BorderSide(width: 3.0, color: AppCouleur.tete),
                ),
            ),
            padding: const EdgeInsets.fromLTRB(15,25,15,10),
            child: const Text("Liste des conversations en cours", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18), textAlign: TextAlign.center,)
          ),
          StreamBuilder(
              stream: monPostier.prendConv(user?.uid??""),
              builder: (BuildContext context, AsyncSnapshot<QuerySnapshot<Discussion>> snapshot) {
                if(snapshot.hasData && snapshot.data!.docs.length>0){
                  List<Widget> enfants = [];
                  List<QueryDocumentSnapshot<Discussion>> lst =snapshot.data!.docs;
                  lst.sort((a,b){
                    if (b.data().notif==user?.uid) return 1;
                    return -1;
                  });
                  lst.forEach((element) async {
                    final dis = element.data() as Discussion;
                    if((dis.supr==null || dis.supr!=user!.uid) && (dis.utilisateur1==user!.uid ||dis.utilisateur2==user!.uid)){
                      enfants.add(construitConv(dis));
                    }
                  });
                  if (enfants.isEmpty)
                    return const Padding(
                      padding: EdgeInsets.all(15),
                      child: Text("Aucune conversation enregistrée\nCommencez en une avec le petit bouton bleu clair", textAlign: TextAlign.center,),
                    );
                  return Expanded(child: ListView(
                    padding: EdgeInsets.only(bottom: 100),
                    shrinkWrap: true,
                    children: enfants));
                }else if(snapshot.hasError){
                  log(snapshot.error.toString());
                  return const Center(
                    child: Column(
                      children: [
                        Icon(Icons.error),
                        Text("Une erreur est survenue", textAlign: TextAlign.center,)
                      ],
                    )
                  );
                }else{
                  return const Padding(
                    padding: EdgeInsets.all(15),
                    child: Text("Aucune conversation enregistrée\nCommencez en une avec le petit bouton bleu clair", textAlign: TextAlign.center,),
                  );
                }
              }
          )
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: AppCouleur().eco,
        onPressed: ()=>{
          Navigator.of(context).push(PageRouteBuilder(
            pageBuilder: (_, __, ___) => NouvConv(idUti: user?.uid??"erreur",),//TODO
            transitionDuration: const Duration(milliseconds: 500),
            transitionsBuilder: (_, a, __, c) => FadeTransition(opacity: a, child: c),
          ))
        },
        label: const Text('Nouvelle Conversation'),
        icon:  const Icon(Icons.add),
      ),
    );
  }



  Widget construitConv(Discussion dis) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical:10,horizontal:15),
        child:FutureBuilder(
          future: monPostier.prendPseudo(dis.utilisateur1==user!.uid?dis.utilisateur2:dis.utilisateur1),
           builder: (BuildContext context, AsyncSnapshot<String> snapshot) {
            if(snapshot.hasData){
              dis.pseudo = snapshot.data??"Inconnu au bataillon";
              return GestureDetector(
                  onTap: (){
                    if(dis.notif==user?.uid)monPostier.enleve_pastille(dis);
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
                      color: dis.supr!=null?AppCouleur.tete:AppCouleur().grisTresClair,
                      borderRadius: const BorderRadius.all(Radius.circular(15)),
                      boxShadow: const [
                        BoxShadow(
                          offset: Offset(3.0, 3.0,),
                          blurRadius: 3.0,
                        ), //BoxShadow
                        BoxShadow(
                          color: Colors.white,
                          offset: Offset(0.0, 0.0),
                          blurRadius: 0.0,
                          spreadRadius: 0.0,
                        ), //BoxShadow
                      ],
                    ),
                    padding: const EdgeInsets.all(5),
                    child: Row(
                      children: [
                        const Expanded(
                            flex: 0,
                            child: Padding(
                              padding: EdgeInsets.all(3),
                              child: Icon(Icons.account_circle_rounded),
                            )
                        ),
                        Expanded(
                          flex: 0,
                            child: Padding(
                              padding: EdgeInsets.all(3),
                              child: Visibility(
                                visible: dis.notif==user?.uid,
                                child:Icon(Icons.mail_outline_rounded, color: AppCouleur().eco,),
                              )
                            )
                        ),
                        Expanded(
                            flex: 1,
                            child: Padding(
                                padding: const EdgeInsets.all(3),
                                child: Text(textAlign: TextAlign.center, dis.pseudo, style: const TextStyle(fontSize: 16),)
                            )
                        ),
                        Expanded(
                            flex: 0,
                            child: Padding(
                                padding: const EdgeInsets.all(3),
                                child: IconButton(
                                  color: dis.supr!=null?AppCouleur.spaceCadet:AppCouleur.banni,
                                  onPressed: () => {
                                    confSupr(dis)
                                  },
                                  icon: const Icon(Icons.delete_forever),
                                  tooltip: "Supprimer la conversation")
                            )
                        ),
                      ],
                    ),
                  ));
            }else{
              return const LinearProgressIndicator();
            }
           }
        ));
  }

  confSupr(Discussion dis) {
    showDialog(
        context: _scaffoldKey.currentContext!,
        builder: (context)=>AlertDialog(
          title: const Text("Supprimer la conversation"),
          content: const Text("Voulez vous supprimez cette conversation?\nCette action est irréversible."),
          actions: [
            TextButton(onPressed: (){
              Navigator.of(context).pop();
              laPoste(firebaseFirestore: FirebaseFirestore.instance).suprConv(dis.utilisateur1+dis.utilisateur2,user?.uid??"erreur",dis.supr).then((value){
                if(value=="0")Usine.montreBiscotte(context, "Supprimé !", this, true,true);
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
