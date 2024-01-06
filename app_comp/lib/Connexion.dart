import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:vidar/Postier.dart';
import 'package:vidar/main.dart';
import 'package:vidar/patrons/MesConstantes.dart';
import 'package:vidar/patrons/convDeListe.dart';

import 'AppCouleur.dart';
import 'usineDeBiscottesGrillees.dart';

class Connexion extends StatefulWidget {

  final String tempo;

  const Connexion({super.key, this.tempo = ""});

  @override
  State<Connexion> createState() => _ConnexionState();
}

class _ConnexionState extends State<Connexion> with TickerProviderStateMixin{

  FirebaseFirestore db = FirebaseFirestore.instance;
  late TabController controleTable ;
  TextEditingController mail_co = TextEditingController();
  TextEditingController mdp_co = TextEditingController();
  TextEditingController mail_ins = TextEditingController();
  TextEditingController pseudo = TextEditingController();
  TextEditingController mdp_ins = TextEditingController();
  static final auth = FirebaseAuth.instance;
  bool mdpVisible = true;

  @override
  void initState() {
    super.initState();
    controleTable = TabController(length: 2, vsync: this);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text("Authentification",),
        bottom: TabBar(
          controller: controleTable,
          tabs: const [
            Tab(icon: Icon(Icons.login), child:Text("Connexion",textAlign: TextAlign.center,)),
            Tab(icon: Icon(Icons.nature_people_outlined), child:Text("Inscription",textAlign: TextAlign.center,)),
          ]
        )
      ),
      body: Column(children:[
          Container(
            width: 500,
              alignment: Alignment.center,
              padding: const EdgeInsets.all(10),
              child: Text(
                'Vidar\nplateforme de communication',
                style: TextStyle(
                    color: AppCouleur().quartenaire,
                    fontWeight: FontWeight.w500,
                    fontSize: 30),
                textAlign: TextAlign.center,
              )),
          Expanded( child: TabBarView(
            controller: controleTable,
            children: [
              Padding(
                padding: const EdgeInsets.all(10),
                child: ListView(
                  shrinkWrap: true,
                  children: <Widget>[
                    Container(
                      padding: const EdgeInsets.all(10),
                      child: TextField(
                        controller: mail_co,
                        keyboardType: TextInputType.emailAddress,
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                          labelText: 'Email',
                          hintText: "adresse email",
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.fromLTRB(10, 10, 10, 0),
                      child: TextField(
                        obscureText: mdpVisible,
                        controller: mdp_co,
                        onSubmitted: (value) => connecte(),
                        decoration: InputDecoration(
                          border: const OutlineInputBorder(),
                          labelText: 'Mot de passe',
                          hintText: "Mot de passe",
                          suffixIcon: IconButton(onPressed: (){setState(() {
                            mdpVisible = !mdpVisible;
                          });}, icon: Icon(mdpVisible? Icons.visibility: Icons.visibility_off)),
                        ),
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        _showMyDialog();
                      },
                      child: const Text('Mot de passe oublié'),
                    ),
                    Container(
                        height: 70,
                        padding: const EdgeInsets.fromLTRB(10, 10, 10, 10),
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.all(5),
                            backgroundColor: AppCouleur().secondaire,
                            foregroundColor : AppCouleur.white,
                            minimumSize:Size(MediaQuery.of(context).size.width/(MediaQuery.of(context).size.aspectRatio>1?2:1),50),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10.0)
                            ),
                          ),
                          child: const Text('Se connecter',style: TextStyle(fontSize: 18),),
                          onPressed: () {
                            connecte();
                          },
                        )
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        const Text('Pas encore inscrit?'),
                        TextButton(
                          child: const Text(
                            'S\'inscrire',
                            style: TextStyle(fontSize: 14),
                          ),
                          onPressed: () {
                            controleTable.animateTo(1);
                          },
                        )
                      ],
                    ),
                  ],
                )),
              Padding(
              padding: const EdgeInsets.all(10),
              child: ListView(
                shrinkWrap: true,
                children: <Widget>[
                  Container(
                    padding: const EdgeInsets.all(10),
                    child: TextField(
                      controller: mail_ins,
                      keyboardType: TextInputType.emailAddress,
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        labelText: 'Email',
                        hintText: "Adresse Email",
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.all(10),
                    child: TextField(
                      controller: pseudo,
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        labelText: 'Nom d\'utilisateur',
                        hintText: "Nom d'utilisateur",
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.fromLTRB(10, 10, 10, 0),
                    child: TextField(
                      controller: mdp_ins,
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        labelText: 'Mot de passe',
                        hintText: "Mot de passe",
                      ),
                    ),
                  ),

                  Container(
                      height: 70,
                      padding: const EdgeInsets.fromLTRB(10, 10, 10, 10),
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.all(5),
                          backgroundColor: AppCouleur().secondaire,
                          foregroundColor : AppCouleur.white,
                          minimumSize:Size(MediaQuery.of(context).size.width/(MediaQuery.of(context).size.aspectRatio>1?2:1),50),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10.0)
                          ),
                        ),
                        child: const Text(
                          "S'inscrire", style: TextStyle(fontSize: 18),),
                        onPressed: () {
                          nouvUti();
                        },
                      )
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      const Text('Déjà inscrit?'),
                      TextButton(
                        child: const Text(
                          'Se connecter',
                          style: TextStyle(fontSize: 14),
                        ),
                        onPressed: () {
                          controleTable.animateTo(0);
                        },
                      )
                    ],
                  ),
                ],
              )
            )
            ],
          ),
        )/*,Expanded(flex:0,child:
            Padding(
              padding: EdgeInsets.all(15),
              child: ElevatedButton(
                style:ElevatedButton.styleFrom(
                  backgroundColor: AppCouleur.tertiaire,
                  foregroundColor : AppCouleur.white,
                  fixedSize:Size(MediaQuery.of(context).size.width/(MediaQuery.of(context).size.aspectRatio>1?2:1),50),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.0)
                  ),
                ),
                onPressed: (){},
                child: Text("Continuer sans se connecter"),
              ),
            )
        ),*/
    ]));
  }

  Future<void> resetPassword({required String email}) async {
    try{
      await auth
          .sendPasswordResetEmail(email: email)
          .then((value) => Usine.montreBiscotte(context, 'Envoyé!', this, true));
    }on FirebaseAuthException catch (e) {
      log(e.code);
      Usine.montreBiscotte(context, 'Une erreur est survenue. \nL\'accès à la Base données a échoué ', this);
    }catch(e){
      Usine.montreBiscotte(context, 'Une erreur est survenue', this);
    }
    return;
  }

  Future<void> _showMyDialog() async {
    final TextEditingController mailControl = TextEditingController();
    return showDialog<void>(
      context: context,
      barrierDismissible: true, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Réinitialiser le mot de passe'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                const Padding(padding: EdgeInsets.all(10),
                    child:Text('Veuillez rentrer votre adresse e-mail\nUn lien de récupération va vous être envoyé (pensez à vérifier les spams)')),
                TextField(
                  controller: mailControl,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: 'email',
                    hintText: "adresse email",
                  ),
                ),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Envoyer'),
              onPressed: () async{
                if(mailControl.text.isNotEmpty) {
                  await resetPassword(email: mailControl.text);
                  Navigator.of(context).pop();
                }else {
                  Usine.montreBiscotte(context, "Oups, il nous faut une adresse e-mail", this);
                }
              },
            ),
            MaterialButton(onPressed: (){Navigator.of(context).pop();}, child: const Text('Annuler'),),
          ],
        );
      },
    );
  }

  Future<void> connecte() async {
    if (auth.currentUser!=null && widget.tempo.isEmpty){
      //Pouf il est connecté ! :=)
    }else if(mail_co.text.isNotEmpty && mdp_co.text.isNotEmpty) {
      try {
        ScaffoldMessenger.of(context).showSnackBar( const SnackBar(content: Text('Connexion...'),));
        if(widget.tempo.isNotEmpty){
          final uti = await auth.signInWithEmailAndPassword(email: mail_co.text, password: mdp_co.text);
          await changeAnonyme(uti.user!.uid);
        }else{
          await auth.signInWithEmailAndPassword(email: mail_co.text, password: mdp_co.text);
        }
      } on FirebaseAuthException catch (e) {
        if (e.code == 'user-not-found') {
          Usine.montreBiscotte(context, "Utilisateur introuvable", this);
        } else if (e.code == 'wrong-password') {
          Usine.montreBiscotte(context, "Mot de passe incorrect", this);
        }else if(e.code == 'too-many-requests'){
          Usine.montreBiscotte(context, "L'accès à ce compte a été temporairement bloqué en raison de nombreuses tentatives de connexion. Veuillez réessayer plus tard", this);
        }else{
          Usine.montreBiscotte(context, "impossible de contacter la base données", this);
          log(e.code);
        }
      } catch (e) {
        log(e.toString());
        Usine.montreBiscotte(context, "Une erreur est survenue", this);
      }
    }else{
      Usine.montreBiscotte(context, "Oups, vous n'avez pas rempli tous les champs !", this);
    }
  }

  nouvUti() async{
    if(mail_ins.text.isNotEmpty && pseudo.text.isNotEmpty && mdp_ins.text.isNotEmpty){
      try {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Chargement...')));
        if(widget.tempo.isNotEmpty){
          final credit = EmailAuthProvider.credential(email: mail_ins.text, password: mdp_ins.text);
          final creditUti = await FirebaseAuth.instance.currentUser?.linkWithCredential(credit);
          await laPoste(firebaseFirestore: db).creeUti(creditUti!.user!.uid,pseudo.text,);
          Navigator.of(context).push(PageRouteBuilder(
            pageBuilder: (_, __, ___) => const MyHomePage(),
            transitionDuration: const Duration(milliseconds: 500),
            transitionsBuilder: (_, a, __, c) => FadeTransition(opacity: a, child: c),
          ));
        }else{
          final credit = await auth.createUserWithEmailAndPassword(email: mail_ins.text.replaceAll(' ', ''), password: mdp_ins.text,);
          if (credit.user != null) {
            await laPoste(firebaseFirestore: db).creeUti(credit.user!.uid,pseudo.text,);
          }else{
            Usine.montreBiscotte(context, "jeton invalide", this);
          }
        }
      } on FirebaseAuthException catch (e) {
        log(e.code);
        switch (e.code){
          case'weak-password':
            Usine.montreBiscotte(context, "Mot de passe trop faible", this);
            break;
          case 'email-already-in-use':
            Usine.montreBiscotte(context, "Adresse mail déjà utilisée par un utilisateur", this);
            break;
          case 'invalid-email':
            Usine.montreBiscotte(context, "Adresse mail non valide", this);
            break;
          case "provider-already-linked":
            Usine.montreBiscotte(context, "Compte déjà lié à un compte existant", this);
            break;
          case "invalid-credential":
            Usine.montreBiscotte(context, "Le fournisseur de jetons est un escroc", this);
            break;
          case "credential-already-in-use":
            Usine.montreBiscotte(context, "Crédit déjà utilisé", this);
            break;
          default:
            Usine.montreBiscotte(context, "Inscription impossible", this);
        }
      } catch (e) {
        log(e.toString());
        Usine.montreBiscotte(context, "Une erreur est survenue", this);
      }
    }else{
      Usine.montreBiscotte(context, "Oups! Vous n'avez pas rempli tous les champs", this);
    }
  }

  Future<void> changeAnonyme(String uti) async {
    final QuerySnapshot<Discussion> listeDiscussions = await laPoste(firebaseFirestore: db).prendConvStatique();
    final theBat = db.batch();
    for(QueryDocumentSnapshot<Discussion> element in listeDiscussions.docs){
      if(element.data().utilisateur1 == widget.tempo || element.data().utilisateur2 == widget.tempo){
        //met à jour liste cov
        DocumentReference docRefConv = db.collection(MesConstantes.cheminMessages).doc(element.id);
        DocumentReference docRef = db.collection(MesConstantes.cheminListeMessages).doc(element.id.replaceAll(widget.tempo, uti));
        final Discussion discussion = element.data();
        if (discussion.utilisateur1 == widget.tempo)discussion.utilisateur1 = uti;
        else discussion.utilisateur2 = uti;
        theBat.set(docRef, discussion.toFirestore());
        //met à jour conv en elles même
        DocumentReference docRefnouvConv = db.collection(MesConstantes.cheminMessages).doc(element.id.replaceAll(widget.tempo, uti));
        final DocumentSnapshot maConv = await db.doc(docRefConv.path).get();
        theBat.set(docRefnouvConv, maConv.data());
        theBat.delete(docRefConv);
        theBat.delete(element.reference);
      }
    }
    final DocumentReference docRef4 = db.collection(MesConstantes.cheminUtilisateur).doc(widget.tempo);
    theBat.delete(docRef4);
    await theBat.commit();
    Navigator.of(context).push(PageRouteBuilder(
      pageBuilder: (_, __, ___) => const MyHomePage(),
      transitionDuration: const Duration(milliseconds: 500),
      transitionsBuilder: (_, a, __, c) => FadeTransition(opacity: a, child: c),
    ));
  }
}