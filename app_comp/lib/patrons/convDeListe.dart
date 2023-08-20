import 'package:cloud_firestore/cloud_firestore.dart';

class Discussion{

  final String? utilisateur1;
  final String? utilisateur2;
  String? pseudo;
  final String? supr;

  Discussion({this.utilisateur1, this.utilisateur2, this.supr});

  factory Discussion.fromFirestore(
      DocumentSnapshot<Map<String, dynamic>> snapshot,
      SnapshotOptions? options,
      ) {
    final data = snapshot.data();
    return Discussion(
      utilisateur1: data?['utilisateur1'],
      utilisateur2: data?['utilisateur2'],
      supr: data?['supr'],
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      if (utilisateur1 != null) "utilisateur1": utilisateur1,
      if (utilisateur2 != null) "utilisateur2": utilisateur2,
      if (supr != null) "supr": supr,
    };
  }

}