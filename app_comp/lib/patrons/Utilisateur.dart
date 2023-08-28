import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:vidar/patrons/MesConstantes.dart';

class Utilisateur{
  String? id;
  String? pseudo;
  List<String>? contacts;
  Map<String, String>? messages;
  int? nb;



  Utilisateur();


  Utilisateur.complet({this.id, this.pseudo, this.contacts, this.messages, this.nb});

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
      messages: data?[MesConstantes.messagesEnregistres] is Map ? Map.from(data?[MesConstantes.messagesEnregistres]) : {},
    );
  }
  Map<String, dynamic> toFirestore() {
    return {
      if (this.pseudo != null) MesConstantes.nomUti: this.pseudo,
      if (this.contacts != null) MesConstantes.contact: this.contacts,
      if (this.messages != null) MesConstantes.messagesEnregistres: this.messages,
      if(this.nb != null) MesConstantes.nb: this.nb,
    };
  }
}