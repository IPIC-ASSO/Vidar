import 'package:cloud_firestore/cloud_firestore.dart';

import 'MesConstantes.dart';

class Discussion{

  String utilisateur1="erreur";
  String utilisateur2="erreur";
  String? notif;
  String pseudo = "Inconnu au bataillon";
  String? supr;

  Discussion();

  Discussion.complet({required this.utilisateur1, required this.utilisateur2, this.supr});
  Discussion.trescomplet({required this.utilisateur1, required this.utilisateur2, this.notif, this.supr});


  factory Discussion.fromFirestore(
      DocumentSnapshot<Map<String, dynamic>> snapshot,
      SnapshotOptions? options,
      ) {
    final data = snapshot.data();
    return Discussion.complet(
      utilisateur1: data?['utilisateur1']??"erreur",
      utilisateur2: data?['utilisateur2']??"erreur",
      supr: data?['supr'],
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
     "utilisateur1": utilisateur1,
     "utilisateur2": utilisateur2,
      if(supr!=null)"supr": supr,
    };
  }
}

class Message {

  String envoyeur;
  String corps;
  String temps;

  Message(
      {required this.envoyeur,
        required this.temps,
        required this.corps});

  Map<String, dynamic> toJson() {
    return {
      MesConstantes.envoyeur: envoyeur,
      MesConstantes.temps: temps,
      MesConstantes.message: corps,
    };
  }

  factory Message.fromDocument(Map<String,String> doc) {
    String envoyeur = doc[MesConstantes.envoyeur]??"inconnu au bataillon";
    String temps = doc[MesConstantes.temps]??"1676633613878";
    String corps = doc[MesConstantes.message]??"Impossible de charger le message";

    return Message(
        envoyeur: envoyeur,
        temps:temps,
        corps:corps,);
  }
}

class MessageDefaut{
  String titre;
  String corps;

  MessageDefaut({required this.titre, required this.corps});



}