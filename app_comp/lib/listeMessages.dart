import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';
import 'package:vidar/interfaceDiscussion.dart';
import 'package:vidar/patrons/MesConstantes.dart';

import 'Postier.dart';
import 'usineDeBiscottesGrillees.dart';


class ListeMessages extends StatefulWidget {

  final String idUti;

  const ListeMessages({super.key, required this.idUti});

  @override
  State<ListeMessages> createState() => _ListeMessagesState();
}

class _ListeMessagesState extends State<ListeMessages> with TickerProviderStateMixin {

  late TabController controleTable;
  late laPoste monPostier;
  FirebaseFirestore db = FirebaseFirestore.instance;
  bool charge = false;

  @override
  void initState() {
    super.initState();
    monPostier = laPoste(firebaseFirestore: db);
  }

  @override
  Widget build(BuildContext context) {
   return Scaffold(
     appBar: AppBar(
       title: const Text("Messages enregistrés"),
     ),
     body: FutureBuilder<Map<String,String>>(
      future: monPostier.prendMessagesEnregistres(), // a previously-obtained Future<String> or null
      builder: (BuildContext context, AsyncSnapshot<Map<String,String>> snapshot) {
      List<Widget> enfants = [];
    })
   );
  }
}