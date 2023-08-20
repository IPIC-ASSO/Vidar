import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
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
            dis.pseudo = await prendPseudo(dis.utilisateur1==idUti?dis.utilisateur2??"":dis.utilisateur1??"");
            conv.add(dis);
          }
        }
    });
    return conv;
  }

  prendPseudo(String id) async {
    final x = await firebaseFirestore.collection("Utilisateurs").doc(id).get();
    return x.data()!["pseudo"]??"Inconnu au bataillon";
  }
}