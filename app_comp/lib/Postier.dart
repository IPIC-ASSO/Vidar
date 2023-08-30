
import 'dart:async';
import 'dart:developer';

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

  Stream<QuerySnapshot<Discussion>> prendConv(String idUti) {
    return firebaseFirestore.collection(MesConstantes.cheminListeMessages).withConverter(fromFirestore: Discussion.fromFirestore, toFirestore: (Discussion discussion,_)=>Discussion().toFirestore()).where("utilisateur1",isNotEqualTo: "").snapshots();
  }

  Future<QuerySnapshot<Discussion>> prendConvStatique(String idUti) {
    return firebaseFirestore.collection(MesConstantes.cheminListeMessages).withConverter(fromFirestore: Discussion.fromFirestore, toFirestore: (Discussion discussion,_)=>Discussion().toFirestore()).where("utilisateur1",isNotEqualTo: "").get();
  }

  Future<Discussion> prendLAconv(String idConv) async {
    final Discussion Dis =  (await firebaseFirestore.collection(MesConstantes.cheminListeMessages).doc(idConv).withConverter(fromFirestore: Discussion.fromFirestore, toFirestore: (Discussion discussion,_)=>Discussion().toFirestore()).get()).data() as Discussion;
    return Dis;
  }

  Future<String> prendPseudo(String id) async {
    final x = await firebaseFirestore.collection(MesConstantes.cheminUtilisateur).doc(id).withConverter(fromFirestore: Utilisateur.fromFirestore, toFirestore: (Utilisateur utilisateur,_)=>Utilisateur().toFirestore()).get();
    if(x.data()==null) return "Inconnu au bataillon";
    return (x.data()!.pseudo)??"Inconnu au bataillon";
  }

  Future<String> suprConv(String idConv, String idMoi, String? dejaSupr) async {
    try{
      if (dejaSupr!=null) {
        await firebaseFirestore.collection(MesConstantes.cheminListeMessages).doc(idConv).delete();
        await firebaseFirestore.collection(MesConstantes.cheminMessages).doc(idConv).delete();
      } else {
        await firebaseFirestore
            .collection(MesConstantes.cheminListeMessages)
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
    try {
      await firebaseFirestore.collection(MesConstantes.cheminMessages).doc(
          idConv).update(
          {
            DateTime
                .now()
                .millisecondsSinceEpoch
                .toString():
            {
              MesConstantes.message: corps,
              MesConstantes.envoyeur: idEnvoyeur
            }
          }
      );
      return 0;
    }on FirebaseException catch(e){
      if(e.code=="not-found"){
        await firebaseFirestore.collection(MesConstantes.cheminMessages).doc(idConv).set(
            {
              DateTime.now().millisecondsSinceEpoch.toString():
              {
                MesConstantes.message: corps,
                MesConstantes.envoyeur: idEnvoyeur
              }
            }
        );
        return 0;
      }else{
        log("b${e.code}");
        return 1;
      }
    }catch(e){
      print("a $e");
      return 1;
    }
  }

  Future<int> supprime(String temps,String idConv) async {
    try{
      await firebaseFirestore.doc("${MesConstantes.cheminMessages}/$idConv").update({temps: FieldValue.delete()});
      return 0;
    }catch(e){
      print(e);
      return 1;
    }
  }

  modifie(String idConv, Map<String,String> nouvMessage) async {
    final nouvMessage2 = Map.from(nouvMessage);
    nouvMessage2.remove(MesConstantes.temps);
    print(nouvMessage2);
    try {
      await firebaseFirestore.collection(MesConstantes.cheminMessages).doc(idConv).update({nouvMessage[MesConstantes.temps]??"1676633613878": nouvMessage2});
      return 0;
    } catch (e) {
      print(e);
      return 1;
    }
  }

  Future<DocumentSnapshot<Map<String,dynamic>>> prendMessagesParDefaut() async{
    return firebaseFirestore.collection(MesConstantes.cheminListeMessages).doc(MesConstantes.cheminListeMessagesPreEnr).get();
  }

  Stream<DocumentSnapshot<Utilisateur>> prendPersonnel(String idUti) {
    return  firebaseFirestore.collection(MesConstantes.cheminUtilisateur).doc(idUti).withConverter(fromFirestore: Utilisateur.fromFirestore, toFirestore: (Utilisateur utilisateur,_)=>Utilisateur().toFirestore()).snapshots();
  }

  Future<DocumentSnapshot<Utilisateur>> prendPersoStatiques(String idUti){
    return  firebaseFirestore.collection(MesConstantes.cheminUtilisateur).doc(idUti).withConverter(fromFirestore: Utilisateur.fromFirestore, toFirestore: (Utilisateur utilisateur,_)=>Utilisateur().toFirestore()).get();
  }

  Future<int> prendPersoNb(String idUti) async{
    final DocumentSnapshot<Utilisateur> uti = await firebaseFirestore.collection(MesConstantes.cheminUtilisateur).doc(idUti).withConverter(fromFirestore: Utilisateur.fromFirestore, toFirestore: (Utilisateur utilisateur,_)=>Utilisateur().toFirestore()).get();
    if(uti.data()!=null)return uti.data()!.nb??0;
    return 0;
  }

  Future<int> supprimeMessage(String idUt, String titre) async {
    try{
      DocumentSnapshot<Utilisateur> uti = await firebaseFirestore.collection(MesConstantes.cheminUtilisateur).doc(idUt).withConverter(fromFirestore: Utilisateur.fromFirestore, toFirestore: (Utilisateur utilisateur, _) => Utilisateur().toFirestore()).get();
      Map<String,String> messages = uti.data()!.messages??{};
      if(messages.containsKey(titre))messages.remove(titre);
      await firebaseFirestore.collection(MesConstantes.cheminUtilisateur).doc(idUt).update({MesConstantes.messagesEnregistres:messages});
      return 0;
    }catch(e){
      print(e);
      return 1;
    }
  }

  Future<int> EnregistreMessage(String idUt, String titre,String nouvtitre, String corps) async{
    try{
      DocumentSnapshot<Utilisateur> uti = await firebaseFirestore.collection(MesConstantes.cheminUtilisateur).doc(idUt).withConverter(fromFirestore: Utilisateur.fromFirestore, toFirestore: (Utilisateur utilisateur, _) => Utilisateur().toFirestore()).get();
      Map<String,String> messages = uti.data()!.messages??{};
      if(messages.containsKey(titre))messages.remove(titre);
      messages[nouvtitre] = corps;
      await firebaseFirestore.collection(MesConstantes.cheminUtilisateur).doc(idUt).update({MesConstantes.messagesEnregistres:messages});
      return 0;
    }catch(e){
      return 1;
    }
  }

  changePseudo(String uid, String text) async {
    await firebaseFirestore.collection(MesConstantes.cheminUtilisateur).doc(uid).update(
        {MesConstantes.nomUti:text});
  }

  Future<int> creeUti(String uid, String pseudo) async {
    final int nb = ((((await firebaseFirestore.collection(MesConstantes.cheminListeMessages).doc(MesConstantes.cheminListeCode).get()).data())??{} as Map<String,dynamic>)[MesConstantes.nb]??0)as int;
    final user = <String, dynamic>{
      MesConstantes.nomUti: pseudo,
      MesConstantes.nb: nb+1,
    };
    await firebaseFirestore.collection("Utilisateurs").doc(uid)
        .set(user)
        .then((value) => print('Utilisateur enregistré'))
        .onError((error, stackTrace) => print(error));
    await firebaseFirestore.collection(MesConstantes.cheminListeMessages).doc(MesConstantes.cheminListeCode).update({MesConstantes.code: FieldValue.arrayUnion([uid])}).onError((error, stackTrace) => log(error.toString()));
    await firebaseFirestore.collection(MesConstantes.cheminListeMessages).doc(MesConstantes.cheminListeCode).update({MesConstantes.nbCode: FieldValue.increment(1)}).onError((error, stackTrace) => log(error.toString()));
    return nb+1;
  }

  Future<void> denotifie(String idUti, String idConv) async {
    await firebaseFirestore.collection(MesConstantes.cheminUtilisateur).doc(idUti).update({
      MesConstantes.co:idConv
    });
  }

  Future<void> renotifie(String idUti) async {
    await firebaseFirestore.collection(MesConstantes.cheminUtilisateur).doc(idUti).update({
      MesConstantes.co:""
    });
  }
}