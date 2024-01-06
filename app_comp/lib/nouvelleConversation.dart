import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';
import 'package:vidar/interfaceDiscussion.dart';
import 'package:vidar/patrons/MesConstantes.dart';
import 'package:vidar/qrcode.dart';
import 'AppCouleur.dart';
import 'Postier.dart';
import 'main.dart';
import 'usineDeBiscottesGrillees.dart';


class NouvConv extends StatefulWidget {

  final String idUti;


  const NouvConv({super.key, required this.idUti,});

  @override
  State<NouvConv> createState() => _NouvConvState();
}

class _NouvConvState extends State<NouvConv> with TickerProviderStateMixin {

  late TabController controleTable;
  late laPoste monPostier;
  FirebaseFirestore db = FirebaseFirestore.instance;
  bool charge = false;
  Map<String,dynamic> listeMessages = {"defaut":{"[AUCUN]":""}};
  List<String> messages = ["[AUCUN]","[AUCUN]","[AUCUN]"];
  List<String> sectionDumessages = ["defaut","defaut","defaut"];
  TextEditingController code = TextEditingController();
  late int nb;

  @override
  void initState() {
    super.initState();
    monPostier = laPoste(firebaseFirestore: db);
    controleTable = TabController(length: 2, vsync: this);
    prendMessages();
    FirebaseAuth.instance.authStateChanges().listen((User? user) {
      if (user == null) {
        Navigator.of(context).push(PageRouteBuilder(
          pageBuilder: (_, __, ___) => const MyHomePage(),
          transitionDuration: const Duration(milliseconds: 500),
          transitionsBuilder: (_, a, __, c) => FadeTransition(opacity: a, child: c),
        ));
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title: const Text("Démarrer une conversation",),
          bottom: TabBar(
              isScrollable: true,
              controller: controleTable,
              tabs: const [
                Tab(icon: Icon(Icons.app_registration),
                    child: Text("Créer un QR-code", textAlign: TextAlign.center,)),
                Tab(icon: Icon(Icons.qr_code_scanner),
                    child: Text("Scanner un QR-code", textAlign: TextAlign.center,)),
              ]
          )
      ),
        body:
          TabBarView(
            controller: controleTable,
            children: [
              Column(children: [
                const Padding(padding: EdgeInsets.all(15),child:Text("Afficher un message avec le QR-code:")),
                Padding(padding: const EdgeInsets.all(15),child:ElevatedButton(onPressed:(){
                  showDialog(context: context, builder: (context)=>AlertDialog(
                    title: const Text("Message à afficher"),
                    content: listeMessagesForme(0),
                    actions: [
                      MaterialButton(onPressed: ()=>{Navigator.of(context).pop()},child: const Text("Annuler"),)
                    ],
                    ),
                  );
                },child:Text(messages[0]))),
                const Padding(padding: EdgeInsets.all(15),child:Text("Lire un message avec l'application:")),
                Padding(padding: const EdgeInsets.all(15),child:ElevatedButton(onPressed:(){
                  showDialog(context: context, builder: (context)=>AlertDialog(
                    title: const Text("Message à lire"),
                    content: listeMessagesForme(1),
                    actions: [
                      MaterialButton(onPressed: ()=>{Navigator.of(context).pop()},child: const Text("Annuler"),)
                    ],
                  ));
                },child:Text(messages[1]))),
                const Padding(padding: EdgeInsets.all(15),child:Text("Message au début de la conversation:")),
                Padding(padding: const EdgeInsets.all(15),child:ElevatedButton(onPressed:(){
                  showDialog(context: context, builder: (context)=>AlertDialog(
                    title: const Text("Message à envoyer"),
                    content: listeMessagesForme(2),
                    actions: [
                      MaterialButton(onPressed: ()=>{Navigator.of(context).pop()},child: const Text("Annuler"),)
                    ],
                  ),
                  );
                },child:Text(messages[2]))),
                Padding(padding: const EdgeInsets.all(20),
                  child:ElevatedButton(
                      child: const Text("Valider",style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17),),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppCouleur().eco,
                      foregroundColor : AppCouleur.white,
                      minimumSize: const Size.fromHeight(50),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10.0)
                      ),
                    ),
                    onPressed:(){
                      print(listeMessages);
                      Navigator.push(context,
                        PageRouteBuilder(
                        pageBuilder: (_, __, ___) => MontreQrCode(idUt: widget.idUti, messageAffiche: listeMessages[sectionDumessages[0]][messages[0]]??"",messageDebut: listeMessages[sectionDumessages[2]][messages[2]]??"",messageLu: listeMessages[sectionDumessages[1]][messages[1]]??"",nb:nb),
                        transitionDuration: const Duration(milliseconds: 500),
                        transitionsBuilder: (_, a, __, c) => FadeTransition(opacity: a, child: c),
                        ),
                      );
                    }
                  ))
              ],),
              Center(child:(charge?
                const CircularProgressIndicator():
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                  !kIsWeb?Padding(
                    padding: const EdgeInsets.all(5),
                    child:ElevatedButton(
                      onPressed: () => scanQR(),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppCouleur().principal,
                        foregroundColor : AppCouleur.white,
                        minimumSize:Size(MediaQuery.of(context).size.width/(MediaQuery.of(context).size.aspectRatio>1?2:1),50),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10.0)
                        ),),
                      child: const Text('Lancer le scan', style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),))):const Text("Utilisez l'application mobile pour scanner un QR-code"),
                  const Padding(padding: EdgeInsets.all(15),child:Text("OU",textAlign: TextAlign.center,)),
                  Padding(padding: const EdgeInsets.all(5),child: TextField(
                    controller: code,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: 'Code',
                      hintText: "Entrez un code",
                    ),
                  ),),
                  Padding(padding: const EdgeInsets.all(15),child:
                  ElevatedButton(
                    onPressed: () async {
                      try {
                        await prendCode(code.text, context,this,widget.idUti,db);
                      } on FirebaseException catch(e){
                        switch (e.code){
                          case 'not-found':
                            Usine.montreBiscotte(context, "Code invalide", this);
                            break;
                          default:
                            Usine.montreBiscotte(context, "La base de donnée refuse la transaction", this);
                        }
                      }
                      catch (e) {
                        log(e.toString());
                        Usine.montreBiscotte(context, "Une erreur est survenue", this);
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppCouleur().eco,
                      foregroundColor : AppCouleur.white,
                      minimumSize: const Size.fromHeight(50),
                      shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.0))
                    ),
                    child: const Text("Valider",style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17),),
                  )),
                  ],)
                )),
              ]),
    );
  }

  Future<void> scanQR() async {
    String barcodeScanRes ="";
    // Platform messages may fail, so we use a try/catch PlatformException.
    try {
      barcodeScanRes = await FlutterBarcodeScanner.scanBarcode('#6666ff', 'Retour',false, ScanMode.QR);
    } on PlatformException {
      Usine.montreBiscotte(context, 'Failed to get platform version.', this);
    }
    if (!mounted) return;

    setState(() {
      charge = true;
    });
    try{
      if(barcodeScanRes.isNotEmpty && barcodeScanRes.length>5)analyselien(barcodeScanRes);
      else{
        Usine.montreBiscotte(context, 'QR-code non valide', this);
        setState(() {
          charge = false;
        });
      }
    }catch(e){
      Usine.montreBiscotte(context, 'Une erreur est survenue', this);
    }
  }

  analyselien(String codex) async {
    String destinataire = codex.replaceAll("https://", "");
    destinataire = destinataire.replaceAll("vidar-9e8ac.web.app/?dest=", "");
    try {
      await traiteCode(destinataire, widget.idUti,db,context);
    } on FirebaseException catch(e){
      switch (e.code){
        case 'not-found':
          Usine.montreBiscotte(context, "Code invalide", this);
          break;
        default:
          Usine.montreBiscotte(context, "La base de donnée refuse la transaction", this);
      }
    }
    catch (e) {
      log(e.toString());
      Usine.montreBiscotte(context, "Une erreur est survenue", this);
    }
  }

  Future<void> prendMessages() async {
    final mesEnre = await monPostier.prendPersoStatiques(widget.idUti);
    if(mesEnre.data()!=null && mesEnre.data()!.messages!= null){
      nb = mesEnre.data()!.nb??0;
      listeMessages.addAll(mesEnre.data()!.messages!);
    }
    final List<QueryDocumentSnapshot<Map<String, dynamic>>> lesEnre = (await monPostier.prendMessagesParDefaut()).docs;
    if(lesEnre.isNotEmpty){
      lesEnre.forEach((element) {
        listeMessages.addAll({element.id:element.data()});
      });
    }
  }

  Widget listeMessagesForme(int maj){
    return SizedBox(width:1000,
        child:ListView.builder(
            shrinkWrap: true,
            itemCount: listeMessages.keys.length,
            itemBuilder: (BuildContext context, int index) {
              String section = listeMessages.keys.toList()[index];
              return ExpansionTile(
                title: Text(section),
                children: creetuile(listeMessages.values.toList()[index], maj,section),
              );
            }
        )
    );
  }

  List<Widget> creetuile(Map<String,dynamic> lesmessages, int maj, String section) {
    List<Widget> enfants = [];
    lesmessages.forEach((key, value) {
      enfants.add(ListTile(
        title: Text(key),
        onTap: (){
          setState(() {
            sectionDumessages [maj] = section;
            messages[maj] = key;
          });
          Navigator.of(context).pop();
        },
      ));
    });
    return enfants;
  }

}
traiteCode(String destinataire, String idUti, FirebaseFirestore db, BuildContext context, [bool tempo=false]) async {
  String idConv;
  final QuerySnapshot<Map<String, dynamic>> listeConv = await db.collection(MesConstantes.cheminListeMessages).get();
  if(listeConv.docs.any((element) => element.id.contains(idUti) && element.id.contains(destinataire))){
    idConv = listeConv.docs.firstWhere((element) => element.id.contains(idUti) && element.id.contains(destinataire)).id;
  }else{
    idConv = destinataire + idUti;
    await db.collection(MesConstantes.cheminListeMessages).doc(idConv).set(
        {
          "utilisateur1": destinataire,
          "utilisateur2": idUti,
        }
    );
    await db.collection(MesConstantes.cheminMessages).doc(idConv).set({});
  }
  await db.collection(MesConstantes.cheminUtilisateur).doc(destinataire).update(
      {"contact":idUti}
  );
  final doc = await db.collection(MesConstantes.cheminUtilisateur).doc(destinataire).get();
  String pseudo = "inconnu au bataillon";
  if(doc.data()!= null && doc.data()![MesConstantes.nomUti]!= null)pseudo = doc.data()![MesConstantes.nomUti];
  Navigator.push(context,
    PageRouteBuilder(
      pageBuilder: (_, __, ___) => InterfaceDiscussion(idUti: idUti, idConv: idConv, pseudoDest: pseudo, tempo: tempo,),
      transitionDuration: const Duration(milliseconds: 500),
      transitionsBuilder: (_, a, __, c) => FadeTransition(opacity: a, child: c),
    ),
  );
}

bool isNumeric(String s) {
  return double.tryParse(s) != null;
}

 prendCode(String code, BuildContext context, TickerProvider ticket, String idUti, FirebaseFirestore db, [bool tempo = false]) async{
  if(code.isNotEmpty && isNumeric(code)){
    final DocumentSnapshot x = await db.collection(MesConstantes.cheminListeMessages).doc(MesConstantes.cheminListeCode).get();
    if(x.data()!= null ){
      final doc = x.data() as Map<String, dynamic>;
      if((doc[MesConstantes.code] as List<dynamic>).length>int.parse(code)){
        await traiteCode((doc[MesConstantes.code] as List<dynamic>)[int.parse(code)].toString(), idUti,db,context, tempo);
      }else{
        Usine.montreBiscotte(context, "Code invalide", ticket);
      }
    }else{
      Usine.montreBiscotte(context, "Une erreur est survenue", ticket);
    }
  }else{
    Usine.montreBiscotte(context, "Entrez un code numérique valide!", ticket);
  }

}
