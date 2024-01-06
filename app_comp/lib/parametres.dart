import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:vidar/AppCouleur.dart';
import 'package:vidar/Postier.dart';
import 'package:vidar/usineDeBiscottesGrillees.dart';

import 'patrons/convDeListe.dart';



class Parametres extends StatefulWidget {

  final bool vitefait;

  const Parametres({super.key,this.vitefait=false});

  @override
  State<Parametres> createState() => _ParametresState();
}

class _ParametresState extends State<Parametres> with TickerProviderStateMixin {

  FirebaseAuth auth = FirebaseAuth.instance;
  late final SharedPreferences prefs;
  String voix = "casser la voix";
  double vitesse = 0.5;
  TextEditingController pseudo = TextEditingController();
  TextEditingController mdp = TextEditingController();
  late laPoste monPostier;
  int valeur = 0;
  bool azizlumiere = false;
  late  MaterialStateProperty<Icon?> Icontombe;

  @override
  void initState() {
    super.initState();
    Icontombe =
        MaterialStateProperty.resolveWith<Icon?>((Set<MaterialState> states) {
            if (azizlumiere) {
              return const Icon(Icons.nightlight_outlined);
            }
            return const Icon(Icons.sunny);
          },
        );
    monPostier = laPoste(firebaseFirestore: FirebaseFirestore.instance);
    SharedPreferences.getInstance().then((value) {
      prefs = value;
      setState(() {
        voix = prefs.getString("voix")??"Karen";
        vitesse = prefs.getDouble("vitesse")??0.5;
        azizlumiere = prefs.getBool("nuit")??false;
      });
    });
    monPostier.prendPseudo(auth.currentUser!.uid).then((value) {
     setState(() {
       pseudo.text = value;
     });
    });

  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Container(
          width: double.infinity,
          decoration: const BoxDecoration(
          border:  Border(
          bottom: BorderSide(width: 8.0, color: AppCouleur.tete),
            ),
          ),
          padding: const EdgeInsets.fromLTRB(0,25,0,10),
          child: const Text(" Paramètres ", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18), textAlign: TextAlign.center,)),
        automaticallyImplyLeading: widget.vitefait,
      ),
      body: ListView(
        shrinkWrap: true,
        children: [
          
          Padding(padding:const EdgeInsets.all(5),child:ExpansionTile(
            title: const Text('Compte'),
            leading: const Icon(Icons.manage_accounts),
            textColor: Colors.black,
            collapsedTextColor: Colors.black,
            collapsedBackgroundColor: AppCouleur().grisTresClair,
            iconColor: Colors.black,
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.all(10),
                child: ElevatedButton.icon(
                  onPressed: (){
                    showDialog(context: context, builder: (context)=> AlertDialog(
                      title: const Text("Changer le pseudo"),
                      content: TextField(
                        textInputAction:TextInputAction.done,
                        keyboardType: TextInputType.text,
                        textCapitalization: TextCapitalization.sentences,
                        controller: pseudo,
                        decoration: const InputDecoration(
                            border: OutlineInputBorder(),
                            hintText: 'Pseudo'
                        ),
                        onSubmitted: (value) {
                          changePseudo();
                        },
                      ),
                      actions: [
                        MaterialButton(onPressed: ()=>{changePseudo()},child: const Text("Valider"),),
                        TextButton(onPressed: ()=>{Navigator.of(context).pop()},child: const Text("Annuler"),)
                      ],
                    ));
                  },
                  icon: const Icon(Icons.nat),
                  label: const Text("Changer le pseudo"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).primaryColor,
                    foregroundColor : AppCouleur.white,
                    minimumSize:Size(MediaQuery.of(context).size.width/(MediaQuery.of(context).size.aspectRatio>1?2:1),50),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10.0)
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(10),
                child: ElevatedButton.icon(
                  onPressed: (){
                    showDialog(context: context, builder: (context)=> AlertDialog(
                      title: const Text("Changer le mot de passe"),
                      content: TextField(
                        textInputAction:TextInputAction.done,
                        keyboardType: TextInputType.text,
                        textCapitalization: TextCapitalization.sentences,
                        controller: mdp,
                        decoration: const InputDecoration(
                            border: OutlineInputBorder(),
                            hintText: 'Nouveau mot de passe'
                        ),
                        onSubmitted: (value) {
                          changeMdp();
                        },
                      ),
                      actions: [
                        MaterialButton(onPressed: ()=>{changeMdp()},child: const Text("Valider"),),
                        TextButton(onPressed: ()=>{Navigator.of(context).pop()},child: const Text("Annuler"),)
                      ],
                    ));
                  },
                  icon: const Icon(Icons.password),
                  label: const Text("Changer le mot de passe"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).primaryColor,
                    foregroundColor : AppCouleur.white,
                    minimumSize:Size(MediaQuery.of(context).size.width/(MediaQuery.of(context).size.aspectRatio>1?2:1),50),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10.0)
                    ),
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.symmetric(vertical:0, horizontal:MediaQuery.of(context).size.width*(MediaQuery.of(context).size.aspectRatio>1?0.25:0.1)),
                child: const Divider(
                  thickness: 3,
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(10),
                child: ElevatedButton.icon(
                  onPressed: ()=>{auth.signOut()},
                  icon: const Icon(Icons.logout),
                  label: const Text("Se déconnecter"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppCouleur().secondaire,
                    foregroundColor : AppCouleur.white,
                    minimumSize:Size(MediaQuery.of(context).size.width/(MediaQuery.of(context).size.aspectRatio>1?2:1),50),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10.0)
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(10),
                child: ElevatedButton.icon(
                  onPressed: (){
                    showDialog(context: context, builder: (context)=> AlertDialog(
                      title: const Text("Supprimer le compte"),
                      content: const Text("Etes vous sûr de vouloir supprimer votre compte?\nCette action et irréversible et toutes vos messages seront effacés."),
                      actions: [
                        MaterialButton(onPressed: ()=>{suuupprime()},child: const Text("Supprimer"),),
                        TextButton(onPressed: ()=>{Navigator.of(context).pop()},child: const Text("Annuler"),)
                      ],
                    ));
                  },
                  icon: const Icon(Icons.no_accounts_rounded),
                  label: const Text("Supprimer le compte"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppCouleur.banni,
                    foregroundColor : AppCouleur.white,
                    minimumSize:Size(MediaQuery.of(context).size.width/(MediaQuery.of(context).size.aspectRatio>1?2:1),50),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10.0)
                    ),
                  ),
                ),
              ),
              ],
           ),),
          Padding(padding:const EdgeInsets.all(5),child:ExpansionTile(
            title: const Text('Lecture de texte'),
            leading: const Icon(Icons.volume_up),
            textColor: Colors.black,
            collapsedTextColor: Colors.black,
            collapsedBackgroundColor: AppCouleur().grisTresClair,
            iconColor: Colors.black,
            children: <Widget>[Padding(
                padding: const EdgeInsets.all(10),
                child:Row(
                  children: [
                    const Expanded(flex:0,child: Icon(Icons.record_voice_over)),
                    const Expanded(child: Text("Voix", textAlign: TextAlign.center,)),
                    Expanded(child:ElevatedButton(
                      onPressed: ()=>{montreVoix()},
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Theme.of(context).primaryColor,
                        foregroundColor : AppCouleur.white,
                        minimumSize:Size(MediaQuery.of(context).size.width/(MediaQuery.of(context).size.aspectRatio>1?2:1),50),
                        shape: RoundedRectangleBorder(
                          side:  BorderSide(width: 3.0, color: AppCouleur().grisTresClair),
                          borderRadius: BorderRadius.circular(10.0),
                        ),),
                      child: Text(voix, textAlign: TextAlign.center,),
                    ))
                  ],
                )
              ),
              Padding(
                  padding: const EdgeInsets.all(10),
                  child:Row(
                    children: [
                      const Expanded(flex:0,child: Icon(Icons.speed)),
                      const Expanded(child: Text("Vitesse", textAlign: TextAlign.center,)),
                      Expanded(child:Slider(
                          value: vitesse*4,
                          max: 4.0,
                          onChanged: (double value){
                            prefs.setDouble("vitesse", value/4);
                            setState(() {
                              vitesse = value/4;
                            });
                          }
                      ))
                    ],
                  )
              ),
            ])),
          /*Padding(
            padding: const EdgeInsets.all(10),
            child:Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Text("Mode sombre", textAlign: TextAlign.center,),
                Switch(
                  value: azizlumiere,
                  onChanged: (bool value) {
                    setState(() {
                      azizlumiere = !azizlumiere;
                      if(azizlumiere)MonVidar.of(context).changeTheme(ThemeMode.dark);
                      else MonVidar.of(context).changeTheme(ThemeMode.light);
                      prefs.setBool("nuit", azizlumiere);
                    });
                  },
                ),
                Icon(azizlumiere?Icons.nightlight_outlined:Icons.sunny)
              ],
            ),
          ),*/
          Padding(
            padding: const EdgeInsets.all(10),
            child: ElevatedButton.icon(
              onPressed: ()=>{
                showDialog(context: context, builder: (context)=>const AlertDialog(
                  title: Text("Notes de version"),
                  content: Text("Version 2.1.7\n• Améliorations mineures de l'interface\n• Résolution de bugs affectant les messages pré-enregistrés\n• Nouveau tutoriel"),
                ))
              },
              icon: const Icon(Icons.sticky_note_2_sharp),
              label: const Text("Notes de version"),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppCouleur.tertiaire,
                foregroundColor : AppCouleur.white,
                minimumSize:Size(MediaQuery.of(context).size.width/(MediaQuery.of(context).size.aspectRatio>1?2:1),50),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.0)
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(10),
            child: ElevatedButton.icon(
              onPressed: ()=>{launchUrl(Uri.parse('https://docs.google.com/document/d/1P6C6ESkxnLY3JsDM0D38scITB3YxAliEFzSw1db3X8E/edit?usp=sharing'))},
              icon: const Icon(Icons.security),
              label: const Text("Politique de confidentialité"),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppCouleur.tertiaire,
                foregroundColor : AppCouleur.white,
                minimumSize:Size(MediaQuery.of(context).size.width/(MediaQuery.of(context).size.aspectRatio>1?2:1),50),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.0)
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(10),
            child: Apropos(context)
          ),
         ]
      ),
    );
  }

  Widget Apropos(BuildContext context){

    final ThemeData theme = Theme.of(context);
    final TextStyle textStyle = theme.textTheme.bodyMedium!;
    final List<Widget> aboutBoxChildren = <Widget>[
      const SizedBox(height: 24),
      RichText(
        text: TextSpan(
          children: <TextSpan>[
            TextSpan(
                style: textStyle,
                text: "Application de messagerie instantanée développée par IPIC-ASSO, pour aider les personnes muettes ou aphasiques.\n"
                    'Pour en savoir plus, poser une question, effectuer une réclamation... '
                    'Ecrivez nous à l\'adresse: '),
            TextSpan(
              text: 'contact@ipic-asso.fr',
              style: const TextStyle(color: Colors.blue),
              recognizer: TapGestureRecognizer()
                ..onTap = () async {
                  await Clipboard.setData(const ClipboardData(text: "contact@ipic-asso.fr"));
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                    content: Text('copié !'),
                  ));
                },
            ),
            TextSpan(
              text: ' ou visitez notre site: ',
              style: textStyle,
            ),
            TextSpan(
              text: 'https://www.ipic-asso.fr',
              style: const TextStyle(color: Colors.blue),
              recognizer: TapGestureRecognizer()
                ..onTap = () {
                  launchUrl(Uri.parse('https://www.ipic-asso.fr'));
                },
            ),
          ],
        ),
      ),
    ];

    return Container(
        color: AppCouleur.white,
        child:AboutListTile(
      icon: const Icon(
        Icons.contact_mail,
      ),
      applicationIcon: Tab(icon: Image.asset("assets/images/IPIC_logo_petit.png",width: 40,)),
      applicationName: 'Vidar',
      applicationVersion: '2.1.7',
      applicationLegalese: '© 2023 IPIC-ASSO',
      aboutBoxChildren: aboutBoxChildren,
      child: Container(
        padding: const EdgeInsets.all(2),
        decoration: BoxDecoration(

          borderRadius: BorderRadius.circular(10)
        ),
        child:const Text('Nous contacter', textAlign: TextAlign.center,),
      )
    ));
  }

  void changePseudo() async{
    if(pseudo.text.isEmpty){
      Usine.montreBiscotte(context, "Le champs est vide!", this);
    }else{
      try{
        await monPostier.changePseudo(auth.currentUser!.uid,pseudo.text);
        Navigator.of(context).pop();
        Usine.montreBiscotte(context, "Bonjour ${pseudo.text}! ", this, true);
      }catch (e){
        log(e.toString());
        Usine.montreBiscotte(context, "Une erreur est survenue ", this);
      }
    }
  }

  Future<void> changeMdp() async {
    if(mdp.text.isEmpty){
      Usine.montreBiscotte(context, "Le champs est vide!", this);
    }else{
      try{
        await auth.currentUser!.updatePassword(mdp.text);
        Navigator.of(context).pop();
        Usine.montreBiscotte(context, "Mot de passe enregistré! ", this, true);
      }catch (e){
        log(e.toString());
        Usine.montreBiscotte(context, "Une erreur est survenue ", this);
      }
    }
  }

  montreVoix()async {
    FlutterTts monTTs = FlutterTts();
    monTTs.setSpeechRate(0.3);
    List<Map<String,String>> lesvoix = ((await  FlutterTts().getVoices) as List<Object?>).map((e) => (e as Map).cast<String,String>()).toList();
    showDialog(context: context, builder: (context)=>AlertDialog(
      title: const Text('Choix de la voix'),
      content: StatefulBuilder(
        builder: (BuildContext context, StateSetter setState) {return SizedBox(height:1000,width:1000,child:ListView(
        shrinkWrap: true,
        children: List<Widget>.generate(lesvoix.length, (index){
            final indice = index;
            if(index==0)
              return const Padding(padding: EdgeInsets.all(10),child: Text("Restez longtemps appuyez sur une voix pour l'écouter", style: TextStyle(fontStyle: FontStyle.italic),),);
            return GestureDetector(
              onLongPress: () async {
                await monTTs.setVoice(lesvoix[index]);
                monTTs.speak("Bonjour");
                },
              child:RadioListTile(
                onChanged: (value){
                  setState(() {
                    valeur = value ?? 0;
                  });
                },
                groupValue: valeur,
                value:indice,
                title: Text(lesvoix[index]["name"]??"indisponible"),
            ));}))
      );}),
        actions: [
          TextButton(onPressed: (){
            prefs.setString("voix", lesvoix[valeur]["name"]??"Karen");
            prefs.setString("localite", lesvoix[valeur]["locale"]??"fr-FR");
            setState(() {
              voix = lesvoix[valeur]["name"]??" ";
            });
            Navigator.of(context).pop();
          }, child: const Text("Valider"))
      ],
    ));
  }

  suuupprime() async {
    bool ok = true;
    String id = auth.currentUser!.uid;
    final QuerySnapshot<Discussion> listeDiscussions = await monPostier.prendConvStatique2(id);
    for(QueryDocumentSnapshot<Discussion> element in listeDiscussions.docs) {
      monPostier.suprConv(element.data().utilisateur1 + element.data().utilisateur2, id, element.data().supr)
          .onError((error, stackTrace) {
        Usine.montreBiscotte(context, "Une erreur est survenue", this, false);
        ok = false;
        return error.toString();
      });
    }
    await monPostier.suprUtilisateur(id);
    await auth.currentUser!.delete().catchError((error, stackTrace) {
      ok = false;
      if (error.toString=="requires-recent-login")
          Usine.montreBiscotte(context, "Une erreur est survenue\nVotre dernière connexion remonte à trop longtemps. Déconnectez vous puis reconnectez vous.", this, false);
      else
        Usine.montreBiscotte(context, "Une erreur est survenue", this, false);
      });
    if(ok){
      Usine.montreBiscotte(context, "Le compte a été supprimé avec succès", this,true);
      auth.signOut();
    }
  }
}