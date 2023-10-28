import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:vidar/patrons/MesConstantes.dart';

class Utilisateur{
  String? id;
  String? pseudo;
  List<String>? contacts;
  Map<String, String>? messages;
  Map<String, dynamic>? messages2;
  int? nb;



  Utilisateur();


  Utilisateur.complet({this.id, this.pseudo, this.contacts, this.messages, this.nb, required this.messages2});

  factory Utilisateur.fromFirestore(
      DocumentSnapshot<Map<String, dynamic>> snapshot,
      SnapshotOptions? options,
      ) {
    final data = snapshot.data();
    return Utilisateur.complet(
      id: snapshot.id,
      pseudo: data?[MesConstantes.nomUti],
      nb: data?[MesConstantes.nb],
      contacts: data?[MesConstantes.contact] is Iterable ? List.from(data?[MesConstantes.contact]) : [],
      //messages: data?[MesConstantes.messagesEnregistres] is Map ? Map.from(data?[MesConstantes.messagesEnregistres]) : {},
      messages2: data?[MesConstantes.messagesEnregistres] is Map ? Map.from(data?[MesConstantes.messagesEnregistres]) : {},
    );
  }
  Map<String, dynamic> toFirestore() {
    return {
      if (pseudo != null) MesConstantes.nomUti: pseudo,
      if (contacts != null) MesConstantes.contact: contacts,
      if (messages != null) MesConstantes.messagesEnregistres: messages,
      if (messages2 != null) MesConstantes.messagesEnregistres: messages2,
      if(nb != null) MesConstantes.nb: nb,
    };
  }
}

//TODO: à travailler!!!


