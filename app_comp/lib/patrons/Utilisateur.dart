import 'package:cloud_firestore/cloud_firestore.dart';

class Utilisateur{
  String? id;
  String? pseudo;
  List<String>? contacts;
  List<String>? messages;

  Utilisateur(this.id, this.pseudo);


  Utilisateur.complet({this.id, this.pseudo, this.contacts, this.messages});

  factory Utilisateur.fromFirestore(
      DocumentSnapshot<Map<String, dynamic>> snapshot,
      SnapshotOptions? options,
      ) {
    final data = snapshot.data();
    return Utilisateur.complet(
      id: snapshot.id,
      pseudo: data?['pseudo'],
      contacts: data?['contacts'] is Iterable ? List.from(data?['contacts']) : [],
      messages: data?['messages'] is Iterable ? List.from(data?['messages']) : [],
    );
  }
  Map<String, dynamic> toFirestore() {
    return {
      if (pseudo != null) "pseudo": pseudo,
      if (contacts != null) "contacts": contacts,
      if (messages != null) "messages": messages,
    };
  }
}