import 'package:cloud_firestore/cloud_firestore.dart';

class Discussion{

  String utilisateur1="erreur";
  String utilisateur2="erreur";
  String pseudo = "Inconnu au bataillon";
  String? supr;

  Discussion();

  Discussion.complet({required this.utilisateur1, required this.utilisateur2, this.supr});


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