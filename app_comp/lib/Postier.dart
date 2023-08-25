
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:vidar/patrons/MesConstantes.dart';
import 'package:vidar/patrons/Utilisateur.dart';
import 'package:vidar/patrons/convDeListe.dart';

class laPoste {

  final FirebaseFirestore firebaseFirestore;


  laPoste({
    required this.firebaseFirestore,
  });

  configure() async {
    if (kIsWeb) {
      await firebaseFirestore.enablePersistence(
          const PersistenceSettings(synchronizeTabs: true));
    } else {
      firebaseFirestore.settings = const Settings(persistenceEnabled: true);
    }
  }

  Future<List<Discussion>>prendConv(String idUti) async {
    List<Discussion> conv = [];
    await firebaseFirestore.collection("ListeChats").withConverter(fromFirestore: Discussion.fromFirestore, toFirestore: (Discussion discussion,_)=>Discussion().toFirestore()).snapshots().listen((event) async {
      for(DocumentSnapshot doc in event.docs)
        if (doc.id.contains(idUti) && doc.data().runtimeType is Discussion){
          final dis = doc.data() as Discussion;
          if(dis.supr!=null && dis.supr!=idUti){
            dis.pseudo = await prendPseudo(dis.utilisateur1==idUti?dis.utilisateur2:dis.utilisateur1);
            conv.add(dis);
          }
        }
    });
    return conv;
  }

  Future<Discussion> prendLAconv(String idConv) async {
    final Discussion Dis =  (await firebaseFirestore.collection("ListeChats").doc(idConv).withConverter(fromFirestore: Discussion.fromFirestore, toFirestore: (Discussion discussion,_)=>Discussion().toFirestore()).get()).data() as Discussion;
    return Dis;
  }

  prendPseudo(String id) async {
    final x = await firebaseFirestore.collection("Utilisateurs").doc(id).get();
    return x.data()!["pseudo"]??"Inconnu au bataillon";
  }

  Future<String>suprConv(String idConv, String idMoi, String? dejaSupr) async {
    try{
      if (dejaSupr!=null) {
        await firebaseFirestore.collection("ListeChats").doc(idConv).delete();
        await firebaseFirestore.collection("Chats").doc(idConv).delete();
      } else {
        await firebaseFirestore
            .collection("ListeChats")
            .doc(idConv)
            .update({"supr": idMoi});
      }
      return "0";
    }on FirebaseException catch(e){
      return(e.code);
    }catch(e){
      return(e.toString());
    }
  }

  Stream<DocumentSnapshot> prendLesChatsDuQuartier(String conv) {
    return firebaseFirestore
        .collection(MesConstantes.cheminMessages)
        .doc(conv)
        .snapshots();
  }

  Future<int> envoie(String corps, String idConv, String idEnvoyeur) async {
    try{
      await firebaseFirestore.collection(MesConstantes.cheminMessages).doc(idConv).update(
        {
          DateTime.now().millisecondsSinceEpoch.toString():
              {
                MesConstantes.message:corps,
                MesConstantes.envoyeur:idEnvoyeur
              }
        }
      );
      return 0;
    }catch(e){
      return 1;
    }
  }

  Future<int> supprime(String temps,String idConv) async {
    try{
      await firebaseFirestore.doc("${MesConstantes.cheminMessages}/$idConv").update({temps: null});
      return 0;
    }catch(e){
      return 1;
    }
  }

  modifie(String idConv, Map<String,String> nouvMessage) async {
    final nouvMessage2 = Map.from(nouvMessage);
    nouvMessage2.remove(MesConstantes.temps);
    try {
      await firebaseFirestore.collection(MesConstantes.cheminMessages).doc(idConv).update({nouvMessage[MesConstantes.temps]??"1676633613878": nouvMessage2});
      return 0;
    } catch (e) {
      return 1;
    }
  }

  prendMessagesParDefaut() async{
    final DocumentSnapshot documentsParDefaut = await firebaseFirestore.collection(MesConstantes.cheminListeMessages).doc(MesConstantes.cheminListeMessagesPreEnr).get();
    return((documentsParDefaut.data()??{}) as Map<String,String>);
  }

  prendMessagesPersonnels(String idUti) async {
    Map<String,String> messages = {};
    final Stream<DocumentSnapshot<Utilisateur>> uti  = await firebaseFirestore.collection(MesConstantes.cheminUtilisateur).doc(idUti).withConverter(fromFirestore: Utilisateur.fromFirestore, toFirestore: (Utilisateur utilisateur,_)=>Utilisateur().toFirestore()).snapshots();
    if(uti..data()!=null){
      messages.addAll(uti.data()!.messages??{});
    }
    return messages;
  }
}