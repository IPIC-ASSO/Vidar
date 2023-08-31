import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:vidar/AppCouleur.dart';
import 'package:vidar/patrons/OutilsUtiles.dart';
import 'package:vidar/usineDeBiscottesGrillees.dart';

import 'Postier.dart';


class EditeurMessages extends StatefulWidget {

  final String idUt;
  final String titre;
  final String corps;
  final bool defaut;
  final bool nouveau;

  const EditeurMessages({super.key, required this.titre, required this.corps, this.defaut= false, this.nouveau=false, required this.idUt});

  @override
  State<EditeurMessages> createState() => _EditeurMessagesState();
}

class _EditeurMessagesState extends State<EditeurMessages> with TickerProviderStateMixin {


  TextEditingController titre = TextEditingController();
  TextEditingController corps = TextEditingController();
  late FlutterTts monTTS;

  @override
  void initState() {
    super.initState();
    OutilsOutils.ConfigureTTS().then((value) => monTTS=value);
    setState(() {
      titre.text = widget.titre;
      corps.text = widget.corps;
    });
    corps.addListener(() {
      setState(() {
        corps;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Edition de messages"),
      ),
      body: Column(
        children: [
          Padding(padding: const EdgeInsets.all(10),child:ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppCouleur.principal,
              foregroundColor : AppCouleur.white,
              minimumSize: const Size.fromHeight(50),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10.0)
              ),
            ),
            onPressed: corps.text.isNotEmpty?()=>{monTTS.speak(corps.text)}:null,
            icon: const Icon(Icons.volume_up_rounded),
            label: const Text("Lire le texte", ),
          ),),
          Expanded(flex:0,child: Padding(
            padding: const EdgeInsets.all(10),
            child: TextField(
              controller: titre,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'Intitulé',
                hintText: "Intitulé",
              ),
            ),
          ),),
          Expanded(flex:1,child: Padding(
            padding: const EdgeInsets.all(10),
            child: TextField(
              textAlignVertical: TextAlignVertical.top,
              maxLines: null,
              expands: true,
              controller: corps,
              keyboardType: TextInputType.multiline,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'Message',
                hintText: "Corps du message",
              ),
            ),
          ),),
          Padding(padding: const EdgeInsets.symmetric(vertical: 5,horizontal: 10),child:ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppCouleur.eco,
              foregroundColor : AppCouleur.white,
              minimumSize: const Size.fromHeight(50),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10.0)
              ),
            ),
            onPressed: () async {
              if(widget.defaut && titre.text == widget.titre){
                Usine.montreBiscotte(context,"Pour modifier un message par défaut, vous devez d'abord changer l'intitulé", this);
              }else if(titre.text.isNotEmpty && corps.text.isNotEmpty){
                final resultat = await laPoste(
                        firebaseFirestore: FirebaseFirestore.instance)
                    .EnregistreMessage(
                        widget.idUt, widget.titre, titre.text, corps.text);
                if (resultat == 0) {
                  ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Enregistré !'),
                        backgroundColor: AppCouleur.secondaire,
                        behavior: SnackBarBehavior.floating,
                      )
                  );
                  Navigator.of(context).pop();
                } else {
                  Usine.montreBiscotte(context, "Une erreur est survenue!", this);
                }
              }else{
                Usine.montreBiscotte(context, "Oups, des champs sont encore vides!", this);
              }
            },
            icon: const Icon(Icons.save),
            label: const Text("Enregistrer", style: TextStyle(color: AppCouleur.white),),
          ),),
          Padding(padding: const EdgeInsets.all(10),child:ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppCouleur.banni,
              foregroundColor : AppCouleur.white,
              minimumSize: const Size.fromHeight(50),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10.0)
              ),
            ),
            onPressed:(widget.nouveau || widget.defaut)?null:() async {
              final resultat = await laPoste(firebaseFirestore: FirebaseFirestore.instance).supprimeMessage(widget.idUt, widget.titre);
              if(resultat==0) {
                ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Supprimé !'),
                      backgroundColor: AppCouleur.secondaire,
                      behavior: SnackBarBehavior.floating,
                    )
                );
                Navigator.of(context).pop();
              } else {
                Usine.montreBiscotte(context, "Une erreur est survenue!", this);
              }
            },
            icon: const Icon(Icons.delete),
            label: const Text("Supprimer", ),
          ),),
        ],
      ),
    );
  }

}