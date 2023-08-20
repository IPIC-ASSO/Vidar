import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:vidar/Postier.dart';
import 'package:vidar/patrons/convDeListe.dart';

class Conversations extends StatefulWidget {

  const Conversations({super.key});

  @override
  State<Conversations> createState() => _ConversationsState();
}

class _ConversationsState extends State<Conversations> {

  final user = FirebaseAuth.instance.currentUser;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          const Padding(
            padding: EdgeInsets.all(15),
            child: Text("Liste des conversations en cours", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18), textAlign: TextAlign.center,)
          ),
          FutureBuilder(
              future: laPoste(firebaseFirestore: FirebaseFirestore.instance).prendConv(user?.uid??""),
              builder: (BuildContext context, AsyncSnapshot<List<Discussion>> snapshot) {
                if(snapshot.hasData && snapshot.data!.length>0){
                  List<Widget> enfants = []
                  return Text("d");
                }else if(snapshot.hasError){
                  return const Center(
                    child: Column(
                      children: [
                        Icon(Icons.error),
                        Text("Une erreur est survenue", textAlign: TextAlign.center,)
                      ],
                    )
                  );
                }else{
                  return Center(
                    child: Text("Aucune conversation enregistrée\nCommencez en une avec le petit bouton vert"),
                  );
                }
              }
          )
        ],
      ),
    );
  }z

}
