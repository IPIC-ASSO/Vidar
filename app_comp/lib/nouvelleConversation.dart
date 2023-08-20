import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'AppCouleur.dart';
import 'usineDeBiscottesGrillees.dart';

class NouvConv extends StatefulWidget {

  const NouvConv({super.key});

  @override
  State<NouvConv> createState() => _NouvConvState();
}

class _NouvConvState extends State<NouvConv> with TickerProviderStateMixin {

  late TabController controleTable;

  @override
  void initState() {
    super.initState();
    controleTable = TabController(length: 2, vsync: this);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title: const Text("Démarrer une conversation",),
          bottom: TabBar(
              controller: controleTable,
              tabs: [
                const Tab(icon: Icon(Icons.app_registration),
                    child: Text("Créer un QR-code", textAlign: TextAlign.center,)),
                const Tab(icon: Icon(Icons.qr_code_scanner),
                    child: Text("Scanner un QR-code", textAlign: TextAlign.center,)),
              ]
          )
      ),
      body: Column(children: [

      ]),
    );
  }
}
