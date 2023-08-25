import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';
import 'package:vidar/interfaceDiscussion.dart';
import 'package:vidar/patrons/MesConstantes.dart';

import 'Postier.dart';
import 'usineDeBiscottesGrillees.dart';


class NouvConv extends StatefulWidget {

  final String idUti;

  const NouvConv({super.key, required this.idUti});

  @override
  State<NouvConv> createState() => _NouvConvState();
}

class _NouvConvState extends State<NouvConv> with TickerProviderStateMixin {

  late TabController controleTable;
  late laPoste monPostier;
  FirebaseFirestore db = FirebaseFirestore.instance;
  bool charge = false;

  @override
  void initState() {
    super.initState();
    monPostier = laPoste(firebaseFirestore: db);
    controleTable = TabController(length: 2, vsync: this);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title: const Text("Démarrer une conversation",),
          bottom: TabBar(
              isScrollable: true,
              controller: controleTable,
              tabs: [
                const Tab(icon: Icon(Icons.app_registration),
                    child: Text("Créer un QR-code", textAlign: TextAlign.center,)),
                const Tab(icon: Icon(Icons.qr_code_scanner),
                    child: Text("Scanner un QR-code", textAlign: TextAlign.center,)),
              ]
          )
      ),
        body:
          TabBarView(
            controller: controleTable,
            children: [
              Column(children: [
                Padding(padding: EdgeInsets.all(15),child:Text("Afficher un message au dessus du QR-code:")),
                Padding(padding: EdgeInsets.all(15),child:ElevatedButton(onPressed:(){},child:Text("[AUCUN]"))),
                Padding(padding: EdgeInsets.all(15),child:Text("Lire un message avec l'application:")),
                Padding(padding: EdgeInsets.all(15),child:ElevatedButton(onPressed:(){},child:Text("[AUCUN]"))),
                Padding(padding: EdgeInsets.all(15),child:Text("Message au début de la conversation:")),
                Padding(padding: EdgeInsets.all(15),child:ElevatedButton(onPressed:(){},child:Text("[AUCUN]"))),
              ],),
              Center(child:
                  charge?
                const CircularProgressIndicator():
                ElevatedButton(
                onPressed: () => scanQR(),
                  child: const Text('Lancer le scan', style: TextStyle(fontSize: 17),))
                ),
              ]),
    );
  }

  Future<void> scanQR() async {
    String barcodeScanRes ="";
    // Platform messages may fail, so we use a try/catch PlatformException.
    try {
      barcodeScanRes = await FlutterBarcodeScanner.scanBarcode(
          '#6666ff', 'Retour',false, ScanMode.QR);
      print(barcodeScanRes);
    } on PlatformException {
      Usine.montreBiscotte(context, 'Failed to get platform version.', this);
    }
    if (!mounted) return;

    setState(() {
      charge = true;
    });
    try{
      if(barcodeScanRes.isNotEmpty)analyselien(barcodeScanRes);
      else{
        Usine.montreBiscotte(context, 'QR-code non valide', this);
      }
    }catch(e){
      Usine.montreBiscotte(context, 'Une erreur est survenue', this);
    }
  }

  analyselien(String codex) async {
    String idConv;
    String destinataire = codex.replaceAll("https://", "");
    destinataire = codex.replaceAll("vidar-9e8ac.web.app/?dest=", "");
    final QuerySnapshot<Map<String, dynamic>> listeConv = await db.collection(MesConstantes.cheminListeMessages).get();
    if(listeConv.docs.any((element) => element.id.contains(widget.idUti) && element.id.contains(destinataire))){
      idConv = listeConv.docs.firstWhere((element) => element.id.contains(widget.idUti) && element.id.contains(destinataire)).id;
    }else{
      idConv = destinataire + widget.idUti;
      await db.collection(MesConstantes.cheminListeMessages).doc(idConv).set(
        {
          "utilisateur1": destinataire,
          "utilisateur2": widget.idUti,
        }
      );
    }
    await db.collection(MesConstantes.cheminUtilisateur).doc(destinataire).update(
        {"contact":widget.idUti}
    );
    final doc = await db.collection(MesConstantes.cheminUtilisateur).doc(destinataire).get();
    String pseudo = "inconnu au bataillon";
    if(doc.data()!= null && doc.data()![MesConstantes.nomUti]!= null)pseudo = doc.data()![MesConstantes.nomUti];
    Navigator.push(context,
      PageRouteBuilder(
        pageBuilder: (_, __, ___) => InterfaceDiscussion(idUti: widget.idUti, idConv: idConv, pseudoDest: pseudo),
        transitionDuration: const Duration(milliseconds: 500),
        transitionsBuilder: (_, a, __, c) => FadeTransition(opacity: a, child: c),
      ),
    );
  }
}
